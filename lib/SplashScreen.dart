import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iac_login_app/GenerateQRScreen.dart';
import 'package:iac_login_app/loginpage.dart';


import 'package:shared_preferences/shared_preferences.dart';


import 'CommonConst/Constants.dart';
import 'CommonConst/commonMethods.dart';
import 'GenerateQrCodeTwoScreen.dart';
import 'main.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  @override
  void initState() {
    super.initState();
    // Navigate to the appropriate screen after 3 seconds
    Future.delayed(Duration(seconds: 3), () async {
      final prefs = await SharedPreferences.getInstance();

      // Debug: Check if the key exists in SharedPreferences
      bool containsKey = prefs.containsKey(IS_LOGIN);
      consoleLog('Does SharedPreferences contain IS_LOGGED_IN key?', containsKey);

     // Get.offAll(LoginScreen());

      if (!containsKey) {
        // If the key does not exist, navigate to the LoginScreen
        consoleLog('IS_LOGGED_IN key does not exist. Navigating to LoginScreen.', 1);
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => LoginScreen()),
        // );

       // Get.to(TabBarControllerScreen());

        Get.offAll(LoginScreen());

      } else {
        // If the key exists, retrieve its value
        bool isLoggedIn = prefs.getBool(IS_LOGIN) ?? false;
        consoleLog('isLoggedIn value', isLoggedIn);

        // Navigate based on the isLoggedIn value
        if (isLoggedIn) {
          // If logged in, go to the home screen
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(builder: (context) => Submitenquiryscreen()),
          // );

          Get.offAll(GenerateQRCode());

        } else {
          // If not logged in, go to the login screen
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(builder: (context) => LoginScreen()),
          // );

          Get.offAll(LoginScreen());
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width; // Get screen width
    double imageWidth = screenWidth; // Calculate 80% of the screen width

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Image
          Center(
            child: Container(
              width: imageWidth,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/forest_aerial.jpg'), // Your background image
                  fit: BoxFit.fitHeight, // Adjust fit as needed
                ),
              ),
            ),
          ),

          // Text: "Welcome to" and "Mitra Sathi" (20 units above the previous text)
          Positioned(
            bottom: 150, // 20 units above the "Desh ka No.1 Sprayer" text
            left: 0,
            right: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome to',
                  style: TextStyle(
                    fontSize: 24, // Adjust font size as needed
                    fontWeight: FontWeight.bold, // Bold text
                    color: Colors.white, // Text color
                  ),
                ),
                Text(
                  'I A C',
                  style: TextStyle(
                    fontSize: 32, // Adjust font size as needed
                    fontWeight: FontWeight.bold, // Bold text
                    color: Colors.white, // Text color
                  ),
                ),
              ],
            ),
          ),

          // Text: "Desh ka No.1 Sprayer" (20 units from the bottom)
          Positioned(
            bottom: 80, // 20 units from the bottom
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Building a Sustainable Business for a Sustainable Future',
                style: TextStyle(
                  fontSize: 16, // Adjust font size as needed
                  fontWeight: FontWeight.bold, // Bold text
                  color: Colors.white, // Text color
                ),
              ),
            ),
          ),


        ],
      ),
    );
  }
}