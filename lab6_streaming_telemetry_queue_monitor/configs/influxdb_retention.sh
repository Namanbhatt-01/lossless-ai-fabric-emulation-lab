#!/bin/sh
# Set 24-hour retention policy to keep InfluxDB memory footprint strictly under 350 MB on M1
influx bucket update -n queue_telemetry -r 24h -o ai_fabric -t telemetry_secret_token_12345
