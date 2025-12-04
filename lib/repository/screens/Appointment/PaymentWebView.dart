import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebView extends StatefulWidget {
  final String url;
  final String amount;
  final int bookingId;

  const PaymentWebView({
    super.key,
    required this.url,
    required this.amount,
    required this.bookingId,
  });

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) => print("PAGE STARTED: $url"),
          onPageFinished: (url) => print("PAGE FINISHED: $url"),
          onWebResourceError: (err) =>
              print("WEB ERROR: ${err.description}"),
        ),
      )
      ..loadRequest(Uri.parse(widget.url)); // RAW URL
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pay ₹${widget.amount}"),
        backgroundColor: Colors.deepPurple,
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}

