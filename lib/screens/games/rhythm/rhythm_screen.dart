import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import '../../../core/app_theme.dart';

class _Verse {
  final String reference;
  final String text;
  final List<String> words;
  const _Verse(this.reference, this.text, this.words);
}

const _verses = [
  _Verse('요한복음 3:16', '하나님이 세상을 이처럼 사랑하사 독생자를 주셨으니',
      ['하나님이', '세상을', '이처럼', '사랑하사', '독생자를', '주셨으니']),
  _Verse('빌립보서 4:13', '내게 능력 주시는 자 안에서 내가 모든 것을 할 수 있느니라',
      ['내게', '능력', '주시는', '자', '안에서', '내가', '모든', '것을', '할', '수', '있느니라']),
  _Verse('시편 23:1', '여호와는 나의 목자시니 내게 부족함이 없으리로다',
      ['여호와는', '나의', '목자시니', '내게', '부족함이', '없으리로다']),
  _Verse('로마서 8:28', '하나님을 사랑하는 자들에게는 모든 것이 합력하여 선을 이루느니라',
      ['하나님을', '사랑하는', '자들에게는', '모든', '것이', '합력하여', '선을', '이루느니라']),
  _Verse('잠언 3:5-6', '너는 마음을 다하여 여호와를 신뢰하고 네 명철을 의지하지 말라',
      ['너는', '마음을', '다하여', '여호와를', '신뢰하고', '네', '명철을', '의지하지', '말라']),
];

const _laneColors = [C.lane1, C.lane2, C.lane3, C.lane4];
const _hitZoneY = 0.80; // 80% down the lane area
const _hitWindow = 0.12;

enum _JudgeResult { perfect, good, miss }

class _FallingTile {
  final String text;
  final int lane;
  double y; // 0=top, 1=bottom
  bool judged;

  _FallingTile({required this.text, required this.lane, this.y = -0.15, this.judged = false});
}

class _Judgment {
  final _JudgeResult result;
  final int lane;
  double opacity;

  _Judgment({required this.result, required this.lane, this.opacity = 1.0});
}

class RhythmScreen extends StatefulWidget {
  const RhythmScreen({super.key});

  @override
  State<RhythmScreen> createState() => _RhythmScreenState();
}

class _RhythmScreenState extends State<RhythmScreen> with TickerProviderStateMixin {
  late _Verse _verse;
  final _tiles = <_FallingTile>[];
  final _judgments = <_Judgment>[];
  final _laneTap = [false, false, false, false];

  int _wordIdx = 0;
  int _score = 0;
  int _combo = 0;
  int _maxCombo = 0;
  int _perfect = 0;
  int _good = 0;
  int _miss = 0;
  bool _started = false;
  bool _finished = false;

  Ticker? _ticker;
  Duration _elapsed = Duration.zero;
  Duration _lastSpawn = Duration.zero;
  Duration _lastJudgeFade = Duration.zero;

  final _bpm = 80.0;
  double get _spawnInterval => 60000 / _bpm; // ms per beat
  double get _fallSpeed => 0.0006; // fraction per ms

