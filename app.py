import os
from flask import Flask
app = Flask(__name__)

@app.route('/')
def index():
    app.logger.warning("OH SHIT!")
    return "Pyyle here."

if __name__ == '__main__':
    app.debug = True
    # Bind to PORT if defined, otherwise default to 5000.
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port)