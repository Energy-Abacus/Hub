#/bin/sh

docker_config_root="/Abacus/Hub"

cd "$docker_config_root"
source abacus_config

/usr/bin/docker compose pull listener
/usr/bin/docker compose up -d

python3 setup_api.py
