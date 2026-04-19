import subprocess
import webbrowser
import platform
import os
import pexpect
import sys

# Whitelist các lệnh Terminal an toàn (Mở rộng cho Ollama/Claude)
ALLOWED_TERMINAL_COMMANDS = {
    "ls": ["ls"],
    "pwd": ["pwd"],
    "whoami": ["whoami"],
    "ping": ["ping", "-c", "4"],
    "date": ["date"],
    "uptime": ["uptime"],
    "ollama": ["ollama"]
}

class ActionExecutor:
    def __init__(self):
        self.os_type = platform.system()
        self.current_session = None

    def get_ollama_models(self) -> list:
        """
        Lấy danh sách các model đang có trong Ollama.
        """
        try:
            result = subprocess.run(["ollama", "list"], capture_output=True, text=True, timeout=5)
            if result.returncode == 0:
                lines = result.stdout.strip().split("\n")[1:] # Bỏ header
                models = [line.split()[0] for line in lines if line]
                return models
            return []
        except Exception:
            return []

    def select_model(self):
        models = self.get_ollama_models()
        if not models:
            self.current_model = "claude"
            return

        # Tự động chọn 'claude' hoặc model đầu tiên
        for m in models:
            if "claude" in m.lower():
                self.current_model = m
                return
        self.current_model = models[0]

    def launch_claude_cli(self, model_name: str = "claude"):
        """
        Khởi động Claude CLI (qua Ollama hoặc lệnh riêng) dùng pexpect.
        """
        if not model_name:
            self.select_model()
            model_name = self.current_model
            
        # Giả định lệnh là 'ollama run <model_name>' dựa trên yêu cầu
        cmd = f"ollama run {model_name}"
        print(f"[EXECUTOR] Đang khởi động: {cmd}")
        
        try:
            self.current_session = pexpect.spawn(cmd, encoding='utf-8', timeout=None)
            self.current_session.logfile = sys.stdout # Log trực tiếp ra console để debug
            return True
        except Exception as e:
            print(f"[ERROR] Không thể khởi động terminal: {e}")
            return False

    def send_to_terminal(self, text: str):
        """
        Gửi lệnh vào session terminal đang mở.
        """
        if self.current_session and self.current_session.isalive():
            self.current_session.sendline(text)
            return True
        return False

    def read_terminal_output(self, timeout=1):
        """
        Đọc output từ terminal (non-blocking).
        """
        if not self.current_session:
            return ""
        
        try:
            # Đọc những gì đang có trong buffer
            self.current_session.expect(pexpect.TIMEOUT, timeout=timeout)
            return self.current_session.before
        except pexpect.EOF:
            return "[TERMINAL CLOSED]"
        except Exception:
            return ""

    def run_terminal(self, command_key: str, args: list = None) -> str:
        # (Giữ nguyên logic cũ cho các lệnh đơn lẻ)
        if command_key not in ALLOWED_TERMINAL_COMMANDS:
            return f"Error: Command '{command_key}' is not allowed."
        
        full_cmd = list(ALLOWED_TERMINAL_COMMANDS[command_key])
        if args:
            sanitized_args = [a for a in args if a.replace('-', '').isalnum()]
            full_cmd.extend(sanitized_args)

        try:
            result = subprocess.run(full_cmd, capture_output=True, text=True, timeout=10)
            return result.stdout if result.returncode == 0 else f"Error: {result.stderr}"
        except Exception as e:
            return f"Exception: {str(e)}"

    def open_web(self, url: str) -> str:
        try:
            if not url.startswith(("http://", "https://")):
                url = "https://" + url
            webbrowser.open(url)
            return f"Success: Opened {url}"
        except Exception as e:
            return f"Error opening web: {str(e)}"

    def launch_app(self, app_name: str) -> str:
        try:
            if self.os_type == "Darwin":
                subprocess.run(["open", "-a", app_name])
            elif self.os_type == "Windows":
                os.startfile(app_name)
            else:
                return f"Unsupported OS"
            return f"Success: Launched {app_name}"
        except Exception as e:
            return f"Error launching app: {str(e)}"

    def execute(self, action_json: dict) -> str:
        action = action_json.get("action")
        params = action_json.get("params", {})
        if action == "run_terminal":
            return self.run_terminal(params.get("command"), params.get("args"))
        elif action == "open_web":
            return self.open_web(params.get("url"))
        elif action == "launch_app":
            return self.launch_app(params.get("app_name"))
        else:
            return f"Error: Unknown action '{action}'"

if __name__ == "__main__":
    # Test
    executor = ActionExecutor()
    print("Testing terminal (ls):", executor.run_terminal("ls"))
    print("Testing web opening:", executor.open_web("google.com"))
    print("Testing unsafe command (rm):", executor.run_terminal("rm"))
