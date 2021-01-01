import 'package:flutter/material.dart';
import 'package:globalshop/views/Login/LoginPage.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.deepOrangeAccent),
      home: LoginPage(),
    ),
  );
}
