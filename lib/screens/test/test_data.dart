// ══════════════════════════════════════
// GOD MODE — 신앙 테스트 데이터
// ══════════════════════════════════════

class TestDef {
  final String id, title, emoji;
  final List<TQ> questions;
  final List<TestResult> results;
  const TestDef({required this.id, required this.title, required this.emoji, required this.questions, required this.results});

  TestResult getResult(Map<String, int> scores) {
    String top = results.first.id;
    int max = -1;
    for (final r in results) {
      final s = scores[r.id] ?? 0;
      if (s > max) { max = s; top = r.id; }
    }
    return results.firstWhere((r) => r.id == top);
  }
}

class TQ {
  final String question;
  final List<TA> answers;
  const TQ(this.question, this.answers);
}

class TA {
  final String text;
  final Map<String, int> scores;
  const TA(this.text, this.scores);
}

class TestResult {
  final String id, type, emoji, title, description, verse;
  final List<String> traits;
  const TestResult({required this.id, required this.type, required this.emoji, required this.title, required this.description, required this.verse, required this.traits});
}

// ══════════════════════════════════════
// 1. 신앙 성격 MBTI
// ══════════════════════════════════════
final mbtiTest = TestDef(
  id: 'mbti', title: '신앙 성격 MBTI', emoji: '🔮',
  questions: [
    TQ('예배 중 가장 은혜받는 순간은?', [
      TA('찬양할 때 — 마음이 뜨거워진다', {'david': 3, 'mary': 1}),
      TA('말씀 들을 때 — 깊이 생각하게 된다', {'paul': 3, 'nehemiah': 1}),
      TA('기도할 때 — 하나님과 대화하는 느낌', {'esther': 3, 'ruth': 1}),
      TA('교제할 때 — 함께하는 느낌이 좋다', {'peter': 3, 'jonah': 1}),
    ]),
    TQ('힘든 일이 생기면 가장 먼저 하는 것은?', [
      TA('찬양을 듣거나 부르며 위로받는다', {'david': 3}),
      TA('성경에서 답을 찾으려고 한다', {'paul': 3}),
      TA('기도로 하나님께 맡긴다', {'esther': 3, 'mary': 1}),
      TA('믿음의 친구에게 연락한다', {'ruth': 3, 'peter': 1}),
    ]),
    TQ('소그룹에서 나의 역할은?', [
      TA('분위기를 띄우는 에너자이저', {'peter': 3, 'david': 1}),
      TA('말씀을 정리해주는 티처', {'paul': 3}),
      TA('묵묵히 기도로 세워주는 중보자', {'esther': 3, 'mary': 1}),
      TA('실질적으로 도와주는 서포터', {'ruth': 3, 'nehemiah': 1}),
    ]),
    TQ('전도할 때 나의 스타일은?', [
      TA('삶으로 보여주는 것이 최고의 전도', {'ruth': 3, 'mary': 1}),
      TA('논리적으로 복음을 설명한다', {'paul': 3}),
      TA('일단 교회에 데려온다 — 경험이 중요', {'peter': 3}),
      TA('관계를 먼저 쌓고 자연스럽게 나눈다', {'esther': 3, 'jonah': 1}),
    ]),
    TQ('QT(말씀 묵상)를 할 때 나는?', [
      TA('매일 정해진 시간에 체계적으로 한다', {'nehemiah': 3, 'paul': 1}),
      TA('말씀에 깊이 빠져서 오래 묵상한다', {'mary': 3}),
      TA('감성적으로 느끼면서 기도와 함께 한다', {'david': 3, 'esther': 1}),
      TA('솔직히 매일은 어렵지만 할 때 은혜받는다', {'jonah': 3, 'peter': 1}),
    ]),
    TQ('교회에서 가장 하고 싶은 봉사는?', [
      TA('찬양팀 / 워십', {'david': 3}),
      TA('설교 / 성경공부 인도', {'paul': 3}),
      TA('중보기도팀', {'esther': 3}),
      TA('새가족 환영 / 안내', {'peter': 3, 'ruth': 1}),
    ]),
    TQ('하나님의 뜻을 확인하는 방법은?', [
      TA('말씀을 통해 확인한다', {'paul': 3, 'mary': 1}),
      TA('기도 중 마음에 평안이 오는지 본다', {'esther': 3}),
      TA('일단 행동하면서 문이 열리는지 본다', {'peter': 3, 'nehemiah': 1}),
      TA('믿음의 선배에게 조언을 구한다', {'ruth': 3, 'jonah': 1}),
    ]),
    TQ('신앙에서 가장 중요하다고 생각하는 것은?', [
      TA('하나님과의 친밀한 관계', {'david': 3, 'mary': 2}),
      TA('진리를 아는 것 — 바른 신학', {'paul': 3}),
      TA('실천과 순종 — 믿음은 행함', {'nehemiah': 3, 'ruth': 1}),
      TA('사랑과 섬김 — 이웃 사랑', {'ruth': 3, 'esther': 1}),
    ]),
    TQ('리더십 스타일은?', [
      TA('비전을 제시하고 앞에서 이끈다', {'nehemiah': 3, 'peter': 1}),
      TA('가르치고 훈련시킨다', {'paul': 3}),
      TA('섬김으로 뒤에서 받쳐준다', {'ruth': 3, 'mary': 1}),
      TA('열정으로 동기부여한다', {'david': 3, 'peter': 1}),
    ]),
    TQ('성경 인물 중 가장 공감되는 사람은?', [
      TA('실수해도 다시 일어서는 베드로', {'peter': 3}),
      TA('헌신적이고 충성스러운 룻', {'ruth': 3}),
      TA('담대하게 나서는 에스더', {'esther': 3}),
      TA('열정적으로 찬양하는 다윗', {'david': 3}),
    ]),
    TQ('갈등이 생겼을 때 나는?', [
      TA('직접 만나서 솔직하게 이야기한다', {'peter': 3}),
      TA('기도하고 하나님의 때를 기다린다', {'mary': 3, 'esther': 1}),
      TA('중재하고 화해를 이끈다', {'ruth': 3}),
      TA('피하고 싶지만 결국 해결한다', {'jonah': 3}),
    ]),
    TQ('신앙의 성장을 느끼는 순간은?', [
      TA('예전과 다른 반응을 할 때', {'jonah': 3, 'peter': 1}),
      TA('말씀이 더 깊이 이해될 때', {'paul': 3, 'mary': 1}),
      TA('기도 응답을 경험할 때', {'esther': 3, 'david': 1}),
      TA('누군가를 섬기며 기쁠 때', {'ruth': 3, 'nehemiah': 1}),
    ]),
  ],
  results: [
    TestResult(id: 'david', type: '열정적 예배자', emoji: '🎵', title: '다윗형',
      description: '당신은 하나님을 향한 열정이 넘치는 예배자입니다. 찬양과 감사로 하나님께 나아가며, 감정이 풍부하고 진솔합니다. 실수도 하지만 진심으로 회개하고 다시 일어서는 강인함이 있습니다.',
      verse: '"여호와를 기뻐하라 그가 네 마음의 소원을 이루어 주시리로다" (시 37:4)',
      traits: ['열정적인 예배', '감성 풍부', '진솔한 기도', '회복력']),
    TestResult(id: 'paul', type: '논리적 전도자', emoji: '✍️', title: '바울형',
      description: '당신은 말씀을 깊이 연구하고 논리적으로 전달하는 은사가 있습니다. 진리에 대한 확신이 강하고, 가르치는 것을 좋아합니다. 체계적이며 사명감이 뚜렷합니다.',
      verse: '"내게 능력 주시는 자 안에서 내가 모든 것을 할 수 있느니라" (빌 4:13)',
      traits: ['논리적 사고', '가르치는 은사', '강한 사명감', '체계적']),
    TestResult(id: 'esther', type: '담대한 중보자', emoji: '👑', title: '에스더형',
      description: '당신은 기도의 사람이며, 위기 상황에서 담대하게 나설 줄 아는 중보자입니다. 조용하지만 결정적 순간에 강한 믿음을 보여줍니다. 다른 사람을 위해 기도하는 것이 자연스럽습니다.',
      verse: '"이 때를 위하여 네가 왕후의 자리를 얻은 것이 아닌지 누가 아느냐" (에 4:14)',
      traits: ['깊은 기도', '담대한 믿음', '중보의 은사', '위기의 리더십']),
    TestResult(id: 'peter', type: '행동파 리더', emoji: '⚓', title: '베드로형',
      description: '당신은 먼저 행동하고 열정적으로 달려드는 행동파입니다. 실수도 많지만 그만큼 시도도 많습니다. 솔직하고 리더십이 있으며, 실패에서 배우고 성장합니다.',
      verse: '"주여 나를 명하사 물 위로 오라 하소서" (마 14:28)',
      traits: ['행동력', '솔직함', '리더십', '성장하는 믿음']),
    TestResult(id: 'mary', type: '순종하는 묵상가', emoji: '🕊️', title: '마리아형',
      description: '당신은 말씀을 마음에 품고 깊이 묵상하는 사색가입니다. 하나님의 뜻에 순종하며, 조용하지만 깊은 영성을 가지고 있습니다. 겸손하고 신실합니다.',
      verse: '"주의 여종이오니 말씀대로 내게 이루어지이다" (눅 1:38)',
      traits: ['깊은 묵상', '순종', '겸손', '내면의 강인함']),
    TestResult(id: 'nehemiah', type: '실행하는 건축자', emoji: '🧱', title: '느헤미야형',
      description: '당신은 비전을 보고 실행하는 건축자입니다. 계획적이고 조직적이며, 목표를 향해 꾸준히 나아갑니다. 공동체를 세우는 것에 관심이 많고, 기도와 실행을 병행합니다.',
      verse: '"하나님이 내 마음에 주신 일이라" (느 2:12)',
      traits: ['실행력', '비전', '조직력', '건축하는 은사']),
    TestResult(id: 'ruth', type: '헌신적 동행자', emoji: '🌾', title: '룻형',
      description: '당신은 관계를 소중히 여기고 헌신적으로 동행하는 사람입니다. 충성스럽고 따뜻하며, 어려운 상황에서도 신실함을 잃지 않습니다. 섬김의 은사가 있습니다.',
      verse: '"어디로 가든지 나도 가고 어디서 유숙하든지 나도 유숙하겠나이다" (룻 1:16)',
      traits: ['헌신', '충성', '섬김', '따뜻한 마음']),
    TestResult(id: 'jonah', type: '성장하는 순종자', emoji: '🐋', title: '요나형',
      description: '당신은 솔직히 믿음이 완벽하지 않다는 것을 알지만, 그 안에서 성장해가는 사람입니다. 때로 피하고 싶지만 결국 하나님의 부르심에 응답합니다. 가장 인간적이고, 그래서 가장 공감되는 유형입니다.',
      verse: '"여호와의 말씀이 두 번째 요나에게 임하니라" (욘 3:1)',
      traits: ['솔직함', '성장 중', '인간적', '결국 순종']),
  ],
);

