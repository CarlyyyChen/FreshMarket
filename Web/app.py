from flask import Flask, request, redirect, url_for, render_template
import pymysql.cursors
import time
app = Flask(__name__)


@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == "POST":
        username = request.form.get("username")
        password = request.form.get("password")

        conn = pymysql.connect(host='localhost',
                               user='root',
                               password='123456',
                               database='test_proj',
                               cursorclass=pymysql.cursors.Cursor)
        with conn:
            with conn.cursor() as cursor:
                sql = "call new_user(\'" + username + \
                    "\', \'" + password + "\')"
                try:
                    cursor.execute(sql)
                    result = cursor.fetchone()
                    conn.commit()
                    return render_template('register.html', error_message=result[0])
                except pymysql.OperationalError as e:
                    error_code, message = e.args
                    return render_template('register.html', error_message=result[0])
    else:
        return render_template('register.html')


@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        email = request.form.get('username')
        password = request.form.get('password')
        return render_template('login.html', error_message='Success')


@app.route('/prepare_order', methods=['GET', 'POST'])
def prepare_order():
    conn = pymysql.connect(host='localhost',
                           user='root',
                           password='123456',
                           database='fresh_market_db',
                           cursorclass=pymysql.cursors.DictCursor)
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
        conn = pymysql.connect(host='localhost',
                               user='root',
                               password='123456',
                               database='fresh_market_db',
                               cursorclass=pymysql.cursors.DictCursor)
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

        conn = pymysql.connect(host='localhost',
                               user='root',
                               password='123456',
                               database='fresh_market_db',
                               cursorclass=pymysql.cursors.DictCursor)
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



if __name__ == '__main__':
    app.run()
