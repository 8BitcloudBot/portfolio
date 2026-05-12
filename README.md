# Vincent Hu - Portfolio

Personal website and blog built with **Astro**, **React**, **Tailwind CSS**, and **MDX**.

## 🚀 Live Demo

| Environment | URL |
|-------------|-----|
| **Production** | [vincentbuilds.fun](https://vincentbuilds.fun) |
| **GitHub Pages** | [8bitcloudbot.github.io/portfolio](https://8bitcloudbot.github.io/portfolio) |

## ✨ Features

- **Blog** - Markdown/MDX blog with syntax highlighting
- **Projects** - Showcase portfolio projects with detailed pages
- **Photos** - Image gallery
- **Dark Mode** - Theme toggle with system preference detection
- **SEO Optimized** - Sitemap, meta tags, structured data
- **Responsive** - Mobile-first design

## 🛠️ Tech Stack

| Category | Technology |
|----------|-----------|
| Framework | [Astro 6.x](https://astro.build) |
| UI Components | [React 19](https://react.dev) |
| Styling | [Tailwind CSS 4.x](https://tailwindcss.com) |
| Content | MDX |
| Sitemap | [@astrojs/sitemap](https://docs.astro.build/en/guides/integrations-guide/sitemap/) |
| Deployment | Nginx + GitHub Pages + GitHub Actions |

## 📦 Installation

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

## 📁 Project Structure

```
WebPage/
├── public/             # Static assets (photos, favicon)
├── src/
│   ├── components/     # Reusable components
│   │   ├── icons/      # SVG icon components
│   │   ├── layout/     # Header, Footer, BackToTop
│   │   ├── blog/       # Blog list & item components
│   │   ├── projects/   # Project card & list components
│   │   └── ui/         # SEO, ThemeToggle
│   ├── content/        # Content collections
│   │   ├── blog/       # Blog posts (Markdown)
│   │   └── projects/   # Project pages (MDX)
│   ├── layouts/        # Page layouts
│   ├── pages/          # Routes (index, about, blog, projects, photos)
│   ├── styles/         # Global CSS
│   └── config.ts       # Site configuration
├── .github/workflows/  # CI/CD (GitHub Actions)
├── astro.config.ts     # Astro configuration
├── deploy.sh           # Multi-environment deploy script
└── deploy.env          # Alibaba Cloud deploy config (gitignored)
```

## ⚡ Commands

| Command | Description |
|---------|-------------|
| `npm run dev` | Start local dev server at `localhost:4321` |
| `npm run build` | Build for production |
| `npm run preview` | Preview the production build locally |
| `npm run deploy:github` | Deploy to GitHub Pages |
| `npm run deploy:production` | Deploy to Alibaba Cloud server |
| `npm run deploy:all` | Deploy to all environments |

## 🚀 Deployment

This project supports three-environment deployment:

| Environment | URL | Trigger |
|-------------|-----|---------|
| **Local** | `http://localhost:4321` | `npm run dev` |
| **GitHub Pages** | `https://8bitcloudbot.github.io/portfolio` | `npm run deploy:github` or git push |
| **Alibaba Cloud** | `https://vincentbuilds.fun` | `npm run deploy:production` |

For detailed deployment instructions, see [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md).
For site operations guide, see [OPERATIONS_GUIDE.md](./OPERATIONS_GUIDE.md).

## 📄 License

MIT License - feel free to use this project as a template for your own portfolio.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
