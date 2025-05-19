import 'package:flutter/material.dart';
import '../models/game_board.dart';
import '../models/block.dart';

class GameBoardWidget extends StatefulWidget {
  final GameBoard gameBoard;
  final Function(int) onScoreUpdate;
  final Function(Block) onBlockUsed;
  final double cellSize;

  const GameBoardWidget({
    Key? key,
    required this.gameBoard,
    required this.onScoreUpdate,
    required this.onBlockUsed,
    required this.cellSize,
  }) : super(key: key);

  @override
  State<GameBoardWidget> createState() => _GameBoardWidgetState();
}

class _GameBoardWidgetState extends State<GameBoardWidget> {
  Block? _hoverBlock;
  int? _hoverOriginX;
  int? _hoverOriginY;
  Set<Offset> _clearingCells = {};
  Map<String, Set<Offset>> _clearingTypes = {};
  Map<String, Set<Offset>> _pendingClearTypes = {};

  void _animateAndClear(Set<Offset> positionsToClear) {
    setState(() {
      _clearingCells = positionsToClear;
      _clearingTypes = _pendingClearTypes;
      _pendingClearTypes = {};
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        for (var pos in positionsToClear) {
          widget.gameBoard.board[pos.dy.toInt()][pos.dx.toInt()] = null;
        }
        _clearingCells.clear();
        _clearingTypes.clear();
      });
    });
  }

  Color _resolveBackgroundColor(int x, int y) {
    final blockX = x ~/ 3;
    final blockY = y ~/ 3;
    final isEven = (blockX + blockY) % 2 == 0;
    return isEven ? const Color(0xFF9C5E40) : const Color(0xFF814F38);
  }

  Color _resolveEffectColor(Offset pos) {
    if (_pendingClearTypes['squares']?.contains(pos) ?? false) {
      return Colors.orangeAccent.withOpacity(0.4);
    } else if ((_pendingClearTypes['rows']?.contains(pos) ?? false) ||
        (_pendingClearTypes['columns']?.contains(pos) ?? false)) {
      return Colors.redAccent.withOpacity(0.3);
    }

    if (_clearingTypes['squares']?.contains(pos) ?? false) {
      return Colors.orangeAccent.withOpacity(0.6);
    } else if ((_clearingTypes['rows']?.contains(pos) ?? false) ||
        (_clearingTypes['columns']?.contains(pos) ?? false)) {
      return Colors.redAccent.withOpacity(0.5);
    }

    return const Color(0xFF8C5B3F);
  }

  @override
  Widget build(BuildContext context) {
    final int size = widget.gameBoard.size;

    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: size * size,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: size,
        ),
        itemBuilder: (context, index) {
          final x = index % size;
          final y = index ~/ size;
          final Offset pos = Offset(x.toDouble(), y.toDouble());
          final cellColor = widget.gameBoard.board[y][x];

          bool isHoverPreview = false;
          if (_hoverBlock != null &&
              _hoverOriginX != null &&
              _hoverOriginY != null) {
            isHoverPreview = _hoverBlock!.shape.any((offset) {
              final dx = (_hoverOriginX! + offset.dx).round();
              final dy = (_hoverOriginY! + offset.dy).round();
              return dx == x && dy == y;
            });
          }

          final bool thickRight = (x + 1) % 3 == 0 && x != size - 1;
          final bool thickBottom = (y + 1) % 3 == 0 && y != size - 1;

          Color backgroundColor = cellColor ?? _resolveEffectColor(pos);
          if (cellColor == null && !isHoverPreview) {
            backgroundColor = _resolveBackgroundColor(x, y);
          }

          return DragTarget<Block>(
            onWillAccept: (block) {
              final minX =
                  block!.shape.map((e) => e.dx).reduce((a, b) => a < b ? a : b);
              final minY =
                  block.shape.map((e) => e.dy).reduce((a, b) => a < b ? a : b);
              final originX = x - minX.toInt();
              final originY = y - minY.toInt();

              if (widget.gameBoard.canPlaceBlock(block, originX, originY)) {
                final simulated =
                    widget.gameBoard.copyWithBlock(block, originX, originY);
                setState(() {
                  _hoverBlock = block;
                  _hoverOriginX = originX;
                  _hoverOriginY = originY;
                  _pendingClearTypes = simulated.getClearingPositionsByType();
                });
                return true;
              }

              setState(() {
                _hoverBlock = null;
                _hoverOriginX = null;
                _hoverOriginY = null;
                _pendingClearTypes.clear();
              });
              return false;
            },
            onLeave: (_) {
              setState(() {
                _hoverBlock = null;
                _hoverOriginX = null;
                _hoverOriginY = null;
                _pendingClearTypes.clear();
              });
            },
            onAccept: (block) {
              final minX =
                  block.shape.map((e) => e.dx).reduce((a, b) => a < b ? a : b);
              final minY =
                  block.shape.map((e) => e.dy).reduce((a, b) => a < b ? a : b);
              final originX = x - minX.toInt();
              final originY = y - minY.toInt();

              widget.gameBoard.placeBlock(block, originX, originY);
              final clearMap = widget.gameBoard.getClearingPositionsByType();
              final toClear = {
                ...clearMap['rows']!,
                ...clearMap['columns']!,
                ...clearMap['squares']!
              };
              final score = block.shape.length + toClear.length;

              widget.onScoreUpdate(score);
              widget.onBlockUsed(block);

              if (toClear.isNotEmpty) {
                _pendingClearTypes = clearMap;
                _animateAndClear(toClear);
              }

              setState(() {
                _hoverBlock = null;
                _hoverOriginX = null;
                _hoverOriginY = null;
              });
            },
            builder: (context, candidateData, rejectedData) {
              return Center(
                child: AnimatedScale(
                  scale: _clearingCells.contains(pos) ? 0 : 1,
                  duration: const Duration(milliseconds: 250),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    width: widget.cellSize,
                    height: widget.cellSize,
                    margin: EdgeInsets.only(
                      right: thickRight ? 2 : 0.5,
                      bottom: thickBottom ? 2 : 0.5,
                    ),
                    decoration: BoxDecoration(
                      color: isHoverPreview
                          ? (_hoverBlock?.color ?? Colors.white)
                              .withOpacity(0.4)
                          : backgroundColor,
                      border: Border.all(
                        color: const Color(0xFF9C6240),
                        width: 0.5,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
