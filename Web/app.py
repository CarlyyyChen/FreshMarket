from flask import Flask, request, redirect, url_for, render_template, jsonify
import pymysql.cursors
import datetime
import os
from dotenv import load_dotenv

load_dotenv()

db_host = os.getenv('DB_HOST')
db_user = os.getenv('DB_USER')
db_password = os.getenv('DB_PASSWORD')
db_database = os.getenv('DB_DATABASE')

app = Flask(__name__)

db_config = {
    'host': db_host,
    'user': db_user,
    'password': db_password,
    'database': db_database,
    'cursorclass': pymysql.cursors.DictCursor
}

@app.route('/home', methods=['GET','POST'])
def home():
    return render_template('home.html')

@app.route('/', methods=['GET', 'POST'])
def register():
    if request.method == "POST":
        username = request.form.get("username")
        password = request.form.get("password")

        conn = pymysql.connect(host=db_host,
                               user=db_user,
                               password=db_password,
                               database=db_database,
                               cursorclass=pymysql.cursors.Cursor)
        with conn:
            with conn.cursor() as cursor:
                sql = "call new_user(\'" + username + \
                    "\', \'" + password + "\')"
                try:
                    cursor.execute(sql)
                    result = cursor.fetchone()
                    conn.commit()
                    return render_template('login.html', error_message=result[0])
                except pymysql.OperationalError as e:
                    error_code, message = e.args
                    return render_template('register.html', error_message=result[0])
    else:
        return render_template('register.html')


@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        conn = pymysql.connect(host=db_host,
                               user=db_user,
                               password=db_password,
                               database=db_database,
                               cursorclass=pymysql.cursors.Cursor)
        cursor = conn.cursor()
        sql = "call login(\'" + username + "\', \'" + password + "\')"
        try:
            cursor.execute(sql)
            result = cursor.fetchone()
            conn.commit()
            return render_template('home.html')
        except pymysql.err.OperationalError as e:
            error_code, message = e.args
            return render_template('login.html', error_message=message)
    else:
        return render_template('login.html')


@app.route('/neworder')
def neworder():
    return render_template('neworder.html')


@app.route('/get_store_id')
def get_store_id():
    conn = pymysql.connect(**db_config)
    cursor = conn.cursor()
    query = "SELECT store_id FROM store"
    cursor.execute(query)
    store_id = cursor.fetchall()
    cursor.close()
    conn.close()
    return jsonify(store_id)


@app.route('/get_customer_id')
def get_customer_id():
    conn = pymysql.connect(**db_config)
    cursor = conn.cursor()
    query = "SELECT customer_id FROM customer"
    cursor.execute(query)
    customer_id = cursor.fetchall()
    cursor.close()
    conn.close()
    return jsonify(customer_id)


@app.route('/get_supplier_id')
def get_supplier_id():
    conn = pymysql.connect(**db_config)
    cursor = conn.cursor()
    query = "SELECT supplier_id FROM supplier"
    cursor.execute(query)
    supplier_id = cursor.fetchall()
    cursor.close()
    conn.close()
    return jsonify(supplier_id)


@app.route('/get_product_types')
def get_product_types():
    conn = pymysql.connect(**db_config)
    cursor = conn.cursor()
    query = "SELECT type_id, name FROM product_type"
    cursor.execute(query)
    product_types = cursor.fetchall()
    cursor.close()
    conn.close()
    return jsonify(product_types)


@app.route('/get_product_names/<int:type_id>')
def get_product_names(type_id):
    conn = pymysql.connect(**db_config)
    cursor = conn.cursor()
    query = f"SELECT product_id, name FROM product WHERE type_id = {type_id}"
    cursor.execute(query)
    product_names = cursor.fetchall()
    cursor.close()
    conn.close()
    return jsonify(product_names)


