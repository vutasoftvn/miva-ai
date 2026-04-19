# Xây dựng MVP cho Trợ lý ảo MIVA

Để xây dựng một MVP (Minimum Viable Product) cho trợ lý ảo MIVA sử dụng bộ tứ **Flutter - Supabase - Python - Groq**, chúng ta cần tập trung vào việc tối ưu hóa "vòng lặp phản hồi" (Feedback Loop) sao cho tốc độ phản hồi gần như tức thì.

Dưới đây là phân tích chi tiết các thành phần cốt lõi của MVP này:

## 1. Kiến trúc tổng thể của MVP
MVP này không cần quá nhiều tính năng màu mè, mà cần tập trung vào tốc độ và khả năng thực thi lệnh.

| Thành phần | Công nghệ | Vai trò trong MVP |
| :--- | :--- | :--- |
| **Giao diện (Frontend)** | Flutter | Nhận giọng nói (STT), hiển thị phản hồi và trạng thái hệ thống. |
| **Giao tiếp (Real-time)** | Supabase | Lưu trữ bảng `commands`. Dùng Realtime để báo cho Python khi có lệnh mới. |
| **Trí tuệ (AI Engine)** | Groq API | Xử lý ngôn ngữ tự nhiên cực nhanh (Llama 3 70B/8B) để trích xuất ý định (Intent). |
| **Thực thi (Backend)** | Python | Chạy ngầm trên máy tính, thực hiện lệnh Terminal/Web và trả kết quả. |

## 2. Các tính năng cốt lõi (Core Features)

### A. Tối ưu hóa tốc độ với Groq
Điểm yếu của các trợ lý AI hiện nay là độ trễ (latency). Với Groq, MVP này sẽ đạt được tốc độ xử lý hàng trăm token/giây.
*   **Prompt Engineering**: Thiết kế System Prompt để Groq luôn trả về định dạng JSON (ví dụ: `{"action": "open_web", "url": "youtube.com"}`).
*   **Streaming**: Tận dụng khả năng stream kết quả của Groq để hiển thị văn bản lên Flutter ngay khi AI đang "nghĩ".

### B. Cơ chế "Lắng nghe" Real-time qua Supabase
Thay vì Flutter gọi trực tiếp Python (khó thiết lập khi ở khác mạng), chúng ta dùng Supabase làm trung gian:
1.  **Flutter** insert một row vào bảng `commands`: `{ "text": "Mở terminal và check IP", "status": "pending" }`.
2.  **Python script** sử dụng thư viện `supabase-py` để lắng nghe sự kiện `INSERT`.
3.  Khi có hàng mới, Python ngay lập tức lấy text đó gửi cho Groq.

### C. Thực thi lệnh hệ thống (Action Execution)
Đây là phần "MIVA" nhất. Script Python sẽ đảm nhận:
*   **Web**: `webbrowser.open(url)`
*   **Terminal**: `subprocess.run(command, shell=True, capture_output=True)`
*   **Apps**: `os.startfile(path)` (Windows) hoặc `open -a (app_name)` (macOS).

## 3. Kế hoạch triển khai MVP (4 Bước)

### Bước 1: Thiết lập Supabase (5 phút)
*   Tạo bảng `miva_logs` với các cột: `id`, `input_text`, `ai_response`, `action_json`, `status` (pending/processing/done).
*   Bật tính năng **Realtime** cho bảng này.

### Bước 2: Viết "Bộ não" Python với Groq (15 phút)
Sử dụng mô hình `llama3-70b-8192` của Groq để đảm bảo sự thông minh.

```python
# Mẫu logic xử lý của Python
def handle_command(payload):
    user_input = payload['new']['input_text']
    # Gọi Groq API để lấy Intent
    chat_completion = groq_client.chat.completions.create(
        messages=[
            {"role": "system", "content": "Trả về JSON: action, target"},
            {"role": "user", "content": user_input}
        ],
        model="llama3-70b-8192",
    )
    # Thực thi lệnh dựa trên action nhận được
    execute_action(chat_completion.choices[0].message.content)
```

### Bước 3: Build giao diện Flutter (30 phút)
*   Dùng package `speech_to_text` để chuyển giọng nói thành văn bản.
*   Khi nhấn nút "Speak", Flutter đẩy văn bản lên Supabase.
*   Lắng nghe bảng `miva_logs` để hiển thị `ai_response` khi Python cập nhật kết quả.

### Bước 4: Kiểm thử Terminal & Web
*   **Test lệnh Web**: "Truy cập Facebook và tìm kiếm NetHyTech".
*   **Test lệnh Terminal**: "Liệt kê các file trong thư mục Downloads".

## 4. Tại sao MVP này khả thi và hiệu quả?
*   **Chi phí cực thấp**: Supabase có gói miễn phí hào phóng, Groq hiện tại cung cấp hạn mức miễn phí rất cao cho developer.
*   **Khả năng mở rộng**: Sau MVP, bạn có thể dễ dàng thêm tính năng Vision (nhìn qua camera) bằng cách gửi ảnh lên Supabase Storage và dùng mô hình LAVA qua Groq.
*   **Trải nghiệm người dùng**: Nhờ Groq, người dùng sẽ có cảm giác đang nói chuyện với một con người thật sự vì không phải chờ đợi AI "nhả" từng chữ.

Phase 5 (Mới): Authentication & Device Orchestration. Chúng ta sẽ xây dựng hệ thống đăng nhập bằng Supabase Auth, danh sách thiết bị và khả năng chọn thiết bị "Active" để nhận lệnh.