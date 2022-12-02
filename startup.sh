#/bin/sh

docker_config_root="/Abacus/Hub"
cd "$docker_config_root"
source abacus_config

/usr/bin/docker compose pull
/usr/bin/docker compose up -d