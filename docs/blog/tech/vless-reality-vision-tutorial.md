---
title: 2026年8月最新稳定 Debian 搭建 VLESS+TCP(RAW)+REALITY+Vision 节点教程
createTime: 2026/10/05 20:00:00
permalink: /blog/tech/vless-reality-vision-tutorial/
tags:
  - VLESS
  - REALITY
  - Vision
  - Xray
  - 3x-ui
  - Debian
  - VPS
---

# 2026年8月最新稳定 Debian 搭建 VLESS+TCP(RAW)+REALITY+Vision 节点教程

如果把优先级明确设为"稳定第一、兼容第二、前沿第三"，那么在这份 2026 年 8 月版教程中，推荐长期使用的默认基线依然是：

```
VLESS + TCP(RAW) + REALITY + xtls-rprx-vision
```

这套方案不是概念最新的一套，但它仍然是当前 Xray 体系里最成熟、最少变量、最容易长期稳定运行的组合。相比 XHTTP + ECH + 后量子这类更前沿的路线，它更适合日常主力节点。

## 为什么现在仍然推荐这套方案

原因很简单：变量越少，稳定性越高。

- 不叠加 WebSocket、XHTTP、ECH、后量子等新变量，故障点更少
- REALITY + Vision 仍然是官方长期维护、文档明确支持的成熟组合
- 客户端兼容面更广，导入订阅后更不容易出兼容问题
- 排障更简单，节点异常时更容易定位问题来源

如果你的目标是"长期稳定不死"，那就不要先追求参数花样，而要先追求链路干净。

## 一、底层环境准备

登录 Debian VPS 后，按下面顺序执行即可。如果你当前就是 root 登录，推荐直接用 apt-get，不需要再额外写 sudo。

### 1. 先更新系统

```bash
apt-get update
apt-get full-upgrade -y
```

### 2. 安装基础工具

```bash
apt-get install -y curl wget vim socat ca-certificates lsb-release gnupg ufw
```

### 3. 设置时区

```bash
timedatectl set-timezone Asia/Shanghai
```

这样拆开执行更好，因为：

- 如果第一步更新失败，你能马上知道
- 不会一串命令里前面报错，后面还继续跑
- 更方便排查到底卡在哪一步

### 4. 开启 BBR

```bash
sh -c 'echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf'
sh -c 'echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf'
sysctl -p
lsmod | grep bbr
```

如果 `lsmod | grep bbr` 有返回值，就说明 BBR 已启用。

注意：前两行是追加写入，重复执行会在 `/etc/sysctl.conf` 里留下重复配置，因此正常执行一次即可。

## 二、安装 3x-ui 面板

### 1. 执行官方安装脚本

```bash
bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
```

### 2. 安装时记住这三项

- 面板用户名
- 面板密码
- 面板端口

建议避开 80、443、8080，例如使用 54321。面板端口只是给管理后台用，不要和你后面节点入站端口混在一起。

安装完成后输出的凭据类似这样（示例，请以你自己的实际输出为准）：

```
═══════════════════════════════════════════
     Panel Installation Complete!         
═══════════════════════════════════════════
Username:    your-username
Password:    your-password
Port:        54321
WebBasePath: your-web-base-path
Database:    SQLite (/etc/x-ui/x-ui.db)
Access URL:  https://your-server-ip:54321/your-base-path
API Token:   （保存在安全的地方，切勿公开）
═══════════════════════════════════════════
```

> ⚠️ 安全提醒：面板用户名、密码、API Token 属于敏感凭据，只应保存在自己的密码管理器里，绝对不要发布到公开博客、聊天群或截图分享。

截至 2026 年 7 月 30 日，3x-ui 官方稳定发布页显示最新版本为 v3.6.0，并集成 Xray-core v26.7.28。Xray-core 官方将该核心版本标记为预发布，因此新手建议使用 3x-ui 的稳定更新通道，不要切换到 Dev 通道；安装后再到面板中确认实际版本。

### 3. 安装完成后立即开启防火墙

面板装好后，不要急着直接裸奔使用，先把系统防火墙开起来。如果你是 root 登录，直接执行下面这组命令：

```bash
ufw default deny incoming
ufw default allow outgoing

ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 54321/tcp

ufw enable
ufw status
```

