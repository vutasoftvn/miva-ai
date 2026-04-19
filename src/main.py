import asyncio
import signal
import socket
import sys
from database import DatabaseManager
from executor import ActionExecutor
from sqlite_db import SQLiteManager

class MivaCore:
    def __init__(self):
        self.db = DatabaseManager()
        self.local_db = SQLiteManager()
        self.executor = ActionExecutor()
        self.client_id = socket.gethostname()
        self.is_running = True
        self.current_model = "claude" # Mặc định

    async def initialize_ollama(self):
        """
        Khởi động và chọn model Ollama.
        """
        models = self.executor.get_ollama_models()
        if not models:
            print("[MIVA] Cảnh báo: Không tìm thấy model Ollama nào. Đang dùng mặc định 'claude'.")
            return

        print("\n--- Ollama Model Selection ---")
        for i, m in enumerate(models):
            print(f"{i+1}. {m}")
        
        # Trong thực tế, nếu chạy headless thì gán mặc định. Nếu interact thì cho chọn.
        # Ở đây ta mặc định chọn cái đầu tiên nếu không có 'claude'
        if "claude" in models:
            self.current_model = "claude"
        else:
            self.current_model = models[0]
        
        print(f"[MIVA] Đã chọn model: {self.current_model}")

    async def sync_local_to_remote(self):
        """
        Đồng bộ định kỳ trạng thái SQLite local lên Supabase.
        """
        while self.is_running:
            stage = self.local_db.get_current_running_stage()
            if stage:
                await self.db.sync_flow_state(
                    stage['sync_key'], 
                    stage['status'], 
                    {"stage_name": stage['stage_name']}
                )
            await asyncio.sleep(5)

    def handle_new_command(self, payload):
        """
        Wrapper đồng bộ để nhận dữ liệu từ Supabase Realtime.
        """
        print(f"[DEBUG] Nhận được payload: {payload}")
        # Chuyển xử lý sang luồng async của asyncio
        asyncio.run_coroutine_threadsafe(self.process_command(payload), asyncio.get_event_loop())

    async def process_command(self, payload):
        """
        Lõi điều phối: Bình thường là trợ lý chat, chỉ mở terminal khi lập trình.
        """
        record = payload.get("new", {})
        input_text = record.get("input_text", "").strip()
        status = record.get("status")

        if status != "pending":
            return

        print(f"\n[MIVA] Input: {input_text}")
        
        current_stage = self.local_db.get_current_running_stage()
        
        # 1. Lệnh điều khiển flow cứng (Dành cho Mobile/Remote)
        if input_text.lower() in ["approve", "next", "duyệt", "ok"]:
            await self.advance_stage()
            await self.db.update_command_status(record.get("id"), "done")
            return
        elif input_text.lower() in ["stop", "dừng", "cancel"]:
            self.stop_execution()
            await self.db.update_command_status(record.get("id"), "done")
            return

        # 2. Xử lý ý định (Intent Recognition)
        from brain import MivaBrain
        if not hasattr(self, 'brain_ai'):
            self.brain_ai = MivaBrain()

        # Nếu đang ở Stage 2-7 (Coding), gõ thẳng vào Terminal của Claude
        if current_stage and current_stage['id'] > 1:
            if self.executor.current_process and self.executor.current_process.poll() is None:
                self.executor.send_to_terminal(input_text)
                await self.db.update_command_status(record.get("id"), "done")
                return

        # Nếu ở ngoài hoặc Stage 1: Dùng Brain AI để xử lý đa năng
        res = await self.brain_ai.ask(input_text)
        reply = res.get("reply", "")
        action = res.get("action", {})
        action_type = action.get("type", "none")
        params = action.get("params", {})

        # THỰC THI HÀNH ĐỘNG
        if action_type == "start_coding":
            # Kích hoạt quy trình 7 bước
            desc = params.get("project_description", input_text)
            self.local_db.update_stage_status(1, "running")
            print(f"[MIVA] Kích hoạt quy trình lập trình: {desc}")
        elif action_type == "open_web":
            self.executor.open_web(params.get("url"))
        elif action_type == "launch_app":
            self.executor.launch_app(params.get("app_name"))
        elif action_type == "run_terminal":
            self.executor.run_terminal(params.get("command"), params.get("args"))

        # Luôn trả về phản hồi hội thoại
        await self.db.update_command_status(record.get("id"), "done", ai_response=reply)
        print(f"[MIVA Reply]: {reply}")

    async def start_coding_session(self, input_text):
        """Khởi động Giai đoạn 2 (hoặc giai đoạn hiện tại > 1)."""
        current = self.local_db.get_current_running_stage()
        stage_id = current['id'] if current else 2
        
        print(f"[MIVA] Bắt đầu phiên Coding (Stage {stage_id})")
        
        if not current:
            self.local_db.update_stage_status(stage_id, "running")
            current = self.local_db.get_stage(stage_id)

        if self.executor.launch_claude_cli(self.current_model):
            # Gửi prompt của giai đoạn đó vào terminal
            cmd = current['claude_command'] or (current['prompt_template'] or "").replace("{user_input}", input_text)
            self.executor.send_to_terminal(cmd)
            asyncio.create_task(self.monitor_terminal())

    async def advance_stage(self):
        """Chuyển sang stage tiếp theo."""
        current = self.local_db.get_current_running_stage()
        if not current:
            # Nếu chưa bắt đầu, nhấn Duyệt sẽ khởi động Stage 1
            self.local_db.update_stage_status(1, "running")
            return
        
        next_id = current['id'] + 1
        if next_id > 7:
            print("[MIVA] Dự án đã hoàn thành.")
            return

        print(f"[MIVA] Chuyển từ Stage {current['id']} sang Stage {next_id}")
        self.local_db.update_stage_status(current['id'], "completed")
        self.local_db.update_stage_status(next_id, "running")
        
        # Nếu chuyển từ Brainstorming (1) sang Coding (2): Khởi động session terminal
        if next_id == 2:
            await self.start_coding_session("")
        else:
            # Các stage sau đó chỉ cần gõ lệnh mới vào session đang mở
            next_stage = self.local_db.get_stage(next_id)
            if self.executor.current_process:
                self.executor.send_to_terminal(next_stage['claude_command'])

    def stop_execution(self):
        if self.executor.current_session:
            self.executor.current_process.terminate()
            print("[MIVA] Đã dừng session terminal.")

    async def monitor_terminal(self):
        """Liên tục đọc log terminal (Chỉ chạy ở Stage 2-7)."""
        while self.executor.current_process and self.executor.current_process.poll() is None:
            current_stage = self.local_db.get_current_running_stage()
            if not current_stage or current_stage['id'] == 1:
                break # Không log terminal khi đang brainstorming
            
            output = self.executor.read_terminal_output(timeout=0.5)
            if output:
                clean_output = output.strip()
                if clean_output:
                    self.local_db.add_terminal_log(current_stage['id'], clean_output)
                    await self.db.push_terminal_log(current_stage['sync_key'], clean_output)
            await asyncio.sleep(0.5)

    async def run(self):
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print(f"  MIVA HYBRID ORCHESTRATOR - {self.client_id}  ")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        
        await self.initialize_ollama()
        
        try:
            await self.db.connect()
            await self.db.listen_to_commands(self.handle_new_command)
            
            # Start background sync
            asyncio.create_task(self.sync_local_to_remote())
            
            while self.is_running:
                await asyncio.sleep(1)
        except Exception as e:
            print(f"[CRITICAL ERROR] {str(e)}")
        finally:
            self.stop_execution()

    def stop(self):
        self.is_running = False

async def main():
    miva = MivaCore()
    loop = asyncio.get_running_loop()
    for sig in (signal.SIGINT, signal.SIGTERM):
        loop.add_signal_handler(sig, miva.stop)
    await miva.run()

if __name__ == "__main__":
    asyncio.run(main())
