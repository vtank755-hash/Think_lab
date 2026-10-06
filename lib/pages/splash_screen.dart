import 'dart:async';
import 'package:flutter/material.dart';
import '../login_user.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Timer _navigationTimer;

  @override
  void initState() {
    super.initState();
    // Start timer for 3 seconds
    _navigationTimer = Timer(const Duration(seconds: 3), _navigateToLogin);
  }

  void _navigateToLogin() {
    if (!mounted) return;

    // Splash finished -> Go to the Login page.
    // Use pushReplacement so user cannot return to splash screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const login_user()),
    );
  }

  @override
  void dispose() {
    _navigationTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6B3FEA), // Vibrant Purple
              Color(0xFF5A30DC), // Mid Violet
              Color(0xFF4221C4), // Deep Indigo
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Container
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: CustomPaint(
                    size: const Size(60, 60),
                    painter: LearnHubLogoSplashPainter(),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // App Name
              const Text(
                'LearnHub',
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 16),

              // Tagline
              Text(
                'Learn Anytime, Anywhere',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.85),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 60),

              // Loading indicator
              SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(
                    Colors.white.withOpacity(0.7),
                  ),
                  strokeWidth: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for LearnHub logo
class LearnHubLogoSplashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double w = size.width;
    final double h = size.height;

    // Outer rounded horseshoe / loop
    final path = Path();
    path.moveTo(w * 0.85, h * 0.32);
    path.lineTo(w * 0.46, h * 0.32);
    path.arcToPoint(
      Offset(w * 0.46, h * 0.68),
      radius: Radius.circular(h * 0.18),
      clockwise: false,
    );
    path.lineTo(w * 0.85, h * 0.68);
    canvas.drawPath(path, strokePaint);

    // Inner node circle
    final circleCenter = Offset(w * 0.50, h * 0.50);
    final double circleRadius = w * 0.085;

    canvas.drawCircle(circleCenter, circleRadius, strokePaint);

    // Horizontal line from node to right
    canvas.drawLine(
      Offset(circleCenter.dx + circleRadius, h * 0.50),
      Offset(w * 0.85, h * 0.50),
      strokePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
