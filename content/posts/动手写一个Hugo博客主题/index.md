---
title: "动手写一个 Hugo 博客主题"
date: 2021-08-29T11:58:46+09:00
draft: false
tags: ["Hugo", "博客", "主题"]
keywords: ["Hugo", "博客", "主题"]
slug: "creating-a-hugo-theme"
---

在读这篇文章的朋友可能已经注意到本博客的主题换了个样，那是因为过去的两个星期我自己写了套 Hugo 的主题。

倒也不是对上一套主题有什么不满，一来是之前从来是拿来主义，都没有正经写过 Hugo 的主题，这次想试一试。另外就是对于上一套主题一直也有缝缝补补的修改，想着与其如此不如自己写一套得了。

于是，借着 Hugo 完善的文档以及上一套主题的代码，正式走上了一条缝合的道路。这篇文章就来介绍一下如何写一个适用于 Hugo 的博客主题。

只想看代码的可以直接移步： https://github.com/masakichi/futu/tree/v1.0.0

<!--more-->

## 特色

在介绍如何写主题之前，先说一说我这个新主题的特色吧，实际上也没啥特色，算是把上一个主题的精华继承下来然后去掉我用不上的功能，就像我给他取名叫「futu」一样，就是一个极为普通（ふつう）的主题。

- 基于 Bootstrap 5，因此自带了响应式的功能
- 自定义导航栏菜单
- 归档页面
- 标签页面
- 文章页
  - 带目录
  - 显示文章 Git 更新记录
  - disqus 评论
  - 文章过期提示
- 底部可自定义带图标的联系方式
- 基本的 SEO 功能
- 搜索功能（利用 Google 的 site: 搜索）
- 杂项
  - 404 页面
  - robots.txt
  - sitemap

## 起步

写一个 Hugo 的主题其实并不复杂，比我想象中的要容易得多（之前总是被它繁杂的文档望而却步），当然也得益于 Hugo 这个项目日趋成熟，很多相同的部分、功能，已经内置，在主题模板中只需稍加引入即可。

首先，Hugo 的命令行工具提供了一个命令来生成主题的脚手架文件，命令如下（futu 为我的主题名）：

```bash
hugo new theme futu
```

有了这个脚手架之后，首先也是最关键的入口文件当属 `layouts/_default/baseof.html`，在这个文件里可以定义网站的基本组成部分，比如 `head`，`main`，`footer` 等等，下面是我主题里这个文件的内容。

```go-html-template
<!DOCTYPE html>
<html>
  <head>
    {{- partial "head.html" . -}}
    <title>{{ block "title" . }}{{ .Site.Title }}{{ end }}</title>
  </head>
  <body>
    {{- partial "header.html" . -}}
    <main class="container">{{- block "main" . }} {{- end }}</main>
    {{- partial "footer.html" . -}} {{- partial "script.html" . -}}
  </body>
</html>
```

{{< admonition primary 点击显示我的主题结构 "true" >}}

```bash
.
├── archetypes
│   └── default.md
├── i18n
│   ├── en.yaml
│   └── zh-CN.yaml
├── layouts
│   ├── 404.html
│   ├── _default
│   │   ├── baseof.html
│   │   ├── _markup
│   │   │   ├── render-heading.html
│   │   │   ├── render-image.html
│   │   │   └── render-link.html
│   │   ├── section.html
│   │   ├── section.md
│   │   ├── single.html
│   │   ├── single.md
│   │   ├── summary.html
│   │   ├── term.html
│   │   └── terms.html
│   ├── index.html
│   ├── partials
│   │   ├── caution.html
│   │   ├── disqus.html
│   │   ├── footer.html
│   │   ├── header.html
│   │   ├── head.html
│   │   ├── icons
│   │   │   ├── arrow-left-circle.html
│   │   │   ├── arrow-right-circle.html
│   │   │   └── search.html
│   │   ├── meta.html
│   │   └── script.html
│   ├── posts
│   │   └── single.html
│   ├── robots.txt
│   ├── shortcodes
│   │   ├── admonition.html
│   │   └── music.html
│   └── sitemap.xml
├── LICENSE
├── package-lock.json
├── static
│   ├── css
│   │   ├── bootstrap.min.css
│   │   └── style.css
│   ├── img
│   │   └── 404.jpeg
│   ├── js
│   │   ├── bootstrap.bundle.min.js
│   │   └── iconfont.js
│   └── sitemap.xsl
└── theme.toml
```

{{< /admonition >}}

