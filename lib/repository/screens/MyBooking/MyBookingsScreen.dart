import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:psychics/repository/screens/MyBooking/VideoCallScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  bool loading = true;
  List bookings = [];

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Session expired. Please login again")),
      );
      return;
    }

    final url = Uri.parse(
        "https://psychicbelive.mapps.site/api/user/orders");

    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer $token"},
    );

    print("BOOKINGS STATUS: ${response.statusCode}");
    print("BOOKINGS RESPONSE: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        bookings = data["data"];
        loading = false;
      });
    } else {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: ${response.body}")),
      );
    }
  }

  // -------------------------------------------------------------
  //  API CALL HERE
  // -------------------------------------------------------------
  Future<Map<String, dynamic>?> startCallAPI(int bookingId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final url = Uri.parse(
          "https://psychicbelive.mapps.site/api/start-call");

      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"booking_id": bookingId}),
      );

      print("START CALL STATUS: ${response.statusCode}");
      print("START CALL RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.body}")),
        );
        return null;
      }
    } catch (e) {
      print("ERROR : $e");
      return null;
    }
  }

  bool isSessionActive(String date, String time) {
    try {
      final bookingDateTime = DateTime.parse("$date $time");
      final now = DateTime.now().toUtc();
      return now.isAfter(bookingDateTime) || now.isAtSameMomentAs(bookingDateTime);
    } catch (e) {
      return false;
    }
  }

  // -------------------------------------------------------------
  // BUTTON UPDATED HERE
  // -------------------------------------------------------------
  Widget getServiceButton(String type, bool active, int bookingId) {
    IconData icon;
    String text;

    switch (type) {
      case "call":
        icon = Icons.call;
        text = "join";
        break;

      case "chat":
        icon = Icons.chat;
        text = "join";
        break;

      case "video":
        icon = Icons.video_call;
        text = "join";
        break;

      default:
        icon = Icons.help;
        text = "Unknown";
    }

    return ElevatedButton.icon(
      onPressed: active
          ? () async {
        final data = await startCallAPI(bookingId);

        if (data != null) {
          final channel = data["channel_name"];
          final uid = data["uid"];
          final token = data["token"];

          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (_) => VideoCallScreen(
          //       channelName: channel,
          //       token: token,
          //       uid: uid,
          //     ),
          //   ),
          // );
        }
      }
          : () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Your session has not started yet.")),
        );
      },

      icon: Icon(icon),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: active ? Colors.deepPurple : Colors.grey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("My Bookings"),
        backgroundColor: Colors.deepPurple,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : bookings.isEmpty
          ? const Center(child: Text("No bookings found"))
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final b = bookings[index];
          final psychic = b["psychic"] ?? {};

          final bool active =
          isSessionActive(b["date"], b["time"]);

          return Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: (psychic["profile_image"] != null && psychic["profile_image"] != "")
                          ? NetworkImage(psychic["profile_image"])
                          : const AssetImage("assets/images/default.png"),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        psychic["display_name"] ??
                            "Unknown Psychic",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    const Icon(Icons.call,
                        size: 18, color: Colors.deepPurple),
                    const SizedBox(width: 6),
                    Text(
                      "Service: ${b["service_type"].toString().toUpperCase()}",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    const Icon(Icons.calendar_month,
                        size: 18, color: Colors.deepPurple),
                    const SizedBox(width: 6),
                    Text(
                      "${b["date"]} at ${b["time"]}",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    const Icon(Icons.payment,
                        size: 18, color: Colors.deepPurple),
                    const SizedBox(width: 6),
                    Text(
                      "Paid: \$${b["amount"]}",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: b["status"] == "confirmed"
                        ? Colors.green.shade100
                        : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Status: ${b["status"].toUpperCase()}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: b["status"] == "confirmed"
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // 👇 UPDATED BUTTON WITH BOOKING ID
                getServiceButton(
                  b["service_type"],
                  active,
                  b["id"],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
