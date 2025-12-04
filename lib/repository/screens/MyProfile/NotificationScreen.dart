import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<Map<String, dynamic>> notifications = [
    {
      "title": "Psychics Notifications",
      "icon": Icons.auto_awesome,
      "color": Colors.pinkAccent,
      "count": 1,
      "expanded": true,
      "message":
      "🔔 Reminder: Your 1-year career report is ready! Download your career report now.",
      "time": "45 minutes ago",
    },
    {
      "title": "Events Notifications",
      "icon": Icons.event_note,
      "color": Colors.blue,
      "expanded": false,
    },
    {
      "title": "Notifications",
      "icon": Icons.notifications_active_outlined,
      "color": Colors.orange,
      "count": 2,
      "expanded": false,
    },
    {
      "title": "Notifications",
      "icon": Icons.chat_bubble_outline,
      "color": Colors.amber,
      "expanded": false,
    },
    {
      "title": "App Notification",
      "icon": Icons.eco_outlined,
      "color": Colors.green,
      "expanded": false,
    },
    {
      "title": "Total Income",
      "icon": Icons.account_balance_wallet_outlined,
      "color": Colors.deepPurple,
      "expanded": false,
    },
    {
      "title": "Customer Support",
      "icon": Icons.support_agent_outlined,
      "color": Colors.cyan,
      "expanded": false,
    },
    {
      "title": "Term’s & Conditions",
      "icon": Icons.policy_outlined,
      "color": Colors.purpleAccent,
      "expanded": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Notification",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.grey),
        itemBuilder: (context, index) {
          final item = notifications[index];

          return ExpansionTile(
            initiallyExpanded: item["expanded"],
            onExpansionChanged: (val) {
              setState(() => notifications[index]["expanded"] = val);
            },
            leading: CircleAvatar(
              radius: 22,
              backgroundColor: item["color"].withOpacity(0.1),
              child: Icon(item["icon"], color: item["color"], size: 22),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    item["title"],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                if (item["count"] != null)
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "${item["count"]}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            childrenPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            children: [
              if (item["message"] != null) ...[
                Row(
                  children: [
                    const Icon(Icons.circle, color: Colors.pinkAccent, size: 8),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item["message"],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item["time"] ?? "",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
