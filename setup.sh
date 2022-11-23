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

echo "Installing docker"
curl -sSL https://get.docker.com | sh

echo "Enabling the docker-service"
systemctl enable --now docker

echo "Downloading config and docker-files"
git clone https://github.com/Energy-Abacus/Hub $docker_config_root

cd $docker_config_root

touch config/password.txt

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
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target" > "/etc/systemd/system/$service_name"

systemctl enable $service_name

echo "Installing and configuring ufw"

DEBIAN_FRONTEND=noninteractive
current_subnet=ip -o -f inet addr show | awk '/scope global/ {print $4}'

apt-get install -y ufw

ufw enable
ufw allow from $current_subnet to any port $broker_port
ufw reload
