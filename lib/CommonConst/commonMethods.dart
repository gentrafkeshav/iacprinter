import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:intl/intl.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';



import 'ColorsCommon.dart';


import 'Constants.dart';

//common methods

// TODO: print
//global Print Statement
/*
//its not fully print big data - ok
void consoleLog(String propertyName, dynamic propertyValue) {
  print('$propertyName ====== $propertyValue');
}

 */

//for big data print statement
void consoleLog(String propertyName, dynamic propertyValue) {
  String message = '$propertyName ====== $propertyValue';

  debugPrint(message, wrapWidth: 99999);
}

// TODO: AppBar without icons
//app Bar method no icon
AppBar customAppBar({
  required String title,
  required Color titleColor,
  Color backgroundColor = myAppColor,
  double elevation = 4.0,
  required Color appBarColor,
}) {
  return AppBar(
    backgroundColor: myAppColor,
    elevation: 0,
    // Set to 0 to remove default shadow
    title: Text(
      title,
      style: TextStyle(
        color: titleColor,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    iconTheme: IconThemeData(
      color: titleColor,
    ),
    flexibleSpace: Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.9),
            spreadRadius: 0.1,
            blurRadius: 4,
            offset: Offset(0, 0),
          ),
        ],
      ),
    ),
  );
}


//custom app bar with right icon
AppBar customAppBar_withRightIcon({
  required String title,
  required Color titleColor,
  Color backgroundColor = myAppColor,
  double elevation = 4.0,
  required Color appBarColor,
  IconData? rightIcon, // Optional icon
  Color rightIconColor = Colors.white, // Default icon color
  VoidCallback? onRightIconPressed, // Click action
}) {
  return AppBar(
    backgroundColor: myAppColor,
    elevation: elevation,
    title: Text(
      title,
      style: TextStyle(
        color: titleColor,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    iconTheme: IconThemeData(
      color: titleColor,
    ),
    actions: rightIcon != null
        ? [
      IconButton(
        icon: Icon(rightIcon, color: rightIconColor),
        onPressed: onRightIconPressed,
      )
    ]
        : null,
    flexibleSpace: Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.9),
            spreadRadius: 0.1,
            blurRadius: 4,
            offset: Offset(0, 0),
          ),
        ],
      ),
    ),
  );
}


// TODO: App Bar with icons
//custom app bar with icons
AppBar customAppBarWithIcons({
  required String title,
  required Color titleColor,
  Color backgroundColor = myAppColor,
  double elevation = 4.0,
  required Color appBarColor,
  IconData? icon, // Icon data for the right-side icon
  Color iconColor = myAppColor, // Default color for the icon
  Color iconBackgroundColor = myWhiteColor, // Background color for the icon
  VoidCallback? onIconPressed, // Callback for icon tap
}) {
  return AppBar(
    backgroundColor: backgroundColor,
    elevation: 0,
    // Set to 0 to remove default shadow
    title: Text(
      title,
      style: TextStyle(
        color: titleColor,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    iconTheme: IconThemeData(
      color: titleColor,
    ),
    actions: icon != null // Check if an icon is provided
        ? [
      IconButton(
        icon: Container(
          decoration: BoxDecoration(
            color: myAppColor,
            shape: BoxShape.circle,
          ),
          padding: EdgeInsets.all(8),
          // Adjust padding to make the icon smaller within the circle
          child: Icon(icon, color: myWhiteColor),
        ),
        onPressed: onIconPressed,
      ),
    ]
        : [],
    flexibleSpace: Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.9),
            spreadRadius: 0.1,
            blurRadius: 4,
            offset: Offset(0, 0),
          ),
        ],
      ),
    ),
  );
}

