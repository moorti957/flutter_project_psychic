import 'package:flutter/material.dart';

class UiHelper {
  /// 🔹 Custom Image Loader
  /// Automatically loads images from "assets/images/"
  /// Example → UiHelper.CustomImage(img: "pana.png")
  static Widget CustomImage({
    required String img,
    double? height,
    double? width,
    // Color? color,
    BoxFit fit = BoxFit.cover,
  }) {
    return Image.asset(
      "assets/images/$img",
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {

        return const Icon(Icons.broken_image, size: 40, color: Colors.grey);
      },
    );
  }
}
