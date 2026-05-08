# 个人网站开发实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 仿照 antfu.me 的清新博客风格，构建一个技术博客 + 作品集个人网站

**Architecture:** Astro SSG + React 岛屿组件 + Tailwind CSS + MDX 内容。Astro 负责静态生成和路由，React 负责交互组件（标签筛选、主题切换等），Tailwind CSS 负责样式系统，MDX 负责博客内容渲染。

**Tech Stack:** Astro 6.x, React 19, Tailwind CSS 4.x, MDX, Shiki (代码高亮)

---

## antfu.me 风格特征提取

### 布局特征
- 顶部左侧 Logo + 右侧导航栏（文字链接 + 图标链接混排）
- 内容区域居中，最大宽度约 `prose`（65ch），大量留白
- 页面切换有 slide-enter 动画（从下方滑入）
- 右下角回到顶部按钮（滚动超过 300px 后显示）
- 底部简洁版权信息

### 配色特征
- 亮色：白底 `#FFFFFF`，黑字，灰色辅助文字 `op50`
- 暗色：黑底 `#000000`，白字
- 强调色：无强烈强调色，靠透明度（opacity）区分层级
- 链接：默认 `op60`，hover 时 `op100`

### 字体特征
- 正文：Inter（无衬线）
- 代码：DM Mono（等宽）
- 标题：Roboto Condensed（紧凑无衬线）

### 交互特征
- 导航链接 hover 透明度变化
- 页面切换 slide 动画
- 图片点击放大预览
- 暗色/亮色主题切换
- 回到顶部按钮

### 内容结构
- 首页：个人介绍 + 社交链接
- 博客列表：按年份分组，每条显示标题 + 日期 + 阅读时间 + 语言标签
- 博客详情：prose 排版 + 代码高亮
- 项目页：分类卡片展示

---

## 文件结构规划

```
WebPage/
├── public/
│   ├── favicon.svg
│   └── fonts/                    # 本地字体文件（可选）
├── src/
│   ├── components/
│   │   ├── layout/
│   │   │   ├── Header.astro      # 顶部导航栏
│   │   │   ├── Footer.astro      # 底部版权
│   │   │   └── BackToTop.astro   # 回到顶部按钮
│   │   ├── blog/
│   │   │   ├── BlogList.astro    # 博客列表（按年分组）
│   │   │   ├── BlogItem.astro    # 单条博客条目
│   │   │   └── TagList.astro     # 标签列表
│   │   ├── projects/
│   │   │   ├── ProjectCard.astro # 项目卡片
│   │   │   └── ProjectList.astro # 项目列表
│   │   ├── ui/
│   │   │   ├── ThemeToggle.tsx   # 主题切换（React 岛屿）
│   │   │   └── Prose.astro       # 内容排版容器
│   │   └── icons/
│   │       └── Icon.astro        # SVG 图标组件
│   ├── content/
│   │   ├── blog/                 # 博客 MDX 文件
│   │   │   └── building-personal-website-from-scratch.md
│   │   └── projects/             # 作品 MDX 文件
│   ├── layouts/
│   │   ├── BaseLayout.astro      # 基础布局（head + header + footer）
│   │   └── BlogPostLayout.astro  # 博客文章布局
│   ├── pages/
│   │   ├── index.astro           # 首页
│   │   ├── blog/
│   │   │   ├── index.astro       # 博客列表页
│   │   │   └── [...slug].astro   # 博客详情页
│   │   ├── projects/
│   │   │   ├── index.astro       # 作品集列表页
│   │   │   └── [...slug].astro   # 作品详情页
│   │   └── about.astro           # 关于我
│   ├── styles/
│   │   └── global.css            # 全局样式 + Tailwind 指令
│   └── config.ts                 # 站点配置
├── astro.config.mjs
├── tailwind.config.mjs
├── tsconfig.json
└── package.json
```

---

## Task 1: 安装依赖和集成配置

**Files:**
- Modify: `package.json`
- Modify: `astro.config.mjs`
- Create: `tailwind.config.mjs`
- Create: `src/styles/global.css`
- Modify: `src/config.ts` (rename from nothing, create new)

- [ ] **Step 1: 安装核心依赖**

```bash
cd /Users/wxhu/Documents/TRAE_workspace/WebPage
npx astro add react tailwind mdx -y
```

- [ ] **Step 2: 安装额外依赖**

```bash
npm install shiki @astrojs/sitemap
```

- [ ] **Step 3: 验证安装成功**

```bash
npm run build
```

