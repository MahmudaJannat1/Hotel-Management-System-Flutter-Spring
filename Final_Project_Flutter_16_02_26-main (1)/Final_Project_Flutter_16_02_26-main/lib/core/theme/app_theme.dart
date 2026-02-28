// import 'package:flutter/material.dart';
//
// class AppTheme {
//   static ThemeData lightTheme = ThemeData(
//     primarySwatch: Colors.blue,
//     brightness: Brightness.light,
//     scaffoldBackgroundColor: Colors.grey[50],
//     appBarTheme: AppBarTheme(
//       elevation: 0,
//       color: Colors.white,
//       iconTheme: IconThemeData(color: Colors.black),
//       titleTextStyle: TextStyle(
//         color: Colors.black,
//         fontSize: 20,
//         fontWeight: FontWeight.w600,
//       ),
//     ),
//     elevatedButtonTheme: ElevatedButtonThemeData(
//       style: ElevatedButton.styleFrom(
//         padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//       ),
//     ),
//     inputDecorationTheme: InputDecorationTheme(
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//       ),
//       filled: true,
//       fillColor: Colors.grey[100],
//     ),
//   );
//
//   static ThemeData darkTheme = ThemeData(
//     primarySwatch: Colors.blue,
//     brightness: Brightness.dark,
//     scaffoldBackgroundColor: Colors.grey[900],
//     appBarTheme: AppBarTheme(
//       elevation: 0,
//       color: Colors.grey[800],
//     ),
//   );
// }



import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.grey[50],
    appBarTheme: AppBarTheme(
      elevation: 0,
      color: Colors.white,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,        // ✅ ব্যাকগ্রাউন্ড কালার
        foregroundColor: Colors.white,        // ✅ টেক্সট কালার (সাদা)
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
      fillColor: Colors.grey[100],
    ),
  );

  static ThemeData darkTheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.grey[900],
    appBarTheme: AppBarTheme(
      elevation: 0,
      color: Colors.grey[800],
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade700,  // ✅ ডার্ক থিমের জন্য
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );
}