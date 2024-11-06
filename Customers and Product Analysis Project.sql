/*The database contains eight tables:

-Offices: contains sales office information.
-Customers: contains customer data.
-Employees: contains all employee information.
-Payments: contains customers' payment records.
-Orders: contains customers' sales orders.
-OrderDetails: contains sales order line for each sales order.
-Products: contains a list of scale model cars.
-ProductLines: contains a list of product line categories.

DATA RELATIONSHIPS

Customers and orders connected by (customerNumber).
Orders and orderdetails connected by (orderNumber).
Products and orderdetails connected by (productCode).
Products and productlines connected by (productLine).
Customers and payments connected by (customerNumber).
Employees  table  self reference itself for attributes employeeNumber and reportsTo.
Employees and offices connected by (officeCode).
Customers and employees connected by (employeeNumber = salesRepEmployeeNumber).*/

--Table descriptions and links in the database 

SELECT 'Customers' AS table_name, 
       13 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM Customers
  
UNION ALL

SELECT 'Products' AS table_name, 
       9 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM Products

UNION ALL

SELECT 'ProductLines' AS table_name, 
       4 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM ProductLines

UNION ALL

SELECT 'Orders' AS table_name, 
       7 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM Orders

UNION ALL

SELECT 'OrderDetails' AS table_name, 
       5 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM OrderDetails

UNION ALL

SELECT 'Payments' AS table_name, 
       4 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM Payments

UNION ALL

SELECT 'Employees' AS table_name, 
       8 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM Employees

UNION ALL

SELECT 'Offices' AS table_name, 
       9 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM Offices;

--Low stock for each product 

SELECT productCode, 
       ROUND(SUM(quantityOrdered) * 1.0 / (SELECT quantityInStock
                                             FROM products p
                                            WHERE od.productCode = p.productCode), 2) AS low_stock
  FROM orderdetails od
 GROUP BY productCode
 ORDER BY low_stock DESC
 LIMIT 10;
 
 --Products to order more or less of
 
 WITH 

low_stock_table AS (
SELECT productCode, 
       ROUND(SUM(quantityOrdered) * 1.0/(SELECT quantityInStock
                                           FROM products p
                                          WHERE od.productCode = p.productCode), 2) AS low_stock
  FROM orderdetails od
 GROUP BY productCode
 ORDER BY low_stock DESC
 LIMIT 10
),

products_to_restock AS (
SELECT productCode, 
       SUM(quantityOrdered * priceEach) AS prod_perf
  FROM orderdetails od
 WHERE productCode IN (SELECT productCode
                         FROM low_stock_table)
 GROUP BY productCode 
 ORDER BY prod_perf DESC
 LIMIT 10
)
    
SELECT productName, productLine
  FROM products AS p
 WHERE productCode IN (SELECT productCode
                         FROM products_to_restock);
					
--Profit by customer

 SELECT o.CustomerNumber, SUM(quantityOrdered * (priceEach - buyPrice)) AS Profit
  FROM products p
  JOIN orderdetails od
    ON p.productCode = od.productCode
  JOIN orders o
    ON o.orderNumber = od.orderNumber
 GROUP BY o.customerNumber
 ORDER BY profit DESC;
 
 --Top five VIP customers
 
 WITH 

money_in_by_customer_table AS (
SELECT o.customerNumber, SUM(quantityOrdered * (priceEach - buyPrice)) AS revenue
  FROM products p
  JOIN orderdetails od
    ON p.productCode = od.productCode
  JOIN orders o
    ON o.orderNumber = od.orderNumber
 GROUP BY o.customerNumber
)

SELECT contactLastName, contactFirstName, city, country, mc.revenue
  FROM customers c
  JOIN money_in_by_customer_table mc
    ON mc.customerNumber = c.customerNumber
 ORDER BY mc.revenue DESC
 LIMIT 5;
 
 --Top 5 least-engaged Customers 
 
 WITH 

money_in_by_customer_table AS (
SELECT o.customerNumber, SUM(quantityOrdered * (priceEach - buyPrice)) AS revenue
  FROM products p
  JOIN orderdetails od
    ON p.productCode = od.productCode
  JOIN orders o
    ON o.orderNumber = od.orderNumber
 GROUP BY o.customerNumber
)

SELECT contactLastName, contactFirstName, city, country, mc.revenue
  FROM customers c
  JOIN money_in_by_customer_table mc
    ON mc.customerNumber = c.customerNumber
 ORDER BY mc.revenue
 LIMIT 5;
 
 --Product Performance

SELECT productCode, 
       SUM(quantityOrdered * priceEach) AS prod_perf
  FROM orderdetails od
 GROUP BY productCode 
 ORDER BY prod_perf DESC
 LIMIT 10;
 
 --Customer Lifetime Value(CLV)
 
 WITH 

money_in_by_customer_table AS (
SELECT o.customerNumber, SUM(quantityOrdered * (priceEach - buyPrice)) AS revenue
  FROM products p
  JOIN orderdetails od
    ON p.productCode = od.productCode
  JOIN orders o
    ON o.orderNumber = od.orderNumber
 GROUP BY o.customerNumber
)

SELECT AVG(mc.revenue) AS ltv
  FROM money_in_by_customer_table mc;
  
  
/*
Conclusion:
We identified vintage cars and motorcycles as priority items for restocking due to their frequent sales and high performance. 
This suggests that increasing the inventory of these products could maximize profit and meet consumer demand more effectively. 
On the other hand, products like ships and planes may require less emphasis based on their lower sales volume.

To better align marketing and communication strategies with customer behavior, we distinguished our VIP customers, who contribute significantly to profits, from those who are less engaged. 
This insight allows us to target VIPs with loyalty programs, exclusive offers, and personalized communication to maintain their high engagement levels, while also creating strategies to incentivize and re-engage less committed customers. 
Additionally, with an average lifetime value (LTV) of $39,039.59 per customer, we have a predictive tool to estimate potential profits and make informed decisions on customer acquisition costs to optimize returns.*/