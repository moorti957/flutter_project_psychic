// FreelancerProfileScreen.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:psychics/repository/screens/Bottomnav/MainNavigationScreen.dart';
import 'package:psychics/repository/screens/Bottomnav/PsychicMainNavigation.dart';
import 'package:psychics/repository/screens/Dashboard/PsychicDashboardScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FreelancerProfileScreen extends StatefulWidget {
  final String name;
  final String about;
  final String price;
  final String experience;
  final String category;
  final List<String> skills;
  final List<String> ability;
  final List<String> tools;
  final List<String> languages;
  final File? image;

  const FreelancerProfileScreen({
    super.key,
    required this.name,
    required this.about,
    required this.price,
    required this.experience,
    required this.category,
    required this.skills,
    required this.ability,
    required this.tools,
    required this.languages,
    required this.image,
  });

  @override
  State<FreelancerProfileScreen> createState() =>
      _FreelancerProfileScreenState();
}

// Expand flags
bool expandSkills = false;
bool expandAbility = false;
bool expandTools = false;

class _FreelancerProfileScreenState extends State<FreelancerProfileScreen>
    with SingleTickerProviderStateMixin {
  int selectedTab = 0;

  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    loadSavedImage();
  }

  /// Load profile image from SharedPreferences and normalize to full URL if needed.
  void loadSavedImage() async {
    final prefs = await SharedPreferences.getInstance();
    String? raw = prefs.getString("profile_image");

    if (raw == null || raw.isEmpty) {
      setState(() => profileImageUrl = null);
      debugPrint("No saved profile_image in prefs");
      return;
    }

    String normalized = raw;

    // If saved value isn't a fully qualified URL, build the expected absolute URL
    if (!normalized.startsWith("http")) {
      normalized = "https://psychicbelive.mapps.site/uploads/users/${normalized.replaceFirst(RegExp(r'^/'), '')}";
    }

    debugPrint("Loaded profile image from prefs -> $normalized");

    setState(() => profileImageUrl = normalized);
  }

  // UPDATE API
  Future<void> updatePsychicProfile() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Saving profile...")),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Token missing, please login again")),
        );
        return;
      }

      var url = Uri.parse("https://psychicbelive.mapps.site/api/userupdate");

      var request = http.MultipartRequest("POST", url);
      request.fields["_method"] = "PUT";

      request.headers["Authorization"] = "Bearer $token";
      request.headers["Accept"] = "application/json";

      // TEXT DATA
      request.fields["display_name"] = widget.name;
      request.fields["bio"] = widget.about;
      request.fields["price_per_minute"] = widget.price;
      request.fields["experience_years"] = widget.experience;
      request.fields["category"] = widget.category;

      request.fields["skills"] = widget.skills.join(",");
      request.fields["ability"] = widget.ability.join(",");
      request.fields["tools"] = widget.tools.join(",");
      request.fields["languages"] = widget.languages.join(",");

      request.fields["online_status"] = "1";

      // IMAGE
      if (widget.image != null) {
        request.files.add(await http.MultipartFile.fromPath(
          "image",
          widget.image!.path,
        ));
      }

      // 🔥 API CALL
      var response = await request.send();
      var body = await response.stream.bytesToString();

      debugPrint("UPDATE STATUS = ${response.statusCode}");
      debugPrint("UPDATE RESPONSE = $body");

      if (response.statusCode == 200) {
        final data = jsonDecode(body);

        // Extract image value from response (several possible keys)
        String? imageUrl =
            data["data"]?["image"] ?? data["data"]?["profile_photo"] ?? data["data"]?["image_url"];

        if (imageUrl != null && imageUrl.isNotEmpty) {
          // Normalize into a full URL if it's a filename
          String normalized = imageUrl;
          if (!normalized.startsWith("http")) {
            normalized =
            "https://psychicbelive.mapps.site/uploads/users/${normalized.replaceFirst(RegExp(r'^/'), '')}";
          }

          await prefs.setString("profile_image", normalized);
          debugPrint("Saved normalized profile_image to prefs -> $normalized");

          // Update displayed image immediately
          setState(() => profileImageUrl = normalized);
        }

        // Success toast
        Fluttertoast.showToast(
          msg: "Profile Saved Successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          fontSize: 16.0,
        );

        // Move to dashboard
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => PsychicMainNavigation(
              profileScreen: const PsychicDashboardScreen(),
            ),
          ),
              (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $body")),
        );
      }
    } catch (e) {
      debugPrint("updatePsychicProfile error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  // TAB BUTTON
  Widget tabButton(String text, int index) {
    bool active = selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? Colors.deepPurple : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: active ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // EXPANDABLE SECTION
  Widget expandableSection({
    required String title,
    required List<String> items,
    required bool expanded,
    required Function() onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              Icon(
                expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                size: 28,
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        if (expanded)
          Column(
            children: items
                .map(
                  (e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.deepPurple),
                    const SizedBox(width: 8),
                    Expanded(child: Text(e)),
                  ],
                ),
              ),
            )
                .toList(),
          ),
        const SizedBox(height: 12),
        Divider(color: Colors.grey.shade300),
        const SizedBox(height: 12),
      ],
    );
  }

  // ABOUT TAB
  Widget aboutTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.deepPurple,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("About Me", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Text(widget.about, style: const TextStyle(fontSize: 15, height: 1.4)),
          const SizedBox(height: 20),
          expandableSection(
            title: "Specialities",
            items: widget.skills,
            expanded: expandSkills,
            onToggle: () => setState(() => expandSkills = !expandSkills),
          ),
          expandableSection(
            title: "Abilities",
            items: widget.ability,
            expanded: expandAbility,
            onToggle: () => setState(() => expandAbility = !expandAbility),
          ),
          expandableSection(
            title: "Tools",
            items: widget.tools,
            expanded: expandTools,
            onToggle: () => setState(() => expandTools = !expandTools),
          ),
        ],
      ),
    );
  }

  Widget projectTab() => const Center(
    child: Text("No users added yet", style: TextStyle(color: Colors.grey, fontSize: 16)),
  );

  Widget reviewTab() => const Center(
    child: Text("No reviews yet", style: TextStyle(color: Colors.grey, fontSize: 16)),
  );

  // UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // FULL SCREEN WHITE
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              const SizedBox(height: 10),
              const SizedBox(height: 10),

              // CARD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // ===== SAFE PROFILE IMAGE WIDGET =====
                        Container(
                          height: 90,
                          width: 90,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Colors.grey.shade200,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: widget.image != null
                                ? Image.file(
                              widget.image!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            )
                                : (profileImageUrl != null && profileImageUrl!.isNotEmpty
                                ? Image.network(
                              profileImageUrl!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  alignment: Alignment.center,
                                  child: const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                debugPrint('Profile image load error: $error');
                                return Container(
                                  color: Colors.grey.shade200,
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.person, size: 42, color: Colors.grey),
                                );
                              },
                            )
                                : Container(
                              color: Colors.grey.shade200,
                              alignment: Alignment.center,
                              child: const Icon(Icons.person, size: 42, color: Colors.grey),
                            )),
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.name,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 6),
                              Text(widget.category, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        tabButton("About", 0),
                        const SizedBox(width: 10),
                        tabButton("Projects", 1),
                        const SizedBox(width: 10),
                        tabButton("Reviews", 2),
                      ],
                    ),

                    const SizedBox(height: 20),

                    if (selectedTab == 0) aboutTab(),
                    if (selectedTab == 1) projectTab(),
                    if (selectedTab == 2) reviewTab(),

                    const SizedBox(height: 20),

                    // Confirm Profile Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: updatePsychicProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("Confirm Profile", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
