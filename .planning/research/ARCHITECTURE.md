# Architecture Research: JARVIS MVP

## Component Boundaries

### 1. Flutter Client (The Ears/Voice)
- **Responsibility**: Speech-to-Text -> String -> Supabase INSERT.
- **Input**: User Voice / Keyboard.
- **Output**: Visual response, Status indicators.

### 2. Supabase Cloud (The Nervous System)
- **Responsibility**: Real-time event broadcasting.
- **Table Structure**:
    - `commands`: `{ id, input_text, ai_response, status (pending, processing, done, error), timestamp }`.

### 3. Python Orchestrator (The Brain/Hands)
- **Responsibility**: Listening to Supabase -> Groq Query -> OS Execution -> Supabase UPDATE.
- **Flow**:
    1. Listen to `commands` INSERT.
    2. Extract intent using Groq.
    3. Execute action.
    4. Update `ai_response` and `status` to `done`.

## Data Flow (Build Order)
1. **Connection**: Establish Supabase <-> Python Realtime link.
2. **Inference**: Wire Python script to Groq API with system prompt for JSON output.
3. **Action**: Implement `execute_command(json_blob)` in Python.
4. **UI**: Build Flutter UI to push to `commands` and watch for updates.

## Build Order Implications
- Python script MUST be working before Flutter work starts to verify the "sink" is active.
- Supabase table RLS (Row Level Security) must be configured correctly even for MVP.