// ══════════════════════════════════════
// 2. 나의 기도 스타일
// ══════════════════════════════════════
final prayerTest = TestDef(
  id: 'prayer', title: '나의 기도 스타일', emoji: '🙏',
  questions: [
    TQ('기도할 때 가장 편한 자세는?', [
      TA('무릎 꿇고 엎드려 기도', {'warrior': 3}),
      TA('조용히 눈 감고 묵상 기도', {'contemplative': 3}),
      TA('걸으면서 대화하듯 기도', {'conversational': 3}),
      TA('찬양 들으면서 감사 기도', {'worshiper': 3}),
    ]),
    TQ('기도 시간은 보통 어느 때?', [
      TA('새벽 — 하루를 기도로 시작', {'warrior': 3}),
      TA('밤 — 하루를 돌아보며 기도', {'contemplative': 3}),
      TA('틈틈이 — 버스, 식사 전 등', {'conversational': 3}),
      TA('예배 중 — 찬양과 함께', {'worshiper': 3}),
    ]),
    TQ('기도 내용은 주로?', [
      TA('다른 사람들을 위한 중보기도', {'warrior': 3}),
      TA('하나님을 알아가는 묵상 기도', {'contemplative': 3}),
      TA('일상의 감사와 고민 나누기', {'conversational': 3}),
      TA('찬양과 경배', {'worshiper': 3}),
    ]),
    TQ('기도 응답을 어떻게 확인하나요?', [
      TA('구체적인 상황 변화로', {'warrior': 3}),
      TA('마음에 오는 평안으로', {'contemplative': 3}),
      TA('일상의 작은 감동으로', {'conversational': 3}),
      TA('예배 중 임재로', {'worshiper': 3}),
    ]),
    TQ('기도가 잘 안 될 때는?', [
      TA('더 강하게, 더 오래 기도한다', {'warrior': 3}),
      TA('성경 말씀을 읽으며 마음을 정돈한다', {'contemplative': 3}),
      TA('솔직하게 "기도가 안 돼요"라고 말한다', {'conversational': 3}),
      TA('찬양을 들으며 마음을 연다', {'worshiper': 3}),
    ]),
    TQ('가장 은혜받았던 기도 경험은?', [
      TA('밤새 기도하며 응답받았을 때', {'warrior': 3}),
      TA('조용한 묵상 중 말씀이 임했을 때', {'contemplative': 3}),
      TA('일상에서 자연스럽게 하나님을 느꼈을 때', {'conversational': 3}),
      TA('찬양하다 눈물이 흘렀을 때', {'worshiper': 3}),
    ]),
    TQ('기도 모임에서 나는?', [
      TA('큰 소리로 열정적으로 기도한다', {'warrior': 3}),
      TA('마음속으로 조용히 기도한다', {'contemplative': 3}),
      TA('짧지만 진솔하게 기도한다', {'conversational': 3}),
      TA('찬양으로 기도를 시작한다', {'worshiper': 3}),
    ]),
    TQ('기도를 한마디로 표현하면?', [
      TA('영적 전쟁', {'warrior': 3}),
      TA('하나님과의 깊은 교제', {'contemplative': 3}),
      TA('아빠와의 대화', {'conversational': 3}),
      TA('찬양과 감사', {'worshiper': 3}),
    ]),
  ],
  results: [
    TestResult(id: 'warrior', type: '기도 전사', emoji: '⚔️', title: '전사형',
      description: '당신은 기도를 영적 전쟁으로 여기는 열정적인 기도 전사입니다. 새벽기도, 철야기도에 강하며, 중보기도의 은사가 있습니다. 어려운 상황에서 더 강하게 기도합니다.',
      verse: '"기도에 힘쓰고 기도에 감사함으로 깨어 있으라" (골 4:2)',
      traits: ['중보기도', '새벽기도', '열정', '끈기']),
    TestResult(id: 'contemplative', type: '묵상형 기도자', emoji: '🧘', title: '묵상형',
      description: '당신은 조용한 묵상을 통해 하나님과 깊이 교제하는 사색형 기도자입니다. 말씀 묵상과 기도가 하나로 연결되며, 내면의 평안을 중시합니다.',
      verse: '"여호와를 기뻐하라 그가 네 마음의 소원을 네게 이루어 주시리로다" (시 37:4)',
      traits: ['묵상', '말씀 중심', '내면의 평안', '깊은 교제']),
    TestResult(id: 'conversational', type: '대화형 기도자', emoji: '💬', title: '대화형',
      description: '당신은 일상 속에서 자연스럽게 하나님과 대화하는 스타일입니다. 격식보다 진솔함을 중시하며, 언제 어디서나 기도할 수 있습니다. 삶 자체가 기도입니다.',
      verse: '"쉬지 말고 기도하라" (살전 5:17)',
      traits: ['일상 기도', '진솔함', '자연스러움', '지속적']),
    TestResult(id: 'worshiper', type: '찬양 기도자', emoji: '🎶', title: '찬양형',
      description: '당신은 찬양과 감사로 하나님께 나아가는 예배형 기도자입니다. 음악이 기도의 통로이며, 찬양할 때 가장 깊은 기도가 됩니다. 감사가 넘치는 사람입니다.',
      verse: '"찬양의 제사를 하나님께 끊임없이 드리자" (히 13:15)',
      traits: ['찬양', '감사', '예배', '감성적 기도']),
  ],
);

