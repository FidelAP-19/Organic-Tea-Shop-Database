-- =============================================================
-- Organic Tea Shop database
-- Test data.
-- =============================================================

USE organic_tea_shop;

-- Suppliers 
INSERT INTO supplier (supplier_id, supplier_name, street, city, country, email) VALUES
(1, 'Green Valley Tea Wholesale', '120 Harbor St',   'Newark',     'USA',   'orders@greenvalleytea.example'),
(2, 'Darjeeling Hills Estate',    '4 Mirik Road',    'Darjeeling', 'India', 'sales@darjeelinghills.example'),
(3, 'Hangzhou Leaf Co.',          '88 Longjing Rd',  'Hangzhou',   'China', 'export@hangzhouleaf.example'),
(4, 'Brew and Pour Supply',       '9 Market Ave',    'Brooklyn',   'USA',   'hello@brewandpour.example');

INSERT INTO supplier_phone (supplier_id, phone) VALUES
(1, '973-555-0141'),
(1, '973-555-0142'),
(2, '+91-354-555-0100'),
(3, '+86-571-555-0199'),
(4, '718-555-0177');

-- Organic certificates 
INSERT INTO organic_certificate (nop_id, supplier_id, certifying_agent, cert_status, last_verified_date) VALUES
('8150001234', 1, 'Quality Certification Services', 'Certified',  '2026-03-15'),
('8150005678', 2, 'Control Union Certifications',   'Certified',  '2026-01-20'),
('8150009012', 3, 'Ecocert SA',                     'Certified',  '2025-06-30'),
('8150003456', 3, 'Ecocert SA',                     'Suspended',  '2024-11-02');

-- Products: packaged teas
INSERT INTO product (product_id, product_name, retail_price, stock_qty, reorder_level, is_organic, product_type) VALUES
(1, 'First Flush Darjeeling 100g', 18.50, 40, 10, TRUE, 'Packaged tea'),
(2, 'Dragon Well Green 100g',      16.00, 8,  10, TRUE, 'Packaged tea'),
(3, 'Chamomile Blossom 20 bags',    9.50, 25, 8,  TRUE, 'Packaged tea'),
(4, 'Tieguanyin Oolong 75g',       21.00, 12, 6,  TRUE, 'Packaged tea');

INSERT INTO packaged_tea (product_id, tea_type, origin_country) VALUES
(1, 'Black',  'India'),
(2, 'Green',  'China'),
(3, 'Herbal', 'Egypt'),
(4, 'Oolong', 'China');

-- Products: beverages 
INSERT INTO product (product_id, product_name, retail_price, stock_qty, reorder_level, is_organic, product_type) VALUES
(5, 'Hot Darjeeling 12 oz',   4.25, 0, 0, TRUE, 'Beverage'),
(6, 'Iced Dragon Well 16 oz', 4.75, 0, 0, TRUE, 'Beverage'),
(7, 'Hot Chamomile 12 oz',    3.95, 0, 0, TRUE, 'Beverage');

INSERT INTO beverage (product_id, serving_style, size_oz, tea_product_id) VALUES
(5, 'Hot',  12, 1),
(6, 'Iced', 16, 2),
(7, 'Hot',  12, 3);

-- Products: accessories 
INSERT INTO product (product_id, product_name, retail_price, stock_qty, reorder_level, is_organic, product_type) VALUES
(8, 'Glass Teapot 600 ml',     32.00, 6,  3, FALSE, 'Accessory'),
(9, 'Stainless Steel Infuser',  7.50, 30, 10, FALSE, 'Accessory');

INSERT INTO accessory (product_id, accessory_type) VALUES
(8, 'Teapot'),
(9, 'Infuser');

-- SUPPLIES (M:N) with agreed unit cost 
INSERT INTO supplies (supplier_id, product_id, unit_cost) VALUES
(1, 1, 10.20),
(2, 1,  9.40),
(1, 2,  9.10),
(3, 2,  8.30),
(1, 3,  4.60),
(3, 4, 11.75),
(4, 8, 15.00),
(4, 9,  2.90);

-- Customers
INSERT INTO customer (customer_id, first_name, last_name, email, loyalty_points) VALUES
(1, 'Maya',  'Torres', 'maya.t@example.com',  120),
(2, 'Daniel','Okafor', 'dokafor@example.com',  45),
(3, 'Lena',  'Park',   'lena.park@example.com', 0);

-- Employees 
INSERT INTO employee (employee_id, first_name, last_name, job_title, hourly_wage, supervisor_id) VALUES
(1, 'Rosa',  'Alvarez', 'Manager', 28.00, NULL),
(2, 'Kevin', 'Nguyen',  'Barista', 18.50, 1),
(3, 'Aisha', 'Bello',   'Cashier', 17.75, 1),
(4, 'Tom',   'Reyes',   'Barista', 18.00, 2);

-- Orders (order 3 is a walk-in with no customer)
INSERT INTO customer_order (order_id, order_datetime, payment_method, customer_id, employee_id) VALUES
(1, '2026-09-01 09:15:00', 'Card',   1,    2),
(2, '2026-09-01 12:40:00', 'Mobile', 2,    3),
(3, '2026-09-02 08:05:00', 'Cash',   NULL, 4),
(4, '2026-09-03 16:30:00', 'Card',   1,    3);

-- Order items: the trigger lowers stock for teas and accessories
INSERT INTO order_item (order_id, line_number, product_id, quantity, unit_price_at_sale, customizations) VALUES
(1, 1, 5, 1,  4.25, 'Oat milk'),
(1, 2, 1, 1, 18.50, NULL),
(2, 1, 6, 2,  4.75, 'Less ice'),
(2, 2, 9, 1,  7.50, NULL),
(3, 1, 7, 1,  3.95, 'Honey'),
(3, 2, 5, 1,  4.25, NULL),
(4, 1, 8, 1, 32.00, 'Gift wrap'),
(4, 2, 2, 2, 16.00, NULL),
(4, 3, 6, 1,  4.75, NULL);