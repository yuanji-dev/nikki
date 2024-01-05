---
title: "博客更新：增加分享按钮"
createDate: 2024-01-05T19:45:08+09:00
publishDate: 2024-01-07
draft: true
tags: ["博客", "Hugo", "主题"]
keywords: ["博客", "Hugo", "主题"]
slug: "blog-updates-add-share-buttons"
icon: 📝
---

上次在{{< relanchor "2023年博客回顾" >}}中提到准备给这个博客加上分享按钮，这一次趁着新年假期还没结束，尝试着做了一下，大概花了一下午时间。本文就把这个过程记录一下。

<!--more-->

## 分享到哪？

首先一个摆在面前的问题是，我都需要哪些分享按钮？稍微参考了一下一些平时浏览的网站，我大致列出了下面几个：

- X（Twitter）
- Telegram
- 豆瓣
- Reddit
- Facebook
- Pocket
- 电子邮件

## 分享按钮的实现方法

调研了一些现有网站上的实现方法，发现有无非是两大类：

1. 使用现成的服务，好处是非常方便，只需要引入一个 JavaScript 脚本，然后在需要的地方添加一个 `div` 元素即可。目前常见的服务有：

- [ShareThis: Digital Behavioral Data Solutions | Global & Real-Time](https://sharethis.com/)
- [AddToAny: Share Buttons by the Universal Sharing Platform](https://www.addtoany.com/)

2. 自己手动制作，这就需要一些基础的 Hugo 主题开发的只是，外加一些 CSS 技巧，还有就是收集各家分享服务的用法（构造 URL）

## 基于 Hugo 模板的分享按钮

本着让本博客最大限度不依赖于 JavaScript 的宗旨，我当然选择了第二个方法。不过倒也不需要从头完全自己写，有一个现成的工具 [Social Media Sharing Buttons. No JavaScript. No tracking. Super fast and easy.](https://sharingbuttons.io/)

## 如何使用

## 可选：变得可配置一点
