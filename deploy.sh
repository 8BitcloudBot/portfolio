#!/bin/bash

# 多环境部署脚本
# 用法: ./deploy.sh [environment]
# 环境: production, github, development, all

set -e

ENV=${1:-production}
BUILD_DIR="dist"

# 自动加载部署配置文件
DEPLOY_CONFIG_FILE="$(dirname "$0")/.deploy.env"
if [ -f "$DEPLOY_CONFIG_FILE" ]; then
    export $(grep -v '^#' "$DEPLOY_CONFIG_FILE" | xargs) 2>/dev/null || true
fi

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# 检查环境
case "$ENV" in
    "production")
        log "部署到阿里云生产环境 (vincentbuilds.fun)"
        export ASTRO_ENV=production
        REMOTE_PATH="/var/www/vincentbuilds"
        ;;
    "github")
        log "部署到 GitHub Pages (8bitcloudbot.github.io/portfolio)"
        export ASTRO_ENV=github
        REMOTE_PATH="dist"
        ;;
    "development")
        log "本地开发环境构建"
        export ASTRO_ENV=development
        REMOTE_PATH="dist"
        ;;
    "all")
        log "三端同步部署模式"
        info "将依次部署到：1. GitHub Pages  2. 阿里云生产环境"
        ;;
    *)
        error "未知环境: $ENV，支持的环境: production, github, development, all"
        ;;
esac

# 构建项目
log "开始构建项目..."
npm run build

if [ $? -ne 0 ]; then
    error "构建失败"
fi

log "构建完成，输出目录: $BUILD_DIR"

# 根据不同环境执行部署
case "$ENV" in
    "production")
        # 阿里云部署 - 检查SSH配置
        if [ -z "$REMOTE_PATH" ]; then
            error "请设置阿里云服务器路径"
        fi
        
        # 检查是否配置了SSH连接信息
        if [ -z "$ALIYUN_SERVER_HOST" ] || [ -z "$ALIYUN_SERVER_USER" ]; then
            warn "阿里云服务器SSH配置未设置"
            info "请配置以下环境变量："
            info "  - ALIYUN_SERVER_HOST: 服务器IP地址"
            info "  - ALIYUN_SERVER_USER: 服务器用户名（如root）"
            info "  - ALIYUN_SSH_KEY: SSH私钥（可选，支持密码登录）"
            info ""
            info "或者使用以下方式手动部署："
            info "  1. 将 dist/ 目录内容上传到服务器 $REMOTE_PATH/"
            info "  2. 重启Nginx: sudo systemctl reload nginx"
            info ""
            info "GitHub Actions 部署需要配置相应的Secrets"
            exit 0
        fi
        
        log "同步文件到阿里云服务器..."
        
        # 设置SSH配置
        if [ -n "$ALIYUN_SSH_KEY" ]; then
            mkdir -p ~/.ssh
            echo "$ALIYUN_SSH_KEY" > ~/.ssh/id_rsa
            chmod 600 ~/.ssh/id_rsa
            ssh-keyscan -H "$ALIYUN_SERVER_HOST" >> ~/.ssh/known_hosts
            SSH_OPTIONS="-i ~/.ssh/id_rsa"
        else
            warn "使用密码认证，请确保已设置SSH密码"
            SSH_OPTIONS=""
        fi
        
        # 使用tar管道同步
        tar czf - --no-xattrs -C "$BUILD_DIR" . | ssh -o StrictHostKeyChecking=no "$ALIYUN_SERVER_USER@$ALIYUN_SERVER_HOST" "tar xzf - -C $REMOTE_PATH"
        
        if [ $? -eq 0 ]; then
            log "阿里云部署完成"
            
            # 重启Nginx（可选）
            read -p "是否重启Nginx服务？(y/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                ssh $SSH_OPTIONS "$ALIYUN_SERVER_USER@$ALIYUN_SERVER_HOST" "sudo systemctl reload nginx"
                log "Nginx服务已重启"
            fi
        else
            error "阿里云部署失败"
        fi
        ;;
    
    "github")
        # GitHub Pages 部署
        log "GitHub Pages 部署将由 GitHub Actions 自动处理"
        log "请确保已推送代码到 GitHub"
        info "推送命令: git push origin main"
        info "GitHub Actions 会自动构建并部署到 GitHub Pages"
        ;;
    
    "development")
        # 本地开发环境
        log "本地构建完成，可运行: npm run preview 预览"
        ;;
    
    "all")
        # 三端同步部署
        log "=== 第一阶段：部署到 GitHub Pages ==="
        bash "$0" github
        
        if [ $? -eq 0 ]; then
            log "GitHub Pages 部署指令已触发"
        else
            error "GitHub Pages 部署失败"
        fi
        
        echo ""
        log "=== 第二阶段：部署到阿里云生产环境 ==="
        
        if [ -z "$ALIYUN_SERVER_HOST" ] || [ -z "$ALIYUN_SERVER_USER" ]; then
            warn "阿里云服务器SSH配置未设置，跳过阿里云部署"
            info "请检查 .deploy.env 文件中的 ALIYUN_SERVER_HOST 和 ALIYUN_SERVER_USER"
            info "跳过阿里云部署，三端同步完成（部分成功）"
        else
            bash "$0" production
            if [ $? -eq 0 ]; then
                log "阿里云部署完成 ✅"
            else
                warn "阿里云部署失败 ⚠️"
            fi
        fi
        
        log "=== 三端同步部署完成 ==="
        info "GitHub Pages: https://8bitcloudbot.github.io/portfolio/"
        info "阿里云生产: https://vincentbuilds.fun"
        ;;
esac

log "$ENV 环境部署流程完成"