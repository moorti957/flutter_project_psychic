import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:psychics/repository/screens/Bottomnav/MainNavigationScreen.dart';
import 'package:psychics/repository/screens/CustomDrawer/CustomDrawer.dart';
import 'package:psychics/repository/screens/Dashboard/AnimatedBanner.dart';
import 'package:psychics/repository/screens/PsychicList/PsychicListScreen.dart';
import 'package:psychics/repository/screens/PsychicProfile/PsychicProfileScreen.dart';
import '../../widgets/uihelper.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _showDrawer = false;
  List<dynamic> recommended = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    fetchRecommended();
    fetchServices(); // ⭐ यह नया जोड़ना है
  }

  String buildImageUrl(dynamic photo) {
    if (photo == null) return "https://i.pravatar.cc/200";
    String p = photo.toString().trim();
    if (p.startsWith("http")) return p;
    if (p.startsWith("/uploads/") || p.startsWith("uploads/")) {
      return "https://psychicbelive.mapps.site/${p.replaceFirst(RegExp(r'^/'), '')}";
    }
    if (p.startsWith("users/")) {
      return "https://psychicbelive.mapps.site/uploads/$p";
    }
    return "https://psychicbelive.mapps.site/uploads/users/$p";
  }

  Future<void> fetchRecommended() async {
    try {
      final res = await http.get(Uri.parse("https://psychicbelive.mapps.site/api/psychics"));
      if (!mounted) return;

      if (res.statusCode == 200) {
        setState(() {
          recommended = jsonDecode(res.body)['data'] ?? [];
          _loading = false;
        });
      } else {
        setState(() {
          recommended = [];
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        recommended = [];
        _loading = false;
      });
    }
  }
  List<dynamic> categories = [];
  bool _serviceLoading = true;

  Future<void> fetchServices() async {
    try {
      final res = await http.get(Uri.parse("https://psychicbelive.mapps.site/api/psychics"));
      if (!mounted) return;

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body)['data'] ?? [];

        // 🔥 सभी Psychics से unique categories collect करो
        Set<String> uniqueCategories = {};

        for (var psychic in data) {
          if (psychic["categories"] != null) {
            for (var c in psychic["categories"]) {
              uniqueCategories.add(c["name"].toString());
            }
          }
        }

        setState(() {
          categories = uniqueCategories.toList();
          _serviceLoading = false;
        });
      } else {
        setState(() {
          categories = [];
          _serviceLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        categories = [];
        _serviceLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,

      body: Stack(
        children: [
          Column(
            children: [
              _buildAppBar(),
              Expanded(child: _buildDashboardBody()),
            ],
          ),

          if (_showDrawer)
            GestureDetector(
              onTap: () => setState(() => _showDrawer = false),
              child: Row(
                children: [
                  const CustomDrawer(),
                  Expanded(child: Container(color: Colors.black26)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ---------------- TOP APPBAR ----------------
  Widget _buildAppBar() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => setState(() => _showDrawer = true),
              child: CircleAvatar(
                radius: 22.r,
                child: ClipOval(
                  child: UiHelper.CustomImage(
                    img: "4d1244c8cd23f93c1a9d40fe9c4df8756afecddf.png",
                    height: 44.h,
                    width: 44.w,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            SizedBox(width: 12.w),

            // ⭐ Instagram-style Search Bar
            Expanded(
              child: GestureDetector(
                onTap: _openSearchSheet,
                child: Container(
                  height: 42.h,
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30.r),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, size: 22.sp, color: Colors.blueAccent),
                      SizedBox(width: 10.w),
                      Text(
                        "Search Psychic...",
                        style: TextStyle(color: Colors.black54, fontSize: 14.sp),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ⭐ Bottom Sheet Search (Instagram style)
  void _openSearchSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: MediaQuery.of(context).size.height * 10.0,
            padding: EdgeInsets.all(16.w),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 25.h),
                TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: "Search Psychic...",
                    prefixIcon: Icon(Icons.search, color: Colors.deepPurple),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                Text(
                  "Recent Searches",
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 10.h),

                Expanded(
                  child: ListView(
                    children: const [
                      ListTile(
                        leading: Icon(Icons.history),
                        title: Text("Love Reading"),
                      ),
                      ListTile(
                        leading: Icon(Icons.history),
                        title: Text("Career Advice"),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------- HOME BODY ----------------
  Widget _buildDashboardBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AnimatedBanner(),
          SizedBox(height: 25.h),

          Text(
            "Psychic Services",
            style: TextStyle(fontSize: 20.sp, fontFamily: "Oswald", fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 15.h),

          SizedBox(
            height: 115.h,
            child: _serviceLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                String title = categories[index];   // ab yaha sirf name hai!
                return _serviceCard(
                  title,
                  "https://i.pravatar.cc/100?img=${index+10}",
                );
              },
            ),
          ),



          SizedBox(height: 20.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Recommended Psychics",
                style: TextStyle(fontSize: 20.sp, fontFamily: "Oswald", fontWeight: FontWeight.bold),
              ),

              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                        const MainNavigationScreen(initialIndex: 1)),
                  );
                },
                child: Text(
                  "See all ➜",
                  style: TextStyle(color: Colors.blue, fontSize: 14.sp),
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          SizedBox(
            height: 250.h,
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recommended.length,
              itemBuilder: (context, index) {
                final psychic = recommended[index];
                final user = psychic["user"] ?? {};
                String imageUrl = buildImageUrl(user["profile_photo"]);

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PsychicProfileScreen(data: psychic),
                      ),
                    );
                  },
                  child: PsychicCard(
                    psychic["display_name"] ?? "Unknown",
                    imageUrl,
                    "\$${psychic["price_per_minute"]}/min",
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _serviceCard(String title, String imgPath) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PsychicListScreen(
              selectedCategoryName: title,
            ),
          ),
        );
      },
      child: Container(
        width: 105.w,
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
        margin: EdgeInsets.symmetric(horizontal: 5.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.deepPurple),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            UiHelper.CustomImage(
              img: "a07f7f7ccc41b709abd504b472aad2e2b642c522.png",   // ⭐ Fixed Dummy Image
              height: 45.h,
              width: 45.w,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 6.h),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }




}

// ----------------------------
// ANIMATED SERVICE CARD
// ----------------------------
class AnimatedServiceCard extends StatefulWidget {
  final String title;
  final String image;

  const AnimatedServiceCard({super.key, required this.title, required this.image});

  @override
  State<AnimatedServiceCard> createState() => _AnimatedServiceCardState();
}

class _AnimatedServiceCardState extends State<AnimatedServiceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: -8.h)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 115.w,
      padding: EdgeInsets.symmetric(vertical: 14.h),
      margin: EdgeInsets.symmetric(horizontal: 5.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.deepPurple),
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (_, child) {
              return Transform.translate(
                offset: Offset(0, _animation.value),
                child: UiHelper.CustomImage(
                  img: widget.image,
                  height: 55.h,
                  width: 55.w,
                ),
              );
            },
          ),
          SizedBox(height: 8.h),
          Text(widget.title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ----------------------------
// PSYCHIC CARD
// ----------------------------
class PsychicCard extends StatelessWidget {
  final String name;
  final String image;
  final String rate;

  const PsychicCard(this.name, this.image, this.rate, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160.w,
      margin: EdgeInsets.only(right: 15.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F1F1),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.deepPurple),
      ),
      child: Column(
        children: [
          SizedBox(height: 12.h),
          CircleAvatar(
            radius: 48.r,
            backgroundColor: Colors.blue.withOpacity(0.08),
            child: ClipOval(
              child: Image.network(
                image,
                height: 90.h,
                width: 90.w,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: Colors.amber, size: 18.sp),
              SizedBox(width: 3.w),
              Text("4.9", style: TextStyle(fontSize: 13.sp, color: Colors.black54)),
            ],
          ),
          SizedBox(height: 4.h),
          Text(name,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600)),
          Text(rate, style: TextStyle(fontSize: 13.sp, color: Colors.grey)),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _button("Chat", Colors.deepPurple),
              SizedBox(width: 7.w),
              _button("Call", Colors.blue),
            ],
          ),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }

  static Widget _button(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 13.sp, fontWeight: FontWeight.w600),
      ),
    );
  }
}
