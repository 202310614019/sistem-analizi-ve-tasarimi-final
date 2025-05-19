import 'package:flutter/material.dart';
import '../models/block.dart';
import 'block_widget.dart';

class BlockSelector extends StatelessWidget {
  final List<Block?> blocks; // Null olanlar boş yerler
  final double cellSize;

  const BlockSelector({
    Key? key,
    required this.blocks,
    required this.cellSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: cellSize * 5.5,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: blocks
            .map(
              (block) => SizedBox(
                width: cellSize * 5,
                height: cellSize * 5,
                child: block != null
                    ? BlockWidget(block: block, cellSize: cellSize, scale: 1.0)
                    : Container(), // Boş kutu
              ),
            )
            .toList(),
      ),
    );
  }
}
