# Research: Phase 3 - Flutter Interface

## Tech Research Findings

### 1. Futuristic HUD Design in Flutter
- **Glassmorphism**: Dùng `BackdropFilter` phối hợp với `ImageFilter.blur` và `BoxDecoration` có độ trong suốt thấp.
- **Neon Glow**: Sử dụng `BoxShadow` với `blurRadius` lớn. Có thể dùng package `glow_container` để đơn giản hóa.
- **Visualizer**: Sử dụng `CustomPainter` để vẽ sóng âm dựa trên dữ liệu từ micro (nếu dùng `speech_to_text` có cung cấp level).

### 2. State Management with GetX
- **Reactive State**: Sử dụng `.obs` cho các biến như `currentText`, `aiResponse`, `isListening`.
- **Supabase Realtime**: 
    - Sử dụng `onPostgresChanges` để nhận thay đổi row theo thời gian thực.
    - Phải gọi `unsubscribe()` trong `onClose()` của Controller để tránh rò rỉ bộ nhớ.

### 3. Speech-to-Text Multi-platform
- **Package**: `speech_to_text`.
- **Permissions**:
    - **Android**: Cần `RECORD_AUDIO` trong `AndroidManifest.xml`.
    - **iOS**: Cần `NSMicrophoneUsageDescription` và `NSSpeechRecognitionUsageDescription` trong `Info.plist`.
    - **macOS**: Cần kích hoạt Sandbox và Mic trong Xcode.

### 4. Supabase Integration
- Khởi tạo `Supabase.initialize()` trong `main.dart`.
- Lưu trữ session hoặc dùng anon key tùy cấu hình RLS (MVP dùng anon key).

## Recommended Patterns
- **Architecture**: MVC/MVVM với GetX:
    - `lib/controllers/jarvis_controller.dart`: Logic chính.
    - `lib/ui/screens/home_screen.dart`: Giao diện HUD.
    - `lib/ui/widgets/glow_button.dart`: Nút micro phong cách neon.
- **Supabase Channel**: Đặt tên channel duy nhất cho mỗi user/session nếu cần, nhưng MVP chỉ cần lắng nghe bảng `commands`.
