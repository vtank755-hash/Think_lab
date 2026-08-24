import 'dart:async';

import 'package:flutter/material.dart';
import 'login_user.dart';

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
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const LearnHubWelcomeScreen(),
    );
  }
}

class LearnHubWelcomeScreen extends StatefulWidget {
  const LearnHubWelcomeScreen({super.key});

  @override
  State<LearnHubWelcomeScreen> createState() => _LearnHubWelcomeScreenState();
}

class _LearnHubWelcomeScreenState extends State<LearnHubWelcomeScreen> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _navigationTimer = Timer(const Duration(seconds: 3), _openLoginScreen);
  }

  void _openLoginScreen() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(builder: (_) => const login_user()),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Gradient
          Container(
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
          ),

          // 2. Decorative Background Circles
          // Top Left Circle
          Positioned(
            top: 50,
            left: 30,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),

          // Bottom Right Circle
          Positioned(
            bottom: 140,
            right: 20,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),

          // 3. Main Content
          SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),

                  // Logo Icon Card
                  Container(
                    width: 108,
                    height: 108,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.22),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: CustomPaint(
                        size: const Size(48, 48),
                        painter: LearnHubLogoPainter(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // App Title
                  const Text(
                    'LearnHub',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Subtitle
                  Text(
                    'Learn Anytime, Anywhere',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.85),
                      letterSpacing: 0.2,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // "Enter" Action Button
                  ElevatedButton(
                    onPressed: _openLoginScreen,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF5A30DC),
                      elevation: 4,
                      shadowColor: Colors.black.withValues(alpha: 0.2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 46,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Enter',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // 4. Page Indicator Dots
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // Active indicator pill
                      Container(
                        width: 30,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),

                      // Inactive dot 1
                      Container(
                        width: 6.5,
                        height: 6.5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.45),
                        ),
                      ),

                      // Active last dot (filled)
                      Container(
                        width: 6.5,
                        height: 6.5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for the LearnHub logo icon
class LearnHubLogoPainter extends CustomPainter {
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

    // 1. Outer rounded horseshoe / loop
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

    // 2. Inner node circle
    final circleCenter = Offset(w * 0.50, h * 0.50);
    final double circleRadius = w * 0.085;

    canvas.drawCircle(circleCenter, circleRadius, strokePaint);

    // 3. Horizontal line from the node to the right
    canvas.drawLine(
      Offset(circleCenter.dx + circleRadius, h * 0.50),
      Offset(w * 0.85, h * 0.50),
      strokePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

