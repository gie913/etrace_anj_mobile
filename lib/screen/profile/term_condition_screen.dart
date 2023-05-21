import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TermConditionScreen extends StatefulWidget {
  @override
  _TermConditionScreenState createState() => _TermConditionScreenState();
}

class _TermConditionScreenState extends State<TermConditionScreen> {
  final controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(const Color(0x00000000))
    ..loadRequest(
        Uri.parse('https://etrace.anj-group.co.id/terms-conditions/'));

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Syarat dan Ketentuan')),
      body: WebViewWidget(controller: controller),
    );
  }
}
