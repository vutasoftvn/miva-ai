# PROJECT: JARVIS MVP

## What This Is
Một trợ lý ảo AI (JARVIS) có khả năng phản hồi gần như tức thì, tập trung vào việc thực thi lệnh hệ thống và truy cập web thông qua sự kết hợp giữa Flutter, Supabase, Python và hạ tầng tăng tốc của Groq.

## Core Value (Why it exists)
Tối ưu hóa "vòng lặp phản hồi" (Feedback Loop) để đạt được tốc độ xử lý hàng trăm token/giây, mang lại cảm giác giao tiếp tự nhiên và khả năng thực thi mạnh mẽ trên máy tính cá nhân.

## Context
- **Frontend**: Flutter (xử lý giọng nói và hiển thị kết quả).
- **Backend/Execution**: Python (chạy ngầm trên máy tính, thực thi Shell/Web).
- **Middleware**: Supabase (Realtime table để truyền nhận lệnh).
- **AI Brain**: Groq API (Sử dụng Llama 3 70B/8B để trích xuất Intent nhanh nhất).

## Requirements

### Validated
(None yet — ship to validate)

### Active
- [ ] **Real-time Command Pipeline**: Flutter gửi văn bản lên Supabase -> Python lắng nghe và xử lý ngay lập tức.
- [ ] **AI Intent Extraction**: Sử dụng Groq để convert user input sang JSON actions (web, terminal, apps).
- [ ] **Action Execution Engine**: Python script thực thi lệnh:
    - Web opening (`webbrowser`)
    - Terminal commands (`subprocess`)
    - App launching (`os.startfile` / `open`)
- [ ] **Voice Interface**: Flutter tích hợp `speech_to_text` để nhận lệnh giọng nói.
- [ ] **Streaming Feedback**: Hiển thị phản hồi từ AI theo thời gian thực (streaming) trên giao diện Flutter.

### Out of Scope
- [ ] Vision capabilities (tạm thời để lại sau MVP).
- [ ] Phân quyền người dùng phức tạp (MVP mặc định chạy trên máy local của người dùng).

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| **Groq API** | Đạt tốc độ hàng trăm token/giây, giảm latency xuống mức tối thiểu. | Cho phép phản hồi gần như tức thì |
| **Supabase Realtime** | Trung gian truyền nhận lệnh giữa Flutter và Python mà không cần thiết lập mạng phức tạp (Port forwarding). | Đơn giản hóa kiến trúc kết nối |
| **Python Backend** | Quyền truy cập trực tiếp vào hệ thống (OS calls) để thực thi lệnh. | Khả năng thực thi lệnh hệ thống mạnh mẽ |

## Evolution
This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-04-18 after initialization*
