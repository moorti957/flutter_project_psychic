import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:psychics/repository/screens/Bottomnav/MainNavigationScreen.dart';
import '../PsychicProfile/PsychicProfileScreen.dart';

class PsychicListScreen extends StatefulWidget {
  final String? selectedCategoryName;

  const PsychicListScreen({
    super.key,
    this.selectedCategoryName,
  });

  @override
  State<PsychicListScreen> createState() => _PsychicListScreenState();
}


class _PsychicListScreenState extends State<PsychicListScreen> {
  List<dynamic> allPsychics = []; // full list from server
  List<dynamic> psychics = []; // currently shown (filtered)
  bool isLoading = true;

  // Filter data (from API)
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> abilities = [];
  List<Map<String, dynamic>> tools = [];

  // Selected filter state
  Set<int> selectedCategoryIds = {};
  Set<int> selectedAbilityIds = {};
  Set<int> selectedToolIds = {};
  int conversationType = 0; // 0=Any, 1=Call, 2=Chat
  double minPrice = 20;
  double maxPrice = 80000;

  // Local UI copies shown inside sheet (so user can cancel)
  Set<int> _tmpSelectedCategoryIds = {};
  Set<int> _tmpSelectedAbilityIds = {};
  Set<int> _tmpSelectedToolIds = {};
  int _tmpConversationType = 0;
  double _tmpMinPrice = 20;
  double _tmpMaxPrice = 80000;

  @override
  void initState() {
    super.initState();

    _loadAllData().then((_) {
      if (widget.selectedCategoryName != null) {
        _autoSelectCategory(widget.selectedCategoryName!);
      }
    });
  }


  Future<void> _loadAllData() async {
    setState(() {
      isLoading = true;
    });

    await Future.wait([
      fetchPsychics(),
      fetchCategories(),
      fetchAbilities(),
      fetchTools(),
    ]);

    // copy allPsychics into psychics initially
    setState(() {
      psychics = List.from(allPsychics);
      isLoading = false;
    });
  }
  void _autoSelectCategory(String categoryName) {
    for (var c in categories) {
      if (c["name"].toString().toLowerCase() ==
          categoryName.toLowerCase()) {
        selectedCategoryIds = {c["id"]};
        break;
      }
    }

    applyFilters(); // finally apply filter
  }


