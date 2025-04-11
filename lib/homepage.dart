import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:trackpro/dashboard.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF001F3F), // Dark Blue
              Colors.black,      // Black Gradient
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.1,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) {
                    return const LinearGradient(
                      colors: [Colors.cyanAccent, Colors.blueAccent],
                    ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
                  },
                  child: Text(
                    'Welcome to TrackPro',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth * 0.091,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: const [
                        Shadow(
                          blurRadius: 60,
                          color: Colors.greenAccent,
                          offset: Offset(0, 0),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'Build your Career',
                      textStyle: TextStyle(
                        fontSize: screenWidth * 0.08,
                        color: Colors.white70,
                      ),
                      speed: const Duration(milliseconds: 120),
                    ),
                    TypewriterAnimatedText(
                      'Show your Talent',
                      textStyle: TextStyle(
                        fontSize: screenWidth * 0.08,
                        color: Colors.white70,
                      ),
                      speed: const Duration(milliseconds: 120),
                    ),
                    TypewriterAnimatedText(
                      'Track your Skill',
                      textStyle: TextStyle(
                        fontSize: screenWidth * 0.08,
                        color: Colors.white70,
                      ),
                      speed: const Duration(milliseconds: 120),
                    ),
                  ],
                  repeatForever: true,
                  pause: const Duration(milliseconds: 800),
                  displayFullTextOnTap: true,
                  stopPauseOnTap: true,
                ),
                SizedBox(height: screenHeight * 0.09),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.08,
                            vertical: screenHeight * 0.03),
                        backgroundColor: const Color.fromARGB(255, 10, 96, 243),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                     onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const DashboardPage()));
                  },
                      child: const Text('Get Started'),
                    ),
                    SizedBox(width: screenWidth * 0.04),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.08,
                            vertical: screenHeight * 0.03),
                        backgroundColor: const Color.fromARGB(255, 37, 37, 37),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {},
                      child: const Text('View Demo'),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.03),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.supervised_user_circle, color: Colors.white70),
                    const SizedBox(width: 5),
                    const Text("10k+ Users", style: TextStyle(color: Colors.white70)),
                    const SizedBox(width: 20),
                    const Icon(Icons.people_alt, color: Colors.white70),
                    const SizedBox(width: 5),
                    const Text("5k+ Connections", style: TextStyle(color: Colors.white70)),
                  ],
                ),
                SizedBox(height:9),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                   const Icon(Icons.document_scanner, color: Colors.white70),
                    const SizedBox(width: 5),
                    const Text("5000+ Projects", style: TextStyle(color: Colors.white70)),
                    const SizedBox(width: 20),
                     const Icon(Icons.star_border_sharp, color: Colors.white70),
                    const SizedBox(width: 5),
                    const Text("Ai Feature", style: TextStyle(color: Colors.white70)),
                ],)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
