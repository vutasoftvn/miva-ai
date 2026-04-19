# Research: Phase 1 - Infrastructure & Connection

## Tech Research Findings

### 1. Supabase Realtime with Python (`supabase-py`)
- **Asynchronous Client**: Realtime requires the `AsyncClient` and `acreate_client` method because it runs an event loop for WebSockets.
- **Table Setup**: Must run `ALTER PUBLICATION supabase_realtime ADD TABLE commands;` to enable broadcasts.
- **Replica Identity**: To get the status transition history (if needed), use `ALTER TABLE commands REPLICA IDENTITY FULL;`.
- **Event Filtering**: Can filter specifically for `INSERT` on the `commands` table where `status = 'pending'`.

### 2. Safe Command Execution
- **Avoid `shell=True`**: This is the primary vector for command injection.
- **Argument Lists**: Always use `subprocess.run(["ls", "-la"])` format.
- **Whitelisting Strategy**: Implement a dictionary mapping of command keys to full executable paths.
- **Validation**: Use `arg.isalnum()` or strict regex to validate any arguments passed to shell commands.

### 3. Cross-Platform App Launching
- **macOS**: `subprocess.run(["open", "-a", app_name])`.
- **Windows**: `os.startfile(app_name)` or `subprocess.run(["start", app_name], shell=True)` (but `os.startfile` is safer).
- **Universal**: Use `platform.system()` to decide at runtime.

### 4. Environment Management
- **python-dotenv**: Standard approach. Requires `.env` file and `load_dotenv()` call.
- **Required Keys**: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `GROQ_API_KEY`.

## Recommended Patterns
- **Directory Structure**:
    - `src/`
        - `main.py`: Entry point, loop setup.
        - `database.py`: Supabase client wrapper.
        - `executor.py`: Command execution logic.
        - `config.py`: Environment variable validation.
- **Graceful Shutdown**: Implement signal handling for `SIGINT` to close the Supabase client cleanly.
