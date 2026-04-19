# Phase 1: Infrastructure & Connection - Plan

## Goal
Thiết lập hệ thống truyền nhận lệnh Realtime giữa Supabase và Python, cho phép thực thi các lệnh hệ thống cơ bản (Web, Terminal, Apps) một cách an toàn.

## Context
- **Middleware**: Supabase `commands` table.
- **Backend**: Python script (Asynchronous listener).
- **Execution**: `subprocess` and `webbrowser` modules.

## Threat Model (Security)
- **Threat**: Command Injection via `input_text`.
- **Mitigation**: 
    - Tuyệt đối không dùng `shell=True` trong `subprocess`.
    - Sử dụng **Whitelist** nghiêm ngặt cho các lệnh Terminal.
    - Validate tham số đầu vào bằng `isalnum()` hoặc regex.

## Tasks

### Wave 1: Supabase Setup
1. **[BLOCKING] Create `commands` table**: Chạy script SQL để khởi tạo bảng và bật Realtime.
    - **Files**: `.planning/phases/01-infrastructure-connection-the-nervous-system/setup.sql`
    - **Action**: Tạo bảng `commands` (id, input_text, ai_response, action_json, status, created_at). Chạy `ALTER PUBLICATION supabase_realtime ADD TABLE commands`.
    - **Acceptance**: Bảng `commands` xuất hiện trong Supabase Dashboard và tab Realtime được bật.

### Wave 2: Python Framework
2. **Setup Python Environment**: Khởi tạo project Python và cài đặt thư viện.
    - **Files**: `requirements.txt`, `.env.example`
    - **Action**: Cài đặt `supabase`, `python-dotenv`. Tạo `.env.example` với các key cần thiết.
    - **Acceptance**: `pip install -r requirements.txt` chạy thành công. `.env` có đầy đủ URL và Keys.

3. **Core Database Client**: Viết module kết nối Supabase.
    - **Files**: `src/database.py`
    - **Read First**: `.planning/phases/01-infrastructure-connection-the-nervous-system/01-RESEARCH.md`
    - **Action**: Implement `acreate_client` và helper method để lắng nghe `INSERT`.
    - **Acceptance**: Python script có thể in ra "Connected to Supabase" khi chạy.

### Wave 3: Execution & Loop
4. **Action Executor Engine**: Viết module thực thi lệnh.
    - **Files**: `src/executor.py`
    - **Action**: Implement whitelist check và các hàm `open_web`, `run_terminal`, `launch_app`.
    - **Acceptance**: Gọi `run_terminal("ls")` trả về kết quả; `run_terminal("rm -rf")` bị chặn.

5. **Main Listener Loop**: Hoàn thiện kịch bản chạy ngầm.
    - **Files**: `src/main.py`
    - **Action**: Tích hợp listener và executor. Khi nhận lệnh `pending`, thực thi và update status lên `done`.
    - **Acceptance**: Khi insert thủ công một row `{ "input_text": "ping", "action_json": {"action": "run_terminal", "command": "ls"} }` vào database, Python script thực hiện và cập nhật trạng thái bảng.

## Verification
### Must-Haves
- [ ] Bảng `commands` trên Supabase có Realtime enabled.
- [ ] Python script nhận được sự kiện INSERT ngay lập tức mà không cần polling.
- [ ] Lệnh `run_terminal` chỉ thực thi các lệnh trong whitelist.
- [ ] Trạng thái lệnh được cập nhật tự động từ `pending` sang `done` sau khi thực thi.

### Confidence Score
95% (Dựa trên research standard về `supabase-py` và Python security).
