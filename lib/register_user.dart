import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

// Color Palette
const _primary = Color(0xFF6C35E8);
const _indigo = Color(0xFF4846D9);
const _darkNavy = Color(0xFF292C55);
const _lightPurple = Color(0xFF7276A8);
const _fieldBackground = Color(0xFFEEF0FA);
const _lightBorder = Color(0xFFE0E3F2);
const _white = Color(0xFFFFFFFF);

// =====================================================
// UI STRUCTURE (SCREEN VIEW)
//  1. Back button             -> Container + GestureDetector + Icon (back arrow)
//  2. Title                   -> Text ("Create account")
//  3. Subtitle                -> Text ("Start your learning journey today.")
//  4. Full Name field         -> TextFormField + TextEditingController
//  5. Email field             -> TextFormField + TextEditingController
//  6. Password field          -> TextFormField + eye icon (GestureDetector + Icon)
//  7. Confirm Password field  -> TextFormField + eye icon (GestureDetector + Icon)
//  8. Terms checkbox          -> GestureDetector + Row + Container (custom checkbox)
//  9. Sign Up button          -> Container + GestureDetector ("Sign Up")
//  10. Login text             -> Text.rich + TapGestureRecognizer (back to Login)
// =====================================================

/// REGISTER PAGE (StatefulWidget)
/// StatefulWidget is used here because this page holds user input
/// (name, email, passwords) and shows error messages, so the page has to
/// rebuild itself while the user is typing.
/// Layout: Scaffold -> SafeArea -> Column (back button, form fields,
/// terms checkbox, Sign Up button).
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Each TextEditingController stores one typed field
  // so we can read it when the user taps Sign Up.
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  // true only when the user ticks the terms checkbox.
  bool _agreeToTerms = false;
  // These two flags hide / show the password text.
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Free all the controllers when this page is closed.
  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  // Name validator
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    if (value.length < 3) {
      return 'Name must be at least 3 characters';
    }
    final nameRegex = RegExp(r'^[a-zA-Z\s]+$');
    if (!nameRegex.hasMatch(value)) {
      return 'Please enter a valid name';
    }
    return null;
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
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // Confirm Password validator
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _password.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Submit registration
  void _submitRegister() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    // Terms not accepted -> show a warning message and stop here.
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please accept the Terms of Service and Privacy Policy',
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Registration details validated successfully!'),
      ),
    );

    // Give the user 1 second to read the success message.
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        // Registration finished -> back to the Login page.
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Scaffold = the whole registration page (white background + body).
      backgroundColor: _white,
      // SafeArea = keeps the form away from the notch / status bar.
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
                    // Column -> vertical stack: back button, heading, fields,
                    // checkbox, Sign Up button.
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back Button
                        _buildBackButton(),
                        const SizedBox(height: 38),

                        // Main Heading
                        const Text(
                          'Create account',
                          style: TextStyle(
                            color: _darkNavy,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Subtitle
                        const Text(
                          'Start your learning journey today.',
                          style: TextStyle(
                            color: _lightPurple,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Full Name Input Field
                        // TextFormField = name box that also runs validation.
                        TextFormField(
                          controller: _name,
                          validator: _validateName,
                          style: const TextStyle(
                            color: _darkNavy,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                          cursorColor: _primary,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: _fieldBackground,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            // Icon = person symbol inside the name field.
                            prefixIcon: const Icon(
                              Icons.person_outline,
                              color: _primary,
                              size: 24,
                            ),
                            hintText: 'Full Name',
                            hintStyle: const TextStyle(
                              color: _lightPurple,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 19,
                            ),
                            errorStyle: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Email Address Input Field
                        TextFormField(
                          controller: _email,
                          validator: _validateEmail,
                          style: const TextStyle(
                            color: _darkNavy,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                          cursorColor: _primary,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: _fieldBackground,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(
                              Icons.mail_outline,
                              color: _primary,
                              size: 24,
                            ),
                            hintText: 'Email Address',
                            hintStyle: const TextStyle(
                              color: _lightPurple,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 19,
                            ),
                            errorStyle: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Password Input Field
                        TextFormField(
                          controller: _password,
                          validator: _validatePassword,
                          obscureText: _obscurePassword,
                          style: const TextStyle(
                            color: _darkNavy,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                          cursorColor: _primary,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: _fieldBackground,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: _primary,
                              size: 24,
                            ),
                            // GestureDetector = taps show or hide the password.
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              child: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: _primary,
                                size: 24,
                              ),
                            ),
                            hintText: 'Password',
                            hintStyle: const TextStyle(
                              color: _lightPurple,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 19,
                            ),
                            errorStyle: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Confirm Password Input Field
                        TextFormField(
                          controller: _confirmPassword,
                          validator: _validateConfirmPassword,
                          obscureText: _obscureConfirmPassword,
                          style: const TextStyle(
                            color: _darkNavy,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                          cursorColor: _primary,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: _fieldBackground,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(
                              Icons.shield_outlined,
                              color: _primary,
                              size: 24,
                            ),
                            // GestureDetector = same eye toggle for confirm password.
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                              child: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: _primary,
                                size: 24,
                              ),
                            ),
                            hintText: 'Confirm Password',
                            hintStyle: const TextStyle(
                              color: _lightPurple,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 19,
                            ),
                            errorStyle: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Terms and Privacy Agreement
                        _buildTermsAgreement(),
                        const SizedBox(height: 24),

                        // Sign Up Button
                        _buildGradientButton(),
                        const SizedBox(height: 32),

                        // Login Redirect Text
                        Center(
                          child: Text.rich(
                            TextSpan(
                              text: "Already have an account? ",
                              style: const TextStyle(
                                color: _lightPurple,
                                fontSize: 18,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Login',
                                  style: _linkTextStyle(18),
                                  // User taps Login link -> back to the Login page.
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.pop(context);
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
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

  // Back Button Widget
  Widget _buildBackButton() {
    // Container = rounded square behind the back arrow.
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: _fieldBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: GestureDetector(
        // Back arrow -> return to the previous page (Login).
        onTap: () {
          Navigator.pop(context);
        },
        // Icon = the back arrow drawn inside the button.
        child: const Icon(Icons.arrow_back, color: _primary, size: 24),
      ),
    );
  }

  // Terms and Privacy Agreement Widget
  Widget _buildTermsAgreement() {
    // GestureDetector = tapping anywhere toggles the terms checkbox.
    return GestureDetector(
      onTap: () {
        setState(() {
          _agreeToTerms = !_agreeToTerms;
        });
      },
      // Row -> custom checkbox on the left, agreement text on the right.
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: _agreeToTerms ? _primary : _fieldBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _agreeToTerms ? _primary : _lightBorder,
                width: 2,
              ),
            ),
            child: _agreeToTerms
                ? const Icon(Icons.check, color: _white, size: 18)
                : null,
          ),
          // Agreement Text
          // Expanded = lets the agreement text wrap in the leftover width.
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text.rich(
                TextSpan(
                  text: 'I agree to the ',
                  style: const TextStyle(
                    color: _lightPurple,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(
                      text: 'Terms of Service',
                      style: _linkTextStyle(16),
                    ),
                    TextSpan(
                      text: ' and ',
                      style: const TextStyle(
                        color: _lightPurple,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(text: 'Privacy Policy', style: _linkTextStyle(16)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Gradient Sign Up Button
  Widget _buildGradientButton() {
    // Container = the gradient rounded Sign Up button.
    return Container(
      width: double.infinity,
      height: 74,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_primary, _indigo],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      // GestureDetector = taps validate the form and register the user.
      child: GestureDetector(
        onTap: _submitRegister,
        child: const Center(
          child: Text(
            'Sign Up',
            style: TextStyle(
              color: _white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // Helper method for link text style
  static TextStyle _linkTextStyle(double size) => const TextStyle(
    color: _primary,
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );
}
