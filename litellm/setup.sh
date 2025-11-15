#!/usr/bin/env bash

# Get the code
curl -o compose.yaml https://raw.githubusercontent.com/BerriAI/litellm/main/docker-compose.yml
curl -O https://raw.githubusercontent.com/BerriAI/litellm/main/prometheus.yml

# Compile into valid compose file on Portainer
PROMETHEUS_CONFIG=$(awk '{printf "%s\\n", $0}' prometheus.yml)
yq eval '
  .services.prometheus.volumes |= [ .[] | select(. != "./prometheus.yml:/etc/prometheus/prometheus.yml") ] |
  .services.prometheus.configs = [{"source": "prometheus", "target": "/etc/prometheus/prometheus.yml"}] |
  .configs.prometheus.content = "'"$PROMETHEUS_CONFIG"'"
' compose.yaml -i

# env_file参照をすべて ../stack.env に統一
yq eval '
  .services |= with_entries(
    .value.env_file = "../stack.env"
  )
' compose.yaml -i
