---
title: "从零搭建个人网站全记录：规划、环境、部署一条龙"
pubDate: 2025-07-01
description: "记录我从零开始搭建个人技术博客与作品集网站的完整过程，包括技术选型、环境准备、部署方案对比、GitHub Pages 配置、阿里云服务器搭建，以及踩过的每一个坑。"
tags: ["个人网站", "Astro", "GitHub Pages", "阿里云", "部署", "Nginx"]
lang: "zh"
---

# 从零搭建个人网站全记录：规划、环境、部署一条龙

## 前言

这篇文章记录了我从零开始搭建个人技术博客与作品集网站的完整过程。从最初的需求分析、技术选型，到环境搭建、部署上线，每一步决策和踩坑都如实记录。希望对同样想搭建个人网站的朋友有所帮助。

---

## 一、需求分析：我要做什么样的网站？

### 网站定位

经过讨论，确定了网站的核心定位：**技术博客 + 作品集展示**。目标受众是面试官和技术社区的朋友，需要能快速了解我的技术能力和项目经验。

### 核心页面规划

| 路由 | 页面 | 说明 |
|------|------|------|
| `/` | 首页 | 个人介绍 + 精选作品 + 最新文章 |
| `/blog` | 博客列表 | 支持标签/分类筛选 |
| `/blog/[slug]` | 博客详情 | MDX 渲染，支持嵌入组件 |
| `/projects` | 作品集 | 项目卡片展示 |
| `/projects/[slug]` | 作品详情 | 项目介绍 + 技术栈 + 链接 |
| `/about` | 关于我 | 详细自我介绍 |
| `/uses` | 使用的工具 | 技术栈和工具展示 |

### 内容管理方式

选择 **Markdown 文件 + Git** 管理内容，理由：
- 简单可控，无需数据库
- Git 版本管理，可追溯
- 写文章就是写代码，开发者友好
- 后续可扩展接入 CMS

---

## 二、技术选型

### 框架选择：Astro + React

| 候选方案 | 优势 | 劣势 | 结论 |
|----------|------|------|------|
| **Astro + React** | 内容优先、岛屿架构、MDX 支持、首屏极快 | 交互部分需加载 React JS | ✅ 选择 |
| Next.js | 生态成熟、SSR/SSG 都支持 | 博客场景不如 Astro 轻量 | ❌ |
| VitePress / Nuxt | Vue 生态 | 个人更熟悉 React | ❌ |
| 纯静态 HTML | 最简单 | 扩展性差 | ❌ |

**选择 Astro 的核心理由：**
- 天生为内容型网站设计，博客/作品集是它的主场
- 岛屿架构：只有交互部分加载 JS，其余纯 HTML，首屏极快
- MDX 支持：博客文章中可以直接嵌入 React 组件
- GitHub Star 49k+，2025 年静态站点框架中增速最快

### 样式方案：Tailwind CSS

- 原子化 CSS，开发效率高
- 与 Astro 集成良好
- 响应式设计开箱即用

### 视觉风格：简约清新风

| 用途 | 色值 | 说明 |
|------|------|------|
| 主背景 | `#FAFAFA` | 温暖的浅灰白 |
| 卡片背景 | `#FFFFFF` | 纯白 |
| 主文字 | `#1A1A2E` | 深蓝黑 |
| 次文字 | `#6B7280` | 中灰 |
| 强调色 | `#3B82F6` | 蓝色（链接、按钮） |
| 辅助强调 | `#10B981` | 绿色（标签、状态） |
| 代码背景 | `#F3F4F6` | 浅灰 |

字体选择：Inter（标题/正文）+ JetBrains Mono（代码块）

设计原则：大量留白、卡片式布局、圆角 8-12px、微妙阴影和过渡动画、响应式设计。

---

## 三、环境准备

### 已有环境

| 工具 | 版本 | 状态 |
|------|------|------|
| Node.js | v25.1.0 | ✅ |
| npm | 11.6.2 | ✅ |
| Git | 2.51.2 | ✅ |
| Python | 3.14.0 | ✅ |
| Homebrew | 5.1.7 | ✅ |
| Docker | 29.4.0 | ✅ |

### 需要补充的环境

| 工具 | 安装命令 | 用途 |
|------|---------|------|
| SSH Key | `ssh-keygen -t ed25519 -C "邮箱"` | GitHub 推送代码 |
| GitHub CLI | `brew install gh` → `gh auth login` | 命令行操作 GitHub |
| Vercel CLI | `npm i -g vercel` → `vercel login` | 本地预览部署（可选） |

### 实际操作记录

