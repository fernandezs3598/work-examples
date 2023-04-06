/*Find the name of manager of the Miami store.*/

SELECT E.name
FROM employees E
WHERE E.StoreID = 2
AND E.position = 'Manager';

/*Find the names, brands, and prices of all the items in the category Breakfast from the Winter Park store.*/

SELECT I.Item_name, I.Brand, S.Price
FROM items I, stocks S
WHERE I.Item_number = S.Item_number
AND S.StoreID = 3
AND I.Category = 'Breakfast';

/*Find the store selling milk for the cheapest price, and the price of the milk, assuming milk is in stock.*/

SELECT S.StoreID, MIN(S.Price)
FROM items I, stocks S
WHERE I.Item_number = S.Item_number
AND I.Item_name = 'Milk'
AND S.Quantity > 0;

/*Find the IDs of the items, and their stores, that need to be restocked (Quantity < 10), along with the quantity of the item left.*/

SELECT S.StoreID, S.Item_number, S.Quantity
FROM stocks S
WHERE S.Quantity < 10;

/*Find the names and emails of all the return customers (customers who have made more than one purchase), and the total amount of money they’ve spent.*/

SELECT C.name, C.Email_address, COUNT(P.Payment_number), SUM(P.Payment_amount)
FROM customers C, payments P
WHERE C.Email_address = P.Email_address
GROUP BY P.Email_address
HAVING COUNT(P.Payment_number) > 1;
