import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/app_theme.dart';

const _cols = 10;
const _rows = 20;

// Piece defs: [rotation][cell][row,col offset]
const _pieceDefs = [
  // 0: I 🦒
  [[[0,0],[0,1],[0,2],[0,3]],[[0,0],[1,0],[2,0],[3,0]],[[0,0],[0,1],[0,2],[0,3]],[[0,0],[1,0],[2,0],[3,0]]],
  // 1: O 🐘
  [[[0,0],[0,1],[1,0],[1,1]],[[0,0],[0,1],[1,0],[1,1]],[[0,0],[0,1],[1,0],[1,1]],[[0,0],[0,1],[1,0],[1,1]]],
  // 2: T 🦁
  [[[0,1],[1,0],[1,1],[1,2]],[[0,0],[1,0],[1,1],[2,0]],[[0,0],[0,1],[0,2],[1,1]],[[0,1],[1,0],[1,1],[2,1]]],
  // 3: S 🐊
  [[[0,1],[0,2],[1,0],[1,1]],[[0,0],[1,0],[1,1],[2,1]],[[0,1],[0,2],[1,0],[1,1]],[[0,0],[1,0],[1,1],[2,1]]],
  // 4: Z 🐆
  [[[0,0],[0,1],[1,1],[1,2]],[[0,1],[1,0],[1,1],[2,0]],[[0,0],[0,1],[1,1],[1,2]],[[0,1],[1,0],[1,1],[2,0]]],
  // 5: J 🦘
  [[[0,0],[1,0],[1,1],[1,2]],[[0,0],[0,1],[1,0],[2,0]],[[0,0],[0,1],[0,2],[1,2]],[[0,1],[1,1],[2,0],[2,1]]],
  // 6: L 🐧
  [[[0,2],[1,0],[1,1],[1,2]],[[0,0],[1,0],[2,0],[2,1]],[[0,0],[0,1],[0,2],[1,0]],[[0,0],[0,1],[1,1],[2,1]]],
];
const _pieceEmojis = ['🦒','🐘','🦁','🐊','🐆','🦘','🐧'];
const _pieceColors = [
  Color(0xFF00BCD4), Color(0xFFFFEB3B), Color(0xFF9C27B0),
  Color(0xFF4CAF50), Color(0xFFF44336), Color(0xFF3F51B5), Color(0xFFFF9800),
];
const _spawnCols = [3, 4, 3, 3, 3, 3, 3];

// Wall kick offsets: [attempt][dr,dc]
const _wallKicks = [[0,0],[0,-1],[0,1],[0,-2],[0,2],[-1,0]];

class _Piece {
  int row, col, type, rot;
  _Piece({required this.row, required this.col, required this.type, this.rot = 0});

  List<List<int>> get cells {
    return _pieceDefs[type][rot % 4].map((o) => [row + o[0], col + o[1]]).toList();
  }

  _Piece copyWith({int? row, int? col, int? rot}) =>
      _Piece(row: row ?? this.row, col: col ?? this.col, type: type, rot: rot ?? this.rot);
}

class NoahTetrisScreen extends StatefulWidget {
  const NoahTetrisScreen({super.key});

  @override
  State<NoahTetrisScreen> createState() => _NoahTetrisScreenState();
}

class _NoahTetrisScreenState extends State<NoahTetrisScreen> {
  late List<List<int?>> _board;
  late List<List<String?>> _boardEmoji;
  _Piece? _current;
  _Piece? _held;
  int _nextType = 0;
  bool _canHold = true;
  int _score = 0;
  int _level = 1;
  int _lines = 0;
  bool _gameOver = false;
  bool _started = false;
  Timer? _fallTimer;
  Timer? _lockTimer;
  Timer? _repeatTimer;
  final Random _rng = Random();
  final List<int> _bag = [];

  int get _fallMs => max(80, 700 - (_level - 1) * 60);

  @override
  void initState() {
    super.initState();
    _reset();
  }

  @override
  void dispose() {
    _fallTimer?.cancel();
    _lockTimer?.cancel();
    _repeatTimer?.cancel();
    super.dispose();
  }

  void _reset() {
    _board = List.generate(_rows, (_) => List.filled(_cols, null));
    _boardEmoji = List.generate(_rows, (_) => List.filled(_cols, null));
    _score = 0; _level = 1; _lines = 0;
    _gameOver = false; _started = false;
    _current = null; _held = null; _canHold = true;
    _bag.clear();
    _nextType = _drawFromBag();
    _fallTimer?.cancel();
    _lockTimer?.cancel();
  }

  int _drawFromBag() {
    if (_bag.isEmpty) _bag.addAll(List.generate(7, (i) => i)..shuffle(_rng));
    return _bag.removeAt(0);
  }

  void _startGame() {
    setState(() {
      _started = true;
      _spawnPiece();
    });
    _startFallTimer();
  }

