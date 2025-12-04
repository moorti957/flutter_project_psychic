import 'package:flutter/material.dart';

class CustomerSupportScreen extends StatefulWidget {
  const CustomerSupportScreen({super.key});

  @override
  State<CustomerSupportScreen> createState() => _CustomerSupportScreenState();
}

class _CustomerSupportScreenState extends State<CustomerSupportScreen> {
  bool showFeedback = false; // 👈 Toggle between Contact Support / Feedback

  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController ideaController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  String? selectedIssue;
  final List<String> issueTypes = [
    "Technical Issue",
    "Payment Problem",
    "Account Issue",
    "General Inquiry",
    "Other"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          showFeedback ? "Feedback" : "Customer Support",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      // 🔹 Body
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔸 Tabs
            const Text(
              "Type",
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Colors.black87),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Radio<bool>(
                  value: false,
                  groupValue: showFeedback,
                  activeColor: Colors.redAccent,
                  onChanged: (value) => setState(() => showFeedback = value!),
                ),
                const Text("Contact Support", style: TextStyle(color: Colors.black87)),
                const SizedBox(width: 20),
                Radio<bool>(
                  value: true,
                  groupValue: showFeedback,
                  activeColor: Colors.redAccent,
                  onChanged: (value) => setState(() => showFeedback = value!),
                ),
                const Text("Feedback", style: TextStyle(color: Colors.black87)),
              ],
            ),

            const SizedBox(height: 10),

            // 🔹 Animated Switch for Forms
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: showFeedback
                  ? _buildFeedbackForm()
                  : _buildContactSupportForm(),
            ),
          ],
        ),
      ),
    );
  }

  // ======================================================
  // 🔸 Contact Support Form
  Widget _buildContactSupportForm() {
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          label: "Email",
          hint: "Enter yourEmail Id",
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        _buildTextField(
          label: "Contact Number",
          hint: "Enter your contact number",
          controller: contactController,
          keyboardType: TextInputType.phone,
        ),
        _buildTextField(
          label: "Subject",
          hint: "Message subject",
          controller: subjectController,
        ),

        const SizedBox(height: 6),
        const Text(
          "Issue Type",
          style: TextStyle(
              color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedIssue,
            hint: const Text(
              "Select option",
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
            items: issueTypes
                .map((item) => DropdownMenuItem(
              value: item,
              child: Text(item,
                  style: const TextStyle(color: Colors.black87)),
            ))
                .toList(),
            onChanged: (value) => setState(() => selectedIssue = value!),
            icon: const Icon(Icons.arrow_drop_down),
            decoration: const InputDecoration(border: InputBorder.none),
          ),
        ),

        const SizedBox(height: 16),
        const Text(
          "Suggestion Box",
          style: TextStyle(
              color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: messageController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: "How can we help you today?",
            hintStyle: const TextStyle(color: Colors.black54, fontSize: 13),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black12),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide:
              const BorderSide(color: Color(0xFF7B1FA2), width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        const SizedBox(height: 25),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Message Sent Successfully!"),
                behavior: SnackBarBehavior.floating,
              ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC107),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              "Send Message",
              style: TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }

  // ======================================================
  // 🔸 Feedback Form
  Widget _buildFeedbackForm() {
    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          label: "Email",
          hint: "Enter yourEmail Id",
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        _buildTextField(
          label: "Contact Number",
          hint: "Enter your contact number",
          controller: contactController,
          keyboardType: TextInputType.phone,
        ),
        _buildTextField(
          label: "I suggest you",
          hint: "Enter your idea",
          controller: ideaController,
        ),
        const SizedBox(height: 6),
        const Text(
          "Suggestion Box",
          style: TextStyle(
              color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: messageController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: "How can we help you today?",
            hintStyle: const TextStyle(color: Colors.black54, fontSize: 13),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black12),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide:
              const BorderSide(color: Color(0xFF7B1FA2), width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 25),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Feedback Submitted Successfully!"),
                behavior: SnackBarBehavior.floating,
              ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC107),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              "Post Feedback",
              style: TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }

  // ======================================================
  // 🔸 Reusable TextField
  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontSize: 14)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
              const TextStyle(color: Colors.black54, fontSize: 13),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.black12),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                const BorderSide(color: Color(0xFF7B1FA2), width: 1.5),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
