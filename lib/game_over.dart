// game_over.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GameOver extends StatelessWidget {

  static var gameFont =GoogleFonts.pressStart2p(
      textStyle: TextStyle(
          color: Colors.deepPurple,letterSpacing: 0,fontSize: 28
      )
  );


  // Add isWin parameter to determine which message to show
  final bool isGameOver;
  final bool isWin;
  final Function reset;

  // Update constructor to include isWin parameter with default value of false
  const GameOver({
    Key? key,
    required this.isGameOver,
    required this.reset,
    this.isWin = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isGameOver
        ? Stack(
      children: [
        Container(
          alignment: const Alignment(0, -0.3),
          child: Text(
            isWin ? 'YOU WIN!' : 'GAME OVER',
            style: gameFont,
          ),
        ),
        Container(
          alignment: const Alignment(0, 0),
          child: GestureDetector(
            onTap: () {
              reset();
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(10),
                color: isWin ? Colors.green : Colors.deepPurple[300],
                child:  Text(
                  'PLAY AGAIN',
                  style: gameFont,
                ),
              ),
            ),
          ),
        ),
      ],
    )
        : Container();
  }
}
