---
title: "博客更新：增加 hugo-notice 功能"
createDate: 2025-01-04T20:55:58+09:00
publishDate: 2025-01-05T20:54:40+09:00
draft: false
tags: ["博客", "Hugo", "主题"]
keywords: ["博客", "Hugo", "主题"]
slug: "blog-updates-introduce-hugo-notice"
icon: ⚠️
---

自从[上次重写博客的样式]({{< relref "Be_Water_My_Friend" >}})以来，一直有一些不痛不痒的坑没有填完，其中有一个就是显示提示、警告框之类的功能。老实说我不太清楚怎么用中文准确表达这个功能，英文方面好像也乱乱的，比如在 GitHub 的 Markdown 语法里叫 [Alerts](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax#alerts)，在 Obsidian 里叫 [Callouts](https://help.obsidian.md/Editing+and+formatting/Callouts)，在 Material for MkDocs 里叫 [Admonitions](https://squidfunk.github.io/mkdocs-material/reference/admonitions/)……

而在今天要使用的 Hugo 组件又把它叫作 [Notice](https://github.com/martignoni/hugo-notice)

<!--more-->

## hugo-notice 功能展示

总而言之，说了这么多其实这个功能非常常见，大概就是长下面这些样子：

{{< notice info >}}
这是一条信息。
{{< /notice >}}

{{< notice warning >}}
这是一条警告信息。
{{< /notice >}}

{{< notice note >}}
这是一条注释信息。
{{< /notice >}}

{{< notice tip >}}
这是一条提示信息。
{{< /notice >}}

突然感觉我这个朴素的博客文章样式一下子鲜艳起来了。而且，这个 hugo-notice 组件**在日间模式和夜间模式下还使用了不同的配色**，完成度很高，这也是我直接拿来主义懒得自己从头写的一个原因。

## 使用 hugo-notice

看文档有两种使用方法，一是用 Hugo module，另一种是当作 Hugo 的主题放到 themes 目录下。我个人没有用过 Hugo module，就用最简单直接的方法——当作主题导入使用它提供的 shortcode。

1. 把 `hugo-notice` 当作一个 git submodule 放到 themes 目录下

```bash
git submodule add https://github.com/martignoni/hugo-notice.git themes/hugo-notice
```

2. 把 `hugo-notice` 加到 Hugo 配置文件中 `theme` 选项的列表中的最左边。比如我的配置像是这样：

```toml
theme = ["hugo-notice", "futu"]
```

3. 完成了上面两步，基本上就可以使用 hugo-notice 提供的 shortcode 了，基本用法如下：

```go-html-template
{{</* notice info */>}}
这是一条信息。
{{</* /notice */>}}
```

除了 `info`，还提供了 `warning`、`note` 以及 `tip` 这几种不同的样式可供使用。

## 微调 hugo-notice（可选）

完成上面的步骤如果你没遇到什么问题，基本上这里的微调并不需要。但如果你本身使用的主题使用的多语言功能不被 hugo-notice 支持，又或者你使用的主题支持的夜间模式不是在 body 标签的 class 属性里加入 `dark`，你可能需要稍微调整一下相关的代码。比如我这个博客的语言使用了 `zh-Hans` 以及夜间模式我是在 html 标签的 class 里加入 `dark-mode`。于是我就 fork 了原来的仓库，在此基础上做了些许修改使它可以与我的博客主题相兼容。感兴趣的话可以查看 [yuanji-dev/hugo-notice@6ff5846](https://github.com/yuanji-dev/hugo-notice/commit/6ff58460fc2ccebddbe9a80eec9694364922bd9a) 这个 commit。

## 快速输入 shortcode 的代码片段（可选）

为了让 Hugo 的 shortcode 在编辑器里用得更容易，我通常会制作一些代码片段（snippet）。虽然我使用 Neovim 的插件来输入这个代码片段，但理论上 VS Code 或者支持 VS Code 代码片段格式的编辑器应该也能用。这样在编辑器输入 `h-notice` 就可以快速输入这个 shortcode 了。

```json
{
  "Hugo notice shortcode": {
    "prefix": "h-notice",
    "body": ["{{</* notice ${1|warning,info,note,tip|} */>}}", "${0}", "{{</* /notice */>}}"],
    "description": "Add notice box to document"
  }
}
```

## 最后

本来在写另一篇博客，当时想加入一些提示的话，才发现现在的主题还没有这个功能。结果就花时间找到了 hugo-notice 这个组件，以及又花了点时间写了这篇博客，导致原本在写的那篇博客却被耽搁了。感觉这样的事情经常出现，甚至已经渐渐习惯为了做某件事情，却被做那件事情的途中产生的支线剧情而支配做完了另一件看似毫不相关的事情。（这样的情况，想必读我博客的读者应该不难理解，对吗？）
