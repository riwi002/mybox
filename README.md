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
| 2 | **日常维护** | 系统更新、软件包清理、缓存清理等 |
| 3 | **安装环境** | 常用系统工具安装、环境配置等 |
| 4 | **GitHub管理器** | Git仓库管理、分支操作、提交推送等 |
| 5 | **GitHooks部署** | 自动部署常用 Git Hooks 到指定仓库 |
| 6 | **Docker管理** | Docker容器管理、镜像管理、网络配置等 |
| 7 | **LDNMP建站** | LDNMP环境搭建、网站部署、反向代理等 |
| 8 | **应用市场** | 常用应用一键安装部署 |
| 9 | **后台工作区** | 后台任务管理、定时任务配置等 |
| 10 | **系统工具** | 系统配置、优化工具等 |
| 11 | **服务器集群控制** | 多服务器统一管理 |
| 12 | **安全优化** | 防火墙配置、安全加固、DDoS防护等 |
| 13 | **热门专栏** | 推广信息展示 |

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

### GitHooks部署详细功能

GitHooks部署模块提供 Git Hooks 自动部署功能，支持以下常用 Hooks：

1. **pre-commit** - 提交前自动检查（尾随空格、大文件警告、console.log检查）
2. **post-merge** - 合并后自动更新依赖（自动检测 npm/yarn/pip/composer/go/cargo）
3. **pre-push** - 推送前运行测试（自动检测测试框架并运行）
4. **post-receive** - 接收推送后自动部署（用于服务器端裸仓库）
5. **commit-msg** - 提交信息格式检查（约定式提交格式）
6. **一键安装所有 Hooks** - 批量部署上述5个常用 Hooks
7. **查看已安装的 Hooks** - 列出当前仓库的所有自定义 hooks
8. **删除指定 Hook** - 删除不需要的 hook

**使用方式**：
1. 运行脚本 `r` 启动
2. 选择 `5` 进入 GitHooks 部署
3. 输入 git 仓库路径（回车使用当前路径）
4. 选择要部署的 hook 类型

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
主菜单 -> 6. Docker管理
```

#### 6. 部署 GitHooks
```
主菜单 -> 5. GitHooks部署 -> 6. 一键安装所有 Hooks
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

### v1.1 (2026-06-06)
- ✅ 新增 GitHooks 部署功能（自动部署常用 Git Hooks）
- ✅ 主菜单优化：2.更新清理 → 日常维护，3.基础工具 → 安装环境
- ✅ 优化菜单高亮显示和提示信息
- ✅ 修复 GitHub 管理器推送超时问题

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

- **GitHub**: [https://github.com/riwi002/mybox](https://github.com/riwi002/mybox)
- **Email**: riwi001@pm.me

---

**最后更新**: 2026-06-06

**版本**: v1.1
