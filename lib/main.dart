import 'package:flutter/material.dart';
import 'pages/splash_screen.dart';

// =============================================================
// LEARNHUB APP - MAIN FILE
// App entry point. Navigation flow used in this project:
//
// Splash -> Login -> Home
// Home -> Categories -> Course List -> Course Details
// Course Details -> Add to Cart -> Cart -> Checkout -> UPI QR
// UPI Payment -> Payment Successful -> Course Enrolled
// Course Details -> Curriculum -> Module -> Lesson Video
// Lesson Video -> Next Lesson -> Last Lesson -> Course Quiz
// Quiz -> Result (75% or above = pass, below = retry quiz)
// Bottom nav: Home | Learning | Wishlist | Profile
// =============================================================
void main() {
  runApp(const LearnHubApp());
}

class LearnHubApp extends StatelessWidget {
  const LearnHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LearnHub',
      theme: ThemeData(useMaterial3: true),
      home: const SplashScreen(),
    );
  }
}
