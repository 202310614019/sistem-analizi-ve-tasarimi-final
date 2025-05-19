import 'package:flutter/material.dart';
import '../models/block.dart';

class BlockWidget extends StatelessWidget {
  final Block block;
  final double cellSize;
  final double scale; // Alt blok için küçük gösterim

  const BlockWidget({
    Key? key,
    required this.block,
    required this.cellSize,
    this.scale = 0.6,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Draggable<Block>(
      data: block,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: _buildBlock(scale: 1.0), // Tam kare boyutunda
      childWhenDragging: _buildBlock(scale: scale, opacity: 0.3),
      child: _buildBlock(scale: scale),
    );
  }

  Widget _buildBlock({double opacity = 1.0, required double scale}) {
    final scaledCell = cellSize * scale;
    const borderColor = Color(0xFF9C6240);

    return SizedBox(
      width: scaledCell * 5,
      height: scaledCell * 5,
      child: Center(
        child: Opacity(
          opacity: opacity,
          child: Stack(
            children: block.shape.map((offset) {
              return Positioned(
                left: offset.dx * scaledCell,
                top: offset.dy * scaledCell,
                child: Container(
                  width: scaledCell,
                  height: scaledCell,
                  decoration: BoxDecoration(
                    color: block.color,
                    border: Border.all(color: borderColor, width: 0.5),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
