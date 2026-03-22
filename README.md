# Revenue Intelligence System

A robust database-centric solution for unified revenue analytics and intelligence. This system integrates CRM data, deal activities, and usage logs into a powerful PostgreSQL backend designed to surface actionable business insights.

## Live Demo & Access

The project is deployed live on **Supabase**. Judges and reviewers can interact with the system using the following methods:

### 1. Direct Database Connection
Connect your favorite database client (e.g., TablePlus, pgAdmin, or DBeaver) using the provided credentials:
- **Host**: `db.bhlklbwpdlwftkvfydvl.supabase.co`
- **Port**: `5432`
- **User**: `postgres`
- **Database**: `postgres`

### 2. Analytical Insights (SQL Editor)
Once connected, you can run queries against our **12 Analytical Views**. Sample queries:
```sql
-- View top revenue-driving products
SELECT * FROM v_product_performance;

-- Detect high-risk deals (stagnation)
SELECT * FROM v_deal_stagnation_risks;

-- View monthly revenue forecast
SELECT * FROM v_revenue_forecast;
```

---

## Core Analytical Features

Our system exposes 12 powerful analytical views to drive revenue intelligence:

1.  **`v_deal_stagnation_risks`**: Detects deals with no activity in 14 days.
2.  **`v_revenue_forecast`**: Calculates weighted revenue using stage probabilities.
3.  **`v_cohort_mrr`**: Tracks MRR retention and growth by account join-month.
4.  **`v_customer_segments`**: Tiers accounts into Strategic, Growth, and Standard.
5.  **`v_funnel_velocity`**: Meaures the average time it takes for a deal to pass through each stage.
6.  **`v_churn_signals`**: Flags accounts with expiring subscriptions and low recent activity.
7.  **`v_revenue_anomalies`**: Uses statistical standard deviation (2σ) to identify outlier deal sizes.
8.  **`v_opportunity_scores`**: A rule-based engine recommending the "Next Best Action" for every deal.
9.  **`v_mrr_movements`**: Breakdowns net new MRR vs Churned MRR.
10. **`v_win_loss_trends`**: Tracks monthly win rates to detect sales effectiveness.
11. **`v_product_performance`**: identifies which product categories drive the most revenue.
12. **`v_sales_rep_ranking`**: Benchmarks individual reps against the team's average.

## Tech Stack
- **Database**: PostgreSQL (Relational focus).
- **Data Ingestion**: Python (Pandas + SQLAlchemy).
- **Simulation**: Faker (Realistic business datasets).
- **Architecture**: Normalized schema with 11 core entities.

## Project Structure
- `/schema`: SQL DDL for tables and analytical views.
- `/scripts`: Python automation for data generation and ingestion.
- `/seed_data`: Realistic sample datasets (300+ opportunities).
- `/docs`: Architecture details and ER diagrams.
