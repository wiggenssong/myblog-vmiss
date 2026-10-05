import { defineThemeConfig } from 'vuepress-theme-plume'

export default defineThemeConfig({
  // 侧边栏个人资料卡片（博客页右侧）
  profile: {
    name: 'wiggens',
    description: '日常记录',
    avatar: '/avatar.jpg', // 头像图片在 .vuepress/public/avatar.jpg
    circle: true,
    layout: 'right',
  },

  // 社交链接（不需要可删掉；图标由 iconify 提供）
  social: [
    // { icon: 'github', link: 'https://github.com/yourname' },
  ],

  // 导航栏
  navbar: [
    { text: '首页', link: '/' },
    { text: '博客', link: '/blog/' },
    { text: '标签', link: '/blog/tags/' },
    { text: '归档', link: '/blog/archives/' },
    { text: '关于', link: '/about/' },
  ],

  // 文章集合：docs/blog/ 目录下的文章，自动生成列表/分类/标签/归档页
  collections: [
    {
      type: 'post',
      dir: 'blog',
      title: '博客',
      link: '/blog/',
      pagination: 10, // 列表每页文章数
      categories: true, // 分类页（按子目录/分类自动生成）
      tags: true, // 标签页（按 frontmatter.tags 生成）
      archives: true, // 归档页（按时间线）
    },
  ],

  // 页脚
  footer: {
    message: '用 ❤️ 与 VuePress & Plume 构建',
    copyright: '© 2026 wiggens',
  },
})
