import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:trackpro/CreateResume.dart';
import 'package:trackpro/RoadmapTrackerPage.dart';
import 'package:trackpro/SignUpPage.dart';
import 'package:trackpro/chatbot.dart';
import 'package:trackpro/createproject.dart';
import 'package:trackpro/dashboard.dart';
import 'package:trackpro/homepage.dart';
import 'package:trackpro/login.dart';
import 'package:trackpro/platformstat.dart';
import 'package:trackpro/profile.dart';
import 'package:trackpro/projectpage.dart';
import 'package:trackpro/explorepage.dart';
import 'package:trackpro/recommend.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    Gemini.init(
      apiKey: 'AIzaSyDYQqol4UPKrBujeKUfWxMMNoscZzfGqiM',
      enableDebugging: true, 
    );
    print('Gemini initialized successfully');
  } catch (e) {
    print('Error initializing Gemini: $e');
  }
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: 'AIzaSyA5lnFpUEnqfV8U-QBohgUIamptQS_7goA',
      appId: '1:882927404853:android:02ee1adb7a03650364ae7c',
      messagingSenderId: '882927404853',
      projectId: 'trackpro-fcc7d',
    ),
  );
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrackPro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      initialRoute: '/dash',
      routes: {
        '/dash': (context) => const DashboardPage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/home': (context) => const HomePage(),
        '/profile': (context) => const ProfilePage(),
        '/resume': (context) => const ResumeGeneratorPage(),
        '/projects': (context) => const ProjectsPage(),
        '/explore': (context) => const ExplorePage(),
        '/suggest': (context) => const RecommendPage(),
        '/add': (context) => const CreateProjectPage(),
        '/create-resume': (context) => const ResumeGeneratorPage(),
        '/stats': (context) => const PlatformStatsPage(),
        '/track': (context) => const RoadmapTrackerPage(),
        '/chat': (context) => const EducationChatbotScreen(),
      },
    );
  }
}
