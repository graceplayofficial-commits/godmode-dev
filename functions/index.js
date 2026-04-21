const { onRequest } = require("firebase-functions/v2/https");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { defineSecret } = require("firebase-functions/params");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

const YOUTUBE_API_KEY = defineSecret("YOUTUBE_API_KEY");

// ── CSV에서 가져온 채널 핸들 목록 ──
const CHANNEL_HANDLES = [
  "becoming.yeshin", "GodLife_Bible", "hepbsibah", "SwanRia",
  "DreaminBible", "bible1cup", "CompassionKR", "CBSJOY",
  "cbsrenew", "현승원TV", "Waker_Ryua", "전충만-n4e",
  "WELOVECREATIVETEAM", "hillsongworship", "swordgrace",
  "jaljalroad", "말씀지도", "헤븐스타", "moreh_story",
  "only_biblelove", "Little_TeleV", "durannobooks",
  "GOODTV_official", "JOOYANG_Channel", "GODFLEX_",
  "haetnim5991", "주님을전하는자", "christian_playground",
  "JEBS.official", "officialchwork",
];

// ── YouTube API 호출 헬퍼 ──
async function ytFetch(path, params, apiKey) {
  const url = new URL(`https://www.googleapis.com/youtube/v3/${path}`);
  params.key = apiKey;
  Object.entries(params).forEach(([k, v]) => url.searchParams.set(k, v));
  const res = await fetch(url.toString());
  if (!res.ok) throw new Error(`YouTube API error: ${res.status} ${await res.text()}`);
  return res.json();
}

// ── 핸들 → 채널 정보 조회 ──
async function resolveChannel(handle, apiKey) {
  const data = await ytFetch("channels", {
    forHandle: handle,
    part: "snippet,contentDetails",
  }, apiKey);
  if (!data.items || data.items.length === 0) return null;
  const ch = data.items[0];
  return {
    channelId: ch.id,
    name: ch.snippet.title,
    handle: handle,
    thumbnail: ch.snippet.thumbnails?.default?.url || "",
    uploadsPlaylistId: ch.contentDetails?.relatedPlaylists?.uploads || "",
  };
}

// ── 업로드 재생목록에서 영상 ID 수집 (페이지네이션) ──
async function fetchAllVideoIds(playlistId, apiKey, afterDate = null) {
  const videoIds = [];
  let pageToken = "";
  let shouldStop = false;

  while (!shouldStop) {
    const params = {
      playlistId,
      part: "snippet",
      maxResults: "50",
    };
    if (pageToken) params.pageToken = pageToken;

    const data = await ytFetch("playlistItems", params, apiKey);

    for (const item of (data.items || [])) {
      const publishedAt = item.snippet?.publishedAt;
      // 증분 수집: afterDate 이후 영상만
      if (afterDate && new Date(publishedAt) <= new Date(afterDate)) {
        shouldStop = true;
        break;
      }
      videoIds.push({
        videoId: item.snippet?.resourceId?.videoId,
        title: item.snippet?.title,
        thumbnail: item.snippet?.thumbnails?.high?.url ||
                   item.snippet?.thumbnails?.default?.url || "",
        publishedAt,
      });
    }

    pageToken = data.nextPageToken || "";
    if (!pageToken) break;
  }

  return videoIds;
}

// ── 영상 상세 (duration) 조회 → Shorts 필터 ──
async function filterShorts(videoItems, apiKey) {
  const shorts = [];
  // 50개씩 배치 처리
  for (let i = 0; i < videoItems.length; i += 50) {
    const batch = videoItems.slice(i, i + 50);
    const ids = batch.map((v) => v.videoId).join(",");
    const data = await ytFetch("videos", {
      id: ids,
      part: "contentDetails",
    }, apiKey);

    for (const detail of (data.items || [])) {
      const duration = parseDuration(detail.contentDetails?.duration || "");
      if (duration > 0 && duration <= 60) {
        const original = batch.find((v) => v.videoId === detail.id);
        if (original) {
          shorts.push({ ...original, duration });
        }
      }
    }
  }
  return shorts;
}

// ── ISO 8601 duration → 초 ──
function parseDuration(iso) {
  const match = iso.match(/PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?/);
  if (!match) return 0;
  const h = parseInt(match[1] || "0", 10);
  const m = parseInt(match[2] || "0", 10);
  const s = parseInt(match[3] || "0", 10);
  return h * 3600 + m * 60 + s;
}

// ── Firestore에 채널 + 영상 저장 ──
async function saveChannel(channelInfo) {
  await db.collection("channels").doc(channelInfo.channelId).set(channelInfo, { merge: true });
}

async function saveVideos(videos, channelInfo) {
  // 490개씩 끊어서 각각 새 batch 생성
  for (let i = 0; i < videos.length; i += 490) {
    const chunk = videos.slice(i, i + 490);
    const batch = db.batch();
    for (const v of chunk) {
      const ref = db.collection("videos").doc(v.videoId);
      batch.set(ref, {
        videoId: v.videoId,
        channelId: channelInfo.channelId,
        channelName: channelInfo.name,
        title: v.title,
        thumbnail: v.thumbnail,
        publishedAt: v.publishedAt,
        duration: v.duration,
        category: "전체",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });
    }
    await batch.commit();
  }
}

