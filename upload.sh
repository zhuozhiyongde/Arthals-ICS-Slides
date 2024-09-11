#!/bin/bash

# 远程服务器信息
REMOTE_USER="ubuntu"
REMOTE_HOST="10.129.80.233"

# 本地目录
LOCAL_DIR="dist/"

# 解析命令行参数
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --path) path="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

if [ -z "$path" ]; then
    echo "Error: --path parameter is required"
    exit 1
fi

# 目标路径
TARGET_PATH="~/Slides/${path}"

# 首先清空目标路径
ssh "${REMOTE_USER}@${REMOTE_HOST}" "rm -rf ${TARGET_PATH}"

# 上传文件
# quiet
scp -r "${LOCAL_DIR}" "${REMOTE_USER}@${REMOTE_HOST}:${TARGET_PATH}"
