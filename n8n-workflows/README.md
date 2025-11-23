# n8n Workflows

This folder contains importable n8n workflows for the Revenue Leakage Detection System.

## Workflows

1. `01-stripe-data-sync.json`
   - Pulls active Stripe subscriptions daily
   - Upserts customers into Supabase
   - Inserts `actual_charges` rows
   - Sends completion notification to Slack

2. `02-usage-collection.json`
   - Collects product usage (mock or real API)
   - Inserts records into `product_usage`

3. `03-detect-outdated-pricing.json`
   - Compares current plan prices vs. actual charges
   - Inserts `leakage_detections` for outdated pricing
   - Sends Slack alerts for high-severity items

4. `04-detect-missing-overages.json`
   - Compares usage vs. contract limits
   - Calculates expected overages vs. actual
   - Inserts `leakage_detections` for missing overages

5. `05-daily-summary.json`
   - Aggregates detections for the current day
   - Sends a daily leakage summary to Slack

## How to import

1. Open your n8n instance
2. Go to **Workflows → Import from file**
3. Upload any of the JSON files in this folder
4. Update credentials:
   - Supabase
   - Stripe
   - Slack
5. Run once manually to verify
