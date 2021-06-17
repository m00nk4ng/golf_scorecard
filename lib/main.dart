import 'package:flutter/material.dart';
import 'package:golf_scorecard/ui/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ThemeData brightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.grey[50],
    primarySwatch: Colors.green,
  );
  final ThemeData darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: Color.fromRGBO(32, 44, 34, 1.0),
  );

  @override
  Widget build(BuildContext context) {
    SharedPreferences.getInstance();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Golf Scorecard',
      theme: brightTheme,
      home: HomeScreen(),
    );
  }
}
