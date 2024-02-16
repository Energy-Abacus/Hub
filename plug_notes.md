# Reverse-Engineered Endpoints for Shelly-Plug-S config endpoints

- Wi-Fi
    - GET: http://192.168.1.100/settings/sta?enabled=1&ssid=Abacus&key=SucukAba123!&ipv4_method=dhcp
- MQTT
    - POST: http://192.168.1.100/settings
    - Payload: 
    ```www-form-encoded
    mqtt_enable=true&mqtt_server=1192.168.1.103%3A1883&mqtt_id=shellyplug-s-4022D8892671&mqtt_user=abacustest&mqtt_reconnect_timeout_max=60&mqtt_reconnect_timeout_min=2&mqtt_clean_session=true&mqtt_keep_alive=60&mqtt_max_qos=0&mqtt_retain=false&mqtt_pass=test
    ```
- Reboot
    - GET: http://192.168.1.100/reboot