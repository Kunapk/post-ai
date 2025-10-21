import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BridgeTestWebView extends StatefulWidget {
  const BridgeTestWebView({super.key});

  @override
  State<BridgeTestWebView> createState() => _BridgeTestWebViewState();
}

class _BridgeTestWebViewState extends State<BridgeTestWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    final PlatformWebViewControllerCreationParams params =
        const PlatformWebViewControllerCreationParams();

    _controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'FlutterBridge',
        onMessageReceived: (JavaScriptMessage message) {
          // message.message เป็น String (มักเป็น JSON ที่เว็บส่งมา)
          _handleIncoming(message.message);
        },
      )
      ..enableZoom(false)
      // เปลี่ยน path ให้ตรงกับไฟล์ของคุณ
      // ถ้าไฟล์อยู่ที่ lib/assets/test_bridge.html ให้ประกาศใน pubspec.yaml แล้วโหลดตามนี้:
      ..loadFlutterAsset('lib/assets/test_bridge.html');
  }

  void _handleIncoming(String raw) {
    // พยายาม parse เป็น JSON ถ้าไม่ใช่ JSON ก็ใช้ raw ตรง ๆ
    Map<String, dynamic>? obj;
    try {
      obj = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {}

    final type = obj?['type']?.toString() ?? 'message';
    final payload = obj?['payload'];

    // แสดง SnackBar แจ้งว่ามีข้อความเข้า
    _showSnack('จากเว็บ: $type');

    // แสดง AlertDialog เนื้อหาจริง (native)
    final pretty = obj != null
        ? const JsonEncoder.withIndent('  ').convert(obj)
        : raw;
    _showNativeDialog(title: 'ข้อความจาก WebView', message: pretty);
  }

  void _showSnack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void _showNativeDialog({required String title, required String message}) {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(message)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }

  // (ออปชัน) ส่งข้อความจากแอปกลับไปหาเว็บ
  Future<void> _sendToWeb(Map<String, dynamic> data) async {
    final json = jsonEncode(data);
    final js = "window.onNativeMessage && window.onNativeMessage($json);";
    await _controller.runJavaScript(js);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bridge Test (Native Alert)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.send),
            tooltip: 'ส่งข้อความไปเว็บ',
            onPressed: () => _sendToWeb({
              'type': 'pingFromNative',
              'payload': {'text': 'สวัสดีจากแอป'},
            }),
          ),
        ],
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
