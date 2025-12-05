//      PSYCHIC PROFILE SETUP – FINAL VERSION (AUTO-FILL + API FETCH + FIXED FIELDS)

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:psychics/repository/screens/login/loginscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'FreelancerProfileScreen.dart';

class PsychicProfileSetupScreen extends StatefulWidget {
  const PsychicProfileSetupScreen({super.key});

  @override
  State<PsychicProfileSetupScreen> createState() =>
      _PsychicProfileSetupScreenState();
}

class _PsychicProfileSetupScreenState extends State<PsychicProfileSetupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController aboutController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  File? _image;
  final picker = ImagePicker();
  String? userImageURL;

  List<dynamic> apiCategories = [];
  List<String> apiSkills = [];
  List<String> apiAbility = [];
  List<String> apiTools = [];

  List<String> selectedSkills = [];
  List<String> selectedAbility = [];
  List<String> selectedTools = [];
  List<String> selectedLanguages = [];

  String? selectedCategory;
  bool isLoading = false;
  bool loadingSkills = true;
  bool loadingTools = true;
  bool loadingAbility = true;

  @override
  void initState() {
    super.initState();
    loadExistingProfile();
    loadCategories();
    loadSkills();
    loadAbility();
    loadTools();
  }

  // ------------------- PICK IMAGE -------------------
  Future pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  // ------------------- AUTO-FILL PROFILE DATA -------------------
  Future<void> loadExistingProfile() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("user_id");

    if (userId == null) {
      print("USER ID NOT FOUND");
      return;
    }

    final response = await http.get(
      Uri.parse("https://psychicbelive.mapps.site/api/psychics"),
    );

    if (response.statusCode != 200) {
      print("Error loading psychics");
      return;
    }

    final List psychics = jsonDecode(response.body)["data"];

    final userPsychic = psychics.firstWhere(
          (p) => p["user_id"].toString() == userId,
      orElse: () => null,
    );

    if (userPsychic == null) {
      print("NO PSYCHIC PROFILE FOUND FOR THIS USER");
      return;
    }

    print("PSYCHIC DATA FOUND = $userPsychic");

    // ------------------- CORRECT FIELDS -------------------

    // NAME → comes from user table
    nameController.text =
        userPsychic["user"]?["name"]?.toString() ?? "";

    // ABOUT → comes from psychic.bio
    aboutController.text =
        userPsychic["bio"]?.toString() ?? "";

    // EXPERIENCE → correct field is experience_years
    experienceController.text =
        userPsychic["experience_years"]?.toString() ?? "";

    // PRICE → correct field is price_per_minute
    priceController.text =
        userPsychic["price_per_minute"]?.toString() ?? "";

    // CATEGORY → psychic API does NOT return category
    selectedCategory = null;

    // SPECIALTIES
    selectedSkills = userPsychic["specialties"] != null
        ? (userPsychic["specialties"] as List)
        .map((e) => e.toString())
        .toList()
        : [];

    // ABILITY
    selectedAbility = userPsychic["ability"] != null
        ? userPsychic["ability"]
        .toString()
        .replaceAll("\"", "")
        .split(",")
        .map((e) => e.trim())
        .toList()
        : [];

    // TOOLS
    selectedTools = userPsychic["tools"] != null
        ? userPsychic["tools"]
        .toString()
        .replaceAll("\"", "")
        .split(",")
        .map((e) => e.trim())
        .toList()
        : [];

    // PROFILE PHOTO FIXED PATH
    // PROFILE PHOTO → correct field
    if (userPsychic["user"]?["profile_photo"] != null &&
        userPsychic["user"]["profile_photo"].toString().isNotEmpty) {
      userImageURL =
      "https://psychicbelive.mapps.site/uploads/users/${userPsychic["user"]["profile_photo"]}";
      print("FINAL IMAGE URL => $userImageURL");
    } else {
      print("NO PROFILE PHOTO FOUND");
    }

    print("CHECK IMAGE PATH ON SERVER NOW:");
    print(Uri.parse("https://psychicbelive.mapps.site/uploads/users/profile_photo/${userPsychic["user"]["profile_photo"]}"));





    setState(() {});
  }


  // ------------------- API LOADER FUNCTIONS -------------------
  Future<void> loadCategories() async {
    final response = await http.get(
        Uri.parse("https://psychicbelive.mapps.site/api/psychics_categories"));

    if (response.statusCode == 200) {
      apiCategories = jsonDecode(response.body)["data"];
      setState(() {});
    }
  }

  Future<void> loadSkills() async {
    final response = await http.get(Uri.parse(
        "https://psychicbelive.mapps.site/api/psychics?category[]=12&min_price=10&max_price=50"));

    if (response.statusCode == 200) {
      final list = <String>[];
      for (var psychic in jsonDecode(response.body)["data"]) {
        if (psychic["specialties"] != null) {
          list.addAll((psychic["specialties"] as List)
              .map((e) => e.toString()));
        }
      }
      apiSkills = list.toSet().toList();
    }

    loadingSkills = false;
    setState(() {});
  }

  Future<void> loadAbility() async {
    final response = await http.get(
        Uri.parse("https://psychicbelive.mapps.site/api/psychics_ability"));

    if (response.statusCode == 200) {
      apiAbility = List<String>.from(
        jsonDecode(response.body)["data"].map((e) => e["name"].toString()),
      );
    }

    loadingAbility = false;
    setState(() {});
  }

  Future<void> loadTools() async {
    final response = await http
        .get(Uri.parse("https://psychicbelive.mapps.site/api/psychics_tools"));

    if (response.statusCode == 200) {
      apiTools = List<String>.from(
        jsonDecode(response.body)["data"].map((e) => e["name"].toString()),
      );
    }

    loadingTools = false;
    setState(() {});
  }

  // ------------------- UPDATE PROFILE -------------------
  Future updateProfileAPI() async {
    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) {
      ScaffoldMessenger.of(this.context).showSnackBar(
          const SnackBar(content: Text("Login token missing")));
      return;
    }

    var request = http.MultipartRequest(
      "PUT",
      Uri.parse("https://psychicbelive.mapps.site/api/userupdate"),
    );

    request.headers["Authorization"] = "Bearer $token";

    request.fields["display_name"] = nameController.text;
    request.fields["experience_years"] = experienceController.text;
    request.fields["bio"] = aboutController.text;
    request.fields["price_per_minute"] = priceController.text;
    request.fields["skills"] = selectedSkills.join(",");
    request.fields["ability"] = selectedAbility.join(",");
    request.fields["tools"] = selectedTools.join(",");

    if (_image != null) {
      request.files.add(await http.MultipartFile.fromPath(
        "image",
        _image!.path,
        filename: basename(_image!.path),
      ));
    }

    final response = await request.send();
    final body = await response.stream.bytesToString();

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      Navigator.pushReplacement(
        this.context,
        MaterialPageRoute(
          builder: (_) => FreelancerProfileScreen(
            name: nameController.text,
            about: aboutController.text,
            price: priceController.text,
            experience: experienceController.text,
            category: selectedCategory ?? "",
            skills: selectedSkills,
            ability: selectedAbility,
            tools: selectedTools,
            languages: selectedLanguages,
            image: _image,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(this.context)
          .showSnackBar(SnackBar(content: Text("Error: $body")));
    }
  }

  // ------------------- VALIDATION -------------------
  void saveProfile() {
    updateProfileAPI();
  }

  // ------------------- UI -------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const LoginScreen()),
            );
          },
        ),
        title: const Text(
          "Create Psychic Profile",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Colors.deepPurple,
                backgroundImage: _image != null
                    ? FileImage(_image!)
                    : (userImageURL != null
                    ? NetworkImage(userImageURL!)
                    : null),
                child: (_image == null && userImageURL == null)
                    ? const Icon(Icons.camera_alt, size: 35)
                    : null,
              ),
            ),

            const SizedBox(height: 20),
            buildInput("Full Name", nameController),
            buildInput("Experience (Years)", experienceController,
                keyboard: TextInputType.number),
            buildInput("Price Per Minute (₹)", priceController,
                keyboard: TextInputType.number),

            DropdownButtonFormField(
              hint: const Text("Select Category"),
              items: apiCategories.map((c) {
                return DropdownMenuItem(
                  value: c["name"].toString(),
                  child: Text(c["name"].toString()),
                );
              }).toList(),
              value: null,
              onChanged: (v) =>
                  setState(() => selectedCategory = v.toString()),
            ),

            const SizedBox(height: 20),
            buildChips("Specialities", apiSkills, selectedSkills,
                loadingSkills),
            const SizedBox(height: 20),
            buildChips("Abilities", apiAbility, selectedAbility,
                loadingAbility),
            const SizedBox(height: 20),
            buildChips("Tools", apiTools, selectedTools, loadingTools),

            const SizedBox(height: 20),
            buildInput("About Psychic", aboutController,
                keyboard: TextInputType.multiline),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: saveProfile,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.deepPurple,
              ),
              child: const Text("Save Profile"),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------- HELPERS -------------------
  Widget buildInput(
      String title,
      TextEditingController c, {
        TextInputType keyboard = TextInputType.text,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        const SizedBox(height: 6),
        TextField(
          controller: c,
          keyboardType: keyboard,
          maxLines: keyboard == TextInputType.multiline ? 4 : 1,
          decoration: InputDecoration(
            fillColor: Colors.grey.shade100,
            filled: true,
            border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            hintText: "Enter $title",
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget buildChips(String title, List<String> list,
      List<String> selected, bool loading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style:
            const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        loading
            ? const Center(child: CircularProgressIndicator())
            : Wrap(
          spacing: 8,
          children: list.map((item) {
            final isSelected = selected.contains(item);
            return FilterChip(
              label: Text(item),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  isSelected
                      ? selected.remove(item)
                      : selected.add(item);
                });
              },
              selectedColor: Colors.deepPurple.withOpacity(0.25),
            );
          }).toList(),
        ),
      ],
    );
  }
}