想必应该很好读懂，`{{- partial "head.html" . -}}`，两个大括号是 Hugo 的模板语言标记，在里面可以定义变量，调用函数等，这里的 `partial` 函数会引用 `head.html` 的内容，并将当前上下文 `.` 传入，也许你也留意到了内侧括号旁的横线`-`，那个是用来清除模板周围的空格符号，比如左边的`-`意味着将左侧模板左侧的空白符号统统清除，详情看[这里](https://gohugo.io/templates/introduction/#whitespace)。

另外一个值得注意的地方是类似 `{{ block "title" . }}{{ .Site.Title }}{{ end }}` 这句，这个 `block` 函数可以申明一个“块”，然后在其他模板文件中通过定义这个“块”的不同内容达成不同页面有不同标题，如果不定义则使用默认的站点名称 `{{ .Site.Title }}`。看到这里问题都不大，只是千万要注意 **`block`** 只在 `baseof.html` 才有效，这也是为什么我没有把

```go-html-template
<title>{{ block "title" . }}{{ .Site.Title }}{{ end }}</title>
```

这一行放在 `head.html`，当时着实被这一点浪费了不少时间。详情可以看 [Hugo 官方论坛的解释](https://discourse.gohugo.io/t/block-in-a-partial-and-defining-in-a-page/4999/2)。

还有，如果你也使用 VS Code 开发并且使用 prettier format 代码，强烈建议安装一下 prettier 用于 Hugo 模板的插件，不然自动格式化的代码丑的亲妈都不认。

```bash
npm install --save-dev prettier prettier-plugin-go-template
```

再在 `.prettierrc` 写：

```json
{
  "overrides": [
    {
      "files": ["*.html"],
      "options": {
        "parser": "go-template"
      }
    }
  ]
}
```

## 文档阅读

有了起步阶段的基础知识，接下来基本上属于阅读文档，搬运示例代码，修改代码的循环，实在不行还可以看看 [Hugo 的代码](https://github.com/gohugoio/hugo/tree/master)。

对于主题开发来讲，文档大体分为三大块，分别是

- [Templates](https://gohugo.io/templates/)
- [Functions](https://gohugo.io/functions/)
- [Variables](https://gohugo.io/variables/)

在我的开发过程中用到的，或者有意思的文档我在此稍作记录。

### 模板读取顺序

对于我们在 `layouts` 目录下的各种模板文件，Hugo 有个预置的读取优先级，详细参考这个页面：[Hugo's Lookup Order | Hugo](https://gohugo.io/templates/lookup-order/)

简单来说，对于`主页`，`文章页`，`归档页`，`分类列表页`，`分类页`这些不同种类的页面，都有相应的地方读取模板，如果某个页面有多个地方的模板文件相匹配，则只有优先级高的模板会被使用。

如果没有主意，你可以用我的模板构成作一个参考：

| 页面                  | 模板地址                       | 说明                             |
| --------------------- | ------------------------------ | -------------------------------- |
| 主页                  | layouts/index.html             |                                  |
| 文章页 (posts 目录下) | layouts/posts/single.html      | 在 posts 目录下的普通文章        |
| 其他文章页            | layouts/\_default/single.html  | 比如 /about 页，由 about.md 生成 |
| 归档页                | layouts/\_default/section.html | 如 /posts/                       |
| 分类列表页            | layouts/\_default/terms.html   | 如 /tags/                        |
| 分类页                | layouts/\_default/term.html    | 如 /tags/日语/                   |

### 内置模板

除了自己写模板呢，Hugo 实际上已经内置了不少通用的模板，称为 [Internal Templates](https://gohugo.io/templates/internal)，比如 disqus，google analytics，可以通过 `template` 函数引入，比如在合适的地方 `{{ template "_internal/disqus.html" . }}`，这样在配置文件中定义了 `disqusShortname` 之后，就可以显示评论了。

对于这些内置模板的内容，感兴趣的朋友可以前往 [Hugo 的源代码](https://github.com/gohugoio/hugo/tree/master/tpl/tplimpl/embedded/templates)阅读。[\_defualt 目录下](https://github.com/gohugoio/hugo/tree/master/tpl/tplimpl/embedded/templates/_default)还有 `robots.txt`，`sitemap.xml`，`rss.xml` 的默认模板。

### 静态文件

[静态文件](https://gohugo.io/content-management/static-files/)就很简单了，位于 `static` 目录下，Hugo 会在生成页面时直接将他们拷贝至根目录。以下是我用到的一些静态文件。

```bash
static
├── css
│   ├── bootstrap.min.css
│   └── style.css
├── img
│   └── 404.jpeg
├── js
│   ├── bootstrap.bundle.min.js
│   └── iconfont.js
└── sitemap.xsl
```

### i18n

这部分也不复杂，只需在 `i18n` 目录下定义好对应关系，对于单词单复数的问题可以通过 `one` 和 `other` 字段解决，比如

```yaml
readingTime:
  one: One minute to read
  other: "{{.Count}} minutes to read"
```

在模板中引用的时候 `{{ i18n "readingTime" .ReadingTime }}` 即可。

此外，还有一个有用的函数 [dict](https://gohugo.io/functions/dict/) 可以用来构造一个对象，赋予它相应字段，以便可以让 i18n 里的模板可以渲染。

参考：

- [Translation of Strings](https://gohugo.io/content-management/multilingual/#translation-of-strings)
- [i18n](https://gohugo.io/functions/i18n/)

### Markdown Render Hooks

这个 [Markdown Render Hooks](https://gohugo.io/getting-started/configuration-markup/#markdown-render-hooks) 就比较有意思了，尤其适合我这种使用 Bootstrap 框架的，因为我们要给某个组件赋予样式，就必须给这个组件赋予相应的 `class`，这个 Hooks 就是（部分）解决这个问题的，比如说我们想给 Markdown 渲染出的 `img` HTML 标签加上某个（些）`class` 怎么办呢？

可以创建 `layouts/_default/_markup/render-image.html` 这么一个文件，里面写上

```go-html-template
<p>
  <img
    class="img-fluid"
    src="{{ .Destination | safeURL }}"
    alt="{{ .Text }}"
    {{ with .Title }}title="{{ . }}"{{ end }}
  />
</p>
```

这样一来，Markdown 在渲染的时候，遇到图片就会采用这里的逻辑。同理给链接加上没有下划线的样式，又或者如果是外部链接在新标签页打开等等的功能就可以实现了。不过，目前只支持以下三种。

- image
- link
- heading

## 问题与解决

大部分时间除了阅读文档之外，就是解决一些琐碎的问题了，这里也分享一下我这个菜鸟总结的一些经验。

### 如何 Debug

Print 大法，简而言之就是在模板中插入如下语句，`$.` 代表全局上下文。

```go-html-template
{{ printf "%#v" $.Site }}
```

详见：[Template Debugging | Hugo](https://gohugo.io/templates/template-debugging/)

### 搜索功能

上一个主题并没有自带搜索功能，另外静态博客的搜索似乎也是一个痛，需要不少努力而实际上似乎效果有限，我就直接偷懒用 Google 的搜索得了。不过在写搜索表单的时候还是学到了一个小技巧值得分享一下。

其实我想实现的功能很简单，一个搜索框，一个搜索按钮，按下按钮然后在新窗口打开 Google，并且自动搜索 `keywords site:blog.gimo.me`，这个功能如果只是一个链接倒是会简单不少，不过换成表单就要稍微麻烦一点，不过效果还是挺不错的。示例代码如下，关键是这个隐藏的 `<input type="hidden" name="q" value="site:blog.gimo.me" />`。

```go-html-template
<form action="https://google.com/search" target="_blank" class="row">
  <div class="col-auto">
    <input class="form-control me-2" type="search" placeholder="{{ i18n "search" }}" name="q" />
    <input type="hidden" name="q" value="site:blog.gimo.me" />
  </div>
  <button class="col-auto btn btn-outline-success" type="submit">
    {{ partial "icons/search.html" . }}
  </button>
</form>
```

### 固定导航栏

固定导航栏本身倒不是什么难事，在 Bootstrap 里就是一个 `.fixed-top` 不过它带来了两个衍生问题，

1. 页面头部的一部分会被这个“漂浮”的固定导航栏挡住
2. 目录跳转到相应的大标题同样被挡住

对于第一个问题倒是简单，直接对于整个 `body` 设定一个合适的 `padding-top` 即可。

```css
body {
  padding-top: 56px;
}
```

第二个问题就相对麻烦一点，而且遭遇这个问题的人不在少数，比如 [html - Fixed page header overlaps in-page anchors - Stack Overflow](https://stackoverflow.com/questions/4086107/fixed-page-header-overlaps-in-page-anchors)，里面列举了多种解决这个问题的手段，懒惰如我当然选了一个最简单的方法（[scroll-padding](https://developer.mozilla.org/en-US/docs/Web/CSS/scroll-padding)），当然坏处是支持的浏览器会少一些。由于这个 padding 的值和问题 1 一致，故定义一个全局变量：

```css
:root {
  --body-padding-top: 56px;
}
html {
  scroll-padding: var(--body-padding-top) 0 0 0;
}
body {
  padding-top: var(--body-padding-top);
}
```

### 重定向

严格来说这个和主题并没有直接联系，不过借着换主题的机会整理了一下已有文章的链接。做了几个调整：

1. 统一使用 `slug` 来定义 URL，之前在 [Front Matter](https://gohugo.io/content-management/front-matter) 里混用了 `url` 和 `slug` 两个字段
2. 把目录 `post` 改成 `posts`，这样就导致原来博客的所有文章页的地址从 `/post/xxx` 变成了 `/posts/xxx` 了，这么做的主要原因是为了和分类页的 `/tags` `/tags/xxx` 结构保持一致。

1 没有啥好办法，写了句 `sed` 批量处理一下，2 的话有两种方法，我都用上了，首先使用 Hugo 内置的 [Alias 功能](https://gohugo.io/content-management/urls/#aliases)，给所有文章的 Front Matter 里加上 `alias`（写了段 py 脚本简单处理下）。这可以理解为一种软重定向，实现的原理可以看 Hugo 的文档，这种方法的好处是不依赖部署的平台都能实现跳转，坏处是对搜索引擎不太友好似乎。另一种是用我的部署平台 Cloudflare 提供的跳转功能，只需定义一个新旧链接的 Map，放在静态文件目录的 [\_redirects](https://github.com/masakichi/nikki/blob/master/static/_redirects) 文件里。文件内容如下（部分）

```txt
/post/ /posts/ 301
/post /posts/ 301
/post/vehicle/ /posts/vehicle/ 301
/post/using-namecheap-email-hosting-service/ /posts/using-namecheap-email-hosting-service/ 301
/post/using-hugo-to-generate-readme-md/ /posts/using-hugo-to-generate-readme-md/ 301
/post/cloudcone-easter-egg-hunt-2021/ /posts/cloudcone-easter-egg-hunt-2021/ 301
```

由于文章链接发生了变化，导致 Disqus 上的评论也需要做一下迁移，同样需要准备一个新旧链接的 csv 文件，在 https://disqus.com/admin/discussions/migrate/ 选择上传即可。内容格式为旧链接在前，新链接在后逗号隔开。

### 文章修改时间

本来解决了重定向的问题以为万事大吉了，没想到老革命又遇到新问题，就是文章的修改时间问题，由于上面为了解决重定向的问题修改了所有文章的 Front Matter，这导致了所有文章都变成今天有更新了，囧。为了让那些老文章可以 RIP，我再吃点儿苦吧。查看 [Hugo 文档](https://gohugo.io/getting-started/configuration/#configure-front-matter)关于修改时间 `.Lastmod` 的定义，发现还是有救的。首先对于某篇文章的修改时间，Hugo 的默认定义是这样的

```toml
lastmod = [':git', 'lastmod', 'date', 'publishDate']
```

`:git` 代表从 git repo 里读取 Author Date，然后依次是 Front Matter 里的 `lastmod`，`date`，`pubDate`。我这里的主要问题是现存文章都在 git 里读取更新记录，解决它分为两步：

1. 用 git 把 HEAD 切到更改所有文章前，用 Hugo 的模板导出一份所有文章的文件名路径和修改时间，再把 git 切到最新的分支上，写个小脚本在所有文章的 Front Matter 里再加上刚刚导出的各自的 `lastmod`。
2. 调整 Hugo 定义 `.Lastmod` 的优先级，在 `config.toml` 里定义如下

```toml
[frontmatter]
  lastmod = ['lastmod', ':git', 'date', 'publishDate']
```

这样一来，Hugo 会先从页面的 `lastmod` 读修改时间，之后再读取 git 里的信息。这就保证老的文章不会都统统显示今天更新了。

## 最后

到此，一次较为完整的动手写 Hugo 主题活动差不多就告一段落了，管理项目的[笔记](https://yuanji-notes.notion.site/Hugo-Theme-a2d1b9a19e5644159d326147edcec470)在这里，虽然还有一些小问题，今后再更新吧。

20220520 更新：

本文所写的主题已由[后继版本]({{< relref "动手写一个Hugo博客主题（性能篇）" >}})取代，对本文描述的主题感兴趣的朋友可以点击下面链接查看截图存档。

- [桌面端](preview_web.png)
- [移动端](preview_mobile.png)
