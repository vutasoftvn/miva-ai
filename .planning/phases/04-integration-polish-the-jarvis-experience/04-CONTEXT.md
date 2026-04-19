# Phase 4: Integration & Polish - Context

**Gathered:** 2026-04-18
**Status:** Ready for planning
**Source:** User decisions

<domain>
## Phase Boundary
Hoàn thiện trải nghiệm JARVIS bằng cách tích hợp đầu ra giọng nói (TTS), tối ưu hóa độ trễ thực thi và thêm cơ chế định danh thiết bị cơ bản để chuẩn bị cho đa thiết bị.

</domain>

<decisions>
## Implementation Decisions

### Voice Output (TTS)
- **Technology**: 
    - **Flutter**: Sử dụng `flutter_tts` để đọc phản hồi của AI.
    - **Python**: Có thể thêm `pyttsx3` hoặc `gTTS` nếu cần JARVIS nói trực tiếp từ PC (nhưng ưu tiên đọc từ App Flutter theo yêu cầu "giọng nói").

### Latency Optimization
- **Python Execute-First**: Python script sẽ thực thi lệnh ngay khi trích xuất được `action_json` thành công, sau đó mới cập nhật kết quả vào Supabase để giảm độ trễ tối đa.

### Visual Polish (Flutter)
- **Error State**: Chuyển HUD sang màu đỏ (Crimson/Red) và hiệu ứng Glitch khi lệnh thất bại.
- **Microphone Feedback**: Sóng âm (Pulse/Waveform) mạnh hơn/nhạy hơn theo `soundLevel` từ micro.

### Simple Targeting Logic
- **Database**: Thêm cột `target_device_id` vào bảng `commands`.
- **Logic**: Python script sẽ nhận diện một `CLIENT_ID` (lấy từ tên máy tính hoặc UUID) và chỉ thực thi các lệnh có `target_device_id` khớp hoặc null.

</decisions>

<canonical_refs>
- `app/lib/ui/screens/home_screen.dart` — Giao diện cần đánh bóng.
- `src/main.py` — Luồng xử lý cần tối ưu.

</canonical_refs>

<specifics>
## Specific Ideas
- Hiệu ứng Glitch sử dụng package `animated_glitch` hoặc custom widget.
- Âm thanh "Bíp" nhẹ khi JARVIS bắt đầu nghe lệnh (giống Google Assistant/Siri).

</specifics>

<deferred>
## Deferred Ideas
- **Phase 5**: Full Supabase Auth (Đăng nhập social, quản lý tài khoản).
- **Phase 5**: Device Management UI (Danh sách các thiết bị đang online để chọn).

</deferred>

---
*Phase: 04-integration-polish-the-jarvis-experience*
*Context gathered: 2026-04-18*
