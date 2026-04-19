# Research: Phase 2 - AI Intelligence

## Tech Research Findings

### 1. Groq JSON Mode
- **Configuration**: Set `response_format={"type": "json_object"}`.
- **Strict Requirement**: The `system` message MUST contain the word "JSON" and describe the expected schema.
- **Schema Recommendation**:
    ```json
    {
      "reply": "Văn bản phản hồi người dùng",
      "action": {
        "type": "open_web | run_terminal | launch_app | none",
        "params": { ... }
      }
    }
    ```
    - `type: none` if no system action is required.

### 2. Conversational Memory
- **Pattern**: A deque or list of dictionaries `{"role": "user/assistant", "content": "..."}`.
- **Trimming**: Keep only the last `N` messages. 
- **Persistence**: For MVP, memory can be stored in-memory in `src/main.py`. For cross-session, it would need a table in Supabase.

### 3. System Prompt Strategy
- Describe JARVIS as an OS-integrated AI.
- List available "Hands" (skills) with examples:
    - `open_web(url)`: Use for requests to open websites.
    - `run_terminal(command)`: Use for system info (ls, ping, whoami).
    - `launch_app(app_name)`: Use for opening specific software.

### 4. Intent Extraction Reliability
- **Pydantic Validation**: Highly recommended to validate Groq's JSON output before passing it to the executor.

## Recommended Patterns
- **Brain Module**: Create `src/brain.py` to encapsulate Groq logic.
- **Workflow**:
    1. Input from Supabase.
    2. Load last 10 messages.
    3. Call Groq with JSON Mode.
    4. Parse and validate JSON.
    5. Update Supabase with `ai_response` and `action_json`.
