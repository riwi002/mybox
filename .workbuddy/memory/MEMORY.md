# 项目记忆 - riwi.sh 脚本工具箱

## 项目概述
- riwi.sh 是一个多功能 Linux 服务器管理脚本（Riou脚本工具箱）
- 原始文件 23492 行，包含 245 个函数定义
- 已完成功能分离重构：riwi.sh 精简到 416 行，所有函数提取到 tools/ 目录

## 重构方法
- 用 `grep -n '^[a-z_]*()'` 定位函数起始行
- 函数边界 = 当前函数起始行 到 下一函数起始行-1
- 避免使用 Python 大括号计数（在处理 heredoc/string 中的 `{}` 时不可靠）
- 最后一个函数 k_info() 结束于 23215 行，CLI 入口从 23219 行开始

## 文件结构
- riwi.sh: 主入口（头部配置 + source语句 + riwi_sh菜单 + CLI入口）
- riwi.sh.bak_final: 原始完整备份
- tools/: 25个功能模块 + 10个git原始工具脚本

## 注意事项
- source 语句使用 `source "$(dirname "$0")/tools/XXX.sh"` 格式
- 函数名保持原始英文名（未做拼音重命名）
- git 原始 tools/ 文件（CF-Under-Attack.sh 等）与新模块文件有少量函数重名（正常，它们是独立脚本）
