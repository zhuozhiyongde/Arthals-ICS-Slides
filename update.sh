cp ./pages/Index.md ./slides.md

slidev build

# 遍历 dist 目录，删除符合条件的文件夹
for dir in dist/[0-9]*
do
  if [ -d "$dir" ]; then
    rm -rf "$dir"
  fi
done

sudo cp -r dist/* /opt/1panel/apps/openresty/openresty/www/sites/slide.huh.moe/index/

git reset --hard origin/main

echo "更新完成"