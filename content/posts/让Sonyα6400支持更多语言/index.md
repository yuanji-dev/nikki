---
title: "让 Sony α6400 支持更多语言"
date: 2023-07-13T20:01:31+09:00
draft: false
tags: ["Sony", "α6400"]
keywords: ["Sony", "α6400"]
slug: "unlock-more-languages-for-sony-a6400"
icon: 📷
---

两年前买了一个 Sony α6400 照相机，除了偶尔出去玩拍了几次照片之外，大部分时间它都呆在原地不动。前两天突然想起来好像因为是在日本购买的，它压根就不支持更改语言。因为我也就会用这么几个功能也没太在意过默认的日文。这两天花时间调查了一下，原来通过一定的手段是可以让它支持多语言的。先说结论好了，就我的日版 α6400 而言：

1. 的确可以解锁包括英语在内的众多语言（总共 33 种）
2. 然而简体中文和繁体中文在日版的机器上不支持，会闪退（据说其他国家购买的也是可以顺利支持的）

本文主要介绍一下这两天折腾的经过，主要就是使用 [ma1co/Sony-PMCA-RE: Reverse Engineering Sony Digital Cameras](https://github.com/ma1co/Sony-PMCA-RE) 这个工具 ，另外根据这个项目的介绍，相同的方法应该也适合其他的相机，感兴趣的朋友可以查看自己的机型是否在支持之列。[Supported Devices](https://openmemories.readthedocs.io/devices.html)

<!--more-->

## 配置 Sony-PMCA-RE

因为我使用的是 Arch Linux，对于这个 Python 项目而言，其实并不需要特意安装什么，无非就是下载代码，装上相应的 Python 依赖就可以了。

```bash
git clone https://github.com/ma1co/Sony-PMCA-RE.git
cd Sony-PMCA-RE
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

到此这个工具就配置完毕了。

## 使用 Sony-PMCA-RE

先把相机连上电脑，输入 `./pmca-console.py info` 果不其然不会这么顺利，似乎是普通用户对于这个 USB 设备没有权限，报错如下：

```
usb.core.USBError: [Errno 13] Access denied (insufficient permissions)
```

凭借我之前给 Android 刷机的经验，差不多写一条 udev 的规则就能解决，于是

```
$ lsusb | grep Sony
Bus 001 Device 007: ID 054c:0ca8 Sony Corp. ILCE-6400
```

注意记录下 **054c:0ca8**，分别是 Vendor 和 Product 的 id，创建 `/etc/udev/rules.d/71-sony-ilce-6400.rules`，内容如下

```
SUBSYSTEMS=="usb", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0ca8", MODE="0660", TAG+="uaccess"
```

保存后，`sudo udevadm control --reload` 让其生效。再重新拔插一下数据线就可以了。

再次输入 `./pmca-console.py info` 如果看到类似下面输出，差不多就成功一半了。

```
No native drivers available
Using drivers libusb-MSC, libusb-MTP, libusb-vendor-specific
Looking for Sony devices

Querying mass storage device
Sony DSC is a camera in mass storage mode

Model:              ILCE-6400
Product code:       **********
Serial number:      ********
Firmware version:   2.00
Lens:               Model 0x17a08051 (Firmware 1.03)
```

按照说明，要想解锁多语言的话，需要输入 `./pmca-console.py serviceshell` 进入 service mode，这时 `lsusb` 的输出会发生变化：

```
$ lsusb | grep Sony
Bus 001 Device 011: ID 054c:0336 Sony Corp. Sony USB Device
```

出现了一个新的 Product id，于是使用上面相同的方法，更新 `/etc/udev/rules.d/71-sony-ilce-6400.rules` 变成

```
SUBSYSTEMS=="usb", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0ca8", MODE="0660", TAG+="uaccess"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0336", MODE="0660", TAG+="uaccess"
```

保存后，再次执行 `sudo udevadm control --reload` 让其生效。再重新拔插一下数据线就可以了。

之后运行 `./pmca-console.py serviceshell` 就可以愉快地进入交互界面了。

```txt
$ ./pmca-console.py serviceshell
Using drivers libusb-MSC, libusb-MTP, libusb-vendor-specific
Looking for Sony devices

Querying mass storage device
Sony DSC is a camera in mass storage mode

Switching to service mode

Waiting for camera to switch...
Found a camera in service mode
Authenticating
Starting service shell...

Welcome to platform shell.
Type `help` for the list of supported commands.
Type `exit` to quit.
>tweak
1: [X] Disable video recording limit
       13h 01m 00s

2: [ ] Unlock all languages
       1 / 35 languages activated

3: [ ] Enable PAL / NTSC selector & warning
       Disabled

4: [X] Enable USB app installer
       Enabled

Enter number of tweak to toggle (0 to apply): 2

1: [X] Disable video recording limit
       13h 01m 00s

2: [X] Unlock all languages
       33 / 35 languages activated

3: [ ] Enable PAL / NTSC selector & warning
       Disabled

4: [X] Enable USB app installer
       Enabled

Enter number of tweak to toggle (0 to apply):
```

## Sony-PMCA-RE 的缺陷

据介绍，这个工具并不会给相机加入新的语言包，他只是把原有隐藏的设置给暴露出来，应该只是更改配置文件而已，而且使用相反的操作可以还原成本来的样子，整体来说没什么大风险，不过我按照他的代码解锁全部 35 种语言后，进入选择语言的界面时会闪退，初步怀疑是某些语言有问题，最后使用二分法逐步排除，反复测试后，发现竟然是简体中文和繁体中文在日版的机器上会闪退，了解到这一真相的我试着去项目里[搜了下 Chinese 这一关键词](https://github.com/search?q=repo%3Ama1co%2FSony-PMCA-RE+Chinese&type=issues)，果然有不少人也遇到了相同的问题。最终不得不更改 [Sony-PMCA-RE/pmca/platform/backup.py](https://github.com/ma1co/Sony-PMCA-RE/blob/a82f5baaa8e9c3d9f28f94699e860fb2e48cc8e0/pmca/platform/backup.py#L189-L217) 这个文件，屏蔽掉这两种中文，果然就闪退了。事后发现早有前辈提出了 https://github.com/ma1co/Sony-PMCA-RE/pull/356 这个 PR，要是早知道就不用一点点自己试了。不过也不失为一次探索的经历，于是又花了点儿时间写了这篇博客。
