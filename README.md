# Riou脚本工具箱

[![GitHub](https://img.shields.io/badge/GitHub-riwi--scripts-black?logo=github)](https://github.com/yourusername/riwi-scripts)
[![Bash](https://img.shields.io/badge/Shell-Bash-green?logo=gnu-bash)](https://www.gnu.org/software/bash/)
[![License](https://img.shields.io/badge/License-MIT-blue)](LICENSE)

## 📝 项目简介

**Riou脚本工具箱** 是一个综合性的 Linux 服务器管理脚本集合，旨在简化服务器运维工作。本脚本箱包含了系统查询、Docker管理、LDNMP建站、应用部署、安全优化等多种实用功能，帮助用户快速完成服务器配置和管理任务。

> **⚠️ 重要说明**：此脚本为个人使用而创建，主要用于方便自己日常服务器管理工作，避免重复编写代码。脚本功能根据个人需求定制，可能存在未完善之处，请谨慎用于生产环境。

---

## 🎯 主要功能

### 主菜单功能列表

| 序号 | 功能模块 | 说明 |
|------|---------|------|
| 1 | **系统查询** | 查看系统信息、资源使用情况、网络状态等 |
| 2 | **更新清理** | 系统更新、软件包清理、缓存清理等 |
| 3 | **基础工具** | 常用系统工具集合 |
| 4 | **GitHub管理器** | Git仓库管理、分支操作、提交推送等 |
| 5 | **Docker管理** | Docker容器管理、镜像管理、网络配置等 |
| 6 | **LDNMP建站** | LDNMP环境搭建、网站部署、反向代理等 |
| 7 | **应用市场** | 常用应用一键安装部署 |
| 8 | **后台工作区** | 后台任务管理、定时任务配置等 |
| 9 | **系统工具** | 系统配置、优化工具等 |
| 10 | **服务器集群控制** | 多服务器统一管理 |
| 11 | **安全优化** | 防火墙配置、安全加固、DDoS防护等 |
| 12 | **广告专栏** | 推广信息展示 |

### LDNMP建站详细功能

LDNMP建站模块提供以下15项功能：

1. **安装LDNMP环境** - 一键安装 Linux + Docker + Nginx + MySQL + PHP 环境
2. **安装Typecho轻量博客** - 快速部署 Typecho 博客系统
3. **仅安装Nginx** - 单独安装 Nginx Web 服务器
4. **Nginx管理** - Nginx服务管理、配置测试、日志查看等
5. **站点数据管理** - 查看、管理、备份网站数据
6. **定时远程备份** - 配置定时远程备份任务
7. **防护LDNMP环境** - 安全加固、fail2ban配置等
8. **更新LDNMP环境** - 更新 Docker 镜像和容器
9. **优化LDNMP环境** - Gzip、Brotli、缓存优化等
10. **还原全站数据** - 从备份恢复全站数据
11. **自定义静态站点** - 创建自定义静态网站
12. **站点反向代理-负载均衡** - 配置负载均衡反向代理
13. **站点反向代理+域名** - 配置域名反向代理
14. **站点重定向** - 配置 301/302 重定向规则
15. **站点反向代理+IP+端口** - 配置 IP+端口 反向代理

---

## 📁 项目结构

```
riwi-scripts/
├── riwi.sh                 # 主脚本文件（核心功能）
├── test_ldnmp.sh          # LDNMP测试脚本
├── tools/                  # 工具脚本目录
│   ├── CF-Under-Attack.sh           # Cloudflare Under Attack 模式配置
│   ├── Limiting_Shut_down.sh       # 限流关机脚本
│   ├── Limiting_Shut_down1.sh      # 限流关机脚本（备用）
│   ├── TG-SSH-check-notify.sh      # Telegram SSH登录通知
│   ├── TG-check-notify.sh          # Telegram 检查通知
│   ├── auto_cert_renewal.sh        # SSL证书自动续期
│   ├── beifen.sh                   # 备份脚本
│   ├── hermes_manager.sh          # Hermes 管理脚本
│   ├── network-optimize.sh        # 网络优化脚本
│   └── upgrade_openssh9.8p1.sh  # OpenSSH 9.8p1 升级脚本
├── .git/                   # Git仓库目录
├── .workbuddy/            # WorkBuddy配置目录
└── README.md              # 本文件
```

---

## 🚀 快速开始

### 系统要求

- **操作系统**: Linux (推荐 Ubuntu/Debian/CentOS)
- **权限要求**: root 或具有 sudo 权限的用户
- **依赖软件**: bash, curl, wget, git

### 安装使用

1. **下载脚本**
   ```bash
   git clone https://github.com/riwi002/mybox.git
   ```

2. **赋予执行权限**
   ```bash
   chmod +x riwi.sh
   ```

3. **运行脚本**
   ```bash
   bash riwi.sh
   ```
   
   或者创建快捷命令：
   ```bash
   echo "alias r='bash /path/to/riwi.sh'" >> ~/.bashrc
   source ~/.bashrc
   # 之后可以直接输入 r 启动脚本
   ```

---

## 📖 使用说明

### 主菜单操作

- 输入对应数字选择功能模块
- 输入 `0` 退出脚本
- 在子菜单中，输入 `0` 返回上级菜单
- 直接按回车执行默认操作（通常是返回）

### 常用功能示例

#### 1. 查看系统信息
```
主菜单 -> 1. 系统查询
```

#### 2. 安装 LDNMP 环境
```
主菜单 -> 6. LDNMP建站 -> 1. 安装LDNMP环境
```

#### 3. 部署 Typecho 博客
```
主菜单 -> 6. LDNMP建站 -> 2. 安装Typecho轻量博客
```

#### 4. 配置反向代理
```
主菜单 -> 6. LDNMP建站 -> 15. 站点反向代理+IP+端口
```

#### 5. 管理 Docker 容器
```
主菜单 -> 5. Docker管理
```

---

## 🔧 技术栈

- **Shell脚本**: Bash
- **容器化**: Docker, Docker Compose
- **Web服务**: Nginx
- **数据库**: MySQL/MariaDB
- **后端**: PHP
- **版本控制**: Git
- **安全**: fail2ban, iptables
- **SSL**: Let's Encrypt (certbot)

---

## ⚠️ 免责声明

1. **个人使用**: 本脚本为个人学习和工作需要而创建，主要用于提高个人工作效率。
2. **风险自负**: 使用本脚本前请做好数据备份，因使用本脚本导致的任何数据丢失、系统损坏等问题，作者不承担任何责任。
3. **生产环境**: 不建议直接用于生产环境，使用前请充分测试。
4. **代码质量**: 脚本代码主要为实现功能而编写，可能存在优化空间，欢迎提出建议。

---

## 📝 更新日志

### v1.0 (2026-06-04)
- ✅ 初始版本发布
- ✅ 完善 LDNMP 建站功能
- ✅ 添加 Nginx 管理功能
- ✅ 优化菜单结构和用户体验

---

## 🤝 贡献指南

由于本脚本主要为个人使用，暂不接受 Pull Request。但如果您有好的建议或发现了 bug，欢迎通过 Issue 提出。

---

## 📄 许可证

本项目采用 MIT 许可证。详见 [LICENSE](LICENSE) 文件。

---

## 🙏 致谢

感谢所有开源项目和技术社区的支持。

---

## 📧 联系方式

- **GitHub**: [yourusername](https://github.com/yourusername)
- **Email**: your-email@example.com

---

**最后更新**: 2026-06-04

**版本**: v1.0
