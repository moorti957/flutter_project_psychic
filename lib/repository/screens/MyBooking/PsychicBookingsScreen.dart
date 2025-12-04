import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
    final url = Uri.parse("YOUR_API_URL_HERE");
    // 👉 Yaha apna API URL lagana

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() {
        bookings = data["bookings"];   // 👉 API JSON ke hisab se change karna
        loading = false;
      });

    } else {
      setState(() => loading = false);
      print("API Error: ${response.statusCode}");
    }
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

            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // USER PROFILE IMAGE
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(
                    item["user_image"] ?? "https://via.placeholder.com/150",
                  ),
                ),

                const SizedBox(width: 12),

                // DETAILS
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["user_name"] ?? "Unknown User",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        "Method: ${item["method"]}",
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        "Time: ${item["time"]}",
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
          );
        },
      ),
    );
  }
}
