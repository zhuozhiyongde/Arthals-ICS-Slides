#!/bin/bash

# 获取第一个参数作为 BASE
BASE=$1

# 检查 BASE 是否为空
if [ -z "$BASE" ]; then
  echo "Error: Base parameter is required"
  exit 1
fi

# 复制 pages/ 下的 BASE 开头的文件到 .
cp -r pages/$BASE* .

# 获取 BASE* 的完整文件名

FULL_NAME=$(ls ./$BASE*)

# 运行 slidev build 命令
slidev build --base /$BASE/ $FULL_NAME

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

# 创建目标目录
TARGET_DIR="/opt/1panel/apps/openresty/openresty/www/sites/slide.huh.moe/index/$BASE"
sudo mkdir -p "$TARGET_DIR"

# 复制 dist 目录内容到目标目录
sudo cp -r dist/* "$TARGET_DIR"

echo "Files have been copied to $TARGET_DIR"

git reset --hard origin/main

rm [0-9]*