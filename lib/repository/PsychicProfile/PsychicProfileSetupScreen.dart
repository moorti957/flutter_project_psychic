//      PSYCHIC PROFILE SETUP – FINAL WORKING VERSION
//      WITH AUTO-REDIRECT + SAVED PROFILE DATA

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'FreelancerProfileScreen.dart';
import 'package:psychics/repository/screens/Bottomnav/PsychicMainNavigation.dart';

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

  List<dynamic> apiCategories = [];
  List<String> apiSkills = [];
  List<String> apiAbility = [];
  List<String> apiTools = [];

  List<String> selectedSkills = [];
  List<String> selectedAbility = [];
  List<String> selectedTools = [];

  List<String> selectedLanguages = [];
  final List<String> languages = [
    "Hindi", "English", "Punjabi", "Gujarati", "Tamil", "Kannada"
  ];

  String? selectedCategory;
  bool isOnline = true;
  bool isLoading = false;

  bool loadingSkills = true;
  bool loadingTools = true;
  bool loadingAbility = true;

  @override
  void initState() {
    super.initState();
    checkProfile();      //  ← NEW FUNCTION (AUTO REDIRECT)
    loadCategories();
    loadSkills();
    loadAbility();
    loadTools();
  }

  //  █████████ AUTO SKIP SETUP IF PROFILE ALREADY CREATED █████████
  Future<void> checkProfile() async {
    final prefs = await SharedPreferences.getInstance();
    bool already = prefs.getBool("isProfileCreated") ?? false;

    if (already) {
      String name = prefs.getString("name") ?? "";
      String about = prefs.getString("about") ?? "";
      String experience = prefs.getString("experience") ?? "";
      String price = prefs.getString("price") ?? "";
      String category = prefs.getString("category") ?? "";

      List<String> skills = prefs.getStringList("skills") ?? [];
      List<String> ability = prefs.getStringList("ability") ?? [];
      List<String> tools = prefs.getStringList("tools") ?? [];
      List<String> languages = prefs.getStringList("languages") ?? [];

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          this.context,
          MaterialPageRoute(
            builder: (_) => FreelancerProfileScreen(
              name: name,
              about: about,
              price: price,
              experience: experience,
              category: category,
              skills: skills,
              ability: ability,
              tools: tools,
              languages: languages,
              image: null,
            ),
          ),
        );
      });
    }
  }

  // ███████ IMAGE PICK ███████
  Future pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  // ███████ API LOADERS ███████

  Future<void> loadCategories() async {
    final response = await http
        .get(Uri.parse("https://psychicbelive.mapps.site/api/psychics_categories"));

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
        if (psychic["specialties"] != null &&
            psychic["specialties"].toString().isNotEmpty) {
          list.addAll(
            psychic["specialties"].toString().split(",").map((e) => e.trim()),
          );
        }
      }
      apiSkills = list.toSet().toList();
    }

    loadingSkills = false;
    setState(() {});
  }

  Future<void> loadAbility() async {
    final response = await http
        .get(Uri.parse("https://psychicbelive.mapps.site/api/psychics_ability"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      apiAbility = List<String>.from(
        data["data"].map((e) =>
            (e["name"] ?? e["title"] ?? e["ability"] ?? "").toString()),
      );
    }

    loadingAbility = false;
    setState(() {});
  }

  Future<void> loadTools() async {
    final response = await http
        .get(Uri.parse("https://psychicbelive.mapps.site/api/psychics_tools"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      apiTools = List<String>.from(
        data["data"].map((e) =>
            (e["name"] ?? e["title"] ?? e["tool"] ?? "").toString()),
      );
    }

    loadingTools = false;
    setState(() {});
  }

  // ███████ SAVE PROFILE TO API + LOCAL STORAGE ███████
  Future updateProfileAPI() async {
    setState(() => isLoading = true);

    // ------------- ADD THIS PART HERE -------------
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null || token.isEmpty) {
      print("TOKEN NOT FOUND!");
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(content: Text("Login token missing. Please login again.")),
      );
      return;
    }
    // -----------------------------------------------

    var request = http.MultipartRequest(
      "PUT",
      Uri.parse("https://psychicbelive.mapps.site/api/userupdate"),
    );

    request.headers["Authorization"] = "Bearer $token";


    request.fields["name"] = nameController.text;
    request.fields["experience"] = experienceController.text;
    request.fields["about"] = aboutController.text;
    request.fields["price"] = priceController.text;
    request.fields["category"] = selectedCategory ?? "";
    request.fields["skills"] = selectedSkills.join(",");
    request.fields["ability"] = selectedAbility.join(",");
    request.fields["tools"] = selectedTools.join(",");
    request.fields["languages"] = selectedLanguages.join(",");

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

      // SAVE LOCALLY TOO
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool("isProfileCreated", true);

      await prefs.setString("name", nameController.text);
      await prefs.setString("experience", experienceController.text);
      await prefs.setString("about", aboutController.text);
      await prefs.setString("price", priceController.text);
      await prefs.setString("category", selectedCategory ?? "");
      await prefs.setStringList("skills", selectedSkills);
      await prefs.setStringList("ability", selectedAbility);
      await prefs.setStringList("tools", selectedTools);
      await prefs.setStringList("languages", selectedLanguages);

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
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(content: Text("Error: $body")),
      );
    }
  }

  // ███████ UI SAVE BUTTON ███████
  void saveProfile() {
    if (nameController.text.isEmpty ||
        selectedCategory == null ||
        experienceController.text.isEmpty ||
        priceController.text.isEmpty) {
      ScaffoldMessenger.of(this.context)
          .showSnackBar(const SnackBar(content: Text("Fill all fields")));
      return;
    }

    updateProfileAPI();
  }

  // █████████████ UI SCREEN █████████████
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Psychic Profile"), backgroundColor: Colors.deepPurple,),
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
                backgroundImage:
                _image != null ? FileImage(_image!) : null,
                child: _image == null
                    ? const Icon(Icons.camera_alt, size: 35,)
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
              value: selectedCategory,
              onChanged: (v) =>
                  setState(() => selectedCategory = v.toString()),
            ),

            const SizedBox(height: 20),
            buildChips("Specialities", apiSkills, selectedSkills,
                loadingSkills),
            const SizedBox(height: 20),
            buildChips(
                "Abilities", apiAbility, selectedAbility, loadingAbility),
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
              child: const Text("Create Profile"),
            ),
          ],
        ),
      ),
    );
  }

  // ███████ HELPERS ███████
  Widget buildInput(String title, TextEditingController c,
      {TextInputType keyboard = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style:
            const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
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

  Widget buildChips(String title, List<String> list, List<String> selected,
      bool loading) {
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
