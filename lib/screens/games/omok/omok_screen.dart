import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/app_theme.dart';

const _size = 15;
const _win = 5;

enum _Stone { none, black, white }

class OmokScreen extends StatefulWidget {
  const OmokScreen({super.key});

  @override
  State<OmokScreen> createState() => _OmokScreenState();
}

class _OmokScreenState extends State<OmokScreen> {
  late List<List<_Stone>> _board;
  bool _playerTurn = true;
  bool _gameOver = false;
  bool _aiThinking = false;
  int _playerWins = 0;
  int _aiWins = 0;
  (int, int)? _lastMove;
  List<(int, int)> _winLine = [];
  String _difficulty = '제자';
  final List<List<List<_Stone>>> _history = [];

  int get _depth => switch (_difficulty) { '사도' => 3, '선지자' => 4, _ => 2 };

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  void _newGame() {
    _board = List.generate(_size, (_) => List.filled(_size, _Stone.none));
    _playerTurn = true;
    _gameOver = false;
    _aiThinking = false;
    _lastMove = null;
    _winLine = [];
    _history.clear();
  }

  void _onTap(int r, int c) {
    if (!_playerTurn || _gameOver || _aiThinking || _board[r][c] != _Stone.none) return;
    _saveHistory();
    _place(r, c, _Stone.black);
  }

  void _saveHistory() {
    _history.add(List.generate(_size, (r) => List<_Stone>.from(_board[r])));
  }

  void _undo() {
    if (_history.length < 2 || _gameOver) return;
    setState(() {
      _history.removeLast(); // remove AI move snapshot
      if (_history.isNotEmpty) {
        _board = List.generate(_size, (r) => List<_Stone>.from(_history.last[r]));
      } else {
        _board = List.generate(_size, (_) => List.filled(_size, _Stone.none));
      }
      _lastMove = null;
      _winLine = [];
      _gameOver = false;
      _playerTurn = true;
      _aiThinking = false;
    });
  }

