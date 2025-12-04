import 'dart:async';
import 'package:flutter/material.dart';
import '../../widgets/uihelper.dart';

class RecommendedPsychics extends StatefulWidget {
  const RecommendedPsychics({super.key});

  @override
  State<RecommendedPsychics> createState() => _RecommendedPsychicsState();
}

class _RecommendedPsychicsState extends State<RecommendedPsychics> {
  final PageController _pageController = PageController(viewportFraction: 0.65);
  int _currentPage = 0;
  late Timer _timer;

  final List<Map<String, String>> _psychics = [
    {"name": "Brother Orion", "image": "09e317bd51f611723c848b89ac5a637dde24dfba.png", "rate": "\$3 /min"},
    {"name": "Sophia Hart", "image": "8541c87f30438bdf0b093c59ceb0ab8f1d4f69f4.png", "rate": "\$2 /min"},
    {"name": "Richard Lee", "image": "85d17abda12164bf52936255295e68b88b04f1e0.jpg", "rate": "\$2 /min"},
    {"name": "Crystal Moon", "image": "7c62e1ae-b4e3-4009-816b-1446b735aa30.png", "rate": "\$4 /min"},
    {"name": "Mia Star", "image": "5829292ad755c47f7fcedc0444e1e0ac0bbe258f.png", "rate": "\$3 /min"},
    {"name": "Angel Grace", "image": "8f18b2e4f1c34e203f071e0082c808196d4d9198.png", "rate": "\$5 /min"},
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    // Slow smooth auto-slide every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        _currentPage++;
        if (_currentPage >= _psychics.length) {
          _currentPage = 0;
        }
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 10),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🔮 Title Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              "Recommended Psychics",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'Poppins',
              ),
            ),
            Text(
              "See all ➜",
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // 🌟 Auto-sliding Psychics Carousel
        SizedBox(
          height: 270,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _psychics.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              final data = _psychics[index];
              final isActive = index == _currentPage;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: isActive ? 5 : 20),
                transform: Matrix4.identity()
                  ..translate(0.0, isActive ? -10.0 : 0.0)
                  ..scale(isActive ? 1.05 : 0.95),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: isActive ? Colors.black26 : Colors.black12,
                      blurRadius: isActive ? 8 : 4,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: _buildPsychicCard(data["name"]!, data["image"]!, data["rate"]!),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPsychicCard(String name, String image, String rate) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 45,
          backgroundColor: Colors.blue.withOpacity(0.05),
          child: ClipOval(
            child: UiHelper.CustomImage(
              img: image,
              height: 85,
              width: 85,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.star, color: Colors.amber, size: 18),
            SizedBox(width: 2),
            Text(
              "4.9",
              style: TextStyle(
                fontSize: 13,
                color: Colors.black54,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            fontFamily: 'Poppins',
          ),
        ),
        Text(
          rate,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _bottomButton("Chat", Colors.green),
            const SizedBox(width: 6),
            _bottomButton("Call", Colors.blue),
          ],
        ),
      ],
    );
  }

  static Widget _bottomButton(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 13,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}
