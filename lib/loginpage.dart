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
import 'GenerateQrCodeTwoScreen.dart'; // Assuming you're using GetX for navigation

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? _selectedOption;
  final List<String> _options = ['Option 1', 'Option 2', 'Option 3'];
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();


 int _tapCount = 0;
  bool _showSecretLabel = false;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    print('LoginScreen initialized');
  }


  void _onLogoTapped() {
    setState(() {
      _tapCount++;
      if (_tapCount == 15) {
        _showSecretLabel = true;
        _hideTimer?.cancel(); // Cancel previous timer if any
        _hideTimer = Timer(const Duration(seconds: 5), () {
          setState(() {
            _showSecretLabel = false;
            _tapCount = 0; // Reset count
          });
        });
      }
    });
  }

   @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  // Function to handle login API call
  Future<void> _login() async {
    // const String url = '${BASE_URL}/desktoplogin';
    const String url = '${BASE_URL}/desktoplogin';

    try {

      LoaderManager.callLoader(context, true); // Show loader

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          //'Cookie': 'ci_session=a65be01c29d8852f37b5898596a2f9f54ed0a3e0',
        },
        body: {
          'email_id': _emailController.text,
          'password': _passwordController.text,
        },
      );

      LoaderManager.callLoader(context, false); // Show loader

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
        //Get.offAll(() => const G()); // Replace HomeScreen with your next screen widget

        Get.offAll(GenerateQRCode());
      } else {
        // Failure case - Invalid credentials
        _showErrorDialog(responseData['message']);
      }
    } catch (e) {
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
              Navigator.of(context).pop(); // Dismiss dialog
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('Screen width: ${MediaQuery.of(context).size.width}');
    print('Screen height: ${MediaQuery.of(context).size.height}');

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            color: Colors.green.shade900,
            width: double.infinity,
            height: double.infinity,
            child: FutureBuilder(
              future: Future.delayed(const Duration(milliseconds: 100)),
              builder: (context, snapshot) {
                print('Attempting to load background image');
                return Image.asset(
                  'assets/forest_aerial.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    print('Error loading background: $error');
                    return Container();
                  },
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
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Text(
                        'IAC',
                        style: TextStyle(fontSize: 24),
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
                  style: TextStyle(color: Colors.grey, fontSize: 8),
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

                    // Dropdown
                    // Container(
                    //   decoration: BoxDecoration(
                    //     color: Colors.white,
                    //     borderRadius: BorderRadius.circular(8),
                    //   ),
                    //   child: DropdownButtonFormField<String>(
                    //     decoration: const InputDecoration(
                    //       hintText: 'Select Option',
                    //     ),
                    //     isExpanded: true,
                    //     value: _selectedOption,
                    //     items: _options.map((String option) {
                    //       return DropdownMenuItem<String>(
                    //         value: option,
                    //         child: Text(option),
                    //       );
                    //     }).toList(),
                    //     onChanged: (String? newValue) {
                    //       print('Option selected: $newValue');
                    //       setState(() {
                    //         _selectedOption = newValue;
                    //       });
                    //     },
                    //   ),
                    // ),
                    const SizedBox(height: 16),

                    // Email Field
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        hintText: 'Email ID',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'Password',
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
                        onPressed: _login, // Call login function
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
                    //version
                    Text('V - 1.0.2+3', style: TextStyle(fontSize: 10, color: Colors.grey),)
                    
                    
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

// Placeholder for HomeScreen (replace with your actual next screen)
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(child: Text('Welcome to Home Screen!')),
    );
  }
}