这几条规则分别对应：

- `22/tcp` 是 SSH 远程登录端口
- `80/tcp` 是给 Let's Encrypt 申请和续签证书用的
- `443/tcp` 是后面节点常见使用端口
- `54321/tcp` 是你安装 3x-ui 时自己设置的管理面板端口（按实际修改）

如果你的 SSH 端口不是 22，这里也要改成真实端口，否则可能把自己锁在服务器外面。

另外，除了系统里的 ufw，云厂商后台的安全组也要同步放行对应端口。很多人以为自己已经开了防火墙，结果其实是被安全组挡住了。

### 4. 开了防火墙后，怎么查自己的订阅端口

很多人第一次装好 3x-ui / x-ui 后，只记住了面板端口和节点端口，结果开了 ufw 以后发现：面板能登录、节点本身也在监听，但客户端更新订阅一直提示超时。这时候最常见的原因不是节点坏了，而是订阅端口没有放行。

先把这 3 类端口分清楚：

| 端口类型 | 用途 |
|---|---|
| 面板端口 | 登录 3x-ui 后台用 |
| 节点端口 | 客户端实际连接入站用，例如 443 |
| 订阅端口 | 客户端拉取订阅链接时访问的端口 |

它们完全可以不同。比如：面板端口 54321、节点端口 443、订阅端口 2096。

**① 直接看订阅链接本身（最直接）**

- 如果链接是 `https://example.com:2096/sub/...`，那客户端实际访问的订阅端口就是 2096
- 如果链接是 `https://example.com/sub/...`，那对客户端来说默认就是 443
- 如果链接是 `http://example.com/sub/...`，那默认就是 80

也就是说，订阅链接里显式写了端口，就看那个端口；没写端口，就按协议默认端口算。

**② 在服务器日志里看 Sub server**

如果你有服务器权限，直接看 x-ui 日志最稳：

```bash
journalctl -u x-ui -n 50 --no-pager
```

通常会看到类似输出：

```
Web server running HTTPS on [::]:25731
Sub server running HTTPS on [::]:2096
```

`Web server` 后面的端口是面板端口，`Sub server` 后面的端口才是订阅服务端口。

**③ 用监听端口反查**

```bash
ss -tlnp | grep x-ui
```

通常你会同时看到面板端口和订阅端口都被 x-ui 监听。

**④ 开了 ufw 记得把订阅端口也一起放行**

```bash
ufw allow 2096/tcp
ufw reload
```

如果你开了云厂商安全组，也要同步把这个端口放行。

注意：如果你的订阅链接前面套了 Nginx 或 Caddy 反代，那么客户端真正访问的可能是 443，而不是 x-ui 内部的订阅监听端口。最终以你客户端实际访问的订阅链接为准。

### 5. 首次登录后怎么修改面板密码并开启 2FA

第一次打开面板后，建议立刻把认证信息处理好，再去建入站。

面板里按这个顺序操作：

1. 登录 3x-ui 面板
2. 进入 Panel Settings
3. 找到 Authentication
4. 修改用户名和密码
5. 开启 Two-Factor Authentication

如果你安装时已经让脚本生成了一组随机用户名和随机密码，也可以先不改用户名，但密码一定要确保足够强。

开启 2FA 时，一般会看到二维码或一串密钥。这时用手机上的验证器 App 扫码即可，例如：

- Google Authenticator
- Microsoft Authenticator
- Aegis

扫码后，App 会每 30 秒生成一个新的 6 位验证码。把当前验证码填回 3x-ui 面板并保存，之后你登录面板时就会多一道动态验证码校验。

这里有两个细节一定别省：

- 把 2FA 的密钥或恢复信息单独保存好，不要只留在手机里
- 开完 2FA 后，退出面板重新登录一次，确认用户名、密码和动态验证码都正常

如果你后面忘了面板密码，或者 2FA 配错导致进不去，可以在服务器里执行：

```bash
x-ui
```

然后走重置账号密码流程。新版菜单里也会问你是否禁用当前已经配置好的 2FA，到时按提示操作即可。

## 三、添加 VLESS + REALITY + Vision 入站

在 3x-ui 面板中进入"入站列表"，点击"添加入站"，按下面填写：

### 基础设置

