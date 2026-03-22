# Project Description: Revenue Intelligence System (RIS)

## 1. Project Overview
**Project Name**: Revenue Intelligence System (RIS)  
**Target Users**: Revenue Operations (RevOps), Sales Leaders, Finance Teams  

## 2. Revenue Problems Solved
- **Inaccurate Forecasting**: Traditional CRM exports lack weighted probability logic and historical snapshots. RIS provides a `v_revenue_forecast` view that simulates weighted pipelines.
- **Pipeline Leaks**: Deals often stagnate without being flagged. `v_deal_stagnation_risks` identifies high-risk deals based on inactivity.
- **Missed Upsell/Churn Signals**: By unifying usage logs with CRM data, the system flags churn risks in `v_churn_signals` and expansion opportunities in `v_expansion_opportunities`.
- **Poor Visibility into Deal Health**: `v_opportunity_scores` provides an automated "Next Best Action" for sales reps, taking the guesswork out of daily tasks.

## 3. Key Analytical Features
- **Statistical Anomaly Detection**: Uses standard deviation to flag deals that are unusually large or small compared to the historical average.
- **Cohort Analysis**: Tracks Monthly Recurring Revenue (MRR) by account cohorts to measure long-term value and retention.
- **Funnel Velocity Tracking**: Measures exactly how long deals spend in each stage to identify bottlenecks in the sales process.

## 4. Tech Stack & Rationale
- **DBMS**: PostgreSQL  
  - *Rationale*: Chosen for its robust support for Window Functions (used in rankings and anomalies), Materialized Views (for performance), and complex CTEs.
- **Data Layer**: Python (Faker + Pandas)
  - *Rationale*: Allows for the simulation of 3+ distinct data sources (CRM, Activity Logs, Usage) to demonstrate data unification capabilities.
- **Hosting**: Recommended for deployment on Neon.tech or Supabase for judge access.

## 5. Potential Real-World Impact
Implementing this system can increase sales velocity by up to 20% by focusing reps on high-score opportunities and reducing churn through early signal detection.
