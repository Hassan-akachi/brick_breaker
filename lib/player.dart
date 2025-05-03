import 'package:flutter/material.dart';
class Player extends StatelessWidget {
  final playerX;
  final double playerWidth;
  const Player({super.key, this.playerX, required this.playerWidth});

  @override
  Widget build(BuildContext context) {
    return  Align(
        alignment: Alignment((2*playerX+playerWidth)/(2-playerWidth), 0.9),
        child: ClipRect(
          child: Container(
          height: 10,
          width: MediaQuery.of(context).size.width * playerWidth /2, //because the screen width aligment -1,0,1
          decoration:BoxDecoration(
            color: Colors.deepPurple,
              borderRadius: BorderRadius.circular(20)
          ),
          ) ,
        ),
      );
  }
}
