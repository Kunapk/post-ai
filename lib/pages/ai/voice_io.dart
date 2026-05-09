// lib/pages/ai/voice_io.dart
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

typedef VoiceResultCallback = void Function(String text);
typedef VoiceErrorCallback = void Function(String error);

abstract class VoiceIO {
  Future<void> startListening({
    required VoiceResultCallback onResult,
    VoiceErrorCallback? onError,
  });
  Future<void> stopListening();
  Future<void> speak(String text);
  Future<void> stopSpeaking();
  void dispose();
}

// Web implementation
class WebVoiceIO implements VoiceIO {
  bool _isListening = false;

  @override
  Future<void> startListening({
    required VoiceResultCallback onResult,
    VoiceErrorCallback? onError,
  }) async {
    if (_isListening) return;

    _isListening = true;

    // For web, we'll simulate voice input or show text input dialog
    onError?.call('🌐 Voice input ไม่รองรับบน Web กรุณาใช้การพิมพ์ข้อความแทน');
  }

  @override
  Future<void> stopListening() async {
    _isListening = false;
  }

  @override
  Future<void> speak(String text) async {
    // Web TTS - ใช้ browser's speech synthesis
    if (kIsWeb) {
      // Note: เพิ่ม web speech synthesis ได้ในอนาคต
      debugPrint('🔊 [Web] TTS: $text');
    }
  }

  @override
  Future<void> stopSpeaking() async {
    // Nothing to do for web
  }

  @override
  void dispose() {
    // Nothing to dispose for web
  }
}

class MobileVoiceIO implements VoiceIO {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _isListening = false;
  bool _initialized = false;
  String? _thaiLocaleId; // <— เก็บ locale TH สำหรับ STT
  bool _ttsThaiReady = false;
  VoiceErrorCallback? _errorCallback; // 🎯 Store error callback

  Future<bool> _ensurePermissions() async {
    final mic = await Permission.microphone.request();
    if (!mic.isGranted) return false;

    if (Platform.isIOS) {
      final sp = await Permission.speech.request();
      if (!sp.isGranted) return false;
    }
    return true;
  }

  Future<bool> _ensureInitialized() async {
    if (_initialized) return true;

    final ok = await _speech.initialize(
      debugLogging: true,
      onError: (e) {
        debugPrint('❌ STT onError: $e');
        // ✅ Better error messages for users
        String userFriendlyError;
        if (e.errorMsg.contains('error_no_match')) {
          userFriendlyError =
              '🎤 ไม่สามารถรับเสียงได้ชัดเจน กรุณาลองใหม่หรือพิมพ์ข้อความ';
        } else if (e.errorMsg.contains('error_network')) {
          userFriendlyError = '🌐 ปัญหาเครือข่าย กรุณาตรวจสอบการเชื่อมต่อ';
        } else if (e.errorMsg.contains('error_audio')) {
          userFriendlyError = '🎙️ ปัญหาการบันทึกเสียง กรุณาลองใหม่';
        } else {
          userFriendlyError = '❌ เกิดข้อผิดพลาด กรุณาลองใหม่หรือพิมพ์ข้อความ';
        }
        _errorCallback?.call(userFriendlyError);
      },
      onStatus: (s) => debugPrint('🎙️ STT onStatus: $s'),
    );
    _initialized = ok;
    if (!ok) return false;

    // เลือก locale ไทยสำหรับ STT
    await _pickThaiLocale();

    // เตรียม TTS ให้พูดไทย (เลือก voice ไทยและตั้ง rate ให้ช้าลง)
    await _prepareThaiTts();

    return true;
  }

