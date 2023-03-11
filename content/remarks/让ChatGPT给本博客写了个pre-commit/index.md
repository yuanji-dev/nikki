---
title: "让 ChatGPT 给本博客写了个 pre-commit"
date: 2023-03-11T17:53:15+09:00
draft: false
toc: false
tags: ["博客", "ChatGPT"]
keywords: ["博客", "ChatGPT", "exiv2"]
icon: 🤖
---

前段时间因为一直在忙日语课的作业等，周末也没啥时间出去玩，博客更新也变慢了。最近终于稍微有所缓和（只要这个月再上两节课就结束了），于是和妻子去了趟上野。回到家准备写篇日记，发点儿照片。

想到既然要发照片到网上的话，最好把照片里的 Exif 信息去掉，于是和原来一样准备用 `exiv2` 这个命令行软件。又转念一想，为了确保万无一失，可以写一个 git 的 `pre-commit` 让我禁止提交带 Exif 的照片。

<!--more-->

起了这个念头，我又不想自己写，于是就想到了我的老朋友 ChatGPT，平时主要让他写作文，这次让他写个代码看看。结果不仅顺利完成任务，还让我在这个过程中感到了一些不可思议。

## 第一回合

于是我马上问道：

> create a git pre-commit hook that prevents committing image files with exif

他不仅马上给出了代码，还给了注释和代码解释，这里考虑到篇幅只贴代码。

```bash
#!/bin/bash

# Define the file types to check for EXIF data
IMAGE_TYPES=(jpg jpeg png gif)

# Loop through all staged files
for file in $(git diff --cached --name-only --diff-filter=ACM | grep -iE "\.(${IMAGE_TYPES[*]})$"); do

  # Check if the file has EXIF data
  if exiftool "$file" | grep -q "EXIF"; then
    echo "ERROR: $file contains EXIF data. Remove EXIF data before committing."
    exit 1
  fi

done

# If no errors were found, allow the commit to proceed
exit 0
```

## 第二回合

看了眼代码似乎问题不大，不过我不用 `exiftool` 而用 `exiv2`，继续：

> can you use exiv2 instead of using exiftool

他继续秒回，改了其中一行如下：

```diff
-if exiftool "$file" | grep -q "EXIF"; then
+if exiv2 "$file" 2>/dev/null | grep -q "Exif"; then
```

## 第三回合

我看这代码似乎差不多了，于是拿去跑了一下，发现并不如预期，于是我开始研究他的代码，最后定位到他的正则表达式写的有问题，具体来说就是这句，`\.(${IMAGE_TYPES[*]})$`，`IMAGE_TYPES` 是一个数组于是这个代码展开后的表达式变成了 `\.(jpg jpeg png gif)$` 很显然这个匹配不对，扩展名之间不应该是空格 ` `，而应该用 `|`。

## 第四回合

照道理我已经知道了问题自己改下就行，不过出于好奇我还是问了 ChatGPT：

> grep -iE "\.(${IMAGE_TYPES[*]})$") seems doesn't work

然后他马上向我道歉说代码确实有问题，还解释了和我的发现一样的问题，应该用 `|` 而非空格，并给出了示例代码如下：

```diff
-grep -iE "\.(${IMAGE_TYPES[*]})$"
+grep -iE "\.($(echo "${IMAGE_TYPES[@]}" | tr ' ' '|'))$"
```

## 第五回合

我换上之后确实就能用了，不过嫌这代码有点儿丑陋，于是继续：

> is it possible to make it more readable?

于是他马上单独抽出一个变量来生成正则：

```bash
# Build the regular expression for matching file extensions
EXT_REGEX=""
for ext in "${IMAGE_TYPES[@]}"; do
  EXT_REGEX+="|$ext"
done
EXT_REGEX=${EXT_REGEX#|}  # remove the leading '|'
```

## 第六回合

虽然好多了，我又感觉太啰嗦，于是：

> any other way to simplify it?

他给出了如下代码：

```bash
# Build the regular expression for matching file extensions
IFS="|"
EXT_REGEX="${IMAGE_TYPES[*]}"
IFS=""
```

## 最后

后来我又问了几次，他又给了几种方案，比如用 `printf` 处理字符串等等。不过，我觉得这个用 `IFS` 方法看着顺眼，就采用了这一方案。代码成品可见：[masakichi/nikki@c970d57](https://github.com/masakichi/nikki/commit/c970d57c7b7138d61f500004ef28ad2cc16026e0)
