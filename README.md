# Revenue Leakage Detection System

**Automated system to detect and recover lost revenue in B2B SaaS companies**


## 🎯 What It Does

Automatically detects 4 types of revenue leakage:

1. **Outdated Pricing** - Customers paying old rates
2. **Missing Overages** - Usage charges not applied  
3. **Incorrect Discounts** - Unqualified discounts given
4. **Feature Leakage** - Premium features on basic plans

**Typical Results:**
- $500K-900K recovered annually
- 1,900% ROI
- 90% time reduction vs manual audits

## 📊 Key Features

- ✅ **100% Coverage** - Checks all customers daily, not just a sample
- ✅ **Real-time Detection** - Finds issues within 24 hours
- ✅ **Smart Prioritization** - Severity scoring by revenue impact
- ✅ **Automated Alerts** - Slack notifications for high-value issues
- ✅ **Recovery Workflow** - Built-in investigation and resolution tools
- ✅ **Prevention Layer** - Catches errors before billing runs

## 🏗️ Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                     DATA COLLECTION                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │  Stripe  │  │ Product  │  │ Contract │  │   Usage  │   │
│  │   API    │  │   API    │  │   Data   │  │   Logs   │   │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘   │
│       │             │             │             │            │
│       └─────────────┴─────────────┴─────────────┘           │
│                           │                                  │
└───────────────────────────┼──────────────────────────────────┘
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    SUPABASE DATABASE                         │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  customers | contract_pricing | actual_charges |     │  │
│  │  product_usage | pricing_rules | leakage_detections │  │
│  └──────────────────────────────────────────────────────┘  │
└───────────────────────────┬─────────────────────────────────┘
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    VALIDATION ENGINE (n8n)                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Outdated   │  │   Missing    │  │  Incorrect   │     │
│  │   Pricing    │  │   Overages   │  │  Discounts   │     │
│  │   Detector   │  │   Detector   │  │   Detector   │     │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘     │
│         │                  │                  │              │
│         └──────────────────┴──────────────────┘             │
│                            │                                 │
└────────────────────────────┼─────────────────────────────────┘
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                    ALERTING & REPORTING                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │    Slack     │  │    Email     │  │  Dashboard   │     │
│  │    Alerts    │  │   Reports    │  │    (Web)     │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

## 🚀 Quick Start

### Prerequisites

- Supabase account (free tier works)
- n8n instance (self-hosted or cloud)
- Stripe account with API access
- Slack workspace (optional, for alerts)

### Installation

**1. Clone the repository**
```bash
git clone https://github.com/Etherlabs-dev/revenue_leakage_system.git
cd revenue_leakage_system
```

**2. Set up Supabase database**
```bash
# Run the database schema script
psql -h your-supabase-url -d postgres -f database/schema.sql

# Load sample data (optional)
psql -h your-supabase-url -d postgres -f database/sample-data.sql
```

**3. Configure environment variables**
```bash
cp .env.example .env
# Edit .env with your credentials:
# - SUPABASE_URL
# - SUPABASE_KEY
# - STRIPE_SECRET_KEY
# - SLACK_WEBHOOK_URL
```

**4. Import n8n workflows**
```bash
# In n8n UI:
# 1. Go to Workflows
# 2. Click "Import from File"
# 3. Import each file from ./n8n-workflows/
```

**5. Configure credentials in n8n**
- Add Supabase credentials
- Add Stripe API key (HTTP Header Auth)
- Add Slack webhook URL

**6. Test the workflows**
```bash
# Run each workflow manually first
# Check database for results
# Verify Slack notifications
```

### Usage

The system runs automatically via scheduled workflows:

- **6:00 AM** - Stripe data sync
- **7:00 AM** - Product usage collection
- **8:00 AM** - Outdated pricing detection
- **9:00 AM** - Missing overages detection
- **10:00 AM** - Incorrect discounts detection
- **5:00 PM** - Daily summary report

**Manual triggers** are also available for testing.

## 📁 Project Structure
```
revenue_leakage_system/
  ├── database/
  │   ├── schema.sql
  │   ├── sample-data.sql
  │   └── migrations/
  ├── n8n-workflows/
  │   ├── 01-stripe-data-sync.json
  │   ├── 02-usage-collection.json
  │   ├── 03-detect-outdated-pricing.json
  │   ├── 04-detect-missing-overages.json
  │   ├── 05-daily-summary.json
  │   └── README.md
  ├── docs/
  │   ├── architecture.md
  │   ├── detection-logic.md
  │   ├── setup-guide.md
  │   └── images/
  ├── scripts/
  │   ├── test-detection.js
  │   └── generate-report.js
  ├── .env.example
  ├── LICENSE
  ├── CONTRIBUTING.md
  └── README.md
```

## 🔧 Configuration

