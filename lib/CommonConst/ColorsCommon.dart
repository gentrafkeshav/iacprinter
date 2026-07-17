import 'package:flutter/material.dart';



//colors
const Color myAppColor = Colors.green; //dark blue // Color(0xFF1D3081); // Circle color //lite color -  //4D52CA // //web site logo color 1D3081
const Color myAppColorRed = Color(0xFFad1027); // light blue
const Color addBtnColor = myAppColor;// Color(0xFFad1027);

const Color myWhiteColor = Colors.white;
const Color infoGrayColor = Colors.black38;
const Color myBlackColor = Colors.black;
const Color myGreenColor = Color(0xFF94c96e); // app green color

//amc cards
//life membership
const Color amcLifeTopLeft = Color(0xFF678A99); // for #23627D
const Color amcLifeBottomRight = Color(0xFF23627D); // for #23627D

//screen background
const Color whiteScreen = Colors.white; // white backgroudn screen
const Color blueGreyScreen = Color(0xFFECEFF1); // Colors.blueGrey.shade50 // blue gray screen

   const Color screenBackgroundColor = blueGreyScreen; // blue gray screen
 //  const Color screenBackgroundColor = whiteScreen; // white screen

// TODO: Membership cards color - dark
//if #49302C is hex color - now to use it full opacity use this prefix - 0xFF
const Color donorCardColor = Color(0xFF49302C);
const Color lifeCardColor = Color(0xFF213D3F);
const Color patronCardColor = Color(0xFF4E6068);

const Color AssociateCardColor = Color(0xFF112a59);


//store cards color
final List<List<Color>> gradientPairs = [
  [Color(0xFFFFB347), Color(0xFFFFE0B2)],
  [Color(0xFF66BB6A), Color(0xFFC8E6C9)],
  [Color(0xFF42A5F5), Color(0xFFBBDEFB)],
  [Color(0xFFEC407A), Color(0xFFF8BBD0)],
  [Color(0xFF26C6DA), Color(0xFF80DEEA)], // Cyan to Light Cyan


  // [Color(0xFFFFCA28), Color(0xFFFFF59D)], // Amber to Light Amber
  // [Color(0xFF78909C), Color(0xFFCFD8DC)], // Blue Grey to Light Blue Grey
];


//colors
const Color myAppColorLight = Color(0xFF73bb20); // light blue

//getx snackbar error red color
const Color snackBarRedColor = Color(0xFFff1a15); //red background for snackbar
const Color snackBarGreenColor = Color(0xFF46b11d); // success green color











// TODO: common text styles

Text customListTitle({
  required String label,
  required double fontSize,
  required Color color,
  required bool isBold,
}) {
  return Text(
    label,
    style: TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
    ),
  );
}









