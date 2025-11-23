-- 1. CUSTOMERS TABLE (baseline data)
CREATE TABLE customers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    stripe_customer_id TEXT UNIQUE NOT NULL,
    email TEXT,
    name TEXT,
    current_plan TEXT,
    current_price DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 2. CONTRACT PRICING TABLE (what they SHOULD pay)
CREATE TABLE contract_pricing (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID REFERENCES customers(id),
    plan_name TEXT NOT NULL,
    base_price DECIMAL(10,2) NOT NULL,
    included_usage JSONB, -- e.g., {"api_calls": 10000, "storage_gb": 50}
    overage_rates JSONB, -- e.g., {"api_calls_per_1000": 5.00, "storage_gb": 2.00}
    discount_percent DECIMAL(5,2) DEFAULT 0,
    discount_reason TEXT,
    effective_date DATE NOT NULL,
    end_date DATE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 3. ACTUAL CHARGES TABLE (what they ARE paying)
CREATE TABLE actual_charges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID REFERENCES customers(id),
    stripe_invoice_id TEXT UNIQUE,
    billing_period_start DATE,
    billing_period_end DATE,
    base_charge DECIMAL(10,2),
    overage_charges DECIMAL(10,2),
    discounts DECIMAL(10,2),
    total_charged DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT NOW()
);

-- 4. PRODUCT USAGE TABLE (actual usage data)
CREATE TABLE product_usage (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID REFERENCES customers(id),
    usage_period_start DATE,
    usage_period_end DATE,
    usage_data JSONB, -- e.g., {"api_calls": 15000, "storage_gb": 75}
    created_at TIMESTAMP DEFAULT NOW()
);

-- 5. LEAKAGE DETECTIONS TABLE (the violations we find)
CREATE TABLE leakage_detections (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID REFERENCES customers(id),
    detection_date DATE DEFAULT CURRENT_DATE,
    leakage_type TEXT NOT NULL, -- 'outdated_pricing', 'missing_overage', 'incorrect_discount', 'feature_mismatch'
    severity TEXT, -- 'low', 'medium', 'high'
    monthly_leakage_amount DECIMAL(10,2),
    description TEXT,
    should_charge DECIMAL(10,2),
    actually_charged DECIMAL(10,2),
    difference DECIMAL(10,2),
    status TEXT DEFAULT 'new', -- 'new', 'investigating', 'resolved', 'false_positive'
    resolved_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 6. PRICING RULES TABLE (business rules)
CREATE TABLE pricing_rules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    plan_name TEXT NOT NULL,
    current_base_price DECIMAL(10,2) NOT NULL,
    included_usage JSONB,
    overage_rates JSONB,
    features JSONB, -- e.g., ["advanced_analytics", "custom_domains", "api_access"]
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX idx_customers_stripe_id ON customers(stripe_customer_id);
CREATE INDEX idx_leakage_status ON leakage_detections(status);
CREATE INDEX idx_leakage_customer ON leakage_detections(customer_id);
CREATE INDEX idx_contract_customer ON contract_pricing(customer_id);
```
