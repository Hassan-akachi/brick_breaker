import 'package:flutter/material.dart';

class Ball extends StatelessWidget {
  final double ballX;
  final double ballY;
  const Ball({super.key, required this.ballX, required this.ballY});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(ballX, ballY),
      child: Container(
        height: 15,
        width: 15,
        decoration: BoxDecoration(shape: BoxShape.circle,
          color: Colors.deepPurple,),

      ),
    );
  }
}
