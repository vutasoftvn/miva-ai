import os
import asyncio
from supabase import acreate_client, AsyncClient
from dotenv import load_dotenv

load_dotenv()

class DatabaseManager:
    def __init__(self):
        self.url = os.getenv("SUPABASE_URL")
        self.key = os.getenv("SUPABASE_KEY")
        self.client: AsyncClient = None

    async def connect(self):
        if not self.url or not self.key:
            raise ValueError("SUPABASE_URL and SUPABASE_KEY must be set in .env")
        
        self.client = await acreate_client(self.url, self.key)
        print("Successfully connected to Supabase Realtime.")

    async def listen_to_commands(self, callback):
        """
        Subscribes to INSERT events on the 'commands' table where status is 'pending'.
        """
        if not self.client:
            await self.connect()

        print("Listening for new commands...")
        channel = self.client.channel("commands_channel")
        
        # Subscribe to INSERT events
        channel.on_postgres_changes(
            event="INSERT",
            schema="public",
            table="commands",
            callback=callback
        )
        await channel.subscribe()

    async def update_command_status(self, command_id: str, status: str, ai_response: str = None, target_device_id: str = None):
        """
        Updates the status, ai_response and target_device_id of a command.
        """
        data = {"status": status}
        if ai_response:
            data["ai_response"] = ai_response
        if target_device_id:
            data["target_device_id"] = target_device_id
            
        await self.client.table("commands").update(data).eq("id", command_id).execute()

    async def sync_flow_state(self, sync_key: str, status: str, details: dict = None):
        """
        Đồng bộ trạng thái Stage lên Supabase để Mobile có thể theo dõi.
        """
        data = {"status": status}
        if details:
            data.update(details)
        
        # Upsert dựa trên sync_key
        await self.client.table("project_flow").upsert({
            "sync_key": sync_key,
            **data
        }, on_conflict="sync_key").execute()

    async def push_terminal_log(self, sync_key: str, log_content: str):
        """
        Đẩy log terminal lên Supabase.
        """
        await self.client.table("terminal_logs").insert({
            "sync_key": sync_key,
            "log_content": log_content
        }).execute()

async def test_connection():
    db = DatabaseManager()
    await db.connect()

if __name__ == "__main__":
    asyncio.run(test_connection())
