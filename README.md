# 日常记录 · 博客项目

个人博客，基于 **VuePress 2 + vuepress-theme-plume**，部署在 `http://45.221.115.138`（nginx 静态托管）。

## 日常使用（就两条命令）

### 1. 新建文章

```bash
./new-post.sh "文章标题" [分类] [标签1 标签2 ...]
```

示例：

```bash
./new-post.sh "今天学了什么" 技术 VuePress 笔记
```

- 自动生成 `docs/blog/技术/今天学了什么.md`（frontmatter 已填好标题/时间/链接/标签）
- **分类 = 子目录**（`docs/blog/技术/` 下的文章自动归入「技术」分类）
- **标签** 写在文章顶部 frontmatter 的 `tags` 字段
- 纯中文标题的链接自动用日期（如 `/blog/技术/20261005-1430/`），想改就编辑文件里 `permalink` 行

### 2. 发布上线

```bash
./deploy.sh
```

自动完成：本地构建 → 推送到服务器 → 生效。一般 10 秒内完成。

## 文章模板参考

```markdown
---
title: 文章标题
createTime: 2026-10-05 14:30:00
permalink: /blog/技术/文章链接/
tags:
  - 标签1
  - 标签2
---

# 文章标题

正文…
```

## 目录结构

```
blog/
├── deploy.sh              # 一键发布（构建 + 推送服务器）
├── new-post.sh            # 一键新建文章
├── docs/                  # 站点源文件
│   ├── README.md          # 首页
│   ├── about.md           # 关于页
│   ├── blog/              # 文章目录（子目录=分类）
│   │   ├── tech/          # 示例分类：技术
│   │   └── life/          # 示例分类：生活
│   └── .vuepress/
│       ├── config.ts      # 站点配置（标题/简介/图标）
│       ├── plume.config.ts# 主题配置（头像/导航/页脚）
│       ├── client.ts      # 客户端配置（布局注入）
│       ├── layouts/       # 自定义布局（不蒜子统计）
│       └── public/        # 静态资源（avatar.jpg 等）
```

## 常见修改

| 想改什么 | 改哪里 |
|---|---|
| 博客标题 / 简介 | `docs/.vuepress/config.ts` |
| 头像 / 导航 / 页脚 | `docs/.vuepress/plume.config.ts` |
| 关于页内容 | `docs/about.md` |
| 首页 hero / 栏目 | `docs/README.md` |

改完运行 `./deploy.sh` 即可生效。

## 服务器信息（备忘）

- 地址：`45.221.115.138`（Ubuntu 24.04，1C/1G）
- 博客目录：`/var/www/blog`（nginx 托管，80 端口）
- 免密登录：`ssh -F /home/wiggens/ssh-vmiss/.ssh/config root@45.221.115.138`
- 加固：1G swap + journald 限容 50M（swap 已持久化到 fstab）
- 同机还跑着 xray/x-ui（443/2096/54321 端口），与博客互不影响
