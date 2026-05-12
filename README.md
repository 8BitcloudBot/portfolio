# Vincent Hu - Portfolio

A modern, high-performance personal website and technical blog built with **Astro**, **React**, **Tailwind CSS**, and **MDX**. Designed for developers who want a fast, SEO-friendly portfolio with multi-environment deployment support.

## 🚀 Live Demo

| Environment | URL |
|-------------|-----|
| **Production** | [vincentbuilds.fun](https://vincentbuilds.fun) |
| **GitHub Pages** | [8bitcloudbot.github.io/portfolio](https://8bitcloudbot.github.io/portfolio) |

## ✨ Features

### Core Features

- **📝 Blog System** - Markdown/MDX blog with syntax highlighting, tags, and full-text search
- **💼 Project Showcase** - Detailed project pages with MDX support for rich content
- **📸 Photo Gallery** - Responsive image gallery with lazy loading
- **🌙 Dark Mode** - Theme toggle with system preference detection and local storage persistence
- **🔍 SEO Optimized** - Automatic sitemap generation, meta tags, Open Graph, and structured data
- **📱 Responsive Design** - Mobile-first approach with Tailwind CSS breakpoints
- **⚡ Performance** - Static site generation (SSG) with Astro for sub-second load times

### Technical Features

- **Content Collections** - Type-safe content with Zod schema validation
- **Component Islands** - React components hydrate only when needed (partial hydration)
- **Image Optimization** - Automatic image optimization with Astro's built-in assets
- **RSS Feed** - Auto-generated RSS feed for blog subscribers
- **Accessibility** - WCAG 2.1 compliant with semantic HTML and ARIA labels

## 🛠️ Tech Stack

### Core Technologies

| Category | Technology | Purpose |
|----------|-----------|---------|
| Framework | [Astro 6.x](https://astro.build) | Static site generator with island architecture |
| UI Components | [React 19](https://react.dev) | Interactive client-side components |
| Styling | [Tailwind CSS 4.x](https://tailwindcss.com) | Utility-first CSS framework |
| Content | [MDX](https://mdxjs.com/) | Markdown with JSX support for rich content |
| Type Safety | [TypeScript](https://www.typescriptlang.org/) | Static type checking |

### Integrations & Tools

| Tool | Purpose |
|------|---------|
| [@astrojs/sitemap](https://docs.astro.build/en/guides/integrations-guide/sitemap/) | Automatic sitemap generation |
| [@astrojs/mdx](https://docs.astro.build/en/guides/integrations-guide/mdx/) | MDX content support |
| [@astrojs/react](https://docs.astro.build/en/guides/integrations-guide/react/) | React component integration |
| [GitHub Actions](https://github.com/features/actions) | CI/CD automation |

### Deployment Infrastructure

| Component | Technology |
|-----------|-----------|
| Primary Server | Alibaba Cloud ECS + Nginx |
| Backup Hosting | GitHub Pages |
| CI/CD | GitHub Actions |
| SSL | Let's Encrypt |

## 📦 Installation

### Prerequisites

- **Node.js** >= 22.12.0 (recommended: use [nvm](https://github.com/nvm-sh/nvm) or [fnm](https://github.com/Schniz/fnm) for version management)
- **npm** >= 10.x or **pnpm** >= 9.x
- **Git** for version control

### Quick Start

```bash
# Clone the repository
git clone https://github.com/8BitcloudBot/portfolio.git
cd portfolio

# Install dependencies
npm install

# Start development server
npm run dev
```

Visit `http://localhost:4321` to see the site.

### Alternative: Using pnpm

```bash
# Install pnpm if not installed
npm install -g pnpm

# Install dependencies
pnpm install

# Start development server
pnpm dev
```

## 📁 Project Structure

```
portfolio/
├── .github/
│   └── workflows/
│       └── deploy.yml          # CI/CD workflow for multi-environment deployment
├── public/
│   ├── photos/                 # Photo gallery images
│   └── favicon.svg             # Site favicon
├── src/
│   ├── components/
│   │   ├── blog/               # Blog list & item components
│   │   ├── icons/              # SVG icon components (inline SVG)
│   │   ├── layout/             # Header, Footer, BackToTop, Navigation
│   │   ├── projects/           # Project card & list components
│   │   └── ui/                 # Shared UI components (SEO, ThemeToggle)
│   ├── content/
│   │   ├── blog/               # Blog posts (Markdown with frontmatter)
│   │   └── projects/           # Project pages (MDX with frontmatter)
│   ├── layouts/
│   │   └── BaseLayout.astro    # Main layout wrapper
│   ├── pages/
│   │   ├── index.astro         # Homepage
│   │   ├── about.astro         # About page
│   │   ├── blog/
│   │   │   ├── index.astro     # Blog listing page
│   │   │   └── [slug].astro    # Dynamic blog post page
│   │   ├── projects/
│   │   │   ├── index.astro     # Projects listing page
│   │   │   └── [slug].astro    # Dynamic project page
│   │   └── photos.astro        # Photo gallery page
│   ├── styles/
│   │   └── global.css          # Global styles and Tailwind imports
│   └── config.ts               # Site configuration (title, nav, social links)
├── astro.config.ts             # Astro configuration (integrations, env)
├── deploy.sh                   # Multi-environment deployment script
├── tsconfig.json               # TypeScript configuration
└── package.json                # Dependencies and scripts
```

### Key Files

| File | Purpose |
|------|---------|
| `src/config.ts` | Site metadata, navigation, and social links |
| `astro.config.ts` | Multi-environment configuration (production/github/development) |
| `deploy.sh` | Local deployment script with environment switching |
| `.github/workflows/deploy.yml` | GitHub Actions CI/CD pipeline |

## 🗺️ Page Routes

| Route | Page | Description |
|-------|------|-------------|
| `/` | Homepage | Landing page with featured content |
| `/about` | About | Personal introduction and skills |
| `/blog` | Blog List | All blog posts with pagination |
| `/blog/[slug]` | Blog Post | Individual blog post (Markdown/MDX) |
| `/projects` | Projects List | Portfolio projects overview |
| `/projects/[slug]` | Project Detail | Individual project page (MDX) |
| `/photos` | Photo Gallery | Image gallery with lightbox |

## 📝 Content Management

### Adding a Blog Post

Create a new `.md` file in `src/content/blog/`:

```markdown
---
title: "Your Post Title"
pubDate: 2026-01-01
description: "Brief description for SEO and previews"
tags: ["tag1", "tag2", "tag3"]
lang: "zh"  # or "en"
---

Your content here...
```

### Adding a Project

Create a new `.mdx` file in `src/content/projects/`:

```mdx
---
title: "Project Name"
description: "Project description"
pubDate: 2026-01-01
tags: ["React", "TypeScript"]
github: "https://github.com/username/repo"
live: "https://example.com"
---

Project details with MDX support...
```

### Content Frontmatter Schema

#### Blog Post

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `title` | string | Yes | Post title |
| `pubDate` | date | Yes | Publication date (YYYY-MM-DD) |
| `description` | string | Yes | SEO description |
| `tags` | string[] | Yes | Categorization tags |
| `lang` | string | No | Language code (zh/en) |

#### Project

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `title` | string | Yes | Project name |
| `description` | string | Yes | Brief description |
| `pubDate` | date | Yes | Publication date |
| `tags` | string[] | Yes | Technology tags |
| `github` | string | No | GitHub repository URL |
| `live` | string | No | Live demo URL |

## ⚡ Commands

### Development

| Command | Description |
|---------|-------------|
| `npm run dev` | Start local dev server at `localhost:4321` with hot reload |
| `npm run build` | Build for production (default environment) |
| `npm run preview` | Preview the production build locally |

### Environment-Specific Builds

| Command | Environment | Output |
|---------|-------------|--------|
| `npm run build:production` | Alibaba Cloud | `dist/` with root base path |
| `npm run build:github` | GitHub Pages | `dist/` with `/portfolio` base path |
| `npm run build:development` | Local | `dist/` with localhost base path |

### Deployment

| Command | Description |
|---------|-------------|
| `npm run deploy:production` | Build and deploy to Alibaba Cloud via SSH |
| `npm run deploy:github` | Build and trigger GitHub Pages deployment |
| `npm run deploy:all` | Deploy to both environments sequentially |

### Utility

| Command | Description |
|---------|-------------|
| `npm run astro` | Run Astro CLI commands |
| `npm run astro -- --help` | Show Astro CLI help |

## 🚀 Deployment

This project supports **three-environment deployment** with automatic and manual triggers:

| Environment | URL | Trigger | Server |
|-------------|-----|---------|--------|
| **Local** | `http://localhost:4321` | `npm run dev` | Local machine |
| **GitHub Pages** | [8bitcloudbot.github.io/portfolio](https://8bitcloudbot.github.io/portfolio) | Git push to `main` | GitHub Actions |
| **Alibaba Cloud** | [vincentbuilds.fun](https://vincentbuilds.fun) | Manual trigger | Alibaba Cloud ECS + Nginx |

### Deployment Methods

#### 1. Local Deployment (Recommended for testing)

```bash
# Development server with hot reload
npm run dev

# Build and preview production version
npm run build:production
npm run preview
```

#### 2. GitHub Pages (Automatic)

Push to `main` branch triggers automatic deployment via GitHub Actions:

```bash
git add .
git commit -m "feat: your changes"
git push origin main
# GitHub Actions automatically builds and deploys
```

#### 3. Alibaba Cloud (Manual)

```bash
# Deploy to production server
npm run deploy:production

# Or use deploy.sh directly
./deploy.sh production
```

#### 4. Deploy to All Environments

```bash
npm run deploy:all
# Builds and deploys to both GitHub Pages and Alibaba Cloud
```

### GitHub Actions Workflow

The CI/CD pipeline supports:

- **Automatic deployment** on push to `main` (GitHub Pages only)
- **Manual deployment** with environment selection:
  - `github` - Deploy to GitHub Pages only
  - `production` - Deploy to Alibaba Cloud only
  - `all` - Deploy to both environments

To trigger manual deployment:
1. Go to repository **Actions** tab
2. Select **"Deploy to Multiple Environments"** workflow
3. Click **"Run workflow"**
4. Choose environment and click **"Run workflow"**

### Environment Variables

Create `.deploy.env` for local deployments (gitignored):

```bash
# Alibaba Cloud Configuration
ALIYUN_SERVER_HOST=your-server-ip
ALIYUN_SERVER_USER=root
ALIYUN_DEPLOY_PATH=/var/www/vincentbuilds
```

For GitHub Actions, configure these secrets in repository settings:
- `ALIYUN_SSH_KEY` - SSH private key for Alibaba Cloud
- `ALIYUN_SERVER_HOST` - Server IP address
- `ALIYUN_SERVER_USER` - Server username
- `ALIYUN_DEPLOY_PATH` - Deployment path on server

For detailed deployment instructions, see [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md).
For site operations guide, see [OPERATIONS_GUIDE.md](./OPERATIONS_GUIDE.md).

## 🔧 Configuration

### Site Configuration

Edit `src/config.ts` to customize site metadata:

```typescript
export const SITE = {
  title: "Your Name",
  description: "Your site description",
  author: "Your Name",
  email: "your.email@example.com",
  github: "https://github.com/yourusername",
  nav: [
    { name: "Blog", path: "/blog", icon: "article" },
    { name: "Projects", path: "/projects", icon: "lightbulb" },
    // Add more navigation items...
  ],
  social: [
    { name: "GitHub", url: "https://github.com/yourusername", icon: "github" },
    // Add more social links...
  ],
};
```

### Multi-Environment Configuration

The `astro.config.ts` supports environment-specific settings:

```typescript
const environments = {
  production: {
    site: 'https://vincentbuilds.fun',
    base: '/',
  },
  github: {
    site: 'https://8bitcloudbot.github.io',
    base: '/portfolio',
  },
  development: {
    site: 'http://localhost:4321',
    base: '/',
  },
};
```

## 🧪 Testing

### Local Testing Checklist

- [ ] Run `npm run dev` and test all pages
- [ ] Test dark mode toggle
- [ ] Verify responsive design on mobile
- [ ] Check blog post rendering
- [ ] Test navigation links
- [ ] Verify images load correctly

### Build Testing

```bash
# Test production build
npm run build:production
npm run preview

# Test GitHub Pages build
npm run build:github
npm run preview
```

### Performance Testing

Use [Lighthouse](https://developers.google.com/web/tools/lighthouse) to verify:
- Performance score > 90
- Accessibility score > 90
- SEO score > 90

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [README.md](./README.md) | This file - Project overview and setup |
| [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) | Detailed deployment instructions |
| [OPERATIONS_GUIDE.md](./OPERATIONS_GUIDE.md) | Site operations and maintenance |

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'feat: add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

### Development Guidelines

- Follow existing code style and conventions
- Add TypeScript types for new components
- Test changes locally before committing
- Write meaningful commit messages (use [Conventional Commits](https://www.conventionalcommits.org/))

## 🐛 Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| Build fails with Node.js error | Ensure Node.js >= 22.12.0 (`node -v`) |
| Images not loading | Check `public/` directory and file paths |
| GitHub Pages 404 | Verify `base` path in `astro.config.ts` |
| Deployment fails | Check SSH keys and server configuration |

### Getting Help

- Check [GitHub Issues](https://github.com/8BitcloudBot/portfolio/issues) for known issues
- Review [Astro Documentation](https://docs.astro.build) for framework questions
- Open a new issue with detailed error information

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

You are free to use this project as a template for your own portfolio. Attribution is appreciated but not required.

## 🙏 Acknowledgments

- [Astro](https://astro.build) - The web framework for content-driven websites
- [Tailwind CSS](https://tailwindcss.com) - Utility-first CSS framework
- [React](https://react.dev) - JavaScript library for building user interfaces
- [Heroicons](https://heroicons.com) - Beautiful hand-crafted SVG icons

## 📧 Contact

- **Email**: 17889786156@163.com
- **GitHub**: [@8BitcloudBot](https://github.com/8BitcloudBot)
- **Website**: [vincentbuilds.fun](https://vincentbuilds.fun)

---

**Built with ❤️ using Astro, React, and Tailwind CSS**