1. **Git 用户信息**：已配置（8BitcloudBot / 17889786156@163.com）
2. **SSH Key 生成**：`ssh-keygen -t ed25519`，一路回车使用默认值
3. **SSH 公钥添加到 GitHub**：Settings → SSH and GPG keys → New SSH Key
4. **SSH 连接验证**：`ssh -T git@github.com`，首次连接需输入 `yes` 确认主机指纹
5. **GitHub CLI 安装**：`brew install gh`，选择 SSH 协议 + 浏览器登录
6. **Vercel CLI**：登录时遇到 "Your account requires further verification" 错误，暂时跳过

### 踩坑记录

- **SSH 首次连接**：出现 `Host key verification failed`，因为没有输入完整的 `yes`（只输入 `y` 不行）
- **Vercel CLI 登录失败**：新账号需要先完成邮箱验证，但网页端部署不受影响，可以后续再处理

---

## 四、部署方案演进

### 方案一：Vercel（最初方案）

```
本地代码 → git push → GitHub → Vercel 自动构建 → CDN 全球分发
```

**问题：`*.vercel.app` 域名在国内被 DNS 污染，无法访问。**

Vercel Hobby 计划虽然免费且额度充裕（100 万次 Edge Requests/月、100GB Data Transfer/月），但默认域名在国内不可用。绑定自定义域名后可以解决，但需要先完成 ICP 备案。

### 方案二：GitHub Pages + 自定义域名

| 优势 | 劣势 |
|------|------|
| 完全免费 | 国内访问慢（3-5秒） |
| 不需要备案 | 偶尔不稳定 |
| 自动 HTTPS | GitHub 曾对中文用户限流 |

**关键发现：`*.github.io` 默认域名被 DNS 污染，但绑定自定义域名后可以访问**，因为 DNS 解析走的是你自己的域名，不再走 `github.io` 的污染链路。

### 方案三：Gitee Pages

| 优势 | 劣势 |
|------|------|
| 国内速度快 | 免费版不支持自定义域名 |
| 不需要备案 | 免费版需手动点"更新" |
| | Pro 版 ¥69-99/年 |
| | 2022 年曾大规模下架审核 |

**结论：免费版限制太多，不推荐。**

### 方案四：GitHub Pages + Cloudflare CDN

免费，但 Cloudflare 在国内没有 CDN 节点，国内速度仍不如阿里云/腾讯云 CDN。

### 最终方案：分阶段组合部署

```
第一阶段（立即上线）：
  GitHub Pages → 海外访问 + 调试验证
  阿里云服务器 IP → 国内访问测试

第二阶段（备案通过后）：
  阿里云服务器 + 自定义域名 + HTTPS → 国内正式上线
  GitHub Pages → 保留作为海外备用线路
```

---

## 五、阿里云服务器配置

### 服务器信息

- **型号**：轻量应用服务器
- **配置**：2 核 2GB 运存 + 40GB 外存
- **系统**：Alibaba Cloud Linux 3.21.04
- **用途**：Nginx 托管静态网站

### 控制台配置清单

| 类目 | 优先级 | 操作 |
|------|--------|------|
| 服务器 | 🔴 必须 | 重置密码、远程连接 |
| 防火墙模板 | 🔴 必须 | 开放 80/443 端口 |
| 域名 | 🔴 必须 | 解析到服务器 IP + ICP 备案 |
| 密钥对 | 🟡 建议 | SSH 密钥登录更安全 |
| 快照 | 🟡 建议 | 配好环境后打快照 |
| 镜像 | ⚪ 不管 | 系统已装好 |
| 命令助手 | ⚪ 不管 | 批量运维用，单台不需要 |
| 内网互通 | ⚪ 不管 | 多台服务器用，只有一台不需要 |
| 配额管理 | ⚪ 不管 | 查资源配额 |
| 磁盘 | ⚪ 不管 | 40GB 够用 |

### 服务器内部操作

```bash
# 系统更新
yum update -y

# 安装 Nginx
yum install -y nginx
systemctl enable nginx
systemctl start nginx

# 创建网站目录
mkdir -p /var/www/portfolio
echo '<h1>Hello from my server!</h1>' > /var/www/portfolio/index.html

# 配置 Nginx
cat > /etc/nginx/conf.d/portfolio.conf << 'EOF'
server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;

    root /var/www/portfolio;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location ~* \.(css|js|jpg|png|svg|woff2|woff|ico)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    location ~ /\. {
        deny all;
    }
}
EOF

nginx -t
systemctl reload nginx
```

### 踩坑记录

- **firewalld 未运行**：执行 `firewall-cmd` 报 `FirewallD is not running`。这不是问题——阿里云轻量服务器有外层（控制台防火墙）和内层（firewalld）两层防火墙，内层不运行意味着全部放行，只需确保外层开了 80/443 端口即可。
- **命令粘贴错误**：两条命令粘在一起执行导致报错，Linux 命令必须逐条输入执行。