  void _startFallTimer() {
    _fallTimer?.cancel();
    _fallTimer = Timer.periodic(Duration(milliseconds: _fallMs), (_) => _tick());
  }

  void _spawnPiece() {
    final type = _nextType;
    _nextType = _drawFromBag();
    _canHold = true;
    _current = _Piece(row: 0, col: _spawnCols[type], type: type);
    if (!_isValid(_current!)) {
      _current = null;
      _gameOver = true;
      _fallTimer?.cancel();
      _showGameOver();
    }
  }

  bool _isValid(_Piece p) {
    for (final c in p.cells) {
      if (c[0] < 0 || c[0] >= _rows || c[1] < 0 || c[1] >= _cols) return false;
      if (_board[c[0]][c[1]] != null) return false;
    }
    return true;
  }

  void _tick() {
    if (_current == null || _gameOver) return;
    final moved = _current!.copyWith(row: _current!.row + 1);
    if (_isValid(moved)) {
      setState(() => _current = moved);
      _lockTimer?.cancel();
    } else {
      _scheduleLock();
    }
  }

  void _scheduleLock() {
    _lockTimer?.cancel();
    _lockTimer = Timer(const Duration(milliseconds: 350), _lockPiece);
  }

  void _lockPiece() {
    if (_current == null) return;
    for (final c in _current!.cells) {
      if (c[0] >= 0 && c[0] < _rows && c[1] >= 0 && c[1] < _cols) {
        _board[c[0]][c[1]] = _current!.type;
        _boardEmoji[c[0]][c[1]] = _pieceEmojis[_current!.type];
      }
    }
    HapticFeedback.lightImpact();
    _clearLines();
    _spawnPiece();
    setState(() {});
  }

  void _clearLines() {
    final fullRows = <int>[];
    for (int r = 0; r < _rows; r++) {
      if (_board[r].every((c) => c != null)) fullRows.add(r);
    }
    if (fullRows.isEmpty) return;

    for (final r in fullRows.reversed) {
      _board.removeAt(r);
      _board.insert(0, List.filled(_cols, null));
      _boardEmoji.removeAt(r);
      _boardEmoji.insert(0, List.filled(_cols, null));
    }

    final cleared = fullRows.length;
    setState(() {
      _lines += cleared;
      _score += [0, 100, 300, 600, 1000][cleared.clamp(0, 4)] * _level;
      final newLevel = (_lines ~/ 10) + 1;
      if (newLevel > _level) {
        _level = newLevel;
        _startFallTimer();
      }
    });
    HapticFeedback.mediumImpact();
  }

  void _moveLeft() {
    if (_current == null || _gameOver) return;
    final p = _current!.copyWith(col: _current!.col - 1);
    if (_isValid(p)) setState(() { _current = p; _lockTimer?.cancel(); });
  }

  void _moveRight() {
    if (_current == null || _gameOver) return;
    final p = _current!.copyWith(col: _current!.col + 1);
    if (_isValid(p)) setState(() { _current = p; _lockTimer?.cancel(); });
  }

  void _rotate() {
    if (_current == null || _gameOver) return;
    final newRot = (_current!.rot + 1) % 4;
    for (final kick in _wallKicks) {
      final p = _current!.copyWith(rot: newRot, row: _current!.row + kick[0], col: _current!.col + kick[1]);
      if (_isValid(p)) {
        setState(() { _current = p; _lockTimer?.cancel(); });
        HapticFeedback.selectionClick();
        return;
      }
    }
  }

  void _softDrop() {
    if (_current == null || _gameOver) return;
    final p = _current!.copyWith(row: _current!.row + 1);
    if (_isValid(p)) {
      setState(() { _current = p; _score += 1; });
    } else {
      _scheduleLock();
    }
  }

  void _hardDrop() {
    if (_current == null || _gameOver) return;
    var p = _current!;
    int dropped = 0;
    while (_isValid(p.copyWith(row: p.row + 1))) {
      p = p.copyWith(row: p.row + 1);
      dropped++;
    }
    setState(() { _current = p; _score += dropped * 2; });
    HapticFeedback.heavyImpact();
    _lockTimer?.cancel();
    _lockPiece();
  }

  void _holdPiece() {
    if (_current == null || !_canHold) return;
    setState(() {
      _canHold = false;
      if (_held == null) {
        _held = _Piece(row: 0, col: _spawnCols[_current!.type], type: _current!.type);
        _spawnPiece();
      } else {
        final heldType = _held!.type;
        _held = _Piece(row: 0, col: _spawnCols[_current!.type], type: _current!.type);
        _current = _Piece(row: 0, col: _spawnCols[heldType], type: heldType);
        if (!_isValid(_current!)) {
          _gameOver = true;
          _fallTimer?.cancel();
        }
      }
    });
  }

