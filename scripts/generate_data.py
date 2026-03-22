import pandas as pd
from faker import Faker
import uuid
import random
from datetime import datetime, timedelta
import os

fake = Faker()
Faker.seed(42)
random.seed(42)

# Configuration
NUM_USERS = 10
NUM_ACCOUNTS = 120
NUM_CONTACTS = 250
NUM_OPPORTUNITIES = 300
NUM_PRODUCTS = 15
NUM_ACTIVITIES = 1500

base_dir = "/home/chiji_linux/uv_python/Revenue_Intelligence_System/seed_data"
os.makedirs(base_dir, exist_ok=True)

def generate_crm_data():
    # 1. Users
    users = []
    roles = ['Sales Rep', 'Sales Manager', 'RevOps', 'VP Sales']
    for _ in range(NUM_USERS):
        users.append({
            'user_id': str(uuid.uuid4()),
            'full_name': fake.name(),
            'email': fake.email(),
            'role': random.choice(roles)
        })
    df_users = pd.DataFrame(users)
    df_users.to_csv(f"{base_dir}/crm_users.csv", index=False)

    # 2. Accounts
    accounts = []
    industries = ['Software', 'Fintech', 'Healthcare', 'Manufacturing', 'Retail', 'Education']
    sizes = ['1-50', '51-200', '201-500', '501-1000', '1000+']
    for _ in range(NUM_ACCOUNTS):
        accounts.append({
            'account_id': str(uuid.uuid4()),
            'name': fake.company(),
            'industry': random.choice(industries),
            'company_size': random.choice(sizes),
            'annual_revenue': round(random.uniform(500000, 50000000), 2),
            'country': fake.country(),
            'owner_id': random.choice(users)['user_id'],
            'status': random.choice(['Active', 'Active', 'Active', 'Prospect', 'Churned'])
        })
    df_accounts = pd.DataFrame(accounts)
    df_accounts.to_csv(f"{base_dir}/crm_accounts.csv", index=False)

    # 3. Contacts
    contacts = []
    for _ in range(NUM_CONTACTS):
        contacts.append({
            'contact_id': str(uuid.uuid4()),
            'account_id': random.choice(accounts)['account_id'],
            'first_name': fake.first_name(),
            'last_name': fake.last_name(),
            'email': fake.unique.email(),
            'job_title': fake.job(),
            'is_primary': random.choice([True, False, False])
        })
    df_contacts = pd.DataFrame(contacts)
    df_contacts.to_csv(f"{base_dir}/crm_contacts.csv", index=False)

    # 4. Products
    products = []
    for i in range(NUM_PRODUCTS):
        products.append({
            'product_id': str(uuid.uuid4()),
            'name': f"Product {chr(65+i)} Premium",
            'sku': f"SKU-{1000+i}",
            'category': random.choice(['SaaS', 'Services', 'Hardware']),
            'unit_price': round(random.uniform(100, 5000), 2)
        })
    df_products = pd.DataFrame(products)
    df_products.to_csv(f"{base_dir}/crm_products.csv", index=False)

    # 5. Opportunities
    opportunities = []
    line_items = []
    stages = [1, 2, 3, 4, 5, 6] # mapped to 01_tables.sql sort_order
    sources = ['Inbound', 'Cold Outreach', 'Referral', 'Webinar', 'Partner']
    for _ in range(NUM_OPPORTUNITIES):
        is_closed = random.choice([True, False])
        stage = random.choice(stages)
        is_won = (stage == 5)
        
        close_date = fake.date_between(start_date='-1y', end_date='+6m')
        opp_id = str(uuid.uuid4())
        amount = round(random.uniform(5000, 200000), 2)
        
        opportunities.append({
            'opportunity_id': opp_id,
            'name': f"{fake.catch_phrase()} Deal",
            'account_id': random.choice(accounts)['account_id'],
            'owner_id': random.choice(users)['user_id'],
            'stage_id': stage,
            'amount': amount,
            'close_date': close_date,
            'lead_source': random.choice(sources),
            'forecast_category': 'Closed' if is_closed else random.choice(['Pipeline', 'Best Case', 'Commit']),
            'is_closed': is_closed or (stage in [5, 6]),
            'is_won': is_won
        })

        # Generate 1-3 line items per opportunity
        num_items = random.randint(1, 3)
        for _ in range(num_items):
            prod = random.choice(products)
            qty = random.randint(1, 5)
            line_items.append({
                'line_item_id': str(uuid.uuid4()),
                'opportunity_id': opp_id,
                'product_id': prod['product_id'],
                'quantity': qty,
                'unit_price': prod['unit_price']
            })

    df_opps = pd.DataFrame(opportunities)
    df_opps.to_csv(f"{base_dir}/crm_opportunities.csv", index=False)
    
    df_items = pd.DataFrame(line_items)
    df_items.to_csv(f"{base_dir}/crm_line_items.csv", index=False)

def generate_activity_logs():
    # Simulating Deal Activities
    activities = []
    # Re-read opportunities for IDs
    opps = pd.read_csv(f"{base_dir}/crm_opportunities.csv")['opportunity_id'].tolist()
    users = pd.read_csv(f"{base_dir}/crm_users.csv")['user_id'].tolist()
    
    types = ['Email', 'Call', 'Meeting', 'Task', 'LinkedIn']
    outcomes = ['Positive', 'Negative', 'Neutral', 'Follow-up Scheduled']
    
    for _ in range(NUM_ACTIVITIES):
        activities.append({
            'activity_id': str(uuid.uuid4()),
            'opportunity_id': random.choice(opps),
            'user_id': random.choice(users),
            'type': random.choice(types),
            'subject': fake.sentence(nb_words=5),
            'activity_date': fake.date_time_between(start_date='-1y', end_date='now'),
            'outcome': random.choice(outcomes)
        })
    df_activities = pd.DataFrame(activities)
    df_activities.to_csv(f"{base_dir}/activity_logs.csv", index=False)

def generate_usage_logs():
    # Simulating Subscription Usage / Revenue signals
    subscriptions = []
    opps = pd.read_csv(f"{base_dir}/crm_opportunities.csv")
    won_opps = opps[opps['is_won'] == True].to_dict('records')
    products = pd.read_csv(f"{base_dir}/crm_products.csv")['product_id'].tolist()
    
    for opp in won_opps:
        subscriptions.append({
            'subscription_id': str(uuid.uuid4()),
            'account_id': opp['account_id'],
            'opportunity_id': opp['opportunity_id'],
            'product_id': random.choice(products),
            'mrr': round(opp['amount'] / 12, 2),
            'start_date': opp['close_date'],
            'end_date': (datetime.strptime(str(opp['close_date']), '%Y-%m-%d') + timedelta(days=365)).strftime('%Y-%m-%d'),
            'status': 'Active' if random.random() > 0.1 else 'Cancelled'
        })
    df_subs = pd.DataFrame(subscriptions)
    df_subs.to_csv(f"{base_dir}/usage_subscriptions.csv", index=False)

if __name__ == "__main__":
    print("Generating CRM data...")
    generate_crm_data()
    print("Generating Activity logs...")
    generate_activity_logs()
    print("Generating Usage logs...")
    generate_usage_logs()
    print(f"Data generation complete. Files saved to {base_dir}")
