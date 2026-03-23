import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

def test_connection():
    load_dotenv()
    
    # Construct connection string from .env
    user = os.getenv("DB_USER")
    password = os.getenv("DB_PASS")
    host = os.getenv("DB_HOST")
    port = os.getenv("DB_PORT", "5432")
    dbname = os.getenv("DB_NAME")
    
    conn_str = f"postgresql://{user}:{password}@{host}:{port}/{dbname}"
    
    try:
        engine = create_engine(conn_str)
        with engine.connect() as conn:
            result = conn.execute(text("SELECT count(*) FROM opportunities"))
            count = result.scalar()
            print(f"✅ Connection Successful!")
            print(f"📊 Found {count} opportunities in the database.")
    except Exception as e:
        print(f"❌ Connection Failed")
        print(f"Error: {e}")

if __name__ == "__main__":
    test_connection()
