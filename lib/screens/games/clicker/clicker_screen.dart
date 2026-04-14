import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/app_theme.dart';

// ── Building: auto-producer (Cookie Clicker style)
class _Building {
  final String emoji;
  final String name;
  final String desc;
  final double baseCost;
  final double basePerSec;
  int owned;

  _Building({required this.emoji, required this.name, required this.desc,
    required this.baseCost, required this.basePerSec, this.owned = 0});

  double get nextCost => baseCost * pow(1.15, owned);
  double get totalPerSec => basePerSec * owned;
  bool canBuy(double pts) => pts >= nextCost;
}

// ── TapUpgrade: one-time purchase
class _TapUpgrade {
  final String emoji;
  final String name;
  final String desc;
  final double cost;
  final int tapBonus;
  bool bought;

  _TapUpgrade({required this.emoji, required this.name, required this.desc,
    required this.cost, required this.tapBonus, this.bought = false});
}

// ── Stage
class _Stage { final double pts; final String name, emoji, verse;
  const _Stage(this.pts, this.name, this.emoji, this.verse); }
const _stages = [
  _Stage(0,      '광야',         '🏜️', '"주는 나의 목자시니" (시 23:1)'),
  _Stage(500,    '가나안 입성',  '⛺', '"강하고 담대하라" (수 1:9)'),
  _Stage(5000,   '성막 건설',    '🕍', '"내 집은 기도하는 집" (사 56:7)'),
  _Stage(50000,  '솔로몬 성전',  '🏛️', '"이 집의 영광이 더하리라" (학 2:9)'),
  _Stage(500000, '예루살렘 재건', '🧱', '"백성이 마음으로 일하였더라" (느 4:6)'),
  _Stage(5000000,'새 예루살렘',  '🏙️', '"하나님의 장막이 사람과 함께" (계 21:3)'),
  _Stage(50000000,'하나님 나라', '👑', '"나라와 권세와 영광이 영원히" (마 6:13)'),
];

// ── Milestone
class _Milestone {
  final double pts; final String title, desc; bool achieved;
  _Milestone(this.pts, this.title, this.desc, {this.achieved = false});
}

class ClickerScreen extends StatefulWidget {
  const ClickerScreen({super.key});

  @override
  State<ClickerScreen> createState() => _ClickerScreenState();
}

class _ClickerScreenState extends State<ClickerScreen> with TickerProviderStateMixin {
  double _pts = 0;
  double _totalEarned = 0;
  int _totalTaps = 0;
  int _prestige = 0;
  double get _prestigeMulti => 1.0 + _prestige * 0.5;
  bool _loaded = false;

  late AnimationController _tapCtrl;
  late AnimationController _glowCtrl;
  final _particles = <_Particle>[];
  Timer? _saveTimer;
  int _selectedTab = 0; // 0=건물, 1=탭 업그레이드

  final _buildings = [
    _Building(emoji:'🙏', name:'기도',      desc:'기도로 믿음 적립',        baseCost:15,        basePerSec:0.1),
    _Building(emoji:'📖', name:'말씀 묵상',  desc:'매일 말씀으로 성장',      baseCost:100,       basePerSec:0.5),
    _Building(emoji:'🏫', name:'주일학교',   desc:'다음 세대를 세우다',       baseCost:500,       basePerSec:2),
    _Building(emoji:'🎵', name:'찬양팀',     desc:'찬양으로 하늘이 열리다',   baseCost:3000,      basePerSec:8),
    _Building(emoji:'🏠', name:'구역모임',   desc:'작은 공동체의 힘',         baseCost:15000,     basePerSec:30),
    _Building(emoji:'📢', name:'전도단',     desc:'복음을 온 땅에 전하다',    baseCost:80000,     basePerSec:100),
    _Building(emoji:'✈️', name:'선교사',     desc:'열방을 향한 발걸음',       baseCost:500000,    basePerSec:350),
    _Building(emoji:'⛪', name:'교회 개척',  desc:'새로운 교회를 세우다',     baseCost:3000000,   basePerSec:1200),
    _Building(emoji:'🌍', name:'열방 부흥',  desc:'전 세계에 복음이 울려퍼지다', baseCost:20000000, basePerSec:5000),
  ];