  @override
  void initState() {
    super.initState();
    _verse = _verses[Random().nextInt(_verses.length)];
  }

  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }

  void _startGame() {
    setState(() => _started = true);
    _ticker = createTicker((elapsed) {
      final dt = (elapsed - _elapsed).inMilliseconds.toDouble();
      _elapsed = elapsed;
      _update(dt, elapsed);
    });
    _ticker!.start();
  }

  void _update(double dt, Duration elapsed) {
    if (!mounted) return;
    setState(() {
      // Move tiles
      for (final tile in _tiles) {
        if (!tile.judged) tile.y += _fallSpeed * dt;
      }

      // Auto-miss tiles past hit zone + tolerance
      for (final tile in _tiles) {
        if (!tile.judged && tile.y > _hitZoneY + _hitWindow + 0.05) {
          tile.judged = true;
          _miss++;
          _combo = 0;
          _judgments.add(_Judgment(result: _JudgeResult.miss, lane: tile.lane));
          HapticFeedback.lightImpact();
        }
      }

      // Spawn new tile
      final sinceSpawn = (elapsed - _lastSpawn).inMilliseconds.toDouble();
      if (_wordIdx < _verse.words.length && sinceSpawn >= _spawnInterval) {
        _lastSpawn = elapsed;
        _tiles.add(_FallingTile(
          text: _verse.words[_wordIdx],
          lane: _wordIdx % 4,
        ));
        _wordIdx++;
      }

      // Fade judgments
      final sinceFade = (elapsed - _lastJudgeFade).inMilliseconds.toDouble();
      if (sinceFade > 16) {
        _lastJudgeFade = elapsed;
        for (final j in _judgments) {
          j.opacity -= 0.035;
        }
        _judgments.removeWhere((j) => j.opacity <= 0);
      }

      // Remove judged tiles off screen
      _tiles.removeWhere((t) => t.judged && t.y > 1.1);

      // Check finish
      if (!_finished && _wordIdx >= _verse.words.length && _tiles.every((t) => t.judged)) {
        _finished = true;
        _ticker?.stop();
        Future.delayed(const Duration(milliseconds: 800), _showResult);
      }
    });
  }

  void _tapLane(int lane) {
    if (!_started || _finished) return;

    // Find closest tile in this lane
    _FallingTile? closest;
    double bestDist = 999;
    for (final tile in _tiles) {
      if (!tile.judged && tile.lane == lane) {
        final dist = (tile.y - _hitZoneY).abs();
        if (dist < bestDist) { bestDist = dist; closest = tile; }
      }
    }

    setState(() {
      _laneTap[lane] = true;
      Timer(const Duration(milliseconds: 120), () {
        if (mounted) setState(() => _laneTap[lane] = false);
      });

      if (closest != null && bestDist <= _hitWindow) {
        closest.judged = true;
        _combo++;
        if (_combo > _maxCombo) _maxCombo = _combo;

        final isPerfect = bestDist <= _hitWindow * 0.5;
        if (isPerfect) {
          _perfect++;
          _score += 100 + min(_combo * 5, 50);
          _judgments.add(_Judgment(result: _JudgeResult.perfect, lane: lane));
        } else {
          _good++;
          _score += 60 + min(_combo * 3, 30);
          _judgments.add(_Judgment(result: _JudgeResult.good, lane: lane));
        }
        HapticFeedback.selectionClick();
      } else {
        // Tap but no tile in window - empty tap, no combo break
      }
    });
  }

  void _showResult() {
    final total = _verse.words.length;
    final accuracy = total == 0 ? 0 : ((_perfect + _good) / total * 100).round();
    final rank = accuracy >= 95 ? 'S' : accuracy >= 80 ? 'A' : accuracy >= 60 ? 'B' : 'C';

    showDialog(
      context: context, barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: C.surface,
        title: Text('랭크 $rank  ${accuracy >= 80 ? "✅ 암송 완료!" : "다시 도전!"}'),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_verse.reference, style: const TextStyle(color: C.lime, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _resultRow('🎯 점수', '$_score pt'),
          _resultRow('💯 정확도', '$accuracy%'),
          _resultRow('✨ PERFECT', '$_perfect'),
          _resultRow('👍 GOOD', '$_good'),
          _resultRow('❌ MISS', '$_miss'),
          _resultRow('🔥 최대 콤보', '$_maxCombo'),
          if (accuracy >= 80) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: C.lime.withAlpha(30), borderRadius: BorderRadius.circular(8), border: Border.all(color: C.lime.withAlpha(80))),
              child: Text('"${_verse.text}"\n- ${_verse.reference}', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, height: 1.5)),
            ),
          ],
        ]),
        actions: [TextButton(
          onPressed: () {
            Navigator.pop(context);
            setState(() {
              _tiles.clear(); _judgments.clear();
              _wordIdx = 0; _score = 0; _combo = 0; _maxCombo = 0;
              _perfect = 0; _good = 0; _miss = 0;
              _started = false; _finished = false;
              _elapsed = Duration.zero; _lastSpawn = Duration.zero;
              _verse = _verses[Random().nextInt(_verses.length)];
            });
            _ticker?.dispose();
            _ticker = null;
          },
          child: const Text('다시하기', style: TextStyle(color: C.lime)),
        )],
      ),
    );
  }

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        Text(label, style: const TextStyle(fontSize: 13)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(child: Column(children: [
        _buildHeader(),
        _buildVerseBar(),
        Expanded(child: _buildLaneArea()),
        _buildHitButtons(),
      ])),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(children: [
        GestureDetector(
          onTap: () { _ticker?.stop(); Navigator.pop(context); },
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: C.border)),
            child: const Icon(Icons.close_rounded, size: 18, color: C.grey),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('말씀 암송 리듬게임', style: S.cardTitle),
          Text(_verse.reference, style: S.caption.copyWith(color: C.grey)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: C.rhythmViolet,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: C.rhythmViolet.withAlpha(30)),
          ),
          child: Text('🔥 x$_combo', style: S.body.copyWith(color: C.rhythmViolet, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [C.lime.withAlpha(20), C.lime.withAlpha(8)]),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text('$_score', style: S.title.copyWith(color: C.lime)),
        ),
      ]),
    );
  }

  Widget _buildVerseBar() {
    final done = _wordIdx;
    final total = _verse.words.length;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Text('"${_verse.text}"',
            style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: C.white, height: 1.5),
            textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : done / total,
              backgroundColor: C.border,
              valueColor: const AlwaysStoppedAnimation(C.lime),
              minHeight: 5,
            ),
          )),
          const SizedBox(width: 8),
          Text('$done/$total', style: const TextStyle(fontSize: 11, color: C.grey)),
        ]),
      ]),
    );
  }

  Widget _buildLaneArea() {
    return LayoutBuilder(builder: (ctx, constraints) {
      return Stack(children: [
        // Lane backgrounds
        Row(children: List.generate(4, (i) => Expanded(child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: i > 0 ? const BorderSide(color: C.border, width: 0.5) : BorderSide.none,
            ),
          ),
        )))),

        // Hit zone line
        Positioned(
          left: 0, right: 0,
          top: constraints.maxHeight * _hitZoneY,
          child: Container(height: 2, color: C.lime.withAlpha(120)),
        ),

        // Falling tiles
        ..._tiles.where((t) => !t.judged).map((tile) {
          final laneW = constraints.maxWidth / 4;
          final x = tile.lane * laneW + laneW * 0.08;
          final y = tile.y * constraints.maxHeight - 26;
          return Positioned(
            left: x, top: y, width: laneW * 0.84,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
              decoration: BoxDecoration(
                color: _laneColors[tile.lane],
                boxShadow: [BoxShadow(color: _laneColors[tile.lane].withAlpha(120), blurRadius: 8, spreadRadius: 1)],
              ),
              child: Text(tile.text,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                  textAlign: TextAlign.center),
            ),
          );
        }),

        // Judgment texts
        ..._judgments.map((j) {
          final laneW = constraints.maxWidth / 4;
          final x = j.lane * laneW;
          return Positioned(
            left: x, width: laneW,
            top: constraints.maxHeight * (_hitZoneY - 0.15),
            child: Opacity(
              opacity: j.opacity.clamp(0.0, 1.0),
              child: Center(child: Text(
                j.result == _JudgeResult.perfect ? 'PERFECT' : j.result == _JudgeResult.good ? 'GOOD' : 'MISS',
                style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w900,
                  color: j.result == _JudgeResult.perfect ? C.lime
                      : j.result == _JudgeResult.good ? Colors.lightGreen
                      : Colors.redAccent,
                ),
              )),
            ),
          );
        }),

        // Start overlay
        if (!_started)
          Container(
            color: C.bg.withAlpha(220),
            child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('🎵', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 8),
              const Text('4개의 라인에서 단어가 내려옵니다\n박자에 맞춰 해당 버튼을 누르세요!',
                  style: TextStyle(fontSize: 13, color: C.grey, height: 1.6), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _startGame,
                style: ElevatedButton.styleFrom(backgroundColor: C.lime, foregroundColor: C.bg, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
                child: const Text('시작', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              ),
            ])),
          ),
      ]);
    });
  }

  Widget _buildHitButtons() {
    return Container(
      height: 76,
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 12),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: C.border))),
      child: Row(children: List.generate(4, (i) => Expanded(
        child: GestureDetector(
          onTapDown: (_) => _tapLane(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: _laneTap[i] ? _laneColors[i] : _laneColors[i].withAlpha(60),
              border: Border.all(color: _laneColors[i], width: _laneTap[i] ? 3 : 1.5),
              boxShadow: _laneTap[i] ? [BoxShadow(color: _laneColors[i].withAlpha(160), blurRadius: 12, spreadRadius: 2)] : null,
            ),
          ),
        ),
      ))),
    );
  }
}
