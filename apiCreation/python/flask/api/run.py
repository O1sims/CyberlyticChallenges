import os
from flask import Flask


app = Flask(__name__)


@app.route("/")
def hello():
    return "Hello World!"

if __name__ == '__main__':
    app.run(
        host=os.environ.get(
            key='API_HOSTNAME'),
        port=os.environ.get(
            key='API_PORT'),
        debug=os.environ.get(
            key='DEBUG_MODE'))
