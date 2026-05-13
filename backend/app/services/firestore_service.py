from firebase_admin import firestore
from app.db.firebase import get_firestore_db
from app.models.models import User, ReportCreate, ReportInDB
from datetime import datetime

class FirestoreService:
    def __init__(self):
        self.db = get_firestore_db()
        self.users_collection = self.db.collection('users')
        self.reports_collection = self.db.collection('reports')

    async def create_user(self, email: str, hashed_password: str):
        user_ref = self.users_collection.document(email)
        user_data = {"email": email, "hashed_password": hashed_password}
        await user_ref.set(user_data)
        return user_data

    async def get_user_by_email(self, email: str):
        user_ref = self.users_collection.document(email)
        user_doc = await user_ref.get()
        if user_doc.exists:
            return user_doc.to_dict()
        return None

    async def create_report(self, report_data: ReportCreate):
        report_dict = report_data.model_dump(by_alias=True, exclude_unset=True)
        report_ref = await self.reports_collection.add(report_dict)
        report_id = report_ref.id
        return ReportInDB(id=report_id, **report_dict)
    
    async def get_user_reports(self, user_id: str):
        reports_query = self.reports_collection.where('user_id', '==', user_id).order_by('timestamp', direction=firestore.Query.DESCENDING)
        reports_docs = await reports_query.get()
        return [ReportInDB(id=doc.id, **doc.to_dict()) for doc in reports_docs]
