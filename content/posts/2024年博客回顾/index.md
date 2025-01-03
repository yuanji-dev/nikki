---
title: "2024 年博客回顾"
createDate: 2025-01-03T12:31:42+09:00
publishDate: 2025-01-03T15:40:41+09:00
draft: false
tags: ["博客"]
keywords: ["博客"]
slug: "2024-recap"
icon: 📝
---

去年写了一篇 {{< relanchor "2023年博客回顾" >}}，没想到时间过得飞快，又一年过去了。为了延续去年的传统，也写一篇 2024 年博客回顾好了。

![2023、2024 年访问统计对比](umami-2024-vs-2023-screenshot.png)

<!--more-->

## 被阅读最多的文章

按照惯例，我下载了 Umami 上统计的信息，使用去年写的 Hugo 的 shortcode 渲染出 2024 年博客文章访问前 10 名大概是这样：

{{< json2table file="data/url_ranking.json" caption="2024 年博客文章访问排行" headers="No.|文章|发布日期|访客|浏览量" columns="url|createDate|visitors|views" pageLink="url" >}}

今年给那个 shortcode 加了个新功能，可以显示文章的发布日期，可以看到 2024 年写的文章里共有 3 篇文章上榜。

{{< details "点击查看博客 2024 年其他统计数据" >}}
{{< json2table file="data/referrer_ranking.json" caption="2024 年访问者来源排行" headers="No.|Referrer|访客|浏览量" columns="referrer|visitors|views" >}}
<br>
{{< json2table file="data/os_ranking.json" caption="2024 年访问者操作系统排行" headers="No.|操作系统|访客|浏览量" columns="os|visitors|views" >}}
<br>
{{< json2table file="data/location_ranking.json" caption="2024 年访问者地区排行" headers="No.|地区|访客|浏览量" columns="country|visitors|views" >}}
{{< /details >}}

## 回顾和展望

回顾去年一年写的博客，感觉最大的变化是换上了新的域名 blog.yuanji.dev，一个原因是为了和博客的标题保持统一，另外也是因为夏天的时候[做了一个新的网站]({{< relref "介绍我最近做的新网站「日语迷.com」" >}})，想着在日本的生活渐渐稳定下来，准备在那个网站专门用来分享一些日语学习、日本生活的文章。（虽然目前也停更几个月了 😂）

至于 2025 年，这个博客就主要分享一些技术相关的记录和一些随笔吧！