void ShowLogoutTwoActionPupup_rewarola({
  required BuildContext context,
  required String title,
  required String message,
  String? leftButtonName,
  String? rightButtonName,
  VoidCallback? onLeftButtonPressed,
  VoidCallback? onRightButtonPressed,
}) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent dismissing by tapping outside
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        insetPadding: EdgeInsets.symmetric(horizontal: 16),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        if (leftButtonName != null)
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  onLeftButtonPressed?.call();
                                  print("Left button pressed: $leftButtonName");
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black87,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                child: Text(
                                  leftButtonName,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        if (rightButtonName != null)
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  onRightButtonPressed?.call();
                                  print("Right button pressed: $rightButtonName");
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black87,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                child: Text(
                                  rightButtonName,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

//reception app bar
AppBar customAppBarReception({
  required String title,
  required Color titleColor,
  Color backgroundColor = myAppColor,
  double elevation = 4.0,
  required Color appBarColor,
}) {
  return AppBar(
    backgroundColor: myBlackColor,
    elevation: 0,
    // Set to 0 to remove default shadow
    title: Text(
      title,
      style: TextStyle(
        color: titleColor,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    iconTheme: IconThemeData(
      color: titleColor,
    ),
    flexibleSpace: Container(
      decoration: BoxDecoration(
        color: myAppColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.9),
            spreadRadius: 0.1,
            blurRadius: 4,
            offset: Offset(0, 0),
          ),
        ],
      ),
    ),
  );
}

// TODO: push navigation - method
void pushViewController(BuildContext context, Widget screen) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => screen,
    ),
  );
}

// TODO: Bottom Center Button - share,
Widget bottomCenterButton({
  required BuildContext context,
  required String buttonText,
  required Color buttonColor,
  required double buttonWidth,
  required VoidCallback onPressed,
}) {
  return Align(
    alignment: Alignment.bottomCenter,
    child: Padding(
      padding:
      EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 25),
      child: SizedBox(
        width: buttonWidth,
        height: 40,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: Text(
            buttonText,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    ),
  );
}

// TODO: Permission denied alert
void showPermissionDeniedDialog(BuildContext context, String permissionType) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Permission Required"),
        content: Text(
            "Niwec does not have access to your $permissionType. To enable access, tap 'Settings' and turn on $permissionType."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // Open the app settings to allow the user to manually enable the permission
              await openAppSettings();
            },
            child: Text("Settings"),
          ),
        ],
      );
    },
  );
}

// TODO: Show OK alert
// Function to show alert
class AlertUtils {
  static void showOKAlert(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}

//ok alert method for any screen
/*
 // Function to show alert
  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
 */

// TODO: Get SnackBar custom with title and all
void showGetxSnackbar(String title, String message) {
  Get.snackbar(
    title,
    message,
    snackPosition: SnackPosition.TOP,
    backgroundColor: myWhiteColor.withOpacity(0.4),
    colorText: myWhiteColor,
    padding: EdgeInsets.all(16),
    margin: EdgeInsets.all(16),
    borderRadius: 10,
    boxShadows: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        spreadRadius: 4,
        blurRadius: 4,
      ),
    ],
    duration: Duration(seconds: 2),
    animationDuration: Duration(milliseconds: 500),
    isDismissible: true,
    //dismissDirection: SnackDismissDirection.HORIZONTAL,
  );
}

//custom get x snackbar - position
void showGetxSnackbarCustom({
  required String title,
  required String message,
  SnackPosition snackPosition = SnackPosition.BOTTOM,
}) {
  Get.snackbar(
    title,
    message,
    snackPosition: snackPosition,
    backgroundColor: Colors.grey[800],
    colorText: Colors.white,
    borderRadius: 10,
    margin: EdgeInsets.all(10),
    snackStyle: SnackStyle.FLOATING,
    duration: Duration(seconds: 2),
  );
}

// TODO: OK action alert - only ok button with action
// Define a global function for showing dialogs
//used at otp controller on otp send successfully alert
void OKAlertWithAction({
  required BuildContext context,
  required String title,
  required String message,
  required VoidCallback onOkPressed,
}) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevents dismissal when tapping outside
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop(); // Dismiss the dialog
            },
          ),
          TextButton(
            child: Text("OK"),
            onPressed: () {
              Navigator.of(context).pop(); // Dismiss the dialog
              onOkPressed(); // Execute the action after dismissing
            },
          ),
        ],
      );
    },
  );
}

void OnlyOKAlertWithAction({
  required BuildContext context,
  required String title,
  required String message,
  required VoidCallback onOkPressed,
}) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevents dismissal when tapping outside
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          // TextButton(
          //   child: Text("Cancel"),
          //   onPressed: () {
          //     Navigator.of(context).pop(); // Dismiss the dialog
          //   },
          // ),
          TextButton(
            child: Text("OK"),
            onPressed: () {
              Navigator.of(context).pop(); // Dismiss the dialog
              onOkPressed(); // Execute the action after dismissing
            },
          ),
        ],
      );
    },
  );
}