### Detection Rules

Customize detection rules in `database/pricing_rules` table:
```sql
-- Example: Set current pricing for Pro plan
INSERT INTO pricing_rules (
  plan_name,
  current_base_price,
  included_usage,
  overage_rates,
  features
) VALUES (
  'pro',
  149.00,
  '{"api_calls": 50000, "storage_gb": 100}',
  '{"api_calls_per_1000": 5.00, "storage_gb": 2.00}',
  '["advanced_analytics", "custom_domains", "api_access"]'
);
```

### Alert Thresholds

Modify severity scoring in workflow functions:
```javascript
// In n8n Function node
let severity = 'low';
if (leakageAmount > 500) {
  severity = 'high';  // Adjust this threshold
} else if (leakageAmount > 100) {
  severity = 'medium';  // Adjust this threshold
}
```

### Notification Channels

Configure in n8n Slack node or add email notifications:
```javascript
// For high severity only
if (severity === 'high') {
  // Send Slack alert
  // Send email to CFO
}
```

## 📖 Documentation

- [System Architecture](.[/docs/architecture.md](https://dev.to/etherlabsdev/i-built-a-system-that-found-663k-in-lost-revenue-heres-the-complete-technical-breakdown-33c5)) - Technical design details
- [Workflow Logic](./n8n-workflows/README.md) - How each detection type works
- [Troubleshooting](.[/docs/troubleshooting.md](https://github.com/Etherlabs-dev/revenue_leakage_system/issues)) - Common issues

## 🧪 Testing

### Run Tests
```bash
# Test database schema
npm run test:db

# Test detection logic with sample data
npm run test:detection

# Run full workflow simulation
npm run test:workflow
```

### Sample Test Scenarios

The `database/sample-data.sql` includes 3 test scenarios:

1. **Customer with outdated pricing** - Should pay $149, paying $99
2. **Customer with missing overages** - Used 25K API calls, only paid for 10K
3. **Customer with incorrect discount** - Has 15% discount without qualification

Expected detections: 3 (one for each scenario)

## 📊 Results & ROI

### Real Client Results

**Case Study: B2B SaaS Company ($5M ARR)**

**Before:**
- Manual audits: 20 accounts/month (10% coverage)
- Time: 40 hours/month
- Leakage found: $50K/month (in audited accounts)
- Detection lag: 2-3 months

**After:**
- Automated monitoring: 200 accounts (100% coverage)
- Time: 5 hours/month
- Leakage found: $65K/month
- Detection lag: 1 day

**Results:**
- $663K recovered in year 1
- 1,907% ROI
- 35 hours/month saved
- Payback in 18 days

### ROI Calculator
```
Annual Leakage Recovered: $XXX,XXX
Annual Time Savings: XXX hours × $200/hour = $XX,XXX
Total Annual Value: $XXX,XXX

Implementation Cost: $15,000
Annual Ongoing Cost: $30,000
Total Investment: $45,000

ROI: (Value - Cost) / Cost = X,XXX%
```

## 🤝 Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](./CONTRIBUTING.md) for details.

### Development Setup
```bash
# Fork and clone
git clone https://github.com/yourusername/revenue-leakage-detector.git

# Create feature branch
git checkout -b feature/your-feature

# Make changes and test
npm run test

# Submit pull request
```

## 📝 License

This project is licensed under the MIT License - see [LICENSE](./LICENSE) file.

## 🙋 Support

- **Email:** ethercess@gail.com

## 🌟 Acknowledgments

Built with:
- [n8n](https://n8n.io/) - Workflow automation
- [Supabase](https://supabase.com/) - Database & real-time
- [Stripe](https://stripe.com/) - Payment processing

Inspired by real problems at my credit card company.

## 🚧 Roadmap

- [ ] Add Chargebee integration
- [ ] Build React dashboard UI
- [ ] Add PDF report generation
- [ ] Create Zapier integration
- [ ] Add historical trend analysis
- [ ] Build mobile app for alerts

## ⭐ Star History

[![Star History Chart](https://api.star-history.com/svg?repos=Etherlabs-dev/revenue_leakage_system&type=Date)](https://star-history.com/#Etherlabs-dev/revenue-leakage-system&Date)

---

**Built by [Ugo Chukwu]([https://yourwebsite.com](https://dev.to/etherlabsdev/i-built-a-system-that-found-663k-in-lost-revenue-heres-the-complete-technical-breakdown-33c5))**  
Credit Card Company Founder | Financial Automation Specialist

[LinkedIn](https://www.linkedin.com/in/ugo-chukwu/) · [Twitter](https://x.com/ChukwuAugustus) · [Website](https://dev.to/etherlabsdev/i-built-a-system-that-found-663k-in-lost-revenue-heres-the-complete-technical-breakdown-33c5)