  _Piece? _ghostPiece() {
    if (_current == null) return null;
    var g = _current!;
    while (_isValid(g.copyWith(row: g.row + 1))) g = g.copyWith(row: g.row + 1);
    return g.row != _current!.row ? g : null;
  }

  void _startRepeat(VoidCallback action) {
    action();
    _repeatTimer?.cancel();
    _repeatTimer = Timer.periodic(const Duration(milliseconds: 80), (_) => action());
  }

  void _stopRepeat() {
    _repeatTimer?.cancel();
  }

  void _showGameOver() {
    showDialog(
      context: context, barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: C.surface,
        title: const Text('⛺ 홍수가 왔습니다!'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('점수: $_score', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          Text('레벨: $_level  |  줄: $_lines', style: const TextStyle(color: C.grey)),
          const SizedBox(height: 12),
          const Text('"노아가 여호와께서 자기에게 명하신 대로 다 준행하였더라" (창 7:5)',
              style: TextStyle(color: C.grey, fontSize: 12, fontStyle: FontStyle.italic), textAlign: TextAlign.center),
        ]),
        actions: [TextButton(
          onPressed: () { Navigator.pop(context); setState(() => _reset()); },
          child: const Text('다시 방주 짓기', style: TextStyle(color: C.lime)),
        )],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(child: Column(children: [
        _buildHeader(),
        Expanded(child: Row(children: [
          Expanded(flex: 2, child: _buildSidePanel(left: true)),
          Expanded(flex: 6, child: _buildBoard()),
          Expanded(flex: 2, child: _buildSidePanel(left: false)),
        ])),
        _buildControls(),
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
            decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: C.border)),
            child: const Icon(Icons.close_rounded, size: 18, color: C.grey),
          ),
        ),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('노아의 방주 테트리스', style: S.cardTitle),
          Text('Lv.$_level', style: S.caption.copyWith(color: C.grey)),
        ]),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [C.lime.withAlpha(20), C.lime.withAlpha(8)]),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: C.lime.withAlpha(30)),
          ),
          child: Row(children: [
            Text('$_score', style: S.title.copyWith(color: C.lime)),
            const SizedBox(width: 3),
            Text('PT', style: S.caption.copyWith(color: C.lime.withAlpha(150))),
          ]),
        ),
      ]),
    );
  }

  Widget _buildBoard() {
    final ghost = _ghostPiece();
    return AspectRatio(
      aspectRatio: _cols / _rows,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: C.border, width: 1),
        ),
        child: _started
            ? CustomPaint(painter: _BoardPainter(_board, _boardEmoji, _current, ghost))
            : _buildStartOverlay(),
      ),
    );
  }

  Widget _buildStartOverlay() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('🚢', style: TextStyle(fontSize: 52)),
      const SizedBox(height: 8),
      const Text('노아의 방주\n테트리스', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15), textAlign: TextAlign.center),
      const SizedBox(height: 4),
      const Text('동물 2마리씩 방주에\n효율적으로 채워라!', style: TextStyle(fontSize: 11, color: C.grey), textAlign: TextAlign.center),
      const SizedBox(height: 16),
      ElevatedButton(
        onPressed: _startGame,
        style: ElevatedButton.styleFrom(backgroundColor: C.lime, foregroundColor: C.bg),
        child: const Text('방주 짓기 시작', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
    ]));
  }

  Widget _buildSidePanel({required bool left}) {
    if (left) {
      return Column(children: [
        _miniPanel('HOLD', _held),
        const SizedBox(height: 8),
        _infoTile('LINES', '$_lines'),
      ]);
    } else {
      return Column(children: [
        _miniPanel('NEXT', _nextType != -1 ? _Piece(row: 0, col: 0, type: _nextType) : null),
        const SizedBox(height: 8),
        _infoTile('LEVEL', '$_level'),
      ]);
    }
  }

  Widget _miniPanel(String label, _Piece? piece) {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: C.border),
      ),
      child: Column(children: [
        Text(label, style: const TextStyle(fontSize: 9, color: C.grey, letterSpacing: 1)),
        const SizedBox(height: 4),
        SizedBox(
          height: 44,
          child: piece != null
              ? Center(child: Text(_pieceEmojis[piece.type], style: const TextStyle(fontSize: 28)))
              : const Center(child: Text('—', style: TextStyle(color: C.border))),
        ),
      ]),
    );
  }

  Widget _infoTile(String label, String value) {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: C.border),
      ),
      child: Column(children: [
        Text(label, style: S.caption),
        const SizedBox(height: 2),
        Text(value, style: S.title),
      ]),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _ctrlBtn(Icons.swap_horiz, _holdPiece, color: C.grey, size: 20, label: 'HOLD'),
        GestureDetector(
          onTapDown: (_) => _startRepeat(_moveLeft),
          onTapUp: (_) => _stopRepeat(),
          onTapCancel: _stopRepeat,
          child: _ctrlBox(Icons.arrow_back_ios_new, size: 28),
        ),
        _ctrlBtn(Icons.rotate_right, _rotate, color: C.lime, size: 26, label: 'ROT'),
        GestureDetector(
          onTapDown: (_) => _startRepeat(_moveRight),
          onTapUp: (_) => _stopRepeat(),
          onTapCancel: _stopRepeat,
          child: _ctrlBox(Icons.arrow_forward_ios, size: 28),
        ),
        GestureDetector(
          onTapDown: (_) => _startRepeat(_softDrop),
          onTapUp: (_) => _stopRepeat(),
          onTapCancel: _stopRepeat,
          onDoubleTap: _hardDrop,
          child: _ctrlBox(Icons.keyboard_arrow_down, size: 28),
        ),
        _ctrlBtn(Icons.vertical_align_bottom, _hardDrop, color: C.grey, size: 20, label: 'DROP'),
      ]),
    );
  }

  Widget _ctrlBtn(IconData icon, VoidCallback onTap, {Color color = C.white, double size = 24, String label = ''}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: C.border)),
          child: Icon(icon, color: color, size: size),
        ),
        if (label.isNotEmpty) Text(label, style: S.caption),
      ]),
    );
  }

  Widget _ctrlBox(IconData icon, {double size = 28}) {
    return Container(
      width: 56, height: 56,
      decoration: BoxDecoration(color: C.elevated, borderRadius: BorderRadius.circular(14), border: Border.all(color: C.border)),
      child: Icon(icon, color: C.white, size: size),
    );
  }
}

