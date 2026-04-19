import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  final FlutterTts _flutterTts = FlutterTts();

  factory TtsService() => _instance;

  TtsService._internal() {
    _init();
  }

  Future<void> _init() async {
    await _flutterTts.setLanguage("vi-VN"); // Mặc định tiếng Việt
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    // Làm sạch text (bỏ các tag kết quả hệ thống nếu cần)
    String cleanText = text.split("[Kết quả hệ thống]")[0].trim();
    await _flutterTts.speak(cleanText);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
