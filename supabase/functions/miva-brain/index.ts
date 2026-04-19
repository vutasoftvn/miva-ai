import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const GROQ_API_KEY = Deno.env.get('GROQ_API_KEY')

const SYSTEM_PROMPT = `
Bạn là MIVA, một trợ lý ảo AI tích hợp sâu vào hệ điều hành.
Nhiệm vụ của bạn là hiểu ý định của người dùng và chuyển đổi thành hành động hệ thống.

CÁC KỸ NĂNG CỦA BẠN (HANDS):
1. open_web(url): Mở trang web.
2. run_terminal(command, args): Chạy lệnh terminal (ls, pwd, whoami, ping, uptime).
3. launch_app(app_name): Mở ứng dụng (ví dụ: Visual Studio Code, Chrome, Spotify).

QUY TẮC PHẢN HỒI:
- Luôn trả về một đối tượng JSON duy nhất.
- Trường 'reply': Chứa văn bản phản hồi ngắn gọn, thông minh cho người dùng.
- Trường 'target_device_id': Nếu người dùng chỉ định thiết bị, hãy điền hostname. Nếu không, để null.
- Trường 'action': Một đối tượng chứa 'type' và 'params'. 
  - 'type': 'open_web', 'run_terminal', 'launch_app', hoặc 'none'.
  - 'params': Tham số tương ứng.
`

serve(async (req) => {
  const { input_text } = await req.json()

  // 1. Call Groq API
  const response = await fetch("https://api.groq.com/openai/v1/chat/completions", {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${GROQ_API_KEY}`,
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      model: "llama3-8b-8192",
      messages: [
        { role: "system", content: SYSTEM_PROMPT },
        { role: "user", content: input_text }
      ],
      response_format: { type: "json_object" }
    })
  })

  const groqData = await response.json()
  const aiResult = JSON.parse(groqData.choices[0].message.content)

  // 2. Initialize Supabase Client
  const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ""
  const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ""
  const supabase = createClient(supabaseUrl, supabaseKey)

  // 3. Insert into DB for Python Backend to pick up the action
  const { data, error } = await supabase
    .from('commands')
    .insert({
      input_text,
      ai_response: aiResult.reply,
      action_json: aiResult.action,
      target_device_id: aiResult.target_device_id,
      status: aiResult.action.type === 'none' ? 'done' : 'pending' 
    })
    .select()
    .single()

  return new Response(
    JSON.stringify({ 
        id: data.id, 
        reply: aiResult.reply, 
        action: aiResult.action,
        status: data.status
    }),
    { headers: { "Content-Type": "application/json" } }
  )
})
