import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:psychics/repository/PsychicProfile/PsychicProfileSetupScreen.dart';
import 'package:psychics/repository/screens/Bottomnav/MainNavigationScreen.dart';
import 'package:psychics/repository/screens/Bottomnav/PsychicMainNavigation.dart';
import 'package:psychics/repository/screens/login/ForgotPasswordScreen.dart';
import 'package:psychics/repository/screens/login/SignUpScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();

}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  // 🔥 POPUP MESSAGE FUNCTION
  void showMessage(String msg) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            "Message",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Text(
            msg,
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "OK",
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }


  // 🌐 LOGIN with API
  Future<void> loginUser() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showMessage("Please enter email & password");
      return;
    }

    setState(() => isLoading = true);

    try {
      final url = Uri.parse("https://psychicbelive.mapps.site/api/login");

      final response = await http.post(
        url,
        headers: {"Accept": "application/json"},
        body: {"email": email, "password": password},
      );

      debugPrint("LOGIN status: ${response.statusCode}");
      debugPrint("LOGIN body: ${response.body}");

      Map<String, dynamic>? data;

      try {
        data = json.decode(response.body);
      } catch (e) {
        data = null;
      }

      setState(() => isLoading = false);

      if (data == null) {
        showMessage("Server error, try again!");
        return;
      }

      if ((data["status"] ?? false) != true) {
        showMessage(data["message"]?.toString() ?? "Invalid email or password");
        return;
      }

      // 🔥 SAVE TOKEN HERE
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", data["token"]);
      debugPrint("TOKEN SAVED = ${data["token"]}");

      // 🎉 Login Success → Check ROLE from API
      final String userRole =
      (data["user"]?["role"] ?? "").toString().toLowerCase();

      debugPrint("RAW ROLE = ${data["user"]?["role"]}");
      debugPrint("LOWER CASE ROLE = $userRole");
      await prefs.setString("role", userRole);


      if (userRole == "psychic") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PsychicProfileSetupScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const MainNavigationScreen(initialIndex: 0),
          ),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      showMessage("Something went wrong!");
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage("assets/images/edd52422740db294cfef5ab313779b90a2a88514.jpg"),
            fit: BoxFit.cover,
          ),
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.6),
              Colors.deepPurple.withOpacity(0.6),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),

            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),

              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),

                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.20),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24, width: 1),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const Text(
                        "Hi Welcome!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),

                      const Text(
                        "Psychics Believers Connection",
                        style: TextStyle(color: Colors.white70, fontSize: 18),
                      ),

                      const SizedBox(height: 25),

                      // Email Field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: "Enter Email Id",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Password Field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            hintText: "Enter Password",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: isLoading ? null : loginUser,
                          child: isLoading
                              ? const CircularProgressIndicator(color: Colors.black)
                              : const Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ForgotPasswordScreen()),
                            );
                          },
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SignUpScreen()),
                          );
                        },
                        child: const Text(
                          "Create a New Account",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
