import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _phoneNumber = '';
  String _otpInput = '';
  String _generatedOtp = '';
  DateTime? _otpExpiry;
  bool _isSendingOtp = false;
  bool _showOtpVerification = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String _generateOTP() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSendingOtp = true);
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _generatedOtp = _generateOTP();
        _otpExpiry = DateTime.now().add(const Duration(minutes: 5));
        _isSendingOtp = false;
        _showOtpVerification = true;
      });
      
      debugPrint('OTP sent to ${_emailController.text}: $_generatedOtp');
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpInput == _generatedOtp && DateTime.now().isBefore(_otpExpiry!)) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', _usernameController.text);
      await prefs.setString('email', _emailController.text);
      await prefs.setString('phone', _phoneNumber);
      await prefs.setString('password', _passwordController.text);
      await prefs.setBool('isVerified', true);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Registration successful!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _otpInput != _generatedOtp
                ? 'Invalid OTP. Please try again.'
                : 'OTP has expired. Please request a new one.',
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine screen width to adjust layout
    double screenWidth = MediaQuery.of(context).size.width;
    double maxWidth = screenWidth > 600 ? 500 : screenWidth * 0.9;  // Max width for large screens

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Container(
              width: maxWidth,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                color: Theme.of(context).colorScheme.background,
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        'Create Account',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Fill in your details to continue',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            if (!_showOtpVerification) ...[
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: _buildRegistrationForm(),
                              ),
                            ] else ...[
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: _buildOtpVerification(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegistrationForm() {
    return Column(
      key: const ValueKey('registration-form'),
      children: [
        TextFormField(
          controller: _usernameController,
          decoration: const InputDecoration(
            labelText: 'Username',
            prefixIcon: Icon(FontAwesomeIcons.user, size: 18),
          ),
          validator: (value) =>
              value == null || value.isEmpty ? 'Enter username' : null,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(FontAwesomeIcons.envelope, size: 18),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) => value == null || !value.contains('@')
              ? 'Enter valid email'
              : null,
        ),
        const SizedBox(height: 20),
        IntlPhoneField(
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            prefixIcon: Icon(FontAwesomeIcons.phone, size: 18),
          ),
          initialCountryCode: 'IN',
          onChanged: (phone) => _phoneNumber = phone.completeNumber,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(FontAwesomeIcons.lock, size: 18),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? FontAwesomeIcons.eye
                    : FontAwesomeIcons.eyeSlash,
                size: 18,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          validator: (value) => value == null || value.length < 6
              ? 'Password must be at least 6 characters'
              : null,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            prefixIcon: const Icon(FontAwesomeIcons.lock, size: 18),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? FontAwesomeIcons.eye
                    : FontAwesomeIcons.eyeSlash,
                size: 18,
              ),
              onPressed: () => setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword),
            ),
          ),
          validator: (value) => value != _passwordController.text
              ? 'Passwords do not match'
              : null,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton(
            onPressed: _isSendingOtp ? null : _sendOtp,
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            ),
            child: _isSendingOtp
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Register & Send OTP'),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Already have an account?',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: const Text('Login'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOtpVerification() {
    return Column(
      key: const ValueKey('otp-verification'),
      children: [
        Text(
          'Enter the 6-digit code sent to ${_emailController.text}',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'OTP Code',
            prefixIcon: Icon(FontAwesomeIcons.key, size: 18),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) => _otpInput = value,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Expires in: ${_formatCountdown()}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() => _showOtpVerification = false);
              },
              child: const Text('Change Email'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton(
            onPressed: _verifyOtp,
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Verify OTP'),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            _generatedOtp = _generateOTP();
            _otpExpiry = DateTime.now().add(const Duration(minutes: 5));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('New OTP sent!'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: const Text('Resend OTP'),
        ),
      ],
    );
  }

  String _formatCountdown() {
    if (_otpExpiry == null) return '05:00';
    final remaining = _otpExpiry!.difference(DateTime.now());
    final minutes = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
 
