---
title: "把 emoji 当作 favicon"
date: 2022-10-01T20:41:04+09:00
draft: false
tags: ["Hugo", "博客"]
keywords: ["Hugo", "博客", "favicon", "emoji"]
slug: "using-emoji-as-favicon"
icon: 🎆
---

平时逛 [V2EX](https://www.v2ex.com/) 的时候会注意到这个网站一些设计上的细节，其中之一就是不同的节点页面会有自己特有的 favicon，这相对于全站只使用一个统一的图案来说活泼不少，对于喜欢在浏览器里打开许多标签的用户来说也非常友好。

另外日常使用的 [Slack](https://slack.com/) 和 [logseq](https://logseq.com/)（包括之前使用的 [Notion](https://www.notion.so/)）之类的软件，emoji 的存在对我来说也是让人乐于使用的一个重要原因。

于是我就想是不是可以把 emoji 作为 favicon 给我这个博客也加入一点儿这样的生机？

<!--more-->

## 原理

稍微搜索了一下 Google，很快找到了答案，具体感兴趣的朋友可以参考 [絵文字をファビコンとして表示する簡単な方法](https://zenn.dev/catnose99/articles/3d2f439e8ed161) 这篇文章。

```html
<link
  rel="icon"
  href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text x=%2250%%22 y=%2250%%22 style=%22dominant-baseline:central;text-anchor:middle;font-size:90px;%22>😸</text></svg>"
/>
```

简单来说因为现在很多现代浏览器支持 [SVG 作为 favicon](https://caniuse.com/link-icon-svg)，而 emoji（或是普通文字）可以直接嵌入 `<text>` 中，于是 emoji 就直接在 favicon 上显示出来了。

## Hugo 模板

首先定义用法，就是在 Mardkown 文件的 [Front Matter](https://gohugo.io/content-management/front-matter/)，定义一个 `icon` 属性像是这样：`icon: 🎉`，然后更新相应的模板即可，代码如下：

```diff
diff --git a/layouts/partials/head/icon.html b/layouts/partials/head/icon.html
index cab9c41..1f47494 100644
--- a/layouts/partials/head/icon.html
+++ b/layouts/partials/head/icon.html
@@ -1,5 +1,8 @@
 <link rel="apple-touch-icon" sizes="180x180" href="{{ "apple-touch-icon.png" | relURL }}" />
 <link rel="icon" type="image/png" sizes="32x32" href="{{ "favicon-32x32.png" | relURL }}" />
 <link rel="icon" type="image/png" sizes="16x16" href="{{ "favicon-16x16.png" | relURL }}" />
+{{ with .Params.icon }}
+<link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text x=%2250%%22 y=%2250%%22 style=%22dominant-baseline:central;text-anchor:middle;font-size:90px;%22>{{ . }}</text></svg>">
+{{ end }}
 <link rel="manifest" href="{{ "site.webmanifest" | relURL }}" />
-<link rel="shortcut icon" href="{{ "favicon.ico" | relURL }}" />
+<link rel="icon" sizes="16x16" href="{{ "favicon.ico" | relURL }}" />
```

顺便用此机会回顾了一下模板里 link 标签的使用：

1. 按照最新 [MDN 的 Links types 文档](https://developer.mozilla.org/en-US/docs/Web/HTML/Link_types)，**`shortcut` 已经不推荐使用（原文是 must not use it anymore）**
2. 我才发现一直以来 Chrome 无论如何都只会下载 `favicon.ico` 而不是其他 `png` 文件，研究了一下加上 `sizes=16x16` 就好了。

## 问题

虽然说大部分现代浏览器都支持在 favicon 里显示 SVG，但目前（2022 年现在）为止 Safari 浏览器并不支持，不过最多也就是沿用原有的逻辑使用全站统一的图标而已。当然也可以用一些公共 CDN 提供的 emoji png 图片作为 fallback，这个就日后再研究吧。

## 最后

今天晚上托妻子的福，看到了来日本之后的第一次烟火大会，本文就使用 🎆 作为 favicon 吧。

## 2022/10/08 更新

发现改完之后 [Nu Html Checker](https://html5.validator.nu/) 提示有错误，原因是 `link` 的 `href` 属性需要转义特殊字符，更新见 [bf04517a](https://gitlab.com/yuanji/futu/-/commit/bf04517a2c2a5d1dee8f43cad647db75d298bc63)

参考： https://stackoverflow.com/a/7109208
