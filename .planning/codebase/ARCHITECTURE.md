# Architecture

**Analysis Date:** 2026-04-19

## Pattern Overview

**Overall:** Client-Server Event-Driven Architecture with Peer-to-Device Communication

**Key Characteristics:**
- Real-time message passing through Supabase Realtime
- Stateless request/response lifecycle via database events
- Device-aware command routing (target_device_id filtering)
- Multi-stage command processing pipeline (pending → processing → done)
- Asynchronous task orchestration with event callbacks

## Layers

**Presentation Layer (Flutter Mobile):**
- Purpose: Voice input interface, real-time response display, audio feedback
- Location: `app/lib/ui/`, `app/lib/controllers/`
- Contains: Screens, UI widgets, state management (GetX controllers)
- Depends on: Supabase client, speech-to-text SDK, text-to-speech SDK
- Used by: End users via mobile app

**Data Transport Layer (Supabase Realtime):**
- Purpose: Event stream mediating between clients and backend
- Location: Cloud-based (managed service)
- Contains: PostgreSQL `commands` table with INSERT/UPDATE triggers
- Depends on: Supabase infrastructure
- Used by: Flutter app and Python backend simultaneously

**Intelligence Layer (Groq LLM):**
- Purpose: Intent extraction and action planning via natural language understanding
- Location: Cloud-based (managed service)
- Contains: `llama3-8b-8192` model with system prompt engineering
- Depends on: Groq API with GROQ_API_KEY credential
- Used by: MivaBrain component for understanding user commands

**Execution Layer (Python Backend):**
- Purpose: System command execution with security constraints
- Location: `src/` (runs locally on target device)
- Contains: ActionExecutor with sanitized terminal/web/app launching
- Depends on: Local OS APIs (subprocess, webbrowser, platform-specific tools)
- Used by: MivaCore orchestrator to implement user intent

**Orchestration Layer (MivaCore):**
- Purpose: Command pipeline coordination and state management
- Location: `src/main.py`
- Contains: Database listening, command routing, result aggregation
- Depends on: DatabaseManager, MivaBrain, ActionExecutor
- Used by: Async event loop (primary entry point)

## Data Flow

**Command Execution Flow:**

1. **Voice Input** (Mobile)
   - User speaks into microphone on Flutter app
   - `MivaController.startListening()` captures audio via `speech_to_text` package
   - Speech recognized as text via on-device STT

2. **Command Insert** (Mobile → Supabase)
   - Flutter calls `supabase.from('commands').insert({'input_text': text})`
   - Command record created with status='pending'
   - Supabase generates unique command ID returned to Flutter

3. **Real-time Subscription** (Mobile)
   - Flutter subscribes to updates on the specific command row
   - Waits for status change from 'pending' to 'processing' to 'done'
   - Displays intermediate statuses (e.g., "Miva AI đang xử lý...")

4. **Backend Detection** (Python → Supabase)
   - Python listener on `src/main.py` receives INSERT event via Realtime
   - `MivaCore.handle_new_command()` callback triggered
   - Command status updated to 'processing' in database

5. **Intent Analysis**
   - If action not pre-provided, `MivaBrain.ask()` sends text to Groq
   - Groq returns JSON with structure: `{"reply": "...", "action": {...}}`
   - Action object contains: `{"action": "open_web|run_terminal|launch_app", "params": {...}}`

6. **Execution** (Python → Local OS)
   - `ActionExecutor.execute()` dispatches to appropriate method
   - Terminal commands: whitelist-filtered via `ALLOWED_TERMINAL_COMMANDS`
   - Web URLs: opened via `webbrowser.open()`
   - Apps: launched via platform-specific commands (macOS: `open -a`, Windows: `os.startfile()`)
   - All commands sandboxed with timeouts (10s) and error handling

7. **Result Aggregation**
   - Execution result captured (stdout, stderr, or status message)
   - Combined with AI reply: `f"{ai_reply}\n\n[Kết quả hệ thống]: {execution_result}"`
   - Final response stored in command record: `ai_response` field

8. **Status Update** (Python → Supabase)
   - Command status updated to 'done' with `ai_response` populated
   - Database triggers Realtime event

9. **Display & Audio Feedback** (Mobile)
   - Flutter receives status='done' event
   - Displays `ai_response` in UI
   - Passes text to `TtsService.speak()` for Vietnamese TTS audio feedback
   - Cleans up subscription stream

