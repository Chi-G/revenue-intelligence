-- Revenue Intelligence System: Core Schema
-- Database Backend for Revenue Optimization

-- Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Users (Internal Sales/RevOps)
CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    full_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    role TEXT CHECK (role IN ('Sales Rep', 'Sales Manager', 'RevOps', 'VP Sales')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. Accounts (B2B Customers)
CREATE TABLE accounts (
    account_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    industry TEXT,
    company_size TEXT,
    annual_revenue NUMERIC(15, 2),
    country TEXT,
    owner_id UUID REFERENCES users(user_id),
    status TEXT DEFAULT 'Active' CHECK (status IN ('Active', 'Churned', 'Prospect')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. Contacts
CREATE TABLE contacts (
    contact_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_id UUID REFERENCES accounts(account_id) ON DELETE CASCADE,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    job_title TEXT,
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. Products
CREATE TABLE products (
    product_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    sku TEXT UNIQUE NOT NULL,
    category TEXT,
    unit_price NUMERIC(15, 2) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 5. Opportunity Stages
CREATE TABLE opportunity_stages (
    stage_id SERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    probability NUMERIC(3, 2) CHECK (probability >= 0 AND probability <= 1),
    sort_order INTEGER UNIQUE NOT NULL
);

-- Seed Stages
INSERT INTO opportunity_stages (name, probability, sort_order) VALUES
('Qualification', 0.10, 1),
('Discovery', 0.25, 2),
('Proposal/Price Quote', 0.50, 3),
('Negotiation/Review', 0.75, 4),
('Closed Won', 1.00, 5),
('Closed Lost', 0.00, 6);

-- 6. Opportunities (Deals)
CREATE TABLE opportunities (
    opportunity_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    account_id UUID REFERENCES accounts(account_id) ON DELETE CASCADE,
    owner_id UUID REFERENCES users(user_id),
    stage_id INTEGER REFERENCES opportunity_stages(stage_id),
    amount NUMERIC(15, 2),
    close_date DATE NOT NULL,
    lead_source TEXT,
    forecast_category TEXT CHECK (forecast_category IN ('Pipeline', 'Best Case', 'Commit', 'Omitted', 'Closed')),
    next_step TEXT,
    is_closed BOOLEAN DEFAULT FALSE,
    is_won BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 7. Opportunity Line Items
CREATE TABLE opportunity_line_items (
    line_item_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    opportunity_id UUID REFERENCES opportunities(opportunity_id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(product_id),
    quantity INTEGER DEFAULT 1,
    unit_price NUMERIC(15, 2),
    total_price NUMERIC(15, 2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 8. Deal Activities (Signals for Risk/Intelligence)
CREATE TABLE deal_activities (
    activity_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    opportunity_id UUID REFERENCES opportunities(opportunity_id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(user_id),
    type TEXT CHECK (type IN ('Email', 'Call', 'Meeting', 'Task', 'LinkedIn')),
    subject TEXT,
    description TEXT,
    activity_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    outcome TEXT -- e.g., 'Positive', 'Negative', 'Follow-up Scheduled'
);

-- 9. Subscriptions (Recurring Revenue)
CREATE TABLE subscriptions (
    subscription_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_id UUID REFERENCES accounts(account_id),
    opportunity_id UUID REFERENCES opportunities(opportunity_id),
    product_id UUID REFERENCES products(product_id),
    mrr NUMERIC(15, 2) NOT NULL, -- Monthly Recurring Revenue
    start_date DATE NOT NULL,
    end_date DATE,
    status TEXT CHECK (status IN ('Active', 'Cancelled', 'Expired', 'Draft')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 10. Revenue Snapshots (For forecasting/historical analysis)
CREATE TABLE revenue_snapshots (
    snapshot_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    snapshot_date DATE NOT NULL DEFAULT CURRENT_DATE,
    opportunity_id UUID REFERENCES opportunities(opportunity_id),
    amount NUMERIC(15, 2),
    stage_id INTEGER REFERENCES opportunity_stages(stage_id),
    probability NUMERIC(3, 2)
);

-- 11. Audit Log
CREATE TABLE audit_log (
    audit_id BIGSERIAL PRIMARY KEY,
    table_name TEXT NOT NULL,
    record_id UUID NOT NULL,
    field_name TEXT,
    old_value TEXT,
    new_value TEXT,
    changed_by UUID REFERENCES users(user_id),
    changed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indices for Performance
CREATE INDEX idx_opportunities_account ON opportunities(account_id);
CREATE INDEX idx_opportunities_owner ON opportunities(owner_id);
CREATE INDEX idx_opportunities_stage ON opportunities(stage_id);
CREATE INDEX idx_activities_opportunity ON deal_activities(opportunity_id);
CREATE INDEX idx_snapshots_date ON revenue_snapshots(snapshot_date);
CREATE INDEX idx_subscriptions_account ON subscriptions(account_id);
