# Research: Phase 4 - Integration & Polish

## Tech Research Findings

### 1. Voice Feedback (TTS)
- **Package**: `flutter_tts`.
- **Latency**: Phản hồi giọng nói nên được kích hoạt ngay khi nhận được `ai_response` từ Supabase.
- **Language Support**: Hỗ trợ tiếng Việt (`vi-VN`) nếu thiết bị có cài đặt engine TTS tương ứng.

### 2. Glitch & Visual Effects
- **Package**: `glitcheffect` hoặc `animated_glitch`.
- **Usage**: Kích hoạt hiệu ứng Glitch trên khối văn bản `AI Response` khi xảy ra lỗi (`status == 'error'`).
- **Sound**: Thêm âm thanh thông báo nhẹ (chất lượng cao) cho các trạng thái: Bắt đầu nghe, Đang xử lý, Hoàn tất.

### 3. Latency Optimization (Python)
- **Direct Execution**: Python loop sẽ gọi `executor.execute()` ngay lập tức sau khi có kết quả từ `brain.ask()`, giúp giảm bớt một vòng lặp ghi/đọc database không cần thiết cho quá trình thực thi.

### 4. Simple Device Targeting
- **Client ID**: Mỗi Python script sẽ tự tạo một `CLIENT_ID` (ví dụ: `socket.gethostname()`).
- **Filtering**: Script chỉ thực thi lệnh nếu `target_device_id` khớp với `CLIENT_ID` của nó.

## Recommended Patterns
- **Database Architecture**:
    - Thêm cột `target_device_id` (TEXT).
- **Flutter Service**:
    - Tạo `TtsService` sử dụng pattern singleton để quản lý giọng nói xuyên suốt app.
- **Asset Management**:
    - Thêm các file âm thanh `.wav` vào `assets/sounds/`.
