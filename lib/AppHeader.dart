import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

import 'loginpage.dart'; // For navigation

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      toolbarHeight: 90.0, // Increased height
      title: Row(
        children: [
          // "IAC" Logo with bars
          _buildIACLogo(),
          SizedBox(width: 40), // Increased spacing before dashboard

          // Navigation Items
          _buildNavItem(Icons.qr_code, 'Generate QR Code'),
          Spacer(),

          // Welcome text and Icons
          Text(
            'Welcome IAC : 1.0.4+5 ',
            style: TextStyle(color: Colors.white, fontSize: 14), // Still smaller
          ),
          SizedBox(width: 12),
          Icon(Icons.description, color: Colors.white, size: 26), // Larger icon
          SizedBox(width: 12),
          GestureDetector(
            onTap: () => _showLogoutDialog(context),
            child: Icon(Icons.logout, color: Colors.white, size: 26),
          ),
        ],
      ),
    );
  }

  // Function to build "IAC" logo with horizontal bars
  Widget _buildIACLogo() {
    return Row(
      children: [
        Text(
          'IAC',
          style: TextStyle(
            fontSize: 28, // Larger text
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(width: 10), // Increased space between text and bars
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildBar(22),
                SizedBox(width: 4),
                _buildBar(22),
                SizedBox(width: 4),
                _buildDot(),
                SizedBox(width: 4),
                _buildDot(),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                _buildBar(18),
                SizedBox(width: 4),
                _buildBar(18),
                SizedBox(width: 4),
                _buildBar(18),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                _buildBar(22),
                SizedBox(width: 4),
                _buildDot(),
                SizedBox(width: 4),
                _buildDot(),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // Function to create a horizontal bar
  Widget _buildBar(double width) {
    return Container(
      width: width,
      height: 5, // Thicker bars
      color: Colors.white,
    );
  }

  // Function to create a dot
  Widget _buildDot() {
    return Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }

  // Function to create a navigation item
  Widget _buildNavItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12), // More spacing
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 26), // Larger icons
          SizedBox(height: 4),
          Text(
            text,
            style: TextStyle(color: Colors.white, fontSize: 14), // Larger text
          ),
        ],
      ),
    );
  }

  // Function to show logout confirmation dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog on cancel
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Clear SharedPreferences
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                print('SharedPreferences cleared');



               Get.offAll(LoginScreen());
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(90.0); // Increased height
}

