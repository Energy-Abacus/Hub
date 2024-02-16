# app.py

import os
import subprocess
from flask import Flask, request
import dotenv

CONFIG_ROOT = '/Abacus/Hub'
CONFIG_PATH = CONFIG_ROOT + '/abacus_config';

app = Flask(__name__)

@app.route('/setup', methods=['POST'])
def setup_endpoint():
    post_token = request.args.get('postToken')

    dotenv.load_dotenv(CONFIG_PATH)
    dotenv.set_key(CONFIG_PATH, 'POST_TOKEN', post_token)

    subprocess.run([CONFIG_PATH + '/update.sh'])

    return {
        'user': os.environ['mosquitto_user_remote'],
        'password': os.environ['mosquitto_passwd_remote']
    }

if __name__ == '__main__':
    app.run(debug=False, port=5000)
