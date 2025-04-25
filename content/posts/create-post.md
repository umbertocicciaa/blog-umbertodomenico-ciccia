---
date: '2025-04-24T23:49:04+02:00'
draft: true
title: 'Create Post'
---

# Create a blog like this

## How to Create a Personal Blog with Hugo and PaperMod 🚀

Setting up a fast, minimalist blog with [Hugo](https://gohugo.io/) and [PaperMod](https://github.com/adityatelange/hugo-PaperMod) is easier than you think. Whether you're writing tutorials, sharing your journey, or just want a place to think in public—this guide will help you spin up your site in no time.

## 🛠 Prerequisites

- [Install Hugo](https://gohugo.io/getting-started/install/) (version **≥ v0.112.4**)
- Git installed on your system

## 1. Create a New Hugo Site

Open your terminal and run:

```bash
hugo new site MyFreshWebsite --format yaml
# Replace 'MyFreshWebsite' with your preferred site name
cd MyFreshWebsite
```

## 2. Install PaperMod Theme

Add PaperMod as a Git submodule:

```bash
git submodule add --depth=1 https://github.com/adityatelange/hugo-PaperMod.git themes/PaperMod
git submodule update --init --recursive
git submodule update --remote --merge
```

## 3. Set the Theme

Open your `hugo.yml` file and set the theme:

```yaml
theme: ["PaperMod"]
```

## 4. Use the Example Site (Optional but Recommended)

To get started with a working structure, copy the [exampleSite](https://github.com/adityatelange/hugo-PaperMod/tree/exampleSite):

```bash
cp -r themes/PaperMod/exampleSite/* .
```

Then customize your content, settings, and config to suit your style.

## 5. Run Your Site Locally 🧪

```bash
hugo server -D
```

Navigate to `http://localhost:1313` to see your blog in action.

## ✅ You're Done

You now have a clean, blazing-fast blog powered by Hugo and styled with the elegant PaperMod theme.

> _Source & credits: [PaperMod Wiki – Installation](https://github.com/adityatelange/hugo-PaperMod/wiki/Installation)_
