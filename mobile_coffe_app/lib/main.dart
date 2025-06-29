import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_coffe_app/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => myAppState();
}

class myAppState extends State<MyApp>{
  @override
  Widget build(BuildContext context){
    return const LoginPage();
  }
}