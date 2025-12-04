// import 'package:demopro/repository/screens/Bottomnav/Bottomnavscreen.dart';
import 'package:flutter/material.dart';
import '../../widgets/uihelper.dart';
import '../dashboard/dashboardscreen.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {

  @override
  void initState() {
    super.initState();


    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    });
    // Navigator.push(context, MaterialPageRoute(builder: (context)=>BottomNavScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🖼️ Top Illustration Image
              SizedBox(
                height: 280,
                width: 280,
                child: UiHelper.CustomImage(
                  img: "pana.png",
                ),
              ),

              const SizedBox(height: 40),

              // ✅ Success Tick Icon
              Container(
                height: 70,
                width: 70,
                decoration: const BoxDecoration(
                  color: Colors.deepPurple,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 40,
                ),
              ),

              const SizedBox(height: 25),

              // 🟣 Message Text
              const Text(
                "Mobile verification has successfully done",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
