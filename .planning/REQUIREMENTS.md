# Requirements: JARVIS MVP

## Functional Requirements (FR)

### 1. Voice-to-Command Pipeline
- **FR1.1**: The system MUST capture user voice input via the mobile/desktop app.
- **FR1.2**: The system MUST convert speech to text (STT) with high accuracy and low latency.
- **FR1.3**: The system MUST transmit the text to a centralized command table in Supabase.

### 2. Intent Extraction (Brain)
- **FR2.1**: The system MUST use Groq API (Llama 3) to parse text into structured JSON.
- **FR2.2**: The JSON output MUST include `action` (e.g., `open_web`, `run_terminal`, `launch_app`) and `params`.
- **FR2.3**: The system MUST maintain a short-term conversational context (last 5 exchanges).

### 3. Action Execution (Hands)
- **FR3.1**: The system MUST be able to open URLs in the default system browser.
- **FR3.2**: The system MUST be able to execute whitelisted terminal commands.
- **FR3.3**: The system MUST be able to launch local applications by name or path.
- **FR3.4**: The system MUST report the outcome (success/error) back to Supabase.

### 4. Real-time Status & Feedback
- **FR4.1**: The Flutter UI MUST show real-time "thinking" and "processing" states.
- **FR4.2**: The system MUST stream the text response from the AI to the UI.
- **FR4.3**: The system MUST show a history of previous commands and results.

## Non-Functional Requirements (NFR)

### 1. Performance (The Core Value)
- **NFR1.1 (Latency)**: Time from Speech End to Action Start SHOULD be under 1.5 seconds.
- **NFR1.2 (Throughput)**: AI text streaming SHOULD exceed 100 tokens per second.

### 2. Security
- **NFR2.1 (API Keys)**: All API keys (Groq, Supabase) MUST be stored in environment variables, never hardcoded.
- **NFR2.2 (Execution Safety)**: Destructive commands (e.g., `rm -rf`, `format`) MUST be blocked or require explicit confirmation.

### 3. User Experience (UX)
- **NFR3.1 (Simplicity)**: The UI SHOULD have a "One-Button" Speak interface.
- **NFR3.2 (Visuals)**: The UI MUST feel "modern and alive" with micro-animations.

## Validation Criteria
- [ ] User says "Open Youtube", browser opens within 1.5s.
- [ ] User says "What is my IP?", terminal runs and AI prints the IP address.
- [ ] AI continues to respond correctly after 3 back-and-forth exchanges.
