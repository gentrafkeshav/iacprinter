import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX package

import 'CommonConst/ColorsCommon.dart';
import 'SplashScreen.dart';

// TODO: Timeline and details
/*


Application Square server  - ${BASE_URL}/
IAC Server


login details
username - imm@iac.com
pass - Imm@123
 */

/*

 */


void main() {
  runApp(MyApp());
}

//api base url

// //dev
// const String BASE_URL = 'https://softwaresupport.co.in/iac/webservices'; // Application square

//Live
// const String BASE_URL = 'http://10.105.102.55/iac/home/dashboard'; //IAC

// const String BASE_URL = 'http://10.105.102.55/iac'; //IAC 1.0.2+3

const String BASE_URL = 'http://10.105.102.55/iac/webservices'; //IAC 1.0.3+4


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false, // Remove debug banner
      title: 'Splash Screen Demo',
      theme: ThemeData(
        primarySwatch: Colors.yellow, // Set the primary color
        fontFamily: 'Poppins', // Set default font
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black), // Default border color
            borderRadius: BorderRadius.circular(8.0), // Border radius
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 0.8), // Focused border
            borderRadius: BorderRadius.circular(8.0),
          ),

          labelStyle: TextStyle(
            color: Colors.grey[800], // Label color
            fontWeight: FontWeight.w500,
          ),
        ),
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: Colors.black, // Progress indicator color
        ),

        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(color: Colors.white), // Back button color in white
          // textTheme: TextTheme(
          //   headline6: TextStyle(
          //     color: Colors.white,
          //     fontSize: 20.0,
          //     fontWeight: FontWeight.bold,
          //   ),
          // ),
        ),

      ),
      home: SplashScreen(),

    );
  }
}
