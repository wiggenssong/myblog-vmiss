#!/usr/bin/env bash
# ============================================
# 新建文章脚本（一键生成带 frontmatter 的文章模板）
# 用法: ./new-post.sh "文章标题" [分类] [标签1 标签2 ...]
# 示例: ./new-post.sh "我的第一篇真实文章" tech VuePress 部署
# 生成后: 编辑正文 → ./deploy.sh 发布
# ============================================
set -e
cd "$(dirname "$0")"

usage() { echo "用法: ./new-post.sh \"文章标题\" [分类] [标签1 标签2 ...]"; exit 1; }
[ -z "$1" ] && usage

TITLE="$1"
CAT="${2:-default}"
TAGS="${@:3}"

# 由标题生成英文 slug；纯中文标题回退为日期链接（避免冲突）
SLUG=$(echo "$TITLE" | sed 's/[^a-zA-Z0-9 ]//g' | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
[ -z "$SLUG" ] && SLUG="$(date +%Y%m%d-%H%M)"

TS=$(date "+%Y-%m-%d %H:%M:%S")
PERMA="/blog/$CAT/$SLUG/"

DIR="docs/blog/$CAT"
mkdir -p "$DIR"
FILE="$DIR/$SLUG.md"
n=1
while [ -f "$FILE" ]; do FILE="$DIR/$SLUG-$n.md"; n=$((n + 1)); done

cat > "$FILE" <<EOF
---
title: $TITLE
createTime: $TS
permalink: $PERMA
tags:
$(for t in $TAGS; do echo "  - $t"; done)
---

# $TITLE

开始写作…
EOF

echo "✅ 已创建: $FILE"
echo "   - 分类: $CAT（子目录即分类）"
echo "   - 链接: $PERMA"
echo "   - 标签: ${TAGS:-（未设置）}"
echo ""
echo "下一步: 编辑正文 → ./deploy.sh 发布"
echo "提示: 想改链接/标签，直接编辑该文件顶部 frontmatter 即可"
