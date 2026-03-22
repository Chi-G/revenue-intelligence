import pandas as pd
from sqlalchemy import create_engine, text
import os
from dotenv import load_dotenv

load_dotenv()

# Database Connection
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT", "5432")
DB_NAME = os.getenv("DB_NAME")
DB_USER = os.getenv("DB_USER")
DB_PASS = os.getenv("DB_PASS")

CONN_STR = f"postgresql://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
engine = create_engine(CONN_STR)

base_dir = "/home/chiji_linux/uv_python/Revenue_Intelligence_System/seed_data"
schema_dir = "/home/chiji_linux/uv_python/Revenue_Intelligence_System/schema"

def run_sql_file(filename):
    print(f"Executing {filename}...")
    with open(f"{schema_dir}/{filename}", 'r') as f:
        query = f.read()
        with engine.connect() as conn:
            conn.execute(text(query))
            conn.commit()

def ingest_csv(filename, table_name):
    print(f"Ingesting {filename} into {table_name}...")
    df = pd.read_csv(f"{base_dir}/{filename}")
    df.to_sql(table_name, engine, if_exists='append', index=False)

if __name__ == "__main__":
    try:
        # 1. Setup Schema
        run_sql_file("01_tables.sql")
        
        # 2. Ingest Data (Order matters for Foreign Keys)
        ingest_csv("crm_users.csv", "users")
        ingest_csv("crm_accounts.csv", "accounts")
        ingest_csv("crm_contacts.csv", "contacts")
        ingest_csv("crm_products.csv", "products")
        ingest_csv("crm_opportunities.csv", "opportunities")
        ingest_csv("crm_line_items.csv", "opportunity_line_items")
        ingest_csv("activity_logs.csv", "deal_activities")
        ingest_csv("usage_subscriptions.csv", "subscriptions")
        
        # 3. Setup Analytical Views
        run_sql_file("02_views.sql")
        
        print("Data ingestion and schema setup complete!")
    except Exception as e:
        print(f"Error during ingestion: {e}")
        print("\nTIP: Make sure your PostgreSQL database is running and credentials in .env are correct.")
