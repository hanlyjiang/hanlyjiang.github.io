#!/bin/bash

# 发布 hugo

function copy_all_md() {
    src="$1"
    dest="$2"

    # 检查参数
    if [ -z "$src" ] || [ -z "$dest" ]; then
      echo "用法: $0 <源目录> <目标目录>"
      exit 1
    fi

    # 创建目标目录
    mkdir -p "$dest"

    # 使用 rsync 递归复制 .md 文件并保留结构
    rsync -av --include='*/' --include='*.md' --exclude='*' "$src"/ "$dest"/
}

copy_all_md typora hugo_blog/content/posts/