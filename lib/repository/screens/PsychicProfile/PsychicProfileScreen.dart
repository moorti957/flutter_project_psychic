import 'package:flutter/material.dart';
import 'package:psychics/repository/screens/Appointment/AppointmentPsychicsScreen.dart';

class PsychicProfileScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const PsychicProfileScreen({super.key, required this.data});

  // 🔥 HTML to Plain Text converter
  String cleanHtml(String html) {
    return html
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')  // multiple spaces → one space
        .trim();
  }
  // ⭐ LIMIT SKILLS (MAX 30 CHARACTERS)
  String limitSkills(String text) {
    if (text.length <= 30) return text;
    return text.substring(0, 33) + "...";
  }

  @override
  Widget build(BuildContext context) {
    final user = data["user"] ?? {};
    final categories = data["categories"] ?? [];

    // IMAGE URL
    final imageUrl = user["profile_photo"] != null
        ? "https://psychicbelive.mapps.site/uploads/users/${user["profile_photo"]}"
        : "";

    // SKILLS
    final skills = categories.isNotEmpty
        ? categories.map((c) => c["name"]).join(", ")
        : "No Skills";

    String limitSkills(String text) {
      if (text.length <= 30) return text;
      return text.substring(0, 30) + "...";
    }
    // ⭐ FIXED — ABOUT ME (bio comes from data["bio"])
    final rawBio = data["bio"];
    final aboutText = (rawBio != null && rawBio.toString().trim().isNotEmpty)
        ? cleanHtml(rawBio)        // 🔥 cleaned HTML → simple text
        : "No data found";

    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A0072), Color(0xFF2A0A6B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _profileCard(context, imageUrl, skills),
            const SizedBox(height: 15),
            _aboutSection(aboutText),
            const SizedBox(height: 15),
            _ratingOverview(),
            const SizedBox(height: 15),
            _reviewList(),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  // ⭐ PROFILE CARD
  Widget _profileCard(BuildContext context, String imageUrl, String skills) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: imageUrl.isNotEmpty
                ? Image.network(imageUrl, height: 120, width: 100, fit: BoxFit.cover)
                : Container(
              height: 120,
              width: 100,
              color: Colors.grey.shade300,
              child: const Icon(Icons.person, size: 40),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data["display_name"] ?? "Unknown",
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                Text(
                  limitSkills(skills), // ⭐ only 30 characters
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
                const SizedBox(height: 6),

                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.black54),
                    const SizedBox(width: 4),
                    Text("${data["experience_years"]} yrs",
                        style: const TextStyle(color: Colors.black54)),
                    const SizedBox(width: 10),

                    const Icon(Icons.attach_money, size: 16, color: Colors.black54),
                    const SizedBox(width: 4),
                    Text("${data["price_per_minute"]}/min",
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 10),
                  ],
                ),

                const SizedBox(height: 10),

                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AppointmentPsychicsScreen(data: data),
                          ),
                        );
                      },
                    icon: const Icon(Icons.calendar_month, color: Colors.white),
                    label: const Text(
                      "Book Appointment",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF3F016F),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ⭐ ABOUT SECTION WITH SEE MORE / SEE LESSrr
  Widget _aboutSection(String about) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.deepPurple.shade400),
        color: const Color(0xFFFFFF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("About Me",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 6),
          ExpandableText(text: about),     // ⭐ NEW COMPONENT
        ],
      ),
    );
  }

  // ⭐ RATING UI
  Widget _ratingOverview() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Rating Overview",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: const [
                  Text("5.0",
                      style:
                      TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                  SizedBox(height: 0),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 18),
                      Icon(Icons.star, color: Colors.amber, size: 18),
                      Icon(Icons.star, color: Colors.amber, size: 18),
                      Icon(Icons.star, color: Colors.amber, size: 18),
                      Icon(Icons.star, color: Colors.amber, size: 18),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text("348 Ratings",
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              const SizedBox(width: 30),

              Expanded(
                child: Column(
                  children: List.generate(5, (i) {
                    int rating = 5 - i;
                    double width = [160, 120, 90, 50, 25][i].toDouble();

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Text("$rating "),
                          const Icon(Icons.star, size: 10, color: Colors.amber),
                          const SizedBox(width: 6),

                          Stack(
                            children: [
                              Container(
                                height: 8,
                                width: 160,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              Container(
                                height: 8,
                                width: width,
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  // ⭐ REVIEWS
  Widget _reviewList() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _reviewTile("Anonymous",
              "Amazing astrologer, all doubts are clear and helpful guidance."),
          _reviewTile("Richard",
              "Astrologer gently answered my questions and shared great advice."),
          _reviewTile("John",
              "Revealed the problems and gave solutions to overcome them."),
        ],
      ),
    );
  }

  Widget _reviewTile(String name, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Colors.blue,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                Row(
                  children: const [
                    Icon(Icons.star, size: 14, color: Colors.amber),
                    Icon(Icons.star, size: 14, color: Colors.amber),
                    Icon(Icons.star, size: 14, color: Colors.amber),
                    Icon(Icons.star, size: 14, color: Colors.amber),
                    Icon(Icons.star, size: 14, color: Colors.amber),
                  ],
                ),
                const SizedBox(height: 6),
                Text(text, style: const TextStyle(fontSize: 13)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ⭐ NEW EXPANDABLE TEXT WIDGET
class ExpandableText extends StatefulWidget {
  final String text;
  final int wordLimit;

  const ExpandableText({
    super.key,
    required this.text,
    this.wordLimit = 50,
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final words = widget.text.split(" ");
    final bool isLong = words.length > widget.wordLimit;

    final String shortText =
    isLong ? words.take(widget.wordLimit).join(" ") : widget.text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          expanded ? widget.text : shortText,
          style: const TextStyle(fontSize: 13, height: 1.5),
        ),

        if (isLong)
          TextButton(
            onPressed: () {
              setState(() {
                expanded = !expanded;
              });
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
            ),
            child: Text(
              expanded ? "See Less" : "See More",
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}
