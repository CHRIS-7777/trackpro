import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:slide_to_act/slide_to_act.dart';
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
              Colors.black,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.08,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) {
                    return const LinearGradient(
                      colors: [Colors.cyanAccent, Colors.greenAccent],
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
                SizedBox(height: screenHeight * 0.02),
                AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'Build your Career',
                      textStyle: TextStyle(
                        fontSize: screenWidth * 0.06 ,
                        color: Colors.white,
                      ),
                      speed: const Duration(milliseconds: 120),
                    ),
                    TypewriterAnimatedText(
                      'Show your Talent',
                      textStyle: TextStyle(
                        fontSize: screenWidth * 0.06,
                        color: Colors.white,
                      ),
                      speed: const Duration(milliseconds: 120),
                    ),
                    TypewriterAnimatedText(
                      'Track your Skill',
                      textStyle: TextStyle(
                        fontSize: screenWidth * 0.06,
                        color: Colors.white,
                      ),
                      speed: const Duration(milliseconds: 120),
                    ),
                  ],
                  repeatForever: true,
                  pause: const Duration(milliseconds: 800),
                  displayFullTextOnTap: true,
                  stopPauseOnTap: true,
                ),
                SizedBox(height: screenHeight * 0.06),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: const [
                //     Icon(Icons.supervised_user_circle, color: Colors.white70),
                //     SizedBox(width: 5),
                //     Text("10k+ Users", style: TextStyle(color: Colors.white70)),
                //     SizedBox(width: 20),
                //     Icon(Icons.people_alt, color: Colors.white70),
                //     SizedBox(width: 5),
                //     Text("5k+ Connections", style: TextStyle(color: Colors.white70)),
                //   ],
                // ),
                SizedBox(height: screenHeight * 0.05),
                Text(
                  'Your Professional Journey',
                  style: TextStyle(
                    fontSize: screenWidth * 0.059,
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent,
                    shadows: const [
                      Shadow(
                        blurRadius: 10,
                        color: Colors.blueAccent,
                        offset: Offset(0, 0),
                      )
                    ],
                  ),
                ),
 
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.lightbulb_outline, size: 48, color: Colors.cyanAccent),
                        SizedBox(height: 16),
                        Text(
                          "Ready to explore more?",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Dive into your dashboard to track skills, explore projects, and grow your career journey.",
                          style: TextStyle(fontSize: 15, color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height:20),
                        Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.supervised_user_circle, color: Colors.white70),
                    
                    Text("10k+ Users", style: TextStyle(color: Colors.white70)),
                    SizedBox(width: 20),
                    Icon(Icons.people_alt, color: Colors.white70),
                  SizedBox(width:3),
                    Text("5k+ Connections", style: TextStyle(color: Colors.white70)),
                  ],
                ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.06),
                // ✅ SLIDE TO START BUTTON
                Builder(
                  builder: (context) {
                    return SlideAction(
                      borderRadius: 28,
                      elevation: 0,
                      outerColor: const Color.fromARGB(255, 51, 51, 51),
                      innerColor: Colors.greenAccent,
                      sliderButtonIcon: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.black87,
                      ),
                      text: "        ✨Start Your Journey✨",
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      onSubmit: () {
                        Future.delayed(const Duration(milliseconds: 300), () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const DashboardPage()),
                          );
                        });
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
