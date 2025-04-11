import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:trackpro/SignUpPage.dart';
import 'package:trackpro/dashboard.dart';
import 'package:trackpro/login.dart';
 // generated automatically

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
        fontFamily: 'Roboto',
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      initialRoute: '/dash',
        routes: {
  '/dash': (context) => DashboardPage(),
  '/login': (context) => LoginPage(),
  '/signup': (context) => SignUpPage(),
  // '/resumes': (context) => ResumesPage(),         // define this screen
  // '/create-resume': (context) => CreateResumePage(),
  // '/projects': (context) => ProjectsPage(),
  // '/explore': (context) => ExplorePage(),
  // '/settings': (context) => SettingsPage(),
},

    );
  }
}
