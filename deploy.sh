#!/usr/bin/env bash
# ============================================
# 博客一键发布脚本
# 用法: ./deploy.sh
# 流程: 本地构建 → rsync 推送到服务器 → 完成
# ============================================
set -e

# 服务器信息
SERVER="45.221.115.138"
REMOTE_DIR="/var/www/blog"
SSH_CONFIG="/home/wiggens/ssh-vmiss/.ssh/config"

cd "$(dirname "$0")"

echo "==> [1/3] 构建静态站点..."
export npm_config_cache=/home/wiggens/ssh-vmiss/.npm-cache
npm run docs:build

echo "==> [2/3] 推送到服务器..."
rsync -az --delete \
  -e "ssh -F $SSH_CONFIG" \
  docs/.vuepress/dist/ \
  root@$SERVER:$REMOTE_DIR/

echo "==> [3/3] 发布完成！"
echo "    访问: http://$SERVER/"
