---
title: "使用 WireGuard 搭建私有网络"
date: 2021-01-31T21:03:20+09:00
lastmod: 2021-05-13T21:23:46+0900
tags: ["VPS"]
isCJKLanguage: true
draft: false
slug: "setup-wireguard-vpn"
aliases:
  - "/post/setup-wireguard-vpn/"
---

## 起因

在上篇日记中讲到了[自建 vaultwarden]({{< relref "自建vaultwarden" >}}) 密码管理软件的经过，虽然过程一帆风顺不过还是不太希望这个服务在公网上被访问到，毕竟实际上只有我一个人在使用，我得选一种方法让别人没法访问。方法其实有不少，比如配置 NGINX 让它只能接受指定 IP 地址的访问，不过不管家里也好，移动设备也好都没有固定 IP，如果要用这个方法的话，我首先得搭建一个代理服务器拿到一个固定的 IP 地址才行，与其如此我不如搭建一个私有网络，把我用到的几个设备连接到这一个虚拟网络中，这样不仅可以实现只让我访问服务的目标，还能带来其他一些好处，比如哪天开始需要去公司上班了，我可以连回家里的设备。

于是想到了早就听说却一直没有用过的 WireGuard。

<!--more-->

## WireGuard

如果用谷歌搜索 WireGuard，结果里官网的标题应该很好地形容这个软件 [WireGuard: fast, modern, secure VPN tunnel](https://www.wireguard.com/) ，基本上它分为两部分，一个内核模块和一个用户空间工具，因为我的 VPS 和我的电脑都是使用的 Arch 的 [linux](https://archlinux.org/packages/core/x86_64/linux/) 内核，它已经自带了编译好的 WireGuard 内核模块， 所以只需要安装一个 [wireguard-tools](https://archlinux.org/packages/extra/x86_64/wireguard-tools/) 工具即可使用。如果内核版本低于 5.6 需要额外安装对应的内核模块包(其他发行版或者其他内核用户需要各自对应)。另外按照 Arch Wiki 上的介绍，systemd-networkd 和 NetworkManager 自带了对 WireGuard 的支持，应该不安装 wireguard-tools 也能使用。

### 配置

实际上 WireGuard 里并没有 server，client 之类的概念区分，所有的节点都叫做 peer，每个设备在联入之前都需要生成一个私钥（公钥可以通过私钥导出），而 VPN Server 实际上算是一种特例，Arch 的 Wiki 里直接给出了这种配置方案的示例，基本稍作修改就能使用。就我而言，我是想让之前搭建的 bitwarden_rs 服务在内网中使用，我就把那台 VPS 作为 "server" 的角色来使用了。

每个设备生成私钥、公钥的方式都一样，通过下面的方式可以一次生成。

```bash
wg genkey | tee peer_A.key | wg pubkey > peer_A.pub
```

因为我使用的是 wireguard-tools 里的工具进行配置的，所以接下来就是创建配置文件，在我那台 VPS 里的配置大概如下，其实就是 “Server” 在 Interface 里指定好对应的网段，和自己的私钥即可，Peer 里则通过其他 "Client" 设备的公钥来确定身份，我在这里配置了三台设备分别是我的手机和两台电脑，其中的 AllowedIPs 指的是 “Server” 可以路由到 "Client" 的哪些 IP 段（会因此创建不同的路由表），这里我们近需要这台 Server 能访问其他设备本身即可。

```ini
❯ sudo cat /etc/wireguard/wg0.conf                      
[Interface]
ListenPort = 51820
PrivateKey = “Server” 的私钥
Address = 192.168.77.1/24

[Peer]
# Redmi K30
PublicKey = 手机的公钥
AllowedIPs = 192.168.77.51/32

[Peer]
# XPS 9370
PublicKey = 笔记本的公钥
AllowedIPs = 192.168.77.52/32

[Peer]
# ArchLinux Desktop
PublicKey = 台式机的公钥
AllowedIPs = 192.168.77.53/32
```

而对应的我的一台电脑的配置则如下，其中加入了 `Endpoint` 和 `PersistentKeepalive` 这两个配置，因为我的笔记本并没有单独的外网 IP，所以这里需要指定“Server”的地址和端口，并保持心跳。

```ini
[Interface]
PrivateKey = 笔记本的私钥
Address = 192.168.77.52/32

[Peer]
PublicKey = “Server” 的公钥
AllowedIPs = 192.168.77.1/32
Endpoint = tokyo-1.gimo.me:51820
PersistentKeepalive = 25
```

### 启动服务

假设配置文件在 `/etc/wireguard/wg0.conf` 的话，通过下面的命令即可

```bash
sudo wg-quick up wg0
```

如果需要开机自启，则可以

```bash
sudo systemctl enable wg-quick@wg0
```

### 查看状态

```bash
sudo wg # 相当于 sudo wg show
```

可以查看各个节点的配置和最后握手时间以及传输流量。

## 其他配置

### NGINX

为了不让 NGINX 不在公网上被访问，直接修改配置文件将监听地址绑定到 wg0 的网段上，像是下面那样

```nginx
listen 192.168.77.1:80;
listen 192.168.77.1:443 ssl http2;
```

### VPS 出入站规则

关闭之前开放的 80、443 端口，仅仅保留 ssh、mosh、和 WireGuard 的 51820 端口。

## OpenWrt

到此基本就实现我的目的了，如果手机上需要访问这个服务直接打开 WireGuard 的 VPN 即可，不过考虑到因为 WFH 其实出门的机会也并不大，在家里我希望不连 VPN 就能访问，于是想在家里的路由器也用上 WireGuard，这里多亏了老婆把我的 NanoPi R2S 给带来了日本，我刷入了[官网最新的 ROM](http://wiki.friendlyarm.com/wiki/index.php/NanoPi_R2S#Install_OS) 之后（也是巧了，它正好在半个月前更新了内核到 5.10）查看了一下，它自带了 wireguard 内核模块，一阵窃喜。

```bash
root@FriendlyWrt:~# modinfo wireguard
module:         /lib/modules/5.10.2/wireguard.ko
alias:          net-pf-16-proto-16-family-wireguard
alias:          rtnl-link-wireguard
version:        1.0.0
author:         Jason A. Donenfeld <Jason@zx2c4.com>
description:    WireGuard secure network tunnel
license:        GPL v2
srcversion:     F50E590B3528AEDDC1F8C5D
depends:        libcurve25519-generic,libblake2s,udp_tunnel,libchacha20poly1305,ip6_udp_tunnel
intree:         Y
name:           wireguard
vermagic:       5.10.2 SMP preempt mod_unload modversions aarch64
```

不过没有自动装载这个模块，直接 `modprobe wireguard`，然后创建 `/etc/modules.d/wireguard ` 让它自动装载。

```bash
root@FriendlyWrt:~# cat /etc/modules.d/wireguard 
wireguard
```

然后打开 [OpenWrt 的 WireGuard 文档](https://openwrt.org/docs/guide-user/services/vpn/wireguard/start)，显示安装两个包即可  [luci-proto-wireguard](https://openwrt.org/packages/pkgdata/luci-proto-wireguard) 和 [luci-app-wireguard](https://openwrt.org/packages/pkgdata/luci-app-wireguard)，第一个是用于创建接口时可以选择 WireGuard 协议，第二个提供一个图形界面查看状态。然而我实际安装的时候失败了，报错找不到依赖 `kmod-wireguard`，我当然不理它，毕竟我已经知道 friendlywrt 提供的内核自带了 wireguard 内核模块，直接大胆地

```bash
opkg update
opkg install luci-proto-wireguard luci-app-wireguard --force-depends
```

接下来就是用 luci 的图形界面创建一个 `WireGuard VPN` 协议的接口 wg0，配置和之前的其他手机、电脑的配置相似，然后把公钥加到”Server“的配置里。不过因为内网的其他设备需要通过这台路由器的 wg0 接口访问“Server”（这样在家里的其他设备就不用连 VPN 访问自建的 bitwarden_rs 啦）还需要配置下路由器的防火墙，主要是加一条

```
iptables -t nat -A POSTROUTING -o wg0 -j MASQUERADE
```

## 最后

现在只要连上家里的 Wi-Fi 就可以访问我自建的 bitwarden_rs 服务了，如果偶尔外出需要使用再单独连接 VPN 即可。不过我仔细想一想我的路由器似乎性能挺过剩的，完全可以把它作为”Server“，似乎 bitwarden_rs 也有 aarch64 架构的镜像，部署在路由器上想必也不是什么难事，如果这么做的话改动一下相应的 WireGuard 配置应该也不太难。

## LT;DR

```bash
我：（发了一个链接给妻子）你看看我刚给你发了个链接，你是不是打不开？但是我能打开，因为我手机上连了 VPN。
妻：哦

（数日后）

我：你看看之前给你发的那个链接是不是能打开了？
妻：嗯
我：你把 Wi-Fi 断了，用流量再打开试试，是不是就打不开了？
妻：嗯
```

## 问题
本人在使用一段时间后发现，网络出现一些奇怪的问题，比如提交 HTML 表单的时候和服务器之间的通讯会中断，通过一番调查一般是因为默认的 MTU 值（1420）过大造成的，至于合适的 MTU 值取决于各自的网络状况，一般来说遇到这个问题把 MTU 调小即可，比如我把路由器上 wg0 的 MTU 调整成 1280 就一切顺利了。
