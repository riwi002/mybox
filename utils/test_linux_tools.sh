#!/bin/bash

# 导入原脚本中的变量定义
gl_huang='\033[33m'
gl_bai='\033[0m'
riwi001='\033[96m'
sh_v="4.5.1"

# 导入 install 函数（简化版本）
install() {
  if [ $# -eq 0 ]; then
    echo "未提供软件包参数!"
    return 1
  fi

  for package in "$@"; do
    if ! command -v "$package" &>/dev/null; then
      echo -e "${riwi001}正在安装 $package...${gl_bai}"
      if command -v apt >/dev/null 2>&1; then
        echo "这是一个测试环境，不会实际安装软件包"
      elif command -v dnf >/dev/null 2>&1; then
        echo "这是一个测试环境，不会实际安装软件包"
      elif command -v yum >/dev/null 2>&1; then
        echo "这是一个测试环境，不会实际安装软件包"
      elif command -v pacman >/dev/null 2>&1; then
        echo "这是一个测试环境，不会实际安装软件包"
      elif command -v apk >/dev/null 2>&1; then
        echo "这是一个测试环境，不会实际安装软件包"
      elif command -v zypper >/dev/null 2>&1; then
        echo "这是一个测试环境，不会实际安装软件包"
      elif command -v opkg >/dev/null 2>&1; then
        echo "这是一个测试环境，不会实际安装软件包"
      elif command -v pkg >/dev/null 2>&1; then
        echo "这是一个测试环境，不会实际安装软件包"
      else
        echo "未知的包管理器!"
        return 1
      fi
    fi
  done
}

# 导入 send_stats 函数（简化版本）
send_stats() {
  echo "send_stats called with: $1"
}

# 从原脚本中复制 linux_tools 函数
linux_tools() {

  while true; do
	  clear
	  # send_stats "基础工具"
	  echo -e "基础工具"

	  tools=(
		curl wget sudo socat htop iftop unzip tar tmux ffmpeg
		btop ranger ncdu fzf cmatrix sl bastet nsnake ninvaders
		vim nano git
	  )

	  if command -v apt >/dev/null 2>&1; then
		PM="apt"
	  elif command -v dnf >/dev/null 2>&1; then
		PM="dnf"
	  elif command -v yum >/dev/null 2>&1; then
		PM="yum"
	  elif command -v pacman >/dev/null 2>&1; then
		PM="pacman"
	  elif command -v apk >/dev/null 2>&1; then
		PM="apk"
	  elif command -v zypper >/dev/null 2>&1; then
		PM="zypper"
	  elif command -v opkg >/dev/null 2>&1; then
		PM="opkg"
	  elif command -v pkg >/dev/null 2>&1; then
		PM="pkg"
	  else
		echo "❌ 未识别的包管理器"
		exit 1
	  fi

	  echo "📦 使用包管理器: $PM"
	  echo -e "${riwi001}------------------------${gl_bai}"

	  for ((i=0; i<${#tools[@]}; i+=2)); do
		# 左列
		if command -v "${tools[i]}" >/dev/null 2>&1; then
		  left=$(printf "✅ %-12s 已安装" "${tools[i]}")
		else
		  left=$(printf "❌ %-12s 未安装" "${tools[i]}")
		fi

		# 右列（防止数组越界）
		if [[ -n "${tools[i+1]}" ]]; then
		  if command -v "${tools[i+1]}" >/dev/null 2>&1; then
			right=$(printf "✅ %-12s 已安装" "${tools[i+1]}")
		  else
			right=$(printf "❌ %-12s 未安装" "${tools[i+1]}")
		  fi
		  printf "%-42s %s\n" "$left" "$right"
		else
		  printf "%s\n" "$left"
		fi
	  done

	  echo -e "${riwi001}------------------------"
	  echo -e "${riwi001}1.   ${gl_bai}curl 下载工具 ${gl_huang}★${gl_bai}                   ${riwi001}2.   ${gl_bai}wget 下载工具 ${gl_huang}★${gl_bai}"
	  echo -e "${riwi001}3.   ${gl_bai}sudo 超级管理权限工具             ${riwi001}4.   ${gl_bai}socat 通信连接工具"
	  echo -e "${riwi001}5.   ${gl_bai}htop 系统监控工具                 ${riwi001}6.   ${gl_bai}iftop 网络流量监控工具"
	  echo -e "${riwi001}7.   ${gl_bai}unzip ZIP压缩解压工具             ${riwi001}8.   ${gl_bai}tar GZ压缩解压工具"
	  echo -e "${riwi001}9.   ${gl_bai}tmux 多路后台运行工具             ${riwi001}10.  ${gl_bai}ffmpeg 视频编码直播推流工具"
	  echo -e "${riwi001}------------------------"
	  echo -e "${riwi001}11.  ${gl_bai}btop 现代化监控工具 ${gl_huang}★${gl_bai}             ${riwi001}12.  ${gl_bai}ranger 文件管理工具"
	  echo -e "${riwi001}13.  ${gl_bai}ncdu 磁盘占用查看工具             ${riwi001}14.  ${gl_bai}fzf 全局搜索工具"
	  echo -e "${riwi001}15.  ${gl_bai}vim 文本编辑器                    ${riwi001}16.  ${gl_bai}nano 文本编辑器 ${gl_huang}★${gl_bai}"
	  echo -e "${riwi001}17.  ${gl_bai}git 版本控制系统                  ${riwi001}18.  ${gl_bai}opencode AI编程助手 ${gl_huang}★${gl_bai}"
	  echo -e "${riwi001}------------------------"
	  echo -e "${riwi001}21.  ${gl_bai}黑客帝国屏保                      ${riwi001}22.  ${gl_bai}跑火车屏保"
	  echo -e "${riwi001}26.  ${gl_bai}俄罗斯方块小游戏                  ${riwi001}27.  ${gl_bai}贪吃蛇小游戏"
	  echo -e "${riwi001}28.  ${gl_bai}太空入侵者小游戏"
	  echo -e "${riwi001}------------------------"
	  echo -e "${riwi001}31.  ${gl_bai}全部安装                          ${riwi001}32.  ${gl_bai}全部安装（不含屏保和游戏）${gl_huang}★${gl_bai}"
	  echo -e "${riwi001}33.  ${gl_bai}全部卸载"
	  echo -e "${riwi001}------------------------"
	  echo -e "${riwi001}41.  ${gl_bai}安装指定工具                      ${riwi001}42.  ${gl_bai}卸载指定工具"
	  echo -e "${riwi001}------------------------"
	  echo -e "${riwi001}0.   ${gl_bai}返回主菜单"
	  echo -e "${riwi001}------------------------${gl_bai}"
	  
	  # 非交互模式：直接显示菜单后退出
	  echo "这是测试模式，不会进入交互选择"
	  break
  done
}

# 运行 linux_tools 函数
echo "开始测试 linux_tools 函数..."
echo "=================================="
linux_tools
echo "=================================="
echo "测试完成！"