### 安全加固

```bash
# 安装 fail2ban 防暴力破解
yum install -y fail2ban
systemctl enable fail2ban
systemctl start fail2ban

# 配置 firewalld（如果启用的话）
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --reload
```

---

## 六、GitHub Pages 配置全流程

### 1. 创建 GitHub 仓库

```bash
gh repo create portfolio --public --source=. --push
```

仓库地址：`git@github.com:8BitcloudBot/portfolio.git`

### 2. Astro 配置

```javascript
// astro.config.mjs
import { defineConfig } from 'astro/config';

export default defineConfig({
  site: 'https://8bitcloudbot.github.io',
  base: '/portfolio',
  output: 'static',
});
```

关键点：`base: '/portfolio'` 是必须的，因为项目站点的 URL 是 `username.github.io/portfolio/`，不加 base 会导致资源路径错误。

### 3. GitHub Actions 部署工作流

```yaml
# .github/workflows/deploy.yml
name: Deploy to GitHub Pages

on:
  push:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: false

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: "22"
      - name: Install dependencies
        run: npm ci
      - name: Build
        run: npm run build
      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: dist

  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    needs: build
    runs-on: ubuntu-latest
    name: Deploy
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

### 4. 启用 GitHub Pages

在仓库 Settings → Pages → Source 中选择 **GitHub Actions**（不是 "Deploy from a branch"）。

### 5. 踩坑记录

**坑 1：部署失败 — `Not Found` / `404`**

```
Error: HttpError: Not Found
Error: Failed to create deployment (status: 404)
```

原因：GitHub Pages 没有正确启用。通过 API 检查发现 `build_type` 虽然是 `workflow`，但 Source 仍指向 `master` 分支。

修复：通过 GitHub API 设置 `build_type` 为 `workflow`：
```bash
gh api repos/8BitcloudBot/portfolio/pages -X PUT -f build_type=workflow
```

**坑 2：部署失败 — 环境保护规则**

```
Branch "main" is not allowed to deploy to github-pages due to environment protection rules.
```

原因：GitHub Pages 的 `github-pages` 环境默认只允许特定分支部署，而我们的代码在 `main` 分支上。

修复：通过 API 添加 `main` 分支的部署权限：
```bash
gh api repos/8BitcloudBot/portfolio/environments/github-pages/deployment-branch-policies -X POST -f name=main
```

**坑 3：Node.js 20 弃用警告**

```
Node.js 20 actions are deprecated. Actions will be forced to run with Node.js 24 by default starting June 2nd, 2026.
```

这是 GitHub 的提前通知，目前不影响功能，后续需要更新 Actions 版本。

### 6. 最终验证

部署成功后访问 `https://8bitcloudbot.github.io/portfolio/`，页面正常显示。

---

## 七、双线部署架构

### 当前架构

```
本地开发 (Astro)
  ↓ npm run build → dist/
  ↓ git push → GitHub
  ↓
GitHub Actions 自动触发
  ↓
  ├──→ GitHub Pages（海外线路）
  │     URL: https://8bitcloudbot.github.io/portfolio/
  │     自动 HTTPS，自动部署
  │
  └──→ 阿里云轻量服务器（国内线路）
        URL: http://服务器IP
        Nginx 托管，待配 HTTPS
```

### 未来架构（备案通过后）

```
本地开发 (Astro)
  ↓ npm run build → dist/
  ↓ git push → GitHub
  ↓
GitHub Actions 自动触发
  ↓
  ├──→ GitHub Pages（海外线路）
  │     URL: https://8bitcloudbot.github.io/portfolio/
  │
  └──→ rsync 同步到阿里云服务器
        ↓
      Nginx + Let's Encrypt HTTPS
        ↓
      yourdomain.com → 国内用户毫秒级访问
```

### DNS 分线路解析

```
yourdomain.com
  ├── 国内线路 → A 记录 → 阿里云服务器 IP
  └── 海外线路 → CNAME → 8bitcloudbot.github.io
```

---

## 八、费用分析

### 当前费用

| 项目 | 费用 | 说明 |
|------|------|------|
| GitHub Pages | ¥0 | 免费托管 |
| 阿里云轻量服务器 | 已购买 | 2 核 2G + 40GB |
| 域名 | ¥0 | 暂未购买 |
| **当前月费用** | **¥0** | 仅服务器成本 |

### 正式上线后费用

| 项目 | 费用 | 说明 |
|------|------|------|
| 域名 | ¥40-70/年 | .com 约 ¥55/年 |
| SSL 证书 | ¥0 | Let's Encrypt 免费 |
| CDN（可选） | ¥0-5/月 | 按流量计费 |
| **年总费用** | **¥50-130** | 基本就是域名钱 |