class _BoardPainter extends CustomPainter {
  final List<List<int?>> board;
  final List<List<String?>> emojis;
  final _Piece? current;
  final _Piece? ghost;

  _BoardPainter(this.board, this.emojis, this.current, this.ghost);

  @override
  void paint(Canvas canvas, Size size) {
    final cw = size.width / _cols;
    final ch = size.height / _rows;

    // Background grid
    final gridPaint = Paint()..color = const Color(0xFF1A1A2E)..strokeWidth = 0.5;
    for (int r = 0; r <= _rows; r++) canvas.drawLine(Offset(0, r * ch), Offset(size.width, r * ch), gridPaint);
    for (int c = 0; c <= _cols; c++) canvas.drawLine(Offset(c * cw, 0), Offset(c * cw, size.height), gridPaint);

    // Locked cells
    for (int r = 0; r < _rows; r++) {
      for (int c = 0; c < _cols; c++) {
        if (board[r][c] != null) _drawCell(canvas, r, c, cw, ch, _pieceColors[board[r][c]!], emojis[r][c], 1.0);
      }
    }

    // Ghost piece
    if (ghost != null) {
      for (final cell in ghost!.cells) {
        _drawCellGhost(canvas, cell[0], cell[1], cw, ch, _pieceColors[ghost!.type]);
      }
    }

    // Current piece
    if (current != null) {
      for (final cell in current!.cells) {
        if (cell[0] >= 0) _drawCell(canvas, cell[0], cell[1], cw, ch, _pieceColors[current!.type], _pieceEmojis[current!.type], 1.0);
      }
    }
  }

  void _drawCell(Canvas canvas, int r, int c, double cw, double ch, Color color, String? emoji, double alpha) {
    if (r < 0 || r >= _rows || c < 0 || c >= _cols) return;
    final rect = Rect.fromLTWH(c * cw + 1, r * ch + 1, cw - 2, ch - 2);
    final rr = RRect.fromRectAndRadius(rect, const Radius.circular(3));

    // Fill with gradient-like effect
    canvas.drawRRect(rr, Paint()..color = color.withAlpha((200 * alpha).round()));
    canvas.drawRRect(rr, Paint()
      ..color = Colors.white.withAlpha((60 * alpha).round())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1);

    // Emoji
    if (emoji != null && ch > 14) {
      final fontSize = ch * 0.58;
      final tp = TextPainter(
        text: TextSpan(text: emoji, style: TextStyle(fontSize: fontSize)),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: cw);
      tp.paint(canvas, Offset(c * cw + (cw - tp.width) / 2, r * ch + (ch - tp.height) / 2));
    }
  }

  void _drawCellGhost(Canvas canvas, int r, int c, double cw, double ch, Color color) {
    if (r < 0 || r >= _rows || c < 0 || c >= _cols) return;
    final rect = Rect.fromLTWH(c * cw + 1, r * ch + 1, cw - 2, ch - 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      Paint()..color = color.withAlpha(45),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      Paint()..color = color.withAlpha(90)..style = PaintingStyle.stroke..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_BoardPainter old) => true;
}
