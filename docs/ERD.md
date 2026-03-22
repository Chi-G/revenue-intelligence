# Entity Relationship Diagram (ERD)

The Revenue Intelligence System is built on a relational PostgreSQL foundation with 11 core entities designed for both operational integrity and analytical depth.

```mermaid
erDiagram
    USERS ||--o{ ACCOUNTS : "owns"
    USERS ||--o{ OPPORTUNITIES : "manages"
    USERS ||--o{ DEAL_ACTIVITIES : "performs"
    
    ACCOUNTS ||--o{ CONTACTS : "has"
    ACCOUNTS ||--o{ OPPORTUNITIES : "associated_with"
    ACCOUNTS ||--o{ SUBSCRIPTIONS : "has"
    
    OPPORTUNITY_STAGES ||--o{ OPPORTUNITIES : "defines"
    
    OPPORTUNITIES ||--o{ OPPORTUNITY_LINE_ITEMS : "contains"
    OPPORTUNITIES ||--o{ DEAL_ACTIVITIES : "logs"
    OPPORTUNITIES ||--o{ SUBSCRIPTIONS : "generates"
    OPPORTUNITIES ||--o{ REVENUE_SNAPSHOTS : "recorded_as"
    
    PRODUCTS ||--o{ OPPORTUNITY_LINE_ITEMS : "sold_as"
    PRODUCTS ||--o{ SUBSCRIPTIONS : "defines_service"
    
    USERS ||--o{ AUDIT_LOG : "triggers"
```

## Data Lineage & Flow
1. **Source Ingestion**: Simulated CRM, Activity, and Usage data is ingested as CSV.
2. **Operational Store**: Data is normalized into the 11 core tables (PostgreSQL).
3. **Analytical Layer**: Complex SQL views and window functions transform operational data into intelligence.
4. **Insights Surface**: Insights are delivered via 12+ analytical views for consumption by TablePlus or external dashboards.
