#!/usr/bin/env bash

# Immich公式のcompose.yamlとexample.envを取得
wget -O compose.yaml https://github.com/immich-app/immich/releases/latest/download/docker-compose.yml
wget -O .env https://github.com/immich-app/immich/releases/latest/download/example.env

# yqがインストールされていれば各種自動編集
if command -v yq >/dev/null 2>&1; then
    # env_fileを../stack.envに置換（env_file指定があるサービスのみ）
    yq -i '(.services[] | select(.env_file)) |= .env_file = ["../stack.env"]' compose.yaml
    echo "env_file replaced with ../stack.env for services with env_file using yq"

    # immich-serverをproxyネットワークにJOINさせる
    yq -i '.services["immich-server"].networks += ["proxy"]' compose.yaml
    # networksセクションがなければ追加
    if ! yq '.networks.proxy' compose.yaml >/dev/null 2>&1; then
        echo -e '\nnetworks:\n  proxy:\n    external: true' >> compose.yaml
    fi
    echo "immich-server joined to proxy network"

    # immich-serverのportsセクションを削除（proxy経由アクセス用）
    yq -i 'del(.services["immich-server"].ports)' compose.yaml
    echo "immich-server ports section removed for proxy access"
else
    echo "yq is not installed. Please install yq to use this feature."
fi
