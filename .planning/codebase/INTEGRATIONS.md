# External Integrations

**Analysis Date:** 2026-04-19

## APIs & External Services

**AI & Inference:**
- Groq (Fast Inference API) - What it's used for: Real-time intent recognition and action planning from natural language
  - SDK/Client: groq==0.5.0 (Python)
  - Auth: GROQ_API_KEY environment variable
  - Model: llama3-8b-8192
  - Integration: Backend (`/Volumes/SSD/DEV/javis/src/brain.py`) uses Groq for chat completions with JSON schema output

**Real-time Communication:**
- Supabase Realtime - What it's used for: Bi-directional command flow between Flutter frontend and Python backend
  - SDK/Client: supabase_flutter 2.4.0 (Dart), supabase==2.4.0 (Python)
  - Auth: SUPABASE_KEY (anonymous key), SUPABASE_URL
  - Integration: Shared database acts as message broker for cross-platform IPC

## Data Storage

**Databases:**
- Supabase PostgreSQL
  - Connection: Configured via SUPABASE_URL and SUPABASE_KEY environment variables
  - Client: supabase_flutter (Dart), Async Supabase client (Python)
  - Tables used:
    - `commands` - Stores user commands with fields: `id`, `input_text`, `status` (pending/processing/done), `ai_response`, `action_json`, `target_device_id`
  - Realtime subscriptions: `commands` table listens for INSERT and UPDATE events

**File Storage:**
- Local filesystem only - No cloud storage integration configured

**Caching:**
- In-memory only - No dedicated caching service (Groq responses not cached between sessions)

## Authentication & Identity

**Auth Provider:**
- Supabase Auth (optional, not currently implemented in MVP)
  - Implementation approach: Anonymous key used for table access, no user authentication layer currently

**Device Identification:**
- Hostname-based (`socket.gethostname()`) - Python backend identifies itself by machine hostname
  - Used for: Multi-device support (target_device_id field in commands table allows command routing to specific devices)

## Monitoring & Observability

**Error Tracking:**
- None - No dedicated error tracking service (Sentry, Rollbar, etc.)

**Logs:**
- Console/stdout - Backend (`src/main.py`, `src/brain.py`, `src/executor.py`) logs to console
  - Flutter frontend logs to debug output (visible in IDE only)

## CI/CD & Deployment

