from supabase import create_client, Client
from dotenv import load_dotenv
import os

load_dotenv()

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")
SUPABASE_SERVICE_ROLE_KEY = os.getenv("SUPABASE_SERVICE_ROLE_KEY")
print("SUPABASE_KEY",SUPABASE_KEY)
print("SUPABASE_SERVICE_ROLE_KEY",SUPABASE_SERVICE_ROLE_KEY)
print("SUPABASE_URL",SUPABASE_URL)

supabase: Client = None

def initialize_supabase():
    global supabase
    if supabase is None:
        if not SUPABASE_URL or not SUPABASE_KEY or not SUPABASE_SERVICE_ROLE_KEY:
            print("ERROR: Supabase environment variables not set.")
            print("Please ensure SUPABASE_URL, SUPABASE_KEY, and SUPABASE_SERVICE_ROLE_KEY are set in your .env file.")
            exit(1)
        try:
            supabase = create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)
            print("Supabase client initialized successfully.")
        except Exception as e:
            print(f"Error initializing Supabase client: {e}")
            exit(1)

def get_supabase_client() -> Client:
    if supabase is None:
        initialize_supabase()
    return supabase

# Initialize Supabase on import
initialize_supabase()
