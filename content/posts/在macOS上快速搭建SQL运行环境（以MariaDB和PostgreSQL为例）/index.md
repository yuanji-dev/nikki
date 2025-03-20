---
title: "在 macOS 上快速搭建 SQL 运行环境（以 MariaDB 和 PostgreSQL 为例）"
createDate: 2025-03-19T23:11:15+09:00
publishDate: 2025-03-20T14:25:37+09:00
draft: false
tags: ["macOS", "MariaDB", "PostgreSQL"]
keywords: ["macOS", "MariaDB", "PostgreSQL"]
slug: "mariadb-and-postgresql-on-macos"
icon: 🐘
---

最近因为妻子工作需要用到 SQL 分析数据，比起直接在线上执行语句，想着要是能在本地有个沙盒环境实际运行一下 SQL 调试调试那就太好了。于是对于这个课题进行了一些调查，总结了分别基于 MariaDB（MySQL） 和 PostgreSQL 的两套方案，供有类似需求的朋友参考。

{{< notice tip >}}
通过我和妻子的测试，我们一致认为 Postgres.app + Postico 2 这套基于 PostgreSQL 的方案更简单，操作也更符合直觉。
如果你没有特别对于 MariaDB（MySQL）环境的要求，那么推荐使用这一套方案。
{{< /notice >}}

<!--more-->

## MariaDB + Sequel Ace

### 安装和运行 MariaDB

{{< notice info >}}
这里我们使用 [Homebrew](https://brew.sh/) 安装和实现开机自动启动 MariaDB 的服务。在运行以下命令前请确保 Homebrew 已经成功安装。
{{< /notice >}}

```bash
brew install mariadb
brew services start mariadb
```

基本上这样一来就可以使用 `mysql` 命令操作数据库了，只是如果要配合接下来谈到的 Sequel Ace 这个 GUI 客户端使用还要给 root 账号配置一个新密码才行。

{{< notice warning >}}
本文只是为了在本地练习、调试。所以直接使用 root 账号和弱密码，请勿用于生产环境。
{{< /notice >}}

在终端输入 `mysql` 后，运行 `ALTER USER 'root'@'localhost' IDENTIFIED BY 'toor';`（按下回车键） 就会给 root 账号设置一个新密码：`toor`

```
$ mysql
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 26
Server version: 11.7.2-MariaDB Homebrew

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> ALTER USER 'root'@'localhost' IDENTIFIED BY 'toor';
Query OK, 0 rows affected (0.007 sec)
```

大体上出现上面的结果，配置就完成了，退出终端即可。

### 安装和使用 Sequel Ace

为了让执行 SQL 的环境更易用，这里我们选择了图形化软件 [Sequel Ace](https://sequel-ace.com/) 作为客户端。既然上面已经用 Homebrew 安装服务端了，我们同样可以使用 brew 命令安装这个客户端软件。

```bash
brew install sequel-ace
```

安装完了之后，打开软件，填入以下信息再点击 Connect 即可。（为了下次连接数据库方便，可以点击 Add to Favorites 保存连接信息）

```
Name: MariaDB (任意名称)
Host: 127.0.0.1
Username: root
Password: toor
```

## Postgres.app + Postico 2

比起上面的 MariaDB 的方案，这套基于 PostgreSQL 的方案就显得更人性化了。全程甚至可以不需要在终端中执行任何命令。

### 安装和使用 Postgres.app

1. 安装方法和安装普通 macOS 上的软件并没有任何差异，前往 [Postgres.app](https://postgresapp.com/downloads.html) 下载最新的安装包。打开后把软件移动到 `Applications` 文件夹就完成安装了。
2. 打开刚刚安装的 Postgres.app，点击 Initialize 按钮创建一个新的服务即可。（至此数据库的安装结束）
3. （可选）如果你需要在命令行里操作数据库，那么可以执行 `sudo mkdir -p /etc/paths.d &&
echo /Applications/Postgres.app/Contents/Versions/latest/bin | sudo tee /etc/paths.d/postgresapp` 如果你不知道这有什么用，那不执行也罢。

如果你按照上面步骤执行后，你应该会注意到系统的状态栏上有一个大象的图标，此时数据库就在后台默默运行了，关掉窗口也没有关系。

### 安装和使用 Postico 2

同样为了执行 SQL 更容易，我们选择了一款叫做 [Postico 2](https://eggerapps.at/postico2/) 的客户端软件。由于和上文提到的 Postgres.app 是同一个人维护的，所以基本上安装好之后就可以无缝连接使用。

安装方法和上面提到的类似，就跟安装普通软件一样，下载安装包之后打开拖动到 `Applications` 文件夹即可，这里不再冗述。打开软件后基本上什么配置都不用填，直接点击连接按钮就能连上之前创建的本地数据库了。

不过这里值得一提的是 Postico 2 的一些功能（似乎像是打开多个标签或是窗口）需要付费，不过使用下来大部分功能似乎都是免费的，体验上也更符合 macOS 用户的直觉，如果想要这些像是多窗口的功能也不差钱的话支持一下作者挺好。如果只是单纯想熟悉一下 SQL 那我感觉免费的功能也够用了。

## 总结

正如开头所讲，如果没有非要使用 MariaDB（MySQL）的要求，使用 Postgres.app + Postico 2 更简单方便。不过 Sequel Ace 胜在是开源软件而且功能全免费也是不错的选择。当然了其实也没必要非要选哪一个，现在电脑性能这么强，我们就把两套都给安装上了，以备哪天说不定它们其中一个就不好使了，也好有个备选方案。
