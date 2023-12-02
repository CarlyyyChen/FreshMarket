use fresh_market_db;

-- register new user
delimiter $$
create procedure new_user(username_p varchar(30), pwd_p varchar(30))
begin
	declare duplicate_entry_for_key boolean default false;
    begin
		declare exit handler for 1062
			set duplicate_entry_for_key = true;
			insert into user_info(user_name, pwd) values (username_p, pwd_p);
			select "User created, please login";
	end;
	if(duplicate_entry_for_key = true) then 
		select "Username already exists";
		signal sqlstate '23000' set message_text = "duplicated key";
	end if;
end$$
delimiter ;

-- login
delimiter $$
create procedure login(username_p varchar(30), pwd_p varchar(30))
begin
	if not exists (select 1 from login where name = username_p and password = pwd_p) then
        signal sqlstate '45000' set message_text = "Invalid username or password";
    else
		select "successfully logged in";
	end if;
end$$
delimiter ;

-- add new order
DELIMITER $$

CREATE PROCEDURE new_order(
    IN orderID INT,
    IN orderDate DATE,
    IN custID INT,
    IN storeID INT,
    IN prodName VARCHAR(255),
    IN prodQuantity INT,
    OUT message VARCHAR(255)
)
BEGIN
    DECLARE existingOrder INT;
    DECLARE prodID INT;
    
    -- Check if the orderID exists
    SELECT COUNT(*) INTO existingOrder FROM orders WHERE order_id = orderID;

    -- If order does not exist, insert a new order
    IF existingOrder = 0 THEN
        INSERT INTO orders(order_id, date, status, customer_id, store_id) 
        VALUES (orderID, orderDate, 'new', custID, storeID);
    END IF;

    -- Get product_id from product name
    SELECT product_id INTO prodID FROM product WHERE name = prodName;

    -- Check if product exists
    IF prodID IS NOT NULL THEN
        -- Insert into order_products table
        INSERT INTO order_products(order_id, product_id, product_quantity) 
        VALUES (orderID, prodID, prodQuantity)
        ON DUPLICATE KEY UPDATE product_quantity = product_quantity + prodQuantity;

        SET message = 'Successfully received a new order';
    ELSE
        SET message = 'Failed to receive new order';
    END IF;
END$$

DELIMITER ;

-- fill new order
DELIMITER $$

CREATE PROCEDURE prepare_order(
    IN inputOrderID INT
)
BEGIN
    DECLARE v_storeID INT;
    DECLARE v_productID INT;
    DECLARE v_quantity INT;
    DECLARE currentInventory INT;  -- Moved this declaration here
    DECLARE notEnoughInventory BOOLEAN DEFAULT FALSE;
    DECLARE done INT DEFAULT FALSE;

    -- Declare cursor
    DECLARE product_cursor CURSOR FOR 
        SELECT product_id, product_quantity 
        FROM order_products 
        WHERE order_id = inputOrderID;

    -- Declare CONTINUE HANDLER
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Get store ID from the orders table
    SELECT store_id INTO v_storeID FROM orders WHERE order_id = inputOrderID;

    OPEN product_cursor;

    product_loop: LOOP
        FETCH product_cursor INTO v_productID, v_quantity;
        
        -- Check if the loop is done
        IF done THEN
            LEAVE product_loop;
        END IF;

        -- Check inventory for each product
        SELECT quantity INTO currentInventory FROM inventory WHERE store_id = v_storeID AND product_id = v_productID;

        -- Check if enough inventory is available
        IF currentInventory < v_quantity THEN
            SET notEnoughInventory = TRUE;
            LEAVE product_loop;
        END IF;

        -- Update inventory
        UPDATE inventory SET quantity = quantity - v_quantity WHERE store_id = v_storeID AND product_id = v_productID;
    END LOOP;

    CLOSE product_cursor;

    -- Check if the order was successfully processed
    IF notEnoughInventory THEN
        SELECT 'not enough inventory' AS message;
    ELSE
        -- Update order status to 'filled'
        UPDATE orders SET status = 'filled' WHERE order_id = inputOrderID;
        SELECT 'successfully filled the order' AS message;
    END IF;
END$$

DELIMITER ;

-- assign delivery
DELIMITER $$

CREATE PROCEDURE assign_delivery(
    IN inputTruckID VARCHAR(255),
    IN inputOrderID INT
)
BEGIN
    -- Update order status to 'complete'
    UPDATE orders SET status = 'complete' WHERE order_id = inputOrderID;

    -- Add a new row to the delivery table
    INSERT INTO delivery(order_id, truck_id)
    VALUES (inputOrderID, inputTruckID);

    -- Set the truck availability to 'No'
    UPDATE freight_truck SET availability = FALSE WHERE license_plate = inputTruckID;

    -- Return a success message
    SELECT 'successfully assigned delivery for the order' AS message;
END$$

DELIMITER ;

-- order from supplier
DELIMITER $$