// ── 메인 수집 로직 ──
async function collectShorts(apiKey, fullFetch = false) {
  const results = { channels: 0, videos: 0, errors: [] };

  for (const handle of CHANNEL_HANDLES) {
    try {
      // 1. 채널 정보 조회
      const channelInfo = await resolveChannel(handle, apiKey);
      if (!channelInfo) {
        results.errors.push(`${handle}: 채널 없음`);
        continue;
      }

      // 2. 마지막 수집 시점 확인
      let afterDate = null;
      if (!fullFetch) {
        const doc = await db.collection("channels").doc(channelInfo.channelId).get();
        if (doc.exists) {
          afterDate = doc.data().lastFetchedAt || null;
        }
      }

      // 3. 영상 ID 수집
      const videoItems = await fetchAllVideoIds(
          channelInfo.uploadsPlaylistId, apiKey, afterDate,
      );

      if (videoItems.length === 0) {
        // 채널 정보만 업데이트
        channelInfo.lastFetchedAt = new Date().toISOString();
        await saveChannel(channelInfo);
        results.channels++;
        continue;
      }

      // 4. Shorts 필터링 (60초 이하)
      const shorts = await filterShorts(videoItems, apiKey);

      // 5. 저장
      channelInfo.lastFetchedAt = new Date().toISOString();
      channelInfo.shortsCount = shorts.length;
      await saveChannel(channelInfo);
      await saveVideos(shorts, channelInfo);

      results.channels++;
      results.videos += shorts.length;
      console.log(`✅ ${channelInfo.name}: ${shorts.length} shorts`);
    } catch (err) {
      results.errors.push(`${handle}: ${err.message}`);
      console.error(`❌ ${handle}:`, err.message);
    }
  }

  return results;
}

// ══════════════════════════════════════
// Cloud Functions
// ══════════════════════════════════════

// 1) 최초 풀 수집 (HTTP 트리거 — 수동 실행)
exports.fetchAllShorts = onRequest(
    { timeoutSeconds: 540, memory: "512MiB", secrets: [YOUTUBE_API_KEY], invoker: "public" },
    async (req, res) => {
      console.log("🚀 Full fetch starting...");
      const results = await collectShorts(YOUTUBE_API_KEY.value(), true);
      console.log("✅ Full fetch done:", results);
      res.json(results);
    },
);

// 2) 일일 증분 수집 (매일 오전 6시 KST = UTC 21시)
exports.dailyFetchShorts = onSchedule(
    {
      schedule: "0 21 * * *",
      timeZone: "Asia/Seoul",
      timeoutSeconds: 300,
      memory: "256MiB",
      secrets: [YOUTUBE_API_KEY],
    },
    async () => {
      console.log("🔄 Daily incremental fetch starting...");
      const results = await collectShorts(YOUTUBE_API_KEY.value(), false);
      console.log("✅ Daily fetch done:", results);
    },
);

// 3) 채널 목록 조회 (디버그용)
exports.listChannels = onRequest({ invoker: "public" }, async (req, res) => {
  const snapshot = await db.collection("channels").get();
  const channels = snapshot.docs.map((doc) => doc.data());
  res.json({ count: channels.length, channels });
});

// 4) Shorts 목록 조회 (디버그용)
exports.listShorts = onRequest({ invoker: "public" }, async (req, res) => {
  const limit = parseInt(req.query.limit || "20", 10);
  const snapshot = await db.collection("videos")
      .orderBy("publishedAt", "desc")
      .limit(limit)
      .get();
  const videos = snapshot.docs.map((doc) => doc.data());
  res.json({ count: videos.length, videos });
});

