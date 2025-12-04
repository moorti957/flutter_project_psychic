import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String name;
  final String photoUrl;

  const ChatScreen({
    super.key,
    required this.name,
    required this.photoUrl,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController msgController = TextEditingController();

  List<Map<String, dynamic>> messages = [
    {"msg": "Hello! ", "me": false},
    {"msg": "How can I help you?", "me": false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // 🔹 PURPLE THEME APP BAR (same as your app)
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A0072), Color(0xFF2A0A6B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),

            CircleAvatar(
              backgroundImage: NetworkImage(widget.photoUrl),
            ),

            const SizedBox(width: 10),

            Text(
              widget.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),

      // 🔹 CHAT BODY
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                bool isMe = messages[index]["me"];

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color:
                      isMe ? Colors.deepPurple.shade600 : Colors.grey.shade200,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft:
                        isMe ? const Radius.circular(16) : Radius.zero,
                        bottomRight:
                        isMe ? Radius.zero : const Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      messages[index]["msg"],
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black87,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 🔹 MESSAGE INPUT BOX
          _messageBox(),
        ],
      ),
    );
  }

  Widget _messageBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 6, offset: Offset(0, -2))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: msgController,
              decoration: InputDecoration(
                hintText: "Type message...",
                filled: true,
                fillColor: Colors.grey.shade200,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // SEND BUTTON
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.deepPurple,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () {
                if (msgController.text.trim().isEmpty) return;

                setState(() {
                  messages.add({
                    "msg": msgController.text.trim(),
                    "me": true,
                  });
                });

                msgController.clear();
              },
            ),
          ),
        ],
      ),
    );
  }
}
