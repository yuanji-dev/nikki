---
title: "Arch、Debian 包管理工具常用命令速查表"
createDate: 2025-01-04T11:24:47+09:00
publishDate: 2025-02-09T16:02:24+09:00
draft: false
tags: ["Debian", "Arch Linux", "apt", "pacman"]
keywords: ["Debian", "Arch Linux", "apt", "pacman"]
slug: "arch-debian-package-manager-commands-cheatsheet"
icon: 📦
---

最近渐渐给一些不太想频繁更新的设备安装上了 Debian 系统，简单了解了一些 Debian 的运维知识。

和其他发行版一样，日常最常用的命令果然还是软件包管理。一直以来不管是电脑还是服务器都使用 Arch Linux 的我多少有一些不太熟悉，于是准备借此机会做一个常用包管理命令的速查表，方笔查阅。

<!--more-->

## 安装软件包前

{{< notice tip >}}
可以使用网页搜索软件包信息，比如以搜索 `curl` 为例：

- [Arch Linux - Package Search -- curl](https://archlinux.org/packages/?sort=&q=curl&maintainer=&flagged=)
- [Debian -- Package Search Results -- curl](https://packages.debian.org/search?lang=en&searchon=names&keywords=curl)
  {{< /notice >}}

|                              | Arch                                               | Debian                                                     |
| ---------------------------- | -------------------------------------------------- | ---------------------------------------------------------- |
| 同步软件包仓库               | `pacman -Sy`                                       | `apt update`                                               |
| 同步软件包文件数据库         | `pacman -Fy`                                       | `apt-file update`                                          |
| 搜索软件包                   | `pacman -Ss <keyword>`                             | `apt search <keyword>`                                     |
| 搜索软件包（是否包含某文件） | `pacman -F <filename>` <br> `pacman -Fx <keyword>` | `apt-file search <keyword>`                                |
| 查看软件包信息               | `pacman -Si <package>`                             | `apt show -a <package>` <br> `apt-cache madison <package>` |

## 安装软件包

{{< notice info >}}
为了避免软件依赖产生的问题，建议在全量更新系统后安装新软件。
{{< /notice >}}

|                              | Arch                                     | Debian                                        |
| ---------------------------- | ---------------------------------------- | --------------------------------------------- |
| 更新系统（安装所有可用更新） | `pacman -Syu`                            | `apt upgrade`                                 |
| 安装软件包                   | `pacman -S <package>`                    | `apt install <package>`                       |
| 安装特定版本软件包           |                                          | `apt install <package>=<version>`             |
| 安装 backports 里的软件包    |                                          | `apt install -t <target>-backports <package>` |
| 安装本地软件包               | `pacman -U /path/to/package.pkg.tar.zst` | `apt install /path/to/package.deb`            |

## 安装软件包后

|                            | Arch                       | Debian                                       |
| -------------------------- | -------------------------- | -------------------------------------------- |
| 查看所有已安装软件包       | `pacman -Q`                | `apt list --installed`                       |
| 查看特定已安装软件包       | `pacman -Qi <package>`     | `dpkg -s <package>`                          |
| 查看已安装软件包提供的文件 | `pacman -Ql <package>`     | `dpkg -L <package>`                          |
| 查看哪个软件包提供特定文件 | `pacman -Qo /path/to/file` | `dpkg -S /path/to/file`                      |
| 查看可升级软件包           | `pacman -Qu`               | `apt list --upgradable`                      |
| 删除软件包及依赖           | `pacman -Rs <package>`     | `apt remove <package>` <br> `apt autoremove` |

## 参考链接

- [pacman/Rosetta - ArchWiki](https://wiki.archlinux.org/title/Pacman/Rosetta)
- [The Debian package management tools](https://www.debian.org/doc/manuals/debian-faq/pkgtools.html)
