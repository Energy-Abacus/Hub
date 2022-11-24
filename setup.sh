#/bin/sh

docker_config_root="/Abacus/Hub"
service_name="abacus-hub.service"
broker_port="1883"

mosquitto_user="abacus"
mosquitto_passwd="bzgYBm86oYbNRbzMz"

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

docker compose up -d
docker compose exec mosquitto mosquitto_passwd -b /mosquitto/config/password.txt $mosquitto_user $mosquitto_passwd

echo "[Unit]
Description=MQTT Broker and communication with Abacus
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$docker_config_root
ExecStart=/usr/bin/docker compose up -d
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target" > "/etc/systemd/system/$service_name"

systemctl enable $service_name

echo "Installing and configuring ufw"

ufw --force enable
ufw allow $broker_port
ufw reload