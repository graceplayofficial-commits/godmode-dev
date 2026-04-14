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