// TODO: show OK alert only
void OKAlertOnly({
  required BuildContext context,
  required String title,
  required String message,
}) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevents dismissal when tapping outside
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold), // Optional: Add styles
        ),
        content: Text(
          message,
          style: TextStyle(fontSize: 16), // Optional: Add styles
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              "OK",
              style: TextStyle(color: Colors.blue), // Optional: Add styles
            ),
            onPressed: () {
              Navigator.of(context).pop(); // Dismiss the dialog
            },
          ),
        ],
      );
    },
  );
}

// TODO: Get Snackbar method to show info or failed api

class SnackbarUtil {
  // Global method to show snackbar
  static void showSnackbar(String title, String message,
      {Duration duration = const Duration(seconds: 3),
        SnackPosition position = SnackPosition.BOTTOM}) {
    Get.snackbar(
      title,
      message,
      duration: duration,
      snackPosition: position,
    );
  }
}

//date formater
String formatDate(String date) {
  DateTime parsedDate = DateTime.parse(date);
  return DateFormat('dd-MM-yyyy').format(parsedDate);
}

///responsive screen size wise width adobpter
// responsive_wrapper.dart

class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final Color backgroundColor;

  const ResponsiveWrapper({
    Key? key,
    required this.child,
    this.maxWidth = 600, // Default max width, adjust as needed
    this.backgroundColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}

// TODO: To Print full response of the api in console
//this only prints the file path where it saves response into txt format
// Future<void> logToFile(String data) async {
//   final directory = await getApplicationDocumentsDirectory();
//   final file = File('${directory.path}/response_log.txt');
//   await file.writeAsString(data);
//   print('Response logged to file: ${file.path}');
// }
//usage
// logToFile(apiResponse); // Replace `apiResponse` with your actual response data

//this prints the data fully data
//    debugPrint(apiResponse, wrapWidth: 1024); // Replace `apiResponse` with your actual response data

//go to website - browerser launch
//launch url - go to kvk
// Function to open a URL in the browser
// Function to open a URL in the browser
Future<void> gotowebsite(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

// TODO: logout global method
// Global logout method

Future<void> logoutUser(BuildContext context) async {

  final prefs = await SharedPreferences.getInstance();

  // Update session data to empty strings and false
  await prefs.setBool(IS_LOGIN, false);
  await prefs.setString(USER_ID, '0');
  await prefs.setString(JWT_TOKEN, '');
  await prefs.setString(USER_ROLE, '');
  await prefs.setString(USER_EMAIL, '');
  await prefs.setString(USER_FIRST_NAME, '');
  await prefs.setString(USER_MOBILE, '');




  // Navigate to the TabBarUserSCreen and replace the current screen
 // Get.offAll(() => MainLoginScreen());




}

Future<void> logoutUser2(BuildContext context) async {
  // Get SharedPreferences instance
  final prefs = await SharedPreferences.getInstance();

  // Update session data to empty strings and false
  await prefs.setBool(IS_LOGIN, false);
  await prefs.setString(USER_ID, '0');
  await prefs.setString(JWT_TOKEN, '');
  await prefs.setString(USER_ROLE, '');
  await prefs.setString(USER_EMAIL, '');
  await prefs.setString(USER_FIRST_NAME, '');
  await prefs.setString(USER_MOBILE, '');


  // Navigate to TabBarUserScreen and remove all previous routes
  if (context.mounted) {
    // Navigator.of(context).pushAndRemoveUntil(
    //   MaterialPageRoute(builder: (context) => TabBarUserSCreen()),
    //       (route) => false,
    // );
  }
}

// TODO: reward ola customisex designed alerts - just like we have in ionic
//only ok alert - called at signup successfull
void ShowOnlyOKPopu_rewardold({
  required BuildContext context,
  required String title,
  required String message,
  required VoidCallback onOkPressed,
}) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent dismissing by tapping outside
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        insetPadding: EdgeInsets.symmetric(horizontal: 16),
        // Horizontal padding
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height *
                0.7, // Max height is 80% of screen
          ),
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Title (Centered at the top, multiline)
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20), // Spacing between title and message
                  // Message (Multiline)
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 20), // Spacing between message and button
                  // OK Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Dismiss the popup
                        onOkPressed(); // Execute the provided action
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text(
                        "OK",
                        style: TextStyle(color: Colors.white),
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
  );
}