Expected: 构建成功无报错

- [ ] **Step 4: 配置 astro.config.mjs**

```javascript
// @ts-check
import { defineConfig } from 'astro/config';
import react from '@astrojs/react';
import tailwind from '@astrojs/tailwind';
import mdx from '@astrojs/mdx';
import sitemap from '@astrojs/sitemap';

export default defineConfig({
  site: 'https://8bitcloudbot.github.io',
  base: '/portfolio',
  output: 'static',
  integrations: [
    react(),
    tailwind(),
    mdx(),
    sitemap(),
  ],
  markdown: {
    shikiConfig: {
      theme: 'github-light',
      wrap: true,
    },
  },
});
```

- [ ] **Step 5: 配置 tailwind.config.mjs**

```javascript
/** @type {import('tailwindcss').Config} */
export default {
  content: ['./src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}'],
  darkMode: 'class',
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter', 'system-ui', '-apple-system', 'sans-serif'],
        mono: ['DM Mono', 'Menlo', 'Monaco', 'Consolas', 'monospace'],
        condensed: ['Roboto Condensed', 'sans-serif'],
      },
      colors: {
        base: {
          DEFAULT: 'rgb(var(--color-base) / <alpha-value>)',
        },
      },
      maxWidth: {
        prose: '65ch',
      },
      animation: {
        'slide-enter': 'slide-enter 0.6s ease-out both',
      },
      keyframes: {
        'slide-enter': {
          '0%': { transform: 'translateY(20px)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' },
        },
      },
    },
  },
  plugins: [],
};
```

- [ ] **Step 6: 创建全局样式 src/styles/global.css**

```css
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
    --color-base: 0 0 0;
    --color-bg: 255 255 255;
  }

  .dark {
    --color-base: 255 255 255;
    --color-bg: 0 0 0;
  }

  html {
    scroll-behavior: smooth;
  }

  body {
    @apply bg-[rgb(var(--color-bg))] text-[rgb(var(--color-base))] font-sans antialiased;
    transition: background-color 0.3s ease, color 0.3s ease;
  }

  a {
    @apply opacity-60 hover:opacity-100 transition-opacity duration-200;
  }

  ::selection {
    @apply bg-blue-500/20;
  }
}

@layer components {
  .prose-custom {
    @apply max-w-prose mx-auto;
  }

  .prose-custom h1 {
    @apply text-3xl font-bold mt-8 mb-4;
  }

  .prose-custom h2 {
    @apply text-2xl font-bold mt-6 mb-3;
  }

  .prose-custom h3 {
    @apply text-xl font-bold mt-5 mb-2;
  }

  .prose-custom p {
    @apply my-4 leading-7;
  }

  .prose-custom a {
    @apply underline underline-offset-4 opacity-100 hover:text-blue-500;
  }

  .prose-custom code {
    @apply font-mono text-sm bg-gray-100 dark:bg-gray-800 px-1.5 py-0.5 rounded;
  }

  .prose-custom pre {
    @apply my-4 rounded-lg overflow-x-auto;
  }

  .prose-custom pre code {
    @apply bg-transparent px-0 py-0;
  }

  .prose-custom ul {
    @apply list-disc pl-6 my-4;
  }

  .prose-custom ol {
    @apply list-decimal pl-6 my-4;
  }

  .prose-custom li {
    @apply my-1 leading-7;
  }

  .prose-custom blockquote {
    @apply border-l-3 border-gray-300 dark:border-gray-700 pl-4 my-4 opacity-80;
  }

  .prose-custom img {
    @apply rounded-lg my-4;
  }

  .prose-custom hr {
    @apply my-8 border-gray-200 dark:border-gray-800;
  }

  .prose-custom table {
    @apply w-full my-4;
  }

  .prose-custom th {
    @apply text-left font-bold py-2 px-3 border-b border-gray-200 dark:border-gray-800;
  }

  .prose-custom td {
    @apply py-2 px-3 border-b border-gray-200 dark:border-gray-800;
  }
}
```

- [ ] **Step 7: 创建站点配置 src/config.ts**

```typescript
export const SITE = {
  title: "8BitcloudBot",
  description: "A fanatical open sourceror and design engineer.",
  author: "8BitcloudBot",
  email: "17889786156@163.com",
  github: "https://github.com/8BitcloudBot",
  nav: [
    { name: "Blog", path: "/blog", icon: "article" },
    { name: "Projects", path: "/projects", icon: "lightbulb" },
    { name: "About", path: "/about", icon: "user" },
  ],
  social: [
    { name: "GitHub", url: "https://github.com/8BitcloudBot", icon: "github" },
  ],
};
```

