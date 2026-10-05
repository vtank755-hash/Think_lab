import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'register_user.dart';
import 'index.dart';

const _primary = Color(0xFF6C35E8);
const _indigo = Color(0xFF4945E8);
const _heading = Colors.black;
const _muted = Colors.black;
const _fieldBackground = Color(0xFFEEF0FF);

class login_user extends StatefulWidget {
  const login_user({super.key});

  @override
  State<login_user> createState() => _login_userState();
}

class _login_userState extends State<login_user> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  // Email validator
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  // Password validator
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // Submit login
  void _submitLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const index(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final padding = constraints.maxWidth > 520 ? 40.0 : 28.0;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(padding, 30, padding, 30),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _logo(),
                        const SizedBox(height: 38),
                        const Text('Welcome back', style: TextStyle(
                          color: _heading, fontSize: 40,
                          fontWeight: FontWeight.bold, height: 1.1,
                        )),
                        const SizedBox(height: 12),
                        const Text('Log in to continue learning.', style: TextStyle(
                          color: _muted, fontSize: 20, fontWeight: FontWeight.w500,
                        )),
                        const SizedBox(height: 42),
                        const _FieldLabel('EMAIL'),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _email,
                          validator: _validateEmail,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: _fieldBackground,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.email_outlined, color: _primary, size: 25),
                            hintText: 'you@email.com',
                            hintStyle: const TextStyle(
                              color: Colors.black54,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 19),
                            errorStyle: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        const _FieldLabel('PASSWORD'),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _password,
                          validator: _validatePassword,
                          obscureText: _obscurePassword,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: _fieldBackground,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.lock_outline, color: _primary, size: 25),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              child: Icon(
                                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: _primary,
                                size: 25,
                              ),
                            ),
                            hintText: '••••••••',
                            hintStyle: const TextStyle(
                              color: Colors.black54,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 19),
                            errorStyle: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Align(alignment: Alignment.centerRight,
                          child: Text('Forgot Password?', style: _link(18))),
                        const SizedBox(height: 25),
                        GestureDetector(
                          onTap: _submitLogin,
                          child: Container(
                            width: double.infinity,
                            height: 74,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [_primary, _indigo]),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignment: Alignment.center,
                            child: const Text('Login', style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            )),
                          ),
                        ),
                        const SizedBox(height: 48),
                        Center(
                          child: Text.rich(
                            TextSpan(
                              text: "Don't have an account? ",
                              style: const TextStyle(color: _muted, fontSize: 18),
                              children: [
                                TextSpan(
                                  text: 'Sign Up',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const register_user(),
                                        ),
                                      );
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Center(child: Text('Admin? Admin Login', style: TextStyle(
                          color: _muted, fontSize: 16, fontWeight: FontWeight.w500,
                        ))),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _logo() => Container(
    width: 76, height: 76,
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [_primary, _indigo]),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Center(child: CustomPaint(size: const Size(38, 38), painter: _LogoPainter())),
  );

  static TextStyle _link(double size) => TextStyle(color: Colors.black, fontSize: size, fontWeight: FontWeight.w700);
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Text(label, style: const TextStyle(
    color: Color.fromARGB(255, 0, 0, 0), fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 1.1,
  ));
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(size.width * .85, size.height * .32)
      ..lineTo(size.width * .46, size.height * .32)
      ..arcToPoint(Offset(size.width * .46, size.height * .68), radius: Radius.circular(size.height * .18), clockwise: false)
      ..lineTo(size.width * .85, size.height * .68);
    canvas.drawPath(path, paint);
    final center = Offset(size.width * .5, size.height * .5);
    final radius = size.width * .085;
    canvas.drawCircle(center, radius, paint);
    canvas.drawLine(Offset(center.dx + radius, center.dy), Offset(size.width * .85, center.dy), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
