import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:psychics/repository/screens/Bottomnav/MainNavigationScreen.dart';
import 'package:psychics/repository/screens/login/loginscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  String gender = "Male";
  bool showSettings = false;
  bool isEditing = false;
  bool isLoading = true;

  // Local User Data
  String? userId;
  String? userName;
  String? userEmail;
  String? userPhone;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();

  final maskFormatter = MaskTextInputFormatter(
    mask: '+1 (###) ###-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final List<String> _faqItems = [
    "FAQ",
    "Feedbacks & Support",
    "Terms & Conditions",
    "Privacy Policy",
    "About Us",
    "Contact Us",
  ];

  @override
  void initState() {
    super.initState();
    _loadLocalUser();
  }

  Future<void> _loadLocalUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    userId = prefs.getString("user_id");
    userName = prefs.getString("user_name") ?? "";
    userEmail = prefs.getString("user_email") ?? "";
    userPhone = prefs.getString("user_phone") ?? "";

    _nameController.text = userName!;
    _phoneController.text = userPhone ?? "";

    setState(() => isLoading = false);
  }


  Future<void> _saveLocalUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString("name", _nameController.text.trim());
    await prefs.setString("phone", _phoneController.text.trim());
    await prefs.setString("dob", _dobController.text.trim());
    await prefs.setString("location", _locationController.text.trim());
    await prefs.setString("zip", _zipController.text.trim());
    await prefs.setString("gender", gender);

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Profile updated locally!")));
  }

  String getInitials(String name) {
    if (name.trim().isEmpty) return "U";
    List<String> parts =
    name.trim().split(" ").where((e) => e.trim().isNotEmpty).toList();
    return parts.map((e) => e.trim()[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const MainNavigationScreen(initialIndex: 0),
                ),
              );
            },
          ),
          title: const Text(
            "My Profile",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
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
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProfileCard(),
            const SizedBox(height: 25),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child:
              showSettings ? _buildSettingsSection() : _buildPersonalInfo(),
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  // ---------- TOP PROFILE CARD ----------
  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: Colors.purple.shade200,
            child: Text(
              getInitials(_nameController.text),
              style: const TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _nameController.text.isEmpty ? "User" : _nameController.text,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            _phoneController.text,
            style: const TextStyle(color: Colors.black87),
          ),
          const SizedBox(height: 12),
          _buildTabs(),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _tabButton("Personal Info", !showSettings, () {
          setState(() => showSettings = false);
        }),
        _tabButton("Settings", showSettings, () {
          setState(() => showSettings = true);
        }),
      ],
    );
  }

  Widget _tabButton(String text, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFEDE7F6) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: active ? Colors.purple : Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ---------- PERSONAL INFO ----------
  Widget _buildPersonalInfo() {
    return Column(
      key: const ValueKey(1),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Personal Information",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            TextButton.icon(
              onPressed: () async {
                if (isEditing) await _saveLocalUser();
                setState(() => isEditing = !isEditing);
              },
              icon: Icon(isEditing ? Icons.save : Icons.edit,
                  color: isEditing ? Colors.green : Colors.purple),
              label: Text(
                isEditing ? "Save" : "Edit",
                style: TextStyle(
                    color: isEditing ? Colors.green : Colors.purple,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        _buildTextField("Name", _nameController, isEditing),
        _buildPhoneField("Phone Number", _phoneController, isEditing),
        _buildDisabledField("Email ID", userEmail ?? ""),
        _buildDOBField(),
        _genderSelector(),
        _buildTextField("Location", _locationController, isEditing),
        _buildTextField("Zipcode", _zipController, isEditing),
      ],
    );
  }

  Widget _buildDOBField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: _dobController,
        readOnly: true,
        enabled: isEditing,
        onTap: isEditing
            ? () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime(2000),
            firstDate: DateTime(1950),
            lastDate: DateTime.now(),
          );
          if (picked != null) {
            _dobController.text = DateFormat('dd-MM-yyyy').format(picked);
          }
        }
            : null,
        decoration: InputDecoration(
          labelText: "Date of Birth",
          suffixIcon: const Icon(Icons.calendar_today,
              color: Colors.purple, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildPhoneField(String label, TextEditingController controller,
      bool editable) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        enabled: editable,
        keyboardType: TextInputType.phone,
        inputFormatters: [maskFormatter],
        decoration: InputDecoration(
          labelText: label,
          hintText: "+1 (555) 123-4567",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _genderSelector() {
    return Row(
      children: [
        const Text("Gender: ",
            style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500)),
        Row(
          children: [
            Radio<String>(
              value: "Male",
              groupValue: gender,
              activeColor: Colors.purple,
              onChanged:
              isEditing ? (value) => setState(() => gender = value!) : null,
            ),
            const Text("Male"),
            const SizedBox(width: 10),
            Radio<String>(
              value: "Female",
              groupValue: gender,
              activeColor: Colors.purple,
              onChanged:
              isEditing ? (value) => setState(() => gender = value!) : null,
            ),
            const Text("Female"),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, bool editable) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        enabled: editable,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildDisabledField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: TextEditingController(text: value),
        enabled: false,
        decoration: InputDecoration(
          labelText: label,
          disabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black26),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        style: const TextStyle(color: Colors.black87),
      ),
    );
  }

  // ---------- SETTINGS SECTION ----------
  Widget _buildSettingsSection() {
    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._faqItems.map(
              (title) => ExpansionTile(
            title: Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.black87)),
            children: [
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  "This is information for $title.",
                  style: const TextStyle(color: Colors.black54),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton.icon(
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
              );
            },
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text("Logout",
                style:
                TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              elevation: 3,
              padding:
              const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
