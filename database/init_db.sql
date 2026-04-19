-- Initialize the local SQLite Source of Truth
-- 7 Superpowers Stages

CREATE TABLE IF NOT EXISTS project_flow (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    stage_name TEXT NOT NULL,
    claude_command TEXT,
    prompt_template TEXT,
    sync_key TEXT UNIQUE,
    is_gate_required INTEGER DEFAULT 0,
    status TEXT DEFAULT 'pending' -- 'pending', 'running', 'completed', 'waiting'
);

CREATE TABLE IF NOT EXISTS terminal_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    stage_id INTEGER,
    log_content TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (stage_id) REFERENCES project_flow(id)
);

-- Pre-populate the 7 Superpowers stages
INSERT OR IGNORE INTO project_flow (id, stage_name, claude_command, prompt_template, sync_key, is_gate_required)
VALUES 
(1, 'Brainstorming (Socratic Design)', '/brainstorming', 'Xây dựng kế hoạch cho {user_input}. Hãy dùng Socratic để làm rõ logic.', 'stage_1_brainstorm', 1),
(2, 'Git Worktrees (Isolated Environment)', '/worktree', 'Tạo git worktree cho giai đoạn phát triển.', 'stage_2_worktree', 0),
(3, 'Writing Plans (Bite-sized Tasks)', '/plan', 'Viết kế hoạch chi tiết cho các task nhỏ.', 'stage_3_plan', 1),
(4, 'Execution (Subagent-Driven)', '/execute', 'Thực thi các task đã lập trong kế hoạch.', 'stage_4_execute', 0),
(5, 'Test-Driven Development (TDD)', '/tdd', 'Viết test trước khi code (Red-Green-Refactor).', 'stage_5_tdd', 0),
(6, 'Code Review (Quality Control)', '/review', 'Kiểm tra chất lượng mã nguồn và đối chiếu với kế hoạch.', 'stage_6_review', 1),
(7, 'Finishing the Branch (Merge & Cleanup)', '/finish', 'Hoàn thiện, merge và dọn dẹp môi trường.', 'stage_7_finish', 1);
