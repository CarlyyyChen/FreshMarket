create database fresh_market_db;
use fresh_market_db;

CREATE TABLE login(
	name varchar(30) PRIMARY KEY,
    password varchar(30) NOT NULL
);

Insert into login(name, password) values("user1","111111");
Insert into login(name, password) values("user2","222222");

CREATE TABLE product_type (
  type_id INT PRIMARY KEY,
  name VARCHAR(255) unique,
  unit VARCHAR(255)
);

Insert into product_type(type_id, name, unit) values("1","Produce","lb");
Insert into product_type(type_id, name, unit) values("2","Meat","lb");
Insert into product_type(type_id, name, unit) values("3","Seafood","lb");
Insert into product_type(type_id, name, unit) values("4","Deli","box");
Insert into product_type(type_id, name, unit) values("5","Dairy","box");
Insert into product_type(type_id, name, unit) values("6","Beverage","bottle");
Insert into product_type(type_id, name, unit) values("7","Bakery","box");

CREATE TABLE supplier (
  supplier_id INT PRIMARY KEY,
  street_number INT,
  street_name VARCHAR(255),
  state_abbreviation VARCHAR(2),
  zip_code VARCHAR(10)
);

Insert into supplier(supplier_id, street_number, street_name, state_abbreviation, zip_code) values("1","20","Central St","MA","02215");
Insert into supplier(supplier_id, street_number, street_name, state_abbreviation, zip_code) values("2","100","Brighton Street","MA","02149");
Insert into supplier(supplier_id, street_number, street_name, state_abbreviation, zip_code) values("3","3","Park Street","NY","10016");

CREATE TABLE product (
  product_id INT PRIMARY KEY,
  name VARCHAR(255) UNIQUE,
  price DECIMAL(10, 2),
  type_id INT,
  FOREIGN KEY (type_id) REFERENCES product_type(type_id) ON UPDATE CASCADE ON DELETE RESTRICT
);

Insert into product(product_id, name, price, type_id) values("1", "Lettuce", "3.99","1");
Insert into product(product_id, name, price, type_id) values("2", "Brown Egg", "3.99","1");
Insert into product(product_id, name, price, type_id) values("3", "White Egg", "3.99","1");
Insert into product(product_id, name, price, type_id) values("4", "Pork", "6.99","2");
Insert into product(product_id, name, price, type_id) values("5", "Beef", "9.99","2");
Insert into product(product_id, name, price, type_id) values("6", "Shrimp", "7.99","3");
Insert into product(product_id, name, price, type_id) values("7", "Crab", "6.99","3");
Insert into product(product_id, name, price, type_id) values("8", "Fish", "5.99","3");
Insert into product(product_id, name, price, type_id) values("9", "Pizza", "4.99","4");
Insert into product(product_id, name, price, type_id) values("10", "Sushi", "5.99","4");
Insert into product(product_id, name, price, type_id) values("11", "Whole Milk", "4.99","5");
Insert into product(product_id, name, price, type_id) values("12", "2% Milk", "4.99","5");
Insert into product(product_id, name, price, type_id) values("13", "Apple Juice", "3.99","6");
Insert into product(product_id, name, price, type_id) values("14", "Orange Juice", "3.99","6");
Insert into product(product_id, name, price, type_id) values("15", "Beer", "4.99","6");
Insert into product(product_id, name, price, type_id) values("16", "Croissant", "3.99","7");
Insert into product(product_id, name, price, type_id) values("17", "Cheese Cake", "4.50","7");
Insert into product(product_id, name, price, type_id) values("18", "Toast", "3.99","7");

CREATE TABLE store (
  store_id INT PRIMARY KEY,
  street_number INT,
  street_name VARCHAR(255),
  state_abbreviation VARCHAR(2),
  zip_code VARCHAR(10)
);

Insert into store (store_id, street_number, street_name, state_abbreviation, zip_code) values ("1","200","Exchange Street","MA","02150");
Insert into store (store_id, street_number, street_name, state_abbreviation, zip_code) values ("2","1","Summer Street","MA","02100");
Insert into store (store_id, street_number, street_name, state_abbreviation, zip_code) values ("3","7","Diamond Street","NY","10220");

