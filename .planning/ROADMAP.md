# Roadmap: JARVIS MVP

## Milestone 1: Core Command Pipeline (MVP)

### Phase 1: Infrastructure & Connection (The Nervous System)
*Set up the communication layer between Python, Supabase, and basic OS calls.*
- **Outcome**: Python script listening to Supabase and opening a browser URL on command.
- **Plans**:
    - [ ] `1.1-supabase-setup`: Initialize project, create `commands` table with RLS and Realtime.
    - [ ] `1.2-python-backbone`: Create Python script using `supabase-py` to listen for new rows.
    - [ ] `1.3-basic-execution`: Implement `webbrowser` and `subprocess` wrappers in Python.

### Phase 2: AI Intelligence (The Brain)
*Integrate Groq for ultra-fast intent extraction and natural responses.*
- **Outcome**: AI converts natural language to JSON actions and provides conversational feedback.
- **Plans**:
    - [ ] `2.1-groq-integration`: Secure Groq API usage and implement basic prompt for intent.
    - [ ] `2.2-intent-engine`: Refine system prompt for strict JSON output and multi-step actions.
    - [ ] `2.3-streaming-impl`: Wire Python to stream AI text responses back to Supabase.

### Phase 3: Flutter Interface (The Senses)
*Build the mobile/desktop app to capture voice and display the assistant's state.*
- **Outcome**: A functional app that sends voice commands and displays real-time AI feedback.
- **Plans**:
    - [ ] `3.1-flutter-base`: Initialize Flutter project with Supabase client and Riverpod.
    - [ ] `3.2-speech-ui`: Implement `speech_to_text` and the "Speak" button UX.
    - [ ] `3.3-realtime-display`: Bind UI to Supabase table for streaming responses and status updates.

### Phase 4: Integration & Polish (The JARVIS Experience)
*Final wiring, security hardening, and aesthetic enhancements.*
- **Outcome**: A polished, secure, and blazing-fast personal assistant experience.
- **Plans**:
    - [ ] `4.1-e2e-integration`: End-to-end testing of voice -> intent -> shell execution.
    - [ ] `4.2-security-hardening`: Implement command whitelisting and input sanitization.
    - [ ] `4.3-ui-wow`: Add glassmorphism, animations, and premium styling to Flutter UI.

---
## Future Milestones
- **Milestone 2**: Vision (Camera integration via Groq/LAVA).
- **Milestone 3**: Personal Knowledge Base (RAG with `pgvector`).
- **Milestone 4**: Multi-agent orchestration (JARVIS calling other agents).
