import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;

import 'package:psychics/repository/screens/Bottomnav/MainNavigationScreen.dart';
import 'package:psychics/repository/screens/CustomDrawer/CustomDrawer.dart';
import 'package:psychics/repository/screens/PsychicList/PsychicListScreen.dart';
import 'package:psychics/repository/screens/PsychicProfile/PsychicProfileScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/uihelper.dart';

class PsychicDashboardScreen extends StatefulWidget {
  const PsychicDashboardScreen({super.key});

  @override
  State<PsychicDashboardScreen> createState() => _PsychicDashboardScreenState();
}

class _PsychicDashboardScreenState extends State<PsychicDashboardScreen> {
  bool _showDrawer = false;
  List<dynamic> recommended = [];
  bool _loading = true;

  List<dynamic> categories = [];
  bool _serviceLoading = true;
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    fetchRecommended();
    loadProfileImage();
    fetchServices();
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

  Future<void> loadProfileImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final img = prefs.getString("profile_image") ?? prefs.getString("image") ?? "";
      if (img != null && img.isNotEmpty) {
        String url = img;
        if (!url.startsWith("http")) {
          url = "https://psychicbelive.mapps.site/${img.replaceFirst(RegExp(r'^/'), '')}";
        }
        if (!mounted) return;
        setState(() => profileImageUrl = url);
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> fetchServices() async {
    try {
      final res = await http.get(Uri.parse("https://psychicbelive.mapps.site/api/psychics"));
      if (!mounted) return;

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body)['data'] ?? [];

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

  // --------------------------------------------------------------------

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
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => setState(() => _showDrawer = true),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: (profileImageUrl != null && profileImageUrl!.isNotEmpty)
                    ? NetworkImage(profileImageUrl!)
                    : null,
                onBackgroundImageError: (profileImageUrl != null && profileImageUrl!.isNotEmpty)
                    ? (_, __) {
                  setState(() => profileImageUrl = null);
                }
                    : null,
                child: (profileImageUrl == null || profileImageUrl!.isEmpty)
                    ? Icon(
                  Icons.person,
                  size: 26,
                  color: Colors.deepPurple,
                )
                    : null,
              ),
            ),

            const SizedBox(width: 12),

