---
title: "个人网站运维指南：从开发到部署的完整流程"
description: "详细的个人网站运维指南，包含本地开发、双线路部署、服务器管理、安全维护以及 uv 虚拟环境操作命令。"
pubDate: 2025-09-15
lang: "zh"
tags: ["网站运维", "Astro", "Nginx", "GitHub Pages", "uv"]
---

# 个人网站运维指南

## 一、项目概览

### 网站信息
- **域名**：
  - 自定义域名：https://vincentbuilds.fun
  - GitHub Pages：https://8bitcloudbot.github.io/portfolio/
- **技术栈**：
  - Astro 6.x（静态站点生成器）
  - React 19（交互组件）
  - Tailwind CSS 4.x（样式系统）
  - MDX（博客内容）
  - Nginx（服务器端静态文件托管）
  - GitHub Actions（CI/CD 自动部署）
  - uv（Python 虚拟环境管理）

### 目录结构

```
WebPage/
├── public/             # 静态资源
│   ├── photos/         # 照片/壁纸
│   └── favicon.svg     # 网站图标
├── src/
│   ├── components/     # 可复用组件
│   │   ├── icons/      # 图标组件
│   │   ├── layout/     # 布局组件
│   │   ├── blog/       # 博客相关组件
│   │   ├── projects/   # 项目相关组件
│   │   └── ui/         # UI 组件
│   ├── content/        # 内容集合
│   │   ├── blog/       # 博客文章
│   │   └── projects/   # 项目文档
│   ├── layouts/        # 页面布局
│   ├── pages/          # 页面组件
│   ├── styles/         # 全局样式
│   └── config.ts       # 站点配置
├── docs/               # 文档
│   └── plans/          # 计划文档
├── .github/            # GitHub 配置
│   └── workflows/      # CI/CD 工作流
├── astro.config.mjs    # Astro 配置
├── package.json        # 项目依赖
└── OPERATIONS_GUIDE.md # 操作指南
```

## 二、本地开发

### 日常开发流程

```bash
cd /Users/wxhu/Documents/TRAE_workspace/WebPage

# 启动开发服务器
npm run dev
# 访问 http://localhost:4321/portfolio/

# 构建生产版本
npm run build
# 输出到 dist/ 目录

# 本地预览构建结果
npm run preview
```

### 新增博客文章

1. **创建文件**：在 `src/content/blog/` 目录下创建 Markdown 文件，如 `my-new-post.md`

2. **添加 Frontmatter**：
   ```yaml
   ---  
title: "文章标题"
description: "文章描述"
pubDate: 2026-04-27
lang: "zh" # 或 "en"
tags: ["前端", "Astro"]
---
   ```

3. **编写内容**：使用 Markdown 语法编写文章内容，支持 MDX 组件

4. **本地预览**：运行 `npm run dev` 查看效果

5. **构建验证**：运行 `npm run build` 确保生成成功

### 新增项目

1. **创建文件**：在 `src/content/projects/` 目录下创建 Markdown/MDX 文件，如 `my-project.mdx`

2. **添加 Frontmatter**：
   ```yaml
   ---  
title: "项目名称"
description: "项目描述"
pubDate: 2026-04-27
tags: ["React", "TypeScript"]
github: "https://github.com/用户名/仓库名" # 可选
---
   ```

3. **编写内容**：介绍项目功能、技术栈、使用方法等

4. **本地预览**：运行 `npm run dev` 查看效果

### 新增照片/壁纸

1. **添加图片**：将图片文件（.jpg/.png/.webp）放入 `public/photos/` 目录
2. **自动显示**：Photos 页面会自动扫描并显示该目录下的所有图片
3. **排序**：按文件名倒序排列（最新的在前）
4. **命名建议**：使用 `YYYY-MM-DD-description.jpg` 格式，如 `2026-04-27-mountain-landscape.jpg`

## 三、uv 虚拟环境操作

### 安装 uv

```bash
# macOS/Linux
curl -LsSf https://astral.sh/uv/install.sh | sh

# Windows
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

### 常用命令

#### 1. 环境管理

```bash
# 创建新的虚拟环境
uv venv

# 创建指定 Python 版本的虚拟环境
uv venv --python 3.12

# 激活虚拟环境
# macOS/Linux
source .venv/bin/activate
# Windows
.venv\Scripts\activate

# 查看当前虚拟环境
uv venv list

# 删除虚拟环境
uv venv remove
```

#### 2. 包管理

```bash
# 安装包
uv add requests
uv add requests==2.31.0

# 安装开发依赖
uv add --dev pytest

# 安装 requirements.txt
uv pip install -r requirements.txt

# 卸载包
uv remove requests

# 更新包
uv upgrade requests
uv upgrade --all

# 查看已安装的包
uv list

# 导出依赖
uv export > requirements.txt
uv export --dev > requirements-dev.txt
```

#### 3. 项目管理

```bash
# 运行 Python 脚本
uv run python script.py

# 运行命令
uv run pytest

