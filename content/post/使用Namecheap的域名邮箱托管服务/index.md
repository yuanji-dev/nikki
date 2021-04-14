---
title: "使用 Namecheap 的域名邮箱托管服务"
date: 2021-04-14T18:59:32+09:00
tags: ["杂"]
isCJKLanguage: true
draft: false
url: "/post/using-namecheap-email-hosting-service"
---

## 背景

最近手机携号转网，运营商从 SoftBank 改成了 Rakuten Mobile，一下子一个月能省下好几千日元，想着借这个机会重新审视下其他一些服务的费用，其中一个就是我的域名邮箱（ [self@gimo.me](mailto:self@gimo.me) ），我的域名 gimo.me 是我 2011 年注册的到今年已经第十个年头，开头的几年出于好玩用过当时腾讯邮箱免费的域名邮箱服务，后来从 2018 年开始一直用的是 G Suite（现在改名叫 Google Workspace），中间涨了一次价格，目前日本的价格最基础版大概一个月 680 日元（含税 748 日元），实际上我需要的只是邮箱功能，它附带的其他功能压根用不上，每个月交这么一笔钱也不太划算。又正好我用的域名服务商 Namecheap 有个邮箱托管（[Professional Business Email](https://www.namecheap.com/hosting/email/)）的促销情报，大概首年半价，或者可以试用 2 个月（这个好像只要新用户就有），于是我开通了 Pro 版的试用几天，目前感觉还不错，借此记录下这个转移的过程，顺便写一写相关 DNS 记录（MX, SPF, DKIM, DMARC）的作用。

<!--more-->

## 迁移步骤

实际上也没有啥要特别注意的，先后顺序大概是

1. 打包下载 Google Workspace 上的数据，这个 Google 自己就提供了这个功能叫作 [takeout](https://takeout.google.com/settings/takeout)，可以一键打包下载所有 Google 服务的数据。（实际上我只是备份用，并不直接用来迁移邮件）
2. 开通 Namecheap 的邮箱托管服务，他们有三档服务可以按照自己的需要选择，我选的 Pro 版本（反正是试用期）自带有 3 个邮箱，30 GB 存储空间。（我在 Google Workspace 上有近万封邮件不过也才占用不到 200 MiB），每个邮箱可以有绑定 50 个别名。
3. 更改 DNS 记录（下文会具体解释）
4. 找个桌面的邮箱客户端（我使用的是 [Thunderbird](https://www.thunderbird.net/)）迁移旧邮件，方法听起来似乎有点愚蠢但确实可行，就是在客户端邮箱里先登录 Google 的邮箱帐号（根据 Google 的安全要求，需要开通二步验证然后生成一个 App Password 专门用来使用 IMAP），然后也登录上新的邮箱，把需要的邮件选中从旧邮箱拖动到新邮箱即可。

## DNS 记录

Namespace 虽然提供了很详细图文教程，比如如何在 [Cloudflare](https://www.namecheap.com/support/knowledgebase/article.aspx/9967/2176/how-to-set-up-dns-records-for-namecheap-email-service-with-cloudflare-cpanel-and-private-email/) 里设置等等，但是他并没有很好地解释为什么要设置这些 DNS，还有一些有用的 DNS 记录设置在他的教程中被省略了，这里应该表扬一下 [Google 家的文档](https://support.google.com/a/answer/140034)，显得很有条理。不过 Namecheap 估计是担心用户设置错误反而造成困扰吧，我这几天也花时间学习了一下与邮箱相关的 DNS 设置，借此记录一下。

### MX 记录

首先最关键的当然是 MX 记录了，这个很好理解，一般设定好 MX 记录等生效后别人给你发邮件基本就可以收到了。

```bash
❯ dog gimo.me MX        
MX gimo.me. 5m00s   10 "mx1.privateemail.com."
MX gimo.me. 5m00s   10 "mx2.privateemail.com."
```

其中有个 **Priority** 可以设置，这个值越小优先级越高的意思，像是 Google 家 MX 记录可以设置 5 条之多，这里 Namecheap 的应该是比较常规的两条记录。（另外读者可能奇怪为什么记录有没有出现 Namecheap 字样，实际上 privateemail 就是 Namecheap 家的邮箱服务名称）另外记录中的 Host（比如 mx1.privateemail.com.） 必须直接映射 A 或者 AAAA 记录，不过这就不是我们需要关心的问题了。

### SPF 记录

这个 SPF（Sender Policy Framework）主要是用来声明发信的服务器是经过我本人授权的，它的假设是只有我本人可以控制 DNS 的记录，既然我在 DNS 里声明了自然代表了我的意志，意思就是声明收到以 gimo.me 结尾的发信人发的信时，去查一查是不是被授权的服务器发来的。那么，按照 Namecheap 的指示，我的记录如下

```bash
❯ dog gimo.me TXT
TXT gimo.me. 5m00s   "v=spf1 include:spf.privateemail.com ~all"
```

不过这条记录是什么意思呢？查阅了相关资料后

v 代表版本，include 就是字面意思，就是包括参照 spf.privateemail.com 上的声明，如果那上面的规则通过的话就认为是我授权的服务器发出的信，如果没有通过的话，最后的 ~all 代表默认还是放行但是做个标记，如果把波浪线 ~ 改成减号 - 就是比较严格的 reject 了。

那么我就马上去看一下 include 的这个记录上到底写了啥，结果如下：

```bash
❯ dog spf.privateemail.com TXT
TXT spf.privateemail.com. 30m00s   "v=spf1 ip4:68.65.122.0/27 ip4:198.54.122.32/27 ip4:198.54.127.64/27 ip4:198.54.127.32/27 ip4:198.54.118.192/27 ip4:198.54.122.96/27 ip4:198.54.127.96/27 include:fbrelay.privateemail.com include:se.privateemail.com ~all"
```

### DKIM 记录

DKIM (Domain Keys Identified Mail) 这条记录的设置实际上在 Namecheap 的设置教程里并没有出现，不过在它的管理页面确实有这么个功能，他的主要功能是通过[公开密钥加密](https://zh.wikipedia.org/wiki/%E5%85%AC%E5%BC%80%E5%AF%86%E9%92%A5%E5%8A%A0%E5%AF%86)的原理，由邮件服务器用我的私钥对邮件内容进行签名附在邮件的 header 里，当收信服务器收到时就可以用存在我 DNS 记录里的公钥进行验证：

```bash
❯ dog default._domainkey.gimo.me TXT
TXT default._domainkey.gimo.me. 5m00s   "v=DKIM1;k=rsa;p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAqkiywqUshjuFyQpeCME01I3vi8Z7vR67k/4VSCfaWQJg6cjAfeOB3V8U8pNCI3884cx6PRhlqhMOW9g4zNLMVbREFqa4nRyg9Kmg8Qop87/Pk8Vc3IldzB5m5YlNJy+a/y1KxRC7gq0JTSKXiT7AEXCKXhU1LBiE9S7e1k7lmWQEDkVZJunFyVDVslUlNUFD6qsCWTLxTV6COEmYbMZxWgLAKX/AcYOzRtlYQKh5ZN/IX0JMPTJwhvj3xYQxVVhdjFWSInVIXENEaRcazskFazEHC3n2awk2YQ3L69PsqMd2qPvayh462CkDw54kfPfMbGXfxzxD0mVJxd5CxDX6pQIDAQAB"
```

不过，我想了想既然都有 SPF 来保证我的邮件是我授权的服务器发出的，为什么还要多此一举加一个 DKIM 呢？难不成有人用同一个邮件服务商来冒名顶替我发邮件？毕竟我的私钥也是 Namecheap 给生成告知我的，既然我都信得过他们的服务了，这么设置 DKIM 感觉有点儿多此一举。不过我查了其他一些资料得知，据说转发邮件的时候 SPF 验证就会失效了，因为当新的接收者收到邮件时，他去验证发出的服务器显然不是我最初指定的授权服务器了，这时他可以通过在 header 里的 DKIM 签名来验证确实是我授权发出的。这样一来两道保障确实是说得通的，一来保障发出的服务器是经过授权的，二来邮件的内容是没有篡改的。

### DMARC 记录

DMARC (Domain-based Message Authentication, Reporting and Conformance) 这条记录的名字虽然看着复杂，不过有了上面两条的铺垫，这个就比较好理解了，因为这条记录的前提是前面两条记录 SPF 和 DKIM。作用大体是是定义如果上面两种验证的结果没有通过的话，接收到邮件的服务器可以采取什么样的手段。这里就不展开讲各种配置的作用，我们可以看看各大邮件提供商是如何配置的

```bash
❯ dog _dmarc.gmail.com TXT
TXT _dmarc.gmail.com. 10m00s   "v=DMARC1; p=none; sp=quarantine; rua=mailto:mailauth-reports@google.com"

❯ dog _dmarc.163.com TXT             
TXT _dmarc.163.com. 30m00s   "v=DMARC1; p=none;"

❯ dog _dmarc.qq.com TXT 
TXT _dmarc.qq.com. 1h00m00s   "v=DMARC1; p=none; rua=mailto:mailauth-reports@qq.com"
```

基本都是比较宽松的，p 代表的是 policy 都是 none，sp 代表的是 subdomain 的 policy，而 rua 则代表发送 aggregate 报告到指定邮箱。我就依葫芦画瓢整一个类似的基本就可以了。

```bash
❯ dog _dmarc.gimo.me TXT  
TXT _dmarc.gimo.me. 5m00s   "v=DMARC1; p=none; rua=mailto:mailauth-reports@gimo.me"
```

### 其他 DNS 记录

实际上，在 Namecheap 的教程里还有好几条其他的 DNS 记录可以设置，不过这些在我看来基本是可有可无的鸡肋，大可不设置也罢，主要功能是用来方便邮箱客户端在初始化的时候可以自动发现和设置 IMAP 和 SMTP 的配置，罗列一下这里我就不一一解释了。

```bash
Type: CNAME | Name: mail | Domain name: privateemail.com | Automatic TTL
Type: CNAME | Name: autoconfig | Domain name: privateemail.com | Automatic TTL
Type: CNAME | Name: autodiscover | Domain name: privateemail.com | Automatic TTL
Type: SRV | Service name: _autodiscover | Protocol: TCP | Name: yourdomain.com | Priority: 0 | Weight: 0 | Port: 443 | Target: privateemail.com | Automatic TTL
```

我自己用 Thunderbird 试了一下确实有效果，也找到了一个相关的[规范文档](https://developer.mozilla.org/en-US/docs/Mozilla/Thunderbird/Autoconfiguration)，有兴趣的读者可以自己阅读。

## 邮箱客户端

因为之前用 Google 的服务就直接用的 Gmail 客户端，手机上我试了几款 Android 的邮件客户端，最终其实选择也不多，不过好在有一款叫 [FairEmail](https://email.faircode.eu/) 的客户端我用着还挺满意的，另一款也同样开源的软件 [K\-9 Mail](https://k9mail.app/) 似乎名气更大些，不过我个人还是比较倾向前一款。