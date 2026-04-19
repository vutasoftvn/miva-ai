import sqlite3
import os

DB_PATH = os.path.join(os.path.dirname(__file__), "..", "local.db")
INIT_SQL_PATH = os.path.join(os.path.dirname(__file__), "..", "database", "init_db.sql")

class SQLiteManager:
    def __init__(self, db_path=DB_PATH):
        self.db_path = db_path
        self._init_db()

    def _init_db(self):
        """Initializes the database if it doesn't exist."""
        conn = sqlite3.connect(self.db_path)
        try:
            with open(INIT_SQL_PATH, 'r') as f:
                sql_script = f.read()
            conn.executescript(sql_script)
            conn.commit()
        except Exception as e:
            print(f"Error initializing SQLite: {e}")
        finally:
            conn.close()

    def get_stage(self, stage_id):
        """Retrieves a specific stage by ID."""
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM project_flow WHERE id = ?", (stage_id,))
        stage = cursor.fetchone()
        conn.close()
        return dict(stage) if stage else None

    def update_stage_status(self, stage_id, status):
        """Updates the status of a stage."""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        cursor.execute("UPDATE project_flow SET status = ? WHERE id = ?", (status, stage_id))
        conn.commit()
        conn.close()

    def get_current_running_stage(self):
        """Retrieves the stage that is currently in 'running' or 'waiting' status."""
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM project_flow WHERE status IN ('running', 'waiting') LIMIT 1")
        stage = cursor.fetchone()
        conn.close()
        return dict(stage) if stage else None

    def add_terminal_log(self, stage_id, log_content):
        """Appends terminal output to the logs."""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        cursor.execute("INSERT INTO terminal_logs (stage_id, log_content) VALUES (?, ?)", (stage_id, log_content))
        conn.commit()
        conn.close()

if __name__ == "__main__":
    manager = SQLiteManager()
    print("Database initialized successfully at:", DB_PATH)
    stage1 = manager.get_stage(1)
    print("Stage 1 name:", stage1['stage_name'])
