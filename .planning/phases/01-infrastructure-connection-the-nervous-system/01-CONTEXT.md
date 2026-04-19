# Phase 1: Infrastructure & Connection - Context

**Gathered:** 2026-04-18
**Status:** Ready for planning
**Source:** User discussion (aligned with recommendations)

<domain>
## Phase Boundary
Xây dựng lớp giao tiếp trung gian (Nervous System) kết nối Python script với Supabase Cloud. Thiết lập khả năng thực thi lệnh hệ thống cơ bản và quản lý trạng thái lệnh Realtime.

</domain>

<decisions>
## Implementation Decisions

### Supabase Architecture
- **Table Name**: `commands`
- **Schema**:
    - `id`: UUID (Primary Key, default gen_random_uuid())
    - `input_text`: TEXT (Lệnh thô từ người dùng)
    - `ai_response`: TEXT (Phản hồi văn bản từ AI)
    - `action_json`: JSONB (Chứa action và params, e.g., `{"action": "open_web", "url": "..."}`)
    - `status`: TEXT (Mặc định: `pending`, các trạng thái khác: `processing`, `done`, `error`)
    - `created_at`: TIMESTAMPTZ (Mặc định: now())
- **Realtime**: Kích hoạt Realtime cho bảng `commands`.

### Python Backend
- **Library**: `supabase-py` cho kết nối database và realtime.
- **Connection**: Python script chạy một instance duy nhất, lắng nghe sự kiện `INSERT` trên bảng `commands`.
- **Environment**: Sử dụng `python-dotenv` và file `.env` (excluded từ git) để lưu `SUPABASE_URL` và `SUPABASE_KEY`.

### Action Execution
- **Web**: Dùng module `webbrowser`.
- **Terminal**: Dùng `subprocess`. Chế độ MVP chỉ cho phép các lệnh whitelist (đọc thông tin): `ls`, `pwd`, `whoami`, `ping`, `ipconfig`, `ifconfig`.
- **Apps**: Sử dụng module `platform` để phân biệt OS (`open -a` cho macOS, `os.startfile` cho Windows).

### the agent's Discretion
- Chi tiết cấu trúc file Python (chia module hay gộp chung trong MVP).
- Cách log lỗi cục bộ trên file `jarvis.log` tại máy tính.

</decisions>

<canonical_refs>
## Canonical References
- `context.md` — Original project vision.
- `.planning/research/STACK.md` — Tech stack recommendations.
- `.planning/research/ARCHITECTURE.md` — System design patterns.

</canonical_refs>

<specifics>
## Specific Ideas
- Python script nên hiển thị trạng thái "JARVIS is listening..." khi bắt đầu.
- Khi một lệnh được thực thi, Python phải update ngược lại Supabase cột `status` sang `done`.

</specifics>

<deferred>
## Deferred Ideas
- Bảo mật RLS (Row Level Security) nâng cao (MVP dùng Service Role key hoặc Public tạm thời để dev nhanh).
- Voice selection (giọng đọc AI).

</deferred>

---
*Phase: 01-infrastructure-connection-the-nervous-system*
*Context gathered: 2026-04-18*
