---
title: 静态博客部署到 VPS 的小结
createTime: 2026/10/02 14:30:00
tags:
  - 部署
  - Nginx
  - Linux
permalink: /blog/tech/static-blog-deploy/
---

# 静态博客部署到 VPS 的小结

本文记录如何把 VuePress 静态博客部署到一台小内存 VPS 上。

## 核心思路

本地构建 → 推送到服务器 → Nginx 托管静态文件。

## 关键点

1. 服务器不需要 Node 环境，只需要 Nginx
2. 构建产物是纯静态文件，内存占用极小
3. 使用 `rsync` 增量同步，发布速度快

## 小内存机器的优化

- 加 1G swap 作为内存保险
- Nginx 单 worker 进程即可
- 开启 gzip 压缩减小传输体积

> 本文为搭建博客时的示例文章，内容会在后续更新为完整版。
