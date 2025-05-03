import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CoverScreen extends StatelessWidget {
  // Font definition as a static getter for better access control
  static TextStyle get gameFont => GoogleFonts.pressStart2p(
    textStyle: const TextStyle(
      color: Colors.deepPurple,
      letterSpacing: 0,
      fontSize: 28,
    ),
  );

  // Required properties with proper initialization
  final bool hasGameStarted;
  final bool isGameOver;

  // Constructor with proper naming convention
  const CoverScreen({
    required this.hasGameStarted,
    required this.isGameOver,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // If game has started, show game title or nothing (when game over)
    if (hasGameStarted) {
      return Container(
        alignment: const Alignment(0, -0.4),
        child: isGameOver
            ? const SizedBox.shrink()
            : Text(
          "Brick Breaker",
          style: gameFont.copyWith(color: Colors.grey),
        ),
      );
    }

    // Otherwise show the start screen with title and instructions
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 10), // Spacing for better positioning
          Text(
            "Brick Breaker",
            style: gameFont,
          ),
          const SizedBox(height: 40), // Spacing between texts
          Text(
            "Tap to play",
            style: gameFont.copyWith(fontSize: 20),
          ),
        ],
      ),
    );
  }
}