**State Management:**
- **Mobile State**: GetX observables in `MivaController` (isListening, isProcessing, aiResponse, hasError, soundLevel)
- **Command State**: PostgreSQL table with atomic status transitions
- **Session State**: Python deque-based conversation history (10-message limit) in `MivaBrain.history`
- **Device Identity**: Python client_id derived from socket.gethostname() for device targeting

## Key Abstractions

**MivaCore (Orchestrator):**
- Purpose: Central state machine managing command lifecycle
- Examples: `src/main.py` (lines 8-87)
- Pattern: Async event listener with callback dispatch

**DatabaseManager (Data Access):**
- Purpose: Supabase client abstraction with Realtime subscription
- Examples: `src/database.py`
- Pattern: Async context manager wrapping acreate_client

**MivaBrain (Intent Parser):**
- Purpose: NLP interface to Groq with conversation memory
- Examples: `src/brain.py`
- Pattern: Async wrapper around Groq SDK with deque-based history

**ActionExecutor (Command Interpreter):**
- Purpose: Sandboxed execution of user intents
- Examples: `src/executor.py`
- Pattern: Command dispatcher with security whitelist enforcement

**MivaController (Mobile State):**
- Purpose: GetX controller binding mobile UI to Supabase streams
- Examples: `app/lib/controllers/miva_controller.dart`
- Pattern: GetX reactive state with stream subscriptions

## Entry Points

**Backend:**
- Location: `src/main.py` (line 89-100)
- Triggers: Manual execution via `python src/main.py` or systemd/cron service
- Responsibilities: Bootstrap MivaCore, install signal handlers, run async event loop

**Mobile:**
- Location: `app/lib/main.dart` (line 7-15)
- Triggers: User launches app on phone
- Responsibilities: Initialize Supabase client, configure theme, display HomeScreen

**Realtime Listen Loop:**
- Location: `src/main.py` line 73-79 (infinite async loop)
- Triggers: Supabase connection established
- Responsibilities: Keep Python process alive, maintain websocket to Realtime

## Error Handling

**Strategy:** Fail-graceful with user-facing feedback

**Patterns:**
- **Brain Errors**: Groq API failures caught in `MivaBrain.ask()` (line 69-74), returns fallback JSON with reply "Xin lỗi, tôi gặp trục trặc..."
- **Executor Errors**: Terminal/web/app failures captured as error messages returned to user (lines 44, 59-60, 76)
- **Database Errors**: Async exceptions in `MivaCore.handle_new_command()` logged with `[CRITICAL ERROR]` prefix (line 82)
- **Missing Action**: If no action parsed and no system action, returns "Tôi không tìm thấy hành động nào cần thực hiện." (line 59)
- **Unsafe Commands**: Terminal whitelist prevents execution, returns security error (line 25)
- **UI Error States**: Flutter detects "Error" or "Exception" in response, sets `hasError.value = true` and applies glitch effect (line 90-91)

## Cross-Cutting Concerns

**Logging:** 
- Backend: Print statements with prefixes ("[MIVA]", "[BRAIN ERROR]", "[CRITICAL ERROR]") to stdout
- Mobile: No explicit logging framework (console would be Dart debug output)
- No structured logging infrastructure or log aggregation

**Validation:**
- URL validation in executor: ensures http(s):// prefix (line 54-55)
- Terminal arg sanitization: alphanumeric-only filters prevent injection (line 30)
- JSON validation in brain: explicit `json.loads()` with exception handling (line 62)
- Command targeting: device_id matching prevents cross-device command execution (line 31-32)

**Authentication:**
- Mobile: Supabase anon key hardcoded in `app/lib/core/config/supabase_config.dart` (public key, not secret)
- Backend: Environment variable `GROQ_API_KEY` loaded via .env
- Database: Supabase RLS (Row-Level Security) policies not enforced in current implementation
- Device identification: Implicit via socket.gethostname() (no cryptographic identity)

**Performance Considerations:**
- Groq latency: ~500ms average response time (depends on token count)
- Supabase Realtime: Sub-100ms delivery for INSERT/UPDATE events
- Python subprocess timeout: Hard 10-second limit on terminal commands (line 39)
- Conversation history: Capped at 10 messages to prevent context window overflow (line 37)
- No caching of Groq responses or action recommendations

---

*Architecture analysis: 2026-04-19*
