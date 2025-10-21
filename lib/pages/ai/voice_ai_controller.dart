// lib/pages/ai/voice_ai_controller.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'gemini_constants.dart';
import 'intent_parser.dart';
import 'voice_io.dart';
import 'package:pos/model/menu_model.dart';
import 'package:pos/model/category_model.dart';

class VoiceAIController extends ChangeNotifier {
  // ===== UI state =====
  bool isListening = false;
  bool isThinking = false;

  // ===== Gemini =====
  late final GenerativeModel model;
  late final ChatSession chat;

  // ===== Chat UI + cart =====
  final List<Map<String, dynamic>> messages = [
    {'role': 'ai', 'text': 'สวัสดีค่ะ รับอะไรดีคะ'},
  ];
  final ScrollController scrollController = ScrollController();
  final List<Map<String, dynamic>> cartItems = [];
  String latestReply = '';
  Map<String, dynamic>? pendingItemForConfirmation;

  // ===== IO (mobile only) =====
  late final VoiceIO voiceIO;

  // ===== คีย์เวิร์ด =====
  static const List<String> _checkoutKeywords = [
    'คิดเงิน',
    'จ่ายเงิน',
    'เช็กบิล',
    'จ่ายตัง',
    'จ่ายตังค์',
  ];
  static const List<String> _confirmWords = [
    'ใช่',
    'โอเค',
    'ได้เลย',
    'ครับ',
    'ค่ะ',
  ];

  // ===== คลังเมนู/หมวดจริง + IntentParser ที่อัปเดตได้ =====
  List<Menu> _menus = [];
  List<Category> _categories = [];
  IntentParser _parser = IntentParser([]);

  // ===== regex สำหรับจับทักทาย =====
  final RegExp _greetingRegex = RegExp(
    r'^\s*(สวัสดี|หวัดดี|hello|hi|hey)\s*(ครับ|ค่ะ)?\s*$',
    caseSensitive: false,
  );

  VoiceAIController() {
    voiceIO = MobileVoiceIO();

    final generationConfig = GenerationConfig(
      // temperature: 0.2, // ลดความ “เพ้อ”
      // topP: 0.8,
      // topK: 20,
      // maxOutputTokens: 120,
    );

    model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: GeminiConstants.apiKey,
      generationConfig: generationConfig,
    );

    final introContext = 'ร้านเราชื่อ "ชานมบ้านหวาน" เมนูจะอัปเดตตามระบบจริง.';
    final policyContext = '''
กติกาการตอบ:
- ตอบเป็นภาษาไทยเท่านั้น
- สั้น กระชับ ลงท้าย "ค่ะ"
- ห้ามคำฟิลเลอร์/คำขอให้รอ เช่น "เดี๋ยว", "เดี๋ยวนะคะ", "สักครู่"
- เมื่อลูกค้าสั่งเมนู ให้ยืนยันชัดเจน เช่น "รับโกโก้เย็น 2 แก้วค่ะ"
- แนะนำเฉพาะเมนูที่มีจริง
''';

