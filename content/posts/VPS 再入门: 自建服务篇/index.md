---
title: "VPS 再入门: 自建服务篇"
date: 2019-10-22T12:19:43+09:00
lastmod: 2019-12-13T20:38:55+0900
tags: ["selfhosted", "VPS"]
isCJKLanguage: true
draft: false
slug: "selfhosted-services-on-vps"
aliases:
  - "/post/selfhosted-services-on-vps/"
---

在上次介绍了[使用 Ansible 搭建 VPS 基础环境]({{< relref "/VPS 再入门: Ansible 使用篇" >}})之后，这次想记录一下我在 VPS 都自建了哪些服务。

<!--more-->

## 环境介绍

这些服务目前基本都搭建在我的两台 VPS 上，一台是上次说的在 Oracle Cloud 上薅到的免费计算实例，运行 Ubuntu 18.04.3 LTS，另一台则是去年双十一在搬瓦工（Bandwagon）上购买的，年付 29.88 USD，通过 [vps2arch](https://gitlab.com/drizzt/vps2arch/) 运行 Arch Linux。基本软硬件信息通过运行 `curl -Lso- bench.sh | bash` 这个脚本列在下面。本文介绍的自建服务在这样的（性能不算太高的）环境下应该都能跑起来，毕竟用户可能常年只有我一个人。

<details>
<summary> VPS 配置详情 </summary>

```
# Oracle Cloud
----------------------------------------------------------------------
CPU model            : AMD EPYC 7551 32-Core Processor
Number of cores      : 2
CPU frequency        : 1996.249 MHz
Total size of Disk   : 94.3 GB (13.3 GB Used)
Total amount of Mem  : 982 MB (343 MB Used)
Total amount of Swap : 1023 MB (216 MB Used)
System uptime        : 5 days, 18 hour 59 min
Load average         : 0.07, 0.07, 0.08
OS                   : Ubuntu 18.04.3 LTS
Arch                 : x86_64 (64 Bit)
Kernel               : 4.15.0-1027-oracle
----------------------------------------------------------------------
I/O speed(1st run)   : 54.2 MB/s
I/O speed(2nd run)   : 50.9 MB/s
I/O speed(3rd run)   : 50.9 MB/s
Average I/O speed    : 52.0 MB/s
----------------------------------------------------------------------
Node Name                       IPv4 address            Download Speed
CacheFly                        205.234.175.175         5.62MB/s      
Linode, Tokyo2, JP              139.162.65.37           5.68MB/s      
Linode, Singapore, SG           139.162.23.4            3.61MB/s      
Linode, London, UK              176.58.107.39           5.12MB/s      
Linode, Frankfurt, DE           139.162.130.8           5.07MB/s      
Linode, Fremont, CA             50.116.14.9             4.87MB/s      
Softlayer, Dallas, TX           173.192.68.18           4.02MB/s      
Softlayer, Seattle, WA          67.228.112.250          5.02MB/s      
Softlayer, Frankfurt, DE        159.122.69.4            4.23MB/s      
Softlayer, Singapore, SG        119.81.28.170           5.23MB/s      
Softlayer, HongKong, CN         119.81.130.170          5.24MB/s      
----------------------------------------------------------------------
```

```
# Bandwagon Host
----------------------------------------------------------------------
CPU model            : QEMU Virtual CPU version (cpu64-rhel6)
Number of cores      : 2
CPU frequency        : 2599.998 MHz
Total size of Disk   : 42.3 GB (23.1 GB Used)
Total amount of Mem  : 2005 MB (231 MB Used)
Total amount of Swap : 511 MB (0 MB Used)
System uptime        : 12 days, 18 hour 3 min
Load average         : 0.06, 0.06, 0.02
OS                   : Arch Linux
Arch                 : x86_64 (64 Bit)
Kernel               : 5.3.6-arch1-1-ARCH
----------------------------------------------------------------------
I/O speed(1st run)   : 425 MB/s
I/O speed(2nd run)   : 384 MB/s
I/O speed(3rd run)   : 414 MB/s
Average I/O speed    : 407.7 MB/s
----------------------------------------------------------------------
Node Name                       IPv4 address            Download Speed
CacheFly                        205.234.175.175         82.8MB/s
Linode, Tokyo2, JP              139.162.65.37           9.73MB/s
Linode, Singapore, SG           139.162.23.4            1.47MB/s
Linode, London, UK              176.58.107.39           5.24MB/s
Linode, Frankfurt, DE           139.162.130.8           5.24MB/s
Linode, Fremont, CA             50.116.14.9             35.3MB/s
Softlayer, Dallas, TX           173.192.68.18           42.9MB/s
Softlayer, Seattle, WA          67.228.112.250          49.6MB/s
Softlayer, Frankfurt, DE        159.122.69.4            5.46MB/s
Softlayer, Singapore, SG        119.81.28.170           7.24MB/s
Softlayer, HongKong, CN         119.81.130.170          9.04MB/s
----------------------------------------------------------------------
```

</details>

## 为什么要自建服务

- 服务是自己写的
- 服务器闲着也是闲着
- 虽然有可以用的实例（通常是免费的）但是不提供任何保障
- 对付费服务的资费、功能不满意，但是有可以自建的替代品
- 当使用的付费服务出现故障，可以使用自建的服务作为过渡

## 选择自建服务的标准

可能各人有各人的想法，就我自己而言，大概有以下几个倾向：

- 功能尽量单一的服务
- 好部署、好维护、方便备份和迁移
- 还在继续更新、维护
- 有一定的用户群，社区活跃
- 和自己技术栈接近

## 自建的服务

### shirokumacafe

项目地址：https://github.com/masakichi/shirokumacafe

这个是我自己写的一个 Python 小程序，用 pipenv 管理依赖，用 systemd 的 timer 定时发送豆瓣广播。地址在 https://www.douban.com/people/shirokumacafe/statuses 这里。因为估计只有我自己部署使用，这里就不多介绍了。

### Anki Sync Server

项目地址：https://github.com/kuklinistvan/docker-anki-sync-server

Anki 就是那个大名鼎鼎的记忆软件，感觉提到背单词之类的事情就很难不提到它。但是它的同步服务器有时候不太稳定，也有可能是中国的网络的问题，以及这个同步服务自身对于访问频率有限制。于是我调查了一下同步服务也可以自己架设。客户端方面桌面端应该都是可以支持自建的服务器，Android 端的 AnkiDroid 自带这个功能，iOS 客户端的支持情况不太清楚。

在 GitHub 上有人做了一个 Docker 版大大简化了部署的难度。这个 anki-sync-server 还提供了一个简单的用户管理工具，我试着用 Ansible 包装了一下，可以实现一键增删用户。

<details>
<summary> 查看 Ansible Playbook </summary>

```yaml
---
- hosts: ubuntu
  become: true

  vars_files:
    - vars/anki.yml

  tasks:
    - name: Build anki-sync-server image
      docker_image:
        name: kuklinistvan/anki-sync-server:latest
        source: pull

    - name: Create anki-sync-server data directory
      file:
        path: "{{ anki_data_path }}"
        state: directory
        mode: 0700
        owner: root

    - name: Start anki-sync-server
      docker_container:
        name: anki-container
        image: kuklinistvan/anki-sync-server:latest
        state: started
        restart_policy: always
        volumes:
          - "{{ anki_data_path }}:/app/data"
        ports:
          - 127.0.0.1:27701:27701

    - name: List anki-sync-server users
      command: docker exec -it anki-container /app/anki-sync-server/ankisyncctl.py lsuser
      register: existing_anki_users
      changed_when: false
      tags: list_anki_users,add_anki_users,del_anki_users
    - debug:
        var: existing_anki_users.stdout
      tags: list_anki_users

    - name: Create anki-sync-server users
      expect:
        command: "docker exec -it anki-container /app/anki-sync-server/ankisyncctl.py adduser {{ item.user }}"
        responses:
          Enter password.*: "{{ item.password }}"
      with_items: "{{ anki_users }}"
      when: item.state != 'absent' and item.user not in existing_anki_users.stdout_lines
      tags: add_anki_users

    - name: Delete anki-sync-server users
      command: "docker exec -it anki-container /app/anki-sync-server/ankisyncctl.py deluser {{ item.user }}"
      with_items: "{{ anki_users }}"
      when: item.state == 'absent' and item.user in existing_anki_users.stdout_lines
      tags: del_anki_users
```

</details>

### Miniflux

项目地址：https://miniflux.app

这是一个非常简单的而且容易部署的 RSS 阅读器，本身提供简洁的 Web 界面，也可以通过自带的 Fever API 使用第三方的本地阅读器。架设这个服务的主要目标是取代之前一直使用的 Inoreader，Inoreader 其实我用着很舒服，每年交不到 20 刀去个广告，我也没用上多复杂的功能，就是看看新闻和标记感兴趣的文章。想到服务器闲着也是闲着，就调查了一番，结果是一般自建 RSS 阅读服务的方案分为两种，Tiny Tiny RSS 和其他，Tiny Tiny RSS 我感觉它提供的功能过于丰富，我也不太用得上，另一方面它部署起来也不太方便。于是其他方案里，Miniflux 目前呼声挺高，部署就是个 Go 语言编译而成的二进制文件，虽然本身提供的功能简单，核心功能也都有。与第三方服务（主要是 Read it later 服务）的连携也不错。实在要说有什么缺点，就是首页不能预览文章和**全文搜索不支持中文、日文等**

{{< figure src="miniflux.png" class="center" title="miniflux screenshot" >}}

### RSSHub

项目地址：https://docs.rsshub.app

随着调查 RSS 服务的深入，在 GitHub 上发现了这么个项目，这个服务实际上就是个输出 RSS 的定时爬虫程序，最大的特点是社区目前已经提供了不少 Recipe 可以直接使用，使得本身不提供 RSS 输出的网站或者服务可以通过 RSSHub 的路由来提供统一的 RSS 服务。虽然项目本身提供的 Demo 也可以使用，不过有一些针对爬虫策略比较严格的服务可能使用上不太稳定还是自己搭建比较方便。文档里提供了 docker-compose 的方案，同样可以一键启动服务。值得注意的是这个服务只提供了比较粗粒度的访问控制，为了防止其他人滥用又能让我自己查看它简单的统计功能，我在前面使用了 NGINX 反代，并且只让本机和我指定的一些 IP 访问。（主要是监控服务的 IP 地址和我使用的代理 IP）因为这个服务基本只是提供一个框架的功能，所以基本不需要考虑数据备份的问题，升级重启等也比较方便，另外可以订阅它自身提供的 RSS 来第一时间知道社区又贡献了哪些 RSS 源可以使用。要说缺点的话，有新的 Recipe 提供必须重新部署软件这一点不太灵活。（可能也是为了鼓励大家往社区共享 Recipe 吧）

### wallabag

项目地址：https://wallabag.org

这是一个稍后阅读和文章收集的服务，被当作 Pocket 或者 Instapaper 的开源实现。看着很实用，支持从好几个服务迁移数据，也支持从我上面自建的 Miniflux 里保存网页。看到官网推荐了一家欧洲的服务商托管这个服务，我就懒得自建服务了，每年的价格是 9 欧元，差不多是 70 人民币，比主流的 Pocket 和 Instapaper 便宜很多。定期做好备份就行了，如果那边服务出现什么状况自己启一个实例，导入备份的数据就行。界面大概长下面的样子：

{{< figure src="wallabag.png" class="center" title="wallabag screenshot" >}}

### File Browser

项目地址：https://filebrowser.xyz

一句话概括就是一个简易网盘。方便预览、上传、下载 VPS 上的文件，还有权限管理和分享的功能，并且支持多用户，方便给小伙伴使用。截图在 https://filebrowser.xyz/features 这里可以看到，我就不贴图了。

### Transmission

项目地址：https://transmissionbt.com

带有 Web 界面的 BT 下载程序。我主要用它来下载一些我本地主机不太方便下载的文件，然后使用上面提到的 File Browser 来预览下载，或者分享给其他人。同样地，最简单的部署方法还是使用 docker，我使用的是 https://hub.docker.com/r/linuxserver/transmission/ 这里的镜像。

## 小贴士

- 在选定了要搭建的服务同时，最好订阅一下这个软件/服务的 Release Notes，或者如果有镜像上传在 Docker Hub 上，可以想办法订阅一下镜像更新的情况，比如使用 https://docs.rsshub.app/program-update.html#docker-hub ，这样在软件有更新的时候，方便第一时间跟上，避免跨好几个版本升级的麻烦
- 遇到问题搜索一下 GitHub Issues，比如 Miniflux 不支持中文全文搜索的问题是因为 PostgreSQL 不支持，然后 https://github.com/miniflux/miniflux/pull/323 这里提到可以使用 zhparser 扩展解决。（虽然我并没有去折腾）
- 在部署之前最好先预览一下功能，判断一下是否满足自己的要求，比如 https://yunohost.org/#/try 这个网站提供很多自建服务的体验。
- 另外在下面这些网站上罗列了很多可以自建服务的项目，感兴趣的朋友可以自己研究一下。
  - https://selfhosted.libhunt.com/ （有基本的比较功能，虽然好像并没有什么用）
  - https://github.com/awesome-selfhosted/awesome-selfhosted
  - https://selfhostedsource.tech/self-hosted

## 其他

还有几个服务看着还不错，不过目前还没有使用的。

- [ptpb/pb: pb is a lightweight pastebin and url shortener built using flask.](https://github.com/ptpb/pb)
- [seejohnrun/haste-server: open source pastebin written in node.js](https://github.com/seejohnrun/haste-server)
- [BookStackApp/BookStack: A platform to create documentation/wiki content built with PHP & Laravel](https://github.com/BookStackApp/BookStack)
