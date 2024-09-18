#!/bin/bash

# 获取第一个参数作为 BASE
BASE=$1

# 检查 BASE 是否为空
if [ -z "$BASE" ]; then
  echo "Error: Base parameter is required"
  exit 1
fi

# 运行 slidev build 命令
slidev build --base /$BASE/

# 遍历 dist 目录，删除符合条件的文件夹
for dir in dist/[0-9]*
do
  if [ -d "$dir" ]; then
    # 获取文件夹名
    FOLDER_NAME=$(basename "$dir")
    if [[ ! $FOLDER_NAME == $BASE* ]]; then
      rm -rf "$dir"
    fi
  fi
done