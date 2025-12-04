import 'dart:io';

import 'package:flutter/material.dart';

class PsychicProfileViewScreen extends StatelessWidget {
  final String name;
  final String experience;
  final String price;
  final String about;
  final List<String> skills;
  final List<String> ability;
  final List<String> tools;
  final String? imagePath;

  const PsychicProfileViewScreen({
    super.key,
    required this.name,
    required this.experience,
    required this.price,
    required this.about,
    required this.skills,
    required this.ability,
    required this.tools,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Psychic Profile"),
        backgroundColor: Colors.deepPurple,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // IMAGE
            CircleAvatar(
              radius: 70,
              backgroundImage:
              imagePath != null ? FileImage(File(imagePath!)) : null,
              child: imagePath == null
                  ? const Icon(Icons.person, size: 70)
                  : null,
            ),

            const SizedBox(height: 20),

            // NAME
            Text(
              name,
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            // EXPERIENCE & PRICE
            Text("Experience: $experience Years",
                style: const TextStyle(fontSize: 16)),
            Text("Price: ₹$price / minute",
                style: const TextStyle(fontSize: 16)),

            const SizedBox(height: 20),

            // SKILLS
            buildSection("Specialities", skills),
            buildSection("Ability", ability),
            buildSection("Tools", tools),

            const SizedBox(height: 20),

            // ABOUT
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                "About Psychic",
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              about,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSection(String title, List<String> list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          title,
          style:
          const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: list
              .map((e) => Chip(
            label: Text(e),
            backgroundColor: Colors.deepPurple.withOpacity(0.2),
          ))
              .toList(),
        )
      ],
    );
  }
}
