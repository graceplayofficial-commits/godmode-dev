import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/app_theme.dart';

enum _Rarity { common, rare, hero, legend }

class _Card {
  final String name;
  final String emoji;
  final _Rarity rarity;
  final String verse;
  final String desc;
  final Map<String, int> stats;
  int count;

  _Card({required this.name, required this.emoji, required this.rarity, required this.verse, required this.desc, required this.stats, this.count = 0});

  Color get color => switch (rarity) {
    _Rarity.common => const Color(0xFF888888),
    _Rarity.rare => const Color(0xFF4A8FE4),
    _Rarity.hero => const Color(0xFF9B4AE4),
    _Rarity.legend => C.lime,
  };
  String get rarityKo => switch (rarity) { _Rarity.common => '일반', _Rarity.rare => '희귀', _Rarity.hero => '영웅', _Rarity.legend => '전설' };
  String get rarityStars => switch (rarity) { _Rarity.common => '★☆☆☆', _Rarity.rare => '★★☆☆', _Rarity.hero => '★★★☆', _Rarity.legend => '★★★★' };
  double get weight => switch (rarity) { _Rarity.common => 0.55, _Rarity.rare => 0.28, _Rarity.hero => 0.13, _Rarity.legend => 0.04 };
  int get dupeGems => switch (rarity) { _Rarity.common => 1, _Rarity.rare => 3, _Rarity.hero => 10, _Rarity.legend => 50 };
}

class _Achievement {
  final String id;
  final String title;
  final String desc;
  final int gems;
  bool claimed;
  _Achievement({required this.id, required this.title, required this.desc, required this.gems, this.claimed = false});
}