- [ ] **Step 8: 验证构建**

```bash
npm run build
```

Expected: 构建成功

- [ ] **Step 9: 提交**

```bash
git add .
git commit -m "feat: add React, Tailwind, MDX integrations and base config"
```

---

## Task 2: 基础布局组件

**Files:**
- Create: `src/components/layout/Header.astro`
- Create: `src/components/layout/Footer.astro`
- Create: `src/components/layout/BackToTop.astro`
- Create: `src/components/ui/ThemeToggle.tsx`
- Create: `src/components/icons/Icon.astro`
- Create: `src/layouts/BaseLayout.astro`

- [ ] **Step 1: 创建 Icon 组件 src/components/icons/Icon.astro**

内联 SVG 图标组件，支持常用图标（仿 antfu.me 使用 Iconify 图标风格）：

```astro
---
interface Props {
  name: string;
  class?: string;
}

const { name, class: className = '' } = Astro.props;

const icons: Record<string, string> = {
  article: '<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" viewBox="0 0 24 24"><path fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4h16v16H4zm4 4h8m-8 4h8m-8 4h4"/></svg>',
  lightbulb: '<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" viewBox="0 0 24 24"><path fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 18h6m-5 4h4M12 2a7 7 0 0 0-4 12.7V17h8v-2.3A7 7 0 0 0 12 2z"/></svg>',
  user: '<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" viewBox="0 0 24 24"><path fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2m8-10a4 4 0 1 0 0-8 4 4 0 0 0 0 8z"/></svg>',
  github: '<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" viewBox="0 0 24 24"><path fill="currentColor" d="M12 2C6.475 2 2 6.475 2 12c0 4.991 3.657 9.128 8.438 9.879V14.89h-2.54V12h2.54V9.797c0-2.506 1.492-3.89 3.777-3.89 1.094 0 2.238.195 2.238.195v2.46h-1.26c-1.243 0-1.63.771-1.63 1.562V12h2.773l-.443 2.89h-2.33v6.989C18.343 21.129 22 16.99 22 12c0-5.523-4.477-10-10-10z"/></svg>',
  sun: '<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" viewBox="0 0 24 24"><path fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 1 1-8 0 4 4 0 0 1 8 0z"/></svg>',
  moon: '<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" viewBox="0 0 24 24"><path fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/></svg>',
  arrowUp: '<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" viewBox="0 0 24 24"><path fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 15l7-7 7 7"/></svg>',
  rss: '<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" viewBox="0 0 24 24"><path fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 11a9 9 0 0 1 9 9m-9-5a5 5 0 0 1 5 5m-5-1a1 1 0 1 1 0 2a1 1 0 0 1 0-2z"/></svg>',
};
---

<span class:list={["inline-block w-[1.2em] h-[1.2em] align-text-bottom", className]} set:html={icons[name] || ''} />
```

- [ ] **Step 2: 创建 ThemeToggle 组件 src/components/ui/ThemeToggle.tsx**

React 岛屿组件，负责暗色/亮色切换：

```tsx
import { useState, useEffect } from 'react';

export default function ThemeToggle() {
  const [isDark, setIsDark] = useState(false);

  useEffect(() => {
    const stored = localStorage.getItem('theme');
    const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
    const dark = stored === 'dark' || (!stored && prefersDark);
    setIsDark(dark);
    document.documentElement.classList.toggle('dark', dark);
  }, []);

  function toggle() {
    const next = !isDark;
    setIsDark(next);
    document.documentElement.classList.toggle('dark', next);
    localStorage.setItem('theme', next ? 'dark' : 'light');
  }

  return (
    <button
      onClick={toggle}
      title={isDark ? 'Switch to light mode' : 'Switch to dark mode'}
      className="opacity-60 hover:opacity-100 transition-opacity duration-200 cursor-pointer"
    >
      {isDark ? (
        <svg xmlns="http://www.w3.org/2000/svg" width="1.2em" height="1.2em" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="5"/><line x1="12" y1="1" x2="12" y2="3"/><line x1="12" y1="21" x2="12" y2="23"/><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"/><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"/><line x1="1" y1="12" x2="3" y2="12"/><line x1="21" y1="12" x2="23" y2="12"/><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"/><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"/></svg>
      ) : (
        <svg xmlns="http://www.w3.org/2000/svg" width="1.2em" height="1.2em" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/></svg>
      )}
    </button>
  );
}
```

