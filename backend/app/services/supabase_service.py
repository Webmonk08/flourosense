from app.db.supabase import get_supabase_client
from app.models.models import User, ReportCreate, ReportInDB
from datetime import datetime

class SupabaseService:
    def __init__(self):
        self.client = get_supabase_client()

    async def create_user(self, email: str, hashed_password: str):
        data = {"email": email, "hashed_password": hashed_password}
        response = self.client.table("users").insert(data).execute()
        # Supabase Python client returns a response object with 'data' and 'error'
        if response.data:
            return response.data[0]
        return None

    async def get_user_by_email(self, email: str):
        response = self.client.table("users").select("*").eq("email", email).execute()
        if response.data:
            return response.data[0]
        return None

    async def update_user(self, old_email: str, update_data: dict):
        response = self.client.table("users").update(update_data).eq("email", old_email).execute()
        if response.data:
            return response.data[0]
        return None

    async def create_report(self, report_data: ReportCreate):
        report_dict = report_data.model_dump(by_alias=True, exclude_unset=True)
        # Convert datetime to ISO string for Supabase
        if 'timestamp' in report_dict and isinstance(report_dict['timestamp'], datetime):
            report_dict['timestamp'] = report_dict['timestamp'].isoformat()
        
        response = self.client.table("reports").insert(report_dict).execute()
        if response.data:
            return ReportInDB(**response.data[0])
        return None
    
    async def get_user_reports(self, user_id: str):
        response = self.client.table("reports").select("*").eq("user_id", user_id).order("timestamp", desc=True).execute()
        if response.data:
            return [ReportInDB(**doc) for doc in response.data]
        return []

    async def upload_image(self, user_id: str, filename: str, contents: bytes, content_type: str):
        file_path = f"{user_id}/{filename}"
        # Using the 'user_images' bucket, allowing upsert to prevent 409 Duplicate error
        response = self.client.storage.from_("user_images").upload(
            path=file_path,
            file=contents,
            file_options={
                "content-type": content_type,
                "upsert": "true"
            }
        )
        # Get public URL
        url_response = self.client.storage.from_("user_images").get_public_url(file_path)
        return url_response
