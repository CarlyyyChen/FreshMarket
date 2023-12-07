# Fresh Market Enterprise Resource Planning System

---

## Introduction

Fresh Market is a supermarket that provides instore shopping and online ordering services. Main product category includes produce, meat, seafood, deli & prepared food, dairy, beverages, bakery, etc. Our application serves as an ERP (Enterprise resource planning) system for Fresh Market internal users(employees and managers), facilitating order management, inventory management, customer management and employee management. 

## Table of Contents

- [Project Details](#project-details)
- [Setting Up the Project](#setting-up-the-project)
- [Exploring the FreshMarket Application](#exploring-the-freshmarket-application)
- [Alternative Design/Approaches:](#alternative-design-and-approaches)
- [Planned Use of the Database](#planned-use-of-the-database)
- [Areas for Added Functionality](#areas-for-added-functionality)
- [Accomplishments](#accomplishments)
- [Technical Challenges](#technical-challenges)
- [Key Takeaways](#key-takeaways)
- [Conclusion](#conclusion)

---

## Project Details

- **Project Name:** FreshMarket
- **Purpose:** Develop a fully functional ERP system for instore shopping and online ordering services
- **Project Engineer:** Huanyue Chen, Yuwei Wu, Zhekun Yu
- **Timeline:** Oct 2023 — Dec 2023
- **Target Audience:** Fresh Market internal users(employees and managers)

---


## Setting Up the Project

1. Cloning the FreshMarket Repository

To get started, clone the "FreshMarket" repository from GitHub. Open a terminal and navigate to the directory where you want to set up the project. Then, run the following command:

```bash
$ git clone https://github.com/CarlyyyChen/FreshMarket.git
```

This will create a new directory called "FreshMarket" containing the project files.

2. Creating a Virtual Environment
Navigate into the "FreshMarket" directory and create a virtual environment for the project. Run the following commands:

```bash
$ cd FreshMarket
$ python3 -m venv venv
$ source venv/bin/activate
```

This will create a new virtual environment and activate it.

3. Installing Dependencies

With the virtual environment activated, let’s install the required dependencies. Run the following command:

```bash
$ pip install flask
$ pip install python-dotenv
$ pip install pymysql
$ pip install pyecharts 
```


4. Configuring the Database

The "FreshMarket" project uses MySQL as the database. Before running the application, you need to set up a MySQL database and configure the project to use it.

   a. **Creating a MySQL Database**

   Open your preferred MySQL client and create a new database for the project. You can use the following SQL command:

   ```sql
   CREATE DATABASE freshmarket;
   ```

   b. **Configuring the Database Connection**

   In the project directory, open the ".env" file. Update the values of the following variables with your MySQL database credentials:

   ```sql
   DB_HOST = 'localhost'
   DB_USER = 'your_mysql_username'
   DB_PASSWORD = 'your_mysql_password'
   DB_NAME = 'fresh_market_db'
   ```

   Save the changes.

5. Running the Application

To start the FreshMarket web application, run one of the following commands:

```bash
$ flask run 
```

```bash
$ python app.py 
```
---

This will launch the application, and you can access it by opening your web browser and entering the URL `http://127.0.0.1:5000/`.

---

## Exploring the FreshMarket Application

The FreshMarket application provides several features to facilitate online grocery shopping. Here are some key functionalities:

- **User Registration and Login:** Users can create a new account or log in to their existing account.
- **Order management (new, prepare, deliver):** 
a. New Order: The system will directly receive order from our customer. Users can enter order details into the database, including order id, store id, customer id, product type, product name and quantity. In case users input a duplicated order id, the called mysql procedure will detect this behavior and return an error to the front end and generate alert that the order id has already exists. 
b.	Prepare order: Users can choose an order id from the drop-down menu to prepare the order. If the quantity entered for this order exceeds the current inventory, we will prompt an error message indicating that there is not enough inventory. If inventory is enough then we will update the order status to “filled”.
c.	Assign delivery: Users can choose order id and freight truck plate from the dropdown-menu. Confirming will set the order status to “complete” and update the freight_truck status from available(1) to unavailable(0), and add a new record to delivery table accordingly.
- **Inventory Management:** Users can order product from suppliers. Users enter a store id, product type, product name, supplier id and quantity. The store id, product type and supplier id will be read from database and displayed in the drop-down menu. Submitting the order will update the inventory table accordingly.
- **Customer Management:** Users can register new customers.
- **Receive Customer Feedback:** Users can add feedback from customers to our database with customer first name, last name, order id, customer rating (from 1 to 5), text review and date.
- **Launch Promotion:** Users can added a new promotion with promotion name, start date, and end date. All product prices will be updated after applying that discount amount.
- **Manage Employees:** Users can delete employees from the database by selecting an employee id from the drop down menu. We will also check if that employee is a manager or not, if so, we will delete them from the manager table as well.
- **Analyze Inventory(data visualization):** Users can select a store id from the drop-down menu and analyze the inventory in that store. The inventory will be visualized as pie chart displaying different product names and their quantity in the selected store.
---

## Alternative Design/Approaches:
We contemplated various design approaches. For example, we considered using a NoSQL database for greater flexibility but ultimately decided against it due to SQL's strong consistency and reliability, which are crucial for transactional data. We also debated between different frontend frameworks before settling on Flask for its simplicity and integration with our Python backend.


## Planned Use of the Database:
The database designed for Fresh Market's ERP system is expected to streamline various operational processes. In the future, we plan to integrate it with point-of-sale systems for real-time inventory tracking and sales analytics. Moreover, we aim to utilize the database for predictive analytics, leveraging historical data to forecast demand and optimize stock levels.


## Areas for Added Functionality
The FreshBasket project provides a solid foundation for building an online grocery delivery platform. There are still areas of funcitonality to improve in the future:

- **Mobile Integration:** Developing a mobile application that interfaces with the database to provide staff and management with on-the-go access to inventory levels, sales reports, and supplier information.
- **Customer Relationship Management (CRM):** Enhancing the database to support a CRM module that can track customer purchases, preferences, and feedback to offer personalized promotions and improve customer service.
- **Supply Chain Optimization:** Implementing advanced algorithms that use the database for supply chain optimization, including automated supplier selection, dynamic pricing models, and transportation logistics.
- **Internet of Things (IoT) Integration:** Incorporating IoT devices such as smart shelves and RFID tags to provide real-time updates to the database, thus further automating inventory management.
- **Machine Learning for Predictive Analytics:** Applying machine learning techniques to the data collected in the database to predict market trends, customer behavior, and operational inefficiencies.
- **Security Enhancements:** Upgrading the database security protocols to ensure data integrity and protect against cyber threats, which is critical for maintaining customer trust and complying with data protection regulations.
- **Scalability Improvements:** Refining the database architecture to ensure it can scale effectively with the growth of Fresh Market, handling increased transaction volumes without compromising performance.


---

## Accomplishments

During the development of the FreshBasket project, several key accomplishments were achieved:

1. Seamless user experience for browsing and purchasing groceries online.
2. Secure user authentication and authorization system.
3. Robust product management and inventory tracking.
4. Efficient order processing and management.
5. User-friendly admin dashboard for easy management of products, orders, and users.

---

## Technical Challenges

While building the FreshMarket application, some technical challenges were encountered:

1. Integrating the Flask framework with MySQL for database operations.
2. Implementing secure user authentication and password hashing.
3. Optimizing the application for scalability and performance.
4. Managing complex server side business logic for order processing and inventory tracking.
5. Implementing a responsive and intuitive user interface.

---

## Key Takeaways

Throughout the FreshMarket project, several key takeaways were gained:

1. Understanding the process of developing a full-stack web application.
2. Proficiency in using the Flask web framework and MySQL database.
3. Implementing secure user authentication and authorization.
4. Working with frontend technologies like HTML, CSS, and JavaScript.
5. Dealing with common challenges in e-commerce application development.

---

## Conclusion
Building the FreshMarekt web application is more than just a successful technological endeavor; it's a testament to the possibilities of digital transformation in retail. It exemplifies how technology can be leveraged to not only meet the current needs of a business but also to pave the way for future advancements. The experience and insights gained from this project will undoubtedly be instrumental in guiding future developments in the field of online retail and ERP systems.