@app.route('/submit_order', methods=['POST'])
def submit_order():
    try:
        now_date = datetime.date.today()
        # Access the JSON data sent with the POST request
        data = request.json
        print(data)
        # Insert the order details into the "order_detail" table
        conn = pymysql.connect(**db_config)
        cursor = conn.cursor()
        # query = "INSERT INTO order_detail (product_type_id, product_id) VALUES (%s, %s)"
        query = "call new_order(%s, %s, %s, %s, %s, %s, @message)"
        for line in data['lines']:
            cursor.execute(query, (line['order_id'], now_date, line['customer_id'], line['store_id'],
                                   line['product_name'], line['quantity']))
        conn.commit()
        cursor.close()
        conn.close()
        return jsonify({'success': True, 'message': 'Order submitted successfully'})
    except pymysql.err.IntegrityError as e:
        return jsonify({'success': False, 'message': str(e)})


@app.route('/delivery')
def delivery():
    return render_template('delivery.html')


@app.route('/get_order_id')
def get_order_id():
    conn = pymysql.connect(**db_config)
    cursor = conn.cursor()
    query = "SELECT order_id FROM orders WHERE status = \'filled\'"
    cursor.execute(query)
    order_id = cursor.fetchall()
    cursor.close()
    conn.close()
    return jsonify(order_id)


@app.route('/get_truck_id')
def get_truck_id():
    conn = pymysql.connect(**db_config)
    cursor = conn.cursor()
    query = "SELECT license_plate FROM freight_truck WHERE availability = true"
    cursor.execute(query)
    order_id = cursor.fetchall()
    cursor.close()
    conn.close()
    return jsonify(order_id)


@app.route('/assign_delivery', methods=['POST'])
def assign_delivery():
    try:
        # Access the JSON data sent with the POST request
        data = request.json
        conn = pymysql.connect(**db_config)
        cursor = conn.cursor()
        query = "call assign_delivery(%s, %s)"
        for line in data['lines']:
            cursor.execute(query, (line['truck_id'], line['order_id']))
        conn.commit()
        cursor.close()
        conn.close()
        return jsonify({'success': True, 'message': 'Successfully assigned delivery'})
    except pymysql.err.IntegrityError as e:
        return jsonify({'success': False, 'message': str(e)})


@app.route('/restock')
def restock():
    return render_template('restock.html')


@app.route('/order_from_supplier', methods=['POST'])
def order_from_supplier():
    try:
        # Access the JSON data sent with the POST request
        data = request.json
        conn = pymysql.connect(**db_config)
        cursor = conn.cursor()
        query = "call order_from_supplier(%s, %s, %s, %s, %s)"
        for line in data['lines']:
            cursor.execute(query, (line['supplier_id'], line['store_id'], line['prod_name'], line['quantity'],
                                   line['prod_type']))
        conn.commit()
        cursor.close()
        conn.close()
        return jsonify({'success': True, 'message': 'Successfully ordered product from supplier'})
    except pymysql.err.OperationalError as e:
        error_code, message = e.args
        return jsonify({'success': False, 'message': message})


@app.route('/prepare_order', methods=['GET', 'POST'])
def prepare_order():
    conn = pymysql.connect(**db_config)
    try:
        if request.method == 'POST':
            order_id = request.form.get('order_id')
            with conn.cursor() as cursor:
                cursor.callproc('prepare_order', [order_id])
                result = cursor.fetchone()
                conn.commit()
                message = result['message'] if result else 'Order processed.'
                return render_template('prepare_order.html', message=message)
        else:
            # Fetch all orders with status 'new' for the dropdown
            with conn.cursor() as cursor:
                cursor.execute(
                    "SELECT order_id FROM orders WHERE status = 'new'")
                orders = cursor.fetchall()
                return render_template('prepare_order.html', orders=orders)
    except pymysql.MySQLError as e:
        error_code, message = e.args
        return render_template('prepare_order.html', error_message=message)
    finally:
        conn.close()


