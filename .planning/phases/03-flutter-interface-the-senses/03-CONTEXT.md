# Phase 3: Flutter Interface - Context

**Gathered:** 2026-04-18
**Status:** Ready for planning
**Source:** User decisions

<domain>
## Phase Boundary
Xây dựng ứng dụng Flutter đa nền tảng (Mobile & Desktop) tích hợp nhận diện giọng nói và hiển thị phản hồi từ JARVIS Realtime.

</domain>

<decisions>
## Implementation Decisions

### Design & Aesthetic
- **Style**: Futuristic HUD (Heads-Up Display).
- **Colors**: Deep blues, neons, glow effects, glassmorphism.
- **Animations**: Lottie hoặc Custom Paint cho sóng âm (visualizer) khi người dùng nói.

### Technology Stack (Frontend)
- **Framework**: Flutter.
- **State Management**: `GetX` (User's choice).
- **Speech-to-Text**: `speech_to_text` package (on-device STT).
- **Communication**: `supabase_flutter` để subscribe vào bảng `commands`.

### Platforms
- Hỗ trợ iOS, Android, macOS, Windows.

### User Flow
1. Người dùng nhấn giữ (hoặc nhấn) nút Micro.
2. Sóng âm Futuristic hiện thị khi đang nghe.
3. Khi dừng nói, text được gửi lên bảng `commands` (INSERT).
4. Lắng nghe (Subscribe) tại id đó để nhận `ai_response` từ Supabase và hiển thị lên màn hình.

</decisions>

<canonical_refs>
## Canonical References
- `PROJECT.md` — Core values (visual excellence).
- `setup.sql` — Bảng `commands` schema.

</canonical_refs>

<specifics>
## Specific Ideas
- Sử dụng phông chữ kiểu công nghệ (Roboto Mono hoặc Orbitron).
- Hiệu ứng "typewriter" khi hiển thị phản hồi của AI.

</specifics>

<deferred>
## Deferred Ideas
- Wake word "Hey Jarvis" (bản MVP dùng nút bấm).
- Custom Voice (TTS).

</deferred>

---
*Phase: 03-flutter-interface-the-senses*
*Context gathered: 2026-04-18*
