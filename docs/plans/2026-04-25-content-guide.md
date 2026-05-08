# 网站内容新增指南

本指南说明如何在网站中新增各类内容，包括博客文章、项目、照片等。

## 目录结构

```
WebPage/
├── public/             # 静态资源
│   ├── photos/         # 照片/壁纸
│   └── favicon.svg     # 网站图标
├── src/
│   ├── content/        # 内容集合
│   │   ├── blog/       # 博客文章
│   │   └── projects/   # 项目文档
│   ├── pages/          # 页面组件
│   │   ├── blog/       # 博客相关页面
│   │   ├── projects/   # 项目相关页面
│   │   ├── photos/     # 照片页面
│   │   ├── about.astro # 关于页面
│   │   └── index.astro # 首页
│   └── components/     # 可复用组件
└── docs/               # 文档
    └── plans/          # 计划文档
```

## 1. 新增博客文章

### 步骤：
1. **创建文件**：在 `src/content/blog/` 目录下创建 Markdown 文件，如 `my-new-post.md`

2. **添加 Frontmatter**：文件开头添加必要的元数据
   ```yaml
   ---  
title: "文章标题"
description: "文章描述"
date: 2026-04-25
lang: "zh" # 或 "en"
tags: ["前端", "Astro"]
---
   ```

3. **编写内容**：使用 Markdown 语法编写文章内容，支持 MDX 组件

4. **构建验证**：运行 `npm run build` 确保生成成功

### 示例文件：
- [src/content/blog/building-personal-website-from-scratch.md](file:///Users/wxhu/Documents/TRAE_workspace/WebPage/src/content/blog/building-personal-website-from-scratch.md)

## 2. 新增项目

### 步骤：
1. **创建文件**：在 `src/content/projects/` 目录下创建 Markdown/MDX 文件，如 `my-project.mdx`

2. **添加 Frontmatter**：
   ```yaml
   ---  
title: "项目名称"
description: "项目描述"
date: 2026-04-25
github: "https://github.com/用户名/仓库名" # 可选
tags: ["React", "TypeScript"]
---
   ```

3. **编写内容**：介绍项目功能、技术栈、使用方法等

4. **构建验证**：运行 `npm run build`

### 示例文件：
- [src/content/projects/portfolio-website.mdx](file:///Users/wxhu/Documents/TRAE_workspace/WebPage/src/content/projects/portfolio-website.mdx)

## 3. 新增照片/壁纸

### 步骤：
1. **添加图片**：将图片文件（.jpg/.png/.webp）放入 `public/photos/` 目录

2. **自动显示**：Photos 页面会自动扫描并显示该目录下的所有图片

3. **排序**：按文件名倒序排列（最新的在前）

4. **验证**：访问 `/photos` 页面查看效果

### 图片命名建议：
- 使用 `YYYY-MM-DD-description.jpg` 格式，如 `2026-04-25-mountain-landscape.jpg`
- 避免特殊字符和空格

## 4. 新增页面

### 步骤：
1. **创建组件**：在 `src/pages/` 目录下创建 `.astro` 文件，如 `new-page.astro`

2. **使用布局**：导入并使用 BaseLayout
   ```astro
   ---  
   import BaseLayout from '../layouts/BaseLayout.astro';
   ---
   
   <BaseLayout title="新页面" description="页面描述">
     <!-- 页面内容 -->
   </BaseLayout>
   ```

3. **添加导航**：在 `src/config.ts` 中添加导航项
   ```typescript
   nav: [
     // 现有项...
     { name: "新页面", path: `${base}new-page`, icon: "folder" },
   ]
   ```

4. **构建验证**：运行 `npm run build`

## 5. 自定义样式

### 全局样式：
- 修改 `src/styles/global.css` 文件
- 可添加自定义 CSS 变量和组件样式

### 组件样式：
- 在组件文件中使用 `<style>` 标签添加组件级样式
- 支持 Tailwind CSS 类

## 6. 部署更新

### 本地开发：
```bash
npm run dev
# 访问 http://localhost:4321/portfolio
```

### 构建生产版本：
```bash
npm run build
# 构建产物在 dist/ 目录
```

### 部署到 GitHub Pages：
1. 推送代码到 GitHub 仓库
2. GitHub Actions 会自动构建并部署
3. 访问 `https://8bitcloudbot.github.io/portfolio/`

## 7. 常见问题

### 图片不显示
- 检查图片路径是否正确（`public/photos/` 目录）
- 检查图片格式是否支持（.jpg/.png/.webp）

### 页面 404
- 检查文件路径是否正确
- 运行 `npm run build` 确保页面生成成功
- 检查 GitHub Pages 部署状态

### 样式问题
- 清除浏览器缓存
- 检查 Tailwind CSS 类名是否正确
- 检查 `global.css` 文件是否有语法错误

## 8. 技术支持

- **Astro 文档**：https://docs.astro.build/
- **Tailwind CSS 文档**：https://tailwindcss.com/docs
- **GitHub Pages 文档**：https://docs.github.com/en/pages

---

**最后更新**：2026-04-25
