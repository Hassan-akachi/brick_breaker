import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:brick_breaker/ball.dart';
import 'package:brick_breaker/brick.dart';
import 'package:brick_breaker/cover_screen.dart';
import 'package:brick_breaker/game_over.dart';
import 'package:brick_breaker/player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Main entry point of the Flutter application
void main() {
  runApp(const MyApp());
}

// Root widget that sets up the MaterialApp with theme
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(), // Main game screen
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// Enum to track direction of ball movement
enum direction { UP, DOWN, RIGHT, LEFT }

class _MyHomePageState extends State<MyHomePage> {
  // Ball variables
  double ballX = 0;               // Ball's X position (0 is center of screen)
  double ballY = 0;               // Ball's Y position (0 is center of screen)
  double ballXIncrement = 0.01;   // How much the ball moves in X direction each frame
  double ballYIncrement = 0.01;   // How much the ball moves in Y direction each frame
  var ballYDirection = direction.DOWN;  // Ball's vertical direction
  var ballXDirection = direction.LEFT;  // Ball's horizontal direction

  // Player paddle variables
  double playerX = -0.2;          // Player's X position (starts slightly left of center)
  double playerWidth = 0.4;       // Width of player paddle (out of 2, since screen is -1 to 1)

  // Brick layout variables
  static double brickHeight = 0.05;             // Height of each brick
  static double brickWidth = 0.4;               // Width of each brick
  static double firstBrickX = -1 + wallGap;     // X position of first brick
  static double firstBrickY = -0.9;             // Y position of first brick (near top)
  static double brickGap = 0.01;                // Gap between bricks
  static double NoOfBrickInRow = 4;             // Number of bricks per row
  static double wallGap = 0.5 * (2 - (NoOfBrickInRow * brickWidth) + ((NoOfBrickInRow - 1) * brickGap)); // Gap from wall to first brick

  // List of bricks [x position, y position, is brick broken]
  List myBricks = [
    [firstBrickX + 0 * (brickWidth + brickGap), firstBrickY, false],
    [firstBrickX + 1 * (brickWidth + brickGap), firstBrickY, false],
    [firstBrickX + 2 * (brickWidth + brickGap), firstBrickY, false],
    [firstBrickX + 3 * (brickWidth + brickGap), firstBrickY, false],
  ];

  bool isGameOver = false;    // Tracks if game is over
  bool hasGamStart = false;   // Tracks if game has started
  bool isWin = false;        // Tracks if player won the game

  // Starts the game loop with a Timer
  void startGame() {
    hasGamStart = true;
    // Create game loop that updates every 10 milliseconds
    Timer.periodic(Duration(milliseconds: 10), (timer) {
      updateBallDirection();  // Check and update ball direction
      moveBall();             // Move the ball
      checkBrickBroken();     // Check if ball hit any bricks

      // Check if player lost
      if (isPlayerDead()) {
        timer.cancel();       // Stop the game loop
        isGameOver = true;
      }

      // Check if player won
      if (checkAllBricksBroken()) {
        timer.cancel();       // Stop the game loop
        isWin = true;
        isGameOver = true;   // Also set game over to true to stop inputs
      }
    });
  }

  // Move paddle left when left arrow key is pressed
  void moveLeft() {
    setState(() {
      // Check boundary to prevent paddle from moving off screen
      if (!(playerX - 0.2 < -1)) {
        playerX -= 0.2;
      }
    });
  }

  // Move paddle right when right arrow key is pressed
  void moveRight() {
    // Check boundary to prevent paddle from moving off screen
    if (!(playerX + playerWidth >= 1)) {
      setState(() {
        playerX += 0.2;
      });
    }
  }

  // Update ball position based on current direction
  void moveBall() {
    setState(() {
      // Update Y position
      if (ballYDirection == direction.UP) {
        ballY -= ballYIncrement;
      } else if (ballYDirection == direction.DOWN) {
        ballY += ballYIncrement;
      }

      // Update X position
      if (ballXDirection == direction.RIGHT) {
        ballX -= ballXIncrement;
      } else if (ballXDirection == direction.LEFT) {
        ballX += ballXIncrement;
      }
    });
  }

