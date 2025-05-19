import 'package:flutter/material.dart';
import 'block.dart';

class GameBoard {
  final int size = 9;
  late List<List<Color?>> board;

  GameBoard() {
    board = List.generate(size, (_) => List.filled(size, null));
  }

  bool canPlaceBlock(Block block, int x, int y) {
    for (var offset in block.shape) {
      final dx = (x + offset.dx).round();
      final dy = (y + offset.dy).round();

      if (dx < 0 || dx >= size || dy < 0 || dy >= size) {
        return false;
      }

      if (board[dy][dx] != null) {
        return false;
      }
    }
    return true;
  }

  void placeBlock(Block block, int x, int y) {
    for (var offset in block.shape) {
      final dx = (x + offset.dx).round();
      final dy = (y + offset.dy).round();

      if (dx >= 0 && dx < size && dy >= 0 && dy < size) {
        board[dy][dx] = block.color;
      }
    }
  }

  int clearFullLinesAndSquares() {
    final cleared = getClearingPositions();
    for (var pos in cleared) {
      board[pos.dy.toInt()][pos.dx.toInt()] = null;
    }
    return cleared.length;
  }

  Set<Offset> getClearingPositions() {
    final map = getClearingPositionsByType();
    return {...map['rows']!, ...map['columns']!, ...map['squares']!};
  }

  Map<String, Set<Offset>> getClearingPositionsByType() {
    Set<Offset> rows = {};
    Set<Offset> columns = {};
    Set<Offset> squares = {};

    for (int y = 0; y < size; y++) {
      if (board[y].every((cell) => cell != null)) {
        for (int x = 0; x < size; x++) {
          rows.add(Offset(x.toDouble(), y.toDouble()));
        }
      }
    }

    for (int x = 0; x < size; x++) {
      bool full = true;
      for (int y = 0; y < size; y++) {
        if (board[y][x] == null) {
          full = false;
          break;
        }
      }
      if (full) {
        for (int y = 0; y < size; y++) {
          columns.add(Offset(x.toDouble(), y.toDouble()));
        }
      }
    }

    for (int blockY = 0; blockY < 3; blockY++) {
      for (int blockX = 0; blockX < 3; blockX++) {
        bool full = true;
        for (int y = 0; y < 3; y++) {
          for (int x = 0; x < 3; x++) {
            if (board[blockY * 3 + y][blockX * 3 + x] == null) {
              full = false;
            }
          }
        }
        if (full) {
          for (int y = 0; y < 3; y++) {
            for (int x = 0; x < 3; x++) {
              squares.add(Offset(
                  (blockX * 3 + x).toDouble(), (blockY * 3 + y).toDouble()));
            }
          }
        }
      }
    }

    return {
      'rows': rows,
      'columns': columns,
      'squares': squares,
    };
  }

  bool hasAvailableMoves(List<Block> blocks) {
    for (var block in blocks) {
      for (int y = 0; y < size; y++) {
        for (int x = 0; x < size; x++) {
          if (canPlaceBlock(block, x, y)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  void resetBoard() {
    for (int y = 0; y < size; y++) {
      for (int x = 0; x < size; x++) {
        board[y][x] = null;
      }
    }
  }

  GameBoard copyWithBlock(Block block, int x, int y) {
    GameBoard copy = GameBoard();
    for (int row = 0; row < size; row++) {
      for (int col = 0; col < size; col++) {
        copy.board[row][col] = board[row][col];
      }
    }

    for (var offset in block.shape) {
      final dx = (x + offset.dx).round();
      final dy = (y + offset.dy).round();
      if (dx >= 0 && dx < size && dy >= 0 && dy < size) {
        copy.board[dy][dx] = block.color;
      }
    }

    return copy;
  }
}
