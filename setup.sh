#/bin/sh

docker_config_root="/Abacus/Hub"
service_name="abacus-hub.service"
broker_port="1883"
broker_port_ssl="8883"

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

echo "Installing git and ufw"
DEBIAN_FRONTEND=noninteractive
apt-get install -y git ufw

echo "Installing docker"
curl -sSL https://get.docker.com | sh

echo "Enabling the docker-service"
systemctl enable --now docker

echo "Downloading config and docker-files"
cd /
git clone https://github.com/Energy-Abacus/Hub $docker_config_root

cd "$docker_config_root"
touch "$docker_config_root/config/password.txt"

echo "Creating config"

randomPassword1=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32})
randomPassword2=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32})

echo "
# Abacus config
mosquitto_user_local=abacus
mosquitto_passwd_local=$randomPassword1

mosquitto_user_remote=remote-abacus-user
mosquitto_passwd_remote=$randomPassword2
" > abacus_config

source abacus_config

echo "Starting mosquitto"

docker compose up mosquitto -d

echo "Creating service"

echo "[Unit]
Description=MQTT Broker and communication with Abacus
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$docker_config_root
ExecStart=bash startup.sh
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target" > "/etc/systemd/system/$service_name"

systemctl enable $service_name

echo "Installing and configuring ufw"

ufw --force enable
ufw allow $broker_port
ufw allow $broker_port_ssl
ufw reload

echo "Setting username and password for mosquitto"

docker compose exec mosquitto mosquitto_passwd -b /mosquitto/config/password.txt $mosquitto_user_local $mosquitto_passwd_local
docker compose exec mosquitto mosquitto_passwd -b /mosquitto/config/password.txt $mosquitto_user_remote $mosquitto_passwd_remote

docker compose down
bash startup.sh