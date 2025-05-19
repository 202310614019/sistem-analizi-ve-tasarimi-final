import 'package:flutter/material.dart';
import 'widgets/game_screen.dart';

void main() {
  runApp(const BlockPlacementGame());
}

class BlockPlacementGame extends StatelessWidget {
  const BlockPlacementGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Block Placement Game',
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFDAB2DD),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: GameScreen(),
      ),
    );
  }
}
