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
	if not exists (select 1 from login where username = username_p and password = pwd_p) then
        signal sqlstate '45000' set message_text = "Invalid username or password";
    else
		select "successfully logged in";
	end if;
end$$
delimiter ;

-- add new order
DELIMITER $$
CREATE PROCEDURE new_order(
    IN orderDate DATE,
    IN custID INT,
    IN storeID INT,
    IN prodName VARCHAR(255),
    IN prodQuantity INT
)
BEGIN
    DECLARE newOrderID INT;
    DECLARE prodID INT;

    -- Find the product ID based on the product name
    SELECT product_id INTO prodID FROM product WHERE name = prodName LIMIT 1;

    -- Insert into orders table
    INSERT INTO orders(date, customer_id, store_id)
    VALUES (orderDate, custID, storeID);

    -- Get the ID of the newly inserted order
    SET newOrderID = LAST_INSERT_ID();

    -- Insert into order_products table
    INSERT INTO order_products(order_id, product_id, product_quantity)
    VALUES (newOrderID, prodID, prodQuantity);

    -- Check for successful insertion and return a message
    IF ROW_COUNT() > 0 THEN
        SELECT 'Successfully received a new order' AS message;
    ELSE
        SELECT 'Failed to receive new order' AS message;
    END IF;
END$$

DELIMITER ;

-- fill new order
DELIMITER $$

CREATE PROCEDURE fill_order(
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
    IN inputSupplierName VARCHAR(255),
    IN inputStoreID INT,
    IN inputProductName VARCHAR(255),
    IN inputQuantity INT,
    IN inputProductTypeName VARCHAR(255)
)
BEGIN
    DECLARE newProductID INT;
    DECLARE newProductTypeID INT;
    DECLARE existingProductID INT;
    DECLARE existingProductTypeID INT;

    -- Check for existing product type
    SELECT type_id INTO existingProductTypeID FROM product_type WHERE name = inputProductTypeName;
    IF existingProductTypeID IS NULL THEN
        -- Insert new product type
        INSERT INTO product_type(name) VALUES (inputProductTypeName);
        SET newProductTypeID = LAST_INSERT_ID();
    ELSE
        SET newProductTypeID = existingProductTypeID;
    END IF;

    -- Check for existing product
    SELECT product_id INTO existingProductID FROM product WHERE name = inputProductName;
    IF existingProductID IS NULL THEN
        -- Insert new product
        INSERT INTO product(name, type_id) VALUES (inputProductName, newProductTypeID);
        SET newProductID = LAST_INSERT_ID();
    ELSE
        SET newProductID = existingProductID;
    END IF;

    -- Update inventory
    IF existingProductID IS NOT NULL THEN
        -- Update existing product quantity
        UPDATE inventory SET quantity = quantity + inputQuantity WHERE store_id = inputStoreID AND product_id = existingProductID;
    ELSE
        -- Insert new product quantity
        INSERT INTO inventory(store_id, product_id, quantity) VALUES (inputStoreID, newProductID, inputQuantity);
    END IF;
    
    -- Return a success message
    SELECT 'successfully ordered products from the supplier' AS message;
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




