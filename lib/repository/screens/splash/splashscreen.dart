import 'dart:async';
import 'package:flutter/material.dart';
import 'package:psychics/repository/PsychicProfile/PsychicProfileSetupScreen.dart';
import 'package:psychics/repository/screens/Bottomnav/MainNavigationScreen.dart';
import 'package:psychics/repository/screens/Bottomnav/PsychicMainNavigation.dart';
import 'package:psychics/repository/screens/login/loginscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/uihelper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 500), _checkLoginStatus);
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString("token");
    String? role = prefs.getString("role");  // ← ROLE CHECK

    // 🔥 User logged in → Navigate based on ROLE
    if (token != null && token.isNotEmpty) {
      if (role == "psychic") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PsychicMainNavigation(
              profileScreen: const PsychicProfileSetupScreen(),  // ← ADD THIS
            ),
          ),
        );

      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigationScreen(initialIndex: 0)),
        );
      }
      return;
    }

    // ❌ No login → Go to Login Page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              "assets/images/edd52422740db294cfef5ab313779b90a2a88514.jpg",
            ),
            fit: BoxFit.cover,
          ),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 150,
              width: 150,
              child: UiHelper.CustomImage(
                img: "3b30cd31745f88c5830e88e61df25ab48c38227a.png",
              ),
            ),

            const SizedBox(height: 30),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Unlock the secrets the universe holds for you",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
