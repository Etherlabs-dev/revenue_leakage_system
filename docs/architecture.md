# 🏗 System Architecture — Revenue Leakage Detection System

This document explains how the system is structured, how data flows between components, and why each layer exists.

The goal is simple:
> Automatically detect and quantify revenue leakage in subscription-based SaaS companies by comparing *what customers should be billed* vs *what they were actually billed*.

---

## **🔍 Core Concept**

Revenue leakage happens when:
- Customers remain on outdated pricing
- Overages are not billed properly
- Discounts apply when they shouldn’t
- Premium features are enabled on lower plans

The system continuously collects data, validates it, flags discrepancies, and generates alerts.

---

## **🧱 5-Layer System Design**

```

┌─────────────────────────────────────────────────┐
│         LAYER 1: DATA COLLECTION                │
│  Stripe API | Product Usage API | Contracts     │
└──────────────────────┬──────────────────────────┘
▼
┌─────────────────────────────────────────────────┐
│         LAYER 2: DATABASE (Supabase / Postgres) │
│  customers | pricing_rules | actual_charges     │
│  product_usage | leakage_detections             │
└──────────────────────┬──────────────────────────┘
▼
┌─────────────────────────────────────────────────┐
│         LAYER 3: VALIDATION ENGINE (n8n)        │
│  Pricing check | Overages check | Discounts     │
└──────────────────────┬──────────────────────────┘
▼
┌─────────────────────────────────────────────────┐
│         LAYER 4: ALERTING & REPORTING           │
│  Slack Alerts | Dashboards | Daily Summaries    │
└──────────────────────┬──────────────────────────┘
▼
┌─────────────────────────────────────────────────┐
│         LAYER 5: RECOVERY WORKFLOWS             │
│  Investigation queue | Billing adjustments      │
└─────────────────────────────────────────────────┘

```

---

## **📌 Component Overview**

### **1️⃣ Data Sources**

| Source | Purpose | Example Fields |
|--------|---------|----------------|
| **Stripe API** | Actual charges & subscriptions | `invoice.total`, `plan.amount`, `discounts` |
| **Product Usage API** | Actual usage numbers | `api_calls`, `storage_used_gb` |
| **Contract Database** | What the customer *should* pay | `included_usage`, `plan_price`, `overage_rates` |

Data gathered from these sources is normalized before insert.

---

### **2️⃣ Database (Supabase / Postgres)**

Main tables:

| Table | Stores | Example |
|--------|--------|---------|
| `customers` | Identity + plan history | email, plan, price |
| `actual_charges` | What they were billed | Stripe invoices |
| `product_usage` | What they consumed | API calls, storage |
| `pricing_rules` | What they *should* pay | plan → pricing |
| `contract_pricing` | Customer-specific overrides | negotiated plans |
| `leakage_detections` | Violations found | type, amount, severity |

→ Full schema: `database/schema.sql`

---

### **3️⃣ Validation Engine (n8n)**

We automate checks using workflows.

| Workflow | File | Function |
|----------|------|----------|
| Daily Stripe Sync | `01-stripe-data-sync.json` | Pull billing data |
| Usage Collection | `02-usage-collection.json` | Pull usage data |
| Outdated Pricing Detection | `03-detect-outdated-pricing.json` | Compare plan vs price |
| Missing Overages Detection | `04-detect-missing-overages.json` | Compare usage vs charges |
| Daily Summary | `05-daily-summary.json` | Aggregated Slack report |

Execution order:

```

6AM → Sync billing
7AM → Sync usage
8AM → Compare pricing
9AM → Compare overages
5PM → Send report

```

---

### **4️⃣ Leakage Severity Rules**

| Monthly Difference | Severity |
|-------------------|----------|
| `< $100` | Low |
| `$100 - $500` | Medium |
| `> $500` | High |
| Future (optional): `> $5K` = Critical |

Severity determines alerting channel.

---

### **5️⃣ Alerting Layer**

- High severity → Slack channel `#revenue-alerts`
- Daily summary digest
- Can integrate:
  - Email (finance)
  - Jira tickets
  - CRM / Billing UI

Example alert:

```

🚨 Outdated Pricing
Customer paying $99 instead of $149
Loss: $50/month ($600/year)
Severity: Medium

```

---

### **6️⃣ Recovery Workflow**

This system **does NOT apply pricing updates automatically**—it surfaces issues and queues them.

Future improvements may include:
- Auto-generated billing adjustments
- Workflow to notify customers proactively
- UI dashboard

---

### **7️⃣ Scaling Considerations**

| Area | Scaling Plan |
|------|--------------|
| **200+ customers** | Supabase indices + batch queries |
| **10,000+ customers** | Move validation logic to scheduled Lambdas / workers |
| **Multiple billing systems** | Add adapters: Chargebee, Recurly, custom |

---

### **8️⃣ Future Extensions**

- Machine-learning anomaly detection
- Real-time invoice pre-flight validation
- Version-controlled pricing schemas
- Customer-facing audit reports

---

### **📎 Related Files**

| Purpose | File |
|---------|------|
| Database schema | `database/schema.sql` |
| Sample test data | `database/sample-data.sql` |
| Workflows | `n8n-workflows/*.json` |
| Setup guide | `docs/setup-guide.md` |

---

*Last updated:* 2025  
Maintainer: **Ugo Chukwu (@Ethercess)**
```