            // Search Bar
            Expanded(
              child: GestureDetector(
                onTap: _openSearchSheet,
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.search, size: 22, color: Colors.blueAccent),
                      SizedBox(width: 10),
                      Text(
                        "Search Psychic...",
                        style: TextStyle(color: Colors.black54, fontSize: 14),
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

  // ⭐ Instagram-style Search Bottom Sheet
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
            height: MediaQuery.of(context).size.height * 0.85,
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

  // --------------------------------------------------------------------
  // ---------------------- DASHBOARD MAIN BODY -------------------------
  // --------------------------------------------------------------------

  Widget _buildDashboardBody() {
    return Column(
      children: [
        /// --- FIXED STATS BOX ---
        _psychicStatsSection(),

        SizedBox(height: 5.h),

        /// --- FIXED HEADER ---
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Recommended Psychics",
                style: TextStyle(
                  fontSize: 20.sp,
                  fontFamily: "Oswald",
                  fontWeight: FontWeight.bold,
                ),
              ),

              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MainNavigationScreen(initialIndex: 1),
                    ),
                  );
                },
                child: Text(
                  "See all ➜",
                  style: TextStyle(color: Colors.blue, fontSize: 14.sp),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 10.h),

        /// -------- SCROLLABLE LIST ONLY --------
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
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
                  "\$${psychic["price_per_minute"]}/Min",
                ),
              );
            },
          ),
        ),
      ],
    );
  }




  // ---------------------- NEW STATS WIDGETS (START) --------------------

  Widget _psychicStatsSection() {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black12.withOpacity(0.06),
        //     blurRadius: 20,
        //     spreadRadius: 2,
        //     offset: Offset(0, 6),
        //   ),
        // ],
      ),
      child: Column(
        children: [
          /// ---- TOP 2 CARDS ----
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _glassCard(
                icon: Icons.currency_rupee,
                title: "Total Earning",
                value: "0.00",
              ),
              _glassCard(
                icon: Icons.people_alt,
                title: "Total Users",
                value: "0.00",
              ),
            ],
          ),

          SizedBox(height: 10.h),

          /// ---- BOTTOM TWO SMALL CARDS ----
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _smallCard(
                icon: Icons.person,
                title: "Today's Users",
                value: "5.00",
              ),
              _ratingCard(),
            ],
          ),

          SizedBox(height: 15.h),

          /// -------- SEE ALL BUTTON --------
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.deepPurple),
                color: Colors.deepPurple.withOpacity(0.05),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "See All",
                    style: TextStyle(
                        color: Colors.deepPurple,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 6.w),
                  Icon(Icons.arrow_forward, color: Colors.deepPurple),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _glassCard({required IconData icon, required String title, required String value}) {
    return Container(
      width: 150.w,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.deepPurple.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.deepPurple, size: 26.sp),
              Spacer(),
              Text(value,
                  style: TextStyle(
                      fontSize: 22.sp,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 6.h),
          Text(title,
              style: TextStyle(fontSize: 13.sp, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _smallCard({required IconData icon, required String title, required String value}) {
    return Container(
      width: 150.w,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        color: Colors.white,
        border: Border.all(color: Colors.deepPurple.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          /// ICON LEFT + NUMBER RIGHT
          Row(
            children: [
              Icon(icon, size: 28.sp, color: Colors.deepPurple),
              Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          /// TITLE (CENTER)
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.sp, color: Colors.black54),
          ),
        ],
      ),
    );
  }


  Widget _ratingCard() {
    return Container(
      width: 150.w,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        color: Colors.white,
        border: Border.all(color: Colors.deepPurple.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber, size: 20.sp),
              SizedBox(width: 5.w),
              Text("4.9",
                  style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
            ],
          ),
          SizedBox(height: 3.h),
          Text("Total Rating", style: TextStyle(fontSize: 12.sp)),
          SizedBox(height: 6.h),
          LinearProgressIndicator(
            value: 0.9,
            backgroundColor: Colors.grey.shade300,
            color: Colors.deepPurple,
          ),
        ],
      ),
    );
  }


  Widget _bottomSmallBox({required IconData icon, required String label, required String value}) {
    return Container(
      width: 150.w,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.deepPurple.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.deepPurple),
          SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(fontSize: 12.sp)),
        ],
      ),
    );
  }

  Widget _ratingBox() {
    return Container(
      width: 150.w,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.deepPurple.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber),
              SizedBox(width: 4),
              Text("4.9", style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 4),
          Text("Total Rating", style: TextStyle(fontSize: 12.sp)),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: 0.9,
            backgroundColor: Colors.grey.shade300,
            color: Colors.deepPurple,
          )
        ],
      ),
    );
  }


  // ---------------------- NEW STATS WIDGETS (END) --------------------

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
              img: "a07f7f7ccc41b709abd504b472aad2e2b642c522.png",
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
// PSYCHIC CARD WIDGET
// ----------------------------
//  class PsychicCard extends StatelessWidget {
//   final String name;
//   final String image;
//   final String rate;
//
//   const PsychicCard(this.name, this.image, this.rate, {super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 160.w,
//       margin: EdgeInsets.only(right: 15.w),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF4F1F1),
//         borderRadius: BorderRadius.circular(18.r),
//         border: Border.all(color: Colors.deepPurple),
//       ),
//       child: Column(
//         children: [
//           SizedBox(height: 12.h),
//           CircleAvatar(
//             radius: 48.r,
//             backgroundColor: Colors.blue.withOpacity(0.08),
//             child: ClipOval(
//               child: Image.network(
//                 image,
//                 height: 90.h,
//                 width: 90.w,
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//           SizedBox(height: 10.h),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.star, color: Colors.amber, size: 18.sp),
//               SizedBox(width: 3.w),
//               Text("4.9", style: TextStyle(fontSize: 13.sp, color: Colors.black54)),
//             ],
//           ),
//           SizedBox(height: 4.h),
//           Text(name,
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600)),
//           Text(rate, style: TextStyle(fontSize: 13.sp, color: Colors.grey)),
//           SizedBox(height: 8.h),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               _button("Chat", Colors.deepPurple),
//               SizedBox(width: 7.w),
//               _button("Call", Colors.blue),
//             ],
//           ),
//           SizedBox(height: 12.h),
//         ],
//       ),
//     );
//   }
//
//   static Widget _button(String text, Color color) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(22.r),
//       ),
//       child: Text(
//         text,
//         style: TextStyle(color: color, fontSize: 13.sp, fontWeight: FontWeight.w600),
//       ),
//     );
//   }
// }

