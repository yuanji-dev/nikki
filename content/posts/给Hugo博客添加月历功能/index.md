---
title: "给 Hugo 博客添加月历功能"
createDate: 2023-12-20T22:25:32+09:00
publishDate: 2023-12-23T12:36:07+09:00
draft: false
tags: ["Hugo", "博客"]
keywords: ["Hugo", "博客"]
slug: "adding-calendar-view-for-hugo-blog-posts"
icon: 📅
---

虽然日本似乎有忙碌的十二月（忙しい師走）的说法，但作为外国人的我反而感觉比较闲。月初的时候翻新了下博客主题，一发不可收拾，又花了点时间给博客整了点新活儿——添加了[月历页面]({{< relref "calendar" >}})。

最早的契机来自身边的书店、超市等，推出了很多月历相关的商品。无意识地感觉到月历这个东西一下子存在感高了起来。另外，可能国内没有这样的习俗，似乎日本在进入 12 月之后，会有一个叫做 [Advent Calendar](https://ja.wikipedia.org/wiki/アドベントカレンダー#企画としてのアドベントカレンダー) 的企划活动，尤其在网络上的技术社区。大体上，这个活动从 12 月的第一天开始，直到圣诞节结束，参加活动的每个人分别负责其中一天，写一篇与某个特定主题相关的文章，比如下面这些：

- [Obsidian Advent Calendar 2023 - Adventar](https://adventar.org/calendars/8783)
- [語学・言語学・言語創作 Advent Calendar 2023 - Adventar](https://adventar.org/calendars/8540)

于是我就想，何不给我自己的博客也加上个月历呢，一方面可以观察一下我过去都在什么时候写博客，另一方面也许有了这么个月历，可以更好地激励我写更多的博客文章呢？

<!--more-->

## 使用 FullCalendar

就像去实体店里买月历一样，要给博客做一个月历功能，我首先想到的去挑选一个现成的。虽然似乎没有看到哪个 Hugo 主题标榜自己有这么个月历功能，不过果然我也不是第一个有这个想法的人，网上已经有一些[类似功能的讨论](https://discourse.gohugo.io/t/calendar-view/5186)，通过一番研究比较，我选择了一个基于 JavaScript 的日历库 [FullCalendar](https://fullcalendar.io/)。

虽然这个库提供各种各样丰富的功能，实际上我需要的仅仅是展示一个基本月历而已。所以使用起来并不是太复杂，基本上直接复制下方的官网示例代码，原型就差不多了。

```html {hl_lines=[11]}
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.10/index.global.min.js"></script>
    <script>
      document.addEventListener("DOMContentLoaded", function () {
        var calendarEl = document.getElementById("calendar");
        var calendar = new FullCalendar.Calendar(calendarEl, {
          initialView: "dayGridMonth",
          events: [],
        });
        calendar.render();
      });
    </script>
  </head>
  <body>
    <div id="calendar"></div>
  </body>
</html>
```

然后只要想办法往上面示例代码中高亮的 `events` 里填入实际的数据即可，在我的博客里自然就是博客文章了。

## Hugo 布局文件

有了上面使用 FullCalendar 的代码原型后，紧接着产生两个疑问：

1. 这个显示月历的代码应该放在哪？
2. 应该怎样使用（调用）这个月历？

因为我之前以前已经有较为丰富的 [Hugo 主题开发经验]({{< relref "/tags/hugo" >}})，要回答这两个问题并非什么难事。

1. 在 Hugo 博客的目录下创建一个布局文件 `layouts/_default/calendar.html`
2. 在 Hugo 博客的内容目录下随便创建一个 `.md` 文件，只需要在 front matter 里加入 `layout: calendar` 即可。比如我想在 `/calendar` 访问月历，就创建一个 `content/calendar/_index.md` 这样的文件就可以了。

## Hugo 提供 FullCalendar 可用的 events

通过上面两步的分析，大体上解决思路都已经确定，接下来就是按部就班让 Hugo 生成一个 JavaScript 对象 `events` 使得 FullCalendar 可以读取即可。整个 `events` 是一个数组，数组中的元素 [Event Object](https://fullcalendar.io/docs/event-object) 可以点击查看官网的文档。

虽然 `event` 支持很多很多属性可以定制，但对于我的博客来说很简单，我希望在月历上显示两种文章：

1. 已发布的文章
2. 未来将要发布，目前还是草稿的文章。（也就是我希望督促自己挖的坑啦）

它们俩在 FullCalendar 层面的区别，仅仅是颜色不一样，以及未发布的文章没有链接不能点击而已。在 Hugo 里虽然这个代码谈不上多好看，但是也够直白。下面这几行就得到了包含所有上面两类文章的 `$events` 了 ，之后把它们放到 JavaScript 代码里即可。

```go-html-template
{{- $events := slice }}
{{- $posts := where .Site.RegularPages "Draft" "eq" false }}
{{- $drafts := where .Site.RegularPages "Draft" "eq" true }}
{{- range $posts }}
  {{- $events = $events | append (dict "title" .Title "start" (time.Format "2006-01-02" .Date) "url" .RelPermalink "allDay" true ) }}
{{- end -}}
{{- range $drafts }}
  {{- $events = $events | append (dict "title" .Title "start" (time.Format "2006-01-02" .Date) "allDay" true "color" "var(--text-muted)" ) }}
{{- end -}}
```

## 注意点

虽然整体上，这个功能并不复杂，但是一些小细节却占用了我不少时间，回想起来大概有下面这几点。

1. Hugo 默认会忽略任何草稿文件，所以不改一下默认设置的话，上面的 `$drafts` 将永远是空值。最简单的方法就是在配置文件里加上：`buildDrafts = true` 以及 `buildFuture = true`
2. 但是经过上面这么一设置，首页，归档页和 RSS 输出都自动出现了草稿，这是我不希望看到的结果，于是分别修改相应的模板文件。
3. 另外一个小问题是 FullCalendar 默认的点击行为是直接在当前页打开链接，我希望改成在新标签中打开。
4. 因为网络上删库跑路的事情太多了，虽然像这样知名的库不太至于，我还是保险起见将 FullCalendar 里需要的 JS 文件下载到了本博客自己的仓库里。
5. 此外就是一些关于月历显示大小，周末颜色区别，以及多语言之类的微调了。

代码在此就不一一解释了，总之整个月历功能的实现，我都包含在下面两个 commit 里了，有需要可以自行查看。

- [feat(theme): add calendar page for posts · masakichi/nikki@cc5f4cc](https://github.com/masakichi/nikki/commit/cc5f4cc952a590872bb881528e7122ab921dce7c)
- [feat: hide draft page in all list pages · masakichi/futu@3499b50](https://github.com/masakichi/futu/commit/3499b50742ef4e0ebc376e12d6f7331761a74d8f)

## 总结

在做完这个小功能之后，我马上新建了包括本文在内的 4 篇草稿，使用自己做的功能的感觉很不错。希望我能让它们准时发布，我甚至开始乐观地估计，基于今年 15 篇博客的数量，明年倍增达到 30 篇也不是难事？
