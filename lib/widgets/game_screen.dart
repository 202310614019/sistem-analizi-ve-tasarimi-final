import 'package:flutter/material.dart';
import '../models/block.dart';
import '../models/game_board.dart';
import '../utils/block_factory.dart';
import 'game_board_widget.dart';
import 'block_widget.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameBoard _gameBoard = GameBoard();
  List<Block?> _blocks = [];
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _generateNewBlocks();
  }

  void _generateNewBlocks() {
    setState(() {
      _blocks = List.generate(3, (_) => BlockFactory.generateRandomBlock());
    });
  }

  void _handleBlockUsed(Block usedBlock) {
    setState(() {
      int index = _blocks.indexOf(usedBlock);
      if (index != -1) {
        _blocks[index] =
            BlockFactory.generateRandomBlock(); // 🔁 Yenisiyle değiştir
      }
    });

    if (!_gameBoard.hasAvailableMoves(_blocks.whereType<Block>().toList())) {
      _showGameOverDialog();
    }
  }

  void _updateScore(int value) {
    setState(() {
      _score += value;
    });
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Oyun Bitti"),
        content: Text("Skorun: $_score"),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _score = 0;
                _gameBoard.resetBoard();
                _generateNewBlocks();
              });
              Navigator.of(context).pop();
            },
            child: const Text("Tekrar Oyna"),
          ),
        ],
      ),
    );
  }

  Widget _buildScore(int score) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.deepOrangeAccent.shade100,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Text(
        'Skor: $score',
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [
            Shadow(
              offset: Offset(2, 2),
              blurRadius: 4,
              color: Colors.black38,
            ),
          ],
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double cellSize = MediaQuery.of(context).size.width / 12;

    return Scaffold(
      backgroundColor: const Color(0xFF7D506B),
      body: SafeArea(
        child: Column(
          children: [
            _buildScore(_score),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: GameBoardWidget(
                gameBoard: _gameBoard,
                onScoreUpdate: _updateScore,
                onBlockUsed: _handleBlockUsed,
                cellSize: cellSize,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: cellSize * 5.5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _blocks.map((block) {
                    return SizedBox(
                      width: cellSize * 3,
                      height: cellSize * 5,
                      child: Center(
                        child: block != null
                            ? BlockWidget(
                                key: ValueKey(block),
                                block: block,
                                cellSize: cellSize,
                                scale: 0.6,
                              )
                            : const SizedBox.shrink(),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