CREATE PROCEDURE order_from_supplier(
    IN inputSupplierID INT,
    IN inputStoreID INT,
    IN inputProductName VARCHAR(255),
    IN inputQuantity INT,
    IN inputProductTypeName VARCHAR(255)
)
BEGIN
    DECLARE typeID INT;
    DECLARE productID INT;
    DECLARE currentQuantity INT;
    DECLARE newQuantity INT;
    
    -- Get product type id
    SELECT type_id into typeID
    FROM product_type
    WHERE name = inputProductTypeName;

    -- Get product_id for the input product name
    SELECT product_id INTO productID
    FROM product
    WHERE product_name = inputProductName;

    -- Check if the supplier can supply the product to the store
    IF EXISTS (SELECT * 
               FROM store_suppliers
               WHERE store_id = inputStoreID AND supplier_id = inputSupplierID AND product_id = productID) THEN

        -- Check if the product already exists in the inventory for the store
        SELECT quantity INTO currentQuantity
        FROM inventory
        WHERE store_id = inputStoreID AND product_id = productID;

        IF currentQuantity IS NOT NULL THEN
            -- Update the quantity if the product already exists
            SET newQuantity = currentQuantity + inputQuantity;
            UPDATE inventory
            SET quantity = newQuantity
            WHERE store_id = inputStoreID AND product_id = productID;
        ELSE
            -- Insert new record if the product does not exist in the inventory
            INSERT INTO inventory(store_id, product_id, quantity)
            VALUES (inputStoreID, productID, inputQuantity);
        END IF;
        -- Return a success message
		SELECT 'successfully assigned delivery for the order' AS message;
    ELSE
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Supplier cannot supply the specified product to this store.';
    END IF;
END$$

DELIMITER ;

-- register new customer
DELIMITER $$

CREATE PROCEDURE register_new_customer(
    IN inputFirstName VARCHAR(255),
    IN inputLastName VARCHAR(255),
    IN inputAddress VARCHAR(255),
    IN inputCreditCardNumber VARCHAR(255),
    IN inputBirthday DATE
)
BEGIN
    -- Insert new customer into the customer table
    INSERT INTO customer(first_name, last_name, address, payment_info, birthday)
    VALUES (inputFirstName, inputLastName, inputAddress, inputCreditCardNumber, inputBirthday);

    -- Return success message
    SELECT 'successfully registered a new customer' AS message;
END$$

DELIMITER ;

-- customer feedback
DELIMITER $$

CREATE PROCEDURE add_feedback(
    IN inputFirstName VARCHAR(255),
    IN inputLastName VARCHAR(255),
    IN inputOrderID INT,
    IN inputRating INT,
    IN inputReview TEXT,
    IN inputDate DATE
)
BEGIN
    DECLARE inputCustomerID INT;

    -- Retrieve customer ID based on the name
    SELECT customer_id INTO inputCustomerID 
    FROM customer 
    WHERE first_name = inputFirstName AND last_name = inputLastName;

    -- Insert new feedback into the feedback table
    INSERT INTO feedback(customer_id, order_id, rating, review, date)
    VALUES (inputCustomerID, inputOrderID, inputRating, inputReview, inputDate);

    -- Return success message
    SELECT 'successfully received new feedback' AS message;
END$$

DELIMITER ;

-- launch promotion
DELIMITER $$

CREATE PROCEDURE launch_promotion(
    IN inputPromotionName VARCHAR(255),
    IN inputStartDate DATE,
    IN inputEndDate DATE,
    IN inputDiscount DECIMAL(5, 2)
)
BEGIN
    -- Add new row to promotion table
    INSERT INTO promotion(name, start_date, end_date, discount)
    VALUES (inputPromotionName, inputStartDate, inputEndDate, inputDiscount);

    -- Update all prices in product table
    UPDATE product
    SET price = price - (price * inputDiscount);

    -- Return success message
    SELECT 'successfully launched promotion' AS message;
END$$

DELIMITER ;

-- manage employee salary
DELIMITER $$

CREATE PROCEDURE manage_salary(
    IN inputStaffID INT,
    IN inputSalary DECIMAL(10, 2)
)
BEGIN
    -- Update employee's salary in the employee table
    UPDATE employee
    SET salary = inputSalary
    WHERE staff_id = inputStaffID;

    -- Return success message
    SELECT 'successfully updated employee salary' AS message;
END$$

DELIMITER ;

-- retire (delete) an employee
DELIMITER $$

CREATE PROCEDURE retire_employee(
    IN inputStaffID INT
)
BEGIN
    -- Check if the employee is a manager
    IF EXISTS (SELECT * FROM manager WHERE staff_id = inputStaffID) THEN
        -- Delete the employee from the manager table
        DELETE FROM manager WHERE staff_id = inputStaffID;
    END IF;

    -- Delete the employee from the employee table
    DELETE FROM employee WHERE staff_id = inputStaffID;
END$$

DELIMITER ;


-- bonus: display all products and quantities in different stores under different types 
DELIMITER $$

CREATE PROCEDURE display_products_by_type()
BEGIN
    SELECT pt.name AS Product_Type, p.name AS Product, i.store_id, i.quantity
    FROM inventory i
    INNER JOIN product p ON i.product_id = p.product_id
    INNER JOIN product_type pt ON p.type_id = pt.type_id
    ORDER BY pt.name, p.name, i.store_id;
END$$

DELIMITER ;




