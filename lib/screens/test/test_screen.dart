import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_theme.dart';
import 'test_data.dart';
import 'test_result_screen.dart';

class TestScreen extends StatefulWidget {
  final TestDef test;
  final bool isBibleTest;
  const TestScreen({super.key, required this.test, this.isBibleTest = false});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> with SingleTickerProviderStateMixin {
  int _qIdx = 0;
  int? _selectedAnswer;
  final Map<String, int> _scores = {};
  late AnimationController _fadeCtrl;

  List<TQ> get _questions => widget.test.questions;
  TQ get _currentQ => _questions[_qIdx];
  double get _progress => (_qIdx + 1) / _questions.length;
  bool get _isLast => _qIdx >= _questions.length - 1;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _selectAnswer(int idx) {
    if (_selectedAnswer != null) return;
    HapticFeedback.selectionClick();
    setState(() => _selectedAnswer = idx);

    // 점수 합산
    final answer = _currentQ.answers[idx];
    answer.scores.forEach((key, val) {
      _scores[key] = (_scores[key] ?? 0) + val;
    });

    // 다음 질문 또는 결과
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      if (_isLast) {
        _showResult();
      } else {
        _fadeCtrl.reverse().then((_) {
          setState(() { _qIdx++; _selectedAnswer = null; });
          _fadeCtrl.forward();
        });
      }
    });
  }

  void _showResult() {
    final result = widget.isBibleTest
        ? getBibleResult(_scores)
        : widget.test.getResult(_scores);

    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (_) => TestResultScreen(test: widget.test, result: result, scores: _scores),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: Column(children: [
          _header(),
          _progressBar(),
          Expanded(child: _questionBody()),
        ]),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(children: [
        GestureDetector(
          onTap: () => _confirmExit(),
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: C.border)),
            child: const Icon(Icons.close_rounded, size: 18, color: C.grey),
          ),
        ),
        const SizedBox(width: 12),
        Text(widget.test.title, style: S.title),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: C.limeSoft, borderRadius: BorderRadius.circular(8)),
          child: Text('${_qIdx + 1}/${_questions.length}', style: S.body.copyWith(color: C.lime, fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }

  Widget _progressBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${(_progress * 100).round()}% 완료', style: S.caption.copyWith(color: C.lime)),
          Text('${_questions.length - _qIdx - 1}문항 남음', style: S.caption),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _progress,
            backgroundColor: C.elevated,
            valueColor: const AlwaysStoppedAnimation(C.lime),
            minHeight: 6,
          ),
        ),
      ]),
    );
  }

  Widget _questionBody() {
    return FadeTransition(
      opacity: _fadeCtrl,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
        children: [
          // 질문 번호
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: C.limeSoft, borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text('Q${_qIdx + 1}', style: S.body.copyWith(color: C.lime, fontWeight: FontWeight.w800))),
          ),
          const SizedBox(height: 16),
          // 질문
          Text(_currentQ.question, style: S.displayMedium.copyWith(height: 1.3)),
          const SizedBox(height: 28),
          // 선택지
          ...List.generate(_currentQ.answers.length, (i) => _answerCard(i)),
        ],
      ),
    );
  }

  Widget _answerCard(int idx) {
    final answer = _currentQ.answers[idx];
    final selected = _selectedAnswer == idx;
    final answered = _selectedAnswer != null;
    final labels = ['A', 'B', 'C', 'D'];

    return GestureDetector(
      onTap: answered ? null : () => _selectAnswer(idx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: selected ? C.lime.withAlpha(15) : C.surface,
          border: Border.all(
            color: selected ? C.lime : (answered ? C.border.withAlpha(60) : C.border),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(children: [
          // 라벨
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: selected ? C.lime : C.elevated,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Text(
              labels[idx],
              style: S.body.copyWith(
                color: selected ? C.bg : C.grey,
                fontWeight: FontWeight.w800,
              ),
            )),
          ),
          const SizedBox(width: 14),
          // 텍스트
          Expanded(child: Text(
            answer.text,
            style: S.body.copyWith(
              color: selected ? C.white : (answered ? C.greyDark : C.white90),
              height: 1.4,
            ),
          )),
          if (selected)
            const Icon(Icons.check_circle_rounded, color: C.lime, size: 22),
        ]),
      ),
    );
  }

  void _confirmExit() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: C.surface,
        title: Text('테스트를 중단할까요?', style: S.title),
        content: Text('진행 상황이 저장되지 않습니다.', style: S.bodySmall),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('계속하기', style: S.body.copyWith(color: C.grey)),
          ),
          TextButton(
            onPressed: () { Navigator.pop(context); Navigator.pop(context); },
            child: Text('나가기', style: S.body.copyWith(color: C.lime)),
          ),
        ],
      ),
    );
  }
}
