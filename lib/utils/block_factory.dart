import 'dart:math';
import 'package:flutter/material.dart';
import '../models/block.dart';

class BlockFactory {
  static final List<List<Offset>> baseShapes = [
    [Offset(0, 0)], // Tek kare
    [Offset(0, 0), Offset(0, 1)], // 2'li dikey
    [Offset(0, 0), Offset(0, 1), Offset(0, 2)], // 3'lü dikey
    [Offset(0, 0), Offset(1, 0)], // 2'li yatay
    [Offset(0, 0), Offset(1, 0), Offset(2, 0)], // 3'lü yatay
    [Offset(0, 0), Offset(1, 0), Offset(0, 1)], // L
    [Offset(0, 0), Offset(1, 0), Offset(2, 0), Offset(2, 1)], // ters L
    [Offset(0, 0), Offset(1, 0), Offset(1, 1), Offset(2, 1)], // Z
    [Offset(1, 0), Offset(2, 0), Offset(0, 1), Offset(1, 1)], // S
    [Offset(0, 0), Offset(1, 0), Offset(2, 0), Offset(1, 1)], // T
    [
      Offset(1, 0),
      Offset(0, 1),
      Offset(1, 1),
      Offset(2, 1),
      Offset(1, 2)
    ], // Artı
    [
      Offset(0, 0),
      Offset(0, 1),
      Offset(0, 2),
      Offset(0, 3),
      Offset(0, 4)
    ], // Dikey 5'li
    [
      Offset(0, 0),
      Offset(1, 0),
      Offset(2, 0),
      Offset(3, 0),
      Offset(4, 0)
    ], // Yatay 5'li
    [Offset(0, 0), Offset(1, 0), Offset(0, 1), Offset(1, 1)], // 2x2 kare
    [Offset(0, 0), Offset(1, 0), Offset(2, 0), Offset(0, 1)], // L4
  ];

  static final _random = Random();

  static Block generateRandomBlock() {
    final original = baseShapes[_random.nextInt(baseShapes.length)];

    int rotation = _random.nextInt(4); // 0, 90, 180, 270
    bool mirror = _random.nextBool();

    List<Offset> transformed = original;
    if (mirror) {
      transformed = _mirror(transformed);
    }
    transformed = _rotate(transformed, rotation);
    transformed = _normalize(transformed);

    return Block(
      shape: transformed,
      color: const Color(0xFFFFE0B2),
    );
  }

  static List<Offset> _mirror(List<Offset> shape) {
    return shape.map((e) => Offset(-e.dx, e.dy)).toList();
  }

  static List<Offset> _rotate(List<Offset> shape, int quarterTurns) {
    var result = shape;
    for (int i = 0; i < quarterTurns; i++) {
      result = result.map((e) => Offset(-e.dy, e.dx)).toList();
    }
    return result;
  }

  static List<Offset> _normalize(List<Offset> shape) {
    final minX = shape.map((e) => e.dx).reduce(min);
    final minY = shape.map((e) => e.dy).reduce(min);
    return shape.map((e) => Offset(e.dx - minX, e.dy - minY)).toList();
  }
}
