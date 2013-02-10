import os
from flask import Flask, render_template
app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

if __name__ == '__main__':
    app.debug = True
    # Bind to PORT if defined, otherwise default to 5000.
    port = int(os.environ.get('PORT', 5000))
    if app.debug: host = '127.0.0.1'
    else: host = '0.0.0.0'
    app.run(host=host, port=port)