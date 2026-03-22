-- Revenue Intelligence System: Analytical Views
-- Key analytical insights for revenue forecasting and risk detection.

-- 1. Pipeline Scoring & Risk Detection (Deal Stagnation)
CREATE OR REPLACE VIEW v_deal_stagnation_risks AS
SELECT 
    o.opportunity_id,
    o.name AS opportunity_name,
    a.name AS account_name,
    s.name AS stage_name,
    o.amount,
    o.updated_at AS last_modified,
    CURRENT_DATE - o.updated_at::date AS days_since_update,
    (SELECT MAX(activity_date) FROM deal_activities WHERE opportunity_id = o.opportunity_id) AS last_activity_date,
    CASE 
        WHEN (CURRENT_DATE - (SELECT MAX(activity_date) FROM deal_activities WHERE opportunity_id = o.opportunity_id)::date) > 14 THEN 'High Risk (No Activity)'
        WHEN (CURRENT_DATE - (SELECT MAX(activity_date) FROM deal_activities WHERE opportunity_id = o.opportunity_id)::date) > 7 THEN 'Medium Risk'
        ELSE 'Healthy'
    END AS risk_level
FROM opportunities o
JOIN accounts a ON o.account_id = a.account_id
JOIN opportunity_stages s ON o.stage_id = s.stage_id
WHERE o.is_closed = FALSE;

-- 2. Revenue Forecasting (Weighted Pipeline)
CREATE OR REPLACE VIEW v_revenue_forecast AS
SELECT 
    DATE_TRUNC('month', close_date) AS forecast_month,
    SUM(amount) AS total_pipeline_value,
    SUM(amount * s.probability) AS weighted_forecast,
    COUNT(*) AS deal_count
FROM opportunities o
JOIN opportunity_stages s ON o.stage_id = s.stage_id
WHERE o.is_closed = FALSE
GROUP BY 1
ORDER BY 1;

-- 3. Cohort Analysis (MRR by Join Month)
CREATE OR REPLACE VIEW v_cohort_mrr AS
WITH account_cohorts AS (
    SELECT 
        account_id,
        DATE_TRUNC('month', MIN(start_date)) AS cohort_month
    FROM subscriptions
    GROUP BY 1
)
SELECT 
    c.cohort_month,
    DATE_TRUNC('month', s.start_date) AS activity_month,
    SUM(s.mrr) AS total_mrr,
    COUNT(DISTINCT s.account_id) AS customer_count
FROM subscriptions s
JOIN account_cohorts c ON s.account_id = c.account_id
WHERE s.status = 'Active'
GROUP BY 1, 2
ORDER BY 1, 2;

-- 4. Customer Segmentation (Revenue Contribution)
CREATE OR REPLACE VIEW v_customer_segments AS
WITH revenue_per_account AS (
    SELECT 
        a.account_id,
        a.name,
        SUM(o.amount) AS total_revenue,
        NTILE(4) OVER (ORDER BY SUM(o.amount) DESC) AS revenue_quartile
    FROM accounts a
    JOIN opportunities o ON a.account_id = o.account_id
    WHERE o.is_won = TRUE
    GROUP BY 1, 2
)
SELECT 
    *,
    CASE 
        WHEN revenue_quartile = 1 THEN 'Tier 1 (Strategic)'
        WHEN revenue_quartile = 2 THEN 'Tier 2 (Growth)'
        WHEN revenue_quartile = 3 THEN 'Tier 3 (Standard)'
        ELSE 'Tier 4 (Long-tail)'
    END AS customer_segment
FROM revenue_per_account;

-- 5. Funnel Conversion & Velocity
CREATE OR REPLACE VIEW v_funnel_velocity AS
SELECT 
    s.name AS stage_name,
    AVG(o.updated_at::date - o.created_at::date) AS avg_days_in_stage,
    COUNT(*) AS deal_count,
    ROUND( (COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()), 2) AS percentage_of_total
FROM opportunities o
JOIN opportunity_stages s ON o.stage_id = s.stage_id
GROUP BY 1, s.sort_order
ORDER BY s.sort_order;

-- 6. Churn Signal Detection (Subscription Activity Pattern)
CREATE OR REPLACE VIEW v_churn_signals AS
SELECT 
    a.name AS account_name,
    s.mrr,
    s.end_date,
    (SELECT COUNT(*) FROM deal_activities da WHERE da.opportunity_id = s.opportunity_id AND da.activity_date > CURRENT_DATE - INTERVAL '30 days') AS activities_last_30_days,
    CASE 
        WHEN (SELECT COUNT(*) FROM deal_activities da WHERE da.opportunity_id = s.opportunity_id AND da.activity_date > CURRENT_DATE - INTERVAL '30 days') = 0 THEN 'Potential Churn (Inactive)'
        WHEN s.end_date < CURRENT_DATE + INTERVAL '30 days' THEN 'Renewal Warning'
        ELSE 'Stable'
    END AS churn_risk_status
