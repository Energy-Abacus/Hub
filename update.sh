#/bin/sh

docker_config_root="/Abacus/Hub"
cd "$docker_config_root"
source abacus_config

docker compose pull listener
docker compose down
docker compose up -d