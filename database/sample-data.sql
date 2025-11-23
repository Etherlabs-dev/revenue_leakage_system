-- Insert test customers with known leakage scenarios

-- SCENARIO 1: Customer on old pricing
INSERT INTO customers (stripe_customer_id, email, name, current_plan, current_price)
VALUES ('cus_test_001', 'oldpricing@test.com', 'Test Company 1', 'pro', 99.00);

INSERT INTO pricing_rules (plan_name, current_base_price)
VALUES ('pro', 149.00); -- Current price is $149, they're paying $99

-- SCENARIO 2: Customer with usage overage not charged
INSERT INTO customers (stripe_customer_id, email, name, current_plan, current_price)
VALUES ('cus_test_002', 'overage@test.com', 'Test Company 2', 'basic', 49.00);

INSERT INTO contract_pricing (
  customer_id, 
  plan_name, 
  base_price, 
  included_usage, 
  overage_rates,
  effective_date
)
VALUES (
  (SELECT id FROM customers WHERE stripe_customer_id = 'cus_test_002'),
  'basic',
  49.00,
  '{"api_calls": 10000, "storage_gb": 50}',
  '{"api_calls_per_1000": 5.00, "storage_gb": 2.00}',
  CURRENT_DATE
);

-- Insert usage showing they exceeded limits
INSERT INTO product_usage (
  customer_id,
  usage_period_start,
  usage_period_end,
  usage_data
)
VALUES (
  (SELECT id FROM customers WHERE stripe_customer_id = 'cus_test_002'),
  CURRENT_DATE - INTERVAL '30 days',
  CURRENT_DATE,
  '{"api_calls": 25000, "storage_gb": 100}' -- Way over limits!
);

-- Insert actual charge showing NO overage charged
INSERT INTO actual_charges (
  customer_id,
  stripe_invoice_id,
  billing_period_start,
  billing_period_end,
  base_charge,
  overage_charges,
  total_charged
)
VALUES (
  (SELECT id FROM customers WHERE stripe_customer_id = 'cus_test_002'),
  'in_test_002',
  CURRENT_DATE - INTERVAL '30 days',
  CURRENT_DATE,
  49.00,
  0.00, -- Should be $75 in overages!
  49.00
);

-- SCENARIO 3: Customer with incorrect discount
INSERT INTO customers (stripe_customer_id, email, name, current_plan, current_price)
VALUES ('cus_test_003', 'discount@test.com', 'Test Company 3', 'pro', 126.50);

INSERT INTO contract_pricing (
  customer_id,
  plan_name,
  base_price,
  discount_percent,
  discount_reason,
  effective_date
)
VALUES (
  (SELECT id FROM customers WHERE stripe_customer_id = 'cus_test_003'),
  'pro',
  149.00,
  15.00, -- 15% discount = $126.50
  'annual_commitment',
  CURRENT_DATE
);

-- But they're actually on monthly (no annual contract in reality)