final _allCards = [
  _Card(name: '아브라함', emoji: '⭐', rarity: _Rarity.legend, verse: '창 22:18', desc: '믿음의 조상. 하나님의 부름에 순종하여 고향을 떠난 믿음의 아버지.', stats: {'믿음': 99, '지혜': 85, '용기': 90, '인내': 97, '사랑': 88}),
  _Card(name: '모세', emoji: '🔱', rarity: _Rarity.legend, verse: '출 14:21', desc: '이스라엘 출애굽을 이끈 위대한 지도자. 홍해를 가르고 십계명을 받다.', stats: {'믿음': 95, '지혜': 90, '용기': 88, '인내': 92, '사랑': 80}),
  _Card(name: '다윗', emoji: '🎵', rarity: _Rarity.legend, verse: '삼상 17:45', desc: '하나님의 마음에 합한 자. 골리앗을 이기고 이스라엘의 왕이 되다.', stats: {'믿음': 98, '지혜': 85, '용기': 95, '인내': 80, '사랑': 92}),
  _Card(name: '바울', emoji: '✍️', rarity: _Rarity.legend, verse: '빌 4:13', desc: '이방인의 사도. 신약성경 13권을 기록한 신학의 거장.', stats: {'믿음': 96, '지혜': 98, '용기': 90, '인내': 95, '사랑': 87}),
  _Card(name: '에스더', emoji: '👑', rarity: _Rarity.hero, verse: '에 4:14', desc: '이 때를 위하여 왕후가 된 자. 자신을 희생해 민족을 구한 용기.', stats: {'믿음': 85, '지혜': 88, '용기': 92, '인내': 82, '사랑': 86}),
  _Card(name: '드보라', emoji: '🦁', rarity: _Rarity.hero, verse: '삿 4:4', desc: '이스라엘 유일의 여성 사사. 전쟁터에서 백성을 이끈 담대한 지도자.', stats: {'믿음': 83, '지혜': 87, '용기': 90, '인내': 80, '사랑': 78}),
  _Card(name: '기드온', emoji: '🗡️', rarity: _Rarity.hero, verse: '삿 6:14', desc: '300명으로 미디안 대군을 무찌른 하나님의 용사.', stats: {'믿음': 82, '지혜': 75, '용기': 93, '인내': 72, '사랑': 74}),
  _Card(name: '룻', emoji: '🌾', rarity: _Rarity.hero, verse: '룻 1:16', desc: '어디 가든 따라가리이다. 헌신과 충성의 아이콘. 예수님의 조상.', stats: {'믿음': 84, '지혜': 76, '용기': 78, '인내': 90, '사랑': 96}),
  _Card(name: '느헤미야', emoji: '🧱', rarity: _Rarity.hero, verse: '느 2:17', desc: '무너진 예루살렘 성벽을 52일 만에 재건한 불굴의 리더.', stats: {'믿음': 86, '지혜': 89, '용기': 85, '인내': 93, '사랑': 80}),
  _Card(name: '베드로', emoji: '⚓', rarity: _Rarity.rare, verse: '마 16:18', desc: '예수님의 수제자. 실수해도 다시 일어서는 열정의 사도.', stats: {'믿음': 72, '지혜': 65, '용기': 85, '인내': 62, '사랑': 80}),
  _Card(name: '마리아', emoji: '🕊️', rarity: _Rarity.rare, verse: '눅 1:38', desc: '주의 여종이오니 말씀대로 되기를 원합니다. 순종의 표본.', stats: {'믿음': 92, '지혜': 80, '용기': 73, '인내': 87, '사랑': 96}),
  _Card(name: '요나', emoji: '🐋', rarity: _Rarity.rare, verse: '욘 2:10', desc: '도망갔지만 결국 순종한 갈등하는 인간적인 선지자.', stats: {'믿음': 65, '지혜': 60, '용기': 56, '인내': 70, '사랑': 62}),
  _Card(name: '노아', emoji: '🚢', rarity: _Rarity.rare, verse: '창 6:22', desc: '당대에 의인. 120년간 방주를 지어 인류를 구한 신실한 사람.', stats: {'믿음': 88, '지혜': 75, '용기': 80, '인내': 97, '사랑': 79}),
  _Card(name: '엘리야', emoji: '🔥', rarity: _Rarity.rare, verse: '왕상 18:38', desc: '갈멜산 대결에서 바알 선지자들에게 승리한 불의 선지자.', stats: {'믿음': 86, '지혜': 70, '용기': 90, '인내': 68, '사랑': 65}),
  _Card(name: '야고보', emoji: '📜', rarity: _Rarity.common, verse: '약 2:17', desc: '행함이 없는 믿음은 죽은 것. 실천을 강조한 예수님의 형제.', stats: {'믿음': 70, '지혜': 72, '용기': 65, '인내': 75, '사랑': 70}),
  _Card(name: '한나', emoji: '🙏', rarity: _Rarity.common, verse: '삼상 1:27', desc: '간절한 기도로 사무엘을 얻고 하나님께 드린 신실한 어머니.', stats: {'믿음': 76, '지혜': 65, '용기': 60, '인내': 82, '사랑': 85}),
  _Card(name: '바나바', emoji: '🤝', rarity: _Rarity.common, verse: '행 11:24', desc: '위로의 아들. 바울의 첫 번째 동역자. 섬김과 격려의 사람.', stats: {'믿음': 73, '지혜': 68, '용기': 66, '인내': 74, '사랑': 88}),
];

class GachaScreen extends StatefulWidget {
  const GachaScreen({super.key});

  @override
  State<GachaScreen> createState() => _GachaScreenState();
}

class _GachaScreenState extends State<GachaScreen> with TickerProviderStateMixin {
  int _gems = 150;
  bool _canFreeDraw = true;
  bool _canDailyGem = true;
  int _pityCount = 0;
  int _totalPulls = 0;
  final Map<String, int> _collection = {};
  List<_Card> _recentDraws = [];
  bool _isDrawing = false;
  bool _showEarn = false;