CREATE TABLE store_suppliers(
	store_id INT NOT NULL,
    supplier_id INT NOT NULL,
    product_id INT NOT NULL,
	PRIMARY KEY (store_id, supplier_id, product_id),
    FOREIGN KEY (store_id) REFERENCES store(store_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (supplier_id) REFERENCES supplier(supplier_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (product_id) REFERENCES product(product_id) ON UPDATE CASCADE ON DELETE RESTRICT
);

Insert into store_suppliers(store_id, supplier_id, product_id) values("1","1","1");
Insert into store_suppliers(store_id, supplier_id, product_id) values("1","1","2");
Insert into store_suppliers(store_id, supplier_id, product_id) values("1","1","3");
Insert into store_suppliers(store_id, supplier_id, product_id) values("1","1","4");
Insert into store_suppliers(store_id, supplier_id, product_id) values("1","1","5");
Insert into store_suppliers(store_id, supplier_id, product_id) values("1","1","6");
Insert into store_suppliers(store_id, supplier_id, product_id) values("1","1","7");
Insert into store_suppliers(store_id, supplier_id, product_id) values("1","1","8");
Insert into store_suppliers(store_id, supplier_id, product_id) values("1","1","9");
Insert into store_suppliers(store_id, supplier_id, product_id) values("1","1","10");
Insert into store_suppliers(store_id, supplier_id, product_id) values("1","2","11");
Insert into store_suppliers(store_id, supplier_id, product_id) values("1","2","12");
Insert into store_suppliers(store_id, supplier_id, product_id) values("1","2","13");
Insert into store_suppliers(store_id, supplier_id, product_id) values("1","2","14");
Insert into store_suppliers(store_id, supplier_id, product_id) values("1","2","15");
Insert into store_suppliers(store_id, supplier_id, product_id) values("1","2","16");
Insert into store_suppliers(store_id, supplier_id, product_id) values("1","2","17");
Insert into store_suppliers(store_id, supplier_id, product_id) values("1","2","18");

Insert into store_suppliers(store_id, supplier_id, product_id) values("2","1","1");
Insert into store_suppliers(store_id, supplier_id, product_id) values("2","1","2");
Insert into store_suppliers(store_id, supplier_id, product_id) values("2","1","3");
Insert into store_suppliers(store_id, supplier_id, product_id) values("2","1","4");
Insert into store_suppliers(store_id, supplier_id, product_id) values("2","1","5");
Insert into store_suppliers(store_id, supplier_id, product_id) values("2","1","6");
Insert into store_suppliers(store_id, supplier_id, product_id) values("2","1","7");
Insert into store_suppliers(store_id, supplier_id, product_id) values("2","1","8");
Insert into store_suppliers(store_id, supplier_id, product_id) values("2","1","9");
Insert into store_suppliers(store_id, supplier_id, product_id) values("2","1","10");
Insert into store_suppliers(store_id, supplier_id, product_id) values("2","2","11");
Insert into store_suppliers(store_id, supplier_id, product_id) values("2","2","12");
Insert into store_suppliers(store_id, supplier_id, product_id) values("2","2","13");
Insert into store_suppliers(store_id, supplier_id, product_id) values("2","2","14");
Insert into store_suppliers(store_id, supplier_id, product_id) values("2","2","15");
Insert into store_suppliers(store_id, supplier_id, product_id) values("2","2","16");
Insert into store_suppliers(store_id, supplier_id, product_id) values("2","2","17");
Insert into store_suppliers(store_id, supplier_id, product_id) values("2","2","18");

Insert into store_suppliers(store_id, supplier_id, product_id) values("3","3","1");
Insert into store_suppliers(store_id, supplier_id, product_id) values("3","3","2");
Insert into store_suppliers(store_id, supplier_id, product_id) values("3","3","3");
Insert into store_suppliers(store_id, supplier_id, product_id) values("3","3","4");
Insert into store_suppliers(store_id, supplier_id, product_id) values("3","3","5");
Insert into store_suppliers(store_id, supplier_id, product_id) values("3","3","6");
Insert into store_suppliers(store_id, supplier_id, product_id) values("3","3","7");
Insert into store_suppliers(store_id, supplier_id, product_id) values("3","3","8");
Insert into store_suppliers(store_id, supplier_id, product_id) values("3","3","9");
Insert into store_suppliers(store_id, supplier_id, product_id) values("3","3","10");
Insert into store_suppliers(store_id, supplier_id, product_id) values("3","3","11");
Insert into store_suppliers(store_id, supplier_id, product_id) values("3","3","12");
Insert into store_suppliers(store_id, supplier_id, product_id) values("3","3","13");
Insert into store_suppliers(store_id, supplier_id, product_id) values("3","3","14");
Insert into store_suppliers(store_id, supplier_id, product_id) values("3","3","15");
Insert into store_suppliers(store_id, supplier_id, product_id) values("3","3","16");
Insert into store_suppliers(store_id, supplier_id, product_id) values("3","3","17");
Insert into store_suppliers(store_id, supplier_id, product_id) values("3","3","18");

CREATE TABLE inventory(
  store_id INT,
  product_id INT,
  quantity INT,
  PRIMARY KEY (store_id, product_id),
  FOREIGN KEY (store_id) REFERENCES store(store_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY (product_id) REFERENCES product(product_id) ON UPDATE CASCADE ON DELETE RESTRICT
);

Insert into inventory(store_id, product_id,quantity) values("1","1","100");
Insert into inventory(store_id, product_id,quantity) values("1","2","200");
Insert into inventory(store_id, product_id,quantity) values("1","3","50");
Insert into inventory(store_id, product_id,quantity) values("1","4","100");
Insert into inventory(store_id, product_id,quantity) values("1","5","80");
Insert into inventory(store_id, product_id,quantity) values("1","6","100");
Insert into inventory(store_id, product_id,quantity) values("1","7","100");
Insert into inventory(store_id, product_id,quantity) values("1","8","100");
Insert into inventory(store_id, product_id,quantity) values("1","9","100");
Insert into inventory(store_id, product_id,quantity) values("1","10","70");
Insert into inventory(store_id, product_id,quantity) values("1","11","100");
Insert into inventory(store_id, product_id,quantity) values("1","12","100");
Insert into inventory(store_id, product_id,quantity) values("1","13","100");
Insert into inventory(store_id, product_id,quantity) values("1","14","100");
Insert into inventory(store_id, product_id,quantity) values("1","15","10");
Insert into inventory(store_id, product_id,quantity) values("1","16","100");
Insert into inventory(store_id, product_id,quantity) values("1","17","100");
Insert into inventory(store_id, product_id,quantity) values("1","18","20");

Insert into inventory(store_id, product_id,quantity) values("2","1","50");
Insert into inventory(store_id, product_id,quantity) values("2","2","100");
Insert into inventory(store_id, product_id,quantity) values("2","3","50");
Insert into inventory(store_id, product_id,quantity) values("2","4","100");
Insert into inventory(store_id, product_id,quantity) values("2","5","80");
Insert into inventory(store_id, product_id,quantity) values("2","6","200");
Insert into inventory(store_id, product_id,quantity) values("2","7","10");
Insert into inventory(store_id, product_id,quantity) values("2","8","880");
Insert into inventory(store_id, product_id,quantity) values("2","9","99");
Insert into inventory(store_id, product_id,quantity) values("2","10","70");
Insert into inventory(store_id, product_id,quantity) values("2","11","500");
Insert into inventory(store_id, product_id,quantity) values("2","12","100");
Insert into inventory(store_id, product_id,quantity) values("2","13","100");
Insert into inventory(store_id, product_id,quantity) values("2","14","100");
Insert into inventory(store_id, product_id,quantity) values("2","15","10");
Insert into inventory(store_id, product_id,quantity) values("2","16","20");
Insert into inventory(store_id, product_id,quantity) values("2","17","100");
Insert into inventory(store_id, product_id,quantity) values("2","18","20");

Insert into inventory(store_id, product_id,quantity) values("3","1","100");
Insert into inventory(store_id, product_id,quantity) values("3","2","50");
Insert into inventory(store_id, product_id,quantity) values("3","3","50");
Insert into inventory(store_id, product_id,quantity) values("3","4","100");
Insert into inventory(store_id, product_id,quantity) values("3","5","80");
Insert into inventory(store_id, product_id,quantity) values("3","6","30");
Insert into inventory(store_id, product_id,quantity) values("3","7","10");
Insert into inventory(store_id, product_id,quantity) values("3","8","880");
Insert into inventory(store_id, product_id,quantity) values("3","9","99");
Insert into inventory(store_id, product_id,quantity) values("3","10","20");
Insert into inventory(store_id, product_id,quantity) values("3","11","500");
Insert into inventory(store_id, product_id,quantity) values("3","12","100");
Insert into inventory(store_id, product_id,quantity) values("3","13","100");
Insert into inventory(store_id, product_id,quantity) values("3","14","20");
Insert into inventory(store_id, product_id,quantity) values("3","15","15");
Insert into inventory(store_id, product_id,quantity) values("3","16","17");
Insert into inventory(store_id, product_id,quantity) values("3","17","100");
Insert into inventory(store_id, product_id,quantity) values("3","18","20");

CREATE TABLE employee (
  staff_id INT PRIMARY KEY,
  first_name VARCHAR(255),
  last_name VARCHAR(255),
  salary DECIMAL(10, 2),
  store_id INT NOT NULL,
  FOREIGN KEY (store_id) REFERENCES store(store_id) ON UPDATE CASCADE ON DELETE RESTRICT
);

Insert into employee (staff_id, first_name, last_name, salary, store_id) values ("10001","Abe", "Louis","70000","1");
Insert into employee (staff_id, first_name, last_name, salary, store_id) values ("10002","Bobby", "White","50100","1");
Insert into employee (staff_id, first_name, last_name, salary, store_id) values ("10003","Charles", "Chen","65000","2");
Insert into employee (staff_id, first_name, last_name, salary, store_id) values ("10004","David", "Wang","40000","2");
Insert into employee (staff_id, first_name, last_name, salary, store_id) values ("10005","Ellen", "Wu","60000","3");
Insert into employee (staff_id, first_name, last_name, salary, store_id) values ("10006","Frank", "Black","50500","3");

CREATE TABLE manager (
  staff_id INT PRIMARY KEY,
  start_date DATE,
  store_id INT NOT NULL,
  FOREIGN KEY (staff_id) REFERENCES employee(staff_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY (store_id) REFERENCES store(store_id) ON UPDATE CASCADE ON DELETE RESTRICT
);

Insert into manager (staff_id, start_date, store_id) values ("10001","2000-01-01","1");
Insert into manager (staff_id, start_date, store_id) values ("10003","2001-05-01","2");
Insert into manager (staff_id, start_date, store_id) values ("10005","2002-02-01","3");

CREATE TABLE customer (
  customer_id INT PRIMARY KEY AUTO_INCREMENT,
  first_name VARCHAR(255) NOT NULL,
  last_name VARCHAR(255) NOT NULL,
  address VARCHAR(255),
  payment_info VARCHAR(255),
  birthday DATE
);

Insert into customer (customer_id, first_name, last_name, address, payment_info, birthday) values ("1","Xinyi","Zhang","25 Summer Street MA 02100","1111222233334444","1990-01-01");
Insert into customer (customer_id, first_name, last_name, address, payment_info, birthday) values ("2","Sherry","Jones","7 Alexander Street NY 10100","1111722233334444","1995-03-01");
Insert into customer (customer_id, first_name, last_name, address, payment_info, birthday) values ("3","John","Anderson","100 Exchange Street MA 02148","1115222233334447","2000-05-27");

CREATE TABLE orders (
  order_id INT PRIMARY KEY,
  date DATE NOT NULL,
  status VARCHAR(255), -- new, filled, pending delivery, delivered, completed
  customer_id INT,
  store_id INT,
  FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY (store_id) REFERENCES store(store_id) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE order_products (
 order_id INT NOT NULL,
 product_id INT NOT NULL,
 product_quantity INT NOT NULL,
 PRIMARY KEY (order_id, product_id),
 FOREIGN KEY (order_id) REFERENCES orders(order_id) ON UPDATE CASCADE ON DELETE RESTRICT,
 FOREIGN KEY (product_id) REFERENCES product(product_id) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE freight_truck (
  license_plate VARCHAR(255) PRIMARY KEY,
  availability BOOLEAN
);

Insert into freight_truck (license_plate, availability) values ("XXX123",True);
Insert into freight_truck (license_plate, availability) values ("YYY345",True);
Insert into freight_truck (license_plate, availability) values ("ZZZ001",True);
Insert into freight_truck (license_plate, availability) values ("AAA234",True);

CREATE TABLE delivery(
	order_id INT NOT NULL,
    truck_id VARCHAR(255) NOT NULL,
    PRIMARY KEY (order_id, truck_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (truck_id) REFERENCES freight_truck(license_plate) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- all products will share a same discount in a promotion
CREATE TABLE promotion (
  name VARCHAR(255) PRIMARY KEY,
  start_date DATE,
  end_date DATE,
  discount DECIMAL(5, 2)
);


CREATE TABLE feedback (
  customer_id INT NOT NULL,
  order_id INT,
  rating INT NOT NULL, -- 0 to 10
  review TEXT,
  date DATE NOT NULL,
  PRIMARY KEY (customer_id, order_id),
  FOREIGN KEY (order_id) REFERENCES orders(order_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON UPDATE CASCADE ON DELETE RESTRICT
);