  // Handle ball bouncing off walls and paddle
  void updateBallDirection() {
    setState(() {
      // Bounce off top wall
      if (ballY <= -1) {
        ballYDirection = direction.DOWN;
      }
      // Bounce off paddle
      else if (ballY >= 0.88 && ballX >= playerX && ballX <= (playerX + playerWidth)) {
        ballYDirection = direction.UP;
      }

      // Bounce off left wall
      if (ballX <= -1) {
        ballXDirection = direction.LEFT;
      }
      // Bounce off right wall
      else if (ballX >= 1) {
        ballXDirection = direction.RIGHT;
      }
    });
  }

  // Check if ball collides with any bricks
  void checkBrickBroken() {
    for (int i = 0; i < myBricks.length; i++) {
      // Check if ball hits a brick that's not already broken
      if (ballY <= (myBricks[i][1] + brickHeight) &&
          ballX >= myBricks[i][0] &&
          ballX <= (myBricks[i][0] + brickWidth) &&
          myBricks[i][2] == false) {
        setState(() {
          myBricks[i][2] = true;  // Mark brick as broken

          // Calculate closest side of brick to determine bounce direction
          double leftSideDistance = (myBricks[i][0] - ballX).abs();
          double rightSideDistance = (myBricks[i][0] + brickWidth - ballX).abs();
          double upSideDistance = (myBricks[i][1] - ballY).abs();
          double bottomSideDistance = (myBricks[i][1] + brickHeight - ballY).abs();

          // Find which side of the brick was hit
          String min = findMin(leftSideDistance, rightSideDistance, upSideDistance, bottomSideDistance);

          // Change ball direction based on which side was hit
          switch (min) {
            case "left":
              ballXDirection = direction.LEFT;
              break;
            case "right":
              ballXDirection = direction.RIGHT;
              break;
            case "up":
              ballYDirection = direction.UP;
              break;
            case "down":
              ballYDirection = direction.DOWN;
              break;
          }

          // NOTE: There appears to be redundant code below that always sets
          // the ball direction in all four directions, which likely causes issues
          // This might be a bug in the original code
          ballXDirection = direction.LEFT;
          ballXDirection = direction.RIGHT;
          ballYDirection = direction.UP;
          ballYDirection = direction.DOWN;
        });
      }
    }
  }

  // Helper function to find minimum distance to determine which side of brick was hit
  String findMin(double leftSideDistance, double rightSideDistance, double upSideDistance, double bottomSideDistance) {
    List myList = [leftSideDistance, rightSideDistance, upSideDistance, bottomSideDistance];
    double currentMin = leftSideDistance;

    // Find minimum distance
    for (int i = 0; i < myList.length; i++) {
      if (currentMin > myList[i]) {
        currentMin = myList[i];
      }
    }

    // Return which side corresponds to minimum distance
    if ((currentMin - leftSideDistance).abs() < 0.01) {
      return 'left';
    } else if ((currentMin - rightSideDistance).abs() < 0.01) {
      return 'right';
    } else if ((currentMin - upSideDistance).abs() < 0.01) {
      return 'up';
    } else if ((currentMin - bottomSideDistance).abs() < 0.01) {
      return 'down';
    }
    return "";
  }

  // Check if ball has fallen below the screen
  bool isPlayerDead() {
    if (ballY >= 1) {
      isGameOver = true;
      return true;
    }
    return false;
  }

  // Check if all bricks are broken
  bool checkAllBricksBroken() {
    // Assume all bricks are broken until we find one that isn't
    bool allBroken = true;

    // Check each brick in the list
    for (int i = 0; i < myBricks.length; i++) {
      // If any brick is not broken, set allBroken to false
      if (myBricks[i][2] == false) {
        allBroken = false;
        break;
      }
    }

    return allBroken;
  }

