# Phase 2: AI Intelligence - Plan

## Goal
Tích hợp Groq API (`llama3-8b-8192`) để biến ngôn ngữ tự nhiên thành lệnh thực thi hệ thống và phản hồi văn bản thông minh.

## Tasks

### Wave 1: AI Backbone
1. **Groq Client Integration**: Viết module quản lý kết nối Groq.
    - **Files**: `src/brain.py`, `requirements.txt`
    - **Action**: 
        - Thêm `groq` vào `requirements.txt`.
        - Implement class `JarvisBrain` sử dụng JSON Mode.
        - Xây dựng System Prompt định nghĩa các "Hands" (skills).
    - **Acceptance**: `JarvisBrain.ask("Mở google")` trả về JSON hợp lệ với action `open_web`.

2. **Memory Manager**: Xây dựng cơ chế nhớ ngắn hạn.
    - **Files**: `src/brain.py`
    - **Action**: Sử dụng list/deque để lưu trữ 10 lượt hội thoại gần nhất và gửi kèm trong OpenAI message format.
    - **Acceptance**: AI có thể hiểu các câu lệnh tham chiếu (ví dụ: "Mở nó" sau khi nhắc đến một trang web).

### Wave 2: System Integration
3. **Bridge Main Loop to Brain**: Kết nối Listener với Brain.
    - **Files**: `src/main.py`
    - **Action**: 
        - Trong `handle_new_command`, thay vì thực thi trực tiếp `action_json` từ database (nếu trống), hãy gọi `JarvisBrain`.
        - Cập nhật kết quả vào database.
    - **Acceptance**: Khi user chỉ gửi `input_text` vào Supabase, Python tự gọi Groq để điền `action_json` trước khi thực thi.

4. **Response Feedback Loop**: Đồng bộ hóa phản hồi AI.
    - **Files**: `src/main.py`, `src/database.py`
    - **Action**: Đảm bảo `ai_response` (văn bản) từ Groq được hiển thị và cập nhật chính xác trên Supabase.
    - **Acceptance**: Cột `ai_response` trong Supabase hiển thị đúng câu trả lời từ AI.

## Verification
### Must-Haves
- [ ] Groq phân loại đúng ít nhất 3 loại intent: `open_web`, `run_terminal`, `launch_app`.
- [ ] Phản hồi JSON luôn hợp lệ (nhờ JSON Mode).
- [ ] Có bộ nhớ hội thoại (thực hiện lệnh dựa trên ngữ cảnh trước đó).
- [ ] Tốc độ trích xuất Intent từ Groq đạt mức < 1s.

### Confidence Score
90%
