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
                sql = "call new_user(\'" + username + "\', \'" + password + "\')"
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


if __name__ == '__main__':
    app.run()