---

## 九、安全方案

| 安全项 | 措施 | 状态 |
|--------|------|------|
| HTTPS | Let's Encrypt 免费证书 | 待备案后配置 |
| 隐藏源站 | Nginx 直接对外，无 CDN 回源 | 当前架构不需要 |
| 防盗链 | Nginx Referer 白名单 | 待配置 |
| SSH 安全 | 密钥登录 + 禁用密码 | 待配置 |
| fail2ban | 防暴力破解 | 待安装 |
| Git 安全 | .gitignore 排除敏感文件 | ✅ 已配置 |
| 密钥管理 | GitHub Secrets 存放 API 密钥 | 待配置 |

---

## 十、ICP 备案须知

### 什么时候需要备案

- 网站部署在中国内地服务器上 → **必须备案**
- 使用海外服务器（GitHub Pages、Vercel 等）→ **不需要备案**
- 使用自定义域名指向国内服务器 → **必须备案**

### 备案流程

```
1. 注册云平台账号 → 实名认证
2. 购买域名 → 域名实名认证（1-3 天）
3. 购买云资源（轻量服务器即可）
4. 提交 ICP 备案申请
5. 云平台初审（1-2 天）
6. 管局审核（5-20 天，各省不同）
7. 备案成功 → 域名可解析
8. 30 天内完成公安联网备案
```

### 备案所需材料

- 身份证正反面照片
- 手机号（需验证）
- 域名证书
- 人脸核验
- 网站名称（不能含"中国""国家"等词，个人站不能含企业性质词汇）

---

## 十一、MVP 验证清单

| 验证项 | 状态 | 说明 |
|--------|------|------|
| 本地开发服务器启动 | ✅ | `npm run dev` → localhost:4321 |
| 本地构建成功 | ✅ | `npm run build` → dist/ |
| Git 推送到 GitHub | ✅ | SSH 连接正常 |
| GitHub Actions 自动构建 | ✅ | build ✅ |
| GitHub Pages 部署成功 | ✅ | Deploy ✅ |
| 线上 URL 可访问 | ✅ | 8bitcloudbot.github.io/portfolio/ |
| 阿里云服务器 Nginx | ✅ | http://服务器IP 可访问 |
| 代码变更自动部署 | ✅ | push → Actions → Pages 自动更新 |

---

## 十二、项目目录结构

```
WebPage/
├── .github/
│   └── workflows/
│       └── deploy.yml          # GitHub Actions 部署工作流
├── .vscode/
│   ├── extensions.json
│   └── launch.json
├── public/
│   ├── favicon.ico
│   └── favicon.svg
├── src/
│   ├── content/
│   │   └── blog/
│   │       └── building-personal-website-from-scratch.md  # 本文章
│   └── pages/
│       └── index.astro
├── .gitignore
├── OPERATIONS_GUIDE.md         # 操作指南
├── astro.config.mjs            # Astro 配置
├── package.json
├── package-lock.json
└── tsconfig.json
```

---

## 十三、后续计划

### 阶段 2：基础框架搭建

- 集成 React、Tailwind CSS、MDX
- 实现基础布局组件（Header、Footer、Container）
- 配置全局样式和 Tailwind 主题
- 实现站点配置文件

### 阶段 3：核心页面开发

- 博客系统：列表页 + 文章详情页 + 标签筛选
- 作品集系统：项目列表 + 项目详情
- 关于我页面
- 首页内容填充

### 阶段 4：打磨与优化

- SEO 优化（meta 标签、Open Graph、sitemap）
- 响应式适配
- 性能优化（图片懒加载、字体优化）
- 暗色模式支持
- 无障碍访问（a11y）

### 阶段 5：正式上线

- 购买域名 + ICP 备案
- 配置 HTTPS
- GitHub Actions 自动同步到阿里云服务器
- DNS 分线路解析

---

## 结语

从最初的需求讨论到 MVP 验证通过，整个过程涉及了技术选型、部署方案对比、环境搭建、CI/CD 配置等多个环节。最大的收获是：

1. **先跑通再优化**：MVP 思维很重要，先验证核心链路，再逐步完善
2. **部署方案要因地制宜**：国内网络环境决定了不能照搬海外方案
3. **踩坑是常态**：GitHub Pages 的环境保护规则、DNS 污染、firewalld 状态等问题都是实际操作中才会遇到的
4. **文档很重要**：每一步操作都记录下来，未来排查问题事半功倍

网站还在搭建中，后续会继续更新进展。如果你也在搭建个人网站，希望这篇记录对你有帮助。
