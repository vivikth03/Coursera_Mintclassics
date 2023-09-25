-- 1.Where are items stored and could a warehouse be eliminated?
-- To identify where items are stored and assess the potential for eliminating a warehouse, you can use SQL to group items by their storage location and count the number of items in each location. 
-- You can then analyze if there are any locations with very low inventory counts that may be candidates for consolidation or elimination.

SELECT 
	SUM(p.quantityInStock) AS total_quantitystock,
    w.warehouseCode,
    w.warehousePctCap,
    w.warehouseName
FROM
	products p
INNER JOIN
	warehouses w ON p.warehouseCode = w.warehouseCode
GROUP BY 
	warehouseCode
ORDER BY
	total_quantitystock DESC
    
-- different product lines stored in west and south warehouses

SELECT
	warehouseCode, quantityInStock, productLine
FROM 
	products
WHERE warehouseCode = 'd'
OR warehouseCode = 'c'
ORDER BY warehouseCode

-- 2.How are inventory numbers related to sales figures? Do inventory counts seem appropriate for each item?
-- To assess the relationship between inventory numbers and sales figures, you can compare the total inventory count of each item to its sales history. 

SELECT 
    p.productLine, SUM(o.priceEach * o.quantityOrdered) AS sales
FROM
    mintclassics.orderdetails AS o
JOIN
    mintclassics.products AS p ON o.productCode = p.productCode

GROUP BY p.productLine
ORDER BY sales DESC;

-- product details and finding which product to eliminate
-- You can then suggest reducing inventory for items with low sales-to-inventory ratios.

SELECT
p.productCode,
p.productName,
p.quantityInStock,
p.productLine,
SUM(od.quantityOrdered) AS totalOrderedQuantity,
AVG (od.quantityOrdered) AS avgOrderedQuantity,
MAX(od.quantityOrdered) AS LargestQuantityOrdered,
MIN(od.quantityOrdered) AS SmallestQuantityOrdered
FROM
products p
JOIN
orderdetails od ON od.productCode = p.productCode
WHERE productLine = 'Vintage Cars'
OR productLine = 'Ships'
OR productLine = 'Trucks and Buses'
GROUP BY p.productCode , p.productName , p.quantityInStock
ORDER BY totalOrderedQuantity ASC;

SELECT 
    p.productName,
    p.productLine,
    SUM(o.priceEach * o.quantityOrdered) AS sales
FROM
    mintclassics.orderdetails AS o
        JOIN
    mintclassics.products AS p ON o.productCode = p.productCode
WHERE
    p.productLine IN ('Trains' , 'Ships', 'Trucks and Buses')
GROUP BY p.productCode
ORDER BY sales
LIMIT 10;

-- 3.Are we storing items that are not moving? Are any items candidates for being dropped from the product line?
-- To identify items that are not selling (i.e., candidates for removal from the product line), you can look at items with zero sales over a specified period. 
-- You can use the following query as a starting point:

SELECT 
	p.productCode, p.productName, p.productLine, SUM(o.priceEach * o.quantityOrdered) AS sales
FROM
    mintclassics.orderdetails AS o
RIGHT JOIN
    mintclassics.products AS p ON o.productCode = p.productCode
GROUP BY p.productCode;