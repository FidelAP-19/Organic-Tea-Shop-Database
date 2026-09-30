-- =============================================================
-- Organic Tea Shop database
-- Quries and Transactions
-- =============================================================

USE organic_tea_shop;

-- Q1. Products at or below their reorder level, with suppliers and unit costs
SELECT p.product_id, p.product_name, p.stock_qty, p.reorder_level,
       s.supplier_name, sp.unit_cost
FROM product p
LEFT JOIN supplies sp ON sp.product_id = p.product_id
LEFT JOIN supplier s  ON s.supplier_id = sp.supplier_id
WHERE p.product_type <> 'Beverage'
  AND p.stock_qty <= p.reorder_level
ORDER BY p.product_name, sp.unit_cost;

-- Q2. Packaged teas by tea type and origin, showing which are organic
SELECT t.tea_type, t.origin_country, p.product_name, p.retail_price,
       IF(p.is_organic, 'Organic', 'Conventional') AS organic_status
FROM packaged_tea t
JOIN product p ON p.product_id = t.product_id
ORDER BY t.tea_type, t.origin_country;

-- Q3. Suppliers whose certificate is not Certified, or was last verified over 12 months ago (BR12)
SELECT s.supplier_name, c.nop_id, c.cert_status, c.last_verified_date
FROM supplier s
JOIN organic_certificate c ON c.supplier_id = s.supplier_id
WHERE c.cert_status <> 'Certified'
   OR c.last_verified_date < CURDATE() - INTERVAL 12 MONTH
ORDER BY c.last_verified_date;

-- Transactions

-- T1. Record a sale: order, items (trigger lowers stock), loyalty points (BR16: 1 point per whole dollar)
START TRANSACTION;
INSERT INTO customer_order (order_id, order_datetime, payment_method, customer_id, employee_id)
VALUES (5, '2026-09-04 10:10:00', 'Card', 3, 2);
INSERT INTO order_item (order_id, line_number, product_id, quantity, unit_price_at_sale, customizations) VALUES
(5, 1, 4, 1, 21.00, NULL),
(5, 2, 7, 1,  3.95, 'Extra hot');
UPDATE customer
SET loyalty_points = loyalty_points +
    (SELECT FLOOR(total_amount) FROM order_total WHERE order_id = 5)
WHERE customer_id = 3;
COMMIT;

-- T2. Record a supplier delivery: raise stock by the quantity received
UPDATE product SET stock_qty = stock_qty + 24 WHERE product_id = 2;

-- T3. Change a product's price and reorder level
UPDATE product SET retail_price = 17.00, reorder_level = 12 WHERE product_id = 2;