//two btn action alert - called at user already signed in drawer menu
void ShowTwoActionPupup_rewarola({
  required BuildContext context,
  required String title,
  required String message,
  String? leftButtonName,
  String? rightButtonName,
  VoidCallback? onLeftButtonPressed,
  VoidCallback? onRightButtonPressed,
}) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent dismissing by tapping outside
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        insetPadding: EdgeInsets.symmetric(horizontal: 16),
        // Horizontal padding
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height *
                0.7, // Max height is 80% of screen
          ),
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Title (Centered at the top, multiline)
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20), // Spacing between title and message
                  // Message (Multiline)
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 20), // Spacing between message and buttons
                  // Buttons Row
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    // Spacing from sides
                    child: Row(
                      children: [
                        // Left Button
                        if (leftButtonName != null)
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(right: 10),
                              // Spacing between buttons
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Dismiss the popup
                                  onLeftButtonPressed
                                      ?.call(); // Execute left button action
                                  print(
                                      "Left button pressed: $leftButtonName"); // Print statement
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black87,
                                  // Customize color
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                child: Text(
                                  leftButtonName,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        // Right Button
                        if (rightButtonName != null)
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: 10),
                              // Spacing between buttons
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Dismiss the popup
                                  onRightButtonPressed
                                      ?.call(); // Execute right button action
                                  print(
                                      "Right button pressed: $rightButtonName"); // Print statement
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black87,
                                  // Customize color
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                child: Text(
                                  rightButtonName,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}




//api call status code get x snackbar
/* standart left align
void showGetxSnackbarCustom_forapicallstatuscode({
  required String title,
  required String message,
  required Color backgrounColor,
  SnackPosition snackPosition = SnackPosition.TOP,
}) {
  Get.snackbar(
    title,
    message,
    snackPosition: snackPosition,
    backgroundColor: backgrounColor,
    colorText: Colors.white,
    borderRadius: 10,
    margin: EdgeInsets.all(10),
    snackStyle: SnackStyle.FLOATING,
    duration: Duration(seconds: 2),
  );
}


 */

//customer centere text getx snackbar
void showGetxSnackbarCustom_forapicallstatuscode({
  required String title,
  required String message,
  required Color backgrounColor,
  SnackPosition snackPosition = SnackPosition.TOP,
}) {
  Get.snackbar(
    '', // Empty title (we'll use custom titleText instead)
    '', // Empty message (we'll use custom messageText instead)
    snackPosition: snackPosition,
    backgroundColor: backgrounColor,
    colorText: Colors.white,
    borderRadius: 10,
    margin: EdgeInsets.all(10),
    snackStyle: SnackStyle.FLOATING,
    duration: Duration(seconds: 2),
    titleText: Center(
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16, // Adjust font size
          fontWeight: FontWeight.w600, // Bold title
          color: Colors.white, // Text color
        ),
      ),
    ),
    messageText: Center(
      child: Text(
        message,
        style: TextStyle(
          fontSize: 18, // Adjust font size
          fontWeight: FontWeight.bold, // Normal message font weight
          color: Colors.white, // Text color
        ),
      ),
    ),
  );
}

//url image validty checker
// Helper method to validate URL
Future<bool> _validateUrl(String url) async {
  try {
    final uri = Uri.parse(url);
    return uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https');
  } catch (e) {
    return false;
  }
}

// TODO: laumnch url and phone numebr
//community details screen - call and map icon
Future<void> launchUrlDirect(String url, {bool isPhoneNumber = false}) async {
  final String link = url ?? "";
  if (link.isNotEmpty) {
    final String formattedUrl = isPhoneNumber ? "tel:$link" : link;

    if (await canLaunch(formattedUrl)) {
      await launch(formattedUrl);
    } else {
      print("Failed to launch URL: $formattedUrl");
      showGetxSnackbarCustom_forapicallstatuscode(title: 'Can not Open', message: 'Invalid Link Address', backgrounColor: infoGrayColor);
    }
  }
}


