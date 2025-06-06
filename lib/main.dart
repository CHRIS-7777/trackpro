import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:trackpro/CreateResume.dart';
import 'package:trackpro/SignUpPage.dart';
import 'package:trackpro/createproject.dart';
import 'package:trackpro/dashboard.dart';
import 'package:trackpro/homepage.dart';
import 'package:trackpro/login.dart';
import 'package:trackpro/profile.dart';
import 'package:trackpro/projectpage.dart';
import 'package:trackpro/explorepage.dart';
import 'package:trackpro/recommend.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    Gemini.init(apiKey: 'AIzaSyDYQqol4UPKrBujeKUfWxMMNoscZzfGqiM'); // Replace with your Gemini API key
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: 'AIzaSyA5lnFpUEnqfV8U-QBohgUIamptQS_7goA',
      appId: '1:882927404853:android:02ee1adb7a03650364ae7c',
      messagingSenderId: '882927404853',
      projectId: 'trackpro-fcc7d',
    ),
  );
  runApp(MyApp());
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
  '/dash': (context) => DashboardPage(),
  '/login': (context) => LoginPage(),
  '/signup': (context) => SignUpPage(),
    '/home': (context) => HomePage(),
     '/profile': (context) => ProfilePage(),
'/resume': (context) => const ResumeGeneratorPage(),
  '/projects': (context) => ProjectsPage(),
  '/explore': (context) => ExplorePage(),
  '/suggest': (context) => RecommendPage(),
   '/add': (context) => CreateProjectPage(),
  // '/settings': (context) => SettingsPage(),
},

    );
  }
}