  Future<void> _pickThaiLocale() async {
    try {
      final locales = await _speech.locales();
      // หา locale ที่เป็นไทยก่อน เช่น th-TH / th_TH
      final th = locales.firstWhere((l) {
        final id = l.localeId.toLowerCase();
        return id.startsWith('th') ||
            id.contains('th-th') ||
            id.contains('th_th');
      }, orElse: () => locales.first);
      _thaiLocaleId = th.localeId;
      debugPrint('🌏 STT choose Thai locale: $_thaiLocaleId');
    } catch (e) {
      debugPrint('⚠️ _pickThaiLocale error: $e');
      _thaiLocaleId = null; // ให้ระบบเดาเอง
    }
  }

  Future<void> _prepareThaiTts() async {
    try {
      await _tts.setLanguage('th-TH'); // บอกภาษาไทย
      await _tts.setPitch(1.0);
      await _tts.setSpeechRate(0.45); // ✅ ช้าลง (0.4–0.55 กำลังดีบน iOS)
      // เลือก voice ภาษาไทยถ้ามี (บางเครื่องจะมีหลาย voice)
      final voices = await _tts.getVoices;
      // หา voice ที่ชื่อบอกว่าเป็นไทย
      final thaiVoice = (voices as List).cast<Map>().firstWhere((v) {
        final name = (v['name']?.toString() ?? '').toLowerCase();
        final locale = (v['locale']?.toString() ?? '').toLowerCase();
        return locale.startsWith('th') || name.contains('thai');
      }, orElse: () => {});

      if (thaiVoice.isNotEmpty) {
        await _tts.setVoice({
          'name': thaiVoice['name'],
          'locale': thaiVoice['locale'],
        });
        debugPrint(
          '🔊 TTS voice set: ${thaiVoice['name']} (${thaiVoice['locale']})',
        );
      } else {
        debugPrint('ℹ️ No explicit Thai voice found; using setLanguage(th-TH)');
      }

      _ttsThaiReady = true;
    } catch (e) {
      debugPrint('⚠️ _prepareThaiTts error: $e');
      _ttsThaiReady = false;
    }
  }

  @override
  Future<void> startListening({
    required VoiceResultCallback onResult,
    VoiceErrorCallback? onError,
  }) async {
    if (_isListening) return;

    // 🎯 Store error callback for use in initialize()
    _errorCallback = onError;

    final permitted = await _ensurePermissions();
    if (!permitted) {
      onError?.call('❌ Microphone permission denied');
      return;
    }

    final ok = await _ensureInitialized();
    if (!ok) {
      onError?.call('❌ STT initialization failed');
      return;
    }

    final localeId =
        _thaiLocaleId ?? 'en-US'; // ✅ Fallback to English if Thai not available
    debugPrint('🎤 Start listening... (localeId=$localeId)');
    _isListening = true;

    await _speech.listen(
      localeId: localeId,
      // ✅ More tolerant settings for better recognition
      cancelOnError: false, // Don't cancel on error, let it finish
      partialResults: true,
      pauseFor: const Duration(seconds: 2), // Longer pause detection
      listenFor: const Duration(seconds: 15), // Longer listening time
      onResult: (res) {
        final text = res.recognizedWords.trim();
        debugPrint(
          '📝 onResult: "$text" | final=${res.finalResult} | confidence=${res.confidence}',
        );

        // ✅ Accept partial results if confidence is reasonable
        if (text.isNotEmpty && res.confidence > 0.3) {
          if (res.finalResult) {
            onResult(text);
            stopListening();
          }
        }
      },
    );
  }

  @override
  Future<void> stopListening() async {
    if (_isListening) {
      try {
        await _speech.stop();
      } catch (_) {}
      _isListening = false;
    }
  }

  @override
  Future<void> speak(String text) async {
    try {
      if (!_ttsThaiReady) {
        // เผื่อรอบแรกยังไม่ได้ set voice
        await _prepareThaiTts();
      }
      await _tts.speak(text);
    } catch (e) {
      debugPrint('❌ TTS error: $e');
    }
  }

  @override
  Future<void> stopSpeaking() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }

  @override
  void dispose() {
    try {
      _speech.cancel();
    } catch (_) {}
    try {
      _tts.stop();
    } catch (_) {}
  }
}
