---
title: "VPS 再入门: Ansible 使用篇"
date: 2019-10-19T16:17:08+09:00
tags: ["Ansible", "VPS"]
isCJKLanguage: true
draft: false
url: "/post/using-ansible-to-setup-vps"
---

话说最早接触 VPS 大约还在刚入大学那会儿，我还没有信用卡、PayPal，国外 IDC 对于支付宝等的支持还非常少，记得那时候还是上淘宝找的代购。之后陆陆续续基本上都有一两台在服役，搭建个网站，跑点脚本、做个代理之类的。但老是不太长久，几乎隔段时间就会重新配置一下，虽然也累计了一些脚本，但我想初始化环境、日常维护之类的工作应该可以更方便些。

就在大约一个月前，在 Oracle Cloud 上薅羊毛薅了一台免费的 VPS，又正好最近转职活动告一段落赋闲在家，就开始了对这台 VPS 的调教之路，主要使用的就是一个叫做 Ansible 的工具。

## Ansible 基本介绍

至于为什么要使用 Ansible，主要的原因还是因为简单。管理工作从之前的直接告诉服务器一步一步该怎么做，变成了告诉 Ansible 每一步的结果是什么样的，这个每一步结果的确定性由 Ansible 的模块（module）去确保，于是让 Ansible 去执行任务，每次任务结果应该都一致，这一特性称为幂等性（当然 Ansible 的 shell 模块等可以执行 shell 脚本，这类任务的幂等性需要用户自己保证）。如果这里有点儿云里雾里没关系，下面会有具体例子解释。总而言之，Ansible 给我们管理服务器提供一个非常好的脚手架，让我们可以少关心具体怎么操作服务器，而把重心转移到描述预期的服务器应该成为什么样子上去。

话题转到怎么初始化一台服务器上，当我们从服务商那租用一台 VPS 的时候一般会提供给我们用 SSH 登录的配置，Ansible 正是使用 SSH 来与服务器交互，这也是 Ansible 的另一个特点，不需要在远端服务器运行监听程序（Agentless），只需要有 Python 运行环境就行，这个特性至少对资源非常有限的 VPS 来说算是一个不错的加分项。接下来我就以几个具体的例子来一探 Ansible 的能力。

## Ansible 模块的使用

### 示例一：管理用户

比如说，通常我们会创建一个管理员用户而不是一直使用 root，Ansible 里我们可以使用 user 模块这么做：

```yaml
---
- name: Add a user
  user:
    name: yuanji
    shell: /bin/bash
    groups:
      - sudo
      - docker
    append: true
```

这就描述了我们的目标服务器上，应该有个叫 yuanji 的用户，他使用 bash，至少在 sudo 和 docker 两个组里。但是如果要声明多个用户，我们可以像下面那样用模板加变量的方式来实现，把逻辑和数据分割开更有助于组织代码。

```yaml
---
- name: Add users
  user:
    name: "{{ item.name }}"
    shell: "{{ item.shell }}"
    groups: "{{ item.groups }}"
    append: "{{ item.append }}"
  with_items: "{{ users }}"
```

```yaml
---
users:
  - name: dog
    shell: /bin/bash
    groups:
      - sudo
      - docker
    append: true
  - name: cat
    groups:
      - sudo
      - docker
    append: true
    shell: /bin/fish
```

### 示例二：上传 SSH 登录用的公钥

再来一个经常用到的配置，比如上面刚创建的 yuanji 用户，我要以 yuanji 的身份用 SSH 登录服务器怎么办呢？用 `ssh-copy-id` 把自己的公钥追加到 VPS 的 yuanji 的 `.ssh/authorized_keys` 文件里。而借助 Ansible 的 `authorized_key` 模块，只要简单声明下就行了，同样的如果复数个人的公钥要配置可以用模板。

```yaml
---
- name: Set authorized_key
  authorized_key:
    user: yuanji
    state: present # absent 可以确保公钥不在 authorized_key 文件里
    key: https://github.com/masakichi.keys # 当然也可以用本地的文件
```

总而言之，Ansible 里已经内置了五花八门的模块供使用，基本能够满足日常的需求。我们要做的就是尽量写出满足幂等性要求的 Playbook（Ansible 的术语，就是书写一系列指令的地方）。

## Ansible 组织复杂配置：使用 Role

