# Features Research: JARVIS MVP

## Table Stakes (Must Have)
1. **Near-Zero Latency STT**: Voice commands must be captured and processed without a 2-second lag.
2. **Streaming AI Response**: User must see the AI "typing" or responding immediately to reduce perceived wait time.
3. **Basic OS Control**:
    - Open web URLs in default browser.
    - Run safe terminal commands (e.g., `ls`, `whoami`, `ping`).
    - Open local applications (Calculator, Terminal, Browser).
4. **Command History**: A log of previous commands and AI responses.

## Differentiators (JARVIS Feel)
1. **Context-Aware Actions**: AI understands "check IP" means running `curl ifconfig.me` or `ipconfig`.
2. **Graceful Error Handling**: If a command fails, AI explains why and suggests a fix.
3. **Background Persistence**: Python script stays active in the system tray, listening for events.

## Anti-Features (Wait for V2)
- **Multi-user Login**: Focus on single-user local control for MVP.
- **Complex RAG (Vector Search)**: Stick to direct intent extraction for now.
- **GUI Automation (PyAutoGUI)**: Too fragile for MVP; stay with OS calls and Web opening.

## Dependencies
- **Groq API Status**: Heavily dependent on Groq uptime for response generation.
- **Microphone Permissions**: Critical for Flutter STT to work.
- **Local Python Environment**: Requires correctly installed dependencies on the host machine.
