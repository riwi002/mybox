#!/bin/bash

# 只定义必要的变量
gl_huang='\033[33m'
gl_bai='\033[0m'
riwi001='\033[96m'

# 直接测试 linux_tools 函数的核心逻辑
echo "=== 测试 linux_tools 函数的核心逻辑 ==="

tools=(
  curl wget sudo socat htop iftop unzip tar tmux ffmpeg
  btop ranger ncdu fzf cmatrix sl bastet nsnake ninvaders
  vim nano git
)

echo "检测包管理器..."
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
elif command -v brew >/dev/null 2>&1; then
  PM="brew (macOS Homebrew)"
else
  echo "❌ 未识别的包管理器"
  PM="unknown"
fi

echo "📦 检测到的包管理器: $PM"
echo ""

echo "检查工具安装状态..."
for tool in "${tools[@]}"; do
  if command -v "$tool" >/dev/null 2>&1; then
    echo "✅ $tool - 已安装"
  else
    echo "❌ $tool - 未安装"
  fi
done

echo ""
echo "=== 测试完成 ==="
