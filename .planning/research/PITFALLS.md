# Pitfalls Research: JARVIS MVP

## Technical Pitfalls

### 1. Latency Accumulation
- **Problem**: STT Delay + Network Latency + Groq TTFT + Supabase Broadcast.
- **Prevention**: Use high-performance STT plugins, ensure proximity to Supabase servers, and use Groq's fastest models (`8b`).

### 2. Prompt Injection / Shell Injection
- **Problem**: "JARVIS, run `rm -rf /`".
- **Prevention**: 
    - **Whitelist**: Only allow specific terminal commands in MVP.
    - **Validation**: Python script must validate the `action` JSON strictly before passing to `subprocess`.
    - **Pydantic**: Use strict schema validation for LLM outputs.

### 3. Token Limits and Context Loss
- **Problem**: Conversational history filling up the context window.
- **Prevention**: Implement simple history trimming (keep last 5-10 exchanges) for the MVP.

### 4. Supabase Network Connectivity
- **Problem**: Python listener dropping connection due to idle timeouts.
- **Prevention**: Implement a "heartbeat" or automatic reconnection logic in the Python script.

### 5. Platform Compatibility (macOS vs Windows)
- **Problem**: `os.startfile` only works on Windows; `open` works on macOS.
- **Prevention**: Use `platform.system()` in Python to handle cross-platform command execution paths.

## Development Mistakes
- **Vibes-based testing**: "It seems fast" isn't enough. Measure `Time to First Token (TTFT)` and `Total Turnaround Time`.
- **Ignoring Streaming**: Waiting for the full LLM response makes the assistant feel like a slow 2023 bot.
