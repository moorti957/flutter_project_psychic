import 'package:flutter/material.dart';
import 'dart:async';
import '../../widgets/uihelper.dart';

class AnimatedBanner extends StatefulWidget {
  const AnimatedBanner({super.key});

  @override
  State<AnimatedBanner> createState() => _AnimatedBannerState();
}

class _AnimatedBannerState extends State<AnimatedBanner>
    with TickerProviderStateMixin {
  int _currentTextIndex = 0;
  final List<Map<String, String>> _bannerTexts = [
    {
      "title": "COMPLIMENTARY",
      "subtitle": "15-min reading!",
    },
  ];

  late Timer _textTimer;

  @override
  void initState() {
    super.initState();
    _textTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        _currentTextIndex =
            (_currentTextIndex + 1) % _bannerTexts.length;
      });
    });
  }

  @override
  void dispose() {
    _textTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textData = _bannerTexts[_currentTextIndex];

    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        image: const DecorationImage(
          image: AssetImage("assets/images/WhatsApp Image 2025-11-17 at 15.36.13_d1f0af83.jpg"), // ← अपनी image यहाँ डालना
          fit: BoxFit.cover,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            // offset: Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Positioned(
          //   right: -30,
          //   bottom: -42,
          //   child: UiHelper.CustomImage(
          //     img: "5829292ad755c47f7fcedc0444e1e0ac0bbe258f.png",
          //     height: 250,
          //     width: 250,
          //     fit: BoxFit.contain,
          //   ),
          // ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "You have unlocked a",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontFamily: 'Oswald',
                  ),
                ),
                const SizedBox(height: 4),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 900),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                  child: Text(
                    textData["title"]!,
                    key: ValueKey<String>(textData["title"]!),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      fontFamily: 'Oswald',
                    ),
                  ),
                ),

                const SizedBox(height: 2),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 800),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                  child: Text(
                    textData["subtitle"]!,
                    key: ValueKey<String>(textData["subtitle"]!),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontFamily: 'Oswald',
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Positioned(
            bottom: 15,
            left: 18,
            child: MovingArrowButton(),
          ),
        ],
      ),
    );
  }
}

/// 🔥 Moving Arrow Button + RGB Border Animation Attached
class MovingArrowButton extends StatefulWidget {
  const MovingArrowButton({super.key});

  @override
  State<MovingArrowButton> createState() => _MovingArrowButtonState();
}

class _MovingArrowButtonState extends State<MovingArrowButton>
    with TickerProviderStateMixin {
  late AnimationController _arrowController;
  late Animation<double> _arrowAnimation;

  // RGB animation
  late AnimationController _rgbController;
  late Animation<Color?> _rgbColor;

  @override
  void initState() {
    super.initState();

    // Arrow animation
    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _arrowAnimation = Tween<double>(begin: 0, end: 6).animate(
      CurvedAnimation(parent: _arrowController, curve: Curves.easeInOut),
    );

    // RGB border animation
    _rgbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _rgbColor = _rgbController.drive(
      TweenSequence<Color?>([
        TweenSequenceItem(weight: 1, tween: ColorTween(begin: Colors.deepPurple, end: Colors.deepPurpleAccent)),
        TweenSequenceItem(weight: 1, tween: ColorTween(begin: Colors.deepPurpleAccent, end: Colors.deepPurpleAccent)),

      ]),
    );
  }

  @override
  void dispose() {
    _arrowController.dispose();
    _rgbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rgbColor,
      builder: (context, child) {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0x3f016f),
            elevation: 5,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: _rgbColor.value ?? Colors.white,
                width: 2.2,
              ),
            ),
          ),
          onPressed: () {},
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Claim Now",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(width: 6),
              AnimatedBuilder(
                animation: _arrowAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_arrowAnimation.value, 0),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
