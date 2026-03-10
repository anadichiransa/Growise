import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/config/firebase_config.dart';
import 'features/auth/presentation/screens/signup-form.dart'; 

void main() async {
  // Ensure Flutter is initialized before interacting with native code
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Enable Firestore offline persistence
  await FirebaseConfig.enableFirestoreOffline();
  
  // Launch the app
  runApp(const GrowiseApp());
}

class GrowiseApp extends StatelessWidget {
  const GrowiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Growise',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color(0xFF1E1335),
      ),
     
      home: const SignupFormScreen(), 
    );
  }
}