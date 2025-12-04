import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyProfileSettingsScreen extends StatelessWidget {
  const MyProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> options = [
      "FAQ",
      "Feedback & Support",
      "Terms & Conditions",
      "Privacy Policy",
      "About Us",
      "Contact Us"
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔹 Settings List
            ...options.map((title) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 3)
                ],
              ),
              child: ExpansionTile(
                title: Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                trailing: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: Colors.black54),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      "This is a dummy description for $title.",
                      style: const TextStyle(
                          color: Colors.black54, fontSize: 13),
                    ),
                  ),
                ],
              ),
            )),

            const SizedBox(height: 20),

            // ✅ Corrected Logout Button
            ElevatedButton.icon(
              onPressed: () async {
                final bool? confirm = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Logout"),
                    content: const Text("Are you sure you want to logout?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Logout",
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  try {
                    await FirebaseAuth.instance.signOut();

                    // ✅ Now show confirmation
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Logged out successfully"),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );

                    // ✅ After short delay, pop all screens
                    Future.delayed(const Duration(seconds: 1), () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Logout failed: $e")),
                    );
                  }
                }
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                "Logout",
                style: TextStyle(
                    color: Colors.red, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding:
                const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
              ),
            ),

            const SizedBox(height: 25),

            // 🔹 Social Links
            const Text("Follow us on",
                style: TextStyle(
                    color: Colors.black87, fontWeight: FontWeight.w600)),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                FaIcon(FontAwesomeIcons.facebook,
                    color: Colors.blue, size: 28),
                SizedBox(width: 20),
                FaIcon(FontAwesomeIcons.instagram,
                    color: Colors.pinkAccent, size: 28),
                SizedBox(width: 20),
                FaIcon(FontAwesomeIcons.twitter,
                    color: Colors.lightBlue, size: 28),
                SizedBox(width: 20),
                FaIcon(FontAwesomeIcons.pinterest,
                    color: Colors.red, size: 28),
              ],
            ),
            const SizedBox(height: 15),
            const Text("App version 7.0",
                style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
