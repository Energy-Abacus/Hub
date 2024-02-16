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
    wifi_name = request.args.get('wifiName')
    wifi_password = request.args.get('wifiPassword')

    dotenv.load_dotenv(CONFIG_PATH)
    dotenv.set_key(CONFIG_PATH, 'POST_TOKEN', post_token)

    subprocess.run('nmcli', 'device', 'wifi', 'connect', wifi_name, 'password', wifi_password)
    subprocess.run([CONFIG_PATH + '/update.sh'])
    return {
        'user': os.environ['mosquitto_user_remote'],
        'password': os.environ['mosquitto_passwd_remote']
    }

if __name__ == '__main__':
    app.run(debug=False, port=5000)
