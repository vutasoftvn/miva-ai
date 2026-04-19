import os
import json
from groq import Groq
from dotenv import load_dotenv
from collections import deque

load_dotenv()

SYSTEM_PROMPT = """
Bạn là MIVA, một trợ lý ảo AI tích hợp sâu vào hệ điều hành.
Nhiệm vụ của bạn là hiểu ý định của người dùng và chuyển đổi thành hành động hệ thống.

CÁC KỸ NĂNG CỦA BẠN (HANDS):
1. open_web(url): Mở trang web.
2. run_terminal(command, args): Chạy lệnh terminal đơn lẻ (ls, pwd...).
3. launch_app(app_name): Mở ứng dụng.
4. start_coding(project_description): Kích hoạt quy trình 7 bước lập trình chuyên sâu.

QUY TẮC PHẢN HỒI:
- Luôn trả về một đối tượng JSON duy nhất.
- Trường 'reply': Phản hồi thông minh cho người dùng.
- Trường 'action': Đối tượng chứa 'type' và 'params'.
  - 'type': 'open_web', 'run_terminal', 'launch_app', 'start_coding' hoặc 'none'.
  - 'params': Các tham số tương ứng (ví dụ: project_description cho start_coding).

VÍ DỤ:
User: "Viết giùm tôi một ứng dụng quản lý task bằng Python"
JSON: { "reply": "Rất sẵn lòng. Tôi sẽ khởi động quy trình 7 bước để thiết kế và lập trình ứng dụng này cho bạn.", "action": { "type": "start_coding", "params": { "project_description": "Task management app in Python" } } }
"""

class MivaBrain:
    def __init__(self, model="llama3-8b-8192", history_size=10):
        self.client = Groq(api_key=os.getenv("GROQ_API_KEY"))
        self.model = model
        self.history = deque(maxlen=history_size)

    async def ask(self, user_input: str) -> dict:
        """
        Gửi input tới Groq và nhận về cấu trúc Intent JSON.
        """
        # Thêm input vào bộ nhớ
        messages = [{"role": "system", "content": SYSTEM_PROMPT}]
        
        # Thêm history
        for msg in self.history:
            messages.append(msg)
            
        # Thêm input hiện tại
        messages.append({"role": "user", "content": user_input})

        try:
            chat_completion = self.client.chat.completions.create(
                messages=messages,
                model=self.model,
                response_format={"type": "json_object"},
                temperature=0.2 # Thấp để đảm bảo tính ổn định của JSON
            )
            
            response_text = chat_completion.choices[0].message.content
            result = json.loads(response_text)
            
            # Lưu vào bộ nhớ (cả user và assistant)
            self.history.append({"role": "user", "content": user_input})
            self.history.append({"role": "assistant", "content": result.get("reply", "")})
            
            return result
        except Exception as e:
            print(f"[BRAIN ERROR] {str(e)}")
            return {
                "reply": "Xin lỗi, tôi gặp trục trặc khi kết nối với bộ não AI.",
                "action": { "type": "none", "params": {} }
            }

if __name__ == "__main__":
    # Test nhanh
    import asyncio
    brain = MivaBrain()
    async def test():
        res = await brain.ask("Chào Miva, hãy mở youtube và xem thời tiết ở Hà Nội bằng terminal")
        print(json.dumps(res, indent=2, ensure_ascii=False))
    
    asyncio.run(test())
