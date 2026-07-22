import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iac_login_app/CommonConst/Constants.dart';
import 'package:iac_login_app/GenerateQRScreen.dart';
import 'package:iac_login_app/main.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

import 'CommonConst/CustomLoader.dart';
import 'GenerateQrCodeTwoScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Password visibility toggle
  bool _obscurePassword = true;

  // Secret tap counter for logo
  int _tapCount = 0;
  bool _showSecretLabel = false;
  bool _showDevInfo = false;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    print('LoginScreen initialized');
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogoTapped() {
    setState(() {
      _tapCount++;

      // Show dev info on 10 taps
      if (_tapCount == 10) {
        _showDevInfo = true;
        _showSecretLabel = false;

        // Cancel any existing timer
        _hideTimer?.cancel();

        // Auto-hide after 10 seconds
        _hideTimer = Timer(const Duration(seconds: 10), () {
          if (mounted) {
            setState(() {
              _showDevInfo = false;
              _tapCount = 0;
            });
          }
        });
      }

      // Show old secret label on 15 taps (kept for backward compatibility)
      if (_tapCount == 15 && !_showDevInfo) {
        _showSecretLabel = true;
        _hideTimer?.cancel();
        _hideTimer = Timer(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              _showSecretLabel = false;
              _tapCount = 0;
            });
          }
        });
      }
    });
  }

  // Function to handle login API call
  Future<void> _login() async {
    const String url = '${BASE_URL}/desktoplogin';

    try {
      LoaderManager.callLoader(context, true);

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'email_id': _emailController.text,
          'password': _passwordController.text,
        },
      );

      LoaderManager.callLoader(context, false);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData['status'] == true) {
        // Success case
        final prefs = await SharedPreferences.getInstance();
        final data = responseData['data'];

        // Save data to SharedPreferences
        await prefs.setBool(IS_LOGIN, true);
        await prefs.setString('associate_id', data['associate_id']);
        await prefs.setString('name', data['name']);
        await prefs.setString('email', data['email']);
        await prefs.setString('role', data['role']);
        await prefs.setString('companycode', data['companycode']);

        print('Login successful, data saved to SharedPreferences');

        // Navigate to next screen using GetX
        Get.offAll(() =>  GenerateQRCode());
      } else {
        // Failure case - Invalid credentials
        _showErrorDialog(responseData['message'] ?? 'Invalid credentials');
      }
    } catch (e) {
      LoaderManager.callLoader(context, false);
      print('Error during login: $e');
      _showErrorDialog('An error occurred. Please try again. $e');
    }
  }

  // Function to show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            color: Colors.green.shade900,
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              'assets/forest_aerial.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.green.shade800,
                  child: const Center(
                    child: Text(
                      'Background Image',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                );
              },
            ),
          ),

          // Login Card
          Center(
            child: Card(
              margin: const EdgeInsets.all(24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                width: 400,
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // IAC Logo
                    GestureDetector(
                      onTap: _onLogoTapped,
                      child: Image.asset(
                        'assets/iac-Logo.png',
                        height: 60,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 60,
                            width: 60,
                            color: Colors.grey.shade300,
                            child: const Center(
                              child: Text(
                                'IAC',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (_showSecretLabel)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          "d-ev :k_e-sh:av 9*7/6+51.1-2'36#2",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 8,
                          ),
                        ),
                      ),

                    const SizedBox(height: 32),

                    // Login Title
                    const Text(
                      'Log in your account!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Email Field
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'Email ID',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password Field with Hide/Show Toggle
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _login,
                        child: const Text(
                          'Log in',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Version and Developer Info
                    Column(
                      children: [
                        // Version
                        Text(
                          'V - 1.0.4+5',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),

                        // Developer Info (shown on 10 taps)
                        if (_showDevInfo)
                          Container(
                            margin: const EdgeInsets.only(top: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.blue.shade200,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.code,
                                      size: 16,
                                      color: Colors.blue.shade700,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Developer Information',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Dev - Keshav Pawar',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.phone,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '9765112362',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.email,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'keshavpawar100@gmail.com',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}