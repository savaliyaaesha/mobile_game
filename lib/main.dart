import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyGame());

class MyGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bucket Catch Game',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: HomeScreen(),
    );
  }
}

// ------------------ 🏠 HOME SCREEN ------------------
class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  int highScore = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: Duration(seconds: 2), vsync: this);
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      highScore = prefs.getInt('highScore') ?? 0;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/background.jpg', fit: BoxFit.cover),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          FadeTransition(
            opacity: _fadeIn,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '🌴 Bucket Catch Game',
                    style: GoogleFonts.orbitron(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '🏆 High Score: $highScore',
                    style: TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => LevelScreen()),
                      );
                    },
                    child: Text("Play Now"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen()));
                    },
                    child: Text("⚙️ Settings", style: TextStyle(color: Colors.white)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => InstructionsScreen()));
                    },
                    child: Text("📘 How to Play", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------ 📘 INSTRUCTIONS SCREEN ------------------
class InstructionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('How to Play')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text("Objective:", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text("\nCatch falling balls with the bucket to earn points. The game gets harder as your score increases!\n"),
            Text("Controls:", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text("\nSlide your finger left/right to move the bucket and catch the balls.\n"),
            Text("Scoring:", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text("\nEach ball caught increases your score. Every 10 points increases the difficulty level.\n"),
            Text("Game Over:", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text("\nIf a ball hits the ground without being caught, the game ends.\n"),
          ],
        ),
      ),
    );
  }
}

// ------------------ ⚙️ SETTINGS SCREEN ------------------
class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isSoundOn = true;
  String selectedTheme = 'System';

  Future<void> _resetHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('highScore', 0);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("High score reset!")),
    );
  }

  void _changeTheme(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', value);
    setState(() => selectedTheme = value);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Theme changed to $value")));
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedTheme = prefs.getString('theme') ?? 'System';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        backgroundColor: Colors.deepOrange,
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.orange.shade50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: Text("Sound", style: TextStyle(fontSize: 18)),
              value: isSoundOn,
              onChanged: (value) {
                setState(() {
                  isSoundOn = value;
                });
              },
              secondary: Icon(Icons.volume_up),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.palette),
              title: Text("Theme", style: TextStyle(fontSize: 18)),
              trailing: DropdownButton<String>(
                value: selectedTheme,
                items: ['Light', 'Dark', 'System'].map((theme) {
                  return DropdownMenuItem<String>(
                    value: theme,
                    child: Text(theme),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    _changeTheme(value);
                  }
                },
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.refresh),
              title: Text("Reset High Score", style: TextStyle(fontSize: 18)),
              onTap: _resetHighScore,
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text("Exit Game", style: TextStyle(fontSize: 18)),
              onTap: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
    );
  }
}


class LevelScreen extends StatefulWidget {
  @override
  _LevelScreenState createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> with SingleTickerProviderStateMixin {
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(vsync: this, duration: Duration(seconds: 3));
    _progressController.forward();
    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => BucketGameScreen()));
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/background.jpg', fit: BoxFit.cover),
          ),
          Center(
            child: Container(
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.85), borderRadius: BorderRadius.circular(16)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🎯 Level 1', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text('Catch the balls to earn points.', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 20),
                  AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      return LinearProgressIndicator(
                        value: _progressController.value,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
                        backgroundColor: Colors.orange.shade100,
                        minHeight: 8,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BucketGameScreen extends StatefulWidget {
  @override
  State<BucketGameScreen> createState() => _BucketGameScreenState();
}

class _BucketGameScreenState extends State<BucketGameScreen> {
  double bucketX = 0.0;
  double screenWidth = 0;
  double screenHeight = 0;
  int score = 0;
  int level = 1;
  bool gameOver = false;
  bool isPaused = false;
  int highScore = 0;
  List<Ball> balls = [];
  Timer? gameLoop;

  final List<String> ballImages = [
    'assets/images/ball1.png',
    'assets/images/ball2.webp',
  ];

  @override
  void initState() {
    super.initState();
    _loadHighScore();
    startGame();
  }

  Future<void> _loadHighScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() => highScore = prefs.getInt('highScore') ?? 0);
  }

  Future<void> _saveHighScore() async {
    if (score > highScore) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('highScore', score);
    }
  }

  void startGame() {
    score = 0;
    level = 1;
    gameOver = false;
    isPaused = false;
    balls.clear();

    gameLoop?.cancel();
    gameLoop = Timer.periodic(Duration(milliseconds: 30), (_) {
      if (isPaused) return;
      setState(() {
        for (var ball in balls) {
          ball.y += ball.speed;
        }
        balls.removeWhere((ball) {
          if (ball.y >= screenHeight - 80) {
            if ((ball.x - bucketX).abs() < 50) {
              score += level;
              if (score ~/ 10 + 1 > level) level++;
              return true;
            } else {
              gameOver = true;
              gameLoop?.cancel();
              _saveHighScore();
              return true;
            }
          }
          return false;
        });
        if (Random().nextDouble() < 0.02) {
          String randomImage = ballImages[Random().nextInt(ballImages.length)];
          double speed = 5.0 + level.toDouble();
          balls.add(Ball(x: Random().nextDouble() * screenWidth, y: 0, speed: speed, image: randomImage));
        }
      });
    });
  }

  void togglePause() => setState(() => isPaused = !isPaused);

  void resetGame() {
    gameLoop?.cancel();
    setState(() {
      score = 0;
      level = 1;
      gameOver = false;
      isPaused = false;
      balls.clear();
      startGame();
    });
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Exit Game?"),
        content: Text("Are you sure you want to leave the game?"),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text("Cancel")),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text("Exit")),
        ],
      ),
    ) ?? false;
  }

  @override
  void dispose() {
    gameLoop?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset('assets/images/background.jpg', fit: BoxFit.cover),
            ),
            GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  bucketX += details.delta.dx;
                  if (bucketX < 0) bucketX = 0;
                  if (bucketX > screenWidth - 100) bucketX = screenWidth - 100;
                });
              },
              child: Stack(
                children: [
                  for (var ball in balls)
                    Positioned(
                      top: ball.y,
                      left: ball.x,
                      child: Image.asset(ball.image, width: 30, height: 30),
                    ),
                  Positioned(
                    bottom: 20,
                    left: bucketX,
                    child: Image.asset('assets/images/bucket1.png', width: 100, height: 60),
                  ),
                  Positioned(
                    top: 40,
                    left: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Score: $score', style: TextStyle(fontSize: 22, color: Colors.white)),
                        Text('Level: $level', style: TextStyle(fontSize: 18, color: Colors.white)),
                      ],
                    ),
                  ),
                  if (gameOver)
                    Center(
                      child: Container(
                        color: Colors.black54,
                        padding: EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Game Over', style: TextStyle(color: Colors.white, fontSize: 30)),
                            SizedBox(height: 10),
                            Text('Final Score: $score', style: TextStyle(color: Colors.white, fontSize: 20)),
                            ElevatedButton(onPressed: resetGame, child: Text('Restart')),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Back to Home'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (!gameOver)
                    Positioned(
                      top: 40,
                      right: 20,
                      child: ElevatedButton(
                        onPressed: togglePause,
                        child: Text(isPaused ? 'Resume' : 'Pause'),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Ball {
  double x;
  double y;
  double speed;
  String image;

  Ball({required this.x, required this.y, required this.speed, required this.image});
}