// ══════════════════════════════════════
// 3. 말씀 암송 레벨
// ══════════════════════════════════════
final bibleTest = TestDef(
  id: 'bible', title: '말씀 암송 레벨', emoji: '📖',
  questions: [
    TQ('"태초에 하나님이 천지를 ___" 빈칸은?', [
      TA('만드셨다', {'wrong': 1}),
      TA('창조하시니라', {'right': 3}),
      TA('지으셨다', {'wrong': 1}),
      TA('세우셨다', {'wrong': 1}),
    ]),
    TQ('"여호와는 나의 ___시니 내게 부족함이 없으리로다"', [
      TA('인도자', {'wrong': 1}),
      TA('아버지', {'wrong': 1}),
      TA('목자', {'right': 3}),
      TA('보호자', {'wrong': 1}),
    ]),
    TQ('"하나님이 세상을 이처럼 사랑하사 독생자를 주셨으니" 이 구절은?', [
      TA('로마서 8:28', {'wrong': 1}),
      TA('요한복음 3:16', {'right': 3}),
      TA('빌립보서 4:13', {'wrong': 1}),
      TA('시편 23:1', {'wrong': 1}),
    ]),
    TQ('"내게 능력 주시는 자 안에서 내가 모든 것을 할 수 있느니라" 이 구절은?', [
      TA('빌립보서 4:13', {'right': 3}),
      TA('로마서 8:28', {'wrong': 1}),
      TA('갈라디아서 2:20', {'wrong': 1}),
      TA('에베소서 3:20', {'wrong': 1}),
    ]),
    TQ('십계명 중 첫 번째 계명은?', [
      TA('살인하지 말라', {'wrong': 1}),
      TA('나 외에 다른 신을 두지 말라', {'right': 3}),
      TA('안식일을 기억하여 거룩히 지키라', {'wrong': 1}),
      TA('네 부모를 공경하라', {'wrong': 1}),
    ]),
    TQ('"모든 것이 합력하여 선을 이루느니라" 이 구절은?', [
      TA('로마서 8:28', {'right': 3}),
      TA('요한복음 14:6', {'wrong': 1}),
      TA('히브리서 11:1', {'wrong': 1}),
      TA('야고보서 1:2', {'wrong': 1}),
    ]),
    TQ('예수님이 말씀하신 가장 큰 계명은?', [
      TA('안식일을 지키라', {'wrong': 1}),
      TA('네 마음을 다하여 주 너의 하나님을 사랑하라', {'right': 3}),
      TA('이웃을 네 몸과 같이 사랑하라', {'partial': 2}),
      TA('살인하지 말라', {'wrong': 1}),
    ]),
    TQ('"믿음은 바라는 것들의 ___이요"', [
      TA('확신', {'partial': 2}),
      TA('실상', {'right': 3}),
      TA('증거', {'wrong': 1}),
      TA('기초', {'wrong': 1}),
    ]),
    TQ('주기도문은 어느 복음서에 있나요?', [
      TA('마가복음', {'wrong': 1}),
      TA('마태복음', {'right': 3}),
      TA('누가복음', {'partial': 2}),
      TA('요한복음', {'wrong': 1}),
    ]),
    TQ('"강하고 담대하라" 이 말씀을 받은 사람은?', [
      TA('모세', {'wrong': 1}),
      TA('다윗', {'wrong': 1}),
      TA('여호수아', {'right': 3}),
      TA('기드온', {'wrong': 1}),
    ]),
  ],
  results: [
    TestResult(id: 'lv5', type: '말씀 마스터', emoji: '👑', title: 'Lv.5 말씀 마스터',
      description: '놀라운 말씀 실력입니다! 성경 구절과 위치를 정확히 알고 있으며, 깊은 말씀 지식을 갖추고 있습니다. 다른 사람을 가르칠 수 있는 수준입니다.',
      verse: '"네 말씀은 내 발에 등이요 내 길에 빛이니이다" (시 119:105)', traits: ['정확한 암송', '깊은 지식', '가르침']),
    TestResult(id: 'lv4', type: '말씀 전문가', emoji: '⭐', title: 'Lv.4 말씀 전문가',
      description: '대부분의 핵심 구절을 잘 알고 있습니다. 조금만 더 깊이 들어가면 마스터 레벨입니다!',
      verse: '"이 율법책을 네 입에서 떠나지 말게 하며" (수 1:8)', traits: ['핵심 구절 숙지', '꾸준한 묵상']),
    TestResult(id: 'lv3', type: '말씀 탐구자', emoji: '📚', title: 'Lv.3 말씀 탐구자',
      description: '기본적인 말씀 지식이 있고 성장 중입니다. 매일 말씀을 읽는 습관을 들이면 빠르게 성장할 수 있습니다!',
      verse: '"주의 말씀을 묵상하며" (시 119:15)', traits: ['기본 지식', '성장 중', '잠재력']),
    TestResult(id: 'lv2', type: '말씀 입문자', emoji: '🌱', title: 'Lv.2 말씀 입문자',
      description: '성경을 알아가기 시작하는 단계입니다. 핵심 구절부터 하나씩 암송해보세요. 작은 시작이 큰 열매를 맺습니다!',
      verse: '"말씀이 육신이 되어 우리 가운데 거하시매" (요 1:14)', traits: ['시작하는 단계', '호기심', '성장 가능성']),
    TestResult(id: 'lv1', type: '말씀 새싹', emoji: '🌿', title: 'Lv.1 말씀 새싹',
      description: '아직 말씀이 익숙하지 않지만 괜찮아요! 모든 믿음의 거장도 여기서 시작했습니다. 요한복음 3:16부터 시작해보세요!',
      verse: '"하나님이 세상을 이처럼 사랑하사" (요 3:16)', traits: ['새로운 시작', '열린 마음']),
  ],
);