**Hosting:**
- Python Backend: Self-hosted on user's desktop machine (local daemon service)
- Flutter Frontend: Multi-platform (iOS, Android, macOS, Windows, Linux, Web)
- Database & Auth: Supabase (cloud-hosted at https://jgtgayqwcwocnxchdpbt.supabase.co)

**CI Pipeline:**
- None - No automated CI/CD configured (manual build and deploy)

## Environment Configuration

**Required env vars:**
- `SUPABASE_URL` - Supabase project URL (hardcoded in Flutter config, also in .env for Python)
- `SUPABASE_KEY` - Anonymous key for Supabase access (hardcoded in Flutter config, also in .env for Python)
- `GROQ_API_KEY` - API key for Groq LLM service (Python only, loaded via python-dotenv)

**Secrets location:**
- `.env` file in project root (not committed to git)
- `.env.example` provides template with placeholder values
- Flutter config: `app/lib/core/config/supabase_config.dart` contains hardcoded Supabase credentials

## Webhooks & Callbacks

**Incoming:**
- None - No webhook endpoints exposed

**Outgoing:**
- None - No external webhooks triggered

## Cross-Platform Communication (IPC)

**Architecture:**
- **Supabase Realtime as Message Broker**: Instead of direct socket communication, Miva uses Supabase as a centralized pub/sub system
- No direct HTTP/WebSocket between Flutter and Python
- No local IPC (named pipes, Unix sockets, etc.)

**Flow Diagram:**

```
USER (Flutter App)
    ↓ (Voice Input via STT)
FLUTTER FRONTEND (app/lib/)
    ↓ insert command
SUPABASE (commands table)
    ↓ Realtime notify
PYTHON BACKEND (src/)
    ├─ brain.py: Request intent to Groq
    ├─ executor.py: Execute system actions
    └─ database.py: Update command status
    ↓ update command row
SUPABASE (commands table)
    ↓ Realtime stream listener
FLUTTER FRONTEND (app/lib/)
    ↓ (TTS output)
USER (Voice Response)
```

## Command Lifecycle (Frontend → Backend)

**Step 1: User Speaks (Flutter)**
- User taps microphone button → `startListening()` in `app/lib/controllers/miva_controller.dart`
- Speech-to-text conversion via `speech_to_text` package (native platform APIs)

**Step 2: Command Insertion (Flutter)**
- Recognized text sent via `supabase.from('commands').insert({'input_text': text})`
- Returns command record with auto-generated `id`
- Location: `app/lib/controllers/miva_controller.dart:_sendCommand()` (lines 67-71)

**Step 3: Python Listens (Backend)**
- Python service maintains Realtime subscription: `channel.on_postgres_changes(event="INSERT", table="commands")`
- Location: `src/database.py:listen_to_commands()` (lines 21-38)
- Callback: `src/main.py:handle_new_command()` processes new commands

**Step 4: AI Processing (Backend)**
- `MivaBrain.ask()` in `src/brain.py` sends user input to Groq API
- System prompt instructs Groq to return JSON: `{"reply": "...", "action": {...}}`
- Response includes: `reply` (text response) and `action` (structured intent: type, params)
- Location: `src/brain.py` (lines 39-74)

**Step 5: Action Execution (Backend)**
- `ActionExecutor.execute()` in `src/executor.py` dispatches to appropriate handler
- Supports: `open_web` (webbrowser), `run_terminal` (subprocess), `launch_app` (platform-specific)
- Location: `src/executor.py` (lines 78-92)

**Step 6: Result Storage (Backend)**
- Status updated: `pending` → `processing` → `done`
- Final response written to `ai_response` column
- Location: `src/database.py:update_command_status()` (lines 40-48)

**Step 7: Flutter Response (Frontend)**
- Stream listener on specific command row triggers: `supabase.from('commands').stream(primaryKey: ['id']).eq('id', commandId)`
- Reads `status` and `ai_response` fields
- On `status == 'done'`: TTS service speaks response and stops processing
- Location: `app/lib/controllers/miva_controller.dart:_sendCommand()` (lines 77-102)

## Security & Validation

**Input Validation:**
- Python executor whitelist: Only safe commands allowed (ls, pwd, whoami, ping, date, uptime)
- No shell injection: `subprocess.run()` with `shell=False` (args passed as list, not string)
- URL validation: Basic check for http:// or https:// prefix before opening
- Location: `src/executor.py` (lines 6-46)

**Data Integrity:**
- Target device filtering: Commands can specify `target_device_id` to route to specific machine
- Status tracking prevents duplicate execution (only processes `pending` status)
- Location: `src/main.py:handle_new_command()` (lines 27-32)

**Credential Management:**
- Environment variables via `python-dotenv` - No hardcoded secrets in Python code
- Flutter hardcodes Supabase credentials (anonymous key for read-only access is acceptable)
- Location: `.env` file (not in git), `app/lib/core/config/supabase_config.dart`

## Platform-Specific Native Integrations

**Speech Recognition (STT):**
- iOS: Uses AVFoundation Speech framework
- Android: Uses AndroidSpeechRecognizer API
- Package: `speech_to_text` (abstraction layer)
- Location: `app/lib/controllers/miva_controller.dart` (lines 28-50)

**Text-to-Speech (TTS):**
- iOS: Uses AVFoundation Speech Synthesis
- Android: Uses TextToSpeech service
- Package: `flutter_tts` v3.8.5 with Vietnamese language configuration
- Location: `app/lib/core/services/tts_service.dart` (lines 13-25)

**App Launching (macOS/Windows/Linux):**
- macOS: `open -a [app_name]` command via subprocess
- Windows: `os.startfile([app_name])`
- Linux: Not implemented
- Location: `src/executor.py:launch_app()` (lines 62-76)

---

*Integration audit: 2026-04-19*
