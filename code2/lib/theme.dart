import 'package:code2/models/demensions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color primaryColor100 = Color(0xffbcdaff);
const Color primaryColor300 = Color(0xff88aad6);
const Color primaryColor500 = Color(0xFF89dad0);
const Color primaryColor200 = Color(0xFF69c5df);
const Color primaryColor400 = Color(0xFF9294cc);
const Color colorWhite = Colors.white;
const Color colorRed = Colors.red;
const Color backgroundColor = Color(0xffF5F9FF);
const Color orangesColor = Color(0xFFFFA500);
const Color lightBlue100 = Color(0xffF0F6FF);
const Color lightBlue300 = Color(0xffD2DFF0);
const Color lightBlue400 = Color(0xffBFC8D2);
const Color mainBlackColor = Color(0xFF332d2b);
const Color darkBlue500 = Color(0xff293948);
const Color darkBlue300 = Color(0xff526983);
const Color darkBlue700 = Color(0xff17212B);
double borderRadiusSize = Demensions.radius16;
const double borderRadiusSize1 = 16;

TextStyle titleTextStyle = GoogleFonts.poppins(
    fontSize: 18, fontWeight: FontWeight.w700, color: darkBlue500);

TextStyle titleTextStyle1 = GoogleFonts.poppins(
    fontSize: 16, fontWeight: FontWeight.w700, color: darkBlue500);

TextStyle subTitleTextStyle = GoogleFonts.poppins(
    fontSize: 16, fontWeight: FontWeight.w500, color: darkBlue500);

TextStyle normalTextStyle = GoogleFonts.poppins(color: darkBlue500);

TextStyle descTextStyle = GoogleFonts.poppins(
    fontSize: 14, fontWeight: FontWeight.w400, color: mainBlackColor);

TextStyle descTextStyle1 = GoogleFonts.poppins(
    fontSize: Demensions.font20,
    fontWeight: FontWeight.w700,
    color: primaryColor500);

TextStyle descTextStyle2 = GoogleFonts.poppins(
    fontSize: Demensions.font20,
    fontWeight: FontWeight.w400,
    color: Colors.black26);

TextStyle descTextStyle3 = GoogleFonts.poppins(
    fontSize: 10, fontWeight: FontWeight.w400, color: mainBlackColor);

TextStyle descTextStyle4 = GoogleFonts.poppins(
    fontSize: Demensions.font26,
    fontWeight: FontWeight.w700,
    color: primaryColor500);

TextStyle descTextStyle6 = GoogleFonts.poppins(
    fontSize: Demensions.font16,
    fontWeight: FontWeight.w700,
    color: primaryColor500);

TextStyle descTextStyle5 = GoogleFonts.poppins(
    fontSize: Demensions.font20,
    fontWeight: FontWeight.w700,
    color: mainBlackColor);

TextStyle descTextStyle7 = GoogleFonts.poppins(
    fontSize: Demensions.font20,
    fontWeight: FontWeight.w700,
    color: Colors.red);

TextStyle descTextStyle8 = GoogleFonts.poppins(
    fontSize: 25, fontWeight: FontWeight.w400, color: mainBlackColor);

TextStyle descTextStyle9 = GoogleFonts.poppins(
    fontSize: Demensions.font20 + Demensions.font20 / 2,
    fontWeight: FontWeight.w700,
    color: colorWhite);

TextStyle addressTextStyle = GoogleFonts.poppins(
    fontSize: 14, fontWeight: FontWeight.w400, color: mainBlackColor);

TextStyle priceTextStyle = GoogleFonts.poppins(
    fontSize: 16, fontWeight: FontWeight.w700, color: darkBlue500);

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}
