import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import '../core/services/tts_service.dart';
import 'package:dash_bubble/dash_bubble.dart';

class MivaController extends GetxController {
  final SpeechToText _speechToText = SpeechToText();
  final supabase = Supabase.instance.client;
  final TtsService _tts = TtsService();
  final textController = TextEditingController();

  // Process Management (Desktop only)
  Process? _pythonProcess;

  // States
  var isListening = false.obs;
  var speechText = "".obs;
  var aiResponse = "Hệ thống Miva AI sẵn sàng.".obs;
  var isProcessing = false.obs;
  var soundLevel = 0.0.obs;
  var hasError = false.obs;

  // Flow & Terminal
  var currentStageName = "Chưa bắt đầu".obs;
  var currentStageStatus = "pending".obs;
  var syncKey = "".obs;
  var terminalLogs = <String>[].obs;

  StreamSubscription? _subscription;
  StreamSubscription? _flowSubscription;
  StreamSubscription? _logSubscription;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> _initSafeBubble() async {
    try {
      await _initBubble();
    } catch (e) {
      debugPrint("Lỗi khởi tạo Bubble: $e");
    }
  }

  Future<void> _initSpeech() async {
    try {
      bool available = await _speechToText.initialize(
        onError: (val) => debugPrint('Speech Error: $val'),
        onStatus: (val) => debugPrint('Speech Status: $val'),
      );
      if (!available) {
        debugPrint("Speech recognition not available");
      }
    } catch (e) {
      debugPrint("Không thể khởi tạo Speech: $e");
    }
  }

