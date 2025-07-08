#!/bin/bash

# --- 检查并安装 gomobile ---

# 检查 gomobile 是否已安装
if ! command -v gomobile &> /dev/null
then
    echo "gomobile 未找到，正在尝试安装..."
    # 尝试安装 gomobile
    go install golang.org/x/mobile/cmd/gomobile@latest

    # 检查安装是否成功
    if [ $? -ne 0 ]; then
        echo "gomobile 安装失败。请检查 Go 环境配置和网络连接。"
        exit 1 # 如果安装失败，则退出脚本
    fi

    # 尝试初始化 gomobile (下载 SDKs)
    echo "正在初始化 gomobile (下载必要的 SDKs)，这可能需要一些时间..."
    gomobile init
    if [ $? -ne 0 ]; then
        echo "gomobile 初始化失败。请检查网络连接。"
        exit 1 # 如果初始化失败，则退出脚本
    fi

    echo "gomobile 已成功安装和初始化。"
else
    echo "gomobile 已存在。"
fi

# 确保 gomobile 在 PATH 中。go install 通常会将其放入 GOBIN，
# 但如果 GOBIN 不在当前 shell 的 PATH 中，则需要手动添加。
# 这个设置仅对当前脚本会话有效。
export PATH=$PATH:$(go env GOBIN):$(go env GOPATH)/bin

# --- 现有脚本内容开始 ---

# Backend
TAG_NAME=$(curl -s -k https://api.github.com/repos/OpenListTeam/OpenList/releases/latest | grep -o '"tag_name": ".*"' | cut -d'"' -f4)
# TAG_NAME=v4.0.3 # 你的注释，保持不动
URL="https://github.com/OpenListTeam/OpenList/archive/refs/tags/${TAG_NAME}.tar.gz"
echo "Downloading openlist ${TAG_NAME} from ${URL}"
curl -L -k "$URL" -o "openlist${TAG_NAME}.tar.gz"
tar xf "openlist${TAG_NAME}.tar.gz" --strip-components 1 -C ../sources
rm -f ../sources/.gitignore

# Frontend
URL=https://github.com/OpenListTeam/OpenList-Frontend/releases/latest/download/openlist-frontend-dist-${TAG_NAME}.tar.gz
echo "Downloading openlist-frontend from ${URL}"
curl -L -k "$URL" -o dist.tar.gz
rm -rf ../sources/public/dist
mkdir -p ../sources/public/dist # 使用 -p 以防父目录不存在
tar xf dist.tar.gz -C ../sources/public/dist

# --- 现有脚本内容结束 ---

# 你之前遇到的 'install_gomobile.sh' 和 'build_aar.sh' 脚本可以在这里被调用
# 例如:
# cd $GITHUB_WORKSPACE/AListLib/scripts
# ./install_gomobile.sh # 如果你仍然有这个脚本
# ./build_aar.sh      # 如果你仍然有这个脚本

echo "脚本执行完毕。"