  final _tapUpgrades = [
    _TapUpgrade(emoji:'💪', name:'믿음 강화',  desc:'탭당 +2 포인트',   cost:50,       tapBonus:2),
    _TapUpgrade(emoji:'✝️', name:'십자가 능력', desc:'탭당 +5 포인트',  cost:300,      tapBonus:5),
    _TapUpgrade(emoji:'⚡', name:'은혜 충전',   desc:'탭당 +15 포인트', cost:2000,     tapBonus:15),
    _TapUpgrade(emoji:'🕊️', name:'성령 충만',   desc:'탭당 +50 포인트', cost:15000,   tapBonus:50),
    _TapUpgrade(emoji:'🔥', name:'불의 기름',   desc:'탭당 +150 포인트',cost:100000,  tapBonus:150),
    _TapUpgrade(emoji:'✨', name:'기름 부음',   desc:'탭당 +500 포인트',cost:1000000, tapBonus:500),
  ];

  final _milestones = [
    _Milestone(100,      '🌱 첫 걸음',    '믿음 100pt 달성!'),
    _Milestone(1000,     '📿 신앙 초보',   '1,000pt 달성!'),
    _Milestone(10000,    '⚡ 은혜 충전',   '10,000pt 달성!'),
    _Milestone(100000,   '🔥 성령 충만',   '100,000pt 달성!'),
    _Milestone(1000000,  '👑 왕 같은 제사장', '100만pt 달성!'),
    _Milestone(10000000, '🌍 하나님 나라', '1000만pt 달성!'),
  ];

  double get _perSec {
    final base = _buildings.fold(0.0, (s, b) => s + b.totalPerSec);
    return base * _prestigeMulti;
  }

  int get _tapValue {
    final base = 1 + _tapUpgrades.where((u) => u.bought).fold(0, (s, u) => s + u.tapBonus);
    return (base * _prestigeMulti).floor();
  }

  _Stage get _stage {
    for (int i = _stages.length - 1; i >= 0; i--) {
      if (_pts >= _stages[i].pts) return _stages[i];
    }
    return _stages[0];
  }

  double get _nextStagePts {
    for (final s in _stages) {
      if (s.pts > _pts) return s.pts;
    }
    return double.infinity;
  }

  bool get _canPrestige => _pts >= 500000;