// ----------------------------
// PREMIUM CENTER CIRCLE CHART
// ----------------------------
class PsychicPerformanceCircle extends StatelessWidget {
  final double earningProgress;
  final double usersProgress;
  final double ratingProgress;

  const PsychicPerformanceCircle({
    super.key,
    required this.earningProgress,
    required this.usersProgress,
    required this.ratingProgress,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120.w,
      width: 120.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(120.w, 120.w),
            painter: _CirclePainter(
              earning: earningProgress,
              users: usersProgress,
              rating: ratingProgress,
            ),
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Performance",
                  style: TextStyle(fontSize: 11.sp, color: Colors.black54)),
              SizedBox(height: 4),
              Text("Score",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp)),
            ],
          )
        ],
      ),
    );
  }
}

class _CirclePainter extends CustomPainter {
  final double earning;
  final double users;
  final double rating;

  _CirclePainter({
    required this.earning,
    required this.users,
    required this.rating,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double stroke = 12;

    Paint base = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = size.width / 2 - stroke;

    canvas.drawCircle(center, radius, base);

    Paint earningPaint = Paint()
      ..color = Colors.deepPurple
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Paint usersPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Paint ratingPaint = Paint()
      ..color = Colors.amber
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    double startAngle = -90 * (3.14 / 180);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      earning * 3.14 * 2,
      false,
      earningPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle + earning * 3.14 * 2,
      users * 3.14 * 2,
      false,
      usersPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle + (earning + users) * 3.14 * 2,
      rating * 3.14 * 2,
      false,
      ratingPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class PsychicCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String rate;
  final String title;

  const PsychicCard(
      this.name,
      this.imageUrl,
      this.rate, {
        this.title = "",
        super.key,
      });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Color(0xffF3F6FB),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Image.network(
              imageUrl,
              height: 100.h,
              width: 80.h,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) =>
              const Icon(Icons.person, size: 60),
            ),
          ),

          SizedBox(width: 12.w),

          // RIGHT SIDE
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // NAME + PRICE
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.deepPurple),
                      ),
                      child: Text(
                        rate == "\$0/min" ? "Free" : rate,
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  ],
                ),

                SizedBox(height: 3.h),

                // LANGUAGES
                Text(
                  "English, Hindi",
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.black87,
                  ),
                ),

                SizedBox(height: 3.h),

                // EXPERIENCE
                Text(
                  "Exp - 5 year",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[700],
                  ),
                ),

                SizedBox(height: 10.h),

                // BOTTOM ROW
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // RATING
                    Row(
                      children: [
                        Icon(Icons.star,
                            size: 20.sp, color: Colors.black),
                        SizedBox(width: 4.w),
                        Text(
                          "3.5",
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ],
                    ),

                    // CALL + CHAT BUTTONS
                    Row(
                      children: [
                        _actionButton("Call"),
                        SizedBox(width: 8.w),
                        _actionButton("Chat"),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.deepPurple),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.black,
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}










