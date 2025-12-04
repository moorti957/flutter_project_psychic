import 'dart:convert';
import 'dart:ui';
// import 'package:demopro/repository/screens/Psychic/PsychicDashboardScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:psychics/repository/screens/Dashboard/PsychicDashboardScreen.dart';
import 'package:psychics/repository/screens/login/loginscreen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool isUser = true;
  bool isPsychic = false;
  String selectedRole = "User";

  bool isLoading = false;

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

  // ----------------- API SIGNUP -----------------
  Future<void> signUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      showMessage("⚠️ Please fill all fields");
      return;
    }

    if (password != confirm) {
      showMessage("❌ Passwords do not match");
      return;
    }

    selectedRole = isPsychic ? "psychic" : "client";

    setState(() => isLoading = true);

    final url = Uri.parse("https://psychicbelive.mapps.site/api/register");
    final payload = {
      "name": name,
      "email": email,
      "password": password,
      "role": selectedRole,
    };

    try {
      final response = await http
          .post(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: json.encode(payload),
      )
          .timeout(const Duration(seconds: 10));

      debugPrint("SIGNUP (json) status: ${response.statusCode}");
      debugPrint("SIGNUP (json) body: ${response.body}");

      Map<String, dynamic>? data;
      try {
        data = json.decode(response.body);
      } catch (_) {
        data = null;
      }

      if (response.statusCode == 200 && data != null && data["status"] == true) {
        setState(() => isLoading = false);

        showMessage(data["message"] ?? "🎉 Account created successfully!");

        // ***************** ROLE BASED NAVIGATION *****************
        if (selectedRole == "psychic") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const PsychicDashboardScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
        return;
      }

      // fallback
      final fallbackResp = await http
          .post(
        url,
        headers: {
          "Accept": "application/json",
        },
        body: payload,
      )
          .timeout(const Duration(seconds: 10));

      debugPrint("SIGNUP (form) status: ${fallbackResp.statusCode}");
      debugPrint("SIGNUP (form) body: ${fallbackResp.body}");

      Map<String, dynamic>? fallbackData;
      try {
        fallbackData = json.decode(fallbackResp.body);
      } catch (_) {
        fallbackData = null;
      }

      setState(() => isLoading = false);

      if (fallbackResp.statusCode == 200 &&
          fallbackData != null &&
          fallbackData["status"] == true) {
        showMessage(fallbackData["message"] ?? "🎉 Account created successfully!");

        // ************** ROLE BASED NAVIGATION **************
        if (selectedRole == "Psychic") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const PsychicDashboardScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
        return;
      }

      final serverMessage =
          (fallbackData?["message"]) ?? (data?["message"]) ?? "Registration Failed!";
      showMessage(serverMessage.toString());
    } catch (e) {
      debugPrint("SIGNUP ERROR: $e");
      setState(() => isLoading = false);
      showMessage("❌ Something went wrong!");
    }
  }

  // ----------------- UI -----------------
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
                    color: Colors.white.withOpacity(0.15),
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

                      const SizedBox(height: 25),

                      _inputBox("Enter Full Name", _nameController),
                      const SizedBox(height: 15),

                      _inputBox("Enter Email Id", _emailController),
                      const SizedBox(height: 15),

                      _inputBox("Enter Password", _passwordController, obscure: true),
                      const SizedBox(height: 15),

                      _inputBox("Confirm Password", _confirmController, obscure: true),
                      const SizedBox(height: 20),

                      const Text(
                        "Select Role",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: isUser,
                                onChanged: (val) {
                                  setState(() {
                                    isUser = true;
                                    isPsychic = false;
                                  });
                                },
                                checkColor: Colors.black,
                                activeColor: Colors.amber,
                              ),
                              const Text("User", style: TextStyle(color: Colors.white)),
                            ],
                          ),
                          const SizedBox(width: 20),

                          Row(
                            children: [
                              Checkbox(
                                value: isPsychic,
                                onChanged: (val) {
                                  setState(() {
                                    isPsychic = true;
                                    isUser = false;
                                  });
                                },
                                checkColor: Colors.black,
                                activeColor: Colors.amber,
                              ),
                              const Text("Psychic", style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

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
                          onPressed: isLoading ? null : signUp,
                          child: isLoading
                              ? const CircularProgressIndicator(color: Colors.black)
                              : const Text(
                            "Sign Up",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      OutlinedButton.icon(
                        icon: const Icon(Icons.mail_outline, color: Colors.white),
                        label: const Text(
                          "Already have an Account? Login",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                        },
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

  // ---------- INPUT BOX WIDGET ----------
  Widget _inputBox(String hint, TextEditingController controller,
      {bool obscure = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }
}
