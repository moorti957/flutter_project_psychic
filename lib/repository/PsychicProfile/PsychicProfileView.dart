import 'dart:io';
import 'package:flutter/material.dart';

class PsychicProfileView extends StatelessWidget {
  final String name;
  final String about;
  final String category;
  final String price;
  final List<String> skills;
  final File? image;

  const PsychicProfileView({
    super.key,
    required this.name,
    required this.about,
    required this.category,
    required this.price,
    required this.skills,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text("Psychic Profile"),
        backgroundColor: Colors.blue,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            // 🔥 PROFILE IMAGE
            CircleAvatar(
              radius: 65,
              backgroundImage: image != null
                  ? FileImage(image!)
                  : const AssetImage("assets/profile.png") as ImageProvider,
            ),

            const SizedBox(height: 14),

            // 🔥 NAME
            Text(
              name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 4),

            // 🔥 CATEGORY
            Text(
              category,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 20),

            // ----------------- PRICE CARD -----------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.currency_rupee,
                      color: Colors.blue, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    "₹$price / minute",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ----------------- SKILLS SECTION -----------------
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                "Skills",
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills.map((skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.deepPurple.shade200, width: 1),
                  ),
                  child: Text(
                    skill,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 30),

            // ----------------- ABOUT CARD -----------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "About Psychic",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    about,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.45,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