- [ ] **Step 3: 创建 Header 组件 src/components/layout/Header.astro**

仿 antfu.me 导航栏：左侧 Logo，右侧导航链接 + 图标 + 主题切换：

```astro
---
import Icon from '../icons/Icon.astro';
import ThemeToggle from '../ui/ThemeToggle.tsx';
import { SITE } from '../../config';

const currentPath = Astro.url.pathname;
---

<header class="z-40">
  <nav class="px-8 py-6 w-full grid grid-cols-[auto_max-content] box-border">
    <div></div>
    <div class="flex items-center gap-5">
      {SITE.nav.map((item) => (
        <a
          href={item.path}
          class:list={[
            'no-underline! transition-opacity duration-200',
            currentPath.startsWith(item.path) ? 'opacity-100!' : 'opacity-60 hover:opacity-100',
          ]}
        >
          <span class="hidden md:inline">{item.name}</span>
          <span class="md:hidden"><Icon name={item.icon} /></span>
        </a>
      ))}
      {SITE.social.map((item) => (
        <a
          href={item.url}
          target="_blank"
          rel="noopener noreferrer"
          title={item.name}
          class="opacity-60 hover:opacity-100 transition-opacity duration-200 hidden md:inline-block"
        >
          <Icon name={item.icon.toLowerCase()} />
        </a>
      ))}
      <ThemeToggle client:load />
    </div>
  </nav>
</header>
```

- [ ] **Step 4: 创建 Footer 组件 src/components/layout/Footer.astro**

```astro
---
const year = new Date().getFullYear();
---

<div class="mt-10 mb-6 max-w-prose mx-auto flex slide-enter animate-delay-1200!">
  <span class="text-sm opacity-50">&copy; 2024-{year} 8BitcloudBot</span>
  <div class="flex-auto"></div>
</div>
```

- [ ] **Step 5: 创建 BackToTop 组件 src/components/layout/BackToTop.astro**

```astro
---
import Icon from '../icons/Icon.astro';
---

<button
  id="back-to-top"
  title="Scroll to top"
  class="fixed right-3 bottom-3 w-10 h-10 rounded-full hover:bg-gray-500/10 transition duration-300 z-100 print:hidden opacity-0 pointer-events-none"
>
  <Icon name="arrowUp" />
</button>

<script>
  const btn = document.getElementById('back-to-top');
  if (btn) {
    window.addEventListener('scroll', () => {
      if (window.scrollY > 300) {
        btn.classList.remove('opacity-0', 'pointer-events-none');
        btn.classList.add('opacity-30');
      } else {
        btn.classList.add('opacity-0', 'pointer-events-none');
        btn.classList.remove('opacity-30');
      }
    });
    btn.addEventListener('click', () => {
      window.scrollTo({ top: 0, behavior: 'smooth' });
    });
    btn.addEventListener('mouseenter', () => {
      btn.classList.remove('opacity-30');
      btn.classList.add('opacity-100');
    });
    btn.addEventListener('mouseleave', () => {
      btn.classList.remove('opacity-100');
      btn.classList.add('opacity-30');
    });
  }
</script>
```

- [ ] **Step 6: 创建 BaseLayout 布局 src/layouts/BaseLayout.astro**

```astro
---
import Header from '../components/layout/Header.astro';
import Footer from '../components/layout/Footer.astro';
import BackToTop from '../components/layout/BackToTop.astro';
import { SITE } from '../config';

interface Props {
  title?: string;
  description?: string;
}

const { title = SITE.title, description = SITE.description } = Astro.props;
---

<!doctype html>
<html lang="zh-CN">
  <head>
    <meta charset="utf-8" />
    <link rel="icon" type="image/svg+xml" href="/favicon.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="generator" content={Astro.generator} />
    <title>{title}</title>
    <meta name="description" content={description} />
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/css2?family=DM+Mono:wght@400;500&family=Inter:wght@400;500;600;700&family=Roboto+Condensed:wght@700&display=swap" rel="stylesheet" />
    <script is:inline>
      const stored = localStorage.getItem('theme');
      const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
      if (stored === 'dark' || (!stored && prefersDark)) {
        document.documentElement.classList.add('dark');
      }
    </script>
  </head>
  <body class="min-h-screen">
    <Header />
    <main class="px-7 py-10 overflow-x-hidden">
      <slot />
      <Footer />
    </main>
    <BackToTop />
  </body>
</html>
```

- [ ] **Step 7: 验证构建**

```bash
npm run build
```

