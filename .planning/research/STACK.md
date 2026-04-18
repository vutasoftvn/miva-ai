# Stack Research: JARVIS MVP (2025/2026)

## Overview
The "JARVIS" assistant leverages a high-performance stack designed for near-instant latency and robust system interaction.

## Core Stack Recommendations

### 1. Frontend: Flutter
- **Role**: Cross-platform UI, voice-to-text integration, and real-time state management.
- **Key Packages**:
    - `speech_to_text`: High-quality STT for voice commands.
    - `supabase_flutter`: Direct integration with Supabase Realtime.
    - `flutter_riverpod`: For robust and reactive state management.
- **Confidence**: High (Industry standard for multi-platform AI apps).

### 2. Middleware: Supabase
- **Role**: Command pipeline, persistent storage, and Auth.
- **Key Features**:
    - **Realtime Tables**: Essential for "push" notifications from Flutter to Python.
    - **pgvector**: For future memory/RAG capabilities.
    - **Edge Functions**: For lightweight, serverless AI orchestration if needed.
- **Confidence**: High (Eliminates complex networking layers).

### 3. AI Inference: Groq
- **Role**: Ultra-fast LLM response generation.
- **Model**: `llama3-70b-8192` or `llama3-8b-8192`.
- **Latency**: Sub-100ms for first token, 200-500 tokens/sec.
- **Confidence**: High (Fastest inference engine available for Llama models).

### 4. Backend/Execution: Python (FastAPI/Scripts)
- **Role**: System-level execution and AI orchestration.
- **Key Libraries**:
    - `supabase-py`: Listening to database changes.
    - `pydantic`: For structured output validation.
    - `subprocess` / `os`: For OS-level commanding.
- **Confidence**: Extreme (Native OS access and best AI ecosystem).

## What NOT to use
- **Plain HTTP Polling**: Too slow for "JARVIS" feel; use Realtime instead.
- **Client-Side Groq Calls**: Security risk (exposed API Keys); always proxy through backend or Supabase.
- **Heavy Frameworks (Django)**: Stick to FastAPI or plain scripts for lower overhead in MVP.
