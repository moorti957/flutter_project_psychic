import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PsychicBookingsScreen extends StatefulWidget {
  const PsychicBookingsScreen({super.key});

  @override
  State<PsychicBookingsScreen> createState() => _PsychicBookingsScreenState();
}

class _PsychicBookingsScreenState extends State<PsychicBookingsScreen> {
  bool loading = true;
  List bookings = [];

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) {
      print("TOKEN NOT FOUND");
      setState(() => loading = false);
      return;
    }

    final url = Uri.parse(
        "https://psychicbelive.mapps.site/api/psychic/my-bookings");

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    print("BOOKING STATUS: ${response.statusCode}");
    print("BOOKING BODY: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() {
        bookings = data["data"] ?? [];   // <-- FIXED HERE
        loading = false;
      });

    } else {
      setState(() => loading = false);
      print("API Error: ${response.statusCode}");
    }

  }
  Widget getServiceButton(String type) {
    IconData icon;
    String text;

    switch (type) {
      case "call":
        icon = Icons.call;
        text = "Start Call";
        break;

      case "chat":
        icon = Icons.chat;
        text = "Start Chat";
        break;

      case "video":
        icon = Icons.video_call;
        text = "Start Video";
        break;

      default:
        icon = Icons.help;
        text = "Unknown";
    }

    return ElevatedButton.icon(
      onPressed: () {
        print("Clicked: $type");
        // Yaha aap next screen open kar sakte ho
      },
      icon: Icon(icon, color: Colors.white),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text("Your Bookings"),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : bookings.isEmpty
          ? const Center(
        child: Text(
          "No bookings found",
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: bookings.length,
          itemBuilder: (context, index) {
            final item = bookings[index];
            final user = item["user"] ?? {};

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: user["profile_photo"] != null
                            ? NetworkImage("https://psychicbelive.mapps.site/uploads/users/${user["profile_photo"]}")
                            : const AssetImage("assets/images/4d1244c8cd23f93c1a9d40fe9c4df8756afecddf.png") as ImageProvider,
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user["name"] ?? "Unknown User",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              "Service: ${item["service_type"]}",
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 15,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              "Date: ${item["date"]}  ${item["time"]}",
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // <<< BUTTON HERE >>>
                  getServiceButton(item["service_type"]),
                ],
              ),
            );
          }


      ),
    );
  }
}