  void _place(int r, int c, _Stone stone) {
    setState(() {
      _board[r][c] = stone;
      _lastMove = (r, c);
    });
    HapticFeedback.selectionClick();

    final winCells = _findWinLine(r, c, stone);
    if (winCells.isNotEmpty) {
      setState(() {
        _gameOver = true;
        _winLine = winCells;
        if (stone == _Stone.black) _playerWins++;
        else _aiWins++;
      });
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 700), () => _showResult(stone == _Stone.black));
      return;
    }

    if (_isFull()) {
      setState(() => _gameOver = true);
      _showResult(null);
      return;
    }

    if (stone == _Stone.black) {
      _saveHistory();
      setState(() { _playerTurn = false; _aiThinking = true; });
      Future.delayed(const Duration(milliseconds: 250), _aiMove);
    } else {
      setState(() { _playerTurn = true; _aiThinking = false; });
    }
  }

  void _aiMove() {
    // First move: center
    bool hasStone = _board.any((row) => row.any((s) => s != _Stone.none));
    if (!hasStone) { _place(_size ~/ 2, _size ~/ 2, _Stone.white); return; }

    final move = _bestMove();
    if (move != null) _place(move.$1, move.$2, _Stone.white);
  }

  (int, int)? _bestMove() {
    // Check if AI can win immediately
    for (final m in _candidates()) {
      _board[m.$1][m.$2] = _Stone.white;
      if (_findWinLine(m.$1, m.$2, _Stone.white).isNotEmpty) {
        _board[m.$1][m.$2] = _Stone.none;
        return m;
      }
      _board[m.$1][m.$2] = _Stone.none;
    }
    // Check if player about to win (block)
    for (final m in _candidates()) {
      _board[m.$1][m.$2] = _Stone.black;
      if (_findWinLine(m.$1, m.$2, _Stone.black).isNotEmpty) {
        _board[m.$1][m.$2] = _Stone.none;
        return m;
      }
      _board[m.$1][m.$2] = _Stone.none;
    }

    int best = -999999;
    (int, int)? bestMove;
    for (final m in _candidates()) {
      _board[m.$1][m.$2] = _Stone.white;
      final score = _minimax(_board, _depth - 1, -999999, 999999, false);
      _board[m.$1][m.$2] = _Stone.none;
      if (score > best) { best = score; bestMove = m; }
    }
    return bestMove;
  }

  int _minimax(List<List<_Stone>> board, int depth, int alpha, int beta, bool maximizing) {
    final score = _evalBoard(board);
    if (score.abs() >= 90000 || depth == 0) return score;
    final candidates = _candidates();
    if (candidates.isEmpty) return score;

    if (maximizing) {
      int maxScore = -999999;
      for (final m in candidates) {
        board[m.$1][m.$2] = _Stone.white;
        final s = _minimax(board, depth - 1, alpha, beta, false);
        board[m.$1][m.$2] = _Stone.none;
        if (s > maxScore) maxScore = s;
        if (maxScore > alpha) alpha = maxScore;
        if (beta <= alpha) break;
      }
      return maxScore;
    } else {
      int minScore = 999999;
      for (final m in candidates) {
        board[m.$1][m.$2] = _Stone.black;
        final s = _minimax(board, depth - 1, alpha, beta, true);
        board[m.$1][m.$2] = _Stone.none;
        if (s < minScore) minScore = s;
        if (minScore < beta) beta = minScore;
        if (beta <= alpha) break;
      }
      return minScore;
    }
  }

  List<(int, int)> _candidates() {
    final Set<(int, int)> set = {};
    bool any = false;
    for (int r = 0; r < _size; r++) {
      for (int c = 0; c < _size; c++) {
        if (_board[r][c] == _Stone.none) continue;
        any = true;
        for (int dr = -2; dr <= 2; dr++) {
          for (int dc = -2; dc <= 2; dc++) {
            final nr = r + dr, nc = c + dc;
            if (nr >= 0 && nr < _size && nc >= 0 && nc < _size && _board[nr][nc] == _Stone.none) {
              set.add((nr, nc));
            }
          }
        }
      }
    }
    if (!any) set.add((_size ~/ 2, _size ~/ 2));
    return set.toList();
  }

  int _evalBoard(List<List<_Stone>> board) {
    int total = 0;
    final dirs = [(0,1),(1,0),(1,1),(1,-1)];
    for (int r = 0; r < _size; r++) {
      for (int c = 0; c < _size; c++) {
        for (final d in dirs) {
          total += _evalWindow(board, r, c, d.$1, d.$2);
        }
      }
    }
    return total;
  }

  int _evalWindow(List<List<_Stone>> board, int r, int c, int dr, int dc) {
    int white = 0, black = 0;
    for (int i = 0; i < _win; i++) {
      final nr = r + dr * i, nc = c + dc * i;
      if (nr < 0 || nr >= _size || nc < 0 || nc >= _size) return 0;
      final s = board[nr][nc];
      if (s == _Stone.white) white++;
      else if (s == _Stone.black) black++;
    }
    if (white > 0 && black > 0) return 0;
    if (white == _win) return 100000;
    if (black == _win) return -100000;
    if (white > 0) return const [0, 10, 100, 1500, 25000][white];
    if (black > 0) return -const [0, 10, 100, 1500, 25000][black];
    return 0;
  }

  List<(int, int)> _findWinLine(int r, int c, _Stone stone) {
    final dirs = [(0,1),(1,0),(1,1),(1,-1)];
    for (final d in dirs) {
      final line = <(int, int)>[];
      for (int sign in [-1, 1]) {
        int i = sign == 1 ? 0 : 1;
        while (true) {
          final nr = r + d.$1 * i * sign;
          final nc = c + d.$2 * i * sign;
          if (nr < 0 || nr >= _size || nc < 0 || nc >= _size || _board[nr][nc] != stone) break;
          if (sign == 1) line.add((nr, nc)); else line.insert(0, (nr, nc));
          i++;
        }
      }
      if (line.length >= _win) return line.take(_win).toList();
    }
    return [];
  }

  bool _isFull() => _board.every((row) => row.every((s) => s != _Stone.none));

  void _showResult(bool? playerWon) {
    showDialog(
      context: context, barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(playerWon == null ? '무승부!' : (playerWon ? '🎉 승리!' : '🙏 패배')),
        content: Text(
          playerWon == true
              ? '"야곱이 이르되 당신이 내게 축복하지 아니하면 가게 하지 아니하겠나이다"\n(창 32:26)'
              : playerWon == false
                  ? '"네 길을 여호와께 맡기라 그를 의지하면 그가 이루시리로다"\n(시 37:5)'
                  : '"서로 화목하라" (막 9:50)',
          style: const TextStyle(color: AppColors.secondary, fontSize: 13, fontStyle: FontStyle.italic),
        ),
        actions: [TextButton(
          onPressed: () { Navigator.pop(context); setState(() => _newGame()); },
          child: const Text('다시 도전', style: TextStyle(color: AppColors.gold)),
        )],
      ),
    );
  }

  void _changeDifficulty() {
    showModalBottomSheet(
      context: context, backgroundColor: AppColors.surface,
      builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Padding(padding: EdgeInsets.all(16), child: Text('난이도 선택', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
        ...{
          '제자': ('🌱', '쉬움 - 처음 배우는 단계'),
          '사도': ('⚔️', '보통 - 도전적인 수준'),
          '선지자': ('👑', '어려움 - 고수용'),
        }.entries.map((e) => ListTile(
          leading: Text(e.value.$1, style: const TextStyle(fontSize: 24)),
          title: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(e.value.$2),
          trailing: _difficulty == e.key ? const Icon(Icons.check_circle, color: AppColors.gold) : null,
          onTap: () { Navigator.pop(context); setState(() { _difficulty = e.key; _newGame(); }); },
        )),
        const SizedBox(height: 8),
      ])),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(child: Column(children: [
        _buildHeader(),
        _buildScoreBar(),
        Expanded(child: _buildBoard()),
        _buildStatusBar(),
      ])),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
            child: const Icon(Icons.close_rounded, size: 18, color: AppColors.secondary),
          ),
        ),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('예수님과 오목', style: AppTextStyles.cardTitle),
          Text('야곱의 씨름', style: AppTextStyles.caption.copyWith(color: AppColors.secondary)),
        ]),
        const Spacer(),
        GestureDetector(
          onTap: _changeDifficulty,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.omokEmerald,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.omokEmeraldAccent.withAlpha(30)),
            ),
            child: Text('⚔️ $_difficulty', style: AppTextStyles.body.copyWith(color: AppColors.omokEmeraldAccent)),
          ),
        ),
      ]),
    );
  }

  Widget _buildScoreBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        _scoreChip('나 (흑)', _playerWins, true, _playerTurn && !_gameOver),
        const Spacer(),
        if (_aiThinking)
          const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold))
        else
          Text(
            _gameOver ? '게임 종료' : (_playerTurn ? '내 차례 ⚫' : '예수님 차례 ⚪'),
            style: const TextStyle(fontSize: 12, color: AppColors.secondary),
          ),
        const Spacer(),
        _scoreChip('예수님 (백)', _aiWins, false, !_playerTurn && !_gameOver),
      ]),
    );
  }

  Widget _scoreChip(String label, int wins, bool isBlack, bool active) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 22, height: 22,
        decoration: BoxDecoration(
          color: isBlack ? Colors.black : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: active ? AppColors.gold : AppColors.border, width: active ? 2.5 : 1),
          boxShadow: active ? [BoxShadow(color: AppColors.gold.withAlpha(100), blurRadius: 8)] : null,
        ),
      ),
      const SizedBox(width: 6),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        Text('$wins승', style: const TextStyle(fontSize: 10, color: AppColors.secondary)),
      ]),
    ]);
  }

  Widget _buildBoard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: AspectRatio(
        aspectRatio: 1,
        child: LayoutBuilder(
          builder: (_, constraints) {
            final boardPx = constraints.maxWidth;
            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFFC8A96E),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withAlpha(80), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: GestureDetector(
                onTapDown: (d) {
                  // Use actual board pixel size from LayoutBuilder
                  final pad = boardPx * 0.05;
                  final cell = (boardPx - pad * 2) / (_size - 1);
                  final col = ((d.localPosition.dx - pad) / cell).round();
                  final row = ((d.localPosition.dy - pad) / cell).round();
                  if (row >= 0 && row < _size && col >= 0 && col < _size) {
                    _onTap(row, col);
                  }
                },
                child: CustomPaint(
                  painter: _OmokPainter(_board, _lastMove, _winLine),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(children: [
        Expanded(child: OutlinedButton.icon(
          onPressed: _history.length >= 2 && !_gameOver && !_aiThinking ? _undo : null,
          icon: const Icon(Icons.undo, size: 16),
          label: const Text('무르기'),
          style: OutlinedButton.styleFrom(foregroundColor: AppColors.secondary, side: const BorderSide(color: AppColors.border)),
        )),
        const SizedBox(width: 8),
        Expanded(flex: 2, child: ElevatedButton.icon(
          onPressed: () => setState(() => _newGame()),
          icon: const Icon(Icons.refresh, size: 16),
          label: Text(_gameOver ? '다시 도전' : '새 게임'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2D6A2D),
            foregroundColor: AppColors.white,
          ),
        )),
        const SizedBox(width: 8),
        Expanded(child: OutlinedButton.icon(
          onPressed: _changeDifficulty,
          icon: const Icon(Icons.tune, size: 16),
          label: const Text('난이도'),
          style: OutlinedButton.styleFrom(foregroundColor: AppColors.secondary, side: const BorderSide(color: AppColors.border)),
        )),
      ]),
    );
  }
}

