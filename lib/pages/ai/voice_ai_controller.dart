import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'gemini_constants.dart';
import 'intent_parser.dart';
import 'voice_io.dart'; // ✅ มี MobileVoiceIO ข้างในอยู่แล้ว

class VoiceAIController extends ChangeNotifier {
  bool isListening = false;
  bool isThinking = false;

  late GenerativeModel model;
  late ChatSession chat;

  final List<Map<String, dynamic>> messages = [
    {'role': 'ai', 'text': 'สวัสดีค่ะ ต้องการสั่งอะไรดีคะ'},
  ];

  final ScrollController scrollController = ScrollController();
  final List<Map<String, dynamic>> cartItems = [];
  String latestReply = '';
  Map<String, dynamic>? pendingItemForConfirmation;

  // IO layer (mobile only)
  late final VoiceIO voiceIO;

  VoiceAIController() {
    /// ใช้ MobileVoiceIO โดยตรง
    voiceIO = MobileVoiceIO();

    /// Init Gemini
    model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: GeminiConstants.apiKey,
    );

    final introContext =
        'ร้านเราชื่อ ชานมบ้านหวาน มีเมนูคือ: ชานมไข่มุก, เค้กชาเขียว, ขนมปังปิ้ง, โกโก้เย็น';
    final policyContext =
        'ถ้าลูกค้าถามแนะนำเมนู ให้แนะนำเฉพาะสินค้าที่ร้านเรามีเท่านั้น และห้ามใช้คำลงท้ายว่า ครับ หรือ ค่ะ ให้ใช้แค่คำว่า ค่ะ เท่านั้น';

    chat = model.startChat(
      history: [Content.text(introContext), Content.text(policyContext)],
    );
  }

  Future<void> handleVoiceInput(BuildContext context) async {
    debugPrint('🎙️ handleVoiceInput: isListening $isListening');

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
        debugPrint('🎙️ Voice input received: $text');
        messages.add({'role': 'user', 'text': text});
        isThinking = true;
        notifyListeners();
        scrollToBottom();

        final lowered = text.toLowerCase();
        const confirmationWords = ['ใช่', 'โอเค', 'ได้เลย', 'ครับ', 'ค่ะ'];

        if (pendingItemForConfirmation != null &&
            confirmationWords.any((w) => lowered.contains(w))) {
          addToCart(pendingItemForConfirmation!);
          final confirmMsg =
              'รับออเดอร์ ${pendingItemForConfirmation!['name']} เรียบร้อยค่ะ';
          messages.add({'role': 'ai', 'text': confirmMsg});
          scrollToBottom();
          await voiceIO.speak(confirmMsg);
          pendingItemForConfirmation = null;
          isThinking = false;
          isListening = false;
          notifyListeners();
          return;
        }

        final response = await chat.sendMessage(Content.text(text));
        final reply = response.text ?? '[ไม่มีคำตอบ]';
        debugPrint('🤖 AI replied: $reply');

        final checkoutKeywords = [
          'คิดเงิน',
          'จ่ายเงิน',
          'เช็กบิล',
          'จ่ายตัง',
          'จ่ายตังค์',
        ];
        if (checkoutKeywords.any((word) => text.contains(word))) {
          messages.add({'role': 'ai', 'text': reply});
          isThinking = false;
          isListening = false;
          notifyListeners();
          scrollToBottom();
          latestReply = reply;
          await voiceIO.speak(reply);
          debugPrint('🧾 Final cart after AI response: $cartItems');
          return;
        }

        messages.add({'role': 'ai', 'text': reply});
        isThinking = false;
        isListening = false;
        notifyListeners();
        scrollToBottom();
        latestReply = reply;
        await voiceIO.speak(reply);

        final parser = IntentParser([
          {'name': 'ชานมไข่มุก', 'price': 25},
          {'name': 'เค้กชาเขียว', 'price': 30},
          {'name': 'ขนมปังปิ้ง', 'price': 20},
          {'name': 'โกโก้เย็น', 'price': 35},
        ]);

        final result = parser.parse(text);
        debugPrint('📝 Parsed intent: $result');

        if (result['add']!.isNotEmpty) {
          for (final item in result['add']!) {
            addToCart(item);
          }
        } else if (result['remove']!.isEmpty &&
            pendingItemForConfirmation == null) {
          final mentioned = parser.menuItems.firstWhere(
            (item) => lowered.contains(item['name'].toString().toLowerCase()),
            orElse: () => {},
          );
          if (mentioned.isNotEmpty) {
            pendingItemForConfirmation = {...mentioned, 'qty': 1};
            final ask = 'รับออเดอร์ ${mentioned['name']} ใช่ไหมคะ?';
            messages.add({'role': 'ai', 'text': ask});
            scrollToBottom();
            await voiceIO.speak(ask);
            notifyListeners();
            return;
          }
        }

        for (final item in result['remove']!) {
          removeFromCart(item['name'], item['qty']);
        }
        debugPrint('🧾 Final cart after AI response: $cartItems');
      },
    );
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void addToCart(Map<String, dynamic> item) {
    final index = cartItems.indexWhere((e) => e['name'] == item['name']);
    if (index != -1) {
      cartItems[index]['qty'] += item['qty'] ?? 1;
    } else {
      cartItems.add({...item, 'qty': item['qty'] ?? 1});
    }
    notifyListeners();
  }

  void removeFromCart(String name, int qty) {
    final index = cartItems.indexWhere((e) => e['name'] == name);
    if (index != -1) {
      if (cartItems[index]['qty'] > qty) {
        cartItems[index]['qty'] -= qty;
      } else {
        cartItems.removeAt(index);
      }
      notifyListeners();
    }
  }

  Future<String> getAIReply(String text) async {
    final response = await chat.sendMessage(Content.text(text));
    final reply = response.text ?? '[ไม่มีคำตอบ]';
    messages.add({'role': 'user', 'text': text});
    messages.add({'role': 'ai', 'text': reply});
    latestReply = reply;
    notifyListeners();
    return reply;
  }
}