# 构建项目
uv build

# 发布包
uv publish
```

#### 4. 缓存管理

```bash
# 清理缓存
uv cache clean

# 查看缓存大小
uv cache size

# 清理特定包的缓存
uv cache remove requests
```

## 四、部署上线

### 双线路部署架构

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
  └──→ 阿里云轻量服务器（国内线路）
        URL: https://vincentbuilds.fun
        Nginx 托管
```

### GitHub Pages 部署（自动）

```bash
# 提交并推送
git add .
git commit -m "描述你的改动"
git push origin main
```

推送后 GitHub Actions 会自动执行：
- 构建站点 → 部署到 GitHub Pages（约 1-2 分钟）
- 访问：https://8bitcloudbot.github.io/portfolio/

### 阿里云服务器部署（手动）

```bash
# 构建生产版本
npm run build

# 上传到服务器
scp -r dist/* root@your-server-ip:/var/www/vincentbuilds/

# 或使用 rsync（更高效）
rsync -avz --delete dist/ root@your-server-ip:/var/www/vincentbuilds/
```

访问：https://vincentbuilds.fun

### 查看部署状态

```bash
# 查看 GitHub Actions 运行状态
gh run list --workflow="deploy.yml" -R 8BitcloudBot/portfolio
gh run view <run-id> -R 8BitcloudBot/portfolio

# 检查服务器 Nginx 状态
ssh root@your-server-ip 'systemctl status nginx'
```

## 五、服务器管理

### SSH 登录

```bash
ssh root@your-server-ip
```

### Nginx 常用命令

```bash
systemctl status nginx    # 查看状态
systemctl start nginx     # 启动
systemctl stop nginx      # 停止
systemctl reload nginx    # 重载配置（修改配置后用这个，不中断服务）
systemctl restart nginx   # 重启（会短暂中断）
nginx -t                  # 测试配置文件语法是否正确
```

### 网站文件位置

```
/var/www/vincentbuilds/       # 静态文件目录
/etc/nginx/conf.d/vincentbuilds.conf  # Nginx 站点配置
/etc/nginx/ssl/              # SSL 证书目录
```

### Nginx 配置修改流程

```bash
# 1. 编辑配置
vim /etc/nginx/conf.d/vincentbuilds.conf

# 2. 测试语法
nginx -t

# 3. 重载配置
systemctl reload nginx
```

### 当前 Nginx 配置

```nginx
server {
    listen 80;
    server_name vincentbuilds.fun www.vincentbuilds.fun;
    
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name vincentbuilds.fun www.vincentbuilds.fun;

    ssl_certificate     /etc/nginx/ssl/vincentbuilds.fun.pem;
    ssl_certificate_key /etc/nginx/ssl/vincentbuilds.fun.key;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    root /var/www/vincentbuilds;
    index index.html;

    # 处理根路径请求
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # 处理 /portfolio 路径（兼容 GitHub Pages 部署）
    location /portfolio {
        alias /var/www/vincentbuilds;
        try_files $uri $uri/ /portfolio/index.html;
    }

    location ~* \.(css|js|jpg|png|svg|webp|woff2|woff|ico|xml)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    location ~ /\. {
        deny all;
    }
}
```

## 六、HTTPS 配置

### 证书信息
- **类型**：阿里云 Nginx 证书
- **有效期**：1年
- **配置路径**：
  - 证书：`/etc/nginx/ssl/vincentbuilds.fun.pem`
  - 私钥：`/etc/nginx/ssl/vincentbuilds.fun.key`

### 证书更新
当证书快过期时：
1. 在阿里云控制台重新申请证书
2. 下载 Nginx 格式证书
3. 上传替换现有证书文件
4. 重载 Nginx 配置：`systemctl reload nginx`

## 七、安全管理

### 服务器安全检查清单

- [x] 阿里云控制台防火墙已开 80/443 端口
- [x] Nginx 禁止访问隐藏文件（配置中已包含）
- [x] HTTPS 已配置
- [ ] SSH 密钥登录已配置（建议）
- [ ] root 密码登录已禁用（建议，密钥配好后执行）
- [ ] fail2ban 已安装运行（建议）

### 禁用密码登录（密钥配好后执行）

```bash
sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart sshd
```

### 防火墙设置

阿里云控制台 → 轻量应用服务器 → 防火墙 → 确认以下端口已开放：
- 80（HTTP）
- 443（HTTPS）
- 22（SSH，建议修改为其他端口）

## 八、域名管理

### 域名信息
- **域名**：vincentbuilds.fun
- **注册商**：阿里云
- **DNS 解析**：
  - A 记录：@ → your-server-ip
  - A 记录：www → your-server-ip

### 域名解析设置

阿里云控制台 → 域名 → 解析设置 → 添加记录：

| 记录类型 | 主机记录 | 记录值 | TTL |
|---------|---------|--------|-----|
| A | @ | your-server-ip | 10分钟 |
| A | www | your-server-ip | 10分钟 |

