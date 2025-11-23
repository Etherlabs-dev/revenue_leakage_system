
````
# 🚀 Setup Guide — Revenue Leakage Detection System

This guide walks you through installing the full system using:

- Supabase (database)
- n8n (workflows)
- Stripe (billing)
- Slack (alerts)
- Optional product usage API

This assumes basic familiarity with API keys, Stripe, and Docker.

---

## **1️⃣ Clone the Repository**

```bash
git clone https://github.com/Etherlabs-dev/revenue_leakage_system.git
cd revenue_leakage_system
````

---

## **2️⃣ Environment Setup**

Copy the template:

```bash
cp .env.example .env
```

Fill in your keys:

```env
# Supabase
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=service-role-key-here

# Stripe
STRIPE_SECRET_KEY=sk_test_or_live_key_here

# Slack
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/...

# Product API (optional)
PRODUCT_API_URL=https://your-product-api.com
PRODUCT_API_KEY=your-api-key
```

⚠ Use **service role key** for Supabase inserts
⚠ Do **not** commit `.env` to GitHub

---

## **3️⃣ Database Setup — Supabase**

### **Create database and apply schema**

Open Supabase → SQL Editor → paste full schema from:

```
database/schema.sql
```

OR run locally:

```bash
psql -f database/schema.sql
```

### **Load sample test data (optional)**

This creates 3 test customers with known leakage scenarios:

```bash
psql -f database/sample-data.sql
```

---

## **4️⃣ Running n8n**

### **Option A — Local via Docker (recommended)**

```bash
docker run -it --rm \
  --name n8n \
  -p 5678:5678 \
  -v ~/.n8n:/home/node/.n8n \
  n8nio/n8n
```

Open:

```
http://localhost:5678
```

### **Option B — n8n Cloud**

No setup required: [https://n8n.io](https://n8n.io)

---

## **5️⃣ Add Credentials inside n8n**

| Service     | Type                | Value                          |
| ----------- | ------------------- | ------------------------------ |
| Supabase    | Supabase API        | URL + Service Role Key         |
| Stripe      | Header Auth         | `Authorization: Bearer sk_...` |
| Slack       | Slack API / Webhook | Team alerts                    |
| Product API | HTTP Request        | Bearer token                   |

---

## **6️⃣ Import Workflows**

Go to:

> n8n → Workflows → **Import workflow**

Import each file:

```
n8n-workflows/
  01-stripe-data-sync.json
  02-usage-collection.json
  03-detect-outdated-pricing.json
  04-detect-missing-overages.json
  05-daily-summary.json
```

Each workflow should execute manually once before scheduling.

---

## **7️⃣ Scheduling**

Default cron expressions:

| Workflow         | Schedule  |
| ---------------- | --------- |
| Stripe Sync      | 6AM daily |
| Usage Sync       | 7AM daily |
| Outdated Pricing | 8AM daily |
| Missing Overages | 9AM daily |
| Summary Digest   | 5PM daily |

Modify by opening the **Schedule Trigger** node.

---

## **8️⃣ Verification Checklist**

### **Check data populated**

```sql
SELECT * FROM customers;
SELECT * FROM actual_charges;
SELECT * FROM product_usage;
```

### **Check leakage created**

```sql
SELECT * FROM leakage_detections ORDER BY created_at DESC;
```

### **Check Slack alerts**

You should see alerts like:

> 🚨 HIGH PRIORITY REVENUE LEAKAGE DETECTED

---

## **9️⃣ Connecting Real Usage Data**

Replace mock usage generator in:

```
02-usage-collection.json
```

with:

```javascript
return [
  {
    json: await $http.get(`${$env.PRODUCT_API_URL}/usage/${$json.stripe_customer_id}`, {
      headers: { Authorization: `Bearer ${$env.PRODUCT_API_KEY}` }
    })
  }
];
```

---

## **🔧 Troubleshooting**

| Issue                  | Fix                                             |
| ---------------------- | ----------------------------------------------- |
| No detections          | Load sample data + run workflows in order       |
| Supabase insert failed | Use Service Role key, not anon key              |
| Stripe errors          | Make sure you're using correct mode (test/live) |
| Slack not sending      | Test webhook manually using curl                |

---

## **📌 Related Files**

| Purpose               | Path                       |
| --------------------- | -------------------------- |
| Architecture Overview | `docs/architecture.md`     |
| Workflows             | `n8n-workflows/*.json`     |
| Schema                | `database/schema.sql`      |
| Sample Data           | `database/sample-data.sql` |

---

## Maintainer

**Ugo Chukwu (@Ethercess)**
Open issues here:
[https://github.com/Etherlabs-dev/revenue_leakage_system/issues](https://github.com/Etherlabs-dev/revenue_leakage_system/issues)

```


