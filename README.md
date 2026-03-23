# Revenue Intelligence System

A robust database-centric solution for unified revenue analytics and intelligence. This system integrates CRM data, deal activities, and subscription logs into a powerful PostgreSQL backend designed to surface actionable business insights.

## 🚀 Overview

The system architecture focuses on:
- **Data Unification**: Integrating ≥3 simulated revenue sources.
- **Analytical Depth**: 12+ complex SQL views covering forecasting, risks, and cohorts.
- **Production Readiness**: Live hosted on Supabase with realistic, high-volume seed data.

## 📂 Project Structure

- `/schema`: SQL DDL for the 11-entity core tables and 12 analytical views.
- `/scripts`: Python automation for data generation and ingestion.
- `/seed_data`: Realistic sample datasets (300+ opportunities, 1500+ activities).
- `/queries`: High-impact analytical queries for immediate exploration.
- `/docs`: Comprehensive architecture diagrams and the project description.

## 📄 Documentation

For detailed analysis, setup instructions, and testing procedures, please refer to the **Project Description Document**:
- [docs/ProjectDescription.md](docs/ProjectDescription.md)
- [Stage 2 Project Description - Chijindu Nwokeohuru.pdf](docs/ProjectDescription.pdf) (Submission Version)

---

## 🛠 Tech Stack
- **Database**: PostgreSQL (Supabase Hosted)
- **Data Layer**: Python (Pandas + SQLAlchemy)
- **Simulation**: Faker (Business Scenario Modeling)
- **UI**: TablePlus / Supabase SQL Editor
