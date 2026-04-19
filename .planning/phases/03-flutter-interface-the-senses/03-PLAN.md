# Phase 3: Flutter Interface - Plan

## Goal
Xây dựng ứng dụng Flutter đa nền tảng với phong cách Futuristic HUD, cho phép người dùng ra lệnh bằng giọng nói và nhận phản hồi tức thì từ JARVIS.

## Tasks

### Wave 1: Foundation
1. **Flutter Project Setup**: Khởi tạo project Flutter.
    - **Action**: Chạy `flutter create .` (nếu chưa có thư mục app) hoặc khởi tạo trong thư mục `interface`.
    - **Acceptance**: App chạy được bản "counter" mặc định trên ít nhất một nền tảng.

2. **Dependencies & Permissions**: Cấu hình thư viện và quyền truy cập.
    - **Files**: `pubspec.yaml`, `AndroidManifest.xml`, `Info.plist`.
    - **Action**: Thêm `get`, `supabase_flutter`, `speech_to_text`, `google_fonts`. Cấu hình quyền Microphone.
    - **Acceptance**: App xin được quyền micro khi bấm nút.

### Wave 2: Logic (The Controller)
3. **JarvisController (GetX)**: Xây dựng bộ não cho giao diện.
    - **Files**: `lib/controllers/jarvis_controller.dart`
    - **Action**: 
        - Quản lý trạng thái `isListening`, `text`, `response`.
        - Implement hàm `startListening()` và `stopListening()`.
        - Kết nối `supabase_flutter` để INSERT lệnh và lắng nghe (stream/channel) kết quả.
    - **Acceptance**: Khi nói, text hiện lên màn hình và được lưu vào Supabase.

### Wave 3: UI (Futuristic HUD)
4. **HUD Design**: Xây dựng giao diện Futuristic.
    - **Files**: `lib/ui/home_screen.dart`, `lib/ui/widgets/hud_visualizer.dart`
    - **Action**: 
        - Sử dụng `Stack`, `BackdropFilter` cho hiệu ứng gương mờ.
        - Tạo hiệu ứng sóng âm (Waveform) khi đang nghe.
        - Nút bấm chính ở giữa với hiệu ứng Neon Glow.
    - **Acceptance**: Giao diện đẹp, mượt mà, đúng phong cách HUD.

5. **Typewriter Feedback**: Hiển thị phản hồi AI.
    - **Action**: Tạo widget hiển thị text với hiệu ứng gõ chữ khi nhận được `ai_response` từ Supabase.
    - **Acceptance**: Phản hồi của AI hiện lên sinh động.

## Verification
### Must-Haves
- [ ] Bấm nút -> Nói -> Text gửi lên Supabase thành công.
- [ ] Python thực thi lệnh và trả về kết quả -> App Flutter nhận được và hiển thị thành công.
- [ ] Giao diện không bị giật lag khi đang nhận diện giọng nói.
- [ ] Hoạt động ổn định trên macOS/Windows (Desktop).

### Confidence Score
85% (Cần lưu ý cấu hình Microphone trên từng nền tảng cụ thể).
