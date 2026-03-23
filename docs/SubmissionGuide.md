# Submission & Demo Guide: Revenue Intelligence System

This document provides all the necessary details and directions for the Remote Hustle Stage 2 submission and live demo.

## 📋 1. Google Form Submission Details
Copy and paste these exact details into your submission form:

- **Live Database Connection**:
  - **Host**: `aws-1-eu-west-1.pooler.supabase.com`
  - **Port**: `6543`
  - **User**: `postgres.bhlklbwpdlwftkvfydvl`
  - **Password**: `iu6DZp.S_b#%3$u`
  - **Database**: `postgres`
- **GitHub Repo Link**: `https://github.com/Chi-G/revenue-intelligence.git`
- **Project Description Document**: Upload the PDF version of [Stage 2 Project Description - Chijindu Nwokeohuru.pdf](../docs/ProjectDescription.pdf).

## 🎥 2. Demo Video Presentation (2–4 Minutes)
Follow this flow for the most impactful presentation:

### Part A: Introduction (45s)
- **Speech**: "My name is Chijindu Nwokeohuru. I have built a Revenue Intelligence System that unifies CRM, activity, and usage data into a single, high-performance PostgreSQL backend. I chose this focus because revenue intelligence is the engine of business growth."
- **Visual**: Show the [README](../README.md) or the [Project Description](../docs/ProjectDescription.md).

### Part B: The Schema (45s)
- **Speech**: "The core system features 11 normalized entities and 12+ analytical views. These views operate as a 'brain,' automatically calculating forecasts and risks in real-time."
- **Visual**: Briefly scroll through [schema/01_tables.sql](../schema/01_tables.sql).

### Part C: Live Intelligence Demo (2m)
- **Visual**: Open the **Supabase SQL Editor**.
- **Speech**: "I will now demonstrate the system's analytical power on our live Supabase cluster, which is currently managing over 300 active opportunities and 1,500 activity logs."
- **Action**: Run the following from [queries/analytical_queries.sql](../queries/analytical_queries.sql):
  1. **Forecast**: `SELECT * FROM v_revenue_forecast;` (Explain how it predicts future revenue).
  2. **Risk**: `SELECT * FROM v_deal_stagnation_risks;` (Show how it flags inactive deals).
  3. **Segmentation**: `SELECT * FROM v_customer_segments;` (Show how it prioritizes high-value accounts).

### Part D: Conclusion (30s)
- **Speech**: "By prioritizing database intelligence over frontend flair, this system provides a scalable, accurate foundation for any RevOps org. Thank you."

---

## 🔎 3. Verification & Safety
- **Connectivity**: The project is live and verified (300+ opportunities confirmed).
- **Security**: Database credentials are NOT included in the repository README. They are only for you to submit via the secure Google Form.
- **Reference**: For technical details on the tech stack and implementation, refer to the [Project Description Document](../docs/ProjectDescription.md).