  @override
  void initState() {
    super.initState();
    _tapCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 130));
    _glowCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _loadData();
    _startIdleTimer();
    _saveTimer = Timer.periodic(const Duration(seconds: 8), (_) => _saveData());
  }

  @override
  void dispose() {
    _tapCtrl.dispose();
    _glowCtrl.dispose();
    _saveTimer?.cancel();
    _saveData();
    super.dispose();
  }

  void _startIdleTimer() {
    Timer.periodic(const Duration(milliseconds: 200), (t) {
      if (!mounted) { t.cancel(); return; }
      if (_perSec > 0) setState(() { _pts += _perSec / 5; _totalEarned += _perSec / 5; });
      _checkMilestones();
    });
  }

  void _checkMilestones() {
    for (final m in _milestones) {
      if (!m.achieved && _pts >= m.pts) {
        m.achieved = true;
        _showMilestone(m);
      }
    }
  }

  void _showMilestone(_Milestone m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Text(m.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(width: 8),
        Text(m.desc, style: const TextStyle(fontSize: 12)),
      ]),
      backgroundColor: C.lime,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
    ));
    HapticFeedback.heavyImpact();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSave = prefs.getInt('ck_ts') ?? 0;
    final offlineSec = ((DateTime.now().millisecondsSinceEpoch - lastSave) / 1000).clamp(0, 4 * 3600);

    setState(() {
      _prestige = prefs.getInt('ck_prestige') ?? 0;
      _pts = prefs.getDouble('ck_pts') ?? 0;
      _totalEarned = prefs.getDouble('ck_total') ?? 0;
      _totalTaps = prefs.getInt('ck_taps') ?? 0;
      for (int i = 0; i < _buildings.length; i++) {
        _buildings[i].owned = prefs.getInt('ck_b$i') ?? 0;
      }
      for (int i = 0; i < _tapUpgrades.length; i++) {
        _tapUpgrades[i].bought = prefs.getBool('ck_t$i') ?? false;
      }
      for (int i = 0; i < _milestones.length; i++) {
        _milestones[i].achieved = prefs.getBool('ck_m$i') ?? false;
      }
      _loaded = true;

      final offline = _perSec * offlineSec;
      if (offline > 1) {
        _pts += offline;
        _totalEarned += offline;
        Future.delayed(const Duration(milliseconds: 600), () => _showOfflineDialog(offline));
      }
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('ck_pts', _pts);
    await prefs.setDouble('ck_total', _totalEarned);
    await prefs.setInt('ck_taps', _totalTaps);
    await prefs.setInt('ck_prestige', _prestige);
    await prefs.setInt('ck_ts', DateTime.now().millisecondsSinceEpoch);
    for (int i = 0; i < _buildings.length; i++) await prefs.setInt('ck_b$i', _buildings[i].owned);
    for (int i = 0; i < _tapUpgrades.length; i++) await prefs.setBool('ck_t$i', _tapUpgrades[i].bought);
    for (int i = 0; i < _milestones.length; i++) await prefs.setBool('ck_m$i', _milestones[i].achieved);
  }

  void _showOfflineDialog(double earned) {
    if (!mounted) return;
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: C.surface,
      title: const Text('⏰ 오프라인 수익'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('앱을 비운 사이 수익이 쌓였습니다!'),
        const SizedBox(height: 12),
        Text('+${_fmt(earned)} pt', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: C.lime)),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('감사합니다!', style: TextStyle(color: C.lime)))],
    ));
  }

  void _onTap(TapDownDetails d) {
    final earned = _tapValue.toDouble();
    setState(() {
      _pts += earned; _totalEarned += earned; _totalTaps++;
      _particles.add(_Particle(d.localPosition, '+$_tapValue'));
    });
    _tapCtrl.forward(from: 0);
    HapticFeedback.lightImpact();
    if (_particles.length > 8) _particles.removeAt(0);
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted && _particles.isNotEmpty) setState(() => _particles.removeAt(0));
    });
  }

  void _buyBuilding(int i) {
    final b = _buildings[i];
    if (_pts >= b.nextCost) {
      setState(() { _pts -= b.nextCost; b.owned++; });
      HapticFeedback.mediumImpact();
    }
  }

  void _buyTapUpgrade(int i) {
    final u = _tapUpgrades[i];
    if (!u.bought && _pts >= u.cost) {
      setState(() { _pts -= u.cost; u.bought = true; });
      HapticFeedback.mediumImpact();
    }
  }

  void _doPrestige() {
    if (!_canPrestige) return;
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: C.surface,
      title: const Text('✨ 프레스티지'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('모든 것을 초기화하고\n영구 x${(_prestigeMulti + 0.5).toStringAsFixed(1)} 배율을 얻습니다.', textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text('현재 배율: x${_prestigeMulti.toStringAsFixed(1)}  →  x${(_prestigeMulti + 0.5).toStringAsFixed(1)}',
            style: const TextStyle(color: C.lime, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        const Text('"이전 것은 지나갔으니 보라 새 것이 되었도다" (고후 5:17)',
            style: TextStyle(color: C.grey, fontSize: 12, fontStyle: FontStyle.italic), textAlign: TextAlign.center),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소', style: TextStyle(color: C.grey))),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            setState(() {
              _prestige++;
              _pts = 0; _totalEarned = 0; _totalTaps = 0;
              for (final b in _buildings) b.owned = 0;
              for (final u in _tapUpgrades) u.bought = false;
              for (final m in _milestones) m.achieved = false;
            });
            _saveData();
          },
          child: const Text('프레스티지!', style: TextStyle(color: C.lime, fontWeight: FontWeight.w800)),
        ),
      ],
    ));
  }

  String _fmt(double p) {
    if (p >= 1e12) return '${(p/1e12).toStringAsFixed(1)}조';
    if (p >= 1e8)  return '${(p/1e8).toStringAsFixed(1)}억';
    if (p >= 10000) return '${(p/10000).toStringAsFixed(1)}만';
    if (p >= 1000) return '${(p/1000).toStringAsFixed(1)}천';
    return p.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const Scaffold(body: Center(child: CircularProgressIndicator(color: C.lime)));
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(child: Column(children: [
        _buildHeader(),
        _buildStageCard(),
        _buildTapArea(),
        _buildUpgradeSection(),
      ])),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(children: [
        GestureDetector(
          onTap: () { _saveData(); Navigator.pop(context); },
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: C.border)),
            child: const Icon(Icons.close_rounded, size: 18, color: C.grey),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('믿음의 왕국', style: S.cardTitle),
            if (_prestige > 0) ...[
              const SizedBox(width: 6),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [C.limeDim, C.lime]),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('✨P$_prestige', style: S.caption.copyWith(color: const Color(0xFF1A1400), fontWeight: FontWeight.w800))),
            ],
          ]),
          Text('초당 ${_fmt(_perSec)} pt  |  탭당 $_tapValue pt', style: S.caption.copyWith(color: C.grey)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [C.lime.withAlpha(20), C.lime.withAlpha(8)]),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: C.lime.withAlpha(30)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(_fmt(_pts), style: S.title.copyWith(color: C.lime, fontSize: 18)),
            Text('누적 ${_fmt(_totalEarned)}', style: S.caption.copyWith(color: C.lime.withAlpha(120))),
          ]),
        ),
      ]),
    );
  }

  Widget _buildStageCard() {
    final s = _stage;
    final next = _nextStagePts;
    final pct = next == double.infinity ? 1.0 : ((_pts - s.pts) / (next - s.pts)).clamp(0.0, 1.0);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        Text(s.emoji, style: const TextStyle(fontSize: 36)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 2),
          Text(s.verse, style: const TextStyle(fontSize: 10, color: C.grey, fontStyle: FontStyle.italic)),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: pct, backgroundColor: C.border,
                valueColor: const AlwaysStoppedAnimation(C.lime), minHeight: 5),
          ),
          if (next != double.infinity)
            Text('다음: ${_fmt(next)} pt', style: const TextStyle(fontSize: 9, color: C.grey)),
        ])),
        if (_canPrestige)
          GestureDetector(
            onTap: _doPrestige,
            child: Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
  

                boxShadow: [BoxShadow(color: C.lime.withAlpha(120), blurRadius: 8)],
              ),
              child: const Column(children: [
                Text('✨', style: TextStyle(fontSize: 20)),
                Text('프레스티지', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.black)),
              ]),
            ),
          ),
      ]),
    );
  }

  Widget _buildTapArea() {
    return Expanded(
      flex: 2,
      child: GestureDetector(
        onTapDown: _onTap,
        behavior: HitTestBehavior.opaque,
        child: Stack(alignment: Alignment.center, children: [
          // Glow ring
          AnimatedBuilder(
            animation: _glowCtrl,
            builder: (_, __) => Container(width: 200, height: 200, decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(
                color: C.lime.withAlpha((20 + 50 * _glowCtrl.value).round()),
                blurRadius: 50 + 20 * _glowCtrl.value, spreadRadius: 8)],
            )),
          ),
          // Main button
          AnimatedBuilder(
            animation: _tapCtrl,
            builder: (_, child) => Transform.scale(scale: 1 - _tapCtrl.value * 0.08, child: child),
            child: Container(
              width: 180, height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [C.lime.withAlpha(230), const Color(0xFFA07820)]),
                border: Border.all(color: C.lime, width: 2),
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(_stage.emoji, style: const TextStyle(fontSize: 64)),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                  decoration: BoxDecoration(color: Colors.black.withAlpha(60), borderRadius: BorderRadius.circular(12)),
                  child: Text('+$_tapValue', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
              ]),
            ),
          ),
          // Particles
          ..._particles.map((p) => Positioned(
            left: p.pos.dx - 20, top: p.pos.dy - 40,
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 900),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (_, t, __) => Opacity(
                opacity: (1 - t).clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(0, -55 * t),
                  child: Text(p.text, style: const TextStyle(color: C.lime, fontWeight: FontWeight.w900, fontSize: 22,
                      shadows: [Shadow(blurRadius: 6, color: Colors.orange)])),
                ),
              ),
            ),
          )),
          // Stats overlay (top right of tap area)
          Positioned(top: 8, right: 16, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('탭 ${_fmt(_totalTaps.toDouble())}회', style: const TextStyle(fontSize: 10, color: C.grey)),
            if (_prestige > 0)
              Text('x${_prestigeMulti.toStringAsFixed(1)} 배율', style: const TextStyle(fontSize: 10, color: C.lime, fontWeight: FontWeight.w700)),
          ])),
        ]),
      ),
    );
  }

  Widget _buildUpgradeSection() {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: C.border),
      ),
      child: Column(children: [
        // Tab selector
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
          child: Row(children: [
            _tabBtn('🏛️ 건물', 0),
            const SizedBox(width: 8),
            _tabBtn('💪 탭 강화', 1),
            const Spacer(),
            Text(_fmt(_pts) + ' pt', style: const TextStyle(fontSize: 11, color: C.lime, fontWeight: FontWeight.w700)),
          ]),
        ),
        // List
        Expanded(child: _selectedTab == 0 ? _buildingList() : _tapUpgradeList()),
      ]),
    );
  }

  Widget _tabBtn(String label, int idx) {
    final active = _selectedTab == idx;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = idx),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        color: active ? C.lime : C.elevated,
        child: Text(label, style: S.body.copyWith(color: active ? C.bg : C.grey, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildingList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
      itemCount: _buildings.length,
      itemBuilder: (_, i) {
        final b = _buildings[i];
        final can = b.canBuy(_pts);
        return GestureDetector(
          onTap: () => _buyBuilding(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: can ? C.elevated : C.bg,


              border: Border.all(color: can ? C.lime.withAlpha(80) : C.border),
            ),
            child: Row(children: [
              Text(b.emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(b.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: b.owned > 0 ? C.lime.withAlpha(40) : C.surface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('보유 ${b.owned}',
                        style: TextStyle(fontSize: 10, color: b.owned > 0 ? C.lime : C.grey, fontWeight: FontWeight.w600)),
                  ),
                ]),
                Text(b.owned > 0 ? '초당 ${_fmt(b.totalPerSec)} pt' : b.desc,
                    style: const TextStyle(fontSize: 11, color: C.grey)),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(_fmt(b.nextCost),
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: can ? C.lime : C.grey)),
                const Text('pt', style: TextStyle(fontSize: 10, color: C.grey)),
              ]),
            ]),
          ),
        );
      },
    );
  }

  Widget _tapUpgradeList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
      itemCount: _tapUpgrades.length,
      itemBuilder: (_, i) {
        final u = _tapUpgrades[i];
        final can = !u.bought && _pts >= u.cost;
        return GestureDetector(
          onTap: () => _buyTapUpgrade(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: u.bought ? C.surface : (can ? C.elevated : C.bg),


              border: Border.all(color: u.bought ? C.lime.withAlpha(40) : (can ? C.lime.withAlpha(80) : C.border)),
            ),
            child: Row(children: [
              Text(u.bought ? '✅' : u.emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(u.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                Text(u.bought ? '구매 완료 (+${u.tapBonus} 탭)' : u.desc, style: const TextStyle(fontSize: 11, color: C.grey)),
              ])),
              if (!u.bought)
                Text('${_fmt(u.cost.toDouble())} pt',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: can ? C.lime : C.grey)),
              if (u.bought)
                const Text('+탭 강화', style: TextStyle(fontSize: 11, color: C.lime)),
            ]),
          ),
        );
      },
    );
  }
}

class _Particle { final Offset pos; final String text; _Particle(this.pos, this.text); }
