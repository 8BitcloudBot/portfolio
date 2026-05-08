# 三端同步部署指南

## 🎯 概述

本项目支持**本地、GitHub Pages、阿里云服务器**三端同步部署，确保内容一致性。

## 📊 环境配置

| 环境 | 域名 | 用途 | 构建命令 |
|------|------|------|----------|
| **阿里云生产** | `https://vincentbuilds.fun` | 正式网站 | `npm run build:production` |
| **GitHub Pages** | `https://8bitcloudbot.github.io/portfolio` | 备份/演示 | `npm run build:github` |
| **本地开发** | `http://localhost:4321` | 开发测试 | `npm run dev` |

## 🚀 快速开始

### 本地开发
```bash
# 启动开发服务器
npm run dev

# 访问: http://localhost:4321
```

### 构建测试
```bash
# 构建生产版本
npm run build:production

# 构建 GitHub Pages 版本
npm run build:github

# 预览构建结果
npm run preview
```

## 🔧 部署脚本

### 本地部署脚本
```bash
# 部署到阿里云生产环境
./deploy.sh production

# 部署到 GitHub Pages
./deploy.sh github

# 一键部署到所有环境
./deploy.sh all

# 或者使用 npm 脚本
npm run deploy:production
npm run deploy:github
npm run deploy:all
```

### GitHub Actions 自动部署

GitHub Actions 支持以下部署方式：

1. **自动部署**：推送代码到 `main` 分支时自动部署到 GitHub Pages
2. **手动部署**：在 GitHub Actions 页面手动触发，可选择部署环境

#### 手动部署步骤：
1. 进入 GitHub 仓库的 **Actions** 标签页
2. 选择 **"Deploy to Multiple Environments"** 工作流
3. 点击 **"Run workflow"**
4. 选择部署环境：
   - `github`：仅部署到 GitHub Pages
   - `production`：仅部署到阿里云服务器
   - `all`：同时部署到两个环境

## ⚙️ 环境配置

### 本地部署配置（.deploy.env）

本地一键部署需要在项目根目录创建 `.deploy.env` 配置文件：

```bash
# 阿里云部署配置
ALIYUN_SERVER_HOST=your-server-ip
ALIYUN_SERVER_USER=root
ALIYUN_DEPLOY_PATH=/var/www/vincentbuilds
```

> ⚠️ `.deploy.env` 已加入 `.gitignore`，不会被提交到 GitHub。

### 阿里云服务器配置

| Secret 名称 | 描述 | 示例值 |
|-------------|------|--------|
| `ALIYUN_SSH_KEY` | 阿里云服务器 SSH 私钥 | `-----BEGIN RSA PRIVATE KEY-----...` |
| `ALIYUN_SERVER_HOST` | 服务器 IP 地址 | `<your-server-ip>` |
| `ALIYUN_SERVER_USER` | 服务器用户名 | `root` |
| `ALIYUN_DEPLOY_PATH` | 部署目录路径 | `/var/www/vincentbuilds` |

### 配置 GitHub Secrets（可选，用于 CI/CD 自动部署）

1. 进入 GitHub 仓库设置
2. 选择 **Secrets and variables** > **Actions**
3. 点击 **New repository secret**
4. 添加上述环境变量

## 🔄 同步流程

### 开发流程
```bash
# 1. 本地开发
npm run dev

# 2. 测试构建
npm run build:production
npm run preview

# 3. 提交代码
git add .
git commit -m "feat: 更新内容"
git push origin main

# 4. 自动部署到 GitHub Pages
# GitHub Actions 会自动运行

# 5. 手动部署到阿里云（可选）
# 在 GitHub Actions 页面手动触发生产环境部署
```

### 多环境配置说明

#### Astro 配置
配置文件：`astro.config.ts`

```typescript
// 多环境配置
const environments = {
  production: {
    site: 'https://vincentbuilds.fun',
    base: '/',
    output: 'static'
  },
  github: {
    site: 'https://8bitcloudbot.github.io',
    base: '/portfolio',
    output: 'static'
  },
  development: {
    site: 'http://localhost:4321',
    base: '/',
    output: 'static'
  }
};
```

#### 环境变量
- `ASTRO_ENV=production`：阿里云生产环境
- `ASTRO_ENV=github`：GitHub Pages 环境
- `ASTRO_ENV=development`：本地开发环境

## 🛠️ 故障排除

### 常见问题

1. **构建失败**
   - 检查 Node.js 版本（要求 >= 22.12.0）
   - 运行 `npm ci` 重新安装依赖

2. **GitHub Pages 无法访问**
   - 检查仓库设置中的 Pages 配置
   - 确认 `base` 路径正确

3. **阿里云部署失败**
   - 检查 SSH 密钥配置
   - 确认服务器路径和权限

### 日志查看

- **本地构建日志**：查看终端输出
- **GitHub Actions 日志**：在 Actions 页面查看工作流运行详情
- **阿里云服务器日志**：通过 SSH 连接查看 Nginx 日志

## 📞 技术支持

如有问题，请检查：
1. 项目文档：`README.md`
2. 操作指南：`OPERATIONS_GUIDE.md`
3. GitHub Issues：创建新的 issue

---

**最后更新：2026-04-28**