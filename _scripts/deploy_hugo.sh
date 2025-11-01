#!/bin/bash

# 发布 hugo

function deploy_hugo() {
    cd hugo_blog
    hugo --minify
}

function copy_posts() {
    cp -r typora/POSTS hugo_blog/content/posts/pst
}


function copy_all_md() {
    #!/bin/bash
    # 用法: ./copy_md.sh <源目录> <目标目录>
    # 作用: 复制所有 .md 文件（含子目录），保留目录结构
    src="$1"
    dest="$2"

    if [ -z "$src" ] || [ -z "$dest" ]; then
        echo "用法: $0 <源目录> <目标目录>"
        exit 1
      fi

      if [ ! -d "$src" ]; then
        echo "源目录不存在: $src"
        exit 1
      fi

      # 创建目标目录
      mkdir -p "$dest"

      # 遍历所有 .md 文件
      find "$src" -type f -name "*.md" | while read file; do
        rel_path="${file#$src/}"         # 去掉前缀路径
        target_dir="$dest/$(dirname "$rel_path")"
        mkdir -p "$target_dir"
        cp "$file" "$target_dir/"
      done
    echo "✅ 所有 Markdown 文件已复制到 $dest"

}

