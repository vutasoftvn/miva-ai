# Phase 2: AI Intelligence - Context

**Gathered:** 2026-04-18
**Status:** Ready for planning
**Source:** User decisions

<domain>
## Phase Boundary
Tích hợp Groq API vào hệ thống để trích xuất Intent từ user input. Chuyển đổi ngôn ngữ tự nhiên thành cấu trúc `action_json` mà Phase 1 có thể thực thi.

</domain>

<decisions>
## Implementation Decisions

### AI Brain Configuration
- **Model**: `llama3-8b-8192` (Tối ưu tốc độ phản hồi).
- **Library**: `groq` official Python SDK.
- **Context Management**: Lưu trữ và gửi 10 lượt hội thoại gần nhất (Short-term memory).
- **Format**: Ép buộc AI trả về JSON sử dụng `System Prompt` và `tool/function calling` hoặc `JSON Mode`.

### Intent Extraction Logic
- **Success Case**: Trả về JSON `{ "action": "...", "params": { ... } }`.
- **Ambiguous Case**: Nếu không chắc chắn, AI trả về văn bản phản hồi thông thường thay vì cố gắng tạo `action_json`.
- **Fallback**: Log lỗi khi trích xuất JSON thất bại và yêu cầu người dùng làm rõ.

### Integration with Phase 1
- Python listener sẽ gửi `input_text` từ Supabase tới Groq.
- Groq trả về `ai_response` (văn bản) và `action_json` (nếu có).
- Kết quả từ Groq được ghi ngược lại bảng `commands` trên Supabase để Phase 1 (Executor) thực thi (hoặc thực thi trực tiếp trong cùng loop).

</decisions>

<canonical_refs>
## Canonical References
- `src/executor.py` — Chứa định nghĩa các action được hỗ trợ.
- `src/database.py` — Để ghi nhận kết quả AI.
- `.planning/phases/01-infrastructure-connection-the-nervous-system/01-CONTEXT.md`

</canonical_refs>

<specifics>
## Specific Ideas
- Viết một `System Prompt` rõ ràng về các "Hands" (kỹ năng) mà JARVIS đang có (Web, Terminal, Apps).
- Sử dụng biến môi trường `GROQ_API_KEY`.

</specifics>

<deferred>
## Deferred Ideas
- Streaming AI response (tạm thời lấy full response cho MVP).
- Reranking intent.

</deferred>

---
*Phase: 02-ai-intelligence-the-brain*
*Context gathered: 2026-04-18*