| 项 | 值 |
|---|---|
| 协议 | vless |
| 监听 IP | 留空 |
| 端口 | 443 |
| 客户端 ID | 随机 UUID |
| Email | 随意填写 |
| Flow | 必须选择 `xtls-rprx-vision` |

### 传输设置

| 项 | 值 |
|---|---|
| 网络 | tcp 或 raw |
| 安全 | reality |

说明一下：新版 Xray 文档中，TCP 的主名已改成 RAW，但在很多面板和客户端里仍然会显示成 TCP，两者本质上是同一类传输。

## 四、REALITY 核心参数怎么填

REALITY 开启后，重点只看这几项：

| 参数 | 值 |
|---|---|
| target / dest | 伪装目标站，例如 `dl.google.com:443` |
| serverNames | 对应 SNI，例如 `dl.google.com` |
| privateKey | 点击生成 X25519 密钥 |
| shortIds | 随机生成 |
| fingerprint / uTLS | chrome |
| spiderX | 留空或填 `/` |

这里有几个稳定派原则：

- 目标站必须能从当前 VPS 正常访问，并支持 TLS 1.3、证书与 SNI 匹配
- 示例使用 dl.google.com，但不同 VPS 线路的可用性可能不同，不能机械照抄
- 如果客户端反复出现 REALITY authentication failed 或连接超时，应先检查 SNI、密钥和 Short ID，再更换一个从 VPS 实测可访问的目标站
- uTLS 用 chrome 就够了，不建议乱改
- spiderX 保持简单即可，没必要过度设计

## 五、保存并重启核心

配置完成后保存入站，然后重启 Xray 核心。接着在入站列表中复制节点链接或二维码，导入客户端。

导入客户端后重点确认这几项：

- Security：reality
- Network：tcp / raw
- Flow：xtls-rprx-vision
- SNI：与你填写的伪装域名一致
- Public Key：服务端生成的公钥
- Short ID：与你分配的一致
- Fingerprint：chrome

## 六、为什么不把 XHTTP / ECH / 后量子当默认主力

这些技术并不差，但它们更适合进阶用户，而不是所有人的默认首选。

- XHTTP 参数空间更大，配置复杂度更高
- ECH 在部分网络环境下可用性仍不稳定
- 后量子签名会增加握手材料体积，提高排障难度
- 新特性常常要求更高版本的客户端和更完整的兼容链路

所以更现实的策略是：

- 主力节点：VLESS + TCP(RAW) + REALITY + Vision
- 实验节点：XHTTP + REALITY 或 TLS + ECH
- 不要让实验方案直接替代主力方案

## FAQ

**1. 现在最稳的方案到底是不是 VLESS + TCP + REALITY + Vision？**

如果你的目标是"长期稳定、尽量少折腾、兼容尽可能广"，那么在这份 2026 年 8 月版教程中，它依然是稳妥的默认基线。

**2. TCP 和 RAW 有什么区别？**

没有本质区别。新版 Xray 文档把原来的 TCP 主名改成了 RAW，旧写法仍兼容。

**3. Flow 为什么必须开 xtls-rprx-vision？**

因为 Vision 才是这套稳定派方案的核心之一。不开它，你得到的只是普通 VLESS + REALITY，而不是默认推荐的 Vision 组合。

**4. spiderX 一定要精细配置吗？**

不一定。日常求稳可以直接留空或写 `/`。对大多数用户来说，这不是决定节点生死的关键项。

**5. 要不要直接上 XHTTP + REALITY + 后量子？**

如果你追求的是实验性增强和进阶玩法，可以单独开一条测试节点；如果你追求的是主力稳定性，不建议它直接取代 TCP(RAW) + REALITY + Vision。

## 结尾总结

在 2026 年 8 月版教程中，如果只看"长期稳定、少踩坑、兼容更广"这三个指标，那么值得作为默认基线的仍然是：

```
VLESS + TCP(RAW) + REALITY + xtls-rprx-vision
```

真正适合长期使用的节点，核心不是参数有多新，而是链路足够干净、变量足够少、客户端足够好适配。在今天这个阶段，大道至简，仍然是最稳的答案。

---

> 本文整理自：https://sky9119.cc/2026/07/30/2026-august-debian-vless-tcp-raw-reality-vision/
