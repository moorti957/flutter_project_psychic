import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:demopro/repository/screens/Chat/ChatScreen.dart';
import 'package:http/http.dart' as http;
import 'package:psychics/repository/screens/Chat/Chatscreen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  bool isLoading = true;
  List<dynamic> psychics = [];

  @override
  void initState() {
    super.initState();
    fetchPsychics();
  }

  // 🔹 API CALL
  Future<void> fetchPsychics() async {
    try {
      final res =
      await http.get(Uri.parse("https://psychics.mapps.site/api/psychics"));

      if (res.statusCode == 200) {
        final jsonData = jsonDecode(res.body);

        setState(() {
          psychics = jsonData["data"];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  // 🔹 BASE URL for image
  String buildImage(String? photo) {
    if (photo == null || photo.isEmpty) {
      return "https://i.pravatar.cc/150?img=12";
    }
    return "https://psychics.mapps.site/uploads/users/$photo";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A0072), Color(0xFF2A0A6B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 1,
        centerTitle: true,
        title: const Text(
          "Chats",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
          : ListView.builder(
        itemCount: psychics.length,
        itemBuilder: (context, index) {
          final psychic = psychics[index];
          final user = psychic["user"] ?? {};

          return ListTile(
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 10),

            leading: CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(
                buildImage(user["profile_photo"]),
              ),
            ),

            // 🔹 Name From API
            title: Text(
              psychic["display_name"] ?? "Unknown Psychic",
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w600),
            ),

            // 🔹 LAST MESSAGE (Price/Minute - You can change)
            subtitle: Text(
              "${psychic["experience_years"]} Years Exp.",
              style: const TextStyle(color: Colors.black54),
            ),

            // 🔹 Time (converted)
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  (user["created_at"] ?? "").toString().substring(0, 10),
                  style: const TextStyle(
                      color: Colors.black45, fontSize: 12),
                ),
                const SizedBox(height: 6),

                // 🔹 unread always 0 (API doesn't give unread count)
              ],
            ),

            // 🔹 On Tap → ChatScreen
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    name: psychic["display_name"],
                    photoUrl: buildImage(user["profile_photo"]),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