## 九、故障排查

### GitHub Pages 部署失败

```bash
# 查看最近运行记录
gh run list --workflow="deploy.yml" -R 8BitcloudBot/portfolio

# 查看失败日志
gh run view <run-id> --log-failed -R 8BitcloudBot/portfolio

# 常见原因：
# - 构建错误（检查 npm run build 输出）
# - 内容集合 schema 验证失败（检查 frontmatter 格式）
# - 权限问题（检查 GitHub Actions 权限设置）
```

### 服务器网站打不开

```bash
# 1. 检查 Nginx 是否运行
ssh root@your-server-ip 'systemctl status nginx'

# 2. 检查端口是否监听
ssh root@your-server-ip 'ss -tlnp | grep -E "80|443"'

# 3. 检查 Nginx 配置
ssh root@your-server-ip 'nginx -t'

# 4. 查看 Nginx 错误日志
ssh root@your-server-ip 'tail -50 /var/log/nginx/error.log'

# 5. 检查防火墙
# 阿里云控制台 → 服务器 → 安全 → 防火墙 → 确认 80/443 端口已开放
```

### 页面加载缓慢或样式丢失

- **检查 Google Fonts**：如果在国内访问慢，确认已使用国内镜像（fonts.loli.net）
- **检查资源路径**：确认 `base: '/portfolio'` 配置正确
- **清除浏览器缓存**：强制刷新页面（Ctrl+F5）
- **检查网络连接**：确认服务器网络正常

### 图片不显示

- 检查图片路径：确保图片在 `public/photos/` 目录
- 检查图片格式：支持 .jpg/.jpeg/.png/.webp
- 检查图片命名：避免特殊字符和空格
- 检查 Nginx 配置：确认静态资源配置正确

## 十、注意事项

### 内容管理注意事项

1. **Frontmatter 格式**：确保所有必填字段都已填写，特别是 `pubDate` 字段
2. **文件命名**：使用小写字母、数字和连字符，避免空格和特殊字符
3. **图片大小**：建议图片大小不超过 2MB，以保证加载速度
4. **链接格式**：内部链接使用相对路径，外部链接使用绝对路径
5. **代码块**：使用 ``` 代码块包裹代码，指定语言以获得语法高亮

### 部署注意事项

1. **双线路部署**：
   - GitHub Pages：自动部署，无需手动操作
   - 阿里云服务器：需要手动上传构建产物
2. **版本控制**：
   - 定期提交代码，使用语义化 commit 信息
   - 重要功能创建分支开发
3. **环境变量**：
   - 敏感信息使用环境变量，不要硬编码在代码中
   - GitHub Secrets 用于 CI/CD 配置
4. **构建缓存**：
   - 如果构建失败，尝试删除 `node_modules` 和 `.astro` 目录后重新构建

### 服务器维护注意事项

1. **定期更新**：
   - 定期更新系统包：`yum update -y`
   - 定期更新 Nginx：`yum update nginx`
2. **备份**：
   - 阿里云控制台创建快照（每月至少一次）
   - 备份 Nginx 配置文件：`cp /etc/nginx/conf.d/vincentbuilds.conf ~/backup/`
3. **监控**：
   - 定期检查服务器状态：`top`、`df -h`
   - 监控 Nginx 访问日志：`tail -f /var/log/nginx/access.log`

### 域名与备案注意事项

1. **域名续费**：提前 30 天续期，避免过期
2. **ICP 备案**：
   - 网站部署在国内服务器必须备案
   - 备案信息变更及时更新
3. **DNS 解析**：
   - 修改解析后等待 TTL 生效（通常 10-30 分钟）
   - 定期检查解析状态

## 十一、技术支持

### 官方文档
- **Astro**：https://docs.astro.build/
- **React**：https://react.dev/
- **Tailwind CSS**：https://tailwindcss.com/docs
- **Nginx**：https://nginx.org/en/docs/
- **GitHub Actions**：https://docs.github.com/en/actions
- **uv**：https://docs.astral.sh/uv/

### 常见问题解决方案

| 问题 | 解决方案 |
|------|---------|
| 构建失败 | 检查 `npm run build` 输出，修复错误 |
| 部署失败 | 查看 GitHub Actions 日志，检查权限和配置 |
| 页面 404 | 检查文件路径，确保 `base` 配置正确 |
| 样式丢失 | 检查资源路径，清除浏览器缓存 |
| 图片不显示 | 检查图片路径和格式，确认 Nginx 配置 |
| 服务器无响应 | 检查 Nginx 状态和防火墙设置 |
| uv 命令执行失败 | 检查 uv 安装状态，确保环境变量配置正确 |

## 十二、更新日志

| 日期 | 版本 | 更新内容 |
|------|------|----------|
| 2026-04-27 | 1.0 | 初始化运维指南，包含 uv 虚拟环境操作命令 |

---

**最后更新**：2026-04-27
**维护者**：Vincent Hu
**联系邮箱**：17889786156@163.com