- [ ] **Step 8: 提交**

```bash
git add .
git commit -m "feat: add base layout components (Header, Footer, BackToTop, ThemeToggle)"
```

---

## Task 3: 首页

**Files:**
- Modify: `src/pages/index.astro`

- [ ] **Step 1: 重写首页 src/pages/index.astro**

仿 antfu.me 首页风格：个人介绍 + 社交链接，简洁大方：

```astro
---
import BaseLayout from '../layouts/BaseLayout.astro';
import Icon from '../components/icons/Icon.astro';
import { SITE } from '../config';
---

<BaseLayout title={SITE.title} description={SITE.description}>
  <div class="max-w-prose mx-auto animate-slide-enter">
    <div class="mb-8">
      <h1 class="text-4xl font-bold font-condensed mb-4">Hey!</h1>
      <p class="text-lg leading-8 opacity-80">
        I'm <span class="font-semibold opacity-100">8BitcloudBot</span>, a passionate developer who loves building things for the web.
      </p>
      <p class="text-lg leading-8 opacity-80 mt-4">
        I enjoy exploring new technologies, writing code, and sharing what I learn.
        You can find my <a href="/blog" class="underline underline-offset-4 opacity-100 hover:text-blue-500">blog posts</a>,
        <a href="/projects" class="underline underline-offset-4 opacity-100 hover:text-blue-500">projects</a>,
        and more on this site.
      </p>
    </div>

    <div class="flex items-center gap-4 mt-8">
      {SITE.social.map((item) => (
        <a
          href={item.url}
          target="_blank"
          rel="noopener noreferrer"
          title={item.name}
          class="opacity-50 hover:opacity-100 transition-opacity duration-200 text-xl"
        >
          <Icon name={item.icon.toLowerCase()} />
        </a>
      ))}
    </div>
  </div>
</BaseLayout>
```

- [ ] **Step 2: 本地预览验证**

```bash
npm run dev
```

访问 http://localhost:4321/portfolio/ 确认首页显示正常

- [ ] **Step 3: 提交**

```bash
git add .
git commit -m "feat: implement homepage with personal intro and social links"
```

---

## Task 4: 博客系统

**Files:**
- Create: `src/content/config.ts`
- Create: `src/components/blog/BlogList.astro`
- Create: `src/components/blog/BlogItem.astro`
- Create: `src/pages/blog/index.astro`
- Create: `src/pages/blog/[...slug].astro`
- Create: `src/layouts/BlogPostLayout.astro`
- Modify: `src/content/blog/building-personal-website-from-scratch.md` (添加 frontmatter)

- [ ] **Step 1: 创建内容集合配置 src/content/config.ts**

```typescript
import { defineCollection, z } from 'astro:content';

const blog = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    description: z.string(),
    pubDate: z.coerce.date(),
    updatedDate: z.coerce.date().optional(),
    tags: z.array(z.string()).default([]),
    lang: z.enum(['zh', 'en']).default('zh'),
    readingTime: z.number().optional(),
  }),
});

const projects = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    description: z.string(),
    pubDate: z.coerce.date(),
    tags: z.array(z.string()).default([]),
    github: z.string().optional(),
    url: z.string().optional(),
    image: z.string().optional(),
  }),
});

export const collections = { blog, projects };
```

- [ ] **Step 2: 更新已有博客文章的 frontmatter**

在 `src/content/blog/building-personal-website-from-scratch.md` 的 frontmatter 中添加必要字段（确保与 schema 匹配）。

- [ ] **Step 3: 创建 BlogItem 组件 src/components/blog/BlogItem.astro**

```astro
---
interface Props {
  title: string;
  href: string;
  date: Date;
  readingTime?: number;
  lang?: string;
  tags?: string[];
}

const { title, href, date, readingTime, lang = 'zh', tags = [] } = Astro.props;

const formattedDate = date.toLocaleDateString(lang === 'zh' ? 'zh-CN' : 'en-US', {
  year: 'numeric',
  month: 'short',
  day: 'numeric',
});
---

<a
  href={href}
  class="block py-2 group no-underline! transition-opacity duration-200 opacity-80 hover:opacity-100"
>
  <div class="flex items-baseline gap-3">
    <span class="text-sm opacity-50 font-mono shrink-0">{formattedDate}</span>
    <span class="text-base group-hover:text-blue-500 transition-colors duration-200">{title}</span>
    {readingTime && (
      <span class="text-xs opacity-40 shrink-0">{readingTime}min</span>
    )}
    {lang === 'en' && (
      <span class="text-xs opacity-40 border border-current rounded px-1 shrink-0">EN</span>
    )}
  </div>
</a>
```

- [ ] **Step 4: 创建 BlogList 组件 src/components/blog/BlogList.astro**

按年份分组显示博客列表：

```astro
---
import BlogItem from './BlogItem.astro';
import type { CollectionEntry } from 'astro:content';

interface Props {
  posts: CollectionEntry<'blog'>[];
}

const { posts } = Astro.props;

const sorted = posts.sort((a, b) => b.data.pubDate.getTime() - a.data.pubDate.getTime());

const grouped = sorted.reduce<Record<number, CollectionEntry<'blog'>[]>>((acc, post) => {
  const year = post.data.pubDate.getFullYear();
  if (!acc[year]) acc[year] = [];
  acc[year].push(post);
  return acc;
}, {});

const years = Object.keys(grouped).map(Number).sort((a, b) => b - a);
---

<div class="max-w-prose mx-auto animate-slide-enter">
  {years.map((year) => (
    <div class="mb-8">
      <h2 class="text-2xl font-bold font-condensed opacity-50 mb-2">{year}</h2>
      <div class="divide-y divide-gray-200 dark:divide-gray-800">
        {grouped[year].map((post) => (
          <BlogItem
            title={post.data.title}
            href={`/blog/${post.id}`}
            date={post.data.pubDate}
            readingTime={post.data.readingTime}
            lang={post.data.lang}
            tags={post.data.tags}
          />
        ))}
      </div>
    </div>
  ))}
</div>
```

- [ ] **Step 5: 创建博客列表页 src/pages/blog/index.astro**

```astro
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import BlogList from '../../components/blog/BlogList.astro';
import { getCollection } from 'astro:content';

const posts = await getCollection('blog');
---

<BaseLayout title="Blog | 8BitcloudBot" description="Blog posts about coding, open source, and more.">
  <BlogList posts={posts} />
</BaseLayout>
```

- [ ] **Step 6: 创建博客文章布局 src/layouts/BlogPostLayout.astro**

```astro
---
import BaseLayout from './BaseLayout.astro';
import Icon from '../components/icons/Icon.astro';

interface Props {
  title: string;
  date: Date;
  tags?: string[];
  readingTime?: number;
  lang?: string;
}

const { title, date, tags = [], readingTime, lang = 'zh' } = Astro.props;

const formattedDate = date.toLocaleDateString(lang === 'zh' ? 'zh-CN' : 'en-US', {
  year: 'numeric',
  month: 'long',
  day: 'numeric',
});
---

<BaseLayout title={`${title} | 8BitcloudBot`}>
  <article class="max-w-prose mx-auto animate-slide-enter">
    <header class="mb-8">
      <h1 class="text-3xl font-bold font-condensed mb-3">{title}</h1>
      <div class="flex items-center gap-3 text-sm opacity-50">
        <time datetime={date.toISOString()}>{formattedDate}</time>
        {readingTime && <span>{readingTime} min read</span>}
        {tags.length > 0 && (
          <div class="flex gap-2">
            {tags.map((tag) => (
              <span class="border border-current rounded px-1.5 py-0.5 text-xs">{tag}</span>
            ))}
          </div>
        )}
      </div>
    </header>
    <div class="prose-custom">
      <slot />
    </div>
  </article>
</BaseLayout>
```

- [ ] **Step 7: 创建博客详情页 src/pages/blog/[...slug].astro**

```astro
---
import { getCollection } from 'astro:content';
import BlogPostLayout from '../../layouts/BlogPostLayout.astro';

export async function getStaticPaths() {
  const posts = await getCollection('blog');
  return posts.map((post) => ({
    params: { slug: post.id },
    props: post,
  }));
}

const post = Astro.props;
const { Content } = await post.render();
---

<BlogPostLayout
  title={post.data.title}
  date={post.data.pubDate}
  tags={post.data.tags}
  readingTime={post.data.readingTime}
  lang={post.data.lang}
>
  <Content />
</BlogPostLayout>
```

- [ ] **Step 8: 验证博客系统**

```bash
npm run dev
```

访问 http://localhost:4321/portfolio/blog 确认列表页显示
访问 http://localhost:4321/portfolio/blog/building-personal-website-from-scratch 确认文章页显示

- [ ] **Step 9: 提交**

```bash
git add .
git commit -m "feat: implement blog system with list and detail pages"
```

---

## Task 5: 作品集系统

