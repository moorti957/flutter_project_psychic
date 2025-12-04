
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:psychics/repository/screens/CustomerSupport/CustomerSupportScreen.dart';
import 'package:psychics/repository/screens/MyProfile/MyProfileScreen.dart';
import 'package:psychics/repository/screens/MyProfile/NotificationScreen.dart';
import 'package:psychics/repository/screens/login/loginscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {

  // Local user data
  String userName = "User";
  String userPhone = "";
  String? userPhoto;

  @override
  void initState() {
    super.initState();
    _loadLocalUserData();
  }

  Future<void> _loadLocalUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      userName = prefs.getString("user_name") ?? "User";
      userPhone = prefs.getString("user_phone") ?? "";
      userPhoto = prefs.getString("user_photo");   // future-proof if you save photo
    });
  }

  String getInitials(String name) {
    if (name.trim().isEmpty) return "U";
    List<String> parts = name.trim().split(" ").where((e) => e.isNotEmpty).toList();
    return parts.map((e) => e[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: Colors.white,
        child: Container(
          width: screenWidth * 0.7,
          color: Colors.white,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ---------------- PROFILE SECTION ----------------
                  Row(
                    children: [
                      _buildProfileAvatar(),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userPhone,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // ---------------- MENU ITEMS ----------------
                  _buildItem(
                    context,
                    Icons.person_outline,
                    "My Profile",
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MyProfileScreen()),
                      );
                      _loadLocalUserData();
                    },
                  ),

                  _buildItem(context, Icons.history, "Order History"),

                  _buildItem(
                    context,
                    Icons.support_agent_outlined,
                    "Customer Support",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CustomerSupportScreen()),
                      );
                    },
                  ),

                  _buildItem(
                    context,
                    Icons.feedback_outlined,
                    "Send Feedback",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const NotificationScreen()),
                      );
                    },
                  ),

                  _buildItem(context, Icons.star_border, "Rate Us"),
                  _buildItem(context, Icons.share_outlined, "Share"),

                  const SizedBox(height: 10),

                  // ---------------- LOGOUT BUTTON ----------------
                  InkWell(
                    onTap: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.clear();

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false,
                      );
                    },
                    child: Row(
                      children: const [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 10),
                        Text(
                          "Logout",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // ---------------- SOCIAL ICONS ----------------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      FaIcon(FontAwesomeIcons.whatsapp,
                          color: Colors.green, size: 28),
                      FaIcon(FontAwesomeIcons.instagram,
                          color: Colors.pinkAccent, size: 28),
                      FaIcon(FontAwesomeIcons.facebook,
                          color: Colors.blue, size: 28),
                      FaIcon(FontAwesomeIcons.youtube,
                          color: Colors.red, size: 28),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Center(
                    child: Column(
                      children: [
                        Text(
                          "Follow us and we will follow you back",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Version: 2.0.3",
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- AVATAR BUILDER ----------------
  Widget _buildProfileAvatar() {
    if (userPhoto != null && userPhoto!.isNotEmpty) {
      return CircleAvatar(
        radius: 26,
        backgroundColor: Colors.grey.shade200,
        backgroundImage: NetworkImage(userPhoto!),
      );
    } else {
      return CircleAvatar(
        radius: 26,
        backgroundColor: Colors.purple.shade200,
        child: Text(
          getInitials(userName),
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  Widget _buildItem(BuildContext context, IconData icon, String title,
      {VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 22, color: Colors.black87),
              const SizedBox(width: 16),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