但是如果配置很多，写在一个 Playbook 里就很难看，于是 Ansible 引入了一个叫作 Role 的概念，就是把一些种类差不多的指令集合在一块，然后在 Playbook 里引入就行了。Role 的另一个作用是屏蔽一些琐碎的细节，比如为了兼容不同包管理的发行版，或者兼容使用 systemd 和不使用 systemd 的发行版等等。另外一个重要的特性是，为了复用代码（ ~~偷懒~~ ），可以使用社区贡献的一些通用的 Role，可以在 [Ansible Galaxy](https://galaxy.ansible.com/) 或者 GitHub 上找找，不过运行前最好自己 review 一下代码（也是个学习别人怎么写的机会）。经过前几天的书写，目前我 VPS 的基础配置用的 Playbook 叫 `bootstrap.yml` 大概长这样（可以看到我使用了很多 geerlingguy 写的第三方 Role）。

```shell
---
- hosts: edo
  become: true

  vars_files:
    - vars/users.yml
    - vars/sudoers.yml
    - vars/packages.yml
    - vars/ssh.yml
    - vars/ntp.yml
    - vars/firewall.yml
    - vars/pip.yml
    - vars/nodequery.yml

  vars:
    swap_file_size_mb: '1024'

  roles:
    - role: geerlingguy.ntp
      tags: ntp
    - role: geerlingguy.firewall
      tags: firewall
    - role: geerlingguy.pip
      tags: pip
    - role: geerlingguy.docker
      tags: docker
    - role: geerlingguy.swap
      tags: swap
    - role: users
      tags: users
    - role: packages
      tags: packages
    - role: sudo
      tags: sudo
    - role: ssh
      tags: ssh
    - role: nodequery
      tags: nodequery,monitor
```

有了这个基础的环境之后，我再在另外的 yaml 文件里书写各个服务不同的配置，目前觉得还是比较好管理的。具体搭建的哪些服务在接下来的文章里再写吧。

## 使用 Ansible 的一些小技巧

### 在复数台服务器上运行相同的指令

虽说通过 Playbook 里任务的声明来使用 Ansible 是比较正统的做法，有些时候只是单纯地想运行一个简单的命令（很多时候可能是对好几台服务器运行同样的命令）我们可以直接用 Ansible 的命令行工具来实现。

```shell
$ ansible all -i inventory -a "uname -a"
edo.gimo.me | CHANGED | rc=0 >>
Linux edo 4.15.0-1026-oracle #29-Ubuntu SMP Wed Sep 18 10:17:09 UTC 2019 x86_64 x86_64 x86_64 GNU/Linux

shin.gimo.me | CHANGED | rc=0 >>
Linux shin 5.3.6-arch1-1-ARCH #1 SMP PREEMPT Fri Oct 11 18:28:05 UTC 2019 x86_64 GNU/Linux
```

### 使用 tags 执行指定的指令

一个 Playbook 里可能包含了不少 task 或者 role，有时可能只需要运行其中一个，我们可以给他们设置 tags，然后执行的时候指定 tags 就行了，可以节省不少时间。比如说，改变了防火墙开放端口的配置，我们只想重新执行下防火墙相关的任务可以这样：

```shell
$ ansible-playbook -i inventory bootstrap.yml --tags firewall
```

### 从指定的任务开始执行

有的时候（调试的时候居多）一个包含好几个任务的 Playbook 执行到某个任务时失败了，修正了错误后不想从头开始跑，可以指定从哪个任务开始。

```shell
$ ansible-playbook -i inventory web.yml --start-at-task "Upload include files"
```

## 感想

除了上面简单提到的几个简单例子，Ansible 还有很多其他功能，例如 block、handler 之类的来更好的组织代码、用 ansible-vault 来加密敏感信息等等。官方提供的文档也非常详细，可能是这个原因近两年似乎没有啥出版的新书。我这几天读了两本关于 Ansible 的书，作为入门应该足够了。分别是 [Ansible : From Beginner to Pro](https://book.douban.com/subject/26884350/) 和 [Ansible for DevOps: Server and configuration management for humans](https://book.douban.com/subject/26643234/) 尤其是第二本的作者在社区里维护了为数众多的 Role，看一看作为模仿的例子还是非常不错的。

另外我自己使用的感受上，Role 的存在虽然很好的组织了代码，不过想引用 Role 里部分代码似乎不太方便，比如我用的一个第三方的 Nginx 的 Role 里有个重启服务的 handler 我要在其他的 Playbook 使用就不太可能，调查了一圈的结果是可以创建一个空任务的 Role，然后把想要复用的 handlers 统统放到那个 Role 里，有想要使用的 Playbook 就引入那个装满了 handler 的 Role。

期间还有一个小插曲，我用 Ansible 配置 SSH，把默认的端口改成非 22 的时候，执行完发现防火墙的配置没有开放新的那个端口，结果把自己隔离在了 VPS 之外......于是只能重新创建一台新的 VPS 然后把之前那台的存储挂载在新的 VPS 上修改配置文件后再重新挂回到原 VPS 上，最后把新开的 VPS 实例删除才救回来。

最后想折腾但并没有实际开始的是，使用 Ansible 来管理自己日常使用的电脑，我看到 GitHub 上有人这么配置 [macOS](https://github.com/geerlingguy/mac-dev-playbook) 和 [Arch Linux](https://github.com/pigmonkey/spark)。~~等我有空折腾一下，基于 Ansible 幂等性的特点，想必不会出什么大问题。~~