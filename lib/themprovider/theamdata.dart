import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
    // **Modern, eye-pleasing base:**
    brightness: Brightness.light,
    primaryColor: Color.fromARGB(255, 66, 235, 0), // Deep sky blue, vibrant and calming
    hintColor: Color(0xFFf39c12), // Orange, for subtle accents
    scaffoldBackgroundColor: Colors.white, // Light background

    // **Enhanced text readability:**
    textTheme: TextTheme(
        bodyText1: TextStyle(color: Colors.black87), // Clear, dark text
        bodyText2: TextStyle(color: Colors.black54), // Slightly muted text
    ),

    // **Improved contrast and accessibility:**
    appBarTheme: AppBarTheme(
        iconTheme: IconThemeData(color: Colors.black87), // Dark icons for better contrast
    ),
   

    // **Optional: Subtle shadows for depth:**
    // shadowColor: Colors.grey[200], // Adjust as needed
);

ThemeData darkTheme = ThemeData(
    // **Elegant and subdued base:**
    brightness: Brightness.dark,
    primaryColor: Color(0xFF82b366), // Sea green, soothing and balanced
    hintColor: Color(0xFFf9c74f), // Light yellow, for subtle accents
    scaffoldBackgroundColor: const Color.fromARGB(255, 39, 39, 39), // Dark background

    // **Ensured text visibility:**
    textTheme: TextTheme(
        bodyText1: TextStyle(color: Color.fromARGB(255, 0, 0, 0)), // White text for dark backgrounds
        bodyText2: TextStyle(color: Colors.white70), // Slightly lighter text
    ),

    // **Maintained good contrast:**
    appBarTheme: AppBarTheme(
        iconTheme: IconThemeData(color: Color.fromARGB(255, 255, 255, 255)), // Light icons for contrast
    ),
   

    // **Optional: Consider subtle highlights for elements:**
    // highlightColor: Colors.grey[600], // Adjust as needed
);

