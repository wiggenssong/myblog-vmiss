import { defineUserConfig } from 'vuepress'
import { viteBundler } from '@vuepress/bundler-vite'
import { plumeTheme } from 'vuepress-theme-plume'

export default defineUserConfig({
  // 站点语言
  lang: 'zh-CN',

  title: '日常记录',
  description: '日常记录',

  // 站点图标（把图标放到 .vuepress/public/ 下）
  head: [
    // ['link', { rel: 'icon', href: '/favicon.svg' }],
    // 不蒜子访问统计脚本
    ['script', { async: '', src: '//busuanzi.ibruce.info/busuanzi/2.3/busuanzi.pure.mini.js' }],
  ],

  // 使用 Vite 作为构建工具
  bundler: viteBundler(),

  // 启用 Plume 主题（具体主题配置在 plume.config.ts，支持热更新）
  theme: plumeTheme(),
})
