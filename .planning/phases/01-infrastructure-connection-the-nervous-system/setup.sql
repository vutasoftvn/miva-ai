-- setup.sql - Khởi tạo hạ tầng dự án JARVIS

-- 1. Tạo bảng commands
CREATE TABLE IF NOT EXISTS public.commands (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    input_text text,
    ai_response text,
    action_json jsonb,
    status text DEFAULT 'pending',
    target_device_id text,
    created_at timestamptz DEFAULT now()
);

-- 2. Bật Realtime cho bảng commands
-- Lưu ý: Nếu lệnh này lỗi, hãy đảm bảo publication 'supabase_realtime' đã tồn tại
-- (Supabase thường tạo sẵn cho bạn).
ALTER PUBLICATION supabase_realtime ADD TABLE public.commands;

-- 3. Cấu hình RLS (MVP - Cho phép truy cập công khai để tiện phát triển)
-- Trong thực tế bạn nên cấu hình chặt chẽ hơn.
ALTER TABLE public.commands ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow public access" ON public.commands FOR ALL USING (true) WITH CHECK (true);

-- 4. Bật Full Replication để nhận dữ liệu cũ/mới nếu cần
ALTER TABLE public.commands REPLICA IDENTITY FULL;
