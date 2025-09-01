// lib/pages/ai/voice_io.dart
import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

typedef VoiceResultCallback = void Function(String text);

/// Interface
abstract class VoiceIO {
  Future<void> startListening({required VoiceResultCallback onResult});
  Future<void> stopListening();
  Future<void> speak(String text);
  Future<void> stopSpeaking();
  void dispose(); // ✅ require every implementation to clean resources
}

/// ==================
/// Mobile Implementation (iOS/Android)
/// ==================
class MobileVoiceIO implements VoiceIO {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _isListening = false;
  bool _initialized = false;

  Future<bool> _ensurePermissions() async {
    // 1) Microphone
    final mic = await Permission.microphone.request();
    if (mic.isPermanentlyDenied) {
      debugPrint('❌ Mic permission permanently denied → open settings');
      await openAppSettings();
      return false;
    }
    if (!mic.isGranted) {
      debugPrint('❌ Mic permission not granted');
      return false;
    }

    // 2) iOS also needs Speech Recognition permission
    if (Platform.isIOS) {
      final sp = await Permission.speech.request();
      if (sp.isPermanentlyDenied) {
        debugPrint('❌ Speech permission permanently denied → open settings');
        await openAppSettings();
        return false;
      }
      if (!sp.isGranted) {
        debugPrint('❌ Speech permission not granted');
        return false;
      }
    }

    return true;
  }

  Future<bool> _ensureInitialized() async {
    if (_initialized) return true;

    debugPrint('🎤 STT initialize...');
    final ok = await _speech.initialize(
      debugLogging: true,
      onError: (e) => debugPrint('❌ STT onError: $e'),
      onStatus: (s) => debugPrint('🎙️ STT onStatus: $s'),
    );

    debugPrint(
      '🎤 STT init result: $ok, hasPermission=${_speech.hasPermission}, isAvailable=${_speech.isAvailable}',
    );
    _initialized = ok;
    return ok;
  }

  @override
  Future<void> startListening({required VoiceResultCallback onResult}) async {
    if (_isListening) {
      debugPrint('⚠️ Already listening, skip');
      return;
    }

    // Ask permissions first
    final permitted = await _ensurePermissions();
    if (!permitted) return;

    // Then init STT
    final ok = await _ensureInitialized();
    if (!ok) {
      debugPrint('⚠️ STT not available (check permissions / mic input)');
      return;
    }

    const String? localeId =
        null; // try null first; set 'th-TH' later if needed
    debugPrint('🎤 Start listening... (localeId=$localeId)');
    _isListening = true;

    await _speech.listen(
      localeId: localeId,
      listenMode: stt.ListenMode.confirmation,
      cancelOnError: true,
      partialResults: true,
      pauseFor: const Duration(seconds: 3),
      listenFor: const Duration(seconds: 10),
      onResult: (res) {
        final text = res.recognizedWords.trim();
        debugPrint('📝 onResult: "$text" | final=${res.finalResult}');
        if (text.isEmpty) return;

        if (res.finalResult) {
          onResult(text);
          stopListening();
        }
      },
    );
  }

  @override
  Future<void> stopListening() async {
    if (_isListening) {
      debugPrint('🛑 Stop listening');
      try {
        await _speech.stop();
      } catch (e) {
        debugPrint('❌ stopListening error: $e');
      }
      _isListening = false;
    }
  }

  @override
  Future<void> speak(String text) async {
    debugPrint('🔊 TTS speak: $text');
    try {
      await _tts.setLanguage('th-TH');
      await _tts.setPitch(1.0);
      await _tts.setSpeechRate(0.9);
      await _tts.speak(text);
    } catch (e) {
      debugPrint('❌ TTS error: $e');
    }
  }

  @override
  Future<void> stopSpeaking() async {
    try {
      await _tts.stop();
    } catch (e) {
      debugPrint('❌ TTS stop error: $e');
    }
  }

  @override
  void dispose() {
    debugPrint('🧹 Dispose MobileVoiceIO');
    try {
      _speech.cancel();
    } catch (_) {}
    try {
      _tts.stop();
    } catch (_) {}
  }
}