  // Reset game to initial state
  void reset() {
    setState(() {
      playerX = -0.2;
      ballX = 0;
      ballY = 0;
      hasGamStart = false;
      isGameOver = false;
      isWin = false;          // Reset win state
      // Reset all bricks to unbroken state
      myBricks = [
        [firstBrickX + 0 * (brickWidth + brickGap), firstBrickY, false],
        [firstBrickX + 1 * (brickWidth + brickGap), firstBrickY, false],
        [firstBrickX + 2 * (brickWidth + brickGap), firstBrickY, false],
        [firstBrickX + 3 * (brickWidth + brickGap), firstBrickY, false],
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine if we're running on web or mobile
    bool isOnWeb = kIsWeb;
    bool isOnMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

    // Different control methods based on platform
    if (isOnWeb) {
      // Use keyboard controls for web
      return _buildKeyboardControls();
    } else {
      // Use touch controls for mobile
      return _buildTouchControls(context);
    }
  }

  // Build method for keyboard controls (web)
  Widget _buildKeyboardControls() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      // Handle keyboard arrow keys
      onKey: (event) {
        if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
          moveLeft();
        } else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
          moveRight();
        }
      },
      child: GestureDetector(
        // Tap anywhere to start game
        onTap: () {
          startGame();
        },
        child: _buildGameScreen(),
      ),
    );
  }

  // Build method for touch controls (mobile)
  Widget _buildTouchControls(BuildContext context) {
    return GestureDetector(
      // Tap to start the game
      onTap: () {
        if (!hasGamStart) {
          startGame();
        }
      },
      // Handle horizontal drag for paddle movement
      onHorizontalDragUpdate: (details) {
        if (hasGamStart && !isGameOver) {
          // Convert screen position to game coordinates (-1 to 1)
          final screenWidth = MediaQuery.of(context).size.width;
          final dragDelta = 2 * details.delta.dx / screenWidth;

          setState(() {
            // Calculate new position and respect boundaries
            double newPosition = playerX + dragDelta;

            // Ensure paddle stays within screen bounds
            if (newPosition < -1) {
              playerX = -1;
            } else if (newPosition + playerWidth > 1) {
              playerX = 1 - playerWidth;
            } else {
              playerX = newPosition;
            }
          });
        }
      },
      child: _buildGameScreen(),
    );
  }

  // Common game screen layout used by both control methods
  Widget _buildGameScreen() {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.purpleAccent,
        body: Stack(  // Stack allows widgets to be positioned using Alignment
          children: [
            // Ball widget
            Ball(ballX: ballX, ballY: ballY),
      
            // Game over or win overlay
            GameOver(isGameOver: isGameOver, reset: reset, isWin: isWin),
      
            // Cover screen (start/game over screens)
            CoverScreen(hasGameStarted: hasGamStart, isGameOver: isGameOver),
      
            // Player paddle
            Player(playerX: playerX, playerWidth: playerWidth),
      
            // Debug marker for left edge of paddle
            Container(
              alignment: Alignment(playerX, 0.9),
              child: Container(
                color: Colors.red,
                width: 4,
                height: 15,
              ),
            ),
      
            // Debug marker for right edge of paddle
            Container(
              alignment: Alignment(playerX + playerWidth, 0.9),
              child: Container(
                color: Colors.green,
                width: 4,
                height: 15,
              ),
            ),
      
            // Brick widgets - one for each brick in the row
            Brick(brickHeight: brickHeight, brickWidth: brickWidth, brickX: myBricks[0][0], brickY: myBricks[0][1], isBrickBroken: myBricks[0][2]),
            Brick(brickHeight: brickHeight, brickWidth: brickWidth, brickX: myBricks[1][0], brickY: myBricks[1][1], isBrickBroken: myBricks[1][2]),
            Brick(brickHeight: brickHeight, brickWidth: brickWidth, brickX: myBricks[2][0], brickY: myBricks[2][1], isBrickBroken: myBricks[2][2]),
            Brick(brickHeight: brickHeight, brickWidth: brickWidth, brickX: myBricks[3][0], brickY: myBricks[3][1], isBrickBroken: myBricks[3][2])
          ],
        ),
      ),
    );
  }
}