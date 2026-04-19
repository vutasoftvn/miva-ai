# Phase 4: Integration & Polish - Plan

## Goal
Hoàn thiện trải nghiệm JARVIS: tối ưu hóa tốc độ, thêm giọng nói và thiết lập nền tảng cho việc điều khiển đa thiết bị.

## Tasks

### Wave 1: Infrastructure Update
1. **Database schema update**: Thêm cột định danh thiết bị.
    - **Action**: Chạy SQL `ALTER TABLE commands ADD COLUMN target_device_id TEXT;`.
    - **Acceptance**: Cột mới xuất hiện trong Supabase.

2. **Python Optimization & Identification**:
    - **Files**: `src/main.py`
    - **Action**: 
        - Lấy `hostname` làm `CLIENT_ID`.
        - Chỉ thực thi lệnh nếu `target_device_id` khớp hoặc null.
        - Thực thi lệnh ngay lập tức sau khi AI trích xuất Intent (trước khi ghi kết quả xong).
    - **Acceptance**: Python log "Executor started for Device: [hostname]".

### Wave 2: Voice & Senses
3. **Flutter Voice Implementation**: Thêm giọng nói cho JARVIS.
    - **Files**: `app/lib/services/tts_service.dart`, `app/lib/controllers/jarvis_controller.dart`, `app/pubspec.yaml`
    - **Action**: Tích hợp `flutter_tts`. Khi nhận `ai_response`, app tự động đọc văn bản.
    - **Acceptance**: App JARVIS phát âm thanh khi AI trả lời.

4. **Visual Glitch & Error Feedback**:
    - **Files**: `app/lib/ui/screens/home_screen.dart`
    - **Action**: 
        - Thêm hiệu ứng Glitch khi lệnh thất bại.
        - Đổi màu HUD sang đỏ khi có lỗi.
    - **Acceptance**: Khi gặp lệnh không hợp lệ, màn hình rung và đổi màu cảnh báo.

### Wave 3: Final Integration
5. **End-to-End Latency Test**:
    - **Action**: Đo thời gian từ khi dứt câu nói đến khi hành động thực thi. Mục tiêu < 1.5s.
    - **Acceptance**: Đạt mục tiêu tốc độ.

## Verification
### Must-Haves
- [ ] JARVIS đọc câu trả lời bằng giọng nói tiếng Việt/Anh.
- [ ] App Flutter hiển thị trạng thái "Error" bằng hiệu ứng Glitch và màu đỏ.
- [ ] Python có thể bỏ qua lệnh nếu lệnh đó dành cho thiết bị khác (testing logic).

### Confidence Score
95%
