# Technical Concerns & Risks

## Critical Security Issues

### 1. Hardcoded Credentials
- **Location**: `app/lib/core/config/supabase_config.dart`
- **Issue**: Supabase anonymous key embedded in source code
- **Risk**: Public key exposure via compiled app; no secrets rotation capability
- **Impact**: CRITICAL - Anyone can access backend database
- **Remediation**: Use environment-based configuration, rotate key on deployment

### 2. API Key in Example Config
- **Location**: `.env.example` with Groq API key visible
- **Issue**: Example shows real (or template) API key
- **Risk**: Accidental commit of actual key; key rate-limit exhaustion
- **Impact**: HIGH - API quota abuse, service disruption
- **Remediation**: Keep example with placeholder `GROQ_API_KEY=your_key_here`

### 3. Missing Backend Authentication
- **Issue**: Python backend accepts any request from Supabase realtime
- **Problem**: No device authentication or Flutter↔Python session validation
- **Risk**: Unauthorized command execution if Supabase credentials compromised
- **Impact**: HIGH - Lateral attack surface
- **Remediation**: Add JWT or session tokens, validate origin

### 4. Insufficient Command Input Validation
- **Location**: `src/executor.py` whitelist enforcement
- **Issue**: Terminal command parsing relies on regex; no sanitization
- **Risk**: Command injection via specially crafted parameters
- **Impact**: CRITICAL for terminal execution
- **Remediation**: Use subprocess API with explicit argument list, not shell=True

## Performance Bottlenecks

### 1. IPC Latency via Supabase
- **Path**: Flutter voice input → Supabase DB insert → Python realtime listener → Groq API → Response → Flutter TTS
- **Latency**: 500-2000ms round trip typical
- **Bottleneck**: Database event propagation, Groq API calls (~2-10s per request)
- **Impact**: Slow voice-to-action feedback loop
- **Mitigation**: 
  - Implement direct HTTP/WebSocket connection for low-latency commands
  - Cache frequently used AI responses
  - Use streaming responses from Groq API

### 2. Synchronous Groq API Calls
- **Location**: `src/brain.py` - blocking wait for Groq response
- **Issue**: No concurrent request handling; one command at a time
- **Risk**: Queuing delays if multiple devices issue commands
- **Impact**: MEDIUM - Scales poorly with multi-device usage
- **Remediation**: Implement async queue with timeout handling

### 3. Unbounded Realtime Subscriptions
- **Location**: `app/lib/controllers/miva_controller.dart`
- **Issue**: No subscription cleanup on screen exit
- **Risk**: Memory leaks, multiple listeners, database connection exhaustion
- **Impact**: App performance degradation over time
- **Remediation**: Cancel subscriptions in `onClose()`, implement refresh logic

## Fragile & Untested Areas

### 1. AI Intent Parser Schema
- **Module**: `src/brain.py`
- **Issue**: Groq response parsing has no schema validation
- **Risk**: Unexpected response format crashes command execution
- **Probability**: Medium (LLMs sometimes format unexpectedly)
- **Remediation**: 
  ```python
  response = validate_schema(groq_response, IntentSchema)
  ```
  - Add Pydantic models for response validation

### 2. Zero Test Coverage
- **Scope**: All modules (Python and Dart)
- **Critical gaps**: 
  - No security validation tests for executor
  - No recovery tests for connection loss
  - No multidevice state sync tests
- **Remediation**: Add pytest suite for Python, flutter_test for Dart

### 3. Device Identification via Hostname
- **Location**: `src/executor.py` - device_name for command targeting
- **Issue**: Hostname can be changed by user, not reliable for security
- **Risk**: Unintended command execution on wrong device
- **Impact**: MEDIUM - Incorrect target but catches at whitelist
- **Remediation**: Use unique device ID (UUID stored in local storage)

### 4. No Connection Loss Handling
- **Module**: `app/lib/controllers/miva_controller.dart`
- **Issue**: Disconnection from Supabase realtime not gracefully handled
- **Risk**: App appears responsive but commands don't execute
- **Remediation**: 
  - Add connection status indicator in UI
  - Implement exponential backoff reconnect
  - Queue commands for retry on reconnect

## Scaling Limitations

### 1. Single Python Instance Bottleneck
- **Issue**: One Python process handles all commands globally
- **Scaling**: Cannot scale to > 1000 concurrent users
- **Remediation**: Containerize with load balancer, implement queue-based worker pool

### 2. Supabase Free Tier Limits
- **Connection limit**: 200 simultaneous
- **Database size**: 500MB
- **Realtime**: Limited subscribers per table
- **Risk**: Service outage at scale
- **Remediation**: Plan for paid tier at 200+ users

### 3. Groq API Rate Limits
- **Free tier**: 500 requests/day
- **Rate**: 30 requests/minute
- **Risk**: Service degradation during peak usage
- **Remediation**: Implement token bucket rate limiter, queue long-tail requests

### 4. Database Growth Strategy
- **Current**: Commands table unbounded growth
- **Risk**: Query slowdown, storage exhaustion
- **Remediation**: Implement command archival (>30 days moved to cold storage)

## Missing Critical Features

### 1. Multi-Device Support
- **Issue**: No device authentication or multi-device targeting
- **Gap**: App works for single device only
- **Requirements**: Device UUID, device registry, secure pairing flow

### 2. Command Confirmation
- **Issue**: Commands execute immediately without user confirmation
- **Risk**: Accidental destructive actions (e.g., terminal rm commands)
- **Remediation**: Add confirmation dialog for high-risk commands

### 3. Offline Mode
- **Issue**: App requires constant Supabase connection
- **Risk**: Cannot function if Supabase is down (5-10min/month uptime = ~72min/year)
- **Remediation**: Queue commands locally, sync when online

### 4. Rate Limiting & Abuse Prevention
- **Issue**: No request throttling or spam protection
- **Risk**: DOS via rapid command issuance, API quota exhaustion
- **Remediation**: Rate limit per device (10 commands/minute), implement IP-based blocking

## Platform-Specific Concerns

### iOS
- **STT/TTS**: `speech_to_text`, `flutter_tts` packages (untested)
- **Risk**: May fail silently if permissions not granted
- **Remediation**: Add permission check UI flow

### Android
- **STT/TTS**: Same packages with Android-specific quirks
- **Risk**: Audio focus loss during playback; TTS interruption
- **Remediation**: Manage audio focus properly

### macOS
- **Status**: Minimally tested
- **Concern**: Native integration incomplete
- **Gap**: No terminal execution on macOS (executor.py Linux/Windows only)

### Web
- **Status**: Not tested
- **Limitations**: No STT/TTS in browsers (needs polyfills), no local terminal access

## Operational Concerns

### Monitoring & Observability
- **Current**: None - no logging to external service
- **Gap**: Cannot diagnose production issues
- **Remediation**: Add Sentry or similar error tracking

### Authentication & Access Control
- **Current**: None
- **Gap**: Anyone with Flutter app can access all commands
- **Remediation**: Implement user authentication and role-based access

### Compliance
- **Data privacy**: No GDPR/CCPA considerations
- **Audit trail**: No command logging or approval workflow
- **Remediation**: Add command audit log, user consent flows
