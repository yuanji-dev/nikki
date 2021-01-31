---
title: "自建 bitwarden_rs"
date: 2021-01-30T22:53:49+09:00
tags: ["VPS"]
isCJKLanguage: true
draft: false
url: "/post/self-host-bitwarden_rs"
---

## 背景

一直以来，大概近 5 年的时间我一直在使用着一款叫做 Enpass 的密码管理软件，当初选择这款软件是考虑到

- 跨平台，尤其是对 Linux 桌面有较好的支持
- 买断式的收费方式
- 软件自身不提供数据同步功能，可选择自定义的同步方式

不过最近用上了新手机之后，它的自动补全方式就开始屡屡失效，虽然之前也有过但并没有这么频繁，于是想着利用这个机会研究一下其他的选择。经过一番比较，基本上把目光投向了 bitwarden。同样支持多平台，实际上我发现桌面端如果只是浏览器使用的话安装一个浏览器插件就行，那个用 Web 技术写的桌面客户端显得非常鸡肋（比起 Enpass，可以说非常卡顿）。不过基本上我在桌面端基本也只使用浏览器填充密码，所以问题不大。

至于 bitwarden 的收费方式虽然是订阅收费但价格可以说真的非常低了，只是它这种自己提供后端同步的方式总觉得心理上有点儿怪怪的。但好在除了使用它官方的服务之外，还有自建服务这条路，这里就不得不说 bitwarden_rs 这个第三方实现的开源后端了，比起官方提供的方式，系统资源的要求上要低的多。

<!--more-->

## 自建 bitwarden_rs

[bitwarden_rs 的 GitHub](https://github.com/dani-garcia/bitwarden_rs) 页面上提供了各种部署方式，为了方便维护，我选择了使用 docker-compose 的方式。有了之前自建服务的经验，基本上分为：

1. 创建 docker-compose.yml
2. 启动服务
3. acme.sh 申请 HTTPS 证书（如果已经有申请过证书可以跳过）
4. 用 NGINX 配置反向代理

### 创建 docker-compose.yml

```yaml
version: '3'
services:
  bitwarden_rs:
    image: bitwardenrs/server:latest
    restart: always
    ports:
      - "3080:80"
      - "3012:3012"
    environment:
      DOMAIN: 'https://bw.tokyo-1.gimo.me/'
      SIGNUPS_ALLOWED: 'true'
      WEBSOCKET_ENABLED: 'true'
    volumes:
      - ./data:/data
```

### 启动服务

直接在 docker-compose.yml 所在目录

```bash
docker-compose up -d
```

如果要停止服务，只要 `docker-compose down`，因为我在 docker-compose.yml 的配置，数据直接保存在当前目录的 `data` 目录。所以备份的话就是备份这个目录即可。

### 申请 HTTPS 证书

之前使用过 acme.sh 这个工具，申请证书非常方便直观，我习惯有一台服务器就先申请一张 wildcard 证书再说。因为我的域名托管在 cloudflare，在使用 acme.sh 前先设置 accout id 和 token 后就可以一键申请了。

```bash
export CF_Account_ID=YOUR_ACCOUNT_ID
export CF_Token=YOUR_TOKEN
acme.sh --issue -d tokyo-1.gimo.me -d '*.tokyo-1.gimo.me' --dns dns_cf
```

申请成功后就是安装证书了

```bash
acme.sh --install-cert -d "tokyo-1.gimo.me" \
--key-file /etc/ssl/tokyo-1.gimo.me/privkey.pem \
--fullchain-file /etc/ssl/tokyo-1.gimo.me/fullchain.pem \
--capath /etc/ssl/tokyo-1.gimo.me/chain.pem \
--reloadcmd "sudo systemctl reload nginx.service"
```

然后设置一个定时脚本用来更新证书（这取决于你安装 acme.sh 的方式，似乎默认的安装方式会自动设置一个 cronjob，不过我的服务器用的是 Arch 仓库里的版本，需要自己配置一下实际上也非常简单，就是创建一个 systemd timer/service。

```ini
# /etc/systemd/system/acme_letsencrypt.timer
[Unit]
Description=Daily renewal of Let's Encrypt's certificates

[Timer]
OnCalendar=daily
RandomizedDelaySec=1h
Persistent=true

[Install]
WantedBy=timers.target
```

```ini
# /etc/systemd/system/acme_letsencrypt.service
[Unit]
Description=Renew Let's Encrypt certificates using acme.sh
After=network-online.target

[Service]
Type=oneshot
Environment="HOME=/home/yuanji"
ExecStart=/usr/bin/acme.sh --cron
SuccessExitStatus=0 2
```

## 配置 NGINX

[bitwarden_rs 的 wiki](https://github.com/dani-garcia/bitwarden_rs/wiki) 里包含了各种各样的文档，其中我对照 https://github.com/dani-garcia/bitwarden_rs/wiki/Proxy-examples 里的例子稍作修改如下。

```nginx
# Define the server IP and ports here.
upstream bitwardenrs-default { server 127.0.0.1:3080; }
upstream bitwardenrs-ws { server 127.0.0.1:3012; } 
                                                                                       
# Redirect HTTP to HTTPS
server {                               
    listen 80;
    server_name bw.tokyo-1.gimo.me;
    return 301 https://$host$request_uri;
} 

server {
    listen 443 ssl http2;
    server_name bw.tokyo-1.gimo.me;

        # SSL
        ssl_certificate /etc/ssl/tokyo-1.gimo.me/fullchain.pem;
        ssl_certificate_key /etc/ssl/tokyo-1.gimo.me/privkey.pem;
        ssl_trusted_certificate /etc/ssl/tokyo-1.gimo.me/chain.pem;

    client_max_body_size 128M;

    location / {
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;

      proxy_pass http://bitwardenrs-default;
    }

    location /notifications/hub/negotiate {
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;

      proxy_pass http://bitwardenrs-default;
    }

    location /notifications/hub {
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection $http_connection;
      proxy_set_header X-Real-IP $remote_addr;

      proxy_pass http://bitwardenrs-ws;
    }
}
```

## 最后

搭好服务后访问域名就可以使用了，bitwarden_rs 的 docker 镜像除了包含了后端的 API 之外还自带了一个修改过的官方 Web UI，通过它可以直接导入从 Enpass 导出的 json 文件，不过 Enpass 的 attachments 并不会自动转成 bitwarden 里的，稍微需要做点儿手动干预。另外如果只是自己使用的话可以把注册功能禁用，设置 docker 的环境变量 `SIGNUPS_ALLOWED: 'false'` 即可。

在使用了几天之后发现没有特别的问题，只是我上服务器查看了下 NGINX 的日志发现好多奇奇怪怪的爬虫、探测请求，虽然说这些无脑的脚本不至于构成什么大问题，但感觉还是稍加保护为好，好奇的读者可能会发现上文配置里的 https://bw.tokyo-1.gimo.me/ 解析到了一个私有 IP 地址，至于细节，请看下一遍日记我会介绍一下如果使用 WireGuard 来搭建一个简单的 VPN 隧道。