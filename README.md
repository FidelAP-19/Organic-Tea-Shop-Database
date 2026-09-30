# Organic Tea Shop Database

Fidel Perez

A MySQL database for a single-location organic tea shop. It tracks the products the shop sells (packaged teas, brewed beverages and accessories), the suppliers it buys from and their USDA organic certificates, customers and their orders, and the employees who process each sale.

## Repository contents

| File | What it is |
| --- | --- |
| `Organic_Tea_Shop_Fidel_Perez.docx` | Project report: requirements, users and roles, entities, design decisions |
| `chen_er_diagram.jpg` | Hand-drawn Chen-style ER diagram |
| `organic_tea_shop_uml.png` | UML-style ER diagram exported from MySQL Workbench |
| `organic_tea_shop.mwb` | MySQL Workbench model (tables, relationships, view, trigger, diagram) |
| `organic_tea_shop_build.sql` | Creates the database, 12 tables, the `order_total` view and the stock trigger |
| `organic_tea_shop_test_data.sql` | Inserts sample suppliers, products, customers, employees and orders |
| `organic_tea_shop_queries_transactions.sql` | Three queries and three transactions from the requirements |

## How to run

Run the scripts in MySQL Workbench (MySQL 8.0 or later), in this order:

1. `organic_tea_shop_build.sql`
2. `organic_tea_shop_test_data.sql`
3. `organic_tea_shop_queries_transactions.sql`

The build script starts with `DROP DATABASE IF EXISTS`, so running files 1 and 2 again resets everything.

## Design summary

- **10 entities:** PRODUCT (with subclasses PACKAGED_TEA, BEVERAGE and ACCESSORY), SUPPLIER, ORGANIC_CERTIFICATE, CUSTOMER, CUSTOMER_ORDER, ORDER_ITEM (weak entity) and EMPLOYEE
- **8 relationships:** SUPPLIES (M:N with unit cost), HOLDS, PLACES, PROCESSES, CONTAINS (identifying), FOR_PRODUCT, BREWED_FROM and SUPERVISES (recursive)
- **Mapped to 12 tables:** the multivalued supplier phone and the M:N SUPPLIES relationship each became their own table
- **Business rules enforced in SQL:** CHECK constraints (no negative stock, 10-digit certificate numbers, no employee supervising themselves), foreign keys, a view for the derived order total, and a trigger that lowers stock after each sale

## Sources

- Elmasri & Navathe, *Fundamentals of Database Systems*, Chapters 1–9
- World Tea News, 2025 State of the Tea Industry Survey
- Tea Association of the USA, Tea Fact Sheet 2024
- Organic Trade Association, Consumer Perception of USDA Organic (2025)
- USDA Agricultural Marketing Service, Strengthening Organic Enforcement FAQ
- Square point-of-sale documentation (vendor information, modifiers, item availability)