  @override
  void onReady() {
    super.onReady();
    // 1. Khởi tạo Speech an toàn
    _initSpeech();
    
    // 2. Chỉ khởi tạo Bubble trên Android
    if (Platform.isAndroid) {
      _initSafeBubble();
    }
    
    // 3. Kết nối Supabase Stream
    _initFlowSync();

    // 4. Tự động chạy Python sau khi UI đã sẵn sàng
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      _launchPythonOrchestrator();
    }
  }

  Future<void> _launchPythonOrchestrator() async {
    // Đợi 5 giây để đảm bảo toàn bộ hệ thống native và mạng đã sẵn sàng
    await Future.delayed(const Duration(seconds: 5));
    debugPrint("--- [DESKTOP] Đang khởi động Python Orchestrator ---");
    try {
      const String projectRoot = "/Volumes/SSD/DEV/javis";
      final String scriptPath = "$projectRoot/src/main.py";
      const String pythonPath = "/usr/bin/python3";

      if (!File(scriptPath).existsSync()) {
        debugPrint("[ERROR] Không tìm thấy file script tại: $scriptPath");
        return;
      }

      _pythonProcess = await Process.start(
        pythonPath, 
        [scriptPath],
        mode: ProcessStartMode.detachedWithStdio,
        workingDirectory: projectRoot,
      ).catchError((e) {
        debugPrint("[ERROR] Lỗi thực thi Process.start: $e");
        return null;
      });

      if (_pythonProcess == null) return;

      // Lắng nghe log một cách an toàn
      _pythonProcess!.stdout.transform(utf8.decoder).listen((data) {
        debugPrint("[PYTHON STDOUT]: $data");
      }, onError: (e) => debugPrint("[ERROR STDOUT]: $e"));

      _pythonProcess!.stderr.transform(utf8.decoder).listen((data) {
        debugPrint("[PYTHON STDERR]: $data");
      }, onError: (e) => debugPrint("[ERROR STDERR]: $e"));

    } catch (e) {
      debugPrint("[ERROR] Không thể khởi động Python: $e");
      aiResponse.value = "Lỗi khởi động Engine.";
    }
  }

  void _initFlowSync() {
    try {
      // 1. Listen to the latest running stage
      _flowSubscription = supabase
          .from('project_flow')
          .stream(primaryKey: ['sync_key'])
          .listen((data) {
            if (data.isNotEmpty) {
              final running = data.firstWhere((e) => e['status'] == 'running' || e['status'] == 'waiting', orElse: () => data.last);
              currentStageName.value = running['stage_name'];
              currentStageStatus.value = running['status'];
              syncKey.value = running['sync_key'];
              
              _subscribeToLogs(syncKey.value);
            }
          }, onError: (e) => debugPrint("[SUPABASE ERROR]: $e"));

      // 2. Listen to AI responses in 'commands' table
      supabase
          .from('commands')
          .stream(primaryKey: ['id'])
          .order('created_at')
          .listen((data) {
            if (data.isNotEmpty) {
              final lastCommand = data.last;
              if (lastCommand['status'] == 'done' && lastCommand['ai_response'] != null) {
                aiResponse.value = lastCommand['ai_response'];
                _tts.speak(aiResponse.value);
              }
            }
          }, onError: (e) => debugPrint("[SUPABASE ERROR]: $e"));
    } catch (e) {
      debugPrint("[FATAL] Lỗi đồng bộ Supabase: $e");
    }
  }

  void _subscribeToLogs(String key) {
    _logSubscription?.cancel();
    _logSubscription = supabase
        .from('terminal_logs')
        .stream(primaryKey: ['id'])
        .eq('sync_key', key)
        .order('created_at')
        .listen((data) {
          terminalLogs.assignAll(data.map((e) => e['log_content'].toString()).toList());
        });
  }

  Future<void> approveStage() async {
    await _sendCommandDirect("approve");
  }

  Future<void> stopStage() async {
    await _sendCommandDirect("stop");
  }

  Future<void> startProject() async {
    await _sendCommandDirect("start");
  }

  Future<void> handleTextSubmit() async {
    final text = textController.text.trim();
    if (text.isNotEmpty) {
      await _sendCommandDirect(text);
      textController.clear();
    }
  }

  Future<void> _sendCommandDirect(String text) async {
     await supabase.from('commands').insert({
      'input_text': text,
      'status': 'pending',
    });
  }

  void _initSpeech() async {
    await _speechToText.initialize();
  }

  // --- Bubble Logic ---
  Future<void> _initBubble() async {
    // Yêu cầu quyền Overlay
    bool hasPermission = await DashBubble.instance.hasPostNotificationsPermission();
    if (!hasPermission) {
      await DashBubble.instance.requestPostNotificationsPermission();
    }

    bool hasOverlay = await DashBubble.instance.hasOverlayPermission();
    if (!hasOverlay) {
      await DashBubble.instance.requestOverlayPermission();
    }
    
    startBubble();
  }

  Future<void> startBubble() async {
    await DashBubble.instance.startBubble(
      bubbleOptions: BubbleOptions(
        bubbleIcon: "default_bubble_icon", // Sử dụng icon của thư viện để tránh lỗi tìm kiếm
        enableClose: true,
      ),
      notificationOptions: NotificationOptions(
        title: "MIVA Assistant",
        body: "Bubble is active",
      ),
      onTap: () {
        // Khi nhấn vào bong bóng, bắt đầu lắng nghe
        if (!isListening.value) {
          startListening();
        } else {
          stopListening();
        }
      },
    );
  }

  void stopBubble() async {
    await DashBubble.instance.stopBubble();
  }
  // --------------------

  void startListening() async {
    hasError.value = false;
    _tts.stop(); // Dừng nói khi user muốn ra lệnh mới
    if (!isListening.value) {
      bool available = await _speechToText.initialize();
      if (available) {
        isListening.value = true;
        _speechToText.listen(
          onResult: (result) {
            speechText.value = result.recognizedWords;
            if (result.finalResult) {
              stopListening();
              _sendCommand(result.recognizedWords);
            }
          },
          onSoundLevelChange: (level) => soundLevel.value = level,
        );
      }
    }
  }

  void stopListening() async {
    await _speechToText.stop();
    isListening.value = false;
  }

  Future<void> _sendCommand(String text) async {
    if (text.isEmpty) return;

    isProcessing.value = true;
    hasError.value = false;
    aiResponse.value = "Đang gửi lệnh...";

    try {
      // 1. Call Cloud Brain (Edge Function)
      // Điều này giúp App có thể phản hồi voice ngay cả khi PC/macOS tắt.
      final FunctionResponse response = await supabase.functions.invoke(
        'miva-brain',
        body: {'input_text': text},
      );

      if (response.status != 200) throw Exception("Lỗi Edge Function: ${response.status}");

      final Map<String, dynamic> brainData = response.data;
      final String commandId = brainData['id'];
      final String reply = brainData['reply'];
      final String status = brainData['status'];

      // Hiển thị và nói ngay lập tức
      aiResponse.value = reply;
      _tts.speak(reply);

      if (status == 'done') {
        isProcessing.value = false;
        return; // Xong, không cần đợi PC thực thi gì thêm
      }

      // 2. Subscribe to this specific row for the execution result (from PC)
      _subscription?.cancel();
      _subscription = supabase
          .from('commands')
          .stream(primaryKey: ['id'])
          .eq('id', commandId)
          .listen((data) {
            if (data.isNotEmpty) {
              final record = data.first;
              final String status = record['status'];
              final String result = record['ai_response'] ?? "";

              if (status == 'done') {
                aiResponse.value = result;
                isProcessing.value = false;
                
                // Kiểm tra lỗi trong kết quả thực thi
                if (result.contains("Error") || result.contains("Exception")) {
                  hasError.value = true;
                }

                // Nếu chưa nói (hoặc có kết quả mới), ưu tiên nói phần kết quả hệ thống
                if (result.contains("[Kết quả hệ thống]")) {
                   _tts.speak(result);
                }
                
                _subscription?.cancel();
              } else if (status == 'processing') {
                if (result.isNotEmpty && result != aiResponse.value) {
                  aiResponse.value = result;
                  _tts.speak(result); // Phản hồi ngay khi có chữ từ AI
                } else {
                  aiResponse.value = "Miva AI đang xử lý...";
                }
              }
            }
          });

    } catch (e) {
      aiResponse.value = "Lỗi kết nối: ${e.toString()}";
      isProcessing.value = false;
      hasError.value = true;
    }
  }

  @override
  void onClose() {
    _subscription?.cancel();
    _flowSubscription?.cancel();
    _logSubscription?.cancel();
    
    // Dừng Python nếu đang chạy (Desktop)
    _pythonProcess?.kill();
    
    if (Platform.isAndroid) {
      stopBubble();
    }
    super.onClose();
  }
}

