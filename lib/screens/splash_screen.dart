import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutterauth/provider/sign_in_provider.dart';
import 'package:flutterauth/screens/home_screen.dart';
import 'package:flutterauth/screens/login_screen.dart';
import 'package:flutterauth/utils/config.dart';
import 'package:provider/provider.dart';

import '../utils/next_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    final sp = context.read<SignInProvider>();
    super.initState();
    Timer(const Duration(seconds: 2), () {
      sp.isSignedIn == false
          ? nextScreen(context, const LoginScreen())
          : nextScreen(context, const HomeScreen());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Image(
            image: AssetImage(Config.app_icon),
            height: 80,
            width: 80,
          ),
        ),
      ),
    );
  }
}