  // ---------------- API: Psychics ----------------
  Future<void> fetchPsychics() async {
    try {
      final response =
      await http.get(Uri.parse("https://psychicbelive.mapps.site/api/psychics"));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        allPsychics = jsonData["data"] ?? [];
      } else {
        allPsychics = [];
      }
    } catch (e) {
      allPsychics = [];
    }
  }

  // ---------------- API: Categories ----------------
  Future<void> fetchCategories() async {
    try {
      final res = await http
          .get(
          Uri.parse("https://psychicbelive.mapps.site/api/psychics_categories"));

      if (res.statusCode == 200) {
        final j = json.decode(res.body);
        final List d = j["data"] ?? [];
        categories = d.map<Map<String, dynamic>>((e) {
          return {
            "id": e["id"],
            "name": e["name"],
          };
        }).toList();
      } else {
        categories = [];
      }
    } catch (e) {
      categories = [];
    }
  }

  // ---------------- API: Abilities ----------------
  Future<void> fetchAbilities() async {
    try {
      final res =
      await http.get(
          Uri.parse("https://psychicbelive.mapps.site/api/psychics_ability"));

      if (res.statusCode == 200) {
        final j = json.decode(res.body);
        final List d = j["data"] ?? [];
        abilities = d.map<Map<String, dynamic>>((e) {
          return {"id": e["id"], "name": e["name"]};
        }).toList();
      } else {
        abilities = [];
      }
    } catch (e) {
      abilities = [];
    }
  }

  // ---------------- API: Tools ----------------
  Future<void> fetchTools() async {
    try {
      final res =
      await http.get(
          Uri.parse("https://psychicbelive.mapps.site/api/psychics_tools"));

      if (res.statusCode == 200) {
        final j = json.decode(res.body);
        final List d = j["data"] ?? [];
        tools = d.map<Map<String, dynamic>>((e) {
          return {"id": e["id"], "name": e["name"]};
        }).toList();
      } else {
        tools = [];
      }
    } catch (e) {
      tools = [];
    }
  }

  // ---------------- Apply frontend filters ----------------
  void applyFilters() {
    List<dynamic> filtered = allPsychics.where((p) {
      // --- Categories filter ---
      if (selectedCategoryIds.isNotEmpty) {
        final pCategories = (p["categories"] ?? []) as List<dynamic>;
        // pCategories elements may be maps with id or ints; handle both.
        final List<int> pCatIds = pCategories.map<int>((c) {
          if (c is int) return c;
          if (c is Map && c["id"] != null) return c["id"] as int;
          return -1;
        }).toList();
        if (!pCatIds.any((id) => selectedCategoryIds.contains(id))) {
          return false;
        }
      }

      // --- Abilities filter ---
      if (selectedAbilityIds.isNotEmpty) {
        final pAbilities = (p["abilities"] ?? p["ability"] ?? []) as List<
            dynamic>;
        final List<int> pAbIds = pAbilities.map<int>((a) {
          if (a is int) return a;
          if (a is Map && a["id"] != null) return a["id"] as int;
          return -1;
        }).toList();
        if (!pAbIds.any((id) => selectedAbilityIds.contains(id))) {
          return false;
        }
      }

      // --- Tools filter ---
      if (selectedToolIds.isNotEmpty) {
        final pTools = (p["tools"] ?? []) as List<dynamic>;
        final List<int> pToolIds = pTools.map<int>((t) {
          if (t is int) return t;
          if (t is Map && t["id"] != null) return t["id"] as int;
          return -1;
        }).toList();
        if (!pToolIds.any((id) => selectedToolIds.contains(id))) {
          return false;
        }
      }

      // --- Price filter ---
      final double price = 0 +
          (p["price_per_minute"] is num ? (p["price_per_minute"] as num)
              .toDouble() : double.tryParse("${p["price_per_minute"]}") ?? 0);
      if (price < minPrice || price > maxPrice) {
        return false;
      }

      // --- Conversation type filter (best-effort matching) ---
      // We don't know exact backend key; try common keys: p['conversation_type'] or p['modes']
      if (conversationType != 0) {
        // 1 => Call, 2 => Chat
        final int want = conversationType;
        bool match = false;

        // try flags
        if (p["conversation_type"] != null) {
          final ct = p["conversation_type"];
          if (ct is int && ct == want) match = true;
          if (ct is String &&
              ct.toLowerCase().contains(want == 1 ? "call" : "chat"))
            match = true;
        }

        // try modes list
        if (!match && p["modes"] != null && p["modes"] is List) {
          final m = (p["modes"] as List)
              .map((e) => e.toString().toLowerCase())
              .join(",");
          if (want == 1 && m.contains("call")) match = true;
          if (want == 2 && m.contains("chat")) match = true;
        }

        if (!match) return false;
      }

      return true;
    }).toList();

    setState(() {
      psychics = filtered;
    });
  }

  // Reset filters
  void clearFilters() {
    setState(() {
      selectedCategoryIds.clear();
      selectedAbilityIds.clear();
      selectedToolIds.clear();
      conversationType = 0;
      minPrice = 20;
      maxPrice = 80000;
      psychics = List.from(allPsychics);
    });
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        elevation: 2,
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => const MainNavigationScreen(initialIndex: 0)),
            );
          },
        ),
        title: const Text(
          "Psychics List",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: const Icon(Icons.filter_alt_rounded, color: Colors.white),
              onPressed: () {
                _openFilterSheet(context);
              },
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Column(
          children: [
            if (isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: Colors.blue),
                ),
              )
            else
              if (psychics.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text(
                        "No psychics found", style: TextStyle(fontSize: 16)),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: psychics.length,
                    itemBuilder: (context, index) {
                      final data = psychics[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PsychicProfileScreen(data: data),
                            ),
                          );
                        },
                        child: _psychicCard(data),
                      );
                    },
                  ),
                ),
          ],
        ),
      ),
      floatingActionButton: (selectedCategoryIds.isNotEmpty ||
          selectedAbilityIds.isNotEmpty ||
          selectedToolIds.isNotEmpty ||
          conversationType != 0 ||
          minPrice != 20 ||
          maxPrice != 80000)
          ? FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.filter_list),
        label: const Text("Clear Filters"),
        onPressed: clearFilters,
      )
          : null,
    );
  }

  // ------------------------- PSYCHIC CARD UI -------------------------
  Widget _psychicCard(dynamic data) {
    final user = data["user"] ?? {};
    final categories = data["categories"] ?? [];

    final imageUrl = (user["profile_photo"] != null && user["profile_photo"]
        .toString()
        .isNotEmpty)
        ? "https://psychicbelive.mapps.site/uploads/users/${user["profile_photo"]}"
        : "";

    final skills = categories.isNotEmpty
        ? categories.map((c) =>
    (c is Map && c["name"] != null) ? c["name"] : c.toString()).join(", ")
        : "No Skills";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              bottomLeft: Radius.circular(18),
            ),
            child: imageUrl.isNotEmpty
                ? Image.network(
              imageUrl,
              height: 145,
              width: 100,
              fit: BoxFit.cover,
            )
                : Container(
              height: 140,
              width: 100,
              color: Colors.grey.shade300,
              child: const Icon(Icons.person, size: 40),
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data["display_name"] ?? "Unknown",
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                          Icons.diamond, size: 16, color: Colors.blueAccent),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          skills,
                          style: const TextStyle(fontSize: 13, color: Colors
                              .black54),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${data["experience_years"] ?? 0} Years Exp.",
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "\$${data["price_per_minute"] ?? '0'}/min",
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _actionButton(Icons.chat, "Chat", Colors.deepPurple),
                      const SizedBox(width: 6),
                      _actionButton(Icons.call, "Call", Colors.blue),
                      const SizedBox(width: 6),
                      _actionButton(Icons.videocam, "Video", Colors.purple),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String title, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: color.withOpacity(0.08),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 13),
            const SizedBox(width: 3),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openFilterSheet(BuildContext context) {
    // temp filter copy
    _tmpSelectedCategoryIds = Set<int>.from(selectedCategoryIds);
    _tmpSelectedAbilityIds = Set<int>.from(selectedAbilityIds);
    _tmpSelectedToolIds = Set<int>.from(selectedToolIds);
    _tmpConversationType = conversationType;
    _tmpMinPrice = minPrice;
    _tmpMaxPrice = maxPrice;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.90,
          child: StatefulBuilder(
            builder: (context, setState) {
              return Container(
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    // HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Filters",
                          style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.close, size: 28),
                        )
                      ],
                    ),

                    const SizedBox(height: 15),

                    Expanded(
                      child: ListView(
                        children: [
                          // ---------------- SPECIALITIES ----------------
                          const Text("Specialities",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),

                          if (categories.isEmpty)
                            const Text("No categories found")
                          else
                            Column(
                              children: List.generate(categories.length, (i) {
                                final c = categories[i];
                                return CheckboxListTile(
                                  value: _tmpSelectedCategoryIds.contains(
                                      c["id"]),
                                  activeColor: Colors.deepPurple,
                                  onChanged: (v) {
                                    setState(() {
                                      if (v == true) {
                                        _tmpSelectedCategoryIds.add(c["id"]);
                                      } else {
                                        _tmpSelectedCategoryIds.remove(c["id"]);
                                      }
                                    });
                                  },
                                  title: Text(c["name"]),
                                );
                              }),
                            ),

                          const Divider(height: 30),

                          // ---------------- ABILITIES ----------------
                          const Text("Abilities",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),

                          if (abilities.isEmpty)
                            const Text("No abilities found")
                          else
                            Column(
                              children: List.generate(abilities.length, (i) {
                                final a = abilities[i];
                                return CheckboxListTile(
                                  value: _tmpSelectedAbilityIds.contains(
                                      a["id"]),
                                  activeColor: Colors.deepPurple,
                                  onChanged: (v) {
                                    setState(() {
                                      if (v == true) {
                                        _tmpSelectedAbilityIds.add(a["id"]);
                                      } else {
                                        _tmpSelectedAbilityIds.remove(a["id"]);
                                      }
                                    });
                                  },
                                  title: Text(a["name"]),
                                );
                              }),
                            ),

                          const Divider(height: 30),

                          // ---------------- TOOLS ----------------
                          const Text("Tools",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),

                          if (tools.isEmpty)
                            const Text("No tools found")
                          else
                            Column(
                              children: List.generate(tools.length, (i) {
                                final t = tools[i];
                                return CheckboxListTile(
                                  value: _tmpSelectedToolIds.contains(t["id"]),
                                  activeColor: Colors.deepPurple,
                                  onChanged: (v) {
                                    setState(() {
                                      if (v == true) {
                                        _tmpSelectedToolIds.add(t["id"]);
                                      } else {
                                        _tmpSelectedToolIds.remove(t["id"]);
                                      }
                                    });
                                  },
                                  title: Text(t["name"]),
                                );
                              }),
                            ),

                          const Divider(height: 30),

                          // ---------------- CONVERSATION TYPE ----------------
                          const Text("Conversation Type",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          _conversationTile(
                            isSelected: _tmpConversationType == 0,
                            title: "Any",
                            count: "(1945)",
                            onTap: () =>
                                setState(() => _tmpConversationType = 0),
                          ),
                          _conversationTile(
                            isSelected: _tmpConversationType == 1,
                            title: "Call",
                            count: "(3136)",
                            onTap: () =>
                                setState(() => _tmpConversationType = 1),
                          ),
                          _conversationTile(
                            isSelected: _tmpConversationType == 2,
                            title: "Chat",
                            count: "(2470)",
                            onTap: () =>
                                setState(() => _tmpConversationType = 2),
                          ),

                          const Divider(height: 30),

                          // ---------------- PRICE RANGE ----------------
                          const Text("Price Range (per minute)",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          RangeSlider(
                            values: RangeValues(_tmpMinPrice, _tmpMaxPrice),
                            min: 20,
                            max: 100000,
                            activeColor: Colors.deepPurple,
                            onChanged: (values) {
                              setState(() {
                                _tmpMinPrice = values.start;
                                _tmpMaxPrice = values.end;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    // APPLY BTN
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          // Commit final changes
                          selectedCategoryIds =
                          Set<int>.from(_tmpSelectedCategoryIds);
                          selectedAbilityIds =
                          Set<int>.from(_tmpSelectedAbilityIds);
                          selectedToolIds =
                          Set<int>.from(_tmpSelectedToolIds);
                          conversationType = _tmpConversationType;
                          minPrice = _tmpMinPrice;
                          maxPrice = _tmpMaxPrice;

                          applyFilters();
                          Navigator.pop(context);
                        },
                        child: const Text("Apply Filters",
                            style: TextStyle(
                                color: Colors.white, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

// ------------------------
// OLD DESIGN Conversation Tile
// ------------------------
  Widget _conversationTile({
    required bool isSelected,
    required String title,
    required String count,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Switch(
            value: isSelected,
            activeColor: Colors.deepPurple,
            onChanged: (_) => onTap(),
          ),
          Expanded(child: Text(title)),
          Text(count, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}
