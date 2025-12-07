#!/usr/bin/env bash

# Immich公式のcompose.yamlとexample.envを取得
wget -O compose.yaml https://github.com/immich-app/immich/releases/latest/download/docker-compose.yml
wget -O .env https://github.com/immich-app/immich/releases/latest/download/example.env

# yqがインストールされていれば各種自動編集
if command -v yq >/dev/null 2>&1; then
    # env_fileを../stack.envに置換（env_file指定があるサービスのみ）
    yq -i '(.services[] | select(.env_file)) |= .env_file = ["../stack.env"]' compose.yaml
    echo "env_file replaced with ../stack.env for services with env_file using yq"

    # immichネットワークを追加し、全サービスにアタッチ（既存ネットワークは維持）
    yq -i '.networks.immich = {}' compose.yaml
    for service in $(yq eval '.services | keys | .[]' compose.yaml); do
        yq -i ".services[\"$service\"].networks += [\"immich\"]" compose.yaml
        echo "${service} attached to immich network"
    done

    # proxyネットワークを追加し、immich-serverをproxyネットワークにアタッチ
    yq -i '.networks.proxy = {"external": true}' compose.yaml
    yq -i '.services["immich-server"].networks += ["proxy"]' compose.yaml

    # immich-serverのportsセクションを削除（proxy経由アクセス用）
    yq -i 'del(.services["immich-server"].ports)' compose.yaml
    echo "immich-server ports section removed for proxy access"
else
    echo "yq is not installed. Please install yq to use this feature."
fi
