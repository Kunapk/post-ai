import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
// สำหรับ iOS-specific params (inline media, no user gesture)
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class AiAgentWebView extends StatefulWidget {
  const AiAgentWebView({super.key});

  @override
  State<AiAgentWebView> createState() => _AiAgentWebViewState();
}

class _AiAgentWebViewState extends State<AiAgentWebView> {
  late final WebViewController _controller;
  double _progress = 0.0;
  bool _isRefreshing = false;

  static const String kStartUrl = 'https://aiagent.safebsc.finance/';

  @override
  void initState() {
    super.initState();

    // ใช้ Platform params และถ้าเป็น iOS จะใช้ WebKit params ที่อนุญาต inline media + ไม่ต้องแตะเพื่อเล่น
    PlatformWebViewControllerCreationParams params =
        const PlatformWebViewControllerCreationParams();

    if (Platform.isIOS) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params)
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0x00000000))
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {
                setState(() => _progress = progress / 100);
              },
              onNavigationRequest: (NavigationRequest request) async {
                final uri = Uri.parse(request.url);

                // เปิดลิงก์พิเศษ/นอกโดเมนด้วยแอปภายนอก
                if (_shouldOpenExternally(uri)) {
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                    return NavigationDecision.prevent;
                  }
                }
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(kStartUrl));

    // ปิด pinch-zoom ได้ทั้ง iOS/Android ใน v4
    controller.enableZoom(false);

    _controller = controller;
  }

  bool _shouldOpenExternally(Uri uri) {
    // อนุญาตให้อยู่ในโดเมนหลัก เปิดใน WebView
    final isSameOrigin = uri.host.endsWith('safebsc.finance');

    // protocol พิเศษให้เปิดนอกแอป
    const externalSchemes = {'tel', 'mailto', 'sms', 'facetime', 'maps'};
    if (externalSchemes.contains(uri.scheme)) return true;

    // ถ้าไม่ใช่ http/https ก็เปิดนอกแอป
    if (uri.scheme != 'http' && uri.scheme != 'https') return true;

    // http/https นอกโดเมน -> เปิดนอกแอป (ปรับตามต้องการ)
    return !isSameOrigin;
  }

  Future<void> _reload() async {
    setState(() => _isRefreshing = true);
    await _controller.reload();
    await Future.delayed(const Duration(milliseconds: 250));
    if (mounted) setState(() => _isRefreshing = false);
  }

  Future<bool> _onWillPop() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    final progressBar = _progress < 1.0 && _progress > 0.0
        ? LinearProgressIndicator(
            value: _progress,
            minHeight: 2,
            backgroundColor: isDark
                ? Colors.white12
                : Colors.black.withOpacity(0.06),
          )
        : const SizedBox.shrink();

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('AI Agent'),
          centerTitle: true,
          actions: [
            IconButton(
              tooltip: 'Reload',
              onPressed: _reload,
              icon: _isRefreshing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CupertinoActivityIndicator(),
                    )
                  : const Icon(Icons.refresh),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2),
            child: progressBar,
          ),
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _reload,
            child: WebViewWidget(controller: _controller),
          ),
        ),
      ),
    );
  }
}
