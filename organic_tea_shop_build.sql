-- =============================================================
-- Organic Tea Shop database
-- CIS 344 Fall 2026, Individual Project
-- =============================================================

DROP DATABASE IF EXISTS organic_tea_shop;
CREATE DATABASE organic_tea_shop;
USE organic_tea_shop;

-- SUPPLIER
CREATE TABLE supplier (
    supplier_id    INT          NOT NULL AUTO_INCREMENT,
    supplier_name  VARCHAR(100) NOT NULL,
    street         VARCHAR(100),
    city           VARCHAR(60),
    country        VARCHAR(60),
    email          VARCHAR(100) UNIQUE,
    PRIMARY KEY (supplier_id)
);

CREATE TABLE supplier_phone (
    supplier_id  INT         NOT NULL,
    phone        VARCHAR(20) NOT NULL,
    PRIMARY KEY (supplier_id, phone),
    CONSTRAINT fk_phone_supplier FOREIGN KEY (supplier_id)
        REFERENCES supplier (supplier_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ORGANIC_CERTIFICATE 
CREATE TABLE organic_certificate (
    nop_id              CHAR(10)     NOT NULL,
    supplier_id         INT          NOT NULL,
    certifying_agent    VARCHAR(100) NOT NULL,
    cert_status         ENUM('Certified','Surrendered','Suspended','Revoked') NOT NULL DEFAULT 'Certified',
    last_verified_date  DATE         NOT NULL,
    PRIMARY KEY (nop_id),
    CONSTRAINT chk_nop_id_digits CHECK (nop_id REGEXP '^[0-9]{10}$'),
    CONSTRAINT fk_cert_supplier FOREIGN KEY (supplier_id)
        REFERENCES supplier (supplier_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- PRODUCT 

CREATE TABLE product (
    product_id     INT           NOT NULL AUTO_INCREMENT,
    product_name   VARCHAR(100)  NOT NULL,
    retail_price   DECIMAL(8,2)  NOT NULL,
    stock_qty      INT           NOT NULL DEFAULT 0,
    reorder_level  INT           NOT NULL DEFAULT 0,
    is_organic     BOOLEAN       NOT NULL DEFAULT FALSE,
    product_type   ENUM('Packaged tea','Beverage','Accessory') NOT NULL,
    PRIMARY KEY (product_id),
    CONSTRAINT chk_price_positive CHECK (retail_price > 0),
    CONSTRAINT chk_stock_nonneg   CHECK (stock_qty >= 0),
    CONSTRAINT chk_reorder_nonneg CHECK (reorder_level >= 0)
);

CREATE TABLE packaged_tea (
    product_id      INT         NOT NULL,
    tea_type        ENUM('Black','Green','Oolong','White','Dark','Herbal') NOT NULL,
    origin_country  VARCHAR(60) NOT NULL,
    PRIMARY KEY (product_id),
    CONSTRAINT fk_tea_product FOREIGN KEY (product_id)
        REFERENCES product (product_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- BREWED_FROM 

CREATE TABLE beverage (
    product_id      INT NOT NULL,
    serving_style   ENUM('Hot','Iced') NOT NULL,
    size_oz         INT NOT NULL,
    tea_product_id  INT NOT NULL,
    PRIMARY KEY (product_id),
    CONSTRAINT chk_size_positive CHECK (size_oz > 0),
    CONSTRAINT fk_beverage_product FOREIGN KEY (product_id)
        REFERENCES product (product_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_beverage_tea FOREIGN KEY (tea_product_id)
        REFERENCES packaged_tea (product_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE accessory (
    product_id      INT NOT NULL,
    accessory_type  ENUM('Teapot','Infuser','Cup','Gift set') NOT NULL,
    PRIMARY KEY (product_id),
    CONSTRAINT fk_accessory_product FOREIGN KEY (product_id)
        REFERENCES product (product_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- SUPPLIES 

CREATE TABLE supplies (
    supplier_id  INT          NOT NULL,
    product_id   INT          NOT NULL,
    unit_cost    DECIMAL(8,2) NOT NULL,
    PRIMARY KEY (supplier_id, product_id),
    CONSTRAINT chk_cost_positive CHECK (unit_cost > 0),
    CONSTRAINT fk_supplies_supplier FOREIGN KEY (supplier_id)
        REFERENCES supplier (supplier_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_supplies_product FOREIGN KEY (product_id)
        REFERENCES product (product_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- CUSTOMER 
CREATE TABLE customer (
    customer_id     INT          NOT NULL AUTO_INCREMENT,
    first_name      VARCHAR(50)  NOT NULL,
    last_name       VARCHAR(50)  NOT NULL,
    email           VARCHAR(100) UNIQUE,
    loyalty_points  INT          NOT NULL DEFAULT 0,
    PRIMARY KEY (customer_id),
    CONSTRAINT chk_points_nonneg CHECK (loyalty_points >= 0)
);


-- EMPLOYEE  

CREATE TABLE employee (
    employee_id    INT          NOT NULL,
    first_name     VARCHAR(50)  NOT NULL,
    last_name      VARCHAR(50)  NOT NULL,
    job_title      ENUM('Manager','Barista','Cashier') NOT NULL,
    hourly_wage    DECIMAL(6,2) NOT NULL,
    supervisor_id  INT          NULL,
    PRIMARY KEY (employee_id),
    CONSTRAINT chk_wage_positive  CHECK (hourly_wage > 0),
    CONSTRAINT chk_not_own_supervisor CHECK (supervisor_id IS NULL OR supervisor_id <> employee_id),
    CONSTRAINT fk_employee_supervisor FOREIGN KEY (supervisor_id)
        REFERENCES employee (employee_id)
);

-- CUSTOMER_ORDER  (ORDER is a reserved word, so customer_order)
-- PLACES: optional customer (walk-ins).  PROCESSES: required employee.

CREATE TABLE customer_order (
    order_id        INT      NOT NULL AUTO_INCREMENT,
    order_datetime  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payment_method  ENUM('Cash','Card','Mobile') NOT NULL,
    customer_id     INT      NULL,
    employee_id     INT      NOT NULL,
    PRIMARY KEY (order_id),
    CONSTRAINT fk_order_customer FOREIGN KEY (customer_id)
        REFERENCES customer (customer_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_order_employee FOREIGN KEY (employee_id)
        REFERENCES employee (employee_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ORDER_ITEM  

CREATE TABLE order_item (
    order_id            INT          NOT NULL,
    line_number         INT          NOT NULL,
    product_id          INT          NOT NULL,
    quantity            INT          NOT NULL,
    unit_price_at_sale  DECIMAL(8,2) NOT NULL,
    customizations      VARCHAR(150),
    PRIMARY KEY (order_id, line_number),
    CONSTRAINT chk_qty_positive       CHECK (quantity > 0),
    CONSTRAINT chk_sale_price_positive CHECK (unit_price_at_sale > 0),
    CONSTRAINT fk_item_order FOREIGN KEY (order_id)
        REFERENCES customer_order (order_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_item_product FOREIGN KEY (product_id)
        REFERENCES product (product_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Derived attribute TotalAmount: calculated, not stored

CREATE VIEW order_total AS
SELECT o.order_id,
       o.order_datetime,
       SUM(i.quantity * i.unit_price_at_sale) AS total_amount
FROM customer_order o
JOIN order_item i ON i.order_id = o.order_id
GROUP BY o.order_id, o.order_datetime;

DELIMITER $$
CREATE TRIGGER trg_order_item_reduce_stock
AFTER INSERT ON order_item
FOR EACH ROW
BEGIN
    UPDATE product
    SET stock_qty = stock_qty - NEW.quantity
    WHERE product_id = NEW.product_id
      AND product_type <> 'Beverage';
END$$
DELIMITER ;