@app.route('/customer_feedback', methods=['GET', 'POST'])
def customer_feedback():
    if request.method == 'POST':
        inputFirstName = request.form.get('firstName')
        inputLastName = request.form.get('lastName')
        inputOrderID = request.form.get('orderID')
        inputRating = request.form.get('rating')
        inputReview = request.form.get('review')
        inputDate = request.form.get('date')  # 'YYYY-MM-DD'
        conn = pymysql.connect(**db_config)
        try:
            with conn.cursor() as cursor:
                cursor.callproc('add_feedback', [
                                inputFirstName, inputLastName, inputOrderID, inputRating, inputReview, inputDate])
                result = cursor.fetchone()
                conn.commit()
                message = result['message'] if result else 'successfully received new feedback.'
                return render_template('customer_feedback.html', message=message)
        except pymysql.MySQLError as e:
            error_code, message = e.args
            return render_template('customer_feedback.html', error_message=message)
        finally:
            conn.close()
    else:
        return render_template('customer_feedback.html')


@app.route('/register_new_customer', methods=['GET', 'POST'])
def register_new_customer():
    if request.method == 'POST':
        inputFirstName = request.form.get('firstName')
        inputLastName = request.form.get('lastName')
        inputAddress = request.form.get('address')
        inputCreditCardNumber = request.form.get('creditCardNumber')
        inputBirthday = request.form.get('birthday')

        conn = pymysql.connect(**db_config)
        try:
            with conn.cursor() as cursor:
                cursor.callproc('register_new_customer', [
                    inputFirstName, inputLastName, inputAddress, inputCreditCardNumber, inputBirthday
                ])
                result = cursor.fetchone()
                conn.commit()
                if 'message' in result:
                    # registration successful
                    success_message = result['message']
                    return render_template('register_new_customer.html', success_message=success_message)
                else:
                    error_message = "Registration failed. Please try again."
                    return render_template('register_new_customer.html', error_message=error_message)
        except pymysql.MySQLError as e:
            error_code, message = e.args
            return render_template('customer_feedback.html', error_message=message)
        finally:
            conn.close()
    else:
        return render_template('register_new_customer.html')


@app.route('/launch_promotion', methods=['GET', 'POST'])
def launch_promotion():
    if request.method == 'POST':
        inputPromotionName = request.form.get('promotionName')
        inputStartDate = request.form.get('startDate')
        inputEndDate = request.form.get('endDate')
        inputDiscount = request.form.get('discount')

        conn = pymysql.connect(**db_config)
        try:
            with conn.cursor() as cursor:
                cursor.callproc('launch_promotion', [
                    inputPromotionName, inputStartDate, inputEndDate, inputDiscount
                ])
                result = cursor.fetchone()
                conn.commit()
                if 'message' in result:
                    success_message = result['message']
                    return render_template('launch_promotion.html', success_message=success_message)
                else:
                    error_message = "Promotion launch failed. Please try again."
                    return render_template('launch_promotion.html', error_message=error_message)
        except pymysql.MySQLError as e:
            error_code, message = e.args
            return render_template('launch_promotion.html', error_message=message)
        finally:
            conn.close()
    else:
        return render_template('launch_promotion.html')

@app.route('/retire_employee', methods=['GET', 'POST'])
def retire_employee():
    conn = pymysql.connect(**db_config)
    try:
        with conn.cursor() as cursor:
            if request.method == 'POST':
                inputStaffID = request.form.get('staffID')
                cursor.callproc('retire_employee', [inputStaffID])
                conn.commit()
                success_message = "Employee retired successfully."
                return render_template('retire_employee.html', success_message=success_message)
            else:
                cursor.execute("SELECT staff_id FROM employee")
                employee_ids = cursor.fetchall()
                print(employee_ids)  # Add this line for debugging
                # Adjust the following line based on the actual structure of employee_ids
                employee_ids = [id['staff_id'] for id in employee_ids]
                return render_template('retire_employee.html', employee_ids=employee_ids)
    except pymysql.MySQLError as e:
        error_code, message = e.args
        error_message = f"Error {error_code}: {message}"
        return render_template('retire_employee.html', error_message=error_message)
    finally:
        conn.close()

if __name__ == '__main__':
    app.run()
