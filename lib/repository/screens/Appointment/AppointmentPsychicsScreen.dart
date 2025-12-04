// APPOINTMENT BOOKING FINAL VERSION
// (Your Screen + API Booking + WebView integrated)

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'PaymentWebView.dart'; // <-- STEP-4 ( नीचे दिया है )

class AppointmentPsychicsScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const AppointmentPsychicsScreen({super.key, required this.data});

  @override
  State<AppointmentPsychicsScreen> createState() =>
      _AppointmentPsychicsScreenState();
}

class _AppointmentPsychicsScreenState extends State<AppointmentPsychicsScreen> {
  late Map<String, dynamic> psychic;
  late Map<String, dynamic> user;
  late List categories;

  DateTime currentMonth = DateTime.now();
  int? _selectedDay;
  String? _selectedTime;
  String? _selectedType;
  int? _selectedMinutes;

  final List<String> _timeSlots = [
    "10:00 AM",
    "11:30 AM",
    "01:00 PM",
    "02:30 PM",
    "04:00 PM",
    "05:30 PM",
  ];

  final List<String> _appointmentTypes = ["Call", "Video Call", "Chat"];

  final TextEditingController _minutesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    psychic = widget.data;
    user = widget.data["user"];
    categories = widget.data["categories"];
    _minutesController.addListener(_onMinutesChanged);
  }

  @override
  void dispose() {
    _minutesController.removeListener(_onMinutesChanged);
    _minutesController.dispose();
    super.dispose();
  }

  void _onMinutesChanged() {
    final text = _minutesController.text.trim();
    if (text.isEmpty) {
      setState(() => _selectedMinutes = null);
      return;
    }
    final val = int.tryParse(text);
    if (val == null || val <= 0) {
      setState(() => _selectedMinutes = null);
      return;
    }
    setState(() => _selectedMinutes = val);
  }
  String convertTo24Hour(String time12h) {
    // 1. Remove weird unicode spaces
    String clean = time12h.replaceAll(RegExp(r'\s+'), " ").trim();

    // 2. Parse properly
    final parsed = DateFormat("hh:mm a").parse(clean);

    // 3. Convert to 24-hour format
    return DateFormat("HH:mm").format(parsed);
  }



  double get _pricePerMin {
    final raw = psychic["price_per_minute"];
    if (raw == null) return 0.0;
    return double.tryParse(raw.toString()) ?? 0.0;
  }

  double get _totalAmount {
    if ((_selectedMinutes ?? 0) <= 0) return 0.0;
    return _pricePerMin * (_selectedMinutes ?? 0);
  }

  // ---------------------------------------------------------
  // 🔥🔥🔥 STEP–2 : API CALL – Create Booking
  // ---------------------------------------------------------
  Future<void> createBooking() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Session expired. Please login again.")),
      );
      return;
    }

    // SERVICE TYPE MAP
    String mapServiceType(String type) {
      if (type == "Call") return "call";
      if (type == "Video Call") return "video";
      return "chat";
    }

    // DATE FORMAT
    final selectedDate = DateFormat("yyyy-MM-dd").format(
      DateTime(currentMonth.year, currentMonth.month, _selectedDay!),
    );

    // BODY
    final body = {
      "psychic_id": psychic["id"].toString(),
      "service_type": mapServiceType(_selectedType!),
      "date": selectedDate,
      "time": convertTo24Hour(_selectedTime!),   // e.g. 11:30 AM → 11:30
      "timezone": "UTC",
      "message": "Booking request"
    };

    print("BOOKING BODY == $body");

    final url = Uri.parse("https://psychicbelive.mapps.site/api/psychic/booking");

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    print("BOOKING STATUS : ${response.statusCode}");
    print("BOOKING RESPONSE : ${response.body}");

    // HANDLE RESPONSE
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        int bookingId = data["booking_id"];
        String amount = data["amount"].toString();

        print("BOOKING ID = $bookingId");

        // ------------ STEP–2 CALL PAYMENT TOKEN API ------------
        requestPaymentToken(bookingId, amount);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Booking failed: ${data["message"]}")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Booking failed: ${response.body}")),
      );
    }
  }




  // ---------------------------------------------------------
  // UI START
  // ---------------------------------------------------------

  AppBar _appBar() {
    return AppBar(
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text("Appointment Psychics",
          style: TextStyle(fontWeight: FontWeight.w600)),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A0072), Color(0xFF2A0A6B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }
  // -----------------------------
  // WEEK DAYS (Sun–Sat)
  // -----------------------------
  Widget _buildWeekDays() {
    const days = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days
          .map(
            (d) => SizedBox(
          width: 44,
          child: Center(
            child: Text(
              d,
              style: const TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ),
        ),
      )
          .toList(),
    );
  }

  // -----------------------------
  // CALENDAR GRID
  // -----------------------------
  Widget _buildCalendarGrid(int offset, int days) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tileSize = (screenWidth - 14 * 2 - 8 * 6) / 7;

    final total = offset + days;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(total, (index) {
        if (index < offset) {
          return SizedBox(width: tileSize, height: tileSize);
        } else {
          final day = index - offset + 1;
          return _buildDayTile(day, tileSize);
        }
      }),
    );
  }

  // -----------------------------
  // DAY TILE BOX
  // -----------------------------
  Widget _buildDayTile(int day, double size) {
    final isSelected = _selectedDay == day;

    final today = DateTime.now();
    final currentDate = DateTime(currentMonth.year, currentMonth.month, day);

    final isPast = currentDate.isBefore(
      DateTime(today.year, today.month, today.day),
    );

    return GestureDetector(
      onTap: isPast
          ? null
          : () {
        setState(() {
          _selectedDay = day;
          _selectedTime = null;
          _selectedType = null;
          _selectedMinutes = null;
          _minutesController.clear();
        });
      },
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isPast
              ? Colors.grey.shade300
              : (isSelected ? Colors.deepPurpleAccent : Colors.white),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isPast
                ? Colors.grey.shade300
                : (isSelected ? Colors.deepPurpleAccent : Colors.grey.shade300),
          ),
          boxShadow: (isSelected && !isPast)
              ? [
            const BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2))
          ]
              : [],
        ),
        child: Text(
          "$day",
          style: TextStyle(
            fontSize: size * 0.35,
            fontWeight: FontWeight.w600,
            color:
            isPast ? Colors.grey : (isSelected ? Colors.white : Colors.black87),
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat.yMMMM().format(currentMonth);
    final days = DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    final offset = DateTime(currentMonth.year, currentMonth.month, 1).weekday % 7;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPsychicProfile(),
            const SizedBox(height: 20),

            _buildMonthSelector(monthLabel),
            const SizedBox(height: 12),

            _buildWeekDays(),
            const SizedBox(height: 10),

            _buildCalendarGrid(offset, days),
            const SizedBox(height: 20),

            if (_selectedDay != null) _buildTimeSlotSection(),
            if (_selectedTime != null) _buildTypeSelection(),
            if (_selectedType != null) _buildMinutesInput(),
            if (_selectedMinutes != null) const SizedBox(height: 16),
            if (_selectedMinutes != null) _buildSummaryBox(),
            if (_selectedMinutes != null) const SizedBox(height: 20),
            if (_selectedMinutes != null) _buildPaymentButton(),
          ],
        ),
      ),
    );
  }
  Future<void> requestPaymentToken(int bookingId, String amount) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final url = Uri.parse(
        "https://psychicbelive.mapps.site/api/psychic/booking/payment");

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"booking_id": bookingId}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final rawToken = data["payment_token"];

      // Convert RAW token → URL SAFE token
      final safeToken = rawToken
          .replaceAll("+", "-")
          .replaceAll("/", "_")
          .replaceAll("=", "");

      // Correct final payment URL
      final finalUrl =
          "https://accept.authorize.net/payment/payment?token=$safeToken";

      print("FINAL PAYMENT URL => $finalUrl");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentWebView(
            url: finalUrl,
            amount: amount,
            bookingId: bookingId,
          ),
        ),
      );
    }
  }


  // ⭐ TIME SLOT SECTION
  Widget _buildTimeSlotSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Time Slot",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _timeSlots.map((time) {
            final isSelected = _selectedTime == time;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTime = time;
                  _selectedType = null;
                  _selectedMinutes = null;
                  _minutesController.clear();
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: MediaQuery.of(context).size.width * 0.02,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.deepPurpleAccent
                      : const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  time,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.035,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 20),
      ],
    );
  }
  // ⭐ TYPE SELECTION (Call / Video Call / Chat)
  Widget _buildTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Appointment Type",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _appointmentTypes.map((type) {
            final isSelected = _selectedType == type;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedType = type;
                  _selectedMinutes = null;
                  _minutesController.clear();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.deepPurpleAccent
                      : const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      type == "Call"
                          ? Icons.call
                          : type == "Video Call"
                          ? Icons.videocam
                          : Icons.chat,
                      size: 18,
                      color: isSelected ? Colors.white : Colors.black54,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      type,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 25),
      ],
    );
  }
  // ⭐ MINUTES INPUT SECTION
  Widget _buildMinutesInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Enter Minutes",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),

        Row(
          children: [
            // MINUS BUTTON
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () {
                final cur = int.tryParse(_minutesController.text) ?? 0;
                final next = (cur - 5) > 0 ? cur - 5 : 0;
                _minutesController.text = next > 0 ? next.toString() : '';
              },
            ),

            // INPUT FIELD
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F6F6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: _minutesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter minutes (e.g. 15)",
                  ),
                ),
              ),
            ),

            // PLUS BUTTON
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () {
                final cur = int.tryParse(_minutesController.text) ?? 0;
                final next = cur + 5;
                _minutesController.text = next.toString();
              },
            ),
          ],
        ),

        const SizedBox(height: 20),
      ],
    );
  }
  // ⭐ SUMMARY BOX
  Widget _buildSummaryBox() {
    final date = DateFormat("d MMM yyyy").format(
      DateTime(currentMonth.year, currentMonth.month, _selectedDay!),
    );

    final total = _totalAmount;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F2FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurpleAccent, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Your Appointment Details",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),

          _summaryRow("Psychic", psychic["display_name"] ?? ""),
          _summaryRow("Date", date),
          _summaryRow("Time", _selectedTime ?? ""),
          _summaryRow("Type", _selectedType ?? ""),
          _summaryRow("Minutes", "${_selectedMinutes ?? 0} min"),

          const Divider(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Amount",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                "\$${total.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }






  // --- PSYCHIC PROFILE CARD UI ---
  Widget _buildPsychicProfile() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              user["profile_photo"] != null
                  ? "https://psychicbelive.mapps.site/uploads/users/${user["profile_photo"]}"
                  : "https://i.pravatar.cc/200",
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(psychic["display_name"] ?? "Unknown",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),

                Text(
                  categories.map((c) => c["name"]).join(" • "),
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
                const SizedBox(height: 6),

                Text("\$${psychic["price_per_minute"]}/min",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //-------------------------------------------------
  // MONTH SELECTOR
  //-------------------------------------------------
  Widget _buildMonthSelector(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.chevron_left), onPressed: () {
            setState(() => currentMonth = DateTime(
                currentMonth.year, currentMonth.month - 1, 1));
          }),
          Expanded(
            child: Center(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          IconButton(icon: const Icon(Icons.chevron_right), onPressed: () {
            setState(() => currentMonth = DateTime(
                currentMonth.year, currentMonth.month + 1, 1));
          }),
        ],
      ),
    );
  }

  //-------------------------------------------------
  // PAYMENT BUTTON (STEP–1)
  //-------------------------------------------------
  Widget _buildPaymentButton() {
    final total = _totalAmount;
    final canProceed = _selectedMinutes != null && _selectedMinutes! > 0;

    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: canProceed ? Colors.deepPurpleAccent : Colors.grey,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),

        // 🔥 STEP–1 : CALL createBooking()
        onPressed: canProceed ? createBooking : null,

        child: Text(
          canProceed
              ? "Proceed to Payment (\$${total.toStringAsFixed(2)})"
              : "Proceed to Payment",
          style: const TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
