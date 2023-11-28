create database fresh_market_db;
use fresh_market_db;

CREATE TABLE login(
	name varchar(30) PRIMARY KEY,
    password varchar(30) NOT NULL
);

CREATE TABLE product_type (
  type_id INT PRIMARY KEY,
  name VARCHAR(255) unique,
  unit VARCHAR(255)
);

CREATE TABLE supplier (
  supplier_id INT PRIMARY KEY,
  street_number INT,
  street_name VARCHAR(255),
  state_abbreviation VARCHAR(2),
  zip_code VARCHAR(10)
);

CREATE TABLE product (
  product_id INT PRIMARY KEY,
  name VARCHAR(255) UNIQUE,
  price DECIMAL(10, 2),
  type_id INT,
  FOREIGN KEY (type_id) REFERENCES product_type(type_id) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE store (
  store_id INT PRIMARY KEY,
  street_number INT,
  street_name VARCHAR(255),
  state_abbreviation VARCHAR(2),
  zip_code VARCHAR(10)
);

CREATE TABLE store_suppliers(
	store_id INT NOT NULL,
    supplier_id INT NOT NULL,
    product_id INT NOT NULL,
	PRIMARY KEY (store_id, supplier_id, product_id),
    FOREIGN KEY (store_id) REFERENCES store(store_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (supplier_id) REFERENCES supplier(supplier_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (product_id) REFERENCES product(product_id) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE inventory(
  store_id INT,
  product_id INT,
  quantity INT,
  PRIMARY KEY (store_id, product_id),
  FOREIGN KEY (store_id) REFERENCES store(store_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY (product_id) REFERENCES product(product_id) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE employee (
  staff_id INT PRIMARY KEY,
  first_name VARCHAR(255),
  last_name VARCHAR(255),
  salary DECIMAL(10, 2),
  store_id INT NOT NULL,
  FOREIGN KEY (store_id) REFERENCES store(store_id) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE manager (
  staff_id INT PRIMARY KEY,
  start_date DATE,
  store_id INT NOT NULL,
  FOREIGN KEY (staff_id) REFERENCES employee(staff_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY (store_id) REFERENCES store(store_id) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE customer (
  customer_id INT PRIMARY KEY,
  first_name VARCHAR(255) NOT NULL,
  last_name VARCHAR(255) NOT NULL,
  address VARCHAR(255),
  payment_info VARCHAR(255),
  birthday DATE
);

CREATE TABLE orders (
  order_id INT PRIMARY KEY,
  date DATE NOT NULL,
  status VARCHAR(255), -- new, filled, pending delivery, delivered, completed
  customer_id INT,
  store_id INT,
  UNIQUE(customer_id, store_id, date),
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
