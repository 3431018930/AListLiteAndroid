#!/bin/bash

if ! command -v gomobile &> /dev/null; then
    echo "gomobile 未找到，正在安装..."
    go install golang.org/x/mobile/cmd/gomobile@latest || {
        echo "gomobile 安装失败。请检查 Go 环境和网络。"
        exit 1
    }

    echo "初始化 gomobile (下载 SDKs)..."
    gomobile init || {
        echo "gomobile 初始化失败。"
        exit 1
    }
    echo "gomobile 已安装。"
else
    echo "gomobile 已存在。"
fi

echo "Adding Go tools to PATH: $(go env GOBIN):$(go env GOPATH)/bin"
echo "$(go env GOBIN):$(go env GOPATH)/bin" >> $GITHUB_PATH
export PATH="$PATH:$(go env GOBIN):$(go env GOPATH)/bin"

mkdir -p ../sources/public/dist || { echo "无法创建目录"; exit 1; }

TAG_NAME=$(curl -s -k https://api.github.com/repos/OpenListTeam/OpenList/releases/latest | grep -o '"tag_name": ".*"' | cut -d'"' -f4)
URL="https://github.com/OpenListTeam/OpenList/archive/refs/tags/${TAG_NAME}.tar.gz"
echo "下载 OpenList ${TAG_NAME}..."
curl -L -k "$URL" -o "openlist${TAG_NAME}.tar.gz" || { echo "下载失败"; exit 1; }
tar xf "openlist${TAG_NAME}.tar.gz" --strip-components 1 -C ../sources || { echo "解压失败"; exit 1; }

URL="https://github.com/OpenListTeam/OpenList-Frontend/releases/latest/download/openlist-frontend-dist-${TAG_NAME}.tar.gz"
echo "下载前端..."
curl -L -k "$URL" -o dist.tar.gz || { echo "前端下载失败"; exit 1; }
tar xf dist.tar.gz -C ../sources/public/dist || { echo "前端解压失败"; exit 1; }

echo "脚本完成。"
