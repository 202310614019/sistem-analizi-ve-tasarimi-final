// widgets/score_board.dart
import 'package:flutter/material.dart';

class ScoreBoard extends StatelessWidget {
  final int score;

  ScoreBoard({required this.score});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Text(
        'Skor: $score',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
