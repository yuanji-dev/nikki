---
title: "给 ThinkBook 更新 BIOS"
date: 2023-09-02T13:17:44+09:00
draft: false
tags: ["thinkbook", "ventoy"]
keywords: ["thinkbook", "bios", "vhd", "ventoy"]
slug: "using-ventoy-to-upgrade-bios-for-thinkbook"
icon: 💻
---

本文其实主要就是通过虚拟机软件（VirtualBox）把 Windows 11 安装到 VHD 文件，最后可以通过 [Ventoy](https://www.ventoy.net/en/index.html) 引导 VHD 文件实现把 Windows 装到优盘，最终执行 Windows 专用的 BIOS 更新程序。不关心本文背景的读者可以直接跳到之后的步骤。

<!--more-->

## 背景

最近入手 ThinkBook 14 G5+ ARP 后一有时间我就删掉了自带的 Windows 11，安装上了 Arch Linux。不知道是 [archinstall](https://github.com/archlinux/archinstall) 比较智能还是这个型号目前已经被支持的不错了，安装完之后，没有需要特意安装无线网卡的驱动，也没有出现显示、或者键盘失灵的问题，可以说是开箱即用了。看起来网上有一些情报似乎已经过期了。

不过用了几个星期之后，还是遇到一些问题。比如说蓝牙耳机似乎有些杂音，不过我大部分时间都是在家使用，倒也不必特别使用耳机。另一个比较恼人的问题是，有时候用着用着就自动重启了，用 `journalctl -b -1` 也没看出什么端倪。因为这个型号的 CPU（Ryzen 7 7735H) 和 6800H 据说就是换了个名字，在网上搜了下 6800H 的情报会比较多，似乎也有人有类似的报告，不过解决的方法似乎又各有不同。另外，我在 [Ryzen - ArchWiki](https://wiki.archlinux.org/title/Ryzen#Random_reboots) 这里了解到 Ryzen 处理器似乎确实有类似的问题，不过文中所提及的是桌面处理器。

由于不清楚到底是什么问题，在 Arch 的系统里没有什么线索的话，就进入 BIOS 看了看。说实话这个 ThinkBook 的 BIOS 虽然看着很高级，但是其实并没有几个选项。看来看去，感觉和设置中的系统性能模式有关，默认是智能模式，其他还有节能模式和野兽（性能）模式。于是就把它改成了野兽模式，不知道是不是瞎猫碰到死耗子，之后一段时间就没遇到随机重启的问题。既然进了 BIOS 就顺便查了下版本，发现官网已经有一个新版本的 BIOS 可以升级。一般来说系统没啥问题的话我是不太喜欢更新的，不过既然遇到了这个谜之问题，就试试吧。

## 升级 BIOS 的几种方法

假定你和我一样，硬盘上只安装了 Linux，那么升级 BIOS 可能会不太容易。不算麻烦的方法大概有下面三种。

1. 如果制造商对 [LVFS](https://fwupd.org/) 有支持，通过 fwupd 这个工具，可以在 Linux 系统里直接更新 BIOS。像是 Dell 的 XPS 和联想的 ThinkPad 系列很多是支持的。比如我之前用的 XPS 9370 就可以在 [LVFS: XPS 13 9370](https://fwupd.org/lvfs/devices/com.dell.uefi7ceaf7a8.firmware) 支持列表里查询到。（突然有点怀念它）
2. 如果制造商没有提供对 LVFS 的支持，但是提供了 ISO 文件，用户可以做成启动盘更新，这种和系统无关的更新方式对于 Linux 用户也比较方便。
3. 如果主板支持读取优盘里的 BIOS 更新文件，也可以方便更新，比如我的台式机的华硕主板支持这么更新。

<mark>如果很不幸，以上三种都行不通。就像目前 ThinkBook 的处境，官方只放出了一个用于 Windows 11 的可执行文件（.exe）就有点伤脑筋了。</mark>

对此，我查了下资料（其实想也能想的出来）排除掉一些不合适或者风险大的，就这个 ThinkBook 而言大概剩下两条路。

1. 老老实实想办法装个 Windows 应急。
2. 想办法抽出 `.exe` 文件里实际上用于升级 BIOS 的文件本体，想办法执行它。

本来我是想实施方法 2 的，Arch 的 Wiki 上找到一个一般的做法，但是似乎没找到同型号这种做法的具体案例。有想尝试的朋友可以移步 [Laptop/Lenovo - ArchWiki](https://wiki.archlinux.org/title/Laptop/Lenovo#BIOS/Firmware_update)，不过后果自负。我自己本着两害相权取其轻的策略，还是老老实实安装 Windows 算了。虽说我这电脑有两个硬盘位，但是我又不想专门买块硬盘装 Windows，而且看起来这个电脑不是很好拆的样子，自然而然我想到是不是可以安装到优盘（实际上也是个 SSD）里。但是我这个优盘已经装了 Ventoy 里面还有好几个其他系统的安装盘，我又不想全部格式化就为了安装一个 Windows。于是抱着试试看的态度，搜了下能不能在保留 Ventoy 的基础上，还能把 Windows 安装到同一个优盘上。

最后还真找到了一个办法，经过尝试确实成功地安装了 Windows 11，最后也顺利升级了 BIOS。

介绍了这么多背景，本文主要讲的就是让 Ventoy 引导 VHD 文件，而 Windows 呢，就安装到那个 VHD 文件里。接下来就简要介绍一下这个过程。

## 制作 VHD 并安装 Windows 11

VHD 就是虚拟硬盘的意思，可以通过虚拟机工具创建。我使用了 VirtualBox，点击菜单中的 `Medium` 选择 `Create` 后，就可以创建一个扩展名是 `.vhd` 的文件了。文件名什么的任意，大小建议 60G 以上，然后记住保存的路径即可，因为接下来的步骤都会用得到。

接下来像往常一样创建虚拟机即可，点击菜单 `Machine` 选择 `New`，之后选择 Windows 11 的映像文件（`.iso`）之后，基本保持默认选项即可，我大概只更改了如下选项：

1. 勾选 Enable EFI(special OSes only)
2. 选择 Use an Existing Virtual Hard Disk File，也就是在第一步中自己创建的 VHD 文件作为硬盘。
3. 关闭了 Secure Boot，可以在创建完 VM 后在 System 里手动去掉勾选。

其他就没什么注意的了，一步一步完成安装引导就好。这里不得不吐槽一下 Windows 11，安装竟然需要在线账号。等上面的安装结束，能顺利进入桌面后，直接关机 VM 即可。

## Ventoy 引导 VHD

因为之前就在优盘上装过 Ventoy，不过好久没有更新了。为了避免不必要的问题，先更新一下。在 Linux 上非常简单，直接插上优盘，然后：

```bash
sudo ventoy -u /dev/sdX # 注意替换实际地址，比如我的优盘是 /dev/sda
```

完成后直接把之前制作的 `.vhd` 文件拷贝到优盘的任意位置即可。

但是为了引导这个文件，需要安装 [WinVhdBoot](https://www.ventoy.net/en/plugin_vhdboot.html) 插件。不过虽说是安装，其实就是复制粘贴一下，过程非常简单。

1. 先到这里下载插件 [Releases · ventoy/vhdiso](https://github.com/ventoy/vhdiso/releases)
2. 解压出来后，把这个 `Win10Based/ventoy_vhdboot.img` 文件放到优盘根目录下的 `ventoy` 目录下，即 `/ventoy/ventoy_vhdboot.img`。如果之前没有创建 `ventoy` 这个目录的话，记得自己创建下。

另外，读者可能注意到那个插件压缩包解压出来怎么只有 `Win7Based` 和 `Win10Based` 两个版本的文件，不过经过测试 `Win10Based` 里的文件也适用于安装了 Windows 11 的 VHD 文件。

## 最后

自从上次利用本文提到的方法更新 BIOS 后差不多一周了，不确定是更新 BIOS 的功劳，还是期间 Kernel 或者相关的其他部分更新的功劳，又或者是我更改 BIOS 里性能模式的功劳。总之，随机重启的问题似乎再也没遇到了，目前我对这部 ThinkBook 还是挺满意的，希望它能好好保持。

最后，期待哪天联想可以对 ThinkBook 的 Linux 用户提供更多的支持，尤其是更新 BIOS 的部分。