// 말씀 암송 레벨 계산 (점수 기반)
TestResult getBibleResult(Map<String, int> scores) {
  final right = scores['right'] ?? 0;
  final partial = scores['partial'] ?? 0;
  final total = right + partial;
  if (total >= 27) return bibleTest.results[0]; // lv5
  if (total >= 21) return bibleTest.results[1]; // lv4
  if (total >= 15) return bibleTest.results[2]; // lv3
  if (total >= 9) return bibleTest.results[3]; // lv2
  return bibleTest.results[4]; // lv1
}

// ══════════════════════════════════════
// 4. 신앙 은사 테스트
// ══════════════════════════════════════
final giftTest = TestDef(
  id: 'gift', title: '신앙 은사 테스트', emoji: '🕊️',
  questions: [
    TQ('사람들이 힘들어할 때 나는?', [
      TA('실질적으로 도울 방법을 찾는다', {'serving': 3}),
      TA('말씀으로 위로하고 격려한다', {'teaching': 2, 'exhort': 1}),
      TA('함께 울어주고 공감한다', {'mercy': 3}),
      TA('기도해준다', {'faith': 3}),
    ]),
    TQ('교회에서 자연스럽게 하게 되는 일은?', [
      TA('준비, 정리, 세팅 등 뒷바라지', {'serving': 3}),
      TA('성경공부 인도, 설명', {'teaching': 3}),
      TA('새로운 아이디어 제안', {'leadership': 3}),
      TA('헌금, 후원 등 물질적 나눔', {'giving': 3}),
    ]),
    TQ('가장 보람을 느끼는 순간은?', [
      TA('누군가가 성장하는 모습을 볼 때', {'teaching': 3}),
      TA('어려운 사람을 도왔을 때', {'mercy': 3, 'serving': 1}),
      TA('프로젝트를 성공적으로 이끌었을 때', {'leadership': 3}),
      TA('기도 응답을 경험했을 때', {'faith': 3}),
    ]),
    TQ('팀 프로젝트에서 나의 역할은?', [
      TA('리더 — 방향을 잡고 이끈다', {'leadership': 3}),
      TA('실무 — 묵묵히 일을 처리한다', {'serving': 3}),
      TA('멘토 — 팀원들을 격려하고 코칭한다', {'exhort': 3}),
      TA('후원자 — 필요한 자원을 제공한다', {'giving': 3}),
    ]),
    TQ('성경 공부를 할 때 나는?', [
      TA('깊이 연구하고 다른 사람에게 나누고 싶다', {'teaching': 3}),
      TA('말씀을 삶에 적용하는 것이 중요하다', {'exhort': 3}),
      TA('믿음이 강해지는 것을 느낀다', {'faith': 3}),
      TA('나눌 수 있는 것을 찾게 된다', {'giving': 2, 'mercy': 1}),
    ]),
    TQ('주변 사람들이 나에게 자주 하는 말은?', [
      TA('"너는 참 잘 가르쳐줘"', {'teaching': 3}),
      TA('"너한테 말하면 힘이 나"', {'exhort': 3}),
      TA('"너는 마음이 따뜻해"', {'mercy': 3}),
      TA('"너는 참 부지런해"', {'serving': 3}),
    ]),
    TQ('여유 자금이 생기면?', [
      TA('선교/후원에 드린다', {'giving': 3}),
      TA('교회 필요한 곳에 쓴다', {'serving': 2, 'giving': 1}),
      TA('어려운 형제자매를 돕는다', {'mercy': 3}),
      TA('교육/훈련 프로그램에 투자한다', {'teaching': 2, 'leadership': 1}),
    ]),
    TQ('새로운 사역을 시작한다면?', [
      TA('비전을 세우고 팀을 조직한다', {'leadership': 3}),
      TA('기도로 준비하고 하나님의 때를 기다린다', {'faith': 3}),
      TA('필요한 곳을 찾아 바로 섬긴다', {'serving': 3}),
      TA('사람들을 격려하고 동기부여한다', {'exhort': 3}),
    ]),
    TQ('가장 마음이 아픈 것은?', [
      TA('거짓 가르침이 퍼질 때', {'teaching': 3}),
      TA('소외된 사람이 있을 때', {'mercy': 3}),
      TA('비전 없이 방황할 때', {'leadership': 3}),
      TA('기도하지 않을 때', {'faith': 3}),
    ]),
    TQ('신앙의 롤모델은?', [
      TA('바울 — 가르치고 전도한 사도', {'teaching': 3}),
      TA('도르가 — 섬김의 여인', {'serving': 3}),
      TA('바나바 — 위로의 아들', {'exhort': 3}),
      TA('아브라함 — 믿음의 조상', {'faith': 3}),
    ]),
    TQ('예배 후 가장 먼저 하는 일은?', [
      TA('새가족에게 인사하고 안내한다', {'serving': 3}),
      TA('설교 내용을 정리하고 나눈다', {'teaching': 3}),
      TA('혼자 온 분에게 다가가 말을 건다', {'mercy': 3}),
      TA('다음 주 사역 계획을 세운다', {'leadership': 3}),
    ]),
    TQ('기도제목을 나눌 때 나는?', [
      TA('"반드시 응답될 거야" 확신을 준다', {'faith': 3}),
      TA('"같이 기도하자" 함께 기도한다', {'exhort': 3}),
      TA('"내가 도울 수 있는 게 있을까?"', {'serving': 2, 'mercy': 1}),
      TA('"관련된 말씀이 있어" 나눠준다', {'teaching': 3}),
    ]),
    TQ('교회가 성장하려면 가장 필요한 것은?', [
      TA('깊은 말씀 교육', {'teaching': 3}),
      TA('따뜻한 교제와 돌봄', {'mercy': 3}),
      TA('비전과 리더십', {'leadership': 3}),
      TA('기도와 믿음', {'faith': 3}),
    ]),
    TQ('봉사를 할 때 가장 중요한 것은?', [
      TA('성실하게 맡은 바를 다하는 것', {'serving': 3}),
      TA('사람들이 변화되는 것', {'teaching': 2, 'exhort': 1}),
      TA('하나님의 영광을 위한 것', {'faith': 3}),
      TA('넉넉하게 나누는 것', {'giving': 3}),
    ]),
    TQ('내가 받고 싶은 칭찬은?', [
      TA('"좋은 리더야"', {'leadership': 3}),
      TA('"참 따뜻한 사람이야"', {'mercy': 3}),
      TA('"믿음이 정말 좋아"', {'faith': 3}),
      TA('"참 성실해"', {'serving': 3}),
    ]),
  ],
  results: [
    TestResult(id: 'teaching', type: '가르침의 은사', emoji: '📖', title: '가르침',
      description: '당신은 말씀을 연구하고 다른 사람에게 전달하는 가르침의 은사가 있습니다. 복잡한 진리를 이해하기 쉽게 설명하며, 사람들의 영적 성장을 돕습니다.',
      verse: '"가르치는 자는 가르치는 일에" (롬 12:7)', traits: ['말씀 연구', '설명력', '영적 성장 도움']),
    TestResult(id: 'serving', type: '섬김의 은사', emoji: '🤲', title: '섬김',
      description: '당신은 묵묵히 필요한 곳을 채우는 섬김의 은사가 있습니다. 눈에 띄지 않는 곳에서 성실하게 봉사하며, 실질적인 도움으로 공동체를 세웁니다.',
      verse: '"섬기는 자는 섬기는 일에" (롬 12:7)', traits: ['성실', '실질적 도움', '뒷바라지']),
    TestResult(id: 'exhort', type: '격려의 은사', emoji: '💪', title: '격려',
      description: '당신은 사람들에게 용기를 주고 동기부여하는 격려의 은사가 있습니다. 바나바처럼 위로의 아들이며, 당신의 말 한마디가 누군가에게 큰 힘이 됩니다.',
      verse: '"위로하는 자는 위로하는 일에" (롬 12:8)', traits: ['격려', '동기부여', '위로']),
    TestResult(id: 'giving', type: '나눔의 은사', emoji: '🎁', title: '나눔',
      description: '당신은 넉넉하게 나누는 나눔의 은사가 있습니다. 물질뿐 아니라 시간, 재능을 기꺼이 나누며, 나눌 때 가장 큰 기쁨을 느낍니다.',
      verse: '"구제하는 자는 성실함으로" (롬 12:8)', traits: ['넉넉함', '기쁜 나눔', '후원']),
    TestResult(id: 'leadership', type: '리더십의 은사', emoji: '🌟', title: '리더십',
      description: '당신은 비전을 제시하고 사람들을 이끄는 리더십의 은사가 있습니다. 조직하고 계획하며, 공동체를 한 방향으로 모아가는 능력이 있습니다.',
      verse: '"다스리는 자는 부지런함으로" (롬 12:8)', traits: ['비전', '조직력', '방향 제시']),
    TestResult(id: 'mercy', type: '긍휼의 은사', emoji: '💗', title: '긍휼',
      description: '당신은 아픈 사람의 마음을 이해하고 함께하는 긍휼의 은사가 있습니다. 따뜻한 마음으로 소외된 사람에게 다가가며, 당신의 공감 능력이 치유를 가져옵니다.',
      verse: '"긍휼을 베푸는 자는 즐거움으로 할 것이니라" (롬 12:8)', traits: ['공감', '돌봄', '따뜻함']),
    TestResult(id: 'faith', type: '믿음의 은사', emoji: '🔥', title: '믿음',
      description: '당신은 어떤 상황에서도 하나님을 신뢰하는 강한 믿음의 은사가 있습니다. 불가능해 보이는 상황에서도 확신을 가지며, 그 믿음이 주변 사람들에게도 전이됩니다.',
      verse: '"믿음은 바라는 것들의 실상이요" (히 11:1)', traits: ['확신', '신뢰', '담대함']),
  ],
);