FROM subscriptions s
JOIN accounts a ON s.account_id = a.account_id
WHERE s.status = 'Active';

-- 7. Anomaly Detection (Outlier Deals)
CREATE OR REPLACE VIEW v_revenue_anomalies AS
WITH stats AS (
    SELECT AVG(amount) as avg_amt, STDDEV(amount) as std_amt
    FROM opportunities WHERE is_won = TRUE
)
SELECT 
    o.name, 
    o.amount,
    s.avg_amt,
    o.amount / s.avg_amt AS multiplier,
    CASE 
        WHEN o.amount > (s.avg_amt + 2 * s.std_amt) THEN 'Significantly Above Average'
        WHEN o.amount < (s.avg_amt - 2 * s.std_amt) THEN 'Significantly Below Average'
        ELSE 'Normal'
    END AS anomaly_type
FROM opportunities o, stats s
WHERE o.is_won = TRUE;

-- 8. Opportunity Scoring (Next Best Action)
CREATE OR REPLACE VIEW v_opportunity_scores AS
SELECT 
    o.opportunity_id,
    o.name,
    (
        (CASE WHEN o.lead_source = 'Referral' THEN 20 ELSE 0 END) +
        (CASE WHEN a.industry = 'Software' THEN 15 ELSE 5 END) +
        (CASE WHEN o.amount > 50000 THEN 10 ELSE 0 END) +
        (SELECT COUNT(*) * 5 FROM deal_activities da WHERE da.opportunity_id = o.opportunity_id)
    ) AS business_score,
    CASE 
        WHEN (SELECT COUNT(*) FROM deal_activities da WHERE da.opportunity_id = o.opportunity_id) = 0 THEN 'Schedule Discovery Call'
        WHEN o.stage_id = 3 THEN 'Send Proposal'
        WHEN o.stage_id = 4 THEN 'Follow up on Negotiation'
        ELSE 'Nurture'
    END AS next_best_action
FROM opportunities o
JOIN accounts a ON o.account_id = a.account_id
WHERE o.is_closed = FALSE;

-- 9. MRR Movements (New vs Churn)
CREATE OR REPLACE VIEW v_mrr_movements AS
SELECT 
    DATE_TRUNC('month', created_at) AS report_month,
    SUM(CASE WHEN status = 'Active' THEN mrr ELSE 0 END) AS new_mrr,
    SUM(CASE WHEN status = 'Cancelled' THEN mrr ELSE 0 END) AS churned_mrr,
    SUM(CASE WHEN status = 'Active' THEN mrr ELSE -mrr END) AS net_mrr_change
FROM subscriptions
GROUP BY 1
ORDER BY 1;

-- 10. Win/Loss Ratio Trend
CREATE OR REPLACE VIEW v_win_loss_trends AS
SELECT 
    DATE_TRUNC('month', close_date) AS close_month,
    COUNT(*) FILTER (WHERE is_won = TRUE) AS wins,
    COUNT(*) FILTER (WHERE is_closed = TRUE AND is_won = FALSE) AS losses,
    ROUND(COUNT(*) FILTER (WHERE is_won = TRUE)::numeric / NULLIF(COUNT(*) FILTER (WHERE is_closed = TRUE), 0), 2) AS win_rate
FROM opportunities
GROUP BY 1
ORDER BY 1;

-- 11. Product Revenue Distribution
CREATE OR REPLACE VIEW v_product_performance AS
SELECT 
    p.name AS product_name,
    p.category,
    SUM(oli.total_price) AS total_revenue,
    COUNT(DISTINCT oli.opportunity_id) AS deal_count
FROM products p
JOIN opportunity_line_items oli ON p.product_id = oli.product_id
JOIN opportunities o ON oli.opportunity_id = o.opportunity_id
WHERE o.is_won = TRUE
GROUP BY 1, 2;

-- 12. Sales Rep Performance vs Average
CREATE OR REPLACE VIEW v_sales_rep_ranking AS
SELECT 
    u.full_name,
    COUNT(o.opportunity_id) AS deals_won,
    SUM(o.amount) AS total_revenue_closed,
    AVG(SUM(o.amount)) OVER () AS team_average_revenue,
    SUM(o.amount) - AVG(SUM(o.amount)) OVER () AS variance_from_avg
FROM users u
JOIN opportunities o ON u.user_id = o.owner_id
WHERE o.is_won = TRUE
GROUP BY u.user_id, u.full_name;
