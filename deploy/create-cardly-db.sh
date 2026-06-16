#!/bin/bash
set -euo pipefail
set -a
source /opt/cardly/.env.prod
set +a
export PGPASSWORD="$SPRING_DATASOURCE_PASSWORD"

HOST="cardly.clwi8c0q49pk.us-east-2.rds.amazonaws.com"

exists=$(psql -h "$HOST" -U postgres -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='cardly'")
if [[ "$exists" == "1" ]]; then
  echo "Database cardly already exists"
else
  psql -h "$HOST" -U postgres -d postgres -c "CREATE DATABASE cardly"
  echo "Database cardly created"
fi