    chat = model.startChat(
      history: [Content.text(introContext), Content.text(policyContext)],
    );
  }

  // ========== sync เมนู/หมวดจากหน้า Home ==========
  void syncCatalog({
    required List<Menu> menus,
    required List<Category> categories,
  }) {
    _menus = menus;
    _categories = categories;

    final items = menus
        .map((m) => {'name': (m.name).trim(), 'price': (m.price)})
        .where((e) => (e['name'] as String).isNotEmpty)
        .toList();

    _parser = IntentParser(items);

    final preview = items.map((e) => e['name']).take(30).join(', ');
    chat.sendMessage(Content.text('อัปเดตรายการเมนูล่าสุด: $preview'));
    debugPrint(
      '✅ VoiceAIController: catalog synced. menus=${items.length}, categories=${categories.length}',
    );
  }

  /// เริ่ม/หยุดฟังเสียง
  Future<void> handleVoiceInput(BuildContext context) async {
    if (isListening) {
      await voiceIO.stopListening();
      isListening = false;
      notifyListeners();
      return;
    }
    isListening = true;
    notifyListeners();

    await voiceIO.startListening(
      onResult: (String text) async {
        await processTranscription(text);
      },
    );
  }

  /// รวม logic หลังได้ข้อความจากเสียง
  Future<void> processTranscription(String text) async {
    final lowered = text.toLowerCase();
    debugPrint('🎙️ Voice input received: $text');

    messages.add({'role': 'user', 'text': text});
    isThinking = true;
    scrollToBottom();
    notifyListeners();

    try {
      // 0) ถ้าเจอการทักทาย → ตอบคงที่เลย
      if (_greetingRegex.hasMatch(lowered)) {
        final greet = 'สวัสดีค่ะ รับอะไรดีคะ';
        await _respondAndSpeak(greet);
        return;
      }

      // 1) มี pending รอ confirm
      if (pendingItemForConfirmation != null &&
          _confirmWords.any((w) => lowered.contains(w))) {
        final item = pendingItemForConfirmation!;
        addToCart(item);
        final confirmMsg = _sanitizeReply(
          'รับออเดอร์ ${item['name']} เรียบร้อยค่ะ',
        );
        await _respondAndSpeak(confirmMsg);
        pendingItemForConfirmation = null;
        return;
      }

      // 2) ส่งไปถาม Gemini
      final response = await chat.sendMessage(Content.text(text));
      var reply = response.text ?? '[ไม่มีคำตอบ]';
      reply = _sanitizeReply(reply);
      debugPrint('🤖 AI replied: $reply');

      // 3) ถ้ามีคำชำระเงิน
      if (_checkoutKeywords.any((w) => text.contains(w))) {
        await _respondAndSpeak(reply);
        return;
      }

      // 4) ตอบทั่วไป
      await _respondAndSpeak(reply);

      // 5) Intent parsing จากเมนูจริง
      final result = _parser.parse(text);
      debugPrint('📝 Parsed intent (real menu): $result');

      if (result['add']!.isNotEmpty) {
        for (final item in result['add']!) {
          addToCart(item);
        }
      } else if (result['remove']!.isEmpty &&
          pendingItemForConfirmation == null) {
        final mentioned = _menus.firstWhere(
          (m) => lowered.contains((m.name).toLowerCase()),
          orElse: () => Menu(
            id: '',
            categoryId: '',
            name: '',
            prices: const [],
            image: '',
            price: 0,
          ),
        );

        final foundName = (mentioned.name).trim();
        if (foundName.isNotEmpty) {
          pendingItemForConfirmation = {
            'name': foundName,
            'qty': 1,
            'price': (mentioned.price),
          };
          final ask = _sanitizeReply('รับออเดอร์ $foundName ใช่ไหมคะ?');
          messages.add({'role': 'ai', 'text': ask});
          scrollToBottom();
          notifyListeners();
          await voiceIO.speak(ask);
          return;
        }
      }

      // 6) remove items
      for (final item in result['remove']!) {
        removeFromCart(item['name'], item['qty']);
      }
    } catch (e, st) {
      debugPrint('❌ processTranscription error: $e\n$st');
      final err = _sanitizeReply('ขออภัย เกิดข้อผิดพลาด ลองอีกครั้งได้ไหมคะ');
      messages.add({'role': 'ai', 'text': err});
      scrollToBottom();
      await voiceIO.speak(err);
    } finally {
      isThinking = false;
      isListening = false;
      notifyListeners();
    }
  }

  // ===== helpers =====
  Future<void> _respondAndSpeak(String reply) async {
    messages.add({'role': 'ai', 'text': reply});
    latestReply = reply;
    scrollToBottom();
    notifyListeners();
    await voiceIO.speak(reply);
  }

  String _sanitizeReply(String input) {
    var s = input.trim();

    // ตัด filler
    final fillers = <RegExp>[
      RegExp(r'\bเดี๋ยวสักครู่(นะคะ|ค่ะ|นะ)?\b'),
      RegExp(r'\bสักครู่(นะคะ|ค่ะ|นะ)?\b'),
      RegExp(r'\bเดี๋ยว(นะคะ|ค่ะ|นะ)?\b'),
      RegExp(r'\bขอ(?:สักครู่|เวลาสักครู่)\b'),
    ];
    for (final r in fillers) {
      s = s.replaceAll(r, '');
    }

    // ลบ "ครับ"
    s = s.replaceAll('ครับ', '');

    // จัด spacing
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();

    // กันคำลงท้ายซ้ำ
    s = s.replaceAll(RegExp(r'(ค่ะ)+$'), 'ค่ะ');
    s = s.replaceAll(RegExp(r'(คะ)\?$'), 'คะ?');

    // กันไม่ให้เติม "ค่ะ" หลังคำถาม
    final endsQuestion = s.endsWith('?');
    final endsKa = s.endsWith('คะ') || s.endsWith('คะ?');
    final endsKha = s.endsWith('ค่ะ') || s.endsWith('ค่ะ?');

    if (!endsQuestion && !endsKa && !endsKha) {
      if (!s.endsWith('ค่ะ')) s = '$s ค่ะ';
    }

    // ถ้าว่างหรือเป็นคำลงท้ายเปล่า
    if (s.isEmpty || s == 'ค่ะ' || s == 'คะ?' || s == 'ค่ะ?') {
      s = 'รับทราบค่ะ';
    }

    return s.trim();
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void addToCart(Map<String, dynamic> item) {
    final idx = cartItems.indexWhere((e) => e['name'] == item['name']);
    if (idx != -1) {
      cartItems[idx]['qty'] += item['qty'] ?? 1;
    } else {
      cartItems.add({...item, 'qty': item['qty'] ?? 1});
    }
    notifyListeners();
  }

  void removeFromCart(String name, int qty) {
    final idx = cartItems.indexWhere((e) => e['name'] == name);
    if (idx != -1) {
      if (cartItems[idx]['qty'] > qty) {
        cartItems[idx]['qty'] -= qty;
      } else {
        cartItems.removeAt(idx);
      }
      notifyListeners();
    }
  }

  Future<String> getAIReply(String text) async {
    final response = await chat.sendMessage(Content.text(text));
    final raw = response.text ?? '[ไม่มีคำตอบ]';
    final reply = _sanitizeReply(raw);
    messages
      ..add({'role': 'user', 'text': text})
      ..add({'role': 'ai', 'text': reply});
    latestReply = reply;
    notifyListeners();
    return reply;
  }

  @override
  void dispose() {
    voiceIO.stopListening();
    voiceIO.stopSpeaking();
    scrollController.dispose();
    super.dispose();
  }
}