**Files:**
- Create: `src/components/projects/ProjectCard.astro`
- Create: `src/components/projects/ProjectList.astro`
- Create: `src/pages/projects/index.astro`
- Create: `src/pages/projects/[...slug].astro`
- Create: `src/content/projects/hello-world.mdx` (示例项目)

- [ ] **Step 1: 创建示例项目文件 src/content/projects/hello-world.mdx**

```mdx
---
title: "Portfolio Website"
description: "My personal website built with Astro, React, and Tailwind CSS."
pubDate: 2026-04-24
tags: ["Astro", "React", "Tailwind CSS", "TypeScript"]
github: "https://github.com/8BitcloudBot/portfolio"
---

A personal website for showcasing blog posts and projects. Built with modern web technologies for optimal performance and developer experience.
```

- [ ] **Step 2: 创建 ProjectCard 组件 src/components/projects/ProjectCard.astro**

```astro
---
interface Props {
  title: string;
  description: string;
  href: string;
  tags?: string[];
  github?: string;
}

const { title, description, href, tags = [], github } = Astro.props;
---

<a
  href={href}
  class="block p-5 rounded-lg border border-gray-200 dark:border-gray-800 hover:border-blue-500/50 transition-all duration-200 no-underline! opacity-80 hover:opacity-100 group"
>
  <h3 class="text-lg font-semibold mb-2 group-hover:text-blue-500 transition-colors duration-200">{title}</h3>
  <p class="text-sm opacity-60 mb-3 leading-6">{description}</p>
  <div class="flex items-center gap-2 flex-wrap">
    {tags.map((tag) => (
      <span class="text-xs border border-gray-300 dark:border-gray-700 rounded px-1.5 py-0.5 opacity-50">{tag}</span>
    ))}
    {github && (
      <span class="ml-auto opacity-40 hover:opacity-100">
        <svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" viewBox="0 0 24 24"><path fill="currentColor" d="M12 2C6.475 2 2 6.475 2 12c0 4.991 3.657 9.128 8.438 9.879V14.89h-2.54V12h2.54V9.797c0-2.506 1.492-3.89 3.777-3.89 1.094 0 2.238.195 2.238.195v2.46h-1.26c-1.243 0-1.63.771-1.63 1.562V12h2.773l-.443 2.89h-2.33v6.989C18.343 21.129 22 16.99 22 12c0-5.523-4.477-10-10-10z"/></svg>
      </span>
    )}
  </div>
</a>
```

- [ ] **Step 3: 创建 ProjectList 组件 src/components/projects/ProjectList.astro**

```astro
---
import ProjectCard from './ProjectCard.astro';
import type { CollectionEntry } from 'astro:content';

interface Props {
  projects: CollectionEntry<'projects'>[];
}

const { projects } = Astro.props;

const sorted = projects.sort((a, b) => b.data.pubDate.getTime() - a.data.pubDate.getTime());
---

<div class="max-w-prose mx-auto animate-slide-enter">
  <div class="grid gap-4">
    {sorted.map((project) => (
      <ProjectCard
        title={project.data.title}
        description={project.data.description}
        href={`/projects/${project.id}`}
        tags={project.data.tags}
        github={project.data.github}
      />
    ))}
  </div>
</div>
```

- [ ] **Step 4: 创建项目列表页 src/pages/projects/index.astro**

```astro
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import ProjectList from '../../components/projects/ProjectList.astro';
import { getCollection } from 'astro:content';

const projects = await getCollection('projects');
---

<BaseLayout title="Projects | 8BitcloudBot" description="Projects I've built and maintained.">
  <ProjectList projects={projects} />
</BaseLayout>
```

- [ ] **Step 5: 创建项目详情页 src/pages/projects/[...slug].astro**

```astro
---
import { getCollection } from 'astro:content';
import BlogPostLayout from '../../layouts/BlogPostLayout.astro';

export async function getStaticPaths() {
  const projects = await getCollection('projects');
  return projects.map((project) => ({
    params: { slug: project.id },
    props: project,
  }));
}

const project = Astro.props;
const { Content } = await project.render();
---

<BlogPostLayout
  title={project.data.title}
  date={project.data.pubDate}
  tags={project.data.tags}
>
  <Content />
</BlogPostLayout>
```

- [ ] **Step 6: 验证作品集系统**

```bash
npm run dev
```

访问 http://localhost:4321/portfolio/projects 确认列表页
访问 http://localhost:4321/portfolio/projects/hello-world 确认详情页

- [ ] **Step 7: 提交**

