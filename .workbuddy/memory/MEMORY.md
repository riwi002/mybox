# 项目记忆 - riwi.sh 脚本工具箱

## 项目概述
- riwi.sh 是一个多功能 Linux 服务器管理脚本（Riou脚本工具箱）
- 当前主文件 ~27146 行（2026-06-26），包含 304 个函数定义
- 部署目标: Linux 服务器（莱卡云/腾讯云）；本地开发用 macOS
- 用户 Owen 通过非 root 用户 (xin) SSH 登录，su/sudo 切 root 运行脚本

## 当前主菜单结构 (2026-06-26)
1.系统查询 linux_info / 2.日常运维 update_clean_menu /
3.环境配置 linux_tools / 4.版本控制 github_manager /
5.应用市场 linux_panel / 6.常用快捷工具 linux_quick_tools /
7.综合管理 other_panel_manager / 8.后台工作 linux_work /
9.容器管理 docker_manager_menu / 10.建站部署 ldnmp_builder_menu /
11.集群控制 linux_cluster / 12.密钥管理 user_manager

## 文件结构
- riwi.sh: 主入口（含所有函数 + riwi_sh菜单 + CLI入口）
- riwi.sh.bak_*: 各次重大修改前的备份（按日期_主题命名）
- tools/: 10个git原始工具脚本（CF-Under-Attack.sh 等）

## 函数扫描方法（重要）
- 用 `^([a-z_]+)\(\)\s*\{` 多行锚点可识别**顶层**函数
- 但 Bash 允许**嵌套函数**定义在父函数内（如 moltbot_menu 内的
  start_gateway、openclaw_* 等），扫描时会被漏掉，这是正常的
- 验证主菜单调用是否齐全：用 Python 对比 `defined` 和 `\d+\)\s+(\w+)\s+;;`
- **函数边界检测绝不能用大括号计数** `{}`，heredoc/string 里的 `{` 会干扰
  → 必须用"查找下一个 `^funcname() {` 顶层定义"作为边界锚点

## 颜色变量约定
- rw_cheng(橙) / rw_lv(绿/重置) / rw_huang(黄) / rw_hong(红)
- 在 macOS bash 3.x 上 rw_cheng 的 256色 ANSI 码可能不兼容，留意

## 注意事项
- source 语句使用 `source "$(dirname "$0")/tools/XXX.sh"` 格式
- 函数名保持原始英文名（未做拼音重命名）
- git 原始 tools/ 文件与新模块有少量函数重名（独立脚本，正常）
- 所有交互 read 用 `< /dev/tty` 读入，避免被管道吞掉
- Owen 偏好：精简菜单、实用功能、紧急救援能力