class _OmokPainter extends CustomPainter {
  final List<List<_Stone>> board;
  final (int, int)? lastMove;
  final List<(int, int)> winLine;

  _OmokPainter(this.board, this.lastMove, this.winLine);

  @override
  void paint(Canvas canvas, Size size) {
    final pad = size.width * 0.05;
    final cell = (size.width - pad * 2) / (_size - 1);
    final linePaint = Paint()..color = const Color(0xFF7A5C1E)..strokeWidth = 1;

    // Grid lines
    for (int i = 0; i < _size; i++) {
      canvas.drawLine(Offset(pad + i * cell, pad), Offset(pad + i * cell, size.height - pad), linePaint);
      canvas.drawLine(Offset(pad, pad + i * cell), Offset(size.width - pad, pad + i * cell), linePaint);
    }

    // Border thick lines
    final borderPaint = Paint()..color = const Color(0xFF5A3E0A)..strokeWidth = 2..style = PaintingStyle.stroke;
    canvas.drawRect(Rect.fromLTWH(pad, pad, cell * (_size - 1), cell * (_size - 1)), borderPaint);

    // Hoshi (star) points - standard 15x15 positions
    final starPaint = Paint()..color = const Color(0xFF5A3E0A);
    for (final p in [(3,3),(3,7),(3,11),(7,3),(7,7),(7,11),(11,3),(11,7),(11,11)]) {
      canvas.drawCircle(Offset(pad + p.$2 * cell, pad + p.$1 * cell), 4, starPaint);
    }

    // Stones
    for (int r = 0; r < _size; r++) {
      for (int c = 0; c < _size; c++) {
        if (board[r][c] == _Stone.none) continue;
        final cx = pad + c * cell;
        final cy = pad + r * cell;
        final isBlack = board[r][c] == _Stone.black;
        final isWin = winLine.any((w) => w.$1 == r && w.$2 == c);
        final isLast = lastMove?.$1 == r && lastMove?.$2 == c;
        final radius = cell * 0.44;

        // Shadow
        canvas.drawCircle(Offset(cx + 1.2, cy + 1.8), radius, Paint()..color = Colors.black.withAlpha(70));

        // Stone gradient
        final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);
        final gradient = isBlack
            ? RadialGradient(colors: [const Color(0xFF555555), Colors.black], center: const Alignment(-0.3, -0.4))
            : const RadialGradient(colors: [Colors.white, Color(0xFFCCCCCC)], center: Alignment(-0.3, -0.4));
        canvas.drawCircle(Offset(cx, cy), radius, Paint()..shader = gradient.createShader(rect));

        // White stone border
        if (!isBlack) {
          canvas.drawCircle(Offset(cx, cy), radius, Paint()..color = Colors.grey[400]!..style = PaintingStyle.stroke..strokeWidth = 0.8);
        }

        // Win ring
        if (isWin) {
          canvas.drawCircle(Offset(cx, cy), radius + 2, Paint()..color = AppColors.gold..style = PaintingStyle.stroke..strokeWidth = 3);
        }

        // Last move dot
        if (isLast && !isWin) {
          canvas.drawCircle(Offset(cx, cy), radius * 0.28, Paint()..color = isBlack ? Colors.white.withAlpha(200) : Colors.red.withAlpha(200));
        }
      }
    }
  }

  @override
  bool shouldRepaint(_OmokPainter old) => true;
}