```bash
git add .
git commit -m "feat: implement projects system with list and detail pages"
```

---

## Task 6: 关于我页面

**Files:**
- Create: `src/pages/about.astro`

- [ ] **Step 1: 创建关于我页面 src/pages/about.astro**

```astro
---
import BaseLayout from '../layouts/BaseLayout.astro';
import Icon from '../components/icons/Icon.astro';
import { SITE } from '../config';
---

<BaseLayout title="About | 8BitcloudBot" description="About me.">
  <div class="max-w-prose mx-auto animate-slide-enter">
    <h1 class="text-3xl font-bold font-condensed mb-6">About Me</h1>

    <div class="prose-custom">
      <p>
        Hey! I'm <strong>8BitcloudBot</strong>, a passionate developer who loves building things for the web.
      </p>
      <p>
        I enjoy exploring new technologies, solving problems, and sharing what I learn with the community.
        This site is where I document my journey — blog posts, projects, and thoughts on software development.
      </p>
      <p>
        Outside of programming, I enjoy reading, gaming, and exploring new things.
      </p>
    </div>

    <div class="mt-10">
      <h2 class="text-xl font-bold font-condensed mb-4 opacity-60">Find me on</h2>
      <div class="flex items-center gap-4">
        {SITE.social.map((item) => (
          <a
            href={item.url}
            target="_blank"
            rel="noopener noreferrer"
            title={item.name}
            class="opacity-50 hover:opacity-100 transition-opacity duration-200 text-xl"
          >
            <Icon name={item.icon.toLowerCase()} />
          </a>
        ))}
      </div>
    </div>
  </div>
</BaseLayout>
```

- [ ] **Step 2: 验证**

```bash
npm run dev
```

访问 http://localhost:4321/portfolio/about

- [ ] **Step 3: 提交**

```bash
git add .
git commit -m "feat: add about page"
```

---

## Task 7: SEO 和元信息优化

**Files:**
- Modify: `src/layouts/BaseLayout.astro`
- Create: `src/components/ui/SEO.astro`

- [ ] **Step 1: 创建 SEO 组件 src/components/ui/SEO.astro**

```astro
---
interface Props {
  title: string;
  description?: string;
  image?: string;
  article?: boolean;
  pubDate?: Date;
}

const { title, description, image, article = false, pubDate } = Astro.props;
const canonicalURL = new URL(Astro.url.pathname, Astro.site);
---

<!-- Primary Meta Tags -->
<title>{title}</title>
<meta name="title" content={title} />
<meta name="description" content={description} />
<link rel="canonical" href={canonicalURL} />

<!-- Open Graph / Facebook -->
<meta property="og:type" content={article ? 'article' : 'website'} />
<meta property="og:url" content={canonicalURL} />
<meta property="og:title" content={title} />
<meta property="og:description" content={description} />
{image && <meta property="og:image" content={new URL(image, Astro.site)} />}

<!-- Twitter -->
<meta property="twitter:card" content="summary_large_image" />
<meta property="twitter:url" content={canonicalURL} />
<meta property="twitter:title" content={title} />
<meta property="twitter:description" content={description} />
{image && <meta property="twitter:image" content={new URL(image, Astro.site)} />}

{article && pubDate && (
  <meta property="article:published_time" content={pubDate.toISOString()} />
)}
```

- [ ] **Step 2: 在 BaseLayout 中集成 SEO 组件**

在 BaseLayout.astro 的 `<head>` 中替换原有的 title 和 meta 标签，使用 SEO 组件。

- [ ] **Step 3: 验证构建**

```bash
npm run build
```

- [ ] **Step 4: 提交**

```bash
git add .
git commit -m "feat: add SEO component with Open Graph and Twitter meta tags"
```

---

## Task 8: 最终验证和部署

**Files:**
- None new

- [ ] **Step 1: 完整构建验证**

```bash
npm run build
npm run preview
```

访问所有页面确认无报错

- [ ] **Step 2: 推送到 GitHub 触发自动部署**

```bash
git push origin main
```

- [ ] **Step 3: 验证线上访问**

访问 https://8bitcloudbot.github.io/portfolio/ 确认所有页面正常

- [ ] **Step 4: 同步到阿里云服务器**

```bash
rsync -avz --delete dist/ root@服务器IP:/var/www/portfolio/
```

- [ ] **Step 5: 验证阿里云服务器访问**

访问 http://服务器IP 确认页面正常

- [ ] **Step 6: 最终提交**

```bash
git add .
git commit -m "chore: final verification and deployment"
```
