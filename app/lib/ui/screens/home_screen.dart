import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../../controllers/miva_controller.dart';
import 'package:animate_do/animate_do.dart';
import 'package:glitcheffect/glitcheffect.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final MivaController controller = Get.put(MivaController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final accentColor = controller.hasError.value ? Colors.redAccent : Colors.cyanAccent;
      final bgColor = controller.hasError.value ? const Color(0xFF140000) : const Color(0xFF000814);

      return Scaffold(
        backgroundColor: bgColor,
        body: Stack(
          children: [
            // Background Glows
            _buildBackgroundGlow(context, accentColor),

            // Main Content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildHeader(accentColor),
                    const SizedBox(height: 10),
                    _buildStageIndicator(accentColor),
                    const SizedBox(height: 20),
                    Expanded(child: _buildTerminalLogView(accentColor)),
                    const SizedBox(height: 20),
                    _buildAIResponseBox(accentColor),
                    const SizedBox(height: 10),
                    _buildListeningIndicator(accentColor),
                    const SizedBox(height: 20),
                    _buildCommandInputBar(accentColor),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBackgroundGlow(BuildContext context, Color color) {
    return Positioned(
      top: -100,
      right: -100,
      child: Container(
        width: 400,
        height: 400,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withAlpha((0.05 * 255).round()),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }

  Widget _buildHeader(Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "M.I.V.A",
          style: GoogleFonts.orbitron(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
            letterSpacing: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildAIResponseBox(Color accentColor) {
    return Obx(() {
      Widget content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "STATUS: ${controller.isProcessing.value ? 'PROCESSING' : (controller.hasError.value ? 'ERROR' : 'READY')}",
            style: GoogleFonts.robotoMono(
              fontSize: 10,
              color: controller.hasError.value ? Colors.redAccent : (controller.isProcessing.value ? Colors.orangeAccent : Colors.greenAccent),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            controller.aiResponse.value,
            style: GoogleFonts.robotoMono(
              fontSize: 16,
              color: Colors.white.withAlpha((0.9 * 255).round()),
              height: 1.5,
            ),
          ),
        ],
      );

      // Nếu có lỗi, bọc trong hiệu ứng Glitch
      if (controller.hasError.value) {
        content = GlitchEffect(
          child: content,
        );
      }

      return Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 120), // Ensure stable height
        decoration: BoxDecoration(
          color: Colors.white.withAlpha((0.05 * 255).round()),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accentColor.withAlpha((0.2 * 255).round())),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center, // Center vertically
                children: [
                  content,
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildListeningIndicator(Color color) {
    return Obx(() {
      if (!controller.isListening.value) return const SizedBox(height: 30);
      return FadeInUp(
        child: Text(
          controller.speechText.value.isEmpty ? "Đang lắng nghe..." : controller.speechText.value,
          textAlign: TextAlign.center,
          style: GoogleFonts.robotoMono(
            fontSize: 14,
            color: color.withAlpha((0.7 * 255).round()),
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    });
  }

  Widget _buildMicrophoneButton(Color accentColor) {
    return Obx(() {
      return GestureDetector(
        onTap: () => controller.isListening.value ? controller.stopListening() : controller.startListening(),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (controller.isListening.value)
              Pulse(
                infinite: true,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: accentColor.withAlpha((0.2 * 255).round()), width: 2),
                  ),
                ),
              ),
            
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: controller.isListening.value 
                    ? [Colors.redAccent, Colors.orangeAccent]
                    : [accentColor, accentColor.withAlpha((0.6 * 255).round())],
                ),
              ),
              child: Icon(
                controller.isListening.value ? Icons.stop : Icons.mic,
                color: Colors.white,
                size: 25,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStageIndicator(Color accentColor) {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: accentColor.withAlpha((0.1 * 255).round()),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: accentColor.withAlpha((0.3 * 255).round())),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: controller.currentStageStatus.value == 'running' ? Colors.greenAccent : Colors.orangeAccent,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              "STAGE: ${controller.currentStageName.value.toUpperCase()}",
              style: GoogleFonts.robotoMono(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white.withAlpha((0.8 * 255).round()),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTerminalLogView(Color accentColor) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black.withAlpha((0.4 * 255).round()),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withAlpha((0.1 * 255).round())),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Obx(() {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.terminalLogs.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  "> ${controller.terminalLogs[index]}",
                  style: GoogleFonts.robotoMono(
                    fontSize: 12,
                    color: Colors.greenAccent.withAlpha((0.7 * 255).round()),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildCommandInputBar(Color accentColor) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((0.05 * 255).round()),
              borderRadius: BorderRadius.circular(30),
            ),
            child: TextField(
              controller: controller.textController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Nhập lệnh hoặc nói...",
                hintStyle: TextStyle(color: Colors.white.withAlpha((0.3 * 255).round())),
                border: InputBorder.none,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send, color: Colors.cyanAccent, size: 20),
                  onPressed: () => controller.handleTextSubmit(),
                ),
              ),
              onSubmitted: (val) => controller.handleTextSubmit(),
            ),
          ),
        ),
        const SizedBox(width: 10),
        _buildMicrophoneButton(accentColor),
        const SizedBox(width: 10),
        IconButton(
          onPressed: () => controller.startProject(),
          icon: const Icon(Icons.play_circle_fill, color: Colors.cyanAccent, size: 30),
          tooltip: "Bắt đầu dự án",
        ),
        IconButton(
          onPressed: () => controller.approveStage(),
          icon: const Icon(Icons.check_circle, color: Colors.greenAccent, size: 30),
          tooltip: "Duyệt giai đoạn",
        ),
        IconButton(
          onPressed: () => controller.stopStage(),
          icon: const Icon(Icons.stop_circle, color: Colors.redAccent, size: 30),
          tooltip: "Dừng",
        ),
      ],
    );
  }
}