// 5) 샘플 커뮤니티 게시물 생성
exports.seedPosts = onRequest({ invoker: "public" }, async (req, res) => {
  const posts = [
    { nickname: "은혜충만", profileEmoji: "🙏", category: "자유", title: "오늘 새벽예배 은혜 넘쳤어요", content: "요즘 새벽예배를 시작했는데 정말 하루가 달라졌어요. 힘들지만 그만큼 은혜가 크네요. 새벽예배 드시는 분들 화이팅입니다! 🔥" },
    { nickname: "말씀묵상러", profileEmoji: "📖", category: "말씀나눔", title: "로마서 8:28 묵상 나눔", content: "\"하나님을 사랑하는 자 곧 그의 뜻대로 부르심을 입은 자들에게는 모든 것이 합력하여 선을 이루느니라\"\n\n요즘 힘든 시간을 보내고 있었는데, 이 말씀이 큰 위로가 됐어요. 지금 겪는 어려움도 하나님의 큰 그림 안에서는 선을 이루는 과정이라는 걸 믿습니다." },
    { nickname: "찬양워십퍼", profileEmoji: "🎵", category: "자유", title: "찬양팀 합류했습니다!", content: "드디어 교회 찬양팀에 합류했어요! 보컬로 참여하게 됐는데 떨리면서도 설레요. 하나님께 최선의 예배를 드리고 싶습니다. 찬양팀 하시는 분들 팁 좀 부탁드려요 😊" },
    { nickname: "기도요청자", profileEmoji: "💪", category: "기도요청", title: "취업 준비 중인데 기도 부탁드려요", content: "대학 졸업 후 취업 준비 중입니다. 면접을 여러 번 봤는데 계속 떨어지고 있어요. 포기하고 싶을 때도 있지만 하나님의 때가 있다고 믿고 있습니다. 중보기도 부탁드립니다 🙏" },
    { nickname: "감사일기", profileEmoji: "✨", category: "간증", title: "교통사고에서 보호받은 간증", content: "지난주 운전 중에 큰 사고가 날 뻔했어요. 앞차가 갑자기 급정거해서 정말 위험한 순간이었는데, 기적적으로 피할 수 있었습니다.\n\n사고 직후에 차를 세우고 감사기도를 드렸어요. 하나님이 정말 살아계시다는 걸 또 한번 경험했습니다." },
    { nickname: "대학부청년", profileEmoji: "⚡", category: "자유", title: "GOD MODE 앱 너무 좋아요!", content: "이 앱 발견하고 매일 들어와요ㅋㅋ 게임도 재밌고 릴스로 기독교 영상 보는 것도 좋아요. 특히 오목은 중독성 있어서 출퇴근 길에 항상 해요 ♟️" },
    { nickname: "선교사지망생", profileEmoji: "🌍", category: "기도요청", title: "단기선교 출발합니다", content: "이번 여름에 캄보디아 단기선교를 떠납니다. 첫 선교라 긴장도 되지만 기대가 더 커요. 현지 아이들에게 복음을 전할 수 있기를 바랍니다. 팀 전체를 위해 기도 부탁드려요! ✈️" },
    { nickname: "말씀암송왕", profileEmoji: "👑", category: "말씀나눔", title: "빌립보서 4:13 암송 챌린지", content: "\"내게 능력 주시는 자 안에서 내가 모든 것을 할 수 있느니라\"\n\n이번 주 암송 말씀입니다. 같이 외워보실 분! 매일 10번씩 소리내어 읽으면 일주일이면 외워져요. 함께 도전해봐요! 💪" },
  ];

  const batch = db.batch();
  for (const post of posts) {
    const ref = db.collection("boards").doc();
    batch.set(ref, {
      uid: "system",
      nickname: post.nickname,
      profileEmoji: post.profileEmoji,
      title: post.title,
      content: post.content,
      category: post.category,
      likeCount: Math.floor(Math.random() * 20) + 1,
      commentCount: 0,
      likedBy: [],
      createdAt: admin.firestore.Timestamp.fromDate(
        new Date(Date.now() - Math.floor(Math.random() * 7 * 24 * 60 * 60 * 1000))
      ),
    });
  }
  await batch.commit();
  res.json({ success: true, count: posts.length });
});

// 6) 임베드 가능 영상 체크
exports.checkEmbeddable = onRequest(
    { timeoutSeconds: 540, memory: "512MiB", secrets: [YOUTUBE_API_KEY], invoker: "public" },
    async (req, res) => {
      const apiKey = YOUTUBE_API_KEY.value();
      const snapshot = await db.collection("videos").get();
      const allIds = snapshot.docs.map((d) => d.data().videoId);
      console.log(`Total videos: ${allIds.length}`);

      let embeddable = 0;
      let notEmbeddable = 0;

      // 50개씩 배치 체크
      for (let i = 0; i < allIds.length; i += 50) {
        const batch = allIds.slice(i, i + 50);
        const ids = batch.join(",");
        const data = await ytFetch("videos", { id: ids, part: "status" }, apiKey);
        for (const item of (data.items || [])) {
          if (item.status && item.status.embeddable) {
            embeddable++;
          } else {
            notEmbeddable++;
          }
        }
      }

      // 임베드 불가 영상 삭제 (query param으로 제어)
      if (req.query.clean === "true") {
        const allDocs = snapshot.docs;
        const notEmbeddableIds = new Set();
        for (let i = 0; i < allIds.length; i += 50) {
          const batch = allIds.slice(i, i + 50);
          const ids = batch.join(",");
          const data = await ytFetch("videos", { id: ids, part: "status" }, apiKey);
          for (const item of (data.items || [])) {
            if (!item.status || !item.status.embeddable) {
              notEmbeddableIds.add(item.id);
            }
          }
        }
        let deleted = 0;
        for (const doc of allDocs) {
          if (notEmbeddableIds.has(doc.data().videoId)) {
            await doc.ref.delete();
            deleted++;
          }
        }
        res.json({ total: allIds.length, embeddable, notEmbeddable, deleted, ratio: `${Math.round(embeddable / allIds.length * 100)}%` });
      } else {
        res.json({ total: allIds.length, embeddable, notEmbeddable, ratio: `${Math.round(embeddable / allIds.length * 100)}%` });
      }
    },
);
