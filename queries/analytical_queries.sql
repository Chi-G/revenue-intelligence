-- Revenue Intelligence System: Sample Analytical Queries
-- Use these queries to explore the live database and surface insights.

-- 1. Pipeline Risk: Identify top 5 stagnant deals (> $50k) with no recent activity
SELECT * 
FROM v_deal_stagnation_risks 
WHERE risk_level = 'High Risk (No Activity)' 
  AND amount > 50000 
ORDER BY amount DESC 
LIMIT 5;

-- 2. Forecasting: View weighted revenue forecast for the next 3 months 
SELECT * 
FROM v_revenue_forecast 
WHERE forecast_month >= CURRENT_DATE 
ORDER BY forecast_month ASC 
LIMIT 3;

-- 3. Cohort Analysis: View MRR retention for the first 3 cohorts
SELECT * 
FROM v_cohort_mrr 
WHERE cohort_month IN (SELECT DISTINCT cohort_month FROM v_cohort_mrr ORDER BY cohort_month LIMIT 3);

-- 4. Customer Segmentation: List 'Tier 1 (Strategic)' accounts by total revenue
SELECT * 
FROM v_customer_segments  
WHERE customer_segment = 'Tier 1 (Strategic)'
ORDER BY total_revenue DESC;

-- 5. Funnel Velocity: Identify stages where deals spend more than 30 days on average
SELECT * 
FROM v_funnel_velocity 
WHERE avg_days_in_stage > 30 
ORDER BY avg_days_in_stage DESC;

-- 6. Churn Warning: List active subscriptions with 'Renewal Warning' status
SELECT * 
FROM v_churn_signals 
WHERE churn_risk_status = 'Renewal Warning' 
ORDER BY end_date ASC;

-- 7. Anomaly Detection: Find won deals that are 'Significantly Above Average' in size
SELECT * 
FROM v_revenue_anomalies 
WHERE anomaly_type = 'Significantly Above Average';

-- 8. Opportunity Scoring: Top 10 recommended 'Next Best Actions' for the sales team
SELECT name, business_score, next_best_action 
FROM v_opportunity_scores 
ORDER BY business_score DESC 
LIMIT 10;

-- 9. MRR Growth: Monthly Net MRR Change (New vs Churned)
SELECT report_month, new_mrr, churned_mrr, net_mrr_change 
FROM v_mrr_movements 
ORDER BY report_month DESC;

-- 10. Performance Benchmarking: Sales reps exceeding the team average revenue
SELECT * 
FROM v_sales_rep_ranking 
WHERE total_revenue_closed > team_average_revenue 
ORDER BY variance_from_avg DESC;

-- 11. Win Rate Trend: Monthly win rate comparison
SELECT close_month, wins, losses, win_rate 
FROM v_win_loss_trends 
ORDER BY close_month DESC;

-- 12. Product Mix: Revenue contribution by product category
SELECT category, SUM(total_revenue) AS category_revenue 
FROM v_product_performance 
GROUP BY 1 
ORDER BY 2 DESC;
