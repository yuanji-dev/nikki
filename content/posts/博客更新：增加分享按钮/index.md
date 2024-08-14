---
title: "博客更新：增加分享按钮"
createDate: 2024-01-05T19:45:08+09:00
publishDate: 2024-01-06T19:27:33+09:00
draft: false
tags: ["博客", "Hugo", "主题"]
keywords: ["博客", "Hugo", "主题"]
slug: "blog-updates-add-share-buttons"
icon: 📝
---

上次在{{< relanchor "2023年博客回顾" >}}中提到准备给博客文章加上分享按钮，这一次趁着新年假期还没结束，尝试着做了一下，大概花了一下午时间。本文就把这个过程记录一下。

<!--more-->

## 分享到哪？

首先摆在面前的一个问题是，我希望把文章都分享到哪？稍微参考了一下一些平时浏览的网站，我大致列出了下面几个，简单附加了我个人对这些网站的看法：

- X（Twitter）：我目前（2024 年 1 月）浏览最多的社交网络
- Telegram：我目前（同上）使用最多的通讯软件
- 豆瓣：我之前最活跃使用的社交网络，目前半隐退中
- Reddit：打发时间的好帮手，潜水 10 年以上
- Facebook：虽然自己不用，但谈到社交网络就不得不说起的存在
- Pocket：似乎是稍后阅读类最知名软件
- 电子邮件：为了本格互联网使用者

## 分享按钮的实现方法

调查了一些现有网站上的实现方法，发现大体上有两大类：

1. 使用现成的服务，好处是非常方便，只需要引入一个 JavaScript 脚本，然后在需要的地方添加一个 `div` 元素即可。目前常见的还在提供服务的有：

   - [ShareThis: Digital Behavioral Data Solutions | Global & Real-Time](https://sharethis.com/)
   - [AddToAny: Share Buttons by the Universal Sharing Platform](https://www.addtoany.com/)

2. 完全不使用 JavaScript，每个分享按钮就是一个可点击的图标链接。虽然从使用者的角度不如上面简单，但是只要稍微有一些 Hugo 模板和 CSS 的知识，再加上下面这个脚手架网站，自己做一个也并非难事。

   - [Social Media Sharing Buttons. No JavaScript. No tracking. Super fast and easy.](https://sharingbuttons.io/)

## 纯 HTML + CSS 实现分享按钮

本着让本博客最大限度不依赖于 JavaScript 就能使用大部分功能的宗旨，我当然选择了第二个方法。通过 https://sharingbuttons.io 生成了一个基本的 HTML 骨架和一个能用的 CSS 之后，魔改之路就开始了。

主要的更改大概是下面几个：

1. 替换最新的图标和配色，最显然的 Twiiter 已经改成 X，Facebook 和 Reddit 等也都有细微改动，通过 [Simple Icons](https://simpleicons.org/) 可以获得各种品牌最新 Logo 的 SVG 和配色。
2. 添加缺失的服务，比如豆瓣和 Pocket，除了需要跟上面一样获得 Logo 和配色之外，还需要构造分享的 URL，比如豆瓣的像是这样：`https://www.douban.com/share/service/?href={{ .Permalink }}&amp;name={{ .Title }}`，各家虽然名称不尽相同，但基本都是需要提供链接和一个可选的标题就行。
3. 最后可选的一步就是清理一下最初生成的 HTML 和 CSS，我甚至把 CSS 转写成了 SCSS 以保持本博客主题样式的一贯性。

代码虽然不复杂但是稍微有点冗长，感兴趣的朋友可以直接参考 [feat: add share buttons for post · yuanji-dev/futu@1ce5993](https://github.com/yuanji-dev/futu/commit/1ce599375e66e524e54f9fb810e9ce315e409b27) 主题仓库里这个 commit。其实也许可以做得更灵活一些，比如支持在 Hugo 可以按需配置生成分享按钮，不过目前的功能已经够我自已用了。

## 在 Hugo 中启用分享按钮

在 Hugo 主题里添加了这个分享按钮的功能后，使用起来就很简单了，就像博客的其他一些非主要的功能（比如显示目录、显示相关文章）一样，我提供了相同的启用逻辑：

1. 如果需要全局所有文章启用分享按钮，就在配置文件（比如 `config.toml`）里设置 `enableShare` 为 `true` 。
2. 如果只需要部分页面启用分享按钮，那就在那些文章的 [front matter](https://gohugo.io/content-management/front-matter/) 里设置 `enableShare` 为 `true`。
3. 同样地，如果需要在特定页面禁用分享按钮，就在那些文章的 front matter 里设置 `enableShare` 为 `false` 。

## 最后

通过差不多一下午的努力，给自己的博客加上了社交属性。虽然不知道多少人会使用，但是不管怎么说从我的角度当然希望自己的文章能被更多的人读到，所以读者朋友们，请毫不犹豫地使用这些分享按钮，分享你觉得有意思的文章给亲朋好友吧！

对于那些不使用 Hugo 的朋友，如果也想给自己的网站加上类似的功能，我做了一个[单 HTML 文件的 demo](/misc/share-buttons-demo.html)，也许你可以直接拿它改一改加到自己的网站。