  final _achievements = [
    _Achievement(id: 'first_draw', title: '첫 소환', desc: '처음으로 카드를 뽑았습니다', gems: 20),
    _Achievement(id: 'first_legend', title: '전설 강림', desc: '전설 등급 카드를 획득했습니다', gems: 100),
    _Achievement(id: 'pull_10', title: '10회 소환', desc: '총 10회 소환을 달성했습니다', gems: 30),
    _Achievement(id: 'pull_50', title: '50회 소환', desc: '총 50회 소환을 달성했습니다', gems: 50),
    _Achievement(id: 'pull_100', title: '100회 소환', desc: '총 100회 소환을 달성했습니다', gems: 80),
    _Achievement(id: 'all_common', title: '일반 카드 완성', desc: '모든 일반 등급 카드를 수집했습니다', gems: 50),
    _Achievement(id: 'all_rare', title: '희귀 카드 완성', desc: '모든 희귀 등급 카드를 수집했습니다', gems: 80),
    _Achievement(id: 'half_collection', title: '반 수집', desc: '전체 카드의 50% 이상 수집했습니다', gems: 60),
  ];

  late AnimationController _revealController;
  late AnimationController _sparkleController;

  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _sparkleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _loadData();
  }

  @override
  void dispose() {
    _revealController.dispose();
    _sparkleController.dispose();
    _saveData();
    super.dispose();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    setState(() {
      _gems = prefs.getInt('gacha_gems') ?? 150;
      _pityCount = prefs.getInt('gacha_pity') ?? 0;
      _totalPulls = prefs.getInt('gacha_total_pulls') ?? 0;
      _canFreeDraw = (prefs.getString('gacha_free_date') ?? '') != today;
      _canDailyGem = (prefs.getString('gacha_daily_gem_date') ?? '') != today;
      for (final card in _allCards) {
        final count = prefs.getInt('gacha_c_${card.name}') ?? 0;
        if (count > 0) _collection[card.name] = count;
      }
      for (final ach in _achievements) {
        ach.claimed = prefs.getBool('gacha_ach_${ach.id}') ?? false;
      }
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('gacha_gems', _gems);
    await prefs.setInt('gacha_pity', _pityCount);
    await prefs.setInt('gacha_total_pulls', _totalPulls);
    for (final card in _allCards) {
      await prefs.setInt('gacha_c_${card.name}', _collection[card.name] ?? 0);
    }
    for (final ach in _achievements) {
      await prefs.setBool('gacha_ach_${ach.id}', ach.claimed);
    }
  }

  _Card _roll() {
    _pityCount++;
    _totalPulls++;
    if (_pityCount >= 90) {
      _pityCount = 0;
      final legends = _allCards.where((c) => c.rarity == _Rarity.legend).toList();
      return legends[Random().nextInt(legends.length)];
    }

    final rand = Random().nextDouble();
    double cum = 0;
    for (final card in _allCards) {
      cum += card.weight;
      if (rand <= cum) return card;
    }
    return _allCards.last;
  }

  void _checkAchievements(List<_Card> drawn) {
    final newGems = <String, int>{};
    final ownedCount = _collection.length;

    for (final ach in _achievements) {
      if (ach.claimed) continue;
      bool earned = false;
      switch (ach.id) {
        case 'first_draw':
          earned = _totalPulls >= 1;
        case 'first_legend':
          earned = drawn.any((c) => c.rarity == _Rarity.legend) ||
              _allCards.any((c) => c.rarity == _Rarity.legend && (_collection[c.name] ?? 0) > 0);
        case 'pull_10':
          earned = _totalPulls >= 10;
        case 'pull_50':
          earned = _totalPulls >= 50;
        case 'pull_100':
          earned = _totalPulls >= 100;
        case 'all_common':
          earned = _allCards.where((c) => c.rarity == _Rarity.common).every((c) => (_collection[c.name] ?? 0) > 0);
        case 'all_rare':
          earned = _allCards.where((c) => c.rarity == _Rarity.rare).every((c) => (_collection[c.name] ?? 0) > 0);
        case 'half_collection':
          earned = ownedCount >= (_allCards.length / 2).ceil();
      }
      if (earned) {
        newGems[ach.title] = ach.gems;
        ach.claimed = true;
      }
    }

    if (newGems.isNotEmpty) {
      for (final g in newGems.values) {
        _gems += g;
      }
      final msg = newGems.entries.map((e) => '${e.key} +${e.value}💎').join('\n');
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('업적 달성!\n$msg'),
          backgroundColor: C.lime,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ));
      });
    }
  }

  Future<void> _draw({bool free = false, int count = 1}) async {
    if (_isDrawing) return;
    if (!free && _gems < count * 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('보석이 부족합니다! 보석 획득 탭을 확인하세요.'), backgroundColor: C.surface),
      );
      return;
    }

    setState(() {
      _isDrawing = true;
      if (!free) _gems -= count * 10;
      if (free) {
        _canFreeDraw = false;
        SharedPreferences.getInstance().then((p) => p.setString('gacha_free_date', DateTime.now().toIso8601String().substring(0, 10)));
      }
    });

    final drawn = <_Card>[];
    for (int i = 0; i < count; i++) {
      final card = _roll();
      _collection[card.name] = (_collection[card.name] ?? 0) + 1;
      drawn.add(card);
    }

    _checkAchievements(drawn);

    await Future.delayed(const Duration(milliseconds: 200));
    final hasLegend = drawn.any((c) => c.rarity == _Rarity.legend);
    if (hasLegend) {
      _sparkleController.forward(from: 0);
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.mediumImpact();
    }

    setState(() {
      _recentDraws = drawn;
      _isDrawing = false;
    });
    _revealController.forward(from: 0);
    _saveData();
  }

  void _claimDailyGem() {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    setState(() {
      _gems += 30;
      _canDailyGem = false;
    });
    SharedPreferences.getInstance().then((p) => p.setString('gacha_daily_gem_date', today));
    _saveData();
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('오늘의 보석 30💎 획득!'), backgroundColor: C.surface, behavior: SnackBarBehavior.floating),
    );
  }

  void _convertDupes(_Card card) {
    final count = _collection[card.name] ?? 0;
    if (count <= 1) return;
    final dupes = count - 1;
    final earned = dupes * card.dupeGems;
    setState(() {
      _collection[card.name] = 1;
      _gems += earned;
    });
    _saveData();
    Navigator.pop(context);
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('중복 ${card.name} ${dupes}장 → 💎$earned 변환 완료!'),
        backgroundColor: card.color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _claimAchievement(_Achievement ach) {
    // Achievements are auto-claimed on draw; this is for manual claim of pre-met ones
    if (ach.claimed) return;
    setState(() {
      ach.claimed = true;
      _gems += ach.gems;
    });
    _saveData();
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${ach.title} 달성! +${ach.gems}💎'), backgroundColor: C.surface, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(child: Column(children: [
        _buildHeader(),
        _buildPityBar(),
        if (_showEarn) Expanded(child: _buildEarnPanel()) else ...[
          if (_recentDraws.isNotEmpty) _buildDrawResults(),
          _buildDrawButtons(),
          Expanded(child: _buildCollection()),
        ],
      ])),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(children: [
        GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.close)),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('성경 인물 카드', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          Text('${_collection.length}/${_allCards.length} 수집', style: const TextStyle(fontSize: 11, color: C.grey)),
        ]),
        const Spacer(),
        // Earn gems toggle
        GestureDetector(
          onTap: () => setState(() => _showEarn = !_showEarn),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: _showEarn ? const Color(0xFF2D5A27) : C.elevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _showEarn ? Colors.green : C.border),
            ),
            child: Text(_showEarn ? '돌아가기' : '💎 획득', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: C.elevated, borderRadius: BorderRadius.circular(14), border: Border.all(color: C.border)),
          child: Row(children: [
            const Text('💎', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            Text('$_gems', style: const TextStyle(fontWeight: FontWeight.w800, color: C.lime, fontSize: 16)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildPityBar() {
    final pityPct = _pityCount / 90;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(10)),
      child: Row(children: [
        const Text('⭐ 천장', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        Expanded(child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pityPct,
            backgroundColor: C.border,
            valueColor: AlwaysStoppedAnimation(pityPct > 0.7 ? Colors.red : C.lime),
            minHeight: 6,
          ),
        )),
        const SizedBox(width: 8),
        Text('$_pityCount/90', style: const TextStyle(fontSize: 11, color: C.grey)),
        const SizedBox(width: 10),
        Text('총 ${_totalPulls}회', style: const TextStyle(fontSize: 11, color: C.grey)),
      ]),
    );
  }

  Widget _buildEarnPanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Daily reward
        _sectionTitle('매일 무료 보석'),
        _dailyGemCard(),
        const SizedBox(height: 16),

        // Duplicate conversion info
        _sectionTitle('중복 카드 변환'),
        _dupeConversionInfo(),
        const SizedBox(height: 16),

        // Achievements
        _sectionTitle('업적 보상'),
        ..._achievements.map(_achievementTile),
        const SizedBox(height: 24),
      ]),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: C.lime)),
    );
  }

  Widget _dailyGemCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _canDailyGem ? Colors.green : C.border),
      ),
      child: Row(children: [
        const Text('💎', style: TextStyle(fontSize: 36)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('오늘의 보석', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const Text('매일 30💎 무료 지급', style: TextStyle(fontSize: 11, color: C.grey)),
        ])),
        GestureDetector(
          onTap: _canDailyGem ? _claimDailyGem : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _canDailyGem ? Colors.green : C.elevated,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _canDailyGem ? '+30💎' : '완료',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _canDailyGem ? Colors.white : C.grey),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _dupeConversionInfo() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: C.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('중복 카드를 보석으로 교환하세요', style: TextStyle(fontSize: 12, color: C.grey)),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _dupeRate('일반', const Color(0xFF888888), '1💎'),
          _dupeRate('희귀', const Color(0xFF4A8FE4), '3💎'),
          _dupeRate('영웅', const Color(0xFF9B4AE4), '10💎'),
          _dupeRate('전설', C.lime, '50💎'),
        ]),
        const SizedBox(height: 10),
        const Text('보유 카드를 탭하면 중복 변환 버튼이 나타납니다', style: TextStyle(fontSize: 11, color: C.grey)),
      ]),
    );
  }

  Widget _dupeRate(String rarity, Color color, String rate) {
    return Column(children: [
      Container(
        width: 48, height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: color.withAlpha(30), borderRadius: BorderRadius.circular(4), border: Border.all(color: color)),
        child: Text(rarity, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
      ),
      const SizedBox(height: 3),
      Text(rate, style: const TextStyle(fontSize: 11, color: C.lime, fontWeight: FontWeight.w700)),
    ]);
  }

  Widget _achievementTile(_Achievement ach) {
    final claimable = !ach.claimed && _isAchievementMet(ach);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: claimable ? C.lime : ach.claimed ? C.border.withAlpha(80) : C.border),
      ),
      child: Row(children: [
        Text(ach.claimed ? '✅' : claimable ? '🎁' : '🔒', style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(ach.title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: ach.claimed ? C.grey : null)),
          Text(ach.desc, style: const TextStyle(fontSize: 11, color: C.grey)),
        ])),
        if (claimable)
          GestureDetector(
            onTap: () => _claimAchievement(ach),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: C.lime, borderRadius: BorderRadius.circular(6)),
              child: Text('+${ach.gems}💎', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: C.bg)),
            ),
          )
        else
          Text('+${ach.gems}💎', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: ach.claimed ? C.grey : C.lime.withAlpha(140))),
      ]),
    );
  }

  bool _isAchievementMet(_Achievement ach) {
    switch (ach.id) {
      case 'first_draw': return _totalPulls >= 1;
      case 'first_legend': return _allCards.any((c) => c.rarity == _Rarity.legend && (_collection[c.name] ?? 0) > 0);
      case 'pull_10': return _totalPulls >= 10;
      case 'pull_50': return _totalPulls >= 50;
      case 'pull_100': return _totalPulls >= 100;
      case 'all_common': return _allCards.where((c) => c.rarity == _Rarity.common).every((c) => (_collection[c.name] ?? 0) > 0);
      case 'all_rare': return _allCards.where((c) => c.rarity == _Rarity.rare).every((c) => (_collection[c.name] ?? 0) > 0);
      case 'half_collection': return _collection.length >= (_allCards.length / 2).ceil();
      default: return false;
    }
  }

  Widget _buildDrawResults() {
    return AnimatedBuilder(
      animation: _revealController,
      builder: (_, __) {
        final t = Curves.elasticOut.transform(_revealController.value.clamp(0.0, 1.0));
        return Transform.scale(
          scale: 0.7 + 0.3 * t,
          child: Opacity(
            opacity: _revealController.value.clamp(0.0, 1.0),
            child: _recentDraws.length == 1
                ? _singleResult(_recentDraws[0])
                : _multiResult(_recentDraws),
          ),
        );
      },
    );
  }

  Widget _singleResult(_Card card) {
    return AnimatedBuilder(
      animation: _sparkleController,
      builder: (_, child) {
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: card.color.withAlpha(25),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: card.color, width: 2),
            boxShadow: card.rarity == _Rarity.legend
                ? [BoxShadow(color: card.color.withAlpha((100 * (0.5 + 0.5 * sin(_sparkleController.value * pi * 4))).round()), blurRadius: 20, spreadRadius: 4)]
                : null,
          ),
          child: Row(children: [
            Text(card.emoji, style: const TextStyle(fontSize: 52)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(card.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(width: 8),
                _rarityBadge(card),
              ]),
              const SizedBox(height: 2),
              Text(card.rarityStars, style: TextStyle(color: card.color, fontSize: 13)),
              Text(card.verse, style: const TextStyle(color: C.grey, fontSize: 11)),
              const SizedBox(height: 6),
              Text(card.desc, style: const TextStyle(fontSize: 11, color: C.grey, height: 1.4)),
            ])),
          ]),
        );
      },
    );
  }

  Widget _multiResult(List<_Card> cards) {
    return Container(
      height: 130,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cards.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final card = cards[i];
          return Container(
            width: 80,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: card.color.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: card.color, width: 1.5),
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(card.emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 4),
              Text(card.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
              Text(card.rarityKo, style: TextStyle(fontSize: 10, color: card.color)),
            ]),
          );
        },
      ),
    );
  }

  Widget _rarityBadge(_Card card) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: card.color, borderRadius: BorderRadius.circular(4)),
      child: Text(card.rarityKo, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: card.rarity == _Rarity.legend ? C.bg : Colors.white)),
    );
  }

  Widget _buildDrawButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(children: [
        if (_canFreeDraw) ...[
          Expanded(child: _drawBtn('무료 뽑기', '1일 1회', const Color(0xFF2D5A27), () => _draw(free: true))),
          const SizedBox(width: 8),
        ],
        Expanded(child: _drawBtn('💎10 · 1뽑기', '1회 소환', C.lime.withAlpha(200), () => _draw(count: 1), textColor: C.bg)),
        const SizedBox(width: 8),
        Expanded(child: _drawBtn('💎100 · 10뽑기', '10회 소환', C.lime, () => _draw(count: 10), textColor: C.bg)),
      ]),
    );
  }

  Widget _drawBtn(String title, String sub, Color bg, VoidCallback onTap, {Color textColor = Colors.white}) {
    return GestureDetector(
      onTap: _isDrawing ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          _isDrawing
              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: textColor)),
          Text(sub, style: TextStyle(fontSize: 10, color: textColor.withAlpha(180))),
        ]),
      ),
    );
  }

  Widget _buildCollection() {
    final cards = _allCards.where((c) => (_collection[c.name] ?? 0) > 0).toList()
      ..sort((a, b) => b.rarity.index.compareTo(a.rarity.index));
    final unowned = _allCards.where((c) => (_collection[c.name] ?? 0) == 0).toList();

    return Container(
      decoration: const BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(top: BorderSide(color: C.border)),
      ),
      child: Column(children: [
        Padding(padding: const EdgeInsets.all(10), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('보유 카드', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          Text('${cards.length}/${_allCards.length}', style: const TextStyle(fontSize: 11, color: C.grey)),
        ])),
        Expanded(child: GridView.builder(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 0.7),
          itemCount: cards.length + unowned.length,
          itemBuilder: (_, i) => i < cards.length
              ? _cardTile(cards[i], owned: true)
              : _cardTile(unowned[i - cards.length], owned: false),
        )),
      ]),
    );
  }

  Widget _cardTile(_Card card, {required bool owned}) {
    final count = _collection[card.name] ?? 0;
    final hasDupes = count > 1;
    return GestureDetector(
      onTap: owned ? () => _showDetail(card) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: owned ? card.color.withAlpha(20) : C.elevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: owned ? card.color.withAlpha(120) : C.border, width: owned ? 1.5 : 1),
        ),
        child: Stack(children: [
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Spacer(),
            Text(owned ? card.emoji : '❓', style: TextStyle(fontSize: 28, color: owned ? null : C.border.withAlpha(128))),
            const SizedBox(height: 3),
            Text(owned ? card.name : '???',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: owned ? null : C.grey),
                textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
            if (owned) Text(card.rarityKo, style: TextStyle(fontSize: 9, color: card.color)),
            const Spacer(),
          ]),
          // Dupe badge
          if (hasDupes)
            Positioned(
              top: 3, right: 3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(color: C.lime, borderRadius: BorderRadius.circular(4)),
                child: Text('x$count', style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: C.bg)),
              ),
            ),
        ]),
      ),
    );
  }

  void _showDetail(_Card card) {
    final count = _collection[card.name] ?? 0;
    showModalBottomSheet(
      context: context, backgroundColor: C.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            Text(card.emoji, style: const TextStyle(fontSize: 56)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(card.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              _rarityBadge(card),
              const SizedBox(height: 4),
              Text(card.verse, style: TextStyle(color: card.color, fontSize: 12, fontWeight: FontWeight.w600)),
            ])),
          ]),
          const SizedBox(height: 12),
          Text(card.desc, style: const TextStyle(fontSize: 13, color: C.grey, height: 1.6)),
          const SizedBox(height: 16),
          ...card.stats.entries.map((e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(children: [
              SizedBox(width: 56, child: Text(e.key, style: const TextStyle(color: C.grey, fontSize: 13))),
              Expanded(child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(value: e.value / 100, backgroundColor: C.border, valueColor: AlwaysStoppedAnimation(card.color), minHeight: 8),
              )),
              SizedBox(width: 32, child: Text('${e.value}', style: const TextStyle(fontSize: 12), textAlign: TextAlign.right)),
            ]),
          )),
          const SizedBox(height: 12),
          Text('보유 수량: $count장', style: const TextStyle(color: C.grey, fontSize: 12)),
          // Dupe conversion button
          if (count > 1) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _convertDupes(card),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: card.color.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: card.color),
                ),
                child: Column(children: [
                  Text('중복 ${count - 1}장 → 💎${(count - 1) * card.dupeGems} 변환', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: card.color)),
                  Text('1장 보존 · 나머지 ${card.dupeGems}💎/장', style: const TextStyle(fontSize: 11, color: C.grey)),
                ]),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}
