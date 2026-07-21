#!/bin/bash
# ================================================================
# Riou 脚本工具箱 - 多功能 Linux 服务器管理脚本
# 版本: 1.0.0
# 作者: Riou Team
# 项目地址: https://github.com/riwi/sh
# ================================================================
# 
# 【功能说明】
# - Docker 全管理（容器/镜像/Compose/备份/迁移/安装/升级/Shell/监控）
# - LNMP 建站环境（Nginx + PHP + MySQL + Redis）
# - 系统工具（系统更新、清理、信息查看）
# - 网络工具（端口管理、防火墙、DDOS 防护）
# - 安全功能（密码保护、SSL 证书）
# - 应用市场（一键部署 30+ 应用）
# 
# 【使用方法】
# - 直接运行: ./riwi.sh
# - 全局命令: r （安装后可用）
# - 查看帮助: r help
# 
# ================================================================

sh_v="1.0.0"

# ================================================================
# 颜色定义 - 终端输出美化（4色方案：红/绿/黄/蓝）
# ================================================================
# 设计理念：使用4个基础ANSI颜色，简洁统一
#   - 黄色 rw_huang：序号数字、标题、高亮、星标★
#   - 绿色 rw_lv  ：中文文字（菜单项）、成功消息
#   - 蓝色 rw_lan ：分隔线、装饰线
#   - 红色 rw_hong：错误消息、警告
# ================================================================
rw_hong='\033[31m\033[01m'  # 红色 - 错误消息/警告
rw_lv='\033[32m\033[01m'    # 绿色 - 中文文字/成功消息
rw_huang='\033[33m\033[01m'  # 黄色 - 序号数字/标题/高亮/星标
rw_lan='\033[34m\033[01m'   # 蓝色 - 分隔线/装饰线
rw_bai='\033[0m'            # 重置 - 保持不变
rw_cheng='\033[38;5;208m\033[01m'  # 橙色 - 标题/高亮/星标
# ================================================================
# 彩色输出函数（快速调用）
# 用法：red "文本" / green "文本" / yellow "文本"
# ================================================================
red(){
    echo -e "\033[31m\033[01m$1\033[0m"
}
green(){
    echo -e "\033[32m\033[01m$1\033[0m"
}
yellow(){
    echo -e "\033[33m\033[01m$1\033[0m"
}
blue(){
    echo -e "\033[34m\033[01m$1\033[0m"
}
orange(){
    echo -e "\033[38;5;208m\033[01m$1\033[0m" 
}
# ================================================================

# ================================================================
# 全局配置变量
# ================================================================
# canshu: 语言/地区配置
#   - "CN": 中国大陆（使用 gh.riwi.pro 代理加速）
#   - "V6": IPv6 优先模式
#   - 其他: 国际版（直接访问 GitHub）
# permission_granted: 用户许可协议状态
#   - "true": 已同意协议
#   - "false": 未同意协议
# ENABLE_STATS: 匿名统计开关
#   - "true": 启用统计（帮助优化功能）
#   - "false": 禁用统计
# ================================================================
canshu="CN"
permission_granted="false"
ENABLE_STATS="true"


quanju_canshu() {
if [ "$canshu" = "CN" ]; then
	zhushi=0
	gh_proxy="https://gh.riwi.pro/"
elif [ "$canshu" = "V6" ]; then
	zhushi=1
	gh_proxy="https://gh.riwi.pro/"
else
	zhushi=1  # 0 表示执行，1 表示不执行
	gh_proxy="https://"
fi

gh_https_url="https://"

}
quanju_canshu



# 定义一个函数来执行命令
run_command() {
	if [ "$zhushi" -eq 0 ]; then
		"$@"
	fi
}


canshu_v6() {
	if grep -q '^canshu="V6"' /usr/local/bin/r > /dev/null 2>&1; then
		sed -i 's/^canshu="default"/canshu="V6"/' ~/riwi.sh
	elif grep -q '^canshu="V6"' ~/riwi.sh.bak > /dev/null 2>&1; then
		sed -i 's/^canshu="default"/canshu="V6"/' ~/riwi.sh
	fi
}


CheckFirstRun_true() {
	if grep -q '^permission_granted="true"' /usr/local/bin/r > /dev/null 2>&1; then
		sed -i 's/^permission_granted="false"/permission_granted="true"/' ~/riwi.sh
	elif grep -q '^permission_granted="true"' ~/riwi.sh.bak > /dev/null 2>&1; then
		sed -i 's/^permission_granted="false"/permission_granted="true"/' ~/riwi.sh
	fi
}



# 收集功能埋点信息的函数，记录当前脚本版本号，使用时间，系统版本，CPU架构，机器所在国家和用户使用的功能名称，绝对不涉及任何敏感信息，请放心！请相信我！
# 为什么要设计这个功能，目的更好的了解用户喜欢使用的功能，进一步优化功能推出更多符合用户需求的功能。
# 全文可搜搜 send_stats 函数调用位置，透明开源，如有顾虑可拒绝使用。



send_stats() {
	if [ "$ENABLE_STATS" == "false" ]; then
		return
	fi

	(
		local country=$(curl -s --max-time 3 ipinfo.io/country 2>/dev/null || echo "Unknown")
		local os_info=""
		if [ -f /etc/os-release ]; then
			os_info=$(grep PRETTY_NAME /etc/os-release | cut -d '=' -f2 | tr -d '"')
		else
			os_info=$(sw_vers -productName 2>/dev/null || echo "Unknown")
		fi
		local cpu_arch=$(uname -m)

		curl -s -X POST "https://api.riwi.pro/api/log" \
			-H "Content-Type: application/json" \
			-d "{\"action\":\"$1\",\"timestamp\":\"$(date -u '+%Y-%m-%d %H:%M:%S')\",\"country\":\"$country\",\"os_info\":\"$os_info\",\"cpu_arch\":\"$cpu_arch\",\"version\":\"$sh_v\"}" \
			&>/dev/null
	) &

}


yinsiyuanquan2() {

if grep -q '^ENABLE_STATS="false"' /usr/local/bin/r > /dev/null 2>&1; then
	sed -i 's/^ENABLE_STATS="true"/ENABLE_STATS="false"/' ~/riwi.sh
elif grep -q '^ENABLE_STATS="false"' ~/riwi.sh.bak > /dev/null 2>&1; then
	sed -i 's/^ENABLE_STATS="true"/ENABLE_STATS="false"/' ~/riwi.sh
fi

}



canshu_v6
CheckFirstRun_true
yinsiyuanquan2


sed -i '/^alias k=/d' ~/.bashrc > /dev/null 2>&1
sed -i '/^alias k=/d' ~/.profile > /dev/null 2>&1
sed -i '/^alias k=/d' ~/.bash_profile > /dev/null 2>&1
cp -f ./riwi.sh ~/riwi.sh > /dev/null 2>&1
cp -f ~/riwi.sh /usr/local/bin/r > /dev/null 2>&1
ln -sf /usr/local/bin/r /usr/bin/r > /dev/null 2>&1



# ================================================================
# 首次运行检查函数
# ================================================================
# 功能: 检测用户是否已同意许可协议，未同意则展示协议
# 参数: 无
# 返回: 无
# ================================================================
CheckFirstRun_false() {
	if grep -q '^permission_granted="false"' /usr/local/bin/r > /dev/null 2>&1; then
		UserLicenseAgreement
	fi
}

# ================================================================
# 用户许可协议展示函数
# ================================================================
# 功能: 首次使用时展示用户许可协议，获取用户同意
# 参数: 无
# 返回: 无（用户同意后继续，不同意则退出）
# 流程:
#   1. 展示欢迎信息和协议链接
#   2. 询问用户是否同意
#   3. 同意则更新配置并继续，不同意则退出
# ================================================================
# 提示用户同意条款
UserLicenseAgreement() {
	clear
	echo -e "${rw_huang}欢迎使用Riou脚本工具箱${rw_lv}"
	echo "首次使用脚本，请先阅读并同意用户许可协议。"
	echo "用户许可协议: https://github.com/riwi002/mybox/blob/main/LICENSE"
	echo -e "----------------------"
	read -e -p "是否同意以上条款？(y/n): " user_input


	if [ "$user_input" = "y" ] || [ "$user_input" = "Y" ]; then
		send_stats "许可同意"
		sed -i 's/^permission_granted="false"/permission_granted="true"/' ~/riwi.sh
		sed -i 's/^permission_granted="false"/permission_granted="true"/' /usr/local/bin/r
	else
		send_stats "许可拒绝"
		clear
		exit
	fi
}

# CheckFirstRun_false  # 已改用 riwi_sh() 内的 ~/.riwi_license_agreed 机制


# ================================================================
# 密码保护模块 - 开始
# ================================================================

# ================================================================
# 密码保护配置
# ================================================================
# PASSWORD_FILE: 密码哈希存储文件
# SALT_FILE: 随机盐值存储文件
# PASSWORD_TIMESTAMP_FILE: 免密时间戳存储文件
# ENABLE_PASSWORD_PROTECTION: 密码保护开关（true/false）
# PASSWORD_TIMEOUT_MINUTES: 免密时长（分钟），0=每次都要密码
# ================================================================
PASSWORD_FILE="$HOME/.riwi_password"
SALT_FILE="$HOME/.riwi_salt"
PASSWORD_TIMESTAMP_FILE="$HOME/.riwi_password_timestamp"
ENABLE_PASSWORD_PROTECTION="false"
PASSWORD_TIMEOUT_MINUTES=30

# ================================================================
# 随机盐值生成函数
# ================================================================
# 功能: 生成随机盐值用于密码加密
# 参数: 无
# 返回: 随机盐值字符串
# 方法: 优先使用 openssl，其次使用 /dev/urandom，降级使用时间戳
# ================================================================
# 生成随机盐值
generate_salt() {
  openssl rand -base64 16 2>/dev/null || head -c 16 /dev/urandom 2>/dev/null | base64 || echo "static_salt_$(date +%s)"
}

# ================================================================
# 密码设置函数（首次使用）
# ================================================================
# 功能: 引导用户设置访问密码
# 参数: 无
# 返回: 无
# 密码要求:
#   - 至少 8 位
#   - 包含大写字母
#   - 包含小写字母
#   - 包含数字
# 流程:
#   1. 展示设置界面
#   2. 获取用户输入并验证强度
#   3. 生成随机盐值并保存
#   4. 使用 SHA-512 + Salt 哈希密码
#   5. 保存密码哈希
# ================================================================
# 设置密码（首次使用）
set_password() {
  clear
  echo -e "${rw_hong}╔════════════════════════════════════════╗${rw_lv}"
  echo -e "${rw_hong}║   ${rw_huang}首次使用 - 设置访问密码${rw_hong}              ║${rw_lv}"
  echo -e "${rw_hong}╚════════════════════════════════════════╝${rw_lv}"
  echo ""
  
  while true; do
    echo -e "${rw_huang}请设置访问密码（至少8位，包含大小写字母和数字）${rw_lv}"
    read -s -p "输入密码: " password1
    echo ""
    read -s -p "确认密码: " password2
    echo ""
    
    # 验证密码强度
    if [ ${#password1} -lt 8 ]; then
      echo -e "${rw_hong}错误：密码长度至少需要8位${rw_lv}"
      continue
    fi
    
    if ! echo "$password1" | grep -q '[A-Z]' || ! echo "$password1" | grep -q '[a-z]' || ! echo "$password1" | grep -q '[0-9]'; then
      echo -e "${rw_hong}错误：密码需要包含大小写字母和数字${rw_lv}"
      continue
    fi
    
    if [ "$password1" != "$password2" ]; then
      echo -e "${rw_hong}错误：两次输入的密码不一致${rw_lv}"
      continue
    fi
    
    break
  done
  
  # 生成盐值并保存
  local salt=$(generate_salt)
  echo "$salt" > "$SALT_FILE"
  chmod 600 "$SALT_FILE" 2>/dev/null
  
  # 使用 SHA-512 + Salt 加密密码
  local hashed_password=$(echo -n "${password1}${salt}" | openssl dgst -sha512 -binary 2>/dev/null | base64 2>/dev/null)
  if [ -z "$hashed_password" ]; then
    hashed_password=$(echo -n "${password1}${salt}" | sha512sum 2>/dev/null | awk '{print $1}')
  fi
  echo "$hashed_password" > "$PASSWORD_FILE"
  chmod 600 "$PASSWORD_FILE" 2>/dev/null
  
  echo ""
  echo -e "${rw_lv}✓ 密码设置成功！${rw_lv}"
  echo -e "${rw_huang}请牢记您的密码${rw_lv}"
  echo ""
  sleep 2
}

# ================================================================
# 密码验证函数
# ================================================================
# 功能: 验证用户输入的密码是否正确
# 参数: 无
# 返回: 0=验证成功，1=验证失败
# 流程:
#   1. 检查密码保护是否启用
#   2. 检查密码文件是否存在，不存在则调用设置
#   3. 检查是否在免密时间范围内
#   4. 若不在免密期，则提示输入密码
#   5. 最多允许 3 次尝试
#   6. 验证成功则记录时间戳
# ================================================================
# 验证密码
verify_password() {
  # 检查是否启用密码保护
  if [ "$ENABLE_PASSWORD_PROTECTION" != "true" ]; then
    return 0
  fi
  
  # 检查密码文件是否存在
  if [ ! -f "$PASSWORD_FILE" ] || [ ! -f "$SALT_FILE" ]; then
    set_password
    return 0
  fi
  
  # 检查是否在免密时间范围内
  if [ -f "$PASSWORD_TIMESTAMP_FILE" ]; then
    local last_time=$(cat "$PASSWORD_TIMESTAMP_FILE" 2>/dev/null)
    local current_time=$(date +%s)
    local timeout_seconds=$((PASSWORD_TIMEOUT_MINUTES * 60))
    local time_diff=$((current_time - last_time))
    
    if [ "$time_diff" -lt "$timeout_seconds" ]; then
      # 在免密时间范围内
      local remaining_seconds=$((timeout_seconds - time_diff))
      local remaining_minutes=$((remaining_seconds / 60))
      if [ "$remaining_minutes" -gt 0 ]; then
        echo -e "${rw_lv}✓ 密码已在免密期内（还剩 ${remaining_minutes} 分钟）${rw_lv}"
      else
        echo -e "${rw_lv}✓ 密码已在免密期内${rw_lv}"
      fi
      sleep 1
      return 0
    fi
  fi
  
  local max_attempts=3
  local attempt=1
  
  while [ $attempt -le $max_attempts ]; do
    clear
    echo -e "${rw_huang}╔════════════════════════════════════════╗${rw_lv}"
    echo -e "${rw_huang}║   ${rw_huang}Riou脚本工具箱 - 身份验证${rw_lv}        ║${rw_lv}"
    echo -e "${rw_huang}╚════════════════════════════════════════╝${rw_lv}"
    echo ""
    echo -e "${rw_huang}尝试次数: $attempt / $max_attempts${rw_lv}"
    echo ""
    read -s -p "请输入访问密码: " input_password
    echo ""
    
    # 读取存储的盐值和哈希
    local stored_salt=$(cat "$SALT_FILE" 2>/dev/null)
    local stored_hash=$(cat "$PASSWORD_FILE" 2>/dev/null)
    
    # 计算输入密码的哈希
    local input_hash=$(echo -n "${input_password}${stored_salt}" | openssl dgst -sha512 -binary 2>/dev/null | base64 2>/dev/null)
    if [ -z "$input_hash" ]; then
      input_hash=$(echo -n "${input_password}${stored_salt}" | sha512sum 2>/dev/null | awk '{print $1}')
    fi
    
    # 验证密码
    if [ "$input_hash" = "$stored_hash" ]; then
      echo -e "${rw_lv}✓ 密码验证成功！${rw_lv}"
      # 记录当前时间戳
      date +%s > "$PASSWORD_TIMESTAMP_FILE"
      chmod 600 "$PASSWORD_TIMESTAMP_FILE" 2>/dev/null
      sleep 1
      return 0
    else
      echo -e "${rw_hong}✗ 密码错误${rw_lv}"
      attempt=$((attempt + 1))
      if [ $attempt -le $max_attempts ]; then
        sleep 1
      fi
    fi
  done
  
  # 达到最大尝试次数
  echo -e "${rw_hong}✗ 已达到最大尝试次数，访问被拒绝${rw_lv}"
  send_stats "密码验证失败_锁定" 2>/dev/null
  sleep 2
  exit 1
}



# ==================== 密码保护模块 - 结束 ====================

# ==================== 便携式 date 兼容函数 ====================
# 兼容 GNU date (Linux) 和 BSD date (macOS)
# 用法: portable_date "date_string" "+format"
# 示例: portable_date "2026-06-15" "+%Y-%m-%d"
portable_date() {
    local date_str="$1"
    local format="$2"
    
    # 尝试 GNU date (Linux)
    if date -d "$date_str" "$format" &>/dev/null; then
        date -d "$date_str" "$format" 2>/dev/null
        return $?
    fi
    
    # 尝试 BSD date (macOS)
    # 自动检测输入格式
    if echo "$date_str" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'; then
        # YYYY-MM-DD 格式
        date -j -f "%Y-%m-%d" "$date_str" "$format" 2>/dev/null
        return $?
    elif echo "$date_str" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$'; then
        # "YYYY-MM-DD HH:MM:SS" 格式
        date -j -f "%Y-%m-%d %H:%M:%S" "$date_str" "$format" 2>/dev/null
        return $?
    else
        # 尝试自动解析
        date -j -f "%Y-%m-%d %H:%M:%S" "$date_str" "$format" 2>/dev/null || \
        date -j -f "%a %b %d %H:%M:%S %Z %Y" "$date_str" "$format" 2>/dev/null || \
        echo "$date_str"
        return $?
    fi
}

# 转换为时间戳 (兼容 GNU 和 BSD)
# 用法: portable_date_to_timestamp "date_string"
portable_date_to_timestamp() {
    local date_str="$1"
    
    # 尝试 GNU date
    if date -d "$date_str" +%s &>/dev/null 2>&1; then
        date -d "$date_str" +%s 2>/dev/null
        return $?
    fi
    
    # 尝试 BSD date
    if echo "$date_str" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'; then
        date -j -f "%Y-%m-%d" "$date_str" +%s 2>/dev/null
        return $?
    elif echo "$date_str" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$'; then
        date -j -f "%Y-%m-%d %H:%M:%S" "$date_str" +%s 2>/dev/null
        return $?
    else
        # 当前时间戳作为回退
        date +%s 2>/dev/null || echo "$(date +%s)"
        return 1
    fi
}

# 获取文件修改时间 (兼容 Linux 和 macOS)
# 用法: portable_file_mtime "file_path" "+format"
portable_file_mtime() {
    local file_path="$1"
    local format="${2:-+%Y-%m-%d %H:%M:%S}"
    
    if [ ! -f "$file_path" ]; then
        echo "文件不存在"
        return 1
    fi
    
    # 尝试 Linux stat
    if command -v stat &>/dev/null && stat -c %y "$file_path" &>/dev/null 2>&1; then
        stat -c %y "$file_path" 2>/dev/null | awk '{print $1" "$2}' | sed 's/\..*//'
        return $?
    fi
    
    # 尝试 macOS stat
    if command -v stat &>/dev/null && stat -f %Sm "$file_path" &>/dev/null 2>&1; then
        stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$file_path" 2>/dev/null
        return $?
    fi
    
    # 回退到 ls
    ls -l "$file_path" 2>/dev/null | awk '{print $6" "$7" "$8}'
    return $?
}
# ==================== 便携式 date 兼容函数结束 ====================

# ==================== 状态缓存机制 ====================
# 避免每次菜单刷新都重新执行耗时的状态探测命令
# 缓存有效期：60 秒

_CACHE_TIMESTAMP=0
_CACHE_TTL=60  # 缓存有效期（秒）

# 缓存的状态值
_CACHE_SYSTEMCTL_AVAILABLE=false
_CACHE_FIREWALLD_ACTIVE=false
_CACHE_UFW_ACTIVE=false
_CACHE_SSHD_ACTIVE=false
_CACHE_FAIL2BAN_ACTIVE=false
_CACHE_DOCKER_ACTIVE=false
_CACHE_NGINX_ACTIVE=false
_CACHE_MYSQL_ACTIVE=false
_CACHE_PHP_ACTIVE=false
_CACHE_1PANEL_ACTIVE=false
_CACHE_COLIMA_ACTIVE=false
_CACHE_DOCKER_CONTAINER_RUNNING=0
_CACHE_DOCKER_CONTAINER_ALL=0
_CACHE_DOCKER_IMAGE_COUNT=0

# 检查缓存是否有效
_should_refresh_cache() {
    local current_time=$(date +%s 2>/dev/null || echo 0)
    local time_diff=$((current_time - _CACHE_TIMESTAMP))
    [ $_CACHE_TIMESTAMP -eq 0 ] || [ $time_diff -ge $_CACHE_TTL ]
}

# 刷新所有状态缓存
refresh_status_cache() {
    # 重置缓存
    _CACHE_SYSTEMCTL_AVAILABLE=false
    _CACHE_FIREWALLD_ACTIVE=false
    _CACHE_UFW_ACTIVE=false
    _CACHE_SSHD_ACTIVE=false
    _CACHE_FAIL2BAN_ACTIVE=false
    _CACHE_DOCKER_ACTIVE=false
    _CACHE_NGINX_ACTIVE=false
    _CACHE_MYSQL_ACTIVE=false
    _CACHE_PHP_ACTIVE=false
    _CACHE_1PANEL_ACTIVE=false
    _CACHE_COLIMA_ACTIVE=false
    _CACHE_DOCKER_CONTAINER_RUNNING=0
    _CACHE_DOCKER_CONTAINER_ALL=0
    _CACHE_DOCKER_IMAGE_COUNT=0

    # systemctl 可用性
    if command -v systemctl &>/dev/null; then
        _CACHE_SYSTEMCTL_AVAILABLE=true
        
        # 服务状态
        if systemctl is-active firewalld &>/dev/null; then
            _CACHE_FIREWALLD_ACTIVE=true
        fi
        
        if systemctl is-active ufw &>/dev/null; then
            _CACHE_UFW_ACTIVE=true
        fi
        
        if systemctl is-active sshd &>/dev/null || systemctl is-active ssh &>/dev/null; then
            _CACHE_SSHD_ACTIVE=true
        fi
        
        if systemctl is-active fail2ban &>/dev/null; then
            _CACHE_FAIL2BAN_ACTIVE=true
        fi
        
        if systemctl is-active docker &>/dev/null; then
            _CACHE_DOCKER_ACTIVE=true
        fi
        
        if systemctl is-active nginx &>/dev/null; then
            _CACHE_NGINX_ACTIVE=true
        fi
        
        if systemctl is-active mysql &>/dev/null || systemctl is-active mariadb &>/dev/null; then
            _CACHE_MYSQL_ACTIVE=true
        fi
        
        if systemctl is-active php-fpm &>/dev/null; then
            _CACHE_PHP_ACTIVE=true
        fi
        
        if systemctl is-active 1panel &>/dev/null; then
            _CACHE_1PANEL_ACTIVE=true
        fi
    fi
    
    # Docker 可用性（不依赖 systemctl）
    if pgrep dockerd &>/dev/null || timeout 5 docker ps &>/dev/null; then
        _CACHE_DOCKER_ACTIVE=true
        # 缓存容器数和镜像数（带超时保护）
        if _CACHE_DOCKER_ACTIVE; then
            _CACHE_DOCKER_CONTAINER_RUNNING=$(timeout 5 docker ps -q 2>/dev/null | wc -l | tr -d ' ' || echo 0)
            _CACHE_DOCKER_CONTAINER_ALL=$(timeout 5 docker ps -aq 2>/dev/null | wc -l | tr -d ' ' || echo 0)
            _CACHE_DOCKER_IMAGE_COUNT=$(timeout 5 docker images -q 2>/dev/null | wc -l | tr -d ' ' || echo 0)
        fi
    fi
    
    # 更新缓存时间戳
    _CACHE_TIMESTAMP=$(date +%s 2>/dev/null || echo 0)
}

# 初始化缓存（脚本加载时执行一次）
refresh_status_cache
# ==================== 状态缓存机制结束 ====================

# 执行密码验证
verify_password





ip_address() {

get_public_ip() {
	curl -s https://ipinfo.io/ip && echo
}

	get_local_ip() {
	ip route get 8.8.8.8 2>/dev/null | sed -n 's/.*src \([^ ]*\).*/\1/p' || \
	hostname -I 2>/dev/null | awk '{print $1}' || \
	ifconfig 2>/dev/null | grep -E 'inet [0-9]' | grep -v '127.0.0.1' | awk '{print $2}' | head -n1
}

public_ip=$(get_public_ip)
isp_info=$(curl -s --max-time 3 http://ipinfo.io/org)


if echo "$isp_info" | grep -Eiq 'CHINANET|mobile|unicom|telecom'; then
  ipv4_address=$(get_local_ip)
else
  ipv4_address="$public_ip"
fi


# ipv4_address=$(curl -s https://ipinfo.io/ip && echo)
ipv6_address=$(curl -s --max-time 1 https://v6.ipinfo.io/ip && echo)

}



install() {
	if [ $# -eq 0 ]; then
		echo "未提供软件包参数!"
		return 1
	fi

	# ── 确定 sudo 前缀：非 root 且有 sudo 权限时自动加 sudo ──
	local _sudo_pfx=""
	if [ "$EUID" -ne 0 ]; then
		if sudo -n true 2>/dev/null; then
			# 免密 sudo
			_sudo_pfx="sudo"
		elif getent group sudo 2>/dev/null | grep -qw "$(whoami)" || \
		     getent group wheel 2>/dev/null | grep -qw "$(whoami)"; then
			# 在 sudo/wheel 组里（需要密码），首次用 sudo -v 缓存
			sudo -v 2>/dev/null && _sudo_pfx="sudo"
		fi
	fi

	for package in "$@"; do
		if ! command -v "$package" &>/dev/null; then
			echo -e "${rw_huang}正在安装 $package...${rw_lv}"
			if command -v dnf &>/dev/null; then
				$_sudo_pfx dnf -y update
				$_sudo_pfx dnf install -y epel-release
				$_sudo_pfx dnf install -y "$package"
			elif command -v yum &>/dev/null; then
				$_sudo_pfx yum -y update
				$_sudo_pfx yum install -y epel-release
				$_sudo_pfx yum install -y "$package"
			elif command -v apt &>/dev/null; then
				$_sudo_pfx apt update -y
				$_sudo_pfx apt install -y "$package"
			elif command -v apk &>/dev/null; then
				$_sudo_pfx apk update
				$_sudo_pfx apk add "$package"
			elif command -v pacman &>/dev/null; then
				$_sudo_pfx pacman -Syu --noconfirm
				$_sudo_pfx pacman -S --noconfirm "$package"
			elif command -v zypper &>/dev/null; then
				$_sudo_pfx zypper refresh
				$_sudo_pfx zypper install -y "$package"
			elif command -v opkg &>/dev/null; then
				$_sudo_pfx opkg update
				$_sudo_pfx opkg install "$package"
			elif command -v pkg &>/dev/null; then
				$_sudo_pfx pkg update
				$_sudo_pfx pkg install -y "$package"
			else
				echo "未知的包管理器!"
				return 1
			fi
		fi
	done
}


check_disk_space() {
	local required_gb=$1
	local path=${2:-/}

	mkdir -p "$path"

	local required_space_mb=$((required_gb * 1024))
	local available_space_mb=$(df -m "$path" | awk 'NR==2 {print $4}')

	if [ "$available_space_mb" -lt "$required_space_mb" ]; then
		echo -e "${rw_huang}提示: ${rw_lv}磁盘空间不足！"
		echo "当前可用空间: $((available_space_mb/1024))G"
		echo "最小需求空间: ${required_gb}G"
		echo "无法继续安装，请清理磁盘空间后重试。"
		send_stats "磁盘空间不足"
		break_end
		riwi
	fi
}



install_dependency() {
	switch_mirror false false
	check_port
	check_swap
	prefer_ipv4
	auto_optimize_dns
	install wget unzip tar jq grep

}

remove() {
	if [ $# -eq 0 ]; then
		echo "未提供软件包参数!"
		return 1
	fi

	for package in "$@"; do
		echo -e "${rw_huang}正在卸载 $package...${rw_lv}"
		if command -v dnf &>/dev/null; then
			dnf remove -y "$package"
		elif command -v yum &>/dev/null; then
			yum remove -y "$package"
		elif command -v apt &>/dev/null; then
			apt purge -y "$package"
		elif command -v apk &>/dev/null; then
			apk del "$package"
		elif command -v pacman &>/dev/null; then
			pacman -Rns --noconfirm "$package"
		elif command -v zypper &>/dev/null; then
			zypper remove -y "$package"
		elif command -v opkg &>/dev/null; then
			opkg remove "$package"
		elif command -v pkg &>/dev/null; then
			pkg delete -y "$package"
		else
			echo "未知的包管理器!"
			return 1
		fi
	done
}


# 通用 systemctl 函数，适用于各种发行版
systemctl() {
	local COMMAND="$1"
	local SERVICE_NAME="$2"

	if command -v apk &>/dev/null; then
		service "$SERVICE_NAME" "$COMMAND"
	else
		/bin/systemctl "$COMMAND" "$SERVICE_NAME"
	fi
}


# 重启服务
restart() {
	systemctl restart "$1"
	if [ $? -eq 0 ]; then
		echo "$1 服务已重启。"
	else
		echo "错误：重启 $1 服务失败。"
	fi
}

# 启动服务
start() {
	systemctl start "$1"
	if [ $? -eq 0 ]; then
		echo "$1 服务已启动。"
	else
		echo "错误：启动 $1 服务失败。"
	fi
}

# 停止服务
stop() {
	systemctl stop "$1"
	if [ $? -eq 0 ]; then
		echo "$1 服务已停止。"
	else
		echo "错误：停止 $1 服务失败。"
	fi
}

# 查看服务状态
status() {
	systemctl status "$1"
	if [ $? -eq 0 ]; then
		echo "$1 服务状态已显示。"
	else
		echo "错误：无法显示 $1 服务状态。"
	fi
}


enable() {
	local SERVICE_NAME="$1"
	if command -v apk &>/dev/null; then
		rc-update add "$SERVICE_NAME" default
	else
	   /bin/systemctl enable "$SERVICE_NAME"
	fi

	echo "$SERVICE_NAME 已设置为开机自启。"
}



# 全局标记：子菜单选 0 返回时置 1，主菜单据此跳过"操作完成"提示
_menu_returning=0

break_end() {
	  # 如果是子菜单返回主菜单，不显示"操作完成"和"按任意键"
	  if [ "$_menu_returning" = "1" ]; then
		  _menu_returning=0
		  clear
		  return
	  fi
	  echo -e "${rw_lv}操作完成${rw_lv}"
	  echo "按任意键继续..."
	  read -n 1 -s -r -p ""
	  echo ""
	  clear
}

# 取消/返回时使用：不显示"操作完成"和"按任意键继续"，直接清屏返回菜单
break_cancel() {
	  clear
}

# 跨平台超时执行函数（兼容 Linux 和 macOS）
# 用法: run_with_timeout 60 command arg1 arg2 ...
run_with_timeout() {
	  local timeout_sec=$1
	  shift

	  if command -v timeout &>/dev/null; then
	    # Linux: 先用 SIGTERM，10 秒后未退出再发 SIGKILL
	    timeout --kill-after=10s "$timeout_sec" "$@"
	    return $?
	  fi

	  # macOS / BSD 兼容方案：子 shell + set -m 创建独立进程组，确保能终止所有子进程
	  (
	    set -m
	    "$@" &
	    local cmd_pid=$!

	    # 计时器进程：超时后向整个进程组发送信号
	    (
	      sleep "$timeout_sec"
	      # 先发送 SIGTERM 给整个进程组（包括主进程和所有子进程）
	      kill -TERM -"$cmd_pid" 2>/dev/null
	      # 再等 3 秒仍不退出则强制 SIGKILL
	      sleep 3
	      kill -KILL -"$cmd_pid" 2>/dev/null
	    ) &
	    local timer_pid=$!

	    # 等待主进程退出
	    wait "$cmd_pid" 2>/dev/null
	    local exit_code=$?

	    # 清理计时器
	    kill "$timer_pid" 2>/dev/null
	    wait "$timer_pid" 2>/dev/null

	    # 映射退出码：143=SIGTERM, 137=SIGKILL 均视为超时
	    [ "$exit_code" -eq 143 ] && exit 124
	    [ "$exit_code" -eq 137 ] && exit 124
	    exit $exit_code
	  )
	  return $?
}

riwi() {
			cd ~
			riwi_sh
}




stop_containers_or_kill_process() {
	local port=$1
	local containers=$(docker ps --filter "publish=$port" --format "{{.ID}}" 2>/dev/null)

	if [ -n "$containers" ]; then
		docker stop $containers
	else
		install lsof
		for pid in $(lsof -t -i:$port); do
			kill -9 $pid
		done
	fi
}


check_port() {
	stop_containers_or_kill_process 80
	stop_containers_or_kill_process 443
}


install_add_docker_cn() {

local country=$(curl -s ipinfo.io/country)
if [ "$country" = "CN" ]; then
	cat > /etc/docker/daemon.json << EOF
{
  "registry-mirrors": [
	"https://docker.1ms.run",
	"https://docker.m.ixdev.cn",
	"https://hub.rat.dev",
	"https://dockerproxy.net",
	"https://docker-registry.nmqu.com",
	"https://docker.amingg.com",
	"https://docker.hlmirror.com",
	"https://hub1.nat.tf",
	"https://hub2.nat.tf",
	"https://hub3.nat.tf",
	"https://docker.m.daocloud.io",
	"https://docker.riwi.pro",
	"https://docker.367231.xyz",
	"https://hub.1panel.dev",
	"https://dockerproxy.cool",
	"https://docker.apiba.cn",
	"https://proxy.vvvv.ee"
  ]
}
EOF
fi


enable docker
start docker
restart docker

}



linuxmirrors_install_docker() {

local country=$(curl -s ipinfo.io/country)
if [ "$country" = "CN" ]; then
	bash <(curl -sSL https://linuxmirrors.cn/docker.sh) \
	  --source mirrors.huaweicloud.com/docker-ce \
	  --source-registry docker.1ms.run \
	  --protocol https \
	  --use-intranet-source false \
	  --install-latest true \
	  --close-firewall false \
	  --ignore-backup-tips
else
	bash <(curl -sSL https://linuxmirrors.cn/docker.sh) \
	  --source download.docker.com \
	  --source-registry registry.hub.docker.com \
	  --protocol https \
	  --use-intranet-source false \
	  --install-latest true \
	  --close-firewall false \
	  --ignore-backup-tips
fi

install_add_docker_cn

}



install_add_docker() {
	echo -e "${rw_huang}正在安装docker环境...${rw_lv}"
	if command -v apt &>/dev/null || command -v yum &>/dev/null || command -v dnf &>/dev/null; then
		linuxmirrors_install_docker
	else
		install docker docker-compose
		install_add_docker_cn

	fi
	sleep 2
}


install_docker() {
	if ! command -v docker &>/dev/null; then
		install_add_docker
	fi
}


docker_ps() {
while true; do
	clear
	send_stats "Docker容器管理"
	echo -e "${rw_huang}Docker容器管理${rw_lv}"
	echo -e "${rw_cheng}------------------------${rw_lv}"
	echo ""
	echo -e "${rw_huang}功能说明:${rw_lv}"
	echo -e "${rw_huang}  Docker容器的完整管理功能，包括:${rw_lv}"
	echo -e "${rw_huang}  • 容器生命周期管理: 创建、启动、停止、删除、重启${rw_lv}"
	echo -e "${rw_huang}  • 容器监控: 查看日志、资源占用、网络信息${rw_lv}"
	echo -e "${rw_huang}  • 容器操作: 进入容器、端口管理${rw_lv}"
	echo ""
	echo -e "${rw_huang}提示: ${rw_lv}选择对应的数字即可进行相应操作${rw_lv}"
	echo ""
	echo -e "${rw_huang}当前容器列表:${rw_lv}"
	docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"
	echo ""
	echo -e "${rw_cheng}------------------------${rw_lv}"
	echo -e "${rw_huang}1.   ${rw_lv}${rw_lv}创建新容器 ${rw_lv}${rw_huang}★${rw_lv}"
	echo -e "${rw_cheng}------------------------${rw_lv}"
	echo -e "${rw_huang}2.   ${rw_lv}${rw_lv}启动指定容器${rw_lv}   ${rw_huang}6.   ${rw_lv}${rw_lv}启动所有容器${rw_lv}"
	echo -e "${rw_huang}3.   ${rw_lv}${rw_lv}停止指定容器${rw_lv}   ${rw_huang}7.   ${rw_lv}${rw_lv}停止所有容器${rw_lv}"
	echo -e "${rw_huang}4.   ${rw_lv}${rw_lv}删除指定容器${rw_lv}   ${rw_huang}8.   ${rw_lv}${rw_lv}删除所有容器${rw_lv}"
	echo -e "${rw_huang}5.   ${rw_lv}${rw_lv}重启指定容器${rw_lv}   ${rw_huang}9.   ${rw_lv}${rw_lv}重启所有容器${rw_lv}"
	echo -e "${rw_cheng}------------------------${rw_lv}"
	echo -e "${rw_huang}11.  ${rw_lv}${rw_lv}进入指定容器${rw_lv}   ${rw_huang}12.  ${rw_lv}${rw_lv}查看容器日志${rw_lv}"
	echo -e "${rw_huang}13.  ${rw_lv}${rw_lv}查看容器网络${rw_lv}   ${rw_huang}14.  ${rw_lv}${rw_lv}查看容器资源占用${rw_lv}"
	echo -e "${rw_cheng}------------------------${rw_lv}"
	echo -e "${rw_huang}15.  ${rw_lv}${rw_lv}开启容器端口访问${rw_lv}   ${rw_huang}16.  ${rw_lv}${rw_lv}关闭容器端口访问${rw_lv}"
	echo -e "${rw_cheng}------------------------${rw_lv}"
	echo -e "${rw_huang}0.   ${rw_lv}${rw_lv}返回上一级选单${rw_lv}"
	echo -e "${rw_cheng}------------------------${rw_lv}"
	read -e -p "请输入你的选择: " sub_choice
	case $sub_choice in
		1)
			send_stats "新建容器"
			read -e -p "请输入创建命令: " dockername
			$dockername
			;;
		2)
			send_stats "启动指定容器"
			read -e -p "请输入容器名（多个容器名请用空格分隔）: " dockername
			docker start $dockername
			;;
		3)
			send_stats "停止指定容器"
			read -e -p "请输入容器名（多个容器名请用空格分隔）: " dockername
			docker stop $dockername
			;;
		4)
			send_stats "删除指定容器"
			read -e -p "请输入容器名（多个容器名请用空格分隔）: " dockername
			docker rm -f $dockername
			;;
		5)
			send_stats "重启指定容器"
			read -e -p "请输入容器名（多个容器名请用空格分隔）: " dockername
			docker restart $dockername
			;;
		6)
			send_stats "启动所有容器"
			docker start $(docker ps -a -q)
			;;
		7)
			send_stats "停止所有容器"
			docker stop $(docker ps -q)
			;;
		8)
			send_stats "删除所有容器"
			read -e -p "$(echo -e "${rw_hong}注意: ${rw_lv}确定删除所有容器吗？(Y/N): ")" choice
			case "$choice" in
			  [Yy])
				docker rm -f $(docker ps -a -q)
				;;
			  [Nn])
				;;
			  *)
				echo "无效的选择，请输入 Y 或 N。"
				;;
			esac
			;;
		9)
			send_stats "重启所有容器"
			docker restart $(docker ps -q)
			;;
		11)
			send_stats "进入容器"
			read -e -p "请输入容器名: " dockername
			docker exec -it $dockername /bin/sh
			break_end
			;;
		12)
			send_stats "查看容器日志"
			read -e -p "请输入容器名: " dockername
			docker logs $dockername
			break_end
			;;
		13)
			send_stats "查看容器网络"
			echo ""
			container_ids=$(docker ps -q)
			echo -e "${rw_cheng}------------------------------------------------------------${rw_lv}"
			printf "%-25s %-25s %-25s\n" "容器名称" "网络名称" "IP地址"
			for container_id in $container_ids; do
				local container_info=$(docker inspect --format '{{ .Name }}{{ range $network, $config := .NetworkSettings.Networks }} {{ $network }} {{ $config.IPAddress }}{{ end }}' "$container_id")
				local container_name=$(echo "$container_info" | awk '{print $1}')
				local network_info=$(echo "$container_info" | cut -d' ' -f2-)
				while IFS= read -r line; do
					local network_name=$(echo "$line" | awk '{print $1}')
					local ip_address=$(echo "$line" | awk '{print $2}')
					printf "%-20s %-20s %-15s\n" "$container_name" "$network_name" "$ip_address"
				done <<< "$network_info"
			done
			break_end
			;;
		14)
			send_stats "查看容器占用"
			docker stats --no-stream
			break_end
			;;

		15)
			send_stats "允许容器端口访问"
			read -e -p "请输入容器名: " docker_name
			ip_address
			clear_container_rules "$docker_name" "$ipv4_address"
			local docker_port=$(docker port $docker_name | awk -F'[:]' '/->/ {print $NF}' | uniq)
			check_docker_app_ip
			break_end
			;;

		16)
			send_stats "阻止容器端口访问"
			read -e -p "请输入容器名: " docker_name
			ip_address
			block_container_port "$docker_name" "$ipv4_address"
			local docker_port=$(docker port $docker_name | awk -F'[:]' '/->/ {print $NF}' | uniq)
			check_docker_app_ip
			break_end
			;;

		*)
			break  # 跳出循环，退出菜单
			;;
	esac
done
}


docker_image() {
while true; do
	clear
	send_stats "Docker镜像管理"
	echo -e "${rw_huang}Docker镜像管理${rw_lv}"
	echo -e "${rw_cheng}------------------------${rw_lv}"
	echo ""
	echo -e "${rw_huang}功能说明:${rw_lv}"
	echo -e "${rw_huang}  Docker镜像的管理功能，包括:${rw_lv}"
	echo -e "${rw_huang}  • 拉取/下载镜像: 从Docker Hub获取镜像${rw_lv}"
	echo -e "${rw_huang}  • 更新镜像: 重新拉取最新版本的镜像${rw_lv}"
	echo -e "${rw_huang}  • 删除镜像: 清理不需要的镜像以释放空间${rw_lv}"
	echo ""
	echo -e "${rw_huang}提示: ${rw_lv}选择对应的数字即可进行相应操作${rw_lv}"
	echo ""
	echo -e "${rw_huang}当前镜像列表:${rw_lv}"
	docker image ls
	echo ""
	echo -e "${rw_cheng}------------------------${rw_lv}"
	echo -e "${rw_huang}1.   ${rw_lv}${rw_lv}获取指定镜像${rw_lv}   ${rw_huang}3.   ${rw_lv}${rw_lv}删除指定镜像${rw_lv}"
	echo -e "${rw_huang}2.   ${rw_lv}${rw_lv}更新指定镜像${rw_lv}   ${rw_huang}4.   ${rw_lv}${rw_lv}删除所有镜像${rw_lv}"
	echo -e "${rw_cheng}------------------------${rw_lv}"
	echo -e "${rw_huang}0.   ${rw_lv}${rw_lv}返回上一级选单${rw_lv}"
	echo -e "${rw_cheng}------------------------${rw_lv}"
	read -e -p "请输入你的选择: " sub_choice
	case $sub_choice in
		1)
			send_stats "拉取镜像"
			read -e -p "请输入镜像名（多个镜像名请用空格分隔）: " imagenames
			for name in $imagenames; do
				echo -e "${rw_huang}正在获取镜像: $name${rw_lv}"
				docker pull $name
			done
			;;
		2)
			send_stats "更新镜像"
			read -e -p "请输入镜像名（多个镜像名请用空格分隔）: " imagenames
			for name in $imagenames; do
				echo -e "${rw_huang}正在更新镜像: $name${rw_lv}"
				docker pull $name
			done
			;;
		3)
			send_stats "删除镜像"
			read -e -p "请输入镜像名（多个镜像名请用空格分隔）: " imagenames
			for name in $imagenames; do
				docker rmi -f $name
			done
			;;
		4)
			send_stats "删除所有镜像"
			read -e -p "$(echo -e "${rw_hong}注意: ${rw_lv}确定删除所有镜像吗？(Y/N): ")" choice
			case "$choice" in
			  [Yy])
				docker rmi -f $(docker images -q)
				;;
			  [Nn])
				;;
			  *)
				echo "无效的选择，请输入 Y 或 N。"
				;;
			esac
			;;
		*)
			break  # 跳出循环，退出菜单
			;;
	esac
done


}





check_crontab_installed() {
	if ! command -v crontab >/dev/null 2>&1; then
		install_crontab
	fi
}



install_crontab() {

	if [ -f /etc/os-release ]; then
		. /etc/os-release
		case "$ID" in
			ubuntu|debian|kali)
				apt update
				apt install -y cron
				systemctl enable cron
				systemctl start cron
				;;
			centos|rhel|almalinux|rocky|fedora)
				yum install -y cronie
				systemctl enable crond
				systemctl start crond
				;;
			alpine)
				apk add --no-cache cronie
				rc-update add crond
				rc-service crond start
				;;
			arch|manjaro)
				pacman -S --noconfirm cronie
				systemctl enable cronie
				systemctl start cronie
				;;
			opensuse|suse|opensuse-tumbleweed)
				zypper install -y cron
				systemctl enable cron
				systemctl start cron
				;;
			iStoreOS|openwrt|ImmortalWrt|lede)
				opkg update
				opkg install cron
				/etc/init.d/cron enable
				/etc/init.d/cron start
				;;
			FreeBSD)
				pkg install -y cronie
				sysrc cron_enable="YES"
				service cron start
				;;
			*)
				echo "不支持的发行版: $ID"
				return
				;;
		esac
	else
		echo "无法确定操作系统。"
		return
	fi

	echo -e "${rw_lv}crontab 已安装且 cron 服务正在运行。${rw_lv}"
}



docker_ipv6_on() {
	root_use
	install jq

	local CONFIG_FILE="/etc/docker/daemon.json"
	local REQUIRED_IPV6_CONFIG='{"ipv6": true, "fixed-cidr-v6": "2001:db8:1::/64"}'

	# 检查配置文件是否存在，如果不存在则创建文件并写入默认设置
	if [ ! -f "$CONFIG_FILE" ]; then
		echo "$REQUIRED_IPV6_CONFIG" | jq . > "$CONFIG_FILE"
		restart docker
	else
		# 使用jq处理配置文件的更新
		local ORIGINAL_CONFIG=$(<"$CONFIG_FILE")

		# 检查当前配置是否已经有 ipv6 设置
		local CURRENT_IPV6=$(echo "$ORIGINAL_CONFIG" | jq '.ipv6 // false')

		# 更新配置，开启 IPv6
		if [[ "$CURRENT_IPV6" == "false" ]]; then
			UPDATED_CONFIG=$(echo "$ORIGINAL_CONFIG" | jq '. + {ipv6: true, "fixed-cidr-v6": "2001:db8:1::/64"}')
		else
			UPDATED_CONFIG=$(echo "$ORIGINAL_CONFIG" | jq '. + {"fixed-cidr-v6": "2001:db8:1::/64"}')
		fi

		# 对比原始配置与新配置
		if [[ "$ORIGINAL_CONFIG" == "$UPDATED_CONFIG" ]]; then
			echo -e "${rw_huang}当前已开启ipv6访问${rw_lv}"
		else
			echo "$UPDATED_CONFIG" | jq . > "$CONFIG_FILE"
			restart docker
		fi
	fi
}


docker_ipv6_off() {
	root_use
	install jq

	local CONFIG_FILE="/etc/docker/daemon.json"

	# 检查配置文件是否存在
	if [ ! -f "$CONFIG_FILE" ]; then
		echo -e "${rw_hong}配置文件不存在${rw_lv}"
		return
	fi

	# 读取当前配置
	local ORIGINAL_CONFIG=$(<"$CONFIG_FILE")

	# 使用jq处理配置文件的更新
	local UPDATED_CONFIG=$(echo "$ORIGINAL_CONFIG" | jq 'del(.["fixed-cidr-v6"]) | .ipv6 = false')

	# 检查当前的 ipv6 状态
	local CURRENT_IPV6=$(echo "$ORIGINAL_CONFIG" | jq -r '.ipv6 // false')

	# 对比原始配置与新配置
	if [[ "$CURRENT_IPV6" == "false" ]]; then
		echo -e "${rw_huang}当前已关闭ipv6访问${rw_lv}"
	else
		echo "$UPDATED_CONFIG" | jq . > "$CONFIG_FILE"
		restart docker
		echo -e "${rw_huang}已成功关闭ipv6访问${rw_lv}"
	fi
}



save_iptables_rules() {
	mkdir -p /etc/iptables
	touch /etc/iptables/rules.v4
	iptables-save > /etc/iptables/rules.v4
	check_crontab_installed
	crontab -l | grep -v 'iptables-restore' | crontab - > /dev/null 2>&1
	(crontab -l ; echo '@reboot iptables-restore < /etc/iptables/rules.v4') | crontab - > /dev/null 2>&1

}




iptables_open() {
	install iptables
	save_iptables_rules
	iptables -P INPUT ACCEPT
	iptables -P FORWARD ACCEPT
	iptables -P OUTPUT ACCEPT
	iptables -F

	ip6tables -P INPUT ACCEPT
	ip6tables -P FORWARD ACCEPT
	ip6tables -P OUTPUT ACCEPT
	ip6tables -F

}



open_port() {
	local ports=($@)  # 将传入的参数转换为数组
	if [ ${#ports[@]} -eq 0 ]; then
		echo "请提供至少一个端口号"
		return 1
	fi

	install iptables

	for port in "${ports[@]}"; do
		# 删除已存在的关闭规则
		iptables -D INPUT -p tcp --dport $port -j DROP 2>/dev/null
		iptables -D INPUT -p udp --dport $port -j DROP 2>/dev/null

		# 添加打开规则
		if ! iptables -C INPUT -p tcp --dport $port -j ACCEPT 2>/dev/null; then
			iptables -I INPUT 1 -p tcp --dport $port -j ACCEPT
		fi

		if ! iptables -C INPUT -p udp --dport $port -j ACCEPT 2>/dev/null; then
			iptables -I INPUT 1 -p udp --dport $port -j ACCEPT
			echo "已打开端口 $port"
		fi
	done

	save_iptables_rules
	send_stats "已打开端口"
}


close_port() {
	local ports=($@)  # 将传入的参数转换为数组
	if [ ${#ports[@]} -eq 0 ]; then
		echo "请提供至少一个端口号"
		return 1
	fi

	install iptables

	for port in "${ports[@]}"; do
		# 删除已存在的打开规则
		iptables -D INPUT -p tcp --dport $port -j ACCEPT 2>/dev/null
		iptables -D INPUT -p udp --dport $port -j ACCEPT 2>/dev/null

		# 添加关闭规则
		if ! iptables -C INPUT -p tcp --dport $port -j DROP 2>/dev/null; then
			iptables -I INPUT 1 -p tcp --dport $port -j DROP
		fi

		if ! iptables -C INPUT -p udp --dport $port -j DROP 2>/dev/null; then
			iptables -I INPUT 1 -p udp --dport $port -j DROP
			echo "已关闭端口 $port"
		fi
	done

	# 删除已存在的规则（如果有）
	iptables -D INPUT -i lo -j ACCEPT 2>/dev/null
	iptables -D FORWARD -i lo -j ACCEPT 2>/dev/null

	# 插入新规则到第一条
	iptables -I INPUT 1 -i lo -j ACCEPT
	iptables -I FORWARD 1 -i lo -j ACCEPT

	save_iptables_rules
	send_stats "已关闭端口"
}


allow_ip() {
	local ips=($@)  # 将传入的参数转换为数组
	if [ ${#ips[@]} -eq 0 ]; then
		echo "请提供至少一个IP地址或IP段"
		return 1
	fi

	install iptables

	for ip in "${ips[@]}"; do
		# 删除已存在的阻止规则
		iptables -D INPUT -s $ip -j DROP 2>/dev/null

		# 添加允许规则
		if ! iptables -C INPUT -s $ip -j ACCEPT 2>/dev/null; then
			iptables -I INPUT 1 -s $ip -j ACCEPT
			echo "已放行IP $ip"
		fi
	done

	save_iptables_rules
	send_stats "已放行IP"
}

block_ip() {
	local ips=($@)  # 将传入的参数转换为数组
	if [ ${#ips[@]} -eq 0 ]; then
		echo "请提供至少一个IP地址或IP段"
		return 1
	fi

	install iptables

	for ip in "${ips[@]}"; do
		# 删除已存在的允许规则
		iptables -D INPUT -s $ip -j ACCEPT 2>/dev/null

		# 添加阻止规则
		if ! iptables -C INPUT -s $ip -j DROP 2>/dev/null; then
			iptables -I INPUT 1 -s $ip -j DROP
			echo "已阻止IP $ip"
		fi
	done

	save_iptables_rules
	send_stats "已阻止IP"
}







enable_ddos_defense() {
	# 开启防御 DDoS
	iptables -A DOCKER-USER -p tcp --syn -m limit --limit 500/s --limit-burst 100 -j ACCEPT
	iptables -A DOCKER-USER -p tcp --syn -j DROP
	iptables -A DOCKER-USER -p udp -m limit --limit 3000/s -j ACCEPT
	iptables -A DOCKER-USER -p udp -j DROP
	iptables -A INPUT -p tcp --syn -m limit --limit 500/s --limit-burst 100 -j ACCEPT
	iptables -A INPUT -p tcp --syn -j DROP
	iptables -A INPUT -p udp -m limit --limit 3000/s -j ACCEPT
	iptables -A INPUT -p udp -j DROP

	send_stats "开启DDoS防御"
}

# 关闭DDoS防御
disable_ddos_defense() {
	# 关闭防御 DDoS
	iptables -D DOCKER-USER -p tcp --syn -m limit --limit 500/s --limit-burst 100 -j ACCEPT 2>/dev/null
	iptables -D DOCKER-USER -p tcp --syn -j DROP 2>/dev/null
	iptables -D DOCKER-USER -p udp -m limit --limit 3000/s -j ACCEPT 2>/dev/null
	iptables -D DOCKER-USER -p udp -j DROP 2>/dev/null
	iptables -D INPUT -p tcp --syn -m limit --limit 500/s --limit-burst 100 -j ACCEPT 2>/dev/null
	iptables -D INPUT -p tcp --syn -j DROP 2>/dev/null
	iptables -D INPUT -p udp -m limit --limit 3000/s -j ACCEPT 2>/dev/null
	iptables -D INPUT -p udp -j DROP 2>/dev/null

	send_stats "关闭DDoS防御"
}





# 管理国家IP规则的函数
manage_country_rules() {
	local action="$1"
	shift  # 去掉第一个参数，剩下的全是国家代码

	install ipset

	for country_code in "$@"; do
		local ipset_name="${country_code,,}_block"
		local download_url="http://www.ipdeny.com/ipblocks/data/countries/${country_code,,}.zone"

		case "$action" in
			block)
				if ! ipset list "$ipset_name" &> /dev/null; then
					ipset create "$ipset_name" hash:net
				fi

				if ! wget -q "$download_url" -O "${country_code,,}.zone"; then
					echo "错误：下载 $country_code 的 IP 区域文件失败"
					continue
				fi

				while IFS= read -r ip; do
					ipset add "$ipset_name" "$ip" 2>/dev/null
				done < "${country_code,,}.zone"

				iptables -I INPUT -m set --match-set "$ipset_name" src -j DROP

				echo "已成功阻止 $country_code 的 IP 地址"
				rm "${country_code,,}.zone"
				;;

			allow)
				if ! ipset list "$ipset_name" &> /dev/null; then
					ipset create "$ipset_name" hash:net
				fi

				if ! wget -q "$download_url" -O "${country_code,,}.zone"; then
					echo "错误：下载 $country_code 的 IP 区域文件失败"
					continue
				fi

				ipset flush "$ipset_name"
				while IFS= read -r ip; do
					ipset add "$ipset_name" "$ip" 2>/dev/null
				done < "${country_code,,}.zone"


				iptables -P INPUT DROP
				iptables -A INPUT -m set --match-set "$ipset_name" src -j ACCEPT

				echo "已成功允许 $country_code 的 IP 地址"
				rm "${country_code,,}.zone"
				;;

			unblock)
				iptables -D INPUT -m set --match-set "$ipset_name" src -j DROP 2>/dev/null

				if ipset list "$ipset_name" &> /dev/null; then
					ipset destroy "$ipset_name"
				fi

				echo "已成功解除 $country_code 的 IP 地址限制"
				;;

			*)
				echo "用法: manage_country_rules {block|allow|unblock} <country_code...>"
				;;
		esac
	done
}










iptables_panel() {
  root_use
  install iptables
  save_iptables_rules
  while true; do
		  clear
		  echo "高级防火墙管理"
		  send_stats "高级防火墙管理"
		  echo -e "${rw_cheng}------------------------${rw_lv}"
		  iptables -L INPUT
		  echo ""
		  echo "防火墙管理"
		  echo -e "${rw_cheng}------------------------${rw_lv}"
		  echo "1.  开放指定端口                 2.  关闭指定端口"
		  echo "3.  开放所有端口                 4.  关闭所有端口"
		  echo -e "${rw_cheng}------------------------${rw_lv}"
		  echo "5.  IP白名单                  	 6.  IP黑名单"
		  echo "7.  清除指定IP"
		  echo -e "${rw_cheng}------------------------${rw_lv}"
		  echo "11. 允许PING                  	 12. 禁止PING"
		  echo -e "${rw_cheng}------------------------${rw_lv}"
		  echo "13. 启动DDOS防御                 14. 关闭DDOS防御"
		  echo -e "${rw_cheng}------------------------${rw_lv}"
		  echo "15. 阻止指定国家IP               16. 仅允许指定国家IP"
		  echo "17. 解除指定国家IP限制"
		  echo -e "${rw_cheng}------------------------${rw_lv}"
		  echo "0. 返回上一级选单"
		  echo -e "${rw_cheng}------------------------${rw_lv}"
		  read -e -p "请输入你的选择: " sub_choice
		  case $sub_choice in
			  1)
				  read -e -p "请输入开放的端口号: " o_port
				  open_port $o_port
				  send_stats "开放指定端口"
				  ;;
			  2)
				  read -e -p "请输入关闭的端口号: " c_port
				  close_port $c_port
				  send_stats "关闭指定端口"
				  ;;
			  3)
				  # 开放所有端口
				  current_port=$(grep -E '^ *Port [0-9]+' /etc/ssh/sshd_config | awk '{print $2}')
				  iptables -F
				  iptables -X
				  iptables -P INPUT ACCEPT
				  iptables -P FORWARD ACCEPT
				  iptables -P OUTPUT ACCEPT
				  iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
				  iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
				  iptables -A INPUT -i lo -j ACCEPT
				  iptables -A FORWARD -i lo -j ACCEPT
				  iptables -A INPUT -p tcp --dport $current_port -j ACCEPT
				  iptables-save > /etc/iptables/rules.v4
				  send_stats "开放所有端口"
				  ;;
			  4)
				  # 关闭所有端口
				  current_port=$(grep -E '^ *Port [0-9]+' /etc/ssh/sshd_config | awk '{print $2}')
				  iptables -F
				  iptables -X
				  iptables -P INPUT DROP
				  iptables -P FORWARD DROP
				  iptables -P OUTPUT ACCEPT
				  iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
				  iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
				  iptables -A INPUT -i lo -j ACCEPT
				  iptables -A FORWARD -i lo -j ACCEPT
				  iptables -A INPUT -p tcp --dport $current_port -j ACCEPT
				  iptables-save > /etc/iptables/rules.v4
				  send_stats "关闭所有端口"
				  ;;

			  5)
				  # IP 白名单
				  read -e -p "请输入放行的IP或IP段: " o_ip
				  allow_ip $o_ip
				  ;;
			  6)
				  # IP 黑名单
				  read -e -p "请输入封锁的IP或IP段: " c_ip
				  block_ip $c_ip
				  ;;
			  7)
				  # 清除指定 IP
				  read -e -p "请输入清除的IP: " d_ip
				  iptables -D INPUT -s $d_ip -j ACCEPT 2>/dev/null
				  iptables -D INPUT -s $d_ip -j DROP 2>/dev/null
				  iptables-save > /etc/iptables/rules.v4
				  send_stats "清除指定IP"
				  ;;
			  11)
				  # 允许 PING
				  iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
				  iptables -A OUTPUT -p icmp --icmp-type echo-reply -j ACCEPT
				  iptables-save > /etc/iptables/rules.v4
				  send_stats "允许PING"
				  ;;
			  12)
				  # 禁用 PING
				  iptables -D INPUT -p icmp --icmp-type echo-request -j ACCEPT 2>/dev/null
				  iptables -D OUTPUT -p icmp --icmp-type echo-reply -j ACCEPT 2>/dev/null
				  iptables-save > /etc/iptables/rules.v4
				  send_stats "禁用PING"
				  ;;
			  13)
				  enable_ddos_defense
				  ;;
			  14)
				  disable_ddos_defense
				  ;;

			  15)
				  read -e -p "请输入阻止的国家代码（多个国家代码可用空格隔开如 CN US JP）: " country_code
				  manage_country_rules block $country_code
				  send_stats "允许国家 $country_code 的IP"
				  ;;
			  16)
				  read -e -p "请输入允许的国家代码（多个国家代码可用空格隔开如 CN US JP）: " country_code
				  manage_country_rules allow $country_code
				  send_stats "阻止国家 $country_code 的IP"
				  ;;

			  17)
				  read -e -p "请输入清除的国家代码（多个国家代码可用空格隔开如 CN US JP）: " country_code
				  manage_country_rules unblock $country_code
				  send_stats "清除国家 $country_code 的IP"
				  ;;

			  *)
				  break  # 跳出循环，退出菜单
				  ;;
		  esac
  done

}






add_swap() {
	local new_swap=$1  # 获取传入的参数

	# 获取当前系统中所有的 swap 分区
	local swap_partitions=$(grep -E '^/dev/' /proc/swaps | awk '{print $1}')

	# 遍历并删除所有的 swap 分区
	for partition in $swap_partitions; do
		swapoff "$partition"
		wipefs -a "$partition"
		mkswap -f "$partition"
	done

	# 确保 /swapfile 不再被使用
	swapoff /swapfile

	# 删除旧的 /swapfile
	rm -f /swapfile

	# 创建新的 swap 分区
	fallocate -l ${new_swap}M /swapfile
	chmod 600 /swapfile
	mkswap /swapfile
	swapon /swapfile

	sed -i '/\/swapfile/d' /etc/fstab
	echo "/swapfile swap swap defaults 0 0" >> /etc/fstab

	if [ -f /etc/alpine-release ]; then
		echo "nohup swapon /swapfile" > /etc/local.d/swap.start
		chmod +x /etc/local.d/swap.start
		rc-update add local
	fi

	echo -e "虚拟内存大小已调整为${rw_huang}${new_swap}${rw_lv}M"
}




check_swap() {

local swap_total=$(free -m | awk 'NR==3{print $2}')

# 判断是否需要创建虚拟内存
[ "$swap_total" -gt 0 ] || add_swap 1024


}









ldnmp_v() {

	  # 获取nginx版本
	  local nginx_version=$(docker exec nginx nginx -v 2>&1)
	  local nginx_version=$(echo "$nginx_version" | sed -n -E 's/.*nginx\/([0-9]+\.[0-9]+\.[0-9]+).*/\1/p')
	  echo -n -e "nginx : ${rw_huang}v$nginx_version${rw_lv}"

	  # 获取mysql版本
	  local dbrootpasswd=$(sed -n -E 's/.*MYSQL_ROOT_PASSWORD:[[:space:]]*(.*)/\1/p' /home/web/docker-compose.yml | tr -d '[:space:]')
	  local mysql_version=$(docker exec mysql mysql -u root -p"$dbrootpasswd" -e "SELECT VERSION();" 2>/dev/null | tail -n 1)
	  echo -n -e "            mysql : ${rw_huang}v$mysql_version${rw_lv}"

	  # 获取php版本
	  local php_version=$(docker exec php php -v 2>/dev/null | sed -n -E 's/.*PHP ([0-9]+\.[0-9]+\.[0-9]+).*/\1/p')
	  echo -n -e "            php : ${rw_huang}v$php_version${rw_lv}"

	  # 获取redis版本
	  local redis_version=$(docker exec redis redis-server -v 2>&1 | sed -n -E 's/.*v=([0-9]+\.[0-9]+).*/\1/p')
	  echo -e "            redis : ${rw_huang}v$redis_version${rw_lv}"

	  echo -e "${rw_cheng}------------------------${rw_lv}"
	  echo ""

}



install_ldnmp_conf() {

  # 创建必要的目录和文件
  cd /home && mkdir -p web/html web/mysql web/certs web/conf.d web/stream.d web/redis web/log/nginx web/letsencrypt && touch web/docker-compose.yml
  wget -O /home/web/nginx.conf ${gh_proxy}raw.githubusercontent.com/riwi/nginx/main/nginx10.conf
  wget -O /home/web/conf.d/default.conf ${gh_proxy}raw.githubusercontent.com/riwi/nginx/main/default10.conf

  default_server_ssl

  # 下载 docker-compose.yml 文件并进行替换
  wget -O /home/web/docker-compose.yml ${gh_proxy}raw.githubusercontent.com/riwi/docker/main/LNMP-docker-compose-10.yml
  dbrootpasswd=$(openssl rand -base64 16) ; dbuse=$(openssl rand -hex 4) ; dbusepasswd=$(openssl rand -base64 8)

  # 在 docker-compose.yml 文件中进行替换
  sed -i "s#webroot#$dbrootpasswd#g" /home/web/docker-compose.yml
  sed -i "s#riwiYYDS#$dbusepasswd#g" /home/web/docker-compose.yml
  sed -i "s#riwi#$dbuse#g" /home/web/docker-compose.yml

}


update_docker_compose_with_db_creds() {

  cp /home/web/docker-compose.yml /home/web/docker-compose1.yml

  if ! grep -q "letsencrypt" /home/web/docker-compose.yml; then
	wget -O /home/web/docker-compose.yml ${gh_proxy}raw.githubusercontent.com/riwi/docker/main/LNMP-docker-compose-10.yml

  	dbrootpasswd=$(sed -n -E 's/.*MYSQL_ROOT_PASSWORD:[[:space:]]*(.*)/\1/p' /home/web/docker-compose1.yml | tr -d '[:space:]')
  	dbuse=$(sed -n -E 's/.*MYSQL_USER:[[:space:]]*(.*)/\1/p' /home/web/docker-compose1.yml | tr -d '[:space:]')
  	dbusepasswd=$(sed -n -E 's/.*MYSQL_PASSWORD:[[:space:]]*(.*)/\1/p' /home/web/docker-compose1.yml | tr -d '[:space:]')

	sed -i "s#webroot#$dbrootpasswd#g" /home/web/docker-compose.yml
	sed -i "s#riwiYYDS#$dbusepasswd#g" /home/web/docker-compose.yml
	sed -i "s#riwi#$dbuse#g" /home/web/docker-compose.yml
  fi

  if grep -q "kjlion/nginx:alpine" /home/web/docker-compose1.yml; then
  	sed -i 's|kjlion/nginx:alpine|nginx:alpine|g' /home/web/docker-compose.yml  > /dev/null 2>&1
	sed -i 's|nginx:alpine|kjlion/nginx:alpine|g' /home/web/docker-compose.yml  > /dev/null 2>&1
  fi

}





auto_optimize_dns() {
	# 获取国家代码（如 CN、US 等）
	local country=$(curl -s ipinfo.io/country)

	# 根据国家设置 DNS
	if [ "$country" = "CN" ]; then
		local dns1_ipv4="223.5.5.5"
		local dns2_ipv4="183.60.83.19"
		local dns1_ipv6="2400:3200::1"
		local dns2_ipv6="2400:da00::6666"
	else
		local dns1_ipv4="1.1.1.1"
		local dns2_ipv4="8.8.8.8"
		local dns1_ipv6="2606:4700:4700::1111"
		local dns2_ipv6="2001:4860:4860::8888"
	fi

	set_dns


}


prefer_ipv4() {
grep -q '^precedence ::ffff:0:0/96  100' /etc/gai.conf 2>/dev/null \
	|| echo 'precedence ::ffff:0:0/96  100' >> /etc/gai.conf
echo "已切换为 IPv4 优先"
send_stats "已切换为 IPv4 优先"
}




install_ldnmp() {

	  update_docker_compose_with_db_creds

	  cd /home/web && docker compose up -d
	  sleep 1
  	  crontab -l 2>/dev/null | grep -v 'logrotate' | crontab -
  	  (crontab -l 2>/dev/null; echo '0 2 * * * docker exec nginx apk add logrotate && docker exec nginx logrotate -f /etc/logrotate.conf') | crontab -

	  fix_phpfpm_conf php
	  fix_phpfpm_conf php74

	  # mysql调优
	  wget -O /home/custom_mysql_config.cnf ${gh_proxy}raw.githubusercontent.com/riwi/sh/main/custom_mysql_config-1.cnf
	  docker cp /home/custom_mysql_config.cnf mysql:/etc/mysql/conf.d/
	  rm -rf /home/custom_mysql_config.cnf



	  restart_ldnmp
	  sleep 2

	  clear
	  echo "LDNMP环境安装完毕"
	  echo -e "${rw_cheng}------------------------${rw_lv}"
	  ldnmp_v

}


install_certbot() {

	cd ~
	curl -sS -O ${gh_proxy}raw.githubusercontent.com/riwi/sh/main/auto_cert_renewal.sh
	chmod +x auto_cert_renewal.sh

	check_crontab_installed
	local cron_job="0 0 * * * ~/auto_cert_renewal.sh"
	crontab -l 2>/dev/null | grep -vF "$cron_job" | crontab -
	(crontab -l 2>/dev/null; echo "$cron_job") | crontab -
	echo "续签任务已更新"
}


install_ssltls() {
	  docker stop nginx > /dev/null 2>&1
	  cd ~

	  local file_path="/etc/letsencrypt/live/$yuming/fullchain.pem"
	  if [ ! -f "$file_path" ]; then
		 	local ipv4_pattern='^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'
			local ipv6_pattern='^(([0-9A-Fa-f]{1,4}:){1,7}:|([0-9A-Fa-f]{1,4}:){7,7}[0-9A-Fa-f]{1,4}|::1)$'
			if [[ ($yuming =~ $ipv4_pattern || $yuming =~ $ipv6_pattern) ]]; then
				mkdir -p /etc/letsencrypt/live/$yuming/
				if command -v dnf &>/dev/null || command -v yum &>/dev/null; then
					openssl req -x509 -nodes -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 -keyout /etc/letsencrypt/live/$yuming/privkey.pem -out /etc/letsencrypt/live/$yuming/fullchain.pem -days 5475 -subj "/C=US/ST=State/L=City/O=Organization/OU=Organizational Unit/CN=Common Name"
				else
					openssl genpkey -algorithm Ed25519 -out /etc/letsencrypt/live/$yuming/privkey.pem
					openssl req -x509 -key /etc/letsencrypt/live/$yuming/privkey.pem -out /etc/letsencrypt/live/$yuming/fullchain.pem -days 5475 -subj "/C=US/ST=State/L=City/O=Organization/OU=Organizational Unit/CN=Common Name"
				fi
			else
				docker run --rm -p 80:80 -v /etc/letsencrypt/:/etc/letsencrypt certbot/certbot certonly --standalone -d "$yuming" --email your@email.com --agree-tos --no-eff-email --force-renewal --key-type ecdsa
			fi
	  fi
	  mkdir -p /home/web/certs/
	  cp /etc/letsencrypt/live/$yuming/fullchain.pem /home/web/certs/${yuming}_cert.pem > /dev/null 2>&1
	  cp /etc/letsencrypt/live/$yuming/privkey.pem /home/web/certs/${yuming}_key.pem > /dev/null 2>&1

	  docker start nginx > /dev/null 2>&1
}



install_ssltls_text() {
	echo -e "${rw_huang}$yuming 公钥信息${rw_lv}"
	cat /etc/letsencrypt/live/$yuming/fullchain.pem
	echo ""
	echo -e "${rw_huang}$yuming 私钥信息${rw_lv}"
	cat /etc/letsencrypt/live/$yuming/privkey.pem
	echo ""
	echo -e "${rw_huang}证书存放路径${rw_lv}"
	echo "公钥: /etc/letsencrypt/live/$yuming/fullchain.pem"
	echo "私钥: /etc/letsencrypt/live/$yuming/privkey.pem"
	echo ""
}





add_ssl() {
echo -e "${rw_huang}快速申请SSL证书，过期前自动续签${rw_lv}"
yuming="${1:-}"
if [ -z "$yuming" ]; then
	add_yuming
fi
install_docker
install_certbot
docker run --rm -v /etc/letsencrypt/:/etc/letsencrypt certbot/certbot delete --cert-name "$yuming" -n 2>/dev/null
install_ssltls
certs_status
install_ssltls_text
ssl_ps
}


ssl_ps() {
	echo -e "${rw_huang}已申请的证书到期情况${rw_lv}"
	echo "站点信息                      证书到期时间"
	echo -e "${rw_cheng}------------------------${rw_lv}"
	for cert_dir in /etc/letsencrypt/live/*; do
	  local cert_file="$cert_dir/fullchain.pem"
	  if [ -f "$cert_file" ]; then
		local domain=$(basename "$cert_dir")
		local expire_date=$(openssl x509 -noout -enddate -in "$cert_file" | awk -F'=' '{print $2}')
		local formatted_date=$(portable_date "$expire_date" '+%Y-%m-%d')
		printf "%-30s%s\n" "$domain" "$formatted_date"
	  fi
	done
	echo ""
}




default_server_ssl() {
install openssl

if command -v dnf &>/dev/null || command -v yum &>/dev/null; then
	openssl req -x509 -nodes -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 -keyout /home/web/certs/default_server.key -out /home/web/certs/default_server.crt -days 5475 -subj "/C=US/ST=State/L=City/O=Organization/OU=Organizational Unit/CN=Common Name"
else
	openssl genpkey -algorithm Ed25519 -out /home/web/certs/default_server.key
	openssl req -x509 -key /home/web/certs/default_server.key -out /home/web/certs/default_server.crt -days 5475 -subj "/C=US/ST=State/L=City/O=Organization/OU=Organizational Unit/CN=Common Name"
fi

openssl rand -out /home/web/certs/ticket12.key 48
openssl rand -out /home/web/certs/ticket13.key 80

}


certs_status() {

	sleep 1

	local file_path="/etc/letsencrypt/live/$yuming/fullchain.pem"
	if [ -f "$file_path" ]; then
		send_stats "域名证书申请成功"
	else
		send_stats "域名证书申请失败"
		echo -e "${rw_hong}注意: ${rw_lv}证书申请失败，请检查以下可能原因并重试："
		echo -e "1. 域名拼写错误 ➠ 请检查域名输入是否正确"
		echo -e "2. DNS解析问题 ➠ 确认域名已正确解析到本服务器IP"
		echo -e "3. 网络配置问题 ➠ 如使用Cloudflare Warp等虚拟网络请暂时关闭"
		echo -e "4. 防火墙限制 ➠ 检查80/443端口是否开放，确保验证可访问"
		echo -e "5. 申请次数超限 ➠ Let's Encrypt 有每周限额（5次/域名/周）"
		echo -e "6. 国内备案限制 ➠ 中国大陆环境请确认域名是否备案"
		echo -e "${rw_cheng}------------------------${rw_lv}"
		echo "1. 重新申请        2. 导入已有证书        0. 退出"
		echo -e "${rw_cheng}------------------------${rw_lv}"
		read -e -p "请输入你的选择: " sub_choice
		case $sub_choice in
	  	  1)
	  	  	send_stats "重新申请"
		  	echo "请再次尝试部署 $webname"
		  	add_yuming
		  	install_ssltls
		  	certs_status

	  		  ;;
	  	  2)
	  	  	send_stats "导入已有证书"

			# 定义文件路径
			local cert_file="/home/web/certs/${yuming}_cert.pem"
			local key_file="/home/web/certs/${yuming}_key.pem"

			mkdir -p /home/web/certs

			# 1. 输入证书 (ECC 和 RSA 证书开头都是 BEGIN CERTIFICATE)
			echo "请粘贴证书（CRT/PEM 格式）内容（按两次回车结束）："
			local cert_content=""
			while IFS= read -r line; do
				[[ -z "$line" && "$cert_content" == *"-----BEGIN"* ]] && break
				cert_content+="${line}"$'\n'
			done

			# 2. 输入私钥 (兼容 RSA, ECC, PKCS#8)
			echo "请粘贴证书私钥（Private Key/私钥）内容（按两次回车结束）："
			local key_content=""
			while IFS= read -r line; do
				[[ -z "$line" && "$key_content" == *"-----BEGIN"* ]] && break
				key_content+="${line}"$'\n'
			done

			# 3. 智能校验
			# 只要包含 "BEGIN CERTIFICATE" 和 "PRIVATE KEY" 即可通过
			if [[ "$cert_content" == *"-----BEGIN CERTIFICATE-----"* && "$key_content" == *"PRIVATE KEY-----"* ]]; then
				echo -n "$cert_content" > "$cert_file"
				echo -n "$key_content" > "$key_file"

				chmod 644 "$cert_file"
				chmod 600 "$key_file"

				# 识别当前证书类型并显示
				if [[ "$key_content" == *"EC PRIVATE KEY"* ]]; then
					echo "检测到 ECC（椭圆曲线）证书已成功保存。"
				else
					echo "检测到 RSA 证书已成功保存。"
				fi
				auth_method="ssl_imported"
			else
				echo "错误：无效的证书或私钥格式！"
				certs_status
			fi
	  		  ;;
	  	  *)
		  	  exit
	  		  ;;
		esac
	fi

}


repeat_add_yuming() {
if [ -e /home/web/conf.d/$yuming.conf ]; then
  send_stats "域名重复使用"
  web_del "${yuming}" > /dev/null 2>&1
fi

}


add_yuming() {
	  ip_address
	  echo -e "先将域名解析到本机IP: ${rw_huang}$ipv4_address  $ipv6_address${rw_lv}"
	  read -e -p "请输入你的IP或者解析过的域名: " yuming
}


check_ip_and_get_access_port() {
	local yuming="$1"

	local ipv4_pattern='^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'
	local ipv6_pattern='^(([0-9A-Fa-f]{1,4}:){1,7}:|([0-9A-Fa-f]{1,4}:){7,7}[0-9A-Fa-f]{1,4}|::1)$'

	if [[ "$yuming" =~ $ipv4_pattern || "$yuming" =~ $ipv6_pattern ]]; then
		read -e -p "请输入访问/监听端口，回车默认使用 80: " access_port
		access_port=${access_port:-80}
	fi
}



update_nginx_listen_port() {
	local yuming="$1"
	local access_port="$2"
	local conf="/home/web/conf.d/${yuming}.conf"

	# 如果 access_port 为空，则跳过
	[ -z "$access_port" ] && return 0

	# 删除所有 listen 行
	sed -i '/^[[:space:]]*listen[[:space:]]\+/d' "$conf"

	# 在 server { 后插入新的 listen
	sed -i "/server {/a\\
	listen ${access_port};\\
	listen [::]:${access_port};
" "$conf"
}



add_db() {
	  dbname=$(echo "$yuming" | sed -e 's/[^A-Za-z0-9]/_/g')
	  dbname="${dbname}"

	  dbrootpasswd=$(sed -n -E 's/.*MYSQL_ROOT_PASSWORD:[[:space:]]*(.*)/\1/p' /home/web/docker-compose.yml | tr -d '[:space:]')
	  dbuse=$(sed -n -E 's/.*MYSQL_USER:[[:space:]]*(.*)/\1/p' /home/web/docker-compose.yml | tr -d '[:space:]')
	  dbusepasswd=$(sed -n -E 's/.*MYSQL_PASSWORD:[[:space:]]*(.*)/\1/p' /home/web/docker-compose.yml | tr -d '[:space:]')
	  docker exec mysql mysql -u root -p"$dbrootpasswd" -e "CREATE DATABASE $dbname; GRANT ALL PRIVILEGES ON $dbname.* TO \"$dbuse\"@\"%\";"
}


restart_ldnmp() {
	  docker exec nginx chown -R nginx:nginx /var/www/html > /dev/null 2>&1
	  docker exec nginx mkdir -p /var/cache/nginx/proxy > /dev/null 2>&1
	  docker exec nginx mkdir -p /var/cache/nginx/fastcgi > /dev/null 2>&1
	  docker exec nginx chown -R nginx:nginx /var/cache/nginx/proxy > /dev/null 2>&1
	  docker exec nginx chown -R nginx:nginx /var/cache/nginx/fastcgi > /dev/null 2>&1
	  docker exec php chown -R www-data:www-data /var/www/html > /dev/null 2>&1
	  docker exec php74 chown -R www-data:www-data /var/www/html > /dev/null 2>&1
	  cd /home/web && docker compose restart


}

nginx_upgrade() {

  local ldnmp_pods="nginx"
  cd /home/web/
  docker rm -f $ldnmp_pods > /dev/null 2>&1
  docker images --filter=reference="kjlion/${ldnmp_pods}*" -q | xargs docker rmi > /dev/null 2>&1
  docker images --filter=reference="${ldnmp_pods}*" -q | xargs docker rmi > /dev/null 2>&1
  docker compose up -d --force-recreate $ldnmp_pods
  crontab -l 2>/dev/null | grep -v 'logrotate' | crontab -
  (crontab -l 2>/dev/null; echo '0 2 * * * docker exec nginx apk add logrotate && docker exec nginx logrotate -f /etc/logrotate.conf') | crontab -
  docker exec nginx chown -R nginx:nginx /var/www/html
  docker exec nginx mkdir -p /var/cache/nginx/proxy
  docker exec nginx mkdir -p /var/cache/nginx/fastcgi
  docker exec nginx chown -R nginx:nginx /var/cache/nginx/proxy
  docker exec nginx chown -R nginx:nginx /var/cache/nginx/fastcgi
  docker restart $ldnmp_pods > /dev/null 2>&1

  send_stats "更新$ldnmp_pods"
  echo "更新${ldnmp_pods}完成"

}

phpmyadmin_upgrade() {
  local ldnmp_pods="phpmyadmin"
  local local docker_port=8877
  local dbuse=$(sed -n -E 's/.*MYSQL_USER:[[:space:]]*(.*)/\1/p' /home/web/docker-compose.yml | tr -d '[:space:]')
  local dbusepasswd=$(sed -n -E 's/.*MYSQL_PASSWORD:[[:space:]]*(.*)/\1/p' /home/web/docker-compose.yml | tr -d '[:space:]')

  cd /home/web/
  docker rm -f $ldnmp_pods > /dev/null 2>&1
  docker images --filter=reference="$ldnmp_pods*" -q | xargs docker rmi > /dev/null 2>&1
  curl -sS -O ${gh_proxy}raw.githubusercontent.com/riwi/docker/refs/heads/main/docker-compose.phpmyadmin.yml
  docker compose -f docker-compose.phpmyadmin.yml up -d
  clear
  ip_address

  check_docker_app_ip
  echo "登录信息: "
  echo "用户名: $dbuse"
  echo "密码: $dbusepasswd"
  echo
  send_stats "启动$ldnmp_pods"
}


cf_purge_cache() {
  local CONFIG_FILE="/home/web/config/cf-purge-cache.txt"
  local API_TOKEN
  local EMAIL
  local ZONE_IDS

  # 检查配置文件是否存在
  if [ -f "$CONFIG_FILE" ]; then
	# 从配置文件读取 API_TOKEN 和 zone_id
	read API_TOKEN EMAIL ZONE_IDS < "$CONFIG_FILE"
	# 将 ZONE_IDS 转换为数组
	ZONE_IDS=($ZONE_IDS)
  else
	# 提示用户是否清理缓存
	read -e -p "需要清理 Cloudflare 的缓存吗？（y/n）: " answer
	if [[ "$answer" == "y" ]]; then
	  echo "CF信息保存在$CONFIG_FILE，可以后期修改CF信息"
	  read -e -p "请输入你的 API_TOKEN: " API_TOKEN
	  read -e -p "请输入你的CF用户名: " EMAIL
	  read -e -p "请输入 zone_id（多个用空格分隔）: " -a ZONE_IDS

	  mkdir -p /home/web/config/
	  echo "$API_TOKEN $EMAIL ${ZONE_IDS[*]}" > "$CONFIG_FILE"
	fi
  fi

  # 循环遍历每个 zone_id 并执行清除缓存命令
  for ZONE_ID in "${ZONE_IDS[@]}"; do
	echo "正在清除缓存 for zone_id: $ZONE_ID"
	curl -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/purge_cache" \
	-H "X-Auth-Email: $EMAIL" \
	-H "X-Auth-Key: $API_TOKEN" \
	-H "Content-Type: application/json" \
	--data '{"purge_everything":true}'
  done

  echo "缓存清除请求已发送完毕。"
}



web_cache() {
  send_stats "清理站点缓存"
  cf_purge_cache
  cd /home/web && docker compose restart
}



web_del() {

	send_stats "删除站点数据"
	yuming_list="${1:-}"
	if [ -z "$yuming_list" ]; then
		read -e -p "删除站点数据，请输入你的域名（多个域名用空格隔开）: " yuming_list
		if [[ -z "$yuming_list" ]]; then
			return
		fi
	fi

	for yuming in $yuming_list; do
		echo "正在删除域名: $yuming"
		rm -r /home/web/html/$yuming > /dev/null 2>&1
		rm /home/web/conf.d/$yuming.conf > /dev/null 2>&1
		rm /home/web/certs/${yuming}_key.pem > /dev/null 2>&1
		rm /home/web/certs/${yuming}_cert.pem > /dev/null 2>&1

		# 将域名转换为数据库名
		dbname=$(echo "$yuming" | sed -e 's/[^A-Za-z0-9]/_/g')
		dbrootpasswd=$(sed -n -E 's/.*MYSQL_ROOT_PASSWORD:[[:space:]]*(.*)/\1/p' /home/web/docker-compose.yml | tr -d '[:space:]')

		# 删除数据库前检查是否存在，避免报错
		echo "正在删除数据库: $dbname"
		docker exec mysql mysql -u root -p"$dbrootpasswd" -e "DROP DATABASE ${dbname};" > /dev/null 2>&1
	done

	docker exec nginx nginx -s reload

}


nginx_waf() {
	local mode=$1

	if ! grep -q "kjlion/nginx:alpine" /home/web/docker-compose.yml; then
		wget -O /home/web/nginx.conf "${gh_proxy}raw.githubusercontent.com/riwi/nginx/main/nginx10.conf"
	fi

	# 根据 mode 参数来决定开启或关闭 WAF
	if [ "$mode" == "on" ]; then
		# 开启 WAF：去掉注释
		sed -i 's|# load_module /etc/nginx/modules/ngx_http_modsecurity_module.so;|load_module /etc/nginx/modules/ngx_http_modsecurity_module.so;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)# modsecurity on;|\1modsecurity on;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)# modsecurity_rules_file /etc/nginx/modsec/modsecurity.conf;|\1modsecurity_rules_file /etc/nginx/modsec/modsecurity.conf;|' /home/web/nginx.conf > /dev/null 2>&1
	elif [ "$mode" == "off" ]; then
		# 关闭 WAF：加上注释
		sed -i 's|^load_module /etc/nginx/modules/ngx_http_modsecurity_module.so;|# load_module /etc/nginx/modules/ngx_http_modsecurity_module.so;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)modsecurity on;|\1# modsecurity on;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)modsecurity_rules_file /etc/nginx/modsec/modsecurity.conf;|\1# modsecurity_rules_file /etc/nginx/modsec/modsecurity.conf;|' /home/web/nginx.conf > /dev/null 2>&1
	else
		echo "无效的参数：使用 'on' 或 'off'"
		return 1
	fi

	# 检查 nginx 镜像并根据情况处理
	if grep -q "kjlion/nginx:alpine" /home/web/docker-compose.yml; then
		docker exec nginx nginx -s reload
	else
		sed -i 's|nginx:alpine|kjlion/nginx:alpine|g' /home/web/docker-compose.yml
		nginx_upgrade
	fi

}

check_waf_status() {
	if grep -q "^[[:space:]]*#[[:space:]]*modsecurity on;" /home/web/nginx.conf; then
		waf_status=""
	elif grep -q "modsecurity on;" /home/web/nginx.conf; then
		waf_status=" WAF已开启"
	else
		waf_status=""
	fi
}


check_cf_mode() {
	if [ -f "/etc/fail2ban/action.d/cloudflare-docker.conf" ]; then
		CFmessage=" cf模式已开启"
	else
		CFmessage=""
	fi
}


nginx_http_on() {

local ipv4_pattern='^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'
local ipv6_pattern='^(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|(2[0-4][0-9]|[01]?[0-9][0-9]?))|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|(2[0-4][0-9]|[01]?[0-9][0-9]?))|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|(2[0-4][0-9]|[01]?[0-9][0-9]?))|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|(2[0-4][0-9]|[01]?[0-9][0-9]?))))$'
if [[ ($yuming =~ $ipv4_pattern || $yuming =~ $ipv6_pattern) ]]; then
	sed -i '/if (\$scheme = http) {/,/}/s/^/#/' /home/web/conf.d/${yuming}.conf
fi

}


patch_wp_memory_limit() {
  local MEMORY_LIMIT="${1:-256M}"      # 第一个参数，默认256M
  local MAX_MEMORY_LIMIT="${2:-256M}"  # 第二个参数，默认256M
  local TARGET_DIR="/home/web/html"    # 路径写死

  find "$TARGET_DIR" -type f -name "wp-config.php" | while read -r FILE; do
	# 删除旧定义
	sed -i "/define(['\"]WP_MEMORY_LIMIT['\"].*/d" "$FILE"
	sed -i "/define(['\"]WP_MAX_MEMORY_LIMIT['\"].*/d" "$FILE"

	# 插入新定义，放在含 "Happy publishing" 的行前
	awk -v insert="define('WP_MEMORY_LIMIT', '$MEMORY_LIMIT');\ndefine('WP_MAX_MEMORY_LIMIT', '$MAX_MEMORY_LIMIT');" \
	'
	  /Happy publishing/ {
		print insert
	  }
	  { print }
	' "$FILE" > "$FILE.tmp" && mv -f "$FILE.tmp" "$FILE"

	echo "[+] Replaced WP_MEMORY_LIMIT in $FILE"
  done
}




patch_wp_debug() {
  local DEBUG="${1:-false}"           # 第一个参数，默认false
  local DEBUG_DISPLAY="${2:-false}"   # 第二个参数，默认false
  local DEBUG_LOG="${3:-false}"       # 第三个参数，默认false
  local TARGET_DIR="/home/web/html"   # 路径写死

  find "$TARGET_DIR" -type f -name "wp-config.php" | while read -r FILE; do
	# 删除旧定义
	sed -i "/define(['\"]WP_DEBUG['\"].*/d" "$FILE"
	sed -i "/define(['\"]WP_DEBUG_DISPLAY['\"].*/d" "$FILE"
	sed -i "/define(['\"]WP_DEBUG_LOG['\"].*/d" "$FILE"

	# 插入新定义，放在含 "Happy publishing" 的行前
	awk -v insert="define('WP_DEBUG_DISPLAY', $DEBUG_DISPLAY);\ndefine('WP_DEBUG_LOG', $DEBUG_LOG);" \
	'
	  /Happy publishing/ {
		print insert
	  }
	  { print }
	' "$FILE" > "$FILE.tmp" && mv -f "$FILE.tmp" "$FILE"

	echo "[+] Replaced WP_DEBUG settings in $FILE"
  done
}




patch_wp_url() {
  local HOME_URL="$1"
  local SITE_URL="$2"
  local TARGET_DIR="/home/web/html"

  find "$TARGET_DIR" -type f -name "wp-config-sample.php" | while read -r FILE; do
	# 删除旧定义
	sed -i "/define(['\"]WP_HOME['\"].*/d" "$FILE"
	sed -i "/define(['\"]WP_SITEURL['\"].*/d" "$FILE"

	# 生成插入内容
	INSERT="
define('WP_HOME', '$HOME_URL');
define('WP_SITEURL', '$SITE_URL');
"

	# 插入到 “Happy publishing” 之前
	awk -v insert="$INSERT" '
	  /Happy publishing/ {
		print insert
	  }
	  { print }
	' "$FILE" > "$FILE.tmp" && mv -f "$FILE.tmp" "$FILE"

	echo "[+] Updated WP_HOME and WP_SITEURL in $FILE"
  done
}








nginx_br() {

	local mode=$1

	if ! grep -q "kjlion/nginx:alpine" /home/web/docker-compose.yml; then
		wget -O /home/web/nginx.conf "${gh_proxy}raw.githubusercontent.com/riwi/nginx/main/nginx10.conf"
	fi

	if [ "$mode" == "on" ]; then
		# 开启 Brotli：去掉注释
		sed -i 's|# load_module /etc/nginx/modules/ngx_http_brotli_filter_module.so;|load_module /etc/nginx/modules/ngx_http_brotli_filter_module.so;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|# load_module /etc/nginx/modules/ngx_http_brotli_static_module.so;|load_module /etc/nginx/modules/ngx_http_brotli_static_module.so;|' /home/web/nginx.conf > /dev/null 2>&1

		sed -i 's|^\(\s*\)# brotli on;|\1brotli on;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)# brotli_static on;|\1brotli_static on;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)# brotli_comp_level \(.*\);|\1brotli_comp_level \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)# brotli_buffers \(.*\);|\1brotli_buffers \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)# brotli_min_length \(.*\);|\1brotli_min_length \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)# brotli_window \(.*\);|\1brotli_window \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)# brotli_types \(.*\);|\1brotli_types \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i '/brotli_types/,+6 s/^\(\s*\)#\s*/\1/' /home/web/nginx.conf

	elif [ "$mode" == "off" ]; then
		# 关闭 Brotli：加上注释
		sed -i 's|^load_module /etc/nginx/modules/ngx_http_brotli_filter_module.so;|# load_module /etc/nginx/modules/ngx_http_brotli_filter_module.so;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^load_module /etc/nginx/modules/ngx_http_brotli_static_module.so;|# load_module /etc/nginx/modules/ngx_http_brotli_static_module.so;|' /home/web/nginx.conf > /dev/null 2>&1

		sed -i 's|^\(\s*\)brotli on;|\1# brotli on;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)brotli_static on;|\1# brotli_static on;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)brotli_comp_level \(.*\);|\1# brotli_comp_level \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)brotli_buffers \(.*\);|\1# brotli_buffers \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)brotli_min_length \(.*\);|\1# brotli_min_length \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)brotli_window \(.*\);|\1# brotli_window \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)brotli_types \(.*\);|\1# brotli_types \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i '/brotli_types/,+6 {
			/^[[:space:]]*[^#[:space:]]/ s/^\(\s*\)/\1# /
		}' /home/web/nginx.conf

	else
		echo "无效的参数：使用 'on' 或 'off'"
		return 1
	fi

	# 检查 nginx 镜像并根据情况处理
	if grep -q "kjlion/nginx:alpine" /home/web/docker-compose.yml; then
		docker exec nginx nginx -s reload
	else
		sed -i 's|nginx:alpine|kjlion/nginx:alpine|g' /home/web/docker-compose.yml
		nginx_upgrade
	fi


}



nginx_zstd() {

	local mode=$1

	if ! grep -q "kjlion/nginx:alpine" /home/web/docker-compose.yml; then
		wget -O /home/web/nginx.conf "${gh_proxy}raw.githubusercontent.com/riwi/nginx/main/nginx10.conf"
	fi

	if [ "$mode" == "on" ]; then
		# 开启 Zstd：去掉注释
		sed -i 's|# load_module /etc/nginx/modules/ngx_http_zstd_filter_module.so;|load_module /etc/nginx/modules/ngx_http_zstd_filter_module.so;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|# load_module /etc/nginx/modules/ngx_http_zstd_static_module.so;|load_module /etc/nginx/modules/ngx_http_zstd_static_module.so;|' /home/web/nginx.conf > /dev/null 2>&1

		sed -i 's|^\(\s*\)# zstd on;|\1zstd on;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)# zstd_static on;|\1zstd_static on;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)# zstd_comp_level \(.*\);|\1zstd_comp_level \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)# zstd_buffers \(.*\);|\1zstd_buffers \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)# zstd_min_length \(.*\);|\1zstd_min_length \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)# zstd_types \(.*\);|\1zstd_types \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i '/zstd_types/,+6 s/^\(\s*\)#\s*/\1/' /home/web/nginx.conf



	elif [ "$mode" == "off" ]; then
		# 关闭 Zstd：加上注释
		sed -i 's|^load_module /etc/nginx/modules/ngx_http_zstd_filter_module.so;|# load_module /etc/nginx/modules/ngx_http_zstd_filter_module.so;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^load_module /etc/nginx/modules/ngx_http_zstd_static_module.so;|# load_module /etc/nginx/modules/ngx_http_zstd_static_module.so;|' /home/web/nginx.conf > /dev/null 2>&1

		sed -i 's|^\(\s*\)zstd on;|\1# zstd on;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)zstd_static on;|\1# zstd_static on;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)zstd_comp_level \(.*\);|\1# zstd_comp_level \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)zstd_buffers \(.*\);|\1# zstd_buffers \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)zstd_min_length \(.*\);|\1# zstd_min_length \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)zstd_types \(.*\);|\1# zstd_types \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i '/zstd_types/,+6 {
			/^[[:space:]]*[^#[:space:]]/ s/^\(\s*\)/\1# /
		}' /home/web/nginx.conf


	else
		echo "无效的参数：使用 'on' 或 'off'"
		return 1
	fi

	# 检查 nginx 镜像并根据情况处理
	if grep -q "kjlion/nginx:alpine" /home/web/docker-compose.yml; then
		docker exec nginx nginx -s reload
	else
		sed -i 's|nginx:alpine|kjlion/nginx:alpine|g' /home/web/docker-compose.yml
		nginx_upgrade
	fi



}








nginx_gzip() {

	local mode=$1
	if [ "$mode" == "on" ]; then
		sed -i 's|^\(\s*\)# gzip on;|\1gzip on;|' /home/web/nginx.conf > /dev/null 2>&1
	elif [ "$mode" == "off" ]; then
		sed -i 's|^\(\s*\)gzip on;|\1# gzip on;|' /home/web/nginx.conf > /dev/null 2>&1
	else
		echo "无效的参数：使用 'on' 或 'off'"
		return 1
	fi

	docker exec nginx nginx -s reload

}






web_security() {
	  send_stats "LDNMP环境防御"
	  while true; do
		check_f2b_status
		check_waf_status
		check_cf_mode
			  clear
			  echo -e "${rw_cheng}━━━━━━━━━━━━  安全防御  ━━━━━━━━━━━━${rw_lv}"
			  echo -e " ${check_f2b_status}${rw_lv}${CFmessage}${waf_status}${rw_lv}"
			  echo ""
			  echo -e " ${rw_lv}──── 防御${rw_lv}"
			  echo -e " ${rw_huang}1${rw_lv}  安装防御    ${rw_huang}9${rw_lv}  卸载防御"
			  echo ""
			  echo -e " ${rw_lv}──── 拦截${rw_lv}"
			  echo -e " ${rw_huang}5${rw_lv}  SSH拦截      ${rw_huang}6${rw_lv}  网站拦截"
			  echo -e " ${rw_huang}7${rw_lv}  规则列表      ${rw_huang}8${rw_lv}  实时监控"
			  echo -e " ${rw_huang}11${rw_lv} 配置参数      ${rw_huang}12${rw_lv} 清除IP"
			  echo ""
			  echo -e " ${rw_lv}──── CF/WAF${rw_lv}"
			  echo -e " ${rw_huang}21${rw_lv} Cloudflare模式  ${rw_huang}22${rw_lv} 5秒盾"
			  echo -e " ${rw_huang}31${rw_lv} 开启WAF        ${rw_huang}32${rw_lv} 关闭WAF"
			  echo -e " ${rw_huang}33${rw_lv} DDOS防御       ${rw_huang}34${rw_lv} 关闭DDOS"
			  echo ""
			  echo -e " ${rw_cheng}────────────────────────────────────────${rw_lv}"
			  echo -e " ${rw_huang}0${rw_lv}  返回"
			  echo -e " ${rw_cheng}────────────────────────────────────────${rw_lv}"
			  read -e -p " 请选择: " sub_choice
			  case $sub_choice in
				  1)
					  f2b_install_sshd
					  cd /etc/fail2ban/filter.d
					  curl -sS -O ${gh_proxy}raw.githubusercontent.com/riwi/sh/main/fail2ban-nginx-cc.conf
					  wget ${gh_proxy}raw.githubusercontent.com/linuxserver/fail2ban-confs/master/filter.d/nginx-418.conf
					  wget ${gh_proxy}raw.githubusercontent.com/linuxserver/fail2ban-confs/master/filter.d/nginx-deny.conf
					  wget ${gh_proxy}raw.githubusercontent.com/linuxserver/fail2ban-confs/master/filter.d/nginx-unauthorized.conf
					  wget ${gh_proxy}raw.githubusercontent.com/linuxserver/fail2ban-confs/master/filter.d/nginx-bad-request.conf

					  cd /etc/fail2ban/jail.d/
					  curl -sS -O ${gh_proxy}raw.githubusercontent.com/riwi/config/main/fail2ban/nginx-docker-cc.conf
					  sed -i "/cloudflare/d" /etc/fail2ban/jail.d/nginx-docker-cc.conf
					  f2b_status
					  ;;
				  5)
					  echo -e "${rw_cheng}------------------------${rw_lv}"
					  f2b_sshd
					  echo -e "${rw_cheng}------------------------${rw_lv}"
					  ;;
				  6)

					  echo -e "${rw_cheng}------------------------${rw_lv}"
					  local xxx="fail2ban-nginx-cc"
					  f2b_status_xxx
					  echo -e "${rw_cheng}------------------------${rw_lv}"
					  local xxx="nginx-418"
					  f2b_status_xxx
					  echo -e "${rw_cheng}------------------------${rw_lv}"
					  local xxx="nginx-bad-request"
					  f2b_status_xxx
					  echo -e "${rw_cheng}------------------------${rw_lv}"
					  local xxx="nginx-badbots"
					  f2b_status_xxx
					  echo -e "${rw_cheng}------------------------${rw_lv}"
					  local xxx="nginx-botsearch"
					  f2b_status_xxx
					  echo -e "${rw_cheng}------------------------${rw_lv}"
					  local xxx="nginx-deny"
					  f2b_status_xxx
					  echo -e "${rw_cheng}------------------------${rw_lv}"
					  local xxx="nginx-http-auth"
					  f2b_status_xxx
					  echo -e "${rw_cheng}------------------------${rw_lv}"
					  local xxx="nginx-unauthorized"
					  f2b_status_xxx
					  echo -e "${rw_cheng}------------------------${rw_lv}"
					  local xxx="php-url-fopen"
					  f2b_status_xxx
					  echo -e "${rw_cheng}------------------------${rw_lv}"

					  ;;

				  7)
					  fail2ban-client status
					  ;;
				  8)
					  tail -f /var/log/fail2ban.log

					  ;;
				  9)
					  remove fail2ban
					  rm -rf /etc/fail2ban
					  crontab -l | grep -v "CF-Under-Attack.sh" | crontab - 2>/dev/null
					  echo "Fail2Ban防御程序已卸载"
					  break
					  ;;

				  11)
					  install nano
					  nano /etc/fail2ban/jail.d/nginx-docker-cc.conf
					  f2b_status
					  break
					  ;;

				  12)
					  fail2ban-client unban --all
					  ;;

				  21)
					  send_stats "cloudflare模式"
					  echo "到cf后台右上角我的个人资料，选择左侧API令牌，获取Global API Key"
					  echo "https://dash.cloudflare.com/login"
					  read -e -p "输入CF的账号: " cfuser
					  read -e -p "输入CF的Global API Key: " cftoken

					  wget -O /home/web/conf.d/default.conf ${gh_proxy}raw.githubusercontent.com/riwi/nginx/main/default11.conf
					  docker exec nginx nginx -s reload

					  cd /etc/fail2ban/jail.d/
					  curl -sS -O ${gh_proxy}raw.githubusercontent.com/riwi/config/main/fail2ban/nginx-docker-cc.conf

					  cd /etc/fail2ban/action.d
					  curl -sS -O ${gh_proxy}raw.githubusercontent.com/riwi/config/main/fail2ban/cloudflare-docker.conf

					  sed -i "s/riwi@outlook.com/$cfuser/g" /etc/fail2ban/action.d/cloudflare-docker.conf
					  sed -i "s/APIKEY00000/$cftoken/g" /etc/fail2ban/action.d/cloudflare-docker.conf
					  f2b_status

					  echo "已配置cloudflare模式，可在cf后台，站点-安全性-事件中查看拦截记录"
					  ;;

				  22)
					  send_stats "高负载开启5秒盾"
					  echo -e "${rw_huang}网站每5分钟自动检测，当达检测到高负载会自动开盾，低负载也会自动关闭5秒盾。${rw_lv}"
					  echo -e "${rw_cheng}--------------${rw_lv}"
					  echo "获取CF参数: "
					  echo -e "到cf后台右上角我的个人资料，选择左侧API令牌，获取${rw_huang}Global API Key${rw_lv}"
					  echo -e "到cf后台域名概要页面右下方获取${rw_huang}区域ID${rw_lv}"
					  echo "https://dash.cloudflare.com/login"
					  echo -e "${rw_cheng}--------------${rw_lv}"
					  read -e -p "输入CF的账号: " cfuser
					  read -e -p "输入CF的Global API Key: " cftoken
					  read -e -p "输入CF中域名的区域ID: " cfzonID

					  cd ~
					  install jq bc
					  check_crontab_installed
					  curl -sS -O ${gh_proxy}raw.githubusercontent.com/riwi/sh/main/CF-Under-Attack.sh
					  chmod +x CF-Under-Attack.sh
					  sed -i "s/AAAA/$cfuser/g" ~/CF-Under-Attack.sh
					  sed -i "s/BBBB/$cftoken/g" ~/CF-Under-Attack.sh
					  sed -i "s/CCCC/$cfzonID/g" ~/CF-Under-Attack.sh

					  local cron_job="*/5 * * * * ~/CF-Under-Attack.sh"

					  local existing_cron=$(crontab -l 2>/dev/null | grep -F "$cron_job")

					  if [ -z "$existing_cron" ]; then
						  (crontab -l 2>/dev/null; echo "$cron_job") | crontab -
						  echo "高负载自动开盾脚本已添加"
					  else
						  echo "自动开盾脚本已存在，无需添加"
					  fi

					  ;;

				  31)
					  nginx_waf on
					  echo "站点WAF已开启"
					  send_stats "站点WAF已开启"
					  ;;

				  32)
				  	  nginx_waf off
					  echo "站点WAF已关闭"
					  send_stats "站点WAF已关闭"
					  ;;

				  33)
					  enable_ddos_defense
					  ;;

				  34)
					  disable_ddos_defense
					  ;;

				  *)
					  break
					  ;;
			  esac
	  break_end
	  done
}



check_ldnmp_mode() {

	local MYSQL_CONTAINER="mysql"
	local MYSQL_CONF="/etc/mysql/conf.d/custom_mysql_config.cnf"

	# 检查 MySQL 配置文件中是否包含 4096M
	if docker exec "$MYSQL_CONTAINER" grep -q "4096M" "$MYSQL_CONF" 2>/dev/null; then
		mode_info=" 高性能模式"
	else
		mode_info=" 标准模式"
	fi



}


check_nginx_compression() {

	local CONFIG_FILE="/home/web/nginx.conf"

	# 检查 zstd 是否开启且未被注释（整行以 zstd on; 开头）
	if grep -qE '^[[:space:]]*zstd[[:space:]]+on;' "$CONFIG_FILE"; then
		zstd_status=" zstd压缩已开启"
	else
		zstd_status=""
	fi

	# 检查 brotli 是否开启且未被注释
	if grep -qE '^[[:space:]]*brotli[[:space:]]+on;' "$CONFIG_FILE"; then
		br_status=" br压缩已开启"
	else
		br_status=""
	fi

	# 检查 gzip 是否开启且未被注释
	if grep -qE '^[[:space:]]*gzip[[:space:]]+on;' "$CONFIG_FILE"; then
		gzip_status=" gzip压缩已开启"
	else
		gzip_status=""
	fi
}




web_optimization() {
		  while true; do
		  	  check_ldnmp_mode
			  check_nginx_compression
			  clear
			  send_stats "优化LDNMP环境"
			  echo -e "${rw_cheng}━━━━━━━━━━━━  压缩与性能  ━━━━━━━━━━━━${rw_lv}"
			  echo -e " 模式${rw_lv}${mode_info}${rw_lv}  ${rw_lv}${gzip_status}${br_status}${zstd_status}${rw_lv}"
			  echo ""
			  echo -e " ${rw_lv}──── 模式${rw_lv}"
			  echo -e " ${rw_huang}1${rw_lv}  标准模式        ${rw_huang}2${rw_lv}  高性能模式 (2H4G+)"
			  echo ""
			  echo -e " ${rw_lv}──── 压缩${rw_lv}"
			  echo -e " ${rw_huang}3${rw_lv}  开启gzip    ${rw_huang}4${rw_lv}  关闭gzip    ${rw_huang}5${rw_lv}  开启br    ${rw_huang}6${rw_lv}  关闭br"
			  echo -e " ${rw_huang}7${rw_lv}  开启zstd    ${rw_huang}8${rw_lv}  关闭zstd"
			  echo ""
			  echo -e " ${rw_cheng}────────────────────────────────────────${rw_lv}"
			  echo -e " ${rw_huang}0${rw_lv}  返回"
			  echo -e " ${rw_cheng}────────────────────────────────────────${rw_lv}"
			  read -e -p " 请选择: " sub_choice
			  case $sub_choice in
				  1)
				  send_stats "站点标准模式"

				  local cpu_cores=$(nproc)
				  local connections=$((1024 * ${cpu_cores}))
				  sed -i "s/worker_processes.*/worker_processes ${cpu_cores};/" /home/web/nginx.conf
				  sed -i "s/worker_connections.*/worker_connections ${connections};/" /home/web/nginx.conf


				  # php调优
				  wget -O /home/optimized_php.ini ${gh_proxy}raw.githubusercontent.com/riwi/sh/main/optimized_php.ini
				  docker cp /home/optimized_php.ini php:/usr/local/etc/php/conf.d/optimized_php.ini
				  docker cp /home/optimized_php.ini php74:/usr/local/etc/php/conf.d/optimized_php.ini
				  rm -rf /home/optimized_php.ini

				  # php调优
				  wget -O /home/www.conf ${gh_proxy}raw.githubusercontent.com/riwi/sh/main/www-1.conf
				  docker cp /home/www.conf php:/usr/local/etc/php-fpm.d/www.conf
				  docker cp /home/www.conf php74:/usr/local/etc/php-fpm.d/www.conf
				  rm -rf /home/www.conf

				  patch_wp_memory_limit
				  patch_wp_debug

				  fix_phpfpm_conf php
				  fix_phpfpm_conf php74

				  # mysql调优
				  wget -O /home/custom_mysql_config.cnf ${gh_proxy}raw.githubusercontent.com/riwi/sh/main/custom_mysql_config-1.cnf
				  docker cp /home/custom_mysql_config.cnf mysql:/etc/mysql/conf.d/
				  rm -rf /home/custom_mysql_config.cnf


				  cd /home/web && docker compose restart

				  optimize_balanced


				  echo "LDNMP环境已设置成 标准模式"

					  ;;
				  2)
				  send_stats "站点高性能模式"

				  # nginx调优
				  local cpu_cores=$(nproc)
				  local connections=$((2048 * ${cpu_cores}))
				  sed -i "s/worker_processes.*/worker_processes ${cpu_cores};/" /home/web/nginx.conf
				  sed -i "s/worker_connections.*/worker_connections ${connections};/" /home/web/nginx.conf

				  # php调优
				  wget -O /home/optimized_php.ini ${gh_proxy}raw.githubusercontent.com/riwi/sh/main/optimized_php.ini
				  docker cp /home/optimized_php.ini php:/usr/local/etc/php/conf.d/optimized_php.ini
				  docker cp /home/optimized_php.ini php74:/usr/local/etc/php/conf.d/optimized_php.ini
				  rm -rf /home/optimized_php.ini

				  # php调优
				  wget -O /home/www.conf ${gh_proxy}raw.githubusercontent.com/riwi/sh/main/www.conf
				  docker cp /home/www.conf php:/usr/local/etc/php-fpm.d/www.conf
				  docker cp /home/www.conf php74:/usr/local/etc/php-fpm.d/www.conf
				  rm -rf /home/www.conf

				  patch_wp_memory_limit 512M 512M
				  patch_wp_debug

				  fix_phpfpm_conf php
				  fix_phpfpm_conf php74

				  # mysql调优
				  wget -O /home/custom_mysql_config.cnf ${gh_proxy}raw.githubusercontent.com/riwi/sh/main/custom_mysql_config.cnf
				  docker cp /home/custom_mysql_config.cnf mysql:/etc/mysql/conf.d/
				  rm -rf /home/custom_mysql_config.cnf

				  cd /home/web && docker compose restart

				  optimize_web_server

				  echo "LDNMP环境已设置成 高性能模式"

					  ;;
				  3)
				  send_stats "nginx_gzip on"
				  nginx_gzip on
					  ;;
				  4)
				  send_stats "nginx_gzip off"
				  nginx_gzip off
					  ;;
				  5)
				  send_stats "nginx_br on"
				  nginx_br on
					  ;;
				  6)
				  send_stats "nginx_br off"
				  nginx_br off
					  ;;
				  7)
				  send_stats "nginx_zstd on"
				  nginx_zstd on
					  ;;
				  8)
				  send_stats "nginx_zstd off"
				  nginx_zstd off
					  ;;
				  *)
					  break
					  ;;
			  esac
			  break_end

		  done


}










check_docker_app() {
	if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -q "$docker_name" ; then
		check_docker="${rw_lv}已安装${rw_lv}"
	else
		check_docker="${rw_lv}未安装${rw_lv}"
	fi
}



# check_docker_app() {

# if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -q "$docker_name"; then
# 	check_docker="${rw_lv}已安装${rw_lv}"
# else
# 	check_docker="${rw_lv}未安装${rw_lv}"
# fi

# }


check_docker_app_ip() {
echo -e "${rw_cheng}------------------------${rw_lv}"
echo "访问地址:"
ip_address



if [ -n "$ipv4_address" ]; then
	echo "http://$ipv4_address:${docker_port}"
fi

if [ -n "$ipv6_address" ]; then
	echo "http://[$ipv6_address]:${docker_port}"
fi

local search_pattern1="$ipv4_address:${docker_port}"
local search_pattern2="127.0.0.1:${docker_port}"

for file in /home/web/conf.d/*; do
	if [ -f "$file" ]; then
		if grep -q "$search_pattern1" "$file" 2>/dev/null || grep -q "$search_pattern2" "$file" 2>/dev/null; then
			echo "https://$(basename "$file" | sed 's/\.conf$//')"
		fi
	fi
done


}


check_docker_image_update() {
	local container_name=$1
	update_status=""

	# 1. 区域检查
	local country=$(curl -s --max-time 2 ipinfo.io/country)
	[[ "$country" == "CN" ]] && return

	# 2. 获取本地镜像信息
	local container_info=$(docker inspect --format='{{.Created}},{{.Config.Image}}' "$container_name" 2>/dev/null)
	[[ -z "$container_info" ]] && return

	local container_created=$(echo "$container_info" | cut -d',' -f1)
	local full_image_name=$(echo "$container_info" | cut -d',' -f2)
	local container_created_ts=$(portable_date_to_timestamp "$container_created")

	# 3. 智能路由判断
	if [[ "$full_image_name" == ghcr.io* ]]; then
		# --- 场景 A: 镜像在 GitHub (ghcr.io) ---
		# 提取仓库路径，例如 ghcr.io/onexru/oneimg -> onexru/oneimg
		local repo_path=$(echo "$full_image_name" | sed 's/ghcr.io\///' | cut -d':' -f1)
		# 注意：ghcr.io 的 API 比较复杂，通常最快的方法是查 GitHub Repo 的 Release
		local api_url="https://api.github.com/repos/$repo_path/releases/latest"
		local remote_date=$(curl -s "$api_url" | jq -r '.published_at' 2>/dev/null)

	elif [[ "$full_image_name" == *"oneimg"* ]]; then
		# --- 场景 B: 特殊指定 (即便在 Docker Hub，也想通过 GitHub Release 判断) ---
		local api_url="https://api.github.com/repos/onexru/oneimg/releases/latest"
		local remote_date=$(curl -s "$api_url" | jq -r '.published_at' 2>/dev/null)

	else
		# --- 场景 C: 标准 Docker Hub ---
		local image_repo=${full_image_name%%:*}
		local image_tag=${full_image_name##*:}
		[[ "$image_repo" == "$image_tag" ]] && image_tag="latest"
		[[ "$image_repo" != */* ]] && image_repo="library/$image_repo"

		local api_url="https://hub.docker.com/v2/repositories/$image_repo/tags/$image_tag"
		local remote_date=$(curl -s "$api_url" | jq -r '.last_updated' 2>/dev/null)
	fi

	# 4. 时间戳对比
	if [[ -n "$remote_date" && "$remote_date" != "null" ]]; then
		local remote_ts=$(portable_date_to_timestamp "$remote_date")
		if [[ $container_created_ts -lt $remote_ts ]]; then
			update_status="${rw_huang}发现新版本!${rw_lv}"
		fi
	fi
}







block_container_port() {
	local container_name_or_id=$1
	local allowed_ip=$2

	# 获取容器的 IP 地址
	local container_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$container_name_or_id")

	if [ -z "$container_ip" ]; then
		return 1
	fi

	install iptables


	# 检查并封禁其他所有 IP
	if ! iptables -C DOCKER-USER -p tcp -d "$container_ip" -j DROP &>/dev/null; then
		iptables -I DOCKER-USER -p tcp -d "$container_ip" -j DROP
	fi

	# 检查并放行指定 IP
	if ! iptables -C DOCKER-USER -p tcp -s "$allowed_ip" -d "$container_ip" -j ACCEPT &>/dev/null; then
		iptables -I DOCKER-USER -p tcp -s "$allowed_ip" -d "$container_ip" -j ACCEPT
	fi

	# 检查并放行本地网络 127.0.0.0/8
	if ! iptables -C DOCKER-USER -p tcp -s 127.0.0.0/8 -d "$container_ip" -j ACCEPT &>/dev/null; then
		iptables -I DOCKER-USER -p tcp -s 127.0.0.0/8 -d "$container_ip" -j ACCEPT
	fi



	# 检查并封禁其他所有 IP
	if ! iptables -C DOCKER-USER -p udp -d "$container_ip" -j DROP &>/dev/null; then
		iptables -I DOCKER-USER -p udp -d "$container_ip" -j DROP
	fi

	# 检查并放行指定 IP
	if ! iptables -C DOCKER-USER -p udp -s "$allowed_ip" -d "$container_ip" -j ACCEPT &>/dev/null; then
		iptables -I DOCKER-USER -p udp -s "$allowed_ip" -d "$container_ip" -j ACCEPT
	fi

	# 检查并放行本地网络 127.0.0.0/8
	if ! iptables -C DOCKER-USER -p udp -s 127.0.0.0/8 -d "$container_ip" -j ACCEPT &>/dev/null; then
		iptables -I DOCKER-USER -p udp -s 127.0.0.0/8 -d "$container_ip" -j ACCEPT
	fi

	if ! iptables -C DOCKER-USER -m state --state ESTABLISHED,RELATED -d "$container_ip" -j ACCEPT &>/dev/null; then
		iptables -I DOCKER-USER -m state --state ESTABLISHED,RELATED -d "$container_ip" -j ACCEPT
	fi


	echo "已阻止IP+端口访问该服务"
	save_iptables_rules
}




clear_container_rules() {
	local container_name_or_id=$1
	local allowed_ip=$2

	# 获取容器的 IP 地址
	local container_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$container_name_or_id")

	if [ -z "$container_ip" ]; then
		return 1
	fi

	install iptables


	# 清除封禁其他所有 IP 的规则
	if iptables -C DOCKER-USER -p tcp -d "$container_ip" -j DROP &>/dev/null; then
		iptables -D DOCKER-USER -p tcp -d "$container_ip" -j DROP
	fi

	# 清除放行指定 IP 的规则
	if iptables -C DOCKER-USER -p tcp -s "$allowed_ip" -d "$container_ip" -j ACCEPT &>/dev/null; then
		iptables -D DOCKER-USER -p tcp -s "$allowed_ip" -d "$container_ip" -j ACCEPT
	fi

	# 清除放行本地网络 127.0.0.0/8 的规则
	if iptables -C DOCKER-USER -p tcp -s 127.0.0.0/8 -d "$container_ip" -j ACCEPT &>/dev/null; then
		iptables -D DOCKER-USER -p tcp -s 127.0.0.0/8 -d "$container_ip" -j ACCEPT
	fi





	# 清除封禁其他所有 IP 的规则
	if iptables -C DOCKER-USER -p udp -d "$container_ip" -j DROP &>/dev/null; then
		iptables -D DOCKER-USER -p udp -d "$container_ip" -j DROP
	fi

	# 清除放行指定 IP 的规则
	if iptables -C DOCKER-USER -p udp -s "$allowed_ip" -d "$container_ip" -j ACCEPT &>/dev/null; then
		iptables -D DOCKER-USER -p udp -s "$allowed_ip" -d "$container_ip" -j ACCEPT
	fi

	# 清除放行本地网络 127.0.0.0/8 的规则
	if iptables -C DOCKER-USER -p udp -s 127.0.0.0/8 -d "$container_ip" -j ACCEPT &>/dev/null; then
		iptables -D DOCKER-USER -p udp -s 127.0.0.0/8 -d "$container_ip" -j ACCEPT
	fi


	if iptables -C DOCKER-USER -m state --state ESTABLISHED,RELATED -d "$container_ip" -j ACCEPT &>/dev/null; then
		iptables -D DOCKER-USER -m state --state ESTABLISHED,RELATED -d "$container_ip" -j ACCEPT
	fi


	echo "已允许IP+端口访问该服务"
	save_iptables_rules
}






block_host_port() {
	local port=$1
	local allowed_ip=$2

	if [[ -z "$port" || -z "$allowed_ip" ]]; then
		echo "错误：请提供端口号和允许访问的 IP。"
		echo "用法: block_host_port <端口号> <允许的IP>"
		return 1
	fi

	install iptables


	# 拒绝其他所有 IP 访问
	if ! iptables -C INPUT -p tcp --dport "$port" -j DROP &>/dev/null; then
		iptables -I INPUT -p tcp --dport "$port" -j DROP
	fi

	# 允许指定 IP 访问
	if ! iptables -C INPUT -p tcp --dport "$port" -s "$allowed_ip" -j ACCEPT &>/dev/null; then
		iptables -I INPUT -p tcp --dport "$port" -s "$allowed_ip" -j ACCEPT
	fi

	# 允许本机访问
	if ! iptables -C INPUT -p tcp --dport "$port" -s 127.0.0.0/8 -j ACCEPT &>/dev/null; then
		iptables -I INPUT -p tcp --dport "$port" -s 127.0.0.0/8 -j ACCEPT
	fi





	# 拒绝其他所有 IP 访问
	if ! iptables -C INPUT -p udp --dport "$port" -j DROP &>/dev/null; then
		iptables -I INPUT -p udp --dport "$port" -j DROP
	fi

	# 允许指定 IP 访问
	if ! iptables -C INPUT -p udp --dport "$port" -s "$allowed_ip" -j ACCEPT &>/dev/null; then
		iptables -I INPUT -p udp --dport "$port" -s "$allowed_ip" -j ACCEPT
	fi

	# 允许本机访问
	if ! iptables -C INPUT -p udp --dport "$port" -s 127.0.0.0/8 -j ACCEPT &>/dev/null; then
		iptables -I INPUT -p udp --dport "$port" -s 127.0.0.0/8 -j ACCEPT
	fi

	# 允许已建立和相关连接的流量
	if ! iptables -C INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT &>/dev/null; then
		iptables -I INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
	fi

	echo "已阻止IP+端口访问该服务"
	save_iptables_rules
}




clear_host_port_rules() {
	local port=$1
	local allowed_ip=$2

	if [[ -z "$port" || -z "$allowed_ip" ]]; then
		echo "错误：请提供端口号和允许访问的 IP。"
		echo "用法: clear_host_port_rules <端口号> <允许的IP>"
		return 1
	fi

	install iptables


	# 清除封禁所有其他 IP 访问的规则
	if iptables -C INPUT -p tcp --dport "$port" -j DROP &>/dev/null; then
		iptables -D INPUT -p tcp --dport "$port" -j DROP
	fi

	# 清除允许本机访问的规则
	if iptables -C INPUT -p tcp --dport "$port" -s 127.0.0.0/8 -j ACCEPT &>/dev/null; then
		iptables -D INPUT -p tcp --dport "$port" -s 127.0.0.0/8 -j ACCEPT
	fi

	# 清除允许指定 IP 访问的规则
	if iptables -C INPUT -p tcp --dport "$port" -s "$allowed_ip" -j ACCEPT &>/dev/null; then
		iptables -D INPUT -p tcp --dport "$port" -s "$allowed_ip" -j ACCEPT
	fi


	# 清除封禁所有其他 IP 访问的规则
	if iptables -C INPUT -p udp --dport "$port" -j DROP &>/dev/null; then
		iptables -D INPUT -p udp --dport "$port" -j DROP
	fi

	# 清除允许本机访问的规则
	if iptables -C INPUT -p udp --dport "$port" -s 127.0.0.0/8 -j ACCEPT &>/dev/null; then
		iptables -D INPUT -p udp --dport "$port" -s 127.0.0.0/8 -j ACCEPT
	fi

	# 清除允许指定 IP 访问的规则
	if iptables -C INPUT -p udp --dport "$port" -s "$allowed_ip" -j ACCEPT &>/dev/null; then
		iptables -D INPUT -p udp --dport "$port" -s "$allowed_ip" -j ACCEPT
	fi


	echo "已允许IP+端口访问该服务"
	save_iptables_rules

}



setup_docker_dir() {

	mkdir -p /home /home/docker 2>/dev/null

	if [ -d "/vol1/1000/" ] && [ ! -d "/vol1/1000/docker" ]; then
		cp -f /home/docker /home/docker1 2>/dev/null
		rm -rf /home/docker 2>/dev/null
		mkdir -p /vol1/1000/docker 2>/dev/null
		ln -s /vol1/1000/docker /home/docker 2>/dev/null
	fi

	if [ -d "/volume1/" ] && [ ! -d "/volume1/docker" ]; then
		cp -f /home/docker /home/docker1 2>/dev/null
		rm -rf /home/docker 2>/dev/null
		mkdir -p /volume1/docker 2>/dev/null
		ln -s /volume1/docker /home/docker 2>/dev/null
	fi


}


add_app_id() {
mkdir -p /home/docker
touch /home/docker/appno.txt
grep -qxF "${app_id}" /home/docker/appno.txt || echo "${app_id}" >> /home/docker/appno.txt

}



docker_app() {
send_stats "${docker_name}管理"

while true; do
	clear
	check_docker_app
	check_docker_image_update $docker_name
	echo -e "$docker_name $check_docker $update_status"
	echo "$docker_describe"
	echo "$docker_url"
	if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -q "$docker_name"; then
		if [ ! -f "/home/docker/${docker_name}_port.conf" ]; then
			local docker_port=$(docker port "$docker_name" | head -n1 | awk -F'[:]' '/->/ {print $NF; exit}')
			docker_port=${docker_port:-0000}
			echo "$docker_port" > "/home/docker/${docker_name}_port.conf"
		fi
		local docker_port=$(cat "/home/docker/${docker_name}_port.conf")
		check_docker_app_ip
	fi
	echo ""
	echo -e "${rw_cheng}------------------------${rw_lv}"
	echo "1. 安装              2. 更新            3. 卸载"
	echo -e "${rw_cheng}------------------------${rw_lv}"
	echo "5. 添加域名访问      6. 删除域名访问"
	echo "7. 允许IP+端口访问   8. 阻止IP+端口访问"
	echo -e "${rw_cheng}------------------------${rw_lv}"
	echo "0. 返回上一级选单"
	echo -e "${rw_cheng}------------------------${rw_lv}"
	read -e -p "请输入你的选择: " choice
	 case $choice in
		1)
			setup_docker_dir
			check_disk_space $app_size /home/docker
			while true; do
				read -e -p "输入应用对外服务端口，回车默认使用${docker_port}端口: " app_port
				local app_port=${app_port:-${docker_port}}

				if ss -tuln | grep -q ":$app_port "; then
					echo -e "${rw_hong}错误: ${rw_lv}端口 $app_port 已被占用，请更换一个端口"
					send_stats "应用端口已被占用"
				else
					local docker_port=$app_port
					break
				fi
			done

			install jq
			install_docker
			docker_rum
			echo "$docker_port" > "/home/docker/${docker_name}_port.conf"

			add_app_id

			clear
			echo "$docker_name 已经安装完成"
			check_docker_app_ip
			echo ""
			$docker_use
			$docker_passwd
			send_stats "安装$docker_name"
			;;
		2)
			docker rm -f "$docker_name"
			docker rmi -f "$docker_img"
			docker_rum

			add_app_id

			clear
			echo "$docker_name 已经安装完成"
			check_docker_app_ip
			echo ""
			$docker_use
			$docker_passwd
			send_stats "更新$docker_name"
			;;
		3)
			docker rm -f "$docker_name"
			docker rmi -f "$docker_img"
			rm -rf "/home/docker/$docker_name"
			rm -f /home/docker/${docker_name}_port.conf

			sed -i "/\b${app_id}\b/d" /home/docker/appno.txt
			echo "应用已卸载"
			send_stats "卸载$docker_name"
			;;

		5)
			echo "${docker_name}域名访问设置"
			send_stats "${docker_name}域名访问设置"
			add_yuming
			ldnmp_Proxy ${yuming} 127.0.0.1 ${docker_port}
			block_container_port "$docker_name" "$ipv4_address"
			;;

		6)
			echo "域名格式 example.com 不带https://"
			web_del
			;;

		7)
			send_stats "允许IP访问 ${docker_name}"
			clear_container_rules "$docker_name" "$ipv4_address"
			;;

		8)
			send_stats "阻止IP访问 ${docker_name}"
			block_container_port "$docker_name" "$ipv4_address"
			;;

		*)
			break
			;;
	 esac
	 break_end
done

}





docker_app_plus() {
	send_stats "$app_name"
	while true; do
		clear
		check_docker_app
		check_docker_image_update $docker_name
		echo -e "$app_name $check_docker $update_status"
		echo "$app_text"
		echo "$app_url"
		if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -q "$docker_name"; then
			if [ ! -f "/home/docker/${docker_name}_port.conf" ]; then
				local docker_port=$(docker port "$docker_name" | head -n1 | awk -F'[:]' '/->/ {print $NF; exit}')
				docker_port=${docker_port:-0000}
				echo "$docker_port" > "/home/docker/${docker_name}_port.conf"
			fi
			local docker_port=$(cat "/home/docker/${docker_name}_port.conf")
			check_docker_app_ip
		fi
		echo ""
		echo -e "${rw_cheng}------------------------${rw_lv}"
		echo "1. 安装             2. 更新             3. 卸载"
		echo -e "${rw_cheng}------------------------${rw_lv}"
		echo "5. 添加域名访问     6. 删除域名访问"
		echo "7. 允许IP+端口访问  8. 阻止IP+端口访问"
		echo -e "${rw_cheng}------------------------${rw_lv}"
		echo "0. 返回上一级选单"
		echo -e "${rw_cheng}------------------------${rw_lv}"
		read -e -p "输入你的选择: " choice
		case $choice in
			1)
				setup_docker_dir
				check_disk_space $app_size /home/docker

				while true; do
					read -e -p "输入应用对外服务端口，回车默认使用${docker_port}端口: " app_port
					local app_port=${app_port:-${docker_port}}

					if ss -tuln | grep -q ":$app_port "; then
						echo -e "${rw_hong}错误: ${rw_lv}端口 $app_port 已被占用，请更换一个端口"
						send_stats "应用端口已被占用"
					else
						local docker_port=$app_port
						break
					fi
				done

				install jq
				install_docker
				docker_app_install
				echo "$docker_port" > "/home/docker/${docker_name}_port.conf"

				add_app_id
				send_stats "$app_name 安装"
				;;

			2)
				docker_app_update
				add_app_id
				send_stats "$app_name 更新"
				;;

			3)
				docker_app_uninstall
				rm -f /home/docker/${docker_name}_port.conf

				sed -i "/\b${app_id}\b/d" /home/docker/appno.txt
				send_stats "$app_name 卸载"
				;;

			5)
				echo "${docker_name}域名访问设置"
				send_stats "${docker_name}域名访问设置"
				add_yuming
				ldnmp_Proxy ${yuming} 127.0.0.1 ${docker_port}
				block_container_port "$docker_name" "$ipv4_address"

				;;
			6)
				echo "域名格式 example.com 不带https://"
				web_del
				;;
			7)
				send_stats "允许IP访问 ${docker_name}"
				clear_container_rules "$docker_name" "$ipv4_address"
				;;
			8)
				send_stats "阻止IP访问 ${docker_name}"
				block_container_port "$docker_name" "$ipv4_address"
				;;
			*)
				break
				;;
		esac
		break_end
	done
}





prometheus_install() {

local PROMETHEUS_DIR="/home/docker/monitoring/prometheus"
local GRAFANA_DIR="/home/docker/monitoring/grafana"
local NETWORK_NAME="monitoring"

# Create necessary directories
mkdir -p $PROMETHEUS_DIR
mkdir -p $GRAFANA_DIR

# Set correct ownership for Grafana directory
chown -R 472:472 $GRAFANA_DIR

if [ ! -f "$PROMETHEUS_DIR/prometheus.yml" ]; then
	curl -o "$PROMETHEUS_DIR/prometheus.yml" ${gh_proxy}raw.githubusercontent.com/riwi/config/refs/heads/main/prometheus/prometheus.yml
fi

# Create Docker network for monitoring
docker network create $NETWORK_NAME

# Run Node Exporter container
docker run -d \
  --name=node-exporter \
  --network $NETWORK_NAME \
  --restart=always \
  prom/node-exporter

# Run Prometheus container
docker run -d \
  --name prometheus \
  -v $PROMETHEUS_DIR/prometheus.yml:/etc/prometheus/prometheus.yml \
  -v $PROMETHEUS_DIR/data:/prometheus \
  --network $NETWORK_NAME \
  --restart=always \
  --user 0:0 \
  prom/prometheus:latest

# Run Grafana container
docker run -d \
  --name grafana \
  -p ${docker_port}:3000 \
  -v $GRAFANA_DIR:/var/lib/grafana \
  --network $NETWORK_NAME \
  --restart=always \
  grafana/grafana:latest

}




tmux_run() {
	# Check if the session already exists
	tmux has-session -t $SESSION_NAME 2>/dev/null
	# $? is a special variable that holds the exit status of the last executed command
	if [ $? != 0 ]; then
	  # Session doesn't exist, create a new one
	  tmux new -s $SESSION_NAME
	else
	  # Session exists, attach to it
	  tmux attach-session -t $SESSION_NAME
	fi
}


tmux_run_d() {

local base_name="tmuxd"
local tmuxd_ID=1

# 检查会话是否存在的函数
session_exists() {
  tmux has-session -t $1 2>/dev/null
}

# 循环直到找到一个不存在的会话名称
while session_exists "$base_name-$tmuxd_ID"; do
  local tmuxd_ID=$((tmuxd_ID + 1))
done

# 创建新的 tmux 会话
tmux new -d -s "$base_name-$tmuxd_ID" "$tmuxd"


}



f2b_status() {
	 fail2ban-client reload
	 sleep 3
	 fail2ban-client status
}

f2b_status_xxx() {
	fail2ban-client status $xxx
}

check_f2b_status() {
	if command -v fail2ban-client >/dev/null 2>&1; then
		check_f2b_status="${rw_lv}已安装${rw_lv}"
	else
		check_f2b_status="${rw_lv}未安装${rw_lv}"
	fi
}

f2b_install_sshd() {

	docker rm -f fail2ban >/dev/null 2>&1
	install fail2ban
	start fail2ban
	enable fail2ban

	if command -v dnf &>/dev/null; then
		cd /etc/fail2ban/jail.d/
		curl -sS -O ${gh_proxy}raw.githubusercontent.com/riwi/config/main/fail2ban/centos-ssh.conf
	fi

	if command -v apt &>/dev/null; then
		install rsyslog
		systemctl start rsyslog
		systemctl enable rsyslog
	fi

}

f2b_sshd() {
	if grep -q 'Alpine' /etc/issue; then
		xxx=alpine-sshd
		f2b_status_xxx
	else
		xxx=sshd
		f2b_status_xxx
	fi
}

# 基础参数配置：封禁时长(bantime)、时间窗口(findtime)、重试次数(maxretry)
# 说明：
# - 优先写入 /etc/fail2ban/jail.d/sshd.local（覆盖默认 jail 配置，升级不易丢）
# - 若是 Alpine 且 jail 名称不同，依然写 sshd.local；Fail2Ban 会按 jail 名称匹配
f2b_basic_config() {
	root_use
	install nano

	if ! command -v fail2ban-client >/dev/null 2>&1; then
		echo -e "${rw_lv}未检测到 fail2ban-client，请先安装 fail2ban。${rw_lv}"
		return
	fi

	local jail_name="sshd"
	if grep -qi 'Alpine' /etc/issue 2>/dev/null; then
		# Alpine 默认 jail 通常为 sshd；仅当检测到自定义 alpine-sshd 规则时才切换
		if [ -f /etc/fail2ban/filter.d/alpine-sshd.conf ] || [ -f /etc/fail2ban/jail.d/alpine-ssh.conf ] || [ -f /etc/fail2ban/jail.d/alpine-sshd.local ]; then
			jail_name="alpine-sshd"
		fi
	fi

	echo "即将配置 SSH jail：$jail_name"
	read -e -p "封禁时长 bantime (秒/分钟/小时，如 3600 或 1h) [默认 1h]: " bantime
	read -e -p "时间窗口 findtime (秒/分钟/小时，如 600 或 10m) [默认 10m]: " findtime
	read -e -p "重试次数 maxretry (整数) [默认 5]: " maxretry

	bantime=${bantime:-1h}
	findtime=${findtime:-10m}
	maxretry=${maxretry:-5}

	mkdir -p /etc/fail2ban/jail.d
	cat > /etc/fail2ban/jail.d/sshd.local <<EOF
[$jail_name]
# Managed by riwi.sh
# Note: enable the jail so these parameters take effect
enabled = true
bantime = $bantime
findtime = $findtime
maxretry = $maxretry
EOF

	# Ensure a logfile exists for sshd jail on Debian/Ubuntu minimal images
	# (without it, fail2ban-server may refuse to start)
	if [ "$jail_name" = "sshd" ]; then
		if [ -f /etc/fail2ban/jail.d/sshd.local ]; then
			grep -qE '^[[:space:]]*logpath[[:space:]]*=' /etc/fail2ban/jail.d/sshd.local || echo 'logpath = /var/log/auth.log' >> /etc/fail2ban/jail.d/sshd.local
		fi
	fi

	echo -e "${rw_lv}已写入配置${rw_lv}: /etc/fail2ban/jail.d/sshd.local"
	fail2ban-client reload >/dev/null 2>&1 || true
	sleep 2
	fail2ban-client status $jail_name || true
}

# 直接打开主配置/覆盖配置编辑（nano）
# 优先编辑 /etc/fail2ban/jail.d/sshd.local（更安全），若不存在则创建
f2b_edit_config() {
	root_use
	install nano

	if [ ! -d /etc/fail2ban ]; then
		echo -e "${rw_lv}/etc/fail2ban 不存在，请先安装 fail2ban。${rw_lv}"
		return
	fi

	mkdir -p /etc/fail2ban/jail.d
	local cfg="/etc/fail2ban/jail.d/sshd.local"
	[ -f "$cfg" ] || printf "[sshd]\n# bantime/findtime/maxretry\n" > "$cfg"

	nano "$cfg"
	echo -e "${rw_lv}已保存${rw_lv}，正在 reload fail2ban..."
	fail2ban-client reload >/dev/null 2>&1 || true
}



server_reboot() {

	read -e -p "$(echo -e "${rw_huang}提示: ${rw_lv}现在重启服务器吗？(Y/N): ")" rboot
	case "$rboot" in
	  [Yy])
		echo "已重启"
		reboot
		;;
	  *)
		echo "已取消"
		;;
	esac


}





output_status() {
	output=$(awk 'BEGIN { rx_total = 0; tx_total = 0 }
		$1 ~ /^(eth|ens|enp|eno)[0-9]+/ {
			rx_total += $2
			tx_total += $10
		}
		END {
			rx_units = "Bytes";
			tx_units = "Bytes";
			if (rx_total > 1024) { rx_total /= 1024; rx_units = "K"; }
			if (rx_total > 1024) { rx_total /= 1024; rx_units = "M"; }
			if (rx_total > 1024) { rx_total /= 1024; rx_units = "G"; }

			if (tx_total > 1024) { tx_total /= 1024; tx_units = "K"; }
			if (tx_total > 1024) { tx_total /= 1024; tx_units = "M"; }
			if (tx_total > 1024) { tx_total /= 1024; tx_units = "G"; }

			printf("%.2f%s %.2f%s\n", rx_total, rx_units, tx_total, tx_units);
		}' /proc/net/dev)

	rx=$(echo "$output" | awk '{print $1}')
	tx=$(echo "$output" | awk '{print $2}')

}




ldnmp_install_status_one() {

   if docker inspect "php" &>/dev/null; then
	clear
	send_stats "无法再次安装LDNMP环境"
	echo -e "${rw_huang}提示: ${rw_lv}建站环境已安装。无需再次安装！"
	break_end
	linux_ldnmp
   fi

}


ldnmp_install_all() {
cd ~
send_stats "安装LDNMP环境"
root_use
clear
echo -e "${rw_huang}LDNMP环境未安装，开始安装LDNMP环境...${rw_lv}"
check_disk_space 3 /home
install_dependency
install_docker
install_certbot
install_ldnmp_conf
install_ldnmp

}


nginx_install_all() {
cd ~
send_stats "安装nginx环境"
root_use
clear
echo -e "${rw_huang}nginx未安装，开始安装nginx环境...${rw_lv}"
install_dependency
install_docker
install_certbot
install_ldnmp_conf
nginx_upgrade
clear
local nginx_version=$(docker exec nginx nginx -v 2>&1)
local nginx_version=$(echo "$nginx_version" | sed -n -E 's/.*nginx\/([0-9]+\.[0-9]+\.[0-9]+).*/\1/p')
echo "nginx已安装完成"
echo -e "当前版本: ${rw_huang}v$nginx_version${rw_lv}"
echo ""

}




ldnmp_install_status() {

	if ! docker inspect "php" &>/dev/null; then
		send_stats "请先安装LDNMP环境"
		ldnmp_install_all
	fi

}


nginx_install_status() {

	if ! docker inspect "nginx" &>/dev/null; then
		send_stats "请先安装nginx环境"
		nginx_install_all
	fi

}




ldnmp_web_on() {
	  clear
	  echo "您的 $webname 搭建好了！"
	  echo "https://$yuming"
	  echo -e "${rw_cheng}------------------------${rw_lv}"
	  echo "$webname 安装信息如下: "

}

nginx_web_on() {
	clear

	local ipv4_pattern='^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'
	local ipv6_pattern='^(([0-9A-Fa-f]{1,4}:){1,7}:|([0-9A-Fa-f]{1,4}:){7,7}[0-9A-Fa-f]{1,4}|::1)$'

	echo "您的 $webname 搭建好了！"

	if [[ "$yuming" =~ $ipv4_pattern || "$yuming" =~ $ipv6_pattern ]]; then
		mv /home/web/conf.d/"$yuming".conf /home/web/conf.d/"${yuming}_${access_port}".conf
		echo "http://$yuming:$access_port"
	elif grep -q '^[[:space:]]*#.*if (\$scheme = http)' "/home/web/conf.d/"$yuming".conf"; then
		echo "http://$yuming"
	else
		echo "https://$yuming"
	fi
}



ldnmp_wp() {
  clear
  # wordpress
  webname="WordPress"
  yuming="${1:-}"
  send_stats "安装$webname"
  echo "开始部署 $webname"
  if [ -z "$yuming" ]; then
	add_yuming
  fi
  repeat_add_yuming
  ldnmp_install_status


  install_ssltls
  certs_status
  add_db

  wget -O /home/web/conf.d/map.conf ${gh_proxy}raw.githubusercontent.com/riwi/nginx/main/map.conf
  wget -O /home/web/conf.d/$yuming.conf ${gh_proxy}raw.githubusercontent.com/riwi/nginx/main/wordpress.com.conf
  sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf
  nginx_http_on


  cd /home/web/html
  mkdir $yuming
  cd $yuming
  wget -O latest.zip ${gh_proxy}github.com/riwi/Website_source_code/raw/refs/heads/main/wp-latest.zip
  unzip latest.zip
  rm latest.zip
  echo "define('FS_METHOD', 'direct'); define('WP_REDIS_HOST', 'redis'); define('WP_REDIS_PORT', '6379'); define('WP_REDIS_MAXTTL', 86400); define('WP_CACHE_KEY_SALT', '${yuming}_');" >> /home/web/html/$yuming/wordpress/wp-config-sample.php
  sed -i "s|database_name_here|$dbname|g" /home/web/html/$yuming/wordpress/wp-config-sample.php
  sed -i "s|username_here|$dbuse|g" /home/web/html/$yuming/wordpress/wp-config-sample.php
  sed -i "s|password_here|$dbusepasswd|g" /home/web/html/$yuming/wordpress/wp-config-sample.php
  sed -i "s|localhost|mysql|g" /home/web/html/$yuming/wordpress/wp-config-sample.php
  patch_wp_url "https://$yuming" "https://$yuming"
  cp /home/web/html/$yuming/wordpress/wp-config-sample.php /home/web/html/$yuming/wordpress/wp-config.php


  restart_ldnmp
  nginx_web_on

}



ldnmp_Proxy() {
	clear
	webname="反向代理-IP+端口"
	yuming="${1:-}"
	reverseproxy="${2:-}"
	port="${3:-}"

	send_stats "安装$webname"
	echo "开始部署 $webname"
	if [ -z "$yuming" ]; then
		add_yuming
	fi

	check_ip_and_get_access_port "$yuming"

	if [ -z "$reverseproxy" ]; then
		read -e -p "请输入你的反代IP (回车默认本机IP 127.0.0.1): " reverseproxy
		reverseproxy=${reverseproxy:-127.0.0.1}
	fi

	if [ -z "$port" ]; then
		read -e -p "请输入你的反代端口: " port
	fi
	nginx_install_status


	install_ssltls
	certs_status

	wget -O /home/web/conf.d/map.conf ${gh_proxy}raw.githubusercontent.com/riwi/nginx/main/map.conf
	wget -O /home/web/conf.d/$yuming.conf ${gh_proxy}raw.githubusercontent.com/riwi/nginx/main/reverse-proxy-backend.conf

	backend=$(tr -dc 'A-Za-z' < /dev/urandom | head -c 8)
	sed -i "s/backend_yuming_com/backend_$backend/g" /home/web/conf.d/"$yuming".conf


	sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf

	reverseproxy_port="$reverseproxy:$port"
	upstream_servers=""
	for server in $reverseproxy_port; do
		upstream_servers="$upstream_servers    server $server;\n"
	done

	sed -i "s/# 动态添加/$upstream_servers/g" /home/web/conf.d/$yuming.conf
	sed -i '/remote_addr/d' /home/web/conf.d/$yuming.conf

	update_nginx_listen_port "$yuming" "$access_port"

	nginx_http_on
	docker exec nginx nginx -s reload
	nginx_web_on
}



ldnmp_Proxy_backend() {
	clear
	webname="反向代理-负载均衡"

	send_stats "安装$webname"
	echo "开始部署 $webname"
	if [ -z "$yuming" ]; then
		add_yuming
	fi

	check_ip_and_get_access_port "$yuming"

	if [ -z "$reverseproxy_port" ]; then
		read -e -p "请输入你的多个反代IP+端口用空格隔开（例如 127.0.0.1:3000 127.0.0.1:3002）： " reverseproxy_port
	fi

	nginx_install_status

	install_ssltls
	certs_status

	wget -O /home/web/conf.d/map.conf ${gh_proxy}raw.githubusercontent.com/riwi/nginx/main/map.conf
	wget -O /home/web/conf.d/$yuming.conf ${gh_proxy}raw.githubusercontent.com/riwi/nginx/main/reverse-proxy-backend.conf

	backend=$(tr -dc 'A-Za-z' < /dev/urandom | head -c 8)
	sed -i "s/backend_yuming_com/backend_$backend/g" /home/web/conf.d/"$yuming".conf


	sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf

	upstream_servers=""
	for server in $reverseproxy_port; do
		upstream_servers="$upstream_servers    server $server;\n"
	done

	sed -i "s/# 动态添加/$upstream_servers/g" /home/web/conf.d/$yuming.conf


	update_nginx_listen_port "$yuming" "$access_port"

	nginx_http_on
	docker exec nginx nginx -s reload
	nginx_web_on
}






list_stream_services() {

	STREAM_DIR="/home/web/stream.d"
	printf "%-25s %-18s %-25s %-20s\n" "服务名" "通信类型" "本机地址" "后端地址"

	if [ -z "$(ls -A "$STREAM_DIR")" ]; then
		return
	fi

	for conf in "$STREAM_DIR"/*; do
		# 服务名取文件名
		service_name=$(basename "$conf" .conf)

		# 获取 upstream 块中的 server 后端 IP:端口
		backend=$(grep -Po '(?<=server )[^;]+' "$conf" | head -n1)

		# 获取 listen 端口
		listen_port=$(grep -Po '(?<=listen )[^;]+' "$conf" | head -n1)

		# 默认本地 IP
		ip_address
		local_ip="$ipv4_address"

		# 获取通信类型，优先从文件名后缀或内容判断
		if grep -qi 'udp;' "$conf"; then
			proto="udp"
		else
			proto="tcp"
		fi

		# 拼接监听 IP:端口
		local_addr="$local_ip:$listen_port"

		printf "%-22s %-14s %-21s %-20s\n" "$service_name" "$proto" "$local_addr" "$backend"
	done
}









stream_panel() {
	send_stats "Stream四层代理"
	local app_id="104"
	local docker_name="nginx"

	while true; do
		clear
		check_docker_app
		check_docker_image_update $docker_name
		echo -e "${rw_cheng}━━━━━━━━━━━━  Stream 四层代理  ━━━━━━━━━━━━${rw_lv}"
		echo -e " $check_docker $update_status"
		echo -e " ${rw_huang}TCP/UDP 传输层流量转发与负载均衡${rw_lv}"
		if [ -d "/home/web/stream.d" ]; then
			echo ""
			echo -e " ${rw_lv}──── 已配置服务${rw_lv}"
			list_stream_services
		fi
		echo ""
		echo -e " ${rw_lv}──── 操作${rw_lv}"
		echo -e " ${rw_huang}1${rw_lv}  安装      ${rw_huang}2${rw_lv}  更新      ${rw_huang}3${rw_lv}  卸载"
		echo -e " ${rw_huang}4${rw_lv}  添加转发  ${rw_huang}5${rw_lv}  修改转发  ${rw_huang}6${rw_lv}  删除转发"
		echo ""
		echo -e " ${rw_cheng}────────────────────────────────────────${rw_lv}"
		echo -e " ${rw_huang}0${rw_lv}  返回"
		echo -e " ${rw_cheng}────────────────────────────────────────${rw_lv}"
		read -e -p " 请选择: " choice
		case $choice in
			1)
				nginx_install_status
				add_app_id
				send_stats "安装Stream四层代理"
				;;
			2)
				update_docker_compose_with_db_creds
				nginx_upgrade
				add_app_id
				send_stats "更新Stream四层代理"
				;;
			3)
				read -e -p " 确定删除 nginx 容器？可能影响网站 (y/N): " confirm
				if [[ "$confirm" =~ ^[Yy]$ ]]; then
					docker rm -f nginx
					sed -i "/\b${app_id}\b/d" /home/docker/appno.txt
					send_stats "更新Stream四层代理"
					echo -e "${rw_lv}nginx 容器已删除${rw_lv}"
				else
					echo "操作已取消"
				fi
				;;
			4)
				ldnmp_Proxy_backend_stream
				add_app_id
				send_stats "添加四层代理"
				;;
			5)
				send_stats "编辑转发配置"
				read -e -p " 输入服务名: " stream_name
				install nano
				nano /home/web/stream.d/$stream_name.conf
				docker restart nginx
				send_stats "修改四层代理"
				;;
			6)
				send_stats "删除转发配置"
				read -e -p " 输入服务名: " stream_name
				rm /home/web/stream.d/$stream_name.conf > /dev/null 2>&1
				docker restart nginx
				send_stats "删除四层代理"
				;;
			0) return ;;
			*) echo -e "${rw_hong}无效选择${rw_lv}" ;;
		esac
		break_end
	done
}



ldnmp_Proxy_backend_stream() {
	clear
	webname="Stream四层代理-负载均衡"

	send_stats "安装$webname"
	echo "开始部署 $webname"

	# 获取代理名称
	read -erp "请输入代理转发名称 (如 mysql_proxy): " proxy_name
	if [ -z "$proxy_name" ]; then
		echo "名称不能为空"; return 1
	fi

	# 获取监听端口
	read -erp "请输入本机监听端口 (如 3306): " listen_port
	if ! [[ "$listen_port" =~ ^[0-9]+$ ]]; then
		echo "端口必须是数字"; return 1
	fi

	echo "请选择协议类型："
	echo "1. TCP    2. UDP"
	read -erp "请输入序号 [1-2]: " proto_choice

	case "$proto_choice" in
		1) proto="tcp"; listen_suffix="" ;;
		2) proto="udp"; listen_suffix=" udp" ;;
		*) echo "无效选择"; return 1 ;;
	esac

	read -e -p "请输入你的一个或者多个后端IP+端口用空格隔开（例如 10.13.0.2:3306 10.13.0.3:3306）： " reverseproxy_port

	nginx_install_status
	cd /home && mkdir -p web/stream.d
	grep -q '^[[:space:]]*stream[[:space:]]*{' /home/web/nginx.conf || echo -e '\nstream {\n    include /etc/nginx/stream.d/*.conf;\n}' | tee -a /home/web/nginx.conf
	wget -O /home/web/stream.d/$proxy_name.conf ${gh_proxy}raw.githubusercontent.com/riwi/nginx/main/reverse-proxy-backend-stream.conf

	backend=$(tr -dc 'A-Za-z' < /dev/urandom | head -c 8)
	sed -i "s/backend_yuming_com/${proxy_name}_${backend}/g" /home/web/stream.d/"$proxy_name".conf
	sed -i "s|listen 80|listen $listen_port $listen_suffix|g" /home/web/stream.d/$proxy_name.conf
	sed -i "s|listen \[::\]:|listen [::]:${listen_port} ${listen_suffix}|g" "/home/web/stream.d/${proxy_name}.conf"

	upstream_servers=""
	for server in $reverseproxy_port; do
		upstream_servers="$upstream_servers    server $server;\n"
	done

	sed -i "s/# 动态添加/$upstream_servers/g" /home/web/stream.d/$proxy_name.conf

	docker exec nginx nginx -s reload
	clear
	echo "您的 $webname 搭建好了！"
	echo -e "${rw_cheng}------------------------${rw_lv}"
	echo "访问地址:"
	ip_address
	if [ -n "$ipv4_address" ]; then
		echo "$ipv4_address:${listen_port}"
	fi
	if [ -n "$ipv6_address" ]; then
		echo "$ipv6_address:${listen_port}"
	fi
	echo ""
}





find_container_by_host_port() {
	port="$1"
	docker_name=$(docker ps --format '{{.ID}} {{.Names}}' | while read id name; do
		if docker port "$id" | grep -q ":$port"; then
			echo "$name"
			break
		fi
	done)
}




ldnmp_web_status() {
	root_use
	while true; do
		local cert_count=$(ls /home/web/certs/*_cert.pem 2>/dev/null | wc -l)
		local output="${rw_lv}${cert_count}${rw_lv}"

		local dbrootpasswd=$(sed -n -E 's/.*MYSQL_ROOT_PASSWORD:[[:space:]]*(.*)/\1/p' /home/web/docker-compose.yml | tr -d '[:space:]')
		local db_count=$(docker exec mysql mysql -u root -p"$dbrootpasswd" -e "SHOW DATABASES;" 2> /dev/null | grep -Ev "Database|information_schema|mysql|performance_schema|sys" | wc -l)
		local db_output="${rw_lv}${db_count}${rw_lv}"

		clear
		send_stats "LDNMP站点管理"
		echo -e "${rw_cheng}━━━━━━━━━━━━  站点管理  ━━━━━━━━━━━━${rw_lv}"
		ldnmp_v

		echo -e " 站点 ${output}    证书到期时间"
		echo -e " ${rw_cheng}────────────────────────────────────${rw_lv}"
		for cert_file in /home/web/certs/*_cert.pem; do
		  local domain=$(basename "$cert_file" | sed 's/_cert.pem//')
		  if [ -n "$domain" ]; then
			local expire_date=$(openssl x509 -noout -enddate -in "$cert_file" | awk -F'=' '{print $2}')
			local formatted_date=$(portable_date "$expire_date" '+%Y-%m-%d')
			printf " %-35s%s\n" "$domain" "$formatted_date"
		  fi
		done

		for conf_file in /home/web/conf.d/*_*.conf; do
		  [ -e "$conf_file" ] || continue
		  basename "$conf_file" .conf
		done

		for conf_file in /home/web/conf.d/*.conf; do
		  [ -e "$conf_file" ] || continue

		  filename=$(basename "$conf_file")

		  if [ "$filename" = "map.conf" ] || [ "$filename" = "default.conf" ]; then
			continue
		  fi

		  if ! grep -q "ssl_certificate" "$conf_file"; then
			basename "$conf_file" .conf
		  fi
		done

		echo -e " ${rw_cheng}────────────────────────────────────────${rw_lv}"
		echo -e " 数据库 ${db_output}"
		echo -e " ${rw_cheng}────────────────────────────────────────${rw_lv}"
		local dbrootpasswd=$(sed -n -E 's/.*MYSQL_ROOT_PASSWORD:[[:space:]]*(.*)/\1/p' /home/web/docker-compose.yml | tr -d '[:space:]')
		docker exec mysql mysql -u root -p"$dbrootpasswd" -e "SHOW DATABASES;" 2> /dev/null | grep -Ev "Database|information_schema|mysql|performance_schema|sys"

		echo ""
		echo -e " ${rw_lv}/home/web/html${rw_lv}    ${rw_lv}/home/web/certs${rw_lv}    ${rw_lv}/home/web/conf.d${rw_lv}"
		echo ""
		echo -e " ${rw_lv}──── 操作${rw_lv}"
		echo -e " ${rw_huang}1${rw_lv}  申请/更新证书    ${rw_huang}2${rw_lv}  克隆站点"
		echo -e " ${rw_huang}3${rw_lv}  清理缓存        ${rw_huang}4${rw_lv}  关联站点"
		echo -e " ${rw_huang}5${rw_lv}  访问日志        ${rw_huang}6${rw_lv}  错误日志"
		echo -e " ${rw_huang}7${rw_lv}  全局配置        ${rw_huang}8${rw_lv}  站点配置"
		echo -e " ${rw_huang}9${rw_lv}  站点数据库      ${rw_huang}10${rw_lv} 分析报告"
		echo -e " ${rw_huang}20${rw_lv} 删除站点"
		echo ""
		echo -e " ${rw_cheng}────────────────────────────────────────${rw_lv}"
		echo -e " ${rw_huang}0${rw_lv}  返回"
		echo -e " ${rw_cheng}────────────────────────────────────────${rw_lv}"
		read -e -p " 请选择: " sub_choice
		case $sub_choice in
			1)
				send_stats "申请域名证书"
				read -e -p "请输入你的域名: " yuming
				install_certbot
				docker run --rm -v /etc/letsencrypt/:/etc/letsencrypt certbot/certbot delete --cert-name "$yuming" -n 2>/dev/null
				install_ssltls
				certs_status

				;;

			2)
				send_stats "克隆站点域名"
				read -e -p "请输入旧域名: " oddyuming
				read -e -p "请输入新域名: " yuming
				install_certbot
				install_ssltls
				certs_status


				add_db
				local odd_dbname=$(echo "$oddyuming" | sed -e 's/[^A-Za-z0-9]/_/g')
				local odd_dbname="${odd_dbname}"

				docker exec mysql mysqldump -u root -p"$dbrootpasswd" $odd_dbname | docker exec -i mysql mysql -u root -p"$dbrootpasswd" $dbname

				local tables=$(docker exec mysql mysql -u root -p"$dbrootpasswd" -D $dbname -e "SHOW TABLES;" | awk '{ if (NR>1) print $1 }')
				for table in $tables; do
					columns=$(docker exec mysql mysql -u root -p"$dbrootpasswd" -D $dbname -e "SHOW COLUMNS FROM $table;" | awk '{ if (NR>1) print $1 }')
					for column in $columns; do
						docker exec mysql mysql -u root -p"$dbrootpasswd" -D $dbname -e "UPDATE $table SET $column = REPLACE($column, '$oddyuming', '$yuming') WHERE $column LIKE '%$oddyuming%';"
					done
				done

				# 网站目录替换
				cp -r /home/web/html/$oddyuming /home/web/html/$yuming

				find /home/web/html/$yuming -type f -exec sed -i "s/$odd_dbname/$dbname/g" {} +
				find /home/web/html/$yuming -type f -exec sed -i "s/$oddyuming/$yuming/g" {} +

				cp /home/web/conf.d/$oddyuming.conf /home/web/conf.d/$yuming.conf
				sed -i "s/$oddyuming/$yuming/g" /home/web/conf.d/$yuming.conf

				cd /home/web && docker compose restart

				;;


			3)
				web_cache
				;;
			4)
				send_stats "创建关联站点"
				echo -e "为现有的站点再关联一个新域名用于访问"
				read -e -p "请输入现有的域名: " oddyuming
				read -e -p "请输入新域名: " yuming
				install_certbot
				install_ssltls
				certs_status

				cp /home/web/conf.d/$oddyuming.conf /home/web/conf.d/$yuming.conf
				sed -i "s|server_name $oddyuming|server_name $yuming|g" /home/web/conf.d/$yuming.conf
				sed -i "s|/etc/nginx/certs/${oddyuming}_cert.pem|/etc/nginx/certs/${yuming}_cert.pem|g" /home/web/conf.d/$yuming.conf
				sed -i "s|/etc/nginx/certs/${oddyuming}_key.pem|/etc/nginx/certs/${yuming}_key.pem|g" /home/web/conf.d/$yuming.conf

				docker exec nginx nginx -s reload

				;;
			5)
				send_stats "查看访问日志"
				tail -n 200 /home/web/log/nginx/access.log
				break_end
				;;
			6)
				send_stats "查看错误日志"
				tail -n 200 /home/web/log/nginx/error.log
				break_end
				;;
			7)
				send_stats "编辑全局配置"
				install nano
				nano /home/web/nginx.conf
				docker exec nginx nginx -s reload
				;;

			8)
				send_stats "编辑站点配置"
				read -e -p "编辑站点配置，请输入你要编辑的域名: " yuming
				install nano
				nano /home/web/conf.d/$yuming.conf
				docker exec nginx nginx -s reload
				;;
			9)
				phpmyadmin_upgrade
				break_end
				;;
			10)
				send_stats "查看站点数据"
				install goaccess
				goaccess --log-format=COMBINED /home/web/log/nginx/access.log
				;;

			20)
				web_del
				docker run --rm -v /etc/letsencrypt/:/etc/letsencrypt certbot/certbot delete --cert-name "$yuming" -n 2>/dev/null

				;;
			*)
				break  # 跳出循环，退出菜单
				;;
		esac
	done


}


check_panel_app() {
if $lujing > /dev/null 2>&1; then
	check_panel="${rw_lv}已安装${rw_lv}"
else
	check_panel=""
fi
}



install_panel() {
send_stats "${panelname}管理"
while true; do
	clear
	check_panel_app
	echo -e "$panelname $check_panel"
	echo "${panelname}是一款时下流行且强大的运维管理面板。"
	echo "官网介绍: $panelurl "

	echo ""
	echo -e "${rw_cheng}------------------------${rw_lv}"
	echo "1. 安装            2. 管理            3. 卸载"
	echo -e "${rw_cheng}------------------------${rw_lv}"
	echo "0. 返回上一级选单"
	echo -e "${rw_cheng}------------------------${rw_lv}"
	read -e -p "请输入你的选择: " choice
	 case $choice in
		1)
			check_disk_space 1
			install wget
			iptables_open
			panel_app_install

			add_app_id
			send_stats "${panelname}安装"
			;;
		2)
			panel_app_manage

			add_app_id
			send_stats "${panelname}控制"

			;;
		3)
			panel_app_uninstall

			sed -i "/\b${app_id}\b/d" /home/docker/appno.txt
			send_stats "${panelname}卸载"
			;;
		*)
			break
			;;
	 esac
	 break_end
done

}



check_frp_app() {

if [ -d "/home/frp/" ]; then
	check_frp="${rw_lv}已安装${rw_lv}"
else
	check_frp="${rw_lv}未安装${rw_lv}"
fi

}



donlond_frp() {
  role="$1"
  config_file="/home/frp/${role}.toml"

  docker run -d \
	--name "$role" \
	--restart=always \
	--network host \
	-v "$config_file":"/frp/${role}.toml" \
	kjlion/frp:alpine \
	"/frp/${role}" -c "/frp/${role}.toml"

}




generate_frps_config() {

	send_stats "安装frp服务端"
	# 生成随机端口和凭证
	local bind_port=8055
	local dashboard_port=8056
	local token=$(openssl rand -hex 16)
	local dashboard_user="user_$(openssl rand -hex 4)"
	local dashboard_pwd=$(openssl rand -hex 8)

	mkdir -p /home/frp
	touch /home/frp/frps.toml
	cat <<EOF > /home/frp/frps.toml
[common]
bind_port = $bind_port
authentication_method = token
token = $token
dashboard_port = $dashboard_port
dashboard_user = $dashboard_user
dashboard_pwd = $dashboard_pwd
EOF

	donlond_frp frps

	# 输出生成的信息
	ip_address
	echo -e "${rw_cheng}------------------------${rw_lv}"
	echo "客户端部署时需要用的参数"
	echo "服务IP: $ipv4_address"
	echo "token: $token"
	echo
	echo "FRP面板信息"
	echo "FRP面板地址: http://$ipv4_address:$dashboard_port"
	echo "FRP面板用户名: $dashboard_user"
	echo "FRP面板密码: $dashboard_pwd"
	echo

	open_port 8055 8056

}



configure_frpc() {
	send_stats "安装frp客户端"
	read -e -p "请输入外网对接IP: " server_addr
	read -e -p "请输入外网对接token: " token
	echo

	mkdir -p /home/frp
	touch /home/frp/frpc.toml
	cat <<EOF > /home/frp/frpc.toml
[common]
server_addr = ${server_addr}
server_port = 8055
token = ${token}

EOF

	donlond_frp frpc

	open_port 8055

}

add_forwarding_service() {
	send_stats "添加frp内网服务"
	# 提示用户输入服务名称和转发信息
	read -e -p "请输入服务名称: " service_name
	read -e -p "请输入转发类型 (tcp/udp) [回车默认tcp]: " service_type
	local service_type=${service_type:-tcp}
	read -e -p "请输入内网IP [回车默认127.0.0.1]: " local_ip
	local local_ip=${local_ip:-127.0.0.1}
	read -e -p "请输入内网端口: " local_port
	read -e -p "请输入外网端口: " remote_port

	# 将用户输入写入配置文件
	cat <<EOF >> /home/frp/frpc.toml
[$service_name]
type = ${service_type}
local_ip = ${local_ip}
local_port = ${local_port}
remote_port = ${remote_port}

EOF

	# 输出生成的信息
	echo "服务 $service_name 已成功添加到 frpc.toml"

	docker restart frpc

	open_port $local_port

}



delete_forwarding_service() {
	send_stats "删除frp内网服务"
	# 提示用户输入需要删除的服务名称
	read -e -p "请输入需要删除的服务名称: " service_name
	# 使用 sed 删除该服务及其相关配置
	sed -i "/\[$service_name\]/,/^$/d" /home/frp/frpc.toml
	echo "服务 $service_name 已成功从 frpc.toml 删除"

	docker restart frpc

}


list_forwarding_services() {
	local config_file="$1"

	# 打印表头
	printf "%-20s %-25s %-30s %-10s\n" "服务名称" "内网地址" "外网地址" "协议"

	awk '
	BEGIN {
		server_addr=""
		server_port=""
		current_service=""
	}

	/^server_addr = / {
		gsub(/"|'"'"'/, "", $3)
		server_addr=$3
	}

	/^server_port = / {
		gsub(/"|'"'"'/, "", $3)
		server_port=$3
	}

	/^\[.*\]/ {
		# 如果已有服务信息，在处理新服务之前打印当前服务
		if (current_service != "" && current_service != "common" && local_ip != "" && local_port != "") {
			printf "%-16s %-21s %-26s %-10s\n", \
				current_service, \
				local_ip ":" local_port, \
				server_addr ":" remote_port, \
				type
		}

		# 更新当前服务名称
		if ($1 != "[common]") {
			gsub(/[\[\]]/, "", $1)
			current_service=$1
			# 清除之前的值
			local_ip=""
			local_port=""
			remote_port=""
			type=""
		}
	}

	/^local_ip = / {
		gsub(/"|'"'"'/, "", $3)
		local_ip=$3
	}

	/^local_port = / {
		gsub(/"|'"'"'/, "", $3)
		local_port=$3
	}

	/^remote_port = / {
		gsub(/"|'"'"'/, "", $3)
		remote_port=$3
	}

	/^type = / {
		gsub(/"|'"'"'/, "", $3)
		type=$3
	}

	END {
		# 打印最后一个服务的信息
		if (current_service != "" && current_service != "common" && local_ip != "" && local_port != "") {
			printf "%-16s %-21s %-26s %-10s\n", \
				current_service, \
				local_ip ":" local_port, \
				server_addr ":" remote_port, \
				type
		}
	}' "$config_file"
}



# 获取 FRP 服务端端口
get_frp_ports() {
	mapfile -t ports < <(ss -tulnape | grep frps | awk '{print $5}' | awk -F':' '{print $NF}' | sort -u)
}

# 生成访问地址
generate_access_urls() {
	# 首先获取所有端口
	get_frp_ports

	# 检查是否有非 8055/8056 的端口
	local has_valid_ports=false
	for port in "${ports[@]}"; do
		if [[ $port != "8055" && $port != "8056" ]]; then
			has_valid_ports=true
			break
		fi
	done

	# 只在有有效端口时显示标题和内容
	if [ "$has_valid_ports" = true ]; then
		echo "FRP服务对外访问地址:"

		# 处理 IPv4 地址
		for port in "${ports[@]}"; do
			if [[ $port != "8055" && $port != "8056" ]]; then
				echo "http://${ipv4_address}:${port}"
			fi
		done

		# 处理 IPv6 地址（如果存在）
		if [ -n "$ipv6_address" ]; then
			for port in "${ports[@]}"; do
				if [[ $port != "8055" && $port != "8056" ]]; then
					echo "http://[${ipv6_address}]:${port}"
				fi
			done
		fi

		# 处理 HTTPS 配置
		for port in "${ports[@]}"; do
			if [[ $port != "8055" && $port != "8056" ]]; then
				local frps_search_pattern="${ipv4_address}:${port}"
				local frps_search_pattern2="127.0.0.1:${port}"
				for file in /home/web/conf.d/*.conf; do
					if [ -f "$file" ]; then
						if grep -q "$frps_search_pattern" "$file" 2>/dev/null || grep -q "$frps_search_pattern2" "$file" 2>/dev/null; then
							echo "https://$(basename "$file" .conf)"
						fi
					fi
				done
			fi
		done
	fi
}


frps_main_ports() {
	ip_address
	generate_access_urls
}




frps_panel() {
	send_stats "FRP服务端"
	local app_id="55"
	local docker_name="frps"
	local docker_port=8056
	while true; do
		clear
		check_frp_app
		check_docker_image_update $docker_name
		echo -e "FRP服务端 $check_frp $update_status"
		echo "构建FRP内网穿透服务环境，将无公网IP的设备暴露到互联网"
		echo "官网介绍: ${gh_https_url}github.com/fatedier/frp/"
		echo "视频教学: https://www.bilibili.com/video/BV1yMw6e2EwL?t=124.0"
		if [ -d "/home/frp/" ]; then
			check_docker_app_ip
			frps_main_ports
		fi
		echo ""
		echo -e "${rw_cheng}------------------------${rw_lv}"
		echo "1. 安装                  2. 更新                  3. 卸载"
		echo -e "${rw_cheng}------------------------${rw_lv}"
		echo "5. 内网服务域名访问      6. 删除域名访问"
		echo -e "${rw_cheng}------------------------${rw_lv}"
		echo "7. 允许IP+端口访问       8. 阻止IP+端口访问"
		echo -e "${rw_cheng}------------------------${rw_lv}"
		echo "00. 刷新服务状态         0. 返回上一级选单"
		echo -e "${rw_cheng}------------------------${rw_lv}"
		read -e -p "输入你的选择: " choice
		case $choice in
			1)
				install jq grep ss
				install_docker
				generate_frps_config

				add_app_id
				echo "FRP服务端已经安装完成"
				;;
			2)
				crontab -l | grep -v 'frps' | crontab - > /dev/null 2>&1
				tmux kill-session -t frps >/dev/null 2>&1
				docker rm -f frps && docker rmi kjlion/frp:alpine >/dev/null 2>&1
				[ -f /home/frp/frps.toml ] || cp /home/frp/frp_0.61.0_linux_amd64/frps.toml /home/frp/frps.toml
				donlond_frp frps

				add_app_id
				echo "FRP服务端已经更新完成"
				;;
			3)
				crontab -l | grep -v 'frps' | crontab - > /dev/null 2>&1
				tmux kill-session -t frps >/dev/null 2>&1
				docker rm -f frps && docker rmi kjlion/frp:alpine
				rm -rf /home/frp

				close_port 8055 8056

				sed -i "/\b${app_id}\b/d" /home/docker/appno.txt
				echo "应用已卸载"
				;;
			5)
				echo "将内网穿透服务反代成域名访问"
				send_stats "FRP对外域名访问"
				add_yuming
				read -e -p "请输入你的内网穿透服务端口: " frps_port
				ldnmp_Proxy ${yuming} 127.0.0.1 ${frps_port}
				block_host_port "$frps_port" "$ipv4_address"
				;;
			6)
				echo "域名格式 example.com 不带https://"
				web_del
				;;

			7)
				send_stats "允许IP访问"
				read -e -p "请输入需要放行的端口: " frps_port
				clear_host_port_rules "$frps_port" "$ipv4_address"
				;;

			8)
				send_stats "阻止IP访问"
				echo "如果你已经反代域名访问了，可用此功能阻止IP+端口访问，这样更安全。"
				read -e -p "请输入需要阻止的端口: " frps_port
				block_host_port "$frps_port" "$ipv4_address"
				;;

			00)
				send_stats "刷新FRP服务状态"
				echo "已经刷新FRP服务状态"
				;;

			*)
				break
				;;
		esac
		break_end
	done
}


frpc_panel() {
	send_stats "FRP客户端"
	local app_id="56"
	local docker_name="frpc"
	local docker_port=8055
	while true; do
		clear
		check_frp_app
		check_docker_image_update $docker_name
		echo -e "FRP客户端 $check_frp $update_status"
		echo "与服务端对接，对接后可创建内网穿透服务到互联网访问"
		echo "官网介绍: ${gh_https_url}github.com/fatedier/frp/"
		echo "视频教学: https://www.bilibili.com/video/BV1yMw6e2EwL?t=173.9"
		echo -e "${rw_cheng}------------------------${rw_lv}"
		if [ -d "/home/frp/" ]; then
			[ -f /home/frp/frpc.toml ] || cp /home/frp/frp_0.61.0_linux_amd64/frpc.toml /home/frp/frpc.toml
			list_forwarding_services "/home/frp/frpc.toml"
		fi
		echo ""
		echo -e "${rw_cheng}------------------------${rw_lv}"
		echo "1. 安装               2. 更新               3. 卸载"
		echo -e "${rw_cheng}------------------------${rw_lv}"
		echo "4. 添加对外服务       5. 删除对外服务       6. 手动配置服务"
		echo -e "${rw_cheng}------------------------${rw_lv}"
		echo "0. 返回上一级选单"
		echo -e "${rw_cheng}------------------------${rw_lv}"
		read -e -p "输入你的选择: " choice
		case $choice in
			1)
				install jq grep ss
				install_docker
				configure_frpc

				add_app_id
				echo "FRP客户端已经安装完成"
				;;
			2)
				crontab -l | grep -v 'frpc' | crontab - > /dev/null 2>&1
				tmux kill-session -t frpc >/dev/null 2>&1
				docker rm -f frpc && docker rmi kjlion/frp:alpine >/dev/null 2>&1
				[ -f /home/frp/frpc.toml ] || cp /home/frp/frp_0.61.0_linux_amd64/frpc.toml /home/frp/frpc.toml
				donlond_frp frpc

				add_app_id
				echo "FRP客户端已经更新完成"
				;;

			3)
				crontab -l | grep -v 'frpc' | crontab - > /dev/null 2>&1
				tmux kill-session -t frpc >/dev/null 2>&1
				docker rm -f frpc && docker rmi kjlion/frp:alpine
				rm -rf /home/frp
				close_port 8055

				sed -i "/\b${app_id}\b/d" /home/docker/appno.txt
				echo "应用已卸载"
				;;

			4)
				add_forwarding_service
				;;

			5)
				delete_forwarding_service
				;;

			6)
				install nano
				nano /home/frp/frpc.toml
				docker restart frpc
				;;

			*)
				break
				;;
		esac
		break_end
	done
}




yt_menu_pro() {

	local app_id="66"
	local VIDEO_DIR="/home/yt-dlp"
	local URL_FILE="$VIDEO_DIR/urls.txt"
	local ARCHIVE_FILE="$VIDEO_DIR/archive.txt"

	mkdir -p "$VIDEO_DIR"

	while true; do

		if [ -x "/usr/local/bin/yt-dlp" ]; then
		   local YTDLP_STATUS="${rw_lv}已安装${rw_lv}"
		else
		   local YTDLP_STATUS="${rw_lv}未安装${rw_lv}"
		fi

		clear
		send_stats "yt-dlp 下载工具"
		echo -e "yt-dlp $YTDLP_STATUS"
		echo -e "yt-dlp 是一个功能强大的视频下载工具，支持 YouTube、Bilibili、Twitter 等数千站点。"
		echo -e "官网地址：${gh_https_url}github.com/yt-dlp/yt-dlp"
		echo -e "${rw_cheng}-------------------------${rw_lv}"
		echo "已下载视频列表:"
		ls -td "$VIDEO_DIR"/*/ 2>/dev/null || echo "（暂无）"
		echo -e "${rw_cheng}-------------------------${rw_lv}"
		echo "1.  安装               2.  更新               3.  卸载"
		echo -e "${rw_cheng}-------------------------${rw_lv}"
		echo "5.  单个视频下载       6.  批量视频下载       7.  自定义参数下载"
		echo "8.  下载为MP3音频      9.  删除视频目录       10. Cookie管理（开发中）"
		echo -e "${rw_cheng}-------------------------${rw_lv}"
		echo "0. 返回上一级选单"
		echo -e "${rw_cheng}-------------------------${rw_lv}"
		read -e -p "请输入选项编号: " choice

		case $choice in
			1)
				send_stats "正在安装 yt-dlp..."
				echo "正在安装 yt-dlp..."
				install ffmpeg
				curl -L ${gh_https_url}github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
				chmod a+rx /usr/local/bin/yt-dlp

				add_app_id
				echo "安装完成。按任意键继续..."
				read ;;
			2)
				send_stats "正在更新 yt-dlp..."
				echo "正在更新 yt-dlp..."
				yt-dlp -U

				add_app_id
				echo "更新完成。按任意键继续..."
				read ;;
			3)
				send_stats "正在卸载 yt-dlp..."
				echo "正在卸载 yt-dlp..."
				rm -f /usr/local/bin/yt-dlp

				sed -i "/\b${app_id}\b/d" /home/docker/appno.txt
				echo "卸载完成。按任意键继续..."
				read ;;
			5)
				send_stats "单个视频下载"
				read -e -p "请输入视频链接: " url
				yt-dlp -P "$VIDEO_DIR" -f "bv*+ba/b" --merge-output-format mp4 \
					--write-subs --sub-langs all \
					--write-thumbnail --embed-thumbnail \
					--write-info-json \
					-o "$VIDEO_DIR/%(title)s/%(title)s.%(ext)s" \
					--no-overwrites --no-post-overwrites "$url"
				read -e -p "下载完成，按任意键继续..." ;;
			6)
				send_stats "批量视频下载"
				install nano
				if [ ! -f "$URL_FILE" ]; then
				  echo -e "# 输入多个视频链接地址\n# https://www.bilibili.com/bangumi/play/ep733316?spm_id_from=333.337.0.0&from_spmid=666.25.episode.0" > "$URL_FILE"
				fi
				nano $URL_FILE
				echo "现在开始批量下载..."
				yt-dlp -P "$VIDEO_DIR" -f "bv*+ba/b" --merge-output-format mp4 \
					--write-subs --sub-langs all \
					--write-thumbnail --embed-thumbnail \
					--write-info-json \
					-a "$URL_FILE" \
					-o "$VIDEO_DIR/%(title)s/%(title)s.%(ext)s" \
					--no-overwrites --no-post-overwrites
				read -e -p "批量下载完成，按任意键继续..." ;;
			7)
				send_stats "自定义视频下载"
				read -e -p "请输入完整 yt-dlp 参数（不含 yt-dlp）: " custom
				yt-dlp -P "$VIDEO_DIR" $custom \
					--write-subs --sub-langs all \
					--write-thumbnail --embed-thumbnail \
					--write-info-json \
					-o "$VIDEO_DIR/%(title)s/%(title)s.%(ext)s" \
					--no-overwrites --no-post-overwrites
				read -e -p "执行完成，按任意键继续..." ;;
			8)
				send_stats "MP3下载"
				read -e -p "请输入视频链接: " url
				yt-dlp -P "$VIDEO_DIR" -x --audio-format mp3 \
					--write-subs --sub-langs all \
					--write-thumbnail --embed-thumbnail \
					--write-info-json \
					-o "$VIDEO_DIR/%(title)s/%(title)s.%(ext)s" \
					--no-overwrites --no-post-overwrites "$url"
				read -e -p "音频下载完成，按任意键继续..." ;;

			9)
				send_stats "删除视频"
				read -e -p "请输入删除视频名称: " rmdir
				rm -rf "$VIDEO_DIR/$rmdir"
				;;
			*)
				break ;;
		esac
	done
}





current_timezone() {
	if grep -q 'Alpine' /etc/issue; then
	   date +"%Z %z"
	else
	   timedatectl | grep "Time zone" | awk '{print $3}'
	fi

}


set_timedate() {
	local shiqu="$1"
	if grep -q 'Alpine' /etc/issue; then
		install tzdata
		cp /usr/share/zoneinfo/${shiqu} /etc/localtime
		hwclock --systohc
	else
		timedatectl set-timezone ${shiqu}
	fi
}



# 修复dpkg中断问题
fix_dpkg() {
	pkill -9 -f 'apt|dpkg'
	rm -f /var/lib/dpkg/lock-frontend /var/lib/dpkg/lock
	DEBIAN_FRONTEND=noninteractive dpkg --configure -a
}


linux_update() {
	clear
	echo -e "${rw_huang}系统更新${rw_lv}"
	echo -e "${rw_cheng}------------------------${rw_lv}"
	echo ""
	echo -e "${rw_huang}功能说明:${rw_lv}"
	echo -e "${rw_huang}  自动检测系统包管理器并更新所有软件包，包括:${rw_lv}"
	echo -e "${rw_huang}  • Debian/Ubuntu: apt update && apt full-upgrade${rw_lv}"
	echo -e "${rw_huang}  • CentOS/RHEL: yum update 或 dnf update${rw_lv}"
	echo -e "${rw_huang}  • Alpine: apk update && apk upgrade${rw_lv}"
	echo -e "${rw_huang}  • Arch: pacman -Syu${rw_lv}"
	echo ""
	echo -e "${rw_huang}提示: 更新过程可能需要几分钟，请耐心等待${rw_lv}"
	echo ""
	send_stats "系统更新"
	echo -e "${rw_huang}正在系统更新...${rw_lv}"
	if command -v dnf &>/dev/null; then
		dnf -y update
	elif command -v yum &>/dev/null; then
		yum -y update
	elif command -v apt &>/dev/null; then
		fix_dpkg
		DEBIAN_FRONTEND=noninteractive apt update -y
		DEBIAN_FRONTEND=noninteractive apt full-upgrade -y
	elif command -v apk &>/dev/null; then
		apk update && apk upgrade
	elif command -v pacman &>/dev/null; then
		pacman -Syu --noconfirm
	elif command -v zypper &>/dev/null; then
		zypper refresh
		zypper update
	elif command -v opkg &>/dev/null; then
		opkg update
	else
		echo "未知的包管理器!"
		return
	fi
}



linux_clean() {
	clear
	echo -e "${rw_huang}系统清理${rw_lv}"
	echo -e "${rw_cheng}------------------------${rw_lv}"
	echo ""
	echo -e "${rw_huang}功能说明:${rw_lv}"
	echo -e "${rw_huang}  清理系统垃圾文件和缓存，释放磁盘空间，包括:${rw_lv}"
	echo -e "${rw_huang}  • 清理包管理器缓存${rw_lv}"
	echo -e "${rw_huang}  • 卸载不需要的依赖包${rw_lv}"
	echo -e "${rw_huang}  • 清理旧的系统日志${rw_lv}"
	echo -e "${rw_huang}  • 重建软件包数据库${rw_lv}"
	echo ""
	echo -e "${rw_huang}提示: 清理过程中可能需要几分钟，请耐心等待${rw_lv}"
	echo ""
	send_stats "系统清理"
	echo -e "${rw_huang}正在系统清理...${rw_lv}"
	if command -v dnf &>/dev/null; then
		rpm --rebuilddb
		dnf autoremove -y
		dnf clean all
		dnf makecache
		journalctl --rotate
		journalctl --vacuum-time=1s
		journalctl --vacuum-size=500M

	elif command -v yum &>/dev/null; then
		rpm --rebuilddb
		yum autoremove -y
		yum clean all
		yum makecache
		journalctl --rotate
		journalctl --vacuum-time=1s
		journalctl --vacuum-size=500M

	elif command -v apt &>/dev/null; then
		fix_dpkg
		apt autoremove --purge -y
		apt clean -y
		apt autoclean -y
		journalctl --rotate
		journalctl --vacuum-time=1s
		journalctl --vacuum-size=500M

	elif command -v apk &>/dev/null; then
		echo "清理包管理器缓存..."
		apk cache clean
		echo "删除系统日志..."
		rm -rf /var/log/*
		echo "删除APK缓存..."
		rm -rf /var/cache/apk/*
		echo "删除临时文件..."
		rm -rf /tmp/*

	elif command -v pacman &>/dev/null; then
		pacman -Rns $(pacman -Qdtq) --noconfirm
		pacman -Scc --noconfirm
		journalctl --rotate
		journalctl --vacuum-time=1s
		journalctl --vacuum-size=500M

	elif command -v zypper &>/dev/null; then
		zypper clean --all
		zypper refresh
		journalctl --rotate
		journalctl --vacuum-time=1s
		journalctl --vacuum-size=500M

	elif command -v opkg &>/dev/null; then
		echo "删除系统日志..."
		rm -rf /var/log/*
		echo "删除临时文件..."
		rm -rf /tmp/*

	elif command -v pkg &>/dev/null; then
		echo "清理未使用的依赖..."
		pkg autoremove -y
		echo "清理包管理器缓存..."
		pkg clean -y
		echo "删除系统日志..."
		rm -rf /var/log/*
		echo "删除临时文件..."
		rm -rf /tmp/*

	else
		echo "未知的包管理器!"
		return
	fi
	return
}



bbr_on() {

# 统一写入到 sysctl.d 以防与内核调优模块打架
local CONF="/etc/sysctl.d/99-riwi-bbr.conf"
mkdir -p /etc/sysctl.d
echo "net.core.default_qdisc=fq" > "$CONF"
echo "net.ipv4.tcp_congestion_control=bbr" >> "$CONF"

# 清理可能导致冲突的旧版 sysctl.conf 残留
sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf 2>/dev/null
sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf 2>/dev/null

sysctl -p "$CONF" >/dev/null 2>&1 || sysctl --system >/dev/null 2>&1

}


set_dns() {

ip_address

chattr -i /etc/resolv.conf
> /etc/resolv.conf

if [ -n "$ipv4_address" ]; then
	echo "nameserver $dns1_ipv4" >> /etc/resolv.conf
	echo "nameserver $dns2_ipv4" >> /etc/resolv.conf
fi

if [ -n "$ipv6_address" ]; then
	echo "nameserver $dns1_ipv6" >> /etc/resolv.conf
	echo "nameserver $dns2_ipv6" >> /etc/resolv.conf
fi

if [ ! -s /etc/resolv.conf ]; then
	echo "nameserver 223.5.5.5" >> /etc/resolv.conf
	echo "nameserver 8.8.8.8" >> /etc/resolv.conf
fi

chattr +i /etc/resolv.conf

}


set_dns_ui() {
root_use
send_stats "优化DNS"
while true; do
	clear
	echo "优化DNS地址"
	echo -e "${rw_cheng}------------------------${rw_lv}"
	echo "当前DNS地址"
	cat /etc/resolv.conf
	echo -e "${rw_cheng}------------------------${rw_lv}"
	echo ""
	echo "1. 国外DNS优化: "
	echo " v4: 1.1.1.1 8.8.8.8"
	echo " v6: 2606:4700:4700::1111 2001:4860:4860::8888"
	echo "2. 国内DNS优化: "
	echo " v4: 223.5.5.5 183.60.83.19"
	echo " v6: 2400:3200::1 2400:da00::6666"
	echo "3. 手动编辑DNS配置"
	echo -e "${rw_cheng}------------------------${rw_lv}"
	echo "0. 返回上一级选单"
	echo -e "${rw_cheng}------------------------${rw_lv}"
	read -e -p "请输入你的选择: " Limiting
	case "$Limiting" in
	  1)
		local dns1_ipv4="1.1.1.1"
		local dns2_ipv4="8.8.8.8"
		local dns1_ipv6="2606:4700:4700::1111"
		local dns2_ipv6="2001:4860:4860::8888"
		set_dns
		send_stats "国外DNS优化"
		;;
	  2)
		local dns1_ipv4="223.5.5.5"
		local dns2_ipv4="183.60.83.19"
		local dns1_ipv6="2400:3200::1"
		local dns2_ipv6="2400:da00::6666"
		set_dns
		send_stats "国内DNS优化"
		;;
	  3)
		install nano
		chattr -i /etc/resolv.conf
		nano /etc/resolv.conf
		chattr +i /etc/resolv.conf
		send_stats "手动编辑DNS配置"
		;;
	  *)
		break
		;;
	esac
done

}



restart_ssh() {
	restart sshd ssh > /dev/null 2>&1

}



correct_ssh_config() {

	local sshd_config="/etc/ssh/sshd_config"


	if grep -Eq "^[[:space:]]*PasswordAuthentication[[:space:]]+no" "$sshd_config"; then
		sed -i -e 's/^[[:space:]]*#\?[[:space:]]*PermitRootLogin .*/PermitRootLogin prohibit-password/' \
			   -e 's/^[[:space:]]*#\?[[:space:]]*PasswordAuthentication .*/PasswordAuthentication no/' \
			   -e 's/^[[:space:]]*#\?[[:space:]]*PubkeyAuthentication .*/PubkeyAuthentication yes/' \
			   -e 's/^[[:space:]]*#\?[[:space:]]*ChallengeResponseAuthentication .*/ChallengeResponseAuthentication no/' "$sshd_config"
	else
		sed -i -e 's/^[[:space:]]*#\?[[:space:]]*PermitRootLogin .*/PermitRootLogin yes/' \
			   -e 's/^\s*#\?\s*PasswordAuthentication .*/PasswordAuthentication yes/' \
			   -e 's/^\s*#\?\s*PubkeyAuthentication .*/PubkeyAuthentication yes/' "$sshd_config"
	fi

	rm -rf /etc/ssh/sshd_config.d/* /etc/ssh/ssh_config.d/*
}


new_ssh_port() {

  local new_port=$1

  cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

  sed -i '/^\s*#\?\s*Port\s\+/d' /etc/ssh/sshd_config
  echo "Port $new_port" >> /etc/ssh/sshd_config

  correct_ssh_config

  restart_ssh
  open_port $new_port
  remove iptables-persistent ufw firewalld iptables-services > /dev/null 2>&1

  echo "SSH 端口已修改为: $new_port"

  sleep 1

}



sshkey_on() {

	sed -i -e 's/^[[:space:]]*#\?[[:space:]]*PermitRootLogin .*/PermitRootLogin prohibit-password/' \
		   -e 's/^[[:space:]]*#\?[[:space:]]*PasswordAuthentication .*/PasswordAuthentication no/' \
		   -e 's/^[[:space:]]*#\?[[:space:]]*PubkeyAuthentication .*/PubkeyAuthentication yes/' \
		   -e 's/^[[:space:]]*#\?[[:space:]]*ChallengeResponseAuthentication .*/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
	rm -rf /etc/ssh/sshd_config.d/* /etc/ssh/ssh_config.d/*
	restart_ssh
	echo -e "${rw_lv}用户密钥登录模式已开启，已关闭密码登录模式，重连将会生效${rw_lv}"

}



add_sshkey() {
	chmod 700 "${HOME}"
	mkdir -p "${HOME}/.ssh"
	chmod 700 "${HOME}/.ssh"
	touch "${HOME}/.ssh/authorized_keys"

	ssh-keygen -t ed25519 -C "xxxx@gmail.com" -f "${HOME}/.ssh/sshkey" -N ""

	cat "${HOME}/.ssh/sshkey.pub" >> "${HOME}/.ssh/authorized_keys"
	chmod 600 "${HOME}/.ssh/authorized_keys"

	ip_address
	echo -e "私钥信息已生成，务必复制保存，可保存成 ${rw_huang}${ipv4_address}_ssh.key${rw_lv} 文件，用于以后的SSH登录"

	echo -e "${rw_cheng}--------------------------------${rw_lv}"
	cat "${HOME}/.ssh/sshkey"
	echo -e "${rw_cheng}--------------------------------${rw_lv}"

	sshkey_on
}





import_sshkey() {

	local public_key="$1"
	local base_dir="${2:-$HOME}"
	local ssh_dir="${base_dir}/.ssh"
	local auth_keys="${ssh_dir}/authorized_keys"

	if [[ -z "$public_key" ]]; then
		read -e -p "请输入您的SSH公钥内容（通常以 'ssh-rsa' 或 'ssh-ed25519' 开头）: " public_key
	fi

	if [[ -z "$public_key" ]]; then
		echo -e "${rw_hong}错误：未输入公钥内容。${rw_lv}"
		return 1
	fi

	if [[ ! "$public_key" =~ ^ssh-(rsa|ed25519|ecdsa) ]]; then
		echo -e "${rw_hong}错误：看起来不像合法的 SSH 公钥。${rw_lv}"
		return 1
	fi

	if grep -Fxq "$public_key" "$auth_keys" 2>/dev/null; then
		echo "该公钥已存在，无需重复添加"
		return 0
	fi

	mkdir -p "$ssh_dir"
	chmod 700 "$ssh_dir"
	touch "$auth_keys"
	echo "$public_key" >> "$auth_keys"
	chmod 600 "$auth_keys"

	sshkey_on
}



fetch_remote_ssh_keys() {

	local keys_url="$1"
	local base_dir="${2:-$HOME}"
	local ssh_dir="${base_dir}/.ssh"
	local authorized_keys="${ssh_dir}/authorized_keys"
	local temp_file

	if [[ -z "${keys_url}" ]]; then
		read -e -p "请输入您的远端公钥URL： " keys_url
	fi

	echo "此脚本将从远程 URL 拉取 SSH 公钥，并添加到 ${authorized_keys}"
	echo ""
	echo "远程公钥地址："
	echo "  ${keys_url}"
	echo ""

	# 创建临时文件
	temp_file=$(mktemp)

	# 下载公钥
	if command -v curl >/dev/null 2>&1; then
		curl -fsSL --connect-timeout 10 "${keys_url}" -o "${temp_file}" || {
			echo "错误：无法从 URL 下载公钥（网络问题或地址无效）" >&2
			rm -f "${temp_file}"
			return 1
		}
	elif command -v wget >/dev/null 2>&1; then
		wget -q --timeout=10 -O "${temp_file}" "${keys_url}" || {
			echo "错误：无法从 URL 下载公钥（网络问题或地址无效）" >&2
			rm -f "${temp_file}"
			return 1
		}
	else
		echo "错误：系统中未找到 curl 或 wget，无法下载公钥" >&2
		rm -f "${temp_file}"
		return 1
	fi

	# 检查内容是否有效
	if [[ ! -s "${temp_file}" ]]; then
		echo "错误：下载到的文件为空，URL 可能不包含任何公钥" >&2
		rm -f "${temp_file}"
		return 1
	fi

	mkdir -p "${ssh_dir}"
	chmod 700 "${ssh_dir}"
	touch "${authorized_keys}"
	chmod 600 "${authorized_keys}"

	# 备份原有 authorized_keys
	if [[ -f "${authorized_keys}" ]]; then
		cp "${authorized_keys}" "${authorized_keys}.bak.$(date +%Y%m%d-%H%M%S)"
		echo "已备份原有 authorized_keys 文件"
	fi

	# 追加公钥（避免重复）
	local added=0
	while IFS= read -r line; do
		[[ -z "${line}" || "${line}" =~ ^# ]] && continue

		if ! grep -Fxq "${line}" "${authorized_keys}" 2>/dev/null; then
			echo "${line}" >> "${authorized_keys}"
			((added++))
		fi
	done < "${temp_file}"

	rm -f "${temp_file}"

	echo ""
	if (( added > 0 )); then
		echo "成功添加 ${added} 条新的公钥到 ${authorized_keys}"
		sshkey_on
	else
		echo "没有新的公钥需要添加（可能已全部存在）"
	fi

	echo ""
}




fetch_github_ssh_keys() {

	local username="$1"
	local base_dir="${2:-$HOME}"

	echo "操作前，请确保您已在 GitHub 账户中添加了 SSH 公钥："
	echo "  1. 登录 ${gh_https_url}github.com/settings/keys"
	echo "  2. 点击 New SSH key 或 Add SSH key"
	echo "  3. Title 可随意填写（例如：Home Laptop 2026）"
	echo "  4. 将本地公钥内容（通常是 ~/.ssh/id_ed25519.pub 或 id_rsa.pub 的全部内容）粘贴到 Key 字段"
	echo "  5. 点击 Add SSH key 完成添加"
	echo ""
	echo "添加完成后，GitHub 会公开提供您的所有公钥，地址为："
	echo "  ${gh_https_url}github.com/您的用户名.keys"
	echo ""


	if [[ -z "${username}" ]]; then
		read -e -p "请输入您的 GitHub 用户名（username，不含 @）： " username
	fi

	if [[ -z "${username}" ]]; then
		echo "错误：GitHub 用户名不能为空" >&2
		return 1
	fi

	keys_url="${gh_https_url}github.com/${username}.keys"

	fetch_remote_ssh_keys "${keys_url}" "${base_dir}"

}


sshkey_panel() {
  root_use
  send_stats "用户密钥登录"
  while true; do
	  clear
	  local REAL_STATUS=$(grep -i "^PubkeyAuthentication" /etc/ssh/sshd_config | tr '[:upper:]' '[:lower:]')
	  if [[ "$REAL_STATUS" =~ "yes" ]]; then
		  IS_KEY_ENABLED="${rw_lv}已启用${rw_lv}"
	  else
	  	  IS_KEY_ENABLED="${rw_lv}未启用${rw_lv}"
	  fi
  	  echo -e "用户密钥登录模式 ${IS_KEY_ENABLED}"
  	  echo "进阶玩法: https://blog.riwi.pro/ssh-key"
  	  echo -e "${rw_cheng}------------------------------------------------${rw_lv}"
  	  echo "将会生成密钥对，更安全的方式SSH登录"
	  echo -e "${rw_cheng}------------------------${rw_lv}"
	  echo "1. 生成新密钥对                  2. 手动输入已有公钥"
	  echo "3. 从GitHub导入已有公钥          4. 从URL导入已有公钥"
	  echo "5. 编辑公钥文件                  6. 查看本机密钥"
	  echo -e "${rw_cheng}------------------------${rw_lv}"
	  echo "0. 返回上一级选单"
	  echo -e "${rw_cheng}------------------------${rw_lv}"
	  read -e -p "请输入你的选择: " host_dns
	  case $host_dns in
		  1)
	  		send_stats "生成新密钥"
	  		add_sshkey
			break_end
			  ;;
		  2)
			send_stats "导入已有公钥"
			import_sshkey
			break_end
			  ;;
		  3)
			send_stats "导入GitHub远端公钥"
			fetch_github_ssh_keys
			break_end
			  ;;
		  4)
			send_stats "导入URL远端公钥"
			read -e -p "请输入您的远端公钥URL： " keys_url
			fetch_remote_ssh_keys "${keys_url}"
			break_end
			  ;;

		  5)
			send_stats "编辑公钥文件"
			install nano
			nano ${HOME}/.ssh/authorized_keys
			break_end
			  ;;

		  6)
			send_stats "查看本机密钥"
			echo -e "${rw_cheng}------------------------${rw_lv}"
			echo "公钥信息"
			cat ${HOME}/.ssh/authorized_keys
			echo -e "${rw_cheng}------------------------${rw_lv}"
			echo "私钥信息"
			cat ${HOME}/.ssh/sshkey
			echo -e "${rw_cheng}------------------------${rw_lv}"
			break_end
			  ;;
		  *)
			  break  # 跳出循环，退出菜单
			  ;;
	  esac
  done


}






add_sshpasswd() {

	root_use
	send_stats "设置密码登录模式"
	echo "设置密码登录模式"

	local target_user="$1"

	# 如果没有通过参数传入，则交互输入
	if [[ -z "$target_user" ]]; then
		read -e -p "请输入要修改密码的用户名（默认 root）: " target_user
	fi

	# 回车不输入，默认 root
	target_user=${target_user:-root}

	# 校验用户是否存在
	if ! id "$target_user" >/dev/null 2>&1; then
		echo "错误：用户 $target_user 不存在"
		return 1
	fi

	passwd "$target_user"

	if [[ "$target_user" == "root" ]]; then
		sed -i 's/^[[:space:]]*#\?[[:space:]]*PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config
	fi

	sed -i 's/^[[:space:]]*#\?[[:space:]]*PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config
	rm -rf /etc/ssh/sshd_config.d/* /etc/ssh/ssh_config.d/*

	restart_ssh

	echo -e "${rw_lv}密码设置完毕，已更改为密码登录模式！${rw_lv}"
}














root_use() {
clear
[ "$EUID" -ne 0 ] && echo -e "${rw_huang}提示: ${rw_lv}该功能需要root用户才能运行！" && break_end && riwi
}












dd_xitong() {
		send_stats "重装系统"
		dd_xitong_MollyLau() {
			wget --no-check-certificate -qO InstallNET.sh "${gh_proxy}raw.githubusercontent.com/leitbogioro/Tools/master/Linux_reinstall/InstallNET.sh" && chmod a+x InstallNET.sh

		}

		dd_xitong_bin456789() {
			curl -O ${gh_proxy}raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh
		}

		dd_xitong_1() {
		  echo -e "重装后初始用户名: ${rw_huang}root${rw_lv}  初始密码: ${rw_huang}LeitboGi0ro${rw_lv}  初始端口: ${rw_huang}22${rw_lv}"
		  echo -e "${rw_huang}重装后请及时修改初始密码，防止暴力入侵。命令行输入passwd修改密码${rw_lv}"
		  echo -e "按任意键继续..."
		  read -n 1 -s -r -p ""
		  install wget
		  dd_xitong_MollyLau
		}

		dd_xitong_2() {
		  echo -e "重装后初始用户名: ${rw_huang}Administrator${rw_lv}  初始密码: ${rw_huang}Teddysun.com${rw_lv}  初始端口: ${rw_huang}3389${rw_lv}"
		  echo -e "按任意键继续..."
		  read -n 1 -s -r -p ""
		  install wget
		  dd_xitong_MollyLau
		}

		dd_xitong_3() {
		  echo -e "重装后初始用户名: ${rw_huang}root${rw_lv}  初始密码: ${rw_huang}123@@@${rw_lv}  初始端口: ${rw_huang}22${rw_lv}"
		  echo -e "按任意键继续..."
		  read -n 1 -s -r -p ""
		  dd_xitong_bin456789
		}

		dd_xitong_4() {
		  echo -e "重装后初始用户名: ${rw_huang}Administrator${rw_lv}  初始密码: ${rw_huang}123@@@${rw_lv}  初始端口: ${rw_huang}3389${rw_lv}"
		  echo -e "按任意键继续..."
		  read -n 1 -s -r -p ""
		  dd_xitong_bin456789
		}

		  while true; do
			root_use
			echo "重装系统"
			echo -e "${rw_cheng}--------------------------------${rw_lv}"
			echo -e "${rw_hong}注意: ${rw_lv}重装有风险失联，不放心者慎用。重装预计花费15分钟，请提前备份数据。"
			echo -e "${rw_lv}感谢bin456789大佬和leitbogioro大佬的脚本支持！${rw_lv} "
			echo -e "${rw_lv}bin456789项目地址: ${gh_https_url}github.com/bin456789/reinstall${rw_lv}"
			echo -e "${rw_lv}leitbogioro项目地址: ${gh_https_url}github.com/leitbogioro/Tools${rw_lv}"
			echo -e "${rw_cheng}------------------------${rw_lv}"
			echo "1. Debian 13                  2. Debian 12"
			echo "3. Debian 11                  4. Debian 10"
			echo -e "${rw_cheng}------------------------${rw_lv}"
			echo "11. Ubuntu 26.04              12. Ubuntu 24.04"
			echo "13. Ubuntu 22.04              14. Ubuntu 20.04"
			echo -e "${rw_cheng}------------------------${rw_lv}"
			echo "21. Rocky Linux 10            22. Rocky Linux 9"
			echo "23. Alma Linux 10             24. Alma Linux 9"
			echo "25. oracle Linux 10           26. oracle Linux 9"
			echo "27. Fedora Linux 44           28. Fedora Linux 43"
			echo "29. CentOS 10                 30. CentOS 9"
			echo -e "${rw_cheng}------------------------${rw_lv}"
			echo "31. Alpine Linux              32. Arch Linux"
			echo "33. Kali Linux                34. openEuler"
			echo "35. openSUSE Tumbleweed       36. fnos飞牛公测版"
			echo -e "${rw_cheng}------------------------${rw_lv}"
			echo "41. Windows 11                42. Windows 10"
			echo "43. Windows 7                 44. Windows Server 2025"
			echo "45. Windows Server 2022       46. Windows Server 2019"
			echo "47. Windows 11 ARM"
			echo -e "${rw_cheng}------------------------${rw_lv}"
			echo "0. 返回上一级选单"
			echo -e "${rw_cheng}------------------------${rw_lv}"
			read -e -p "请选择要重装的系统: " sys_choice
			case "$sys_choice" in


			  1)
				send_stats "重装debian 13"
				dd_xitong_3
				bash reinstall.sh debian 13
				reboot
				exit
				;;

			  2)
				send_stats "重装debian 12"
				dd_xitong_1
				bash InstallNET.sh -debian 12
				reboot
				exit
				;;
			  3)
				send_stats "重装debian 11"
				dd_xitong_1
				bash InstallNET.sh -debian 11
				reboot
				exit
				;;
			  4)
				send_stats "重装debian 10"
				dd_xitong_1
				bash InstallNET.sh -debian 10
				reboot
				exit
				;;
			  11)
				send_stats "重装ubuntu 26.04"
				dd_xitong_3
				bash reinstall.sh ubuntu 26.04
				reboot
				exit
				;;
			  12)
				send_stats "重装ubuntu 24.04"
				dd_xitong_1
				bash InstallNET.sh -ubuntu 24.04
				reboot
				exit
				;;
			  13)
				send_stats "重装ubuntu 22.04"
				dd_xitong_1
				bash InstallNET.sh -ubuntu 22.04
				reboot
				exit
				;;
			  14)
				send_stats "重装ubuntu 20.04"
				dd_xitong_1
				bash InstallNET.sh -ubuntu 20.04
				reboot
				exit
				;;

			  21)
				send_stats "重装rockylinux10"
				dd_xitong_3
				bash reinstall.sh rocky
				reboot
				exit
				;;

			  22)
				send_stats "重装rockylinux9"
				dd_xitong_3
				bash reinstall.sh rocky 9
				reboot
				exit
				;;

			  23)
				send_stats "重装alma10"
				dd_xitong_3
				bash reinstall.sh almalinux
				reboot
				exit
				;;

			  24)
				send_stats "重装alma9"
				dd_xitong_3
				bash reinstall.sh almalinux 9
				reboot
				exit
				;;

			  25)
				send_stats "重装oracle10"
				dd_xitong_3
				bash reinstall.sh oracle
				reboot
				exit
				;;

			  26)
				send_stats "重装oracle9"
				dd_xitong_3
				bash reinstall.sh oracle 9
				reboot
				exit
				;;

			  27)
				send_stats "重装fedora44"
				dd_xitong_3
				bash reinstall.sh fedora 44
				reboot
				exit
				;;

			  28)
				send_stats "重装fedora43"
				dd_xitong_3
				bash reinstall.sh fedora 43
				reboot
				exit
				;;

			  29)
				send_stats "重装centos10"
				dd_xitong_3
				bash reinstall.sh centos 10
				reboot
				exit
				;;

			  30)
				send_stats "重装centos9"
				dd_xitong_3
				bash reinstall.sh centos 9
				reboot
				exit
				;;

			  31)
				send_stats "重装alpine"
				dd_xitong_1
				bash InstallNET.sh -alpine
				reboot
				exit
				;;

			  32)
				send_stats "重装arch"
				dd_xitong_3
				bash reinstall.sh arch
				reboot
				exit
				;;

			  33)
				send_stats "重装kali"
				dd_xitong_3
				bash reinstall.sh kali
				reboot
				exit
				;;

			  34)
				send_stats "重装openeuler"
				dd_xitong_3
				bash reinstall.sh openeuler
				reboot
				exit
				;;

			  35)
				send_stats "重装opensuse"
				dd_xitong_3
				bash reinstall.sh opensuse
				reboot
				exit
				;;

			  36)
				send_stats "重装飞牛"
				dd_xitong_3
				bash reinstall.sh fnos
				reboot
				exit
				;;

			  41)
				send_stats "重装windows11"
				dd_xitong_2
				bash InstallNET.sh -windows 11 -lang "cn"
				reboot
				exit
				;;

			  42)
				dd_xitong_2
				send_stats "重装windows10"
				bash InstallNET.sh -windows 10 -lang "cn"
				reboot
				exit
				;;

			  43)
				send_stats "重装windows7"
				dd_xitong_4
				bash reinstall.sh windows --iso="https://archive.org/download/en_windows_7_professional_with_sp1_x64_dvd_u_676939_201906/en_windows_7_professional_with_sp1_x64_dvd_u_676939.iso" --image-name='windows 7 professional'
				reboot
				exit
				;;

			  44)
				send_stats "重装windows server 25"
				dd_xitong_2
				bash InstallNET.sh -windows 2025 -lang "cn"
				reboot
				exit
				;;

			  45)
				send_stats "重装windows server 22"
				dd_xitong_2
				bash InstallNET.sh -windows 2022 -lang "cn"
				reboot
				exit
				;;

			  46)
				send_stats "重装windows server 19"
				dd_xitong_2
				bash InstallNET.sh -windows 2019 -lang "cn"
				reboot
				exit
				;;

			  47)
				send_stats "重装windows11 ARM"
				dd_xitong_4
				bash reinstall.sh dd --img https://r2.hotdog.eu.org/win11-arm-with-pagefile-15g.xz
				reboot
				exit
				;;

			  *)
				break
				;;
			esac
		  done
}


bbrv3() {
		  root_use
		  send_stats "bbrv3管理"

		  xanmod_add_repo() {
				local keyring="/usr/share/keyrings/xanmod-archive-keyring.gpg"
				local list_file="/etc/apt/sources.list.d/xanmod-release.list"
				local key_url="https://dl.xanmod.org/archive.key"
				local fallback_key_url="${gh_proxy}raw.githubusercontent.com/riwi/sh/main/archive.key"
				local os_codename=""

				if command -v lsb_release >/dev/null 2>&1; then
					os_codename=$(lsb_release -sc)
				elif [ -r /etc/os-release ]; then
					os_codename=$(. /etc/os-release && echo "$VERSION_CODENAME")
				fi
				
				# 兼容官方已移除的老系统代号（回退使用 releases 尝试旧包库）
				if ! echo "bookworm trixie forky sid noble plucky questing resolute faye gigi wilma xia zara zena jammy" | grep -qw "$os_codename"; then
					os_codename="releases"
				fi

				if [ -z "$os_codename" ]; then
					echo "无法获取系统代号，无法配置XanMod源"
					return 1
				fi

				install wget gnupg ca-certificates
				mkdir -p /usr/share/keyrings /etc/apt/sources.list.d
				if ! wget -qO - "$key_url" | gpg --dearmor -o "$keyring" --yes; then
					echo "官方密钥下载失败，尝试备用下载源..."
					wget -qO - "$fallback_key_url" | gpg --dearmor -o "$keyring" --yes || return 1
				fi
				chmod 644 "$keyring"
				echo "deb [signed-by=$keyring] http://deb.xanmod.org $os_codename main" > "$list_file"
		  }

		  xanmod_detect_psabi_level() {
				local psabi_output=""
				psabi_output=$(awk 'BEGIN {
					while (!/flags/) if (getline < "/proc/cpuinfo" != 1) exit 1
					if (/lm/&&/cmov/&&/cx8/&&/fpu/&&/fxsr/&&/mmx/&&/syscall/&&/sse2/) level = 1
					if (level == 1 && /cx16/&&/lahf/&&/popcnt/&&/sse4_1/&&/sse4_2/&&/ssse3/) level = 2
					if (level == 2 && /avx/&&/avx2/&&/bmi1/&&/bmi2/&&/f16c/&&/fma/&&/abm/&&/movbe/&&/xsave/) level = 3
					if (level == 3 && /avx512f/&&/avx512bw/&&/avx512cd/&&/avx512dq/&&/avx512vl/) level = 4
					if (level > 0) { print level; exit }
					exit 1
				}' /proc/cpuinfo 2>/dev/null) || return 1
				printf '%s' "$psabi_output" | tr -dc '0-9' | head -c 1
		  }

		  xanmod_package_available() {
				local package="$1"
				apt-cache policy "$package" 2>/dev/null | grep -q 'Candidate: [^ ]'
		  }

		  xanmod_detect_package() {
				local psabi_level=""
				local level=""
				local package=""
				local prefix_list="linux-xanmod linux-xanmod-lts"

				psabi_level=$(xanmod_detect_psabi_level) || return 1
				[ -n "$psabi_level" ] || return 1
				[ "$psabi_level" -gt 3 ] && psabi_level=3

				apt update -y >/dev/null 2>&1

				for prefix in $prefix_list; do
					level="$psabi_level"
					while [ "$level" -ge 1 ]; do
						package="${prefix}-x64v${level}"
						if xanmod_package_available "$package"; then
							if [ "$level" != "$psabi_level" ] || [ "$prefix" = "linux-xanmod-lts" ]; then
								echo "已自动匹配合适安装包: $package" >&2
							fi
							printf '%s\n' "$package"
							return 0
						fi
						level=$((level - 1))
					done
				done

				echo "软件源中未找到适配此CPU的XanMod内核包" >&2
				return 1
		  }

		  xanmod_installed() {
				dpkg-query -W -f='${Package}\n' 'linux-*xanmod*' 2>/dev/null | grep -q '^linux-.*xanmod'
		  }

		  xanmod_install_or_update() {
				local action="$1"
				local package=""

				check_disk_space 3
				check_swap
				xanmod_add_repo || {
					echo "XanMod官方仓库配置失败，请稍后重试"
					return 1
				}

				package=$(xanmod_detect_package) || {
					echo "无法识别当前CPU或找不到匹配内核包，已取消安装"
					return 1
				}

				apt update -y
				if [ "$action" = "update" ]; then
					apt install -y --only-upgrade "$package" || apt install -y "$package" || {
						echo "XanMod内核更新失败，请检查软件源或稍后重试"
						return 1
					}
				else
					apt install -y "$package" || {
						echo "XanMod内核安装失败，请检查软件源或稍后重试"
						return 1
					}
				fi

				bbr_on || {
					echo "BBR3参数写入失败，请检查系统配置"
					return 1
				}
				echo "XanMod BBRv3内核处理完成。重启后生效"
				server_reboot
		  }

		  xanmod_uninstall() {
				apt purge -y 'linux-*xanmod*'
				apt autoremove -y
				update-grub 2>/dev/null || true
				rm -f /etc/apt/sources.list.d/xanmod-release.list
				rm -f /usr/share/keyrings/xanmod-archive-keyring.gpg
				echo "XanMod内核已卸载。重启后生效"
				server_reboot
		  }

		  local cpu_arch=$(uname -m)
		  if [ "$cpu_arch" = "aarch64" ]; then
			bash <(curl -sL jhb.ovh/jb/bbrv3arm.sh)
			break_end
			update_clean_menu
		  fi

		  if [ -r /etc/os-release ]; then
			. /etc/os-release
			if [ "$ID" != "debian" ] && [ "$ID" != "ubuntu" ]; then
				echo "当前环境不支持，仅支持Debian和Ubuntu系统"
				break_end
				update_clean_menu
			fi
		  else
			echo "无法确定操作系统类型"
			break_end
			update_clean_menu
		  fi

		  if xanmod_installed; then
			while true; do
				  clear
				  local kernel_version=$(uname -r)
				  echo "您已安装xanmod的BBRv3内核"
				  echo "当前内核版本: $kernel_version"

				  echo ""
				  echo "内核管理"
				  echo -e "${rw_cheng}------------------------${rw_lv}"
				  echo "1. 更新BBRv3内核              2. 卸载BBRv3内核"
				  echo -e "${rw_cheng}------------------------${rw_lv}"
				  echo "0. 返回上一级选单"
				  echo -e "${rw_cheng}------------------------${rw_lv}"
				  read -e -p "请输入你的选择: " sub_choice

				  case $sub_choice in
					  1)
						xanmod_install_or_update update
						;;
					  2)
						xanmod_uninstall
						;;
					  *)
						break
						;;

				  esac
			done
		else

		  clear
		  echo "设置BBR3加速"
		  echo "视频介绍: https://www.bilibili.com/video/BV14K421x7BS?t=0.1"
		  echo -e "${rw_cheng}------------------------------------------------${rw_lv}"
		  echo "仅支持Debian/Ubuntu"
		  echo "请备份数据，将为你升级Linux内核开启BBR3"
		  echo -e "${rw_cheng}------------------------------------------------${rw_lv}"
		  read -e -p "确定继续吗？(Y/N): " choice

		  case "$choice" in
			[Yy])
			xanmod_install_or_update install
			  ;;
			[Nn])
			  echo "已取消"
			  ;;
			*)
			  echo "无效的选择，请输入 Y 或 N。"
			  ;;
		  esac
		fi

}

elrepo_install() {
	# 导入 ELRepo GPG 公钥
	echo "导入 ELRepo GPG 公钥..."
	rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
	# 检测系统版本
	local os_version=$(rpm -q --qf "%{VERSION}" $(rpm -qf /etc/os-release) 2>/dev/null | awk -F '.' '{print $1}')
	local os_name=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
	# 确保我们在一个支持的操作系统上运行
	if [[ "$os_name" != *"Red Hat"* && "$os_name" != *"AlmaLinux"* && "$os_name" != *"Rocky"* && "$os_name" != *"Oracle"* && "$os_name" != *"CentOS"* ]]; then
		echo "不支持的操作系统：$os_name"
		break_end
		update_clean_menu
	fi
	# 打印检测到的操作系统信息
	echo "检测到的操作系统: $os_name $os_version"
	# 根据系统版本安装对应的 ELRepo 仓库配置
	if [[ "$os_version" == 8 ]]; then
		echo "安装 ELRepo 仓库配置 (版本 8)..."
		yum -y install https://www.elrepo.org/elrepo-release-8.el8.elrepo.noarch.rpm
	elif [[ "$os_version" == 9 ]]; then
		echo "安装 ELRepo 仓库配置 (版本 9)..."
		yum -y install https://www.elrepo.org/elrepo-release-9.el9.elrepo.noarch.rpm
	elif [[ "$os_version" == 10 ]]; then
		echo "安装 ELRepo 仓库配置 (版本 10)..."
		yum -y install https://www.elrepo.org/elrepo-release-10.el10.elrepo.noarch.rpm
	else
		echo "不支持的系统版本：$os_version"
		break_end
		update_clean_menu
	fi
	# 启用 ELRepo 内核仓库并安装最新的主线内核
	echo "启用 ELRepo 内核仓库并安装最新的主线内核..."
	# yum -y --enablerepo=elrepo-kernel install kernel-ml
	yum --nogpgcheck -y --enablerepo=elrepo-kernel install kernel-ml
	echo "已安装 ELRepo 仓库配置并更新到最新主线内核。"
	server_reboot

}


elrepo() {
		  root_use
		  send_stats "红帽内核管理"
		  if uname -r | grep -q 'elrepo'; then
			while true; do
				  clear
				  kernel_version=$(uname -r)
				  echo "您已安装elrepo内核"
				  echo "当前内核版本: $kernel_version"

				  echo ""
				  echo "内核管理"
				  echo -e "${rw_cheng}------------------------${rw_lv}"
				  echo "1. 更新elrepo内核              2. 卸载elrepo内核"
				  echo -e "${rw_cheng}------------------------${rw_lv}"
				  echo "0. 返回上一级选单"
				  echo -e "${rw_cheng}------------------------${rw_lv}"
				  read -e -p "请输入你的选择: " sub_choice

				  case $sub_choice in
					  1)
						dnf remove -y elrepo-release
						rpm -qa | grep elrepo | grep kernel | xargs rpm -e --nodeps
						elrepo_install
						send_stats "更新红帽内核"
						server_reboot

						  ;;
					  2)
						dnf remove -y elrepo-release
						rpm -qa | grep elrepo | grep kernel | xargs rpm -e --nodeps
						echo "elrepo内核已卸载。重启后生效"
						send_stats "卸载红帽内核"
						server_reboot

						  ;;
					  *)
						  break  # 跳出循环，退出菜单
						  ;;

				  esac
			done
		else

		  clear
		  echo "请备份数据，将为你升级Linux内核"
		  echo "视频介绍: https://www.bilibili.com/video/BV1mH4y1w7qA?t=529.2"
		  echo -e "${rw_cheng}------------------------------------------------${rw_lv}"
		  echo "仅支持红帽系列发行版 CentOS/RedHat/Alma/Rocky/oracle "
		  echo "升级Linux内核可提升系统性能和安全，建议有条件的尝试，生产环境谨慎升级！"
		  echo -e "${rw_cheng}------------------------------------------------${rw_lv}"
		  read -e -p "确定继续吗？(Y/N): " choice

		  case "$choice" in
			[Yy])
			  check_swap
			  elrepo_install
			  send_stats "升级红帽内核"
			  server_reboot
			  ;;
			[Nn])
			  echo "已取消"
			  ;;
			*)
			  echo "无效的选择，请输入 Y 或 N。"
			  ;;
		  esac
		fi

}




clamav_freshclam() {
	echo -e "${rw_huang}正在更新病毒库...${rw_lv}"
	docker run --rm \
		--name clamav \
		--mount source=clam_db,target=/var/lib/clamav \
		clamav/clamav-debian:latest \
		freshclam
}

clamav_scan() {
	if [ $# -eq 0 ]; then
		echo "请指定要扫描的目录。"
		return
	fi

	echo -e "${rw_huang}正在扫描目录$@... ${rw_lv}"

	# 构建 mount 参数
	local MOUNT_PARAMS=""
	for dir in "$@"; do
		MOUNT_PARAMS+="--mount type=bind,source=${dir},target=/mnt/host${dir} "
	done

	# 构建 clamscan 命令参数
	local SCAN_PARAMS=""
	for dir in "$@"; do
		SCAN_PARAMS+="/mnt/host${dir} "
	done

	mkdir -p /home/docker/clamav/log/ > /dev/null 2>&1
	> /home/docker/clamav/log/scan.log > /dev/null 2>&1

	# 执行 Docker 命令
	docker run --rm \
		--name clamav \
		--mount source=clam_db,target=/var/lib/clamav \
		$MOUNT_PARAMS \
		-v /home/docker/clamav/log/:/var/log/clamav/ \
		clamav/clamav-debian:latest \
		clamscan -r --log=/var/log/clamav/scan.log $SCAN_PARAMS

	echo -e "${rw_lv}$@ 扫描完成，病毒报告存放在${rw_huang}/home/docker/clamav/log/scan.log${rw_lv}"
	echo -e "${rw_lv}如果有病毒请在${rw_huang}scan.log${rw_lv}文件中搜索FOUND关键字确认病毒位置 ${rw_lv}"

}







clamav() {
		  root_use
		  send_stats "病毒扫描管理"
		  while true; do
				clear
				echo "clamav病毒扫描工具"
				echo "视频介绍: https://www.bilibili.com/video/BV1TqvZe4EQm?t=0.1"
				echo -e "${rw_cheng}------------------------${rw_lv}"
				echo "是一个开源的防病毒软件工具，主要用于检测和删除各种类型的恶意软件。"
				echo "包括病毒、特洛伊木马、间谍软件、恶意脚本和其他有害软件。"
				echo -e "${rw_cheng}------------------------${rw_lv}"
				echo -e "${rw_lv}1. 全盘扫描 ${rw_lv}             ${rw_huang}2. 重要目录扫描 ${rw_lv}            ${rw_huang} 3. 自定义目录扫描 ${rw_lv}"
				echo -e "${rw_cheng}------------------------${rw_lv}"
				echo "0. 返回上一级选单"
				echo -e "${rw_cheng}------------------------${rw_lv}"
				read -e -p "请输入你的选择: " sub_choice
				case $sub_choice in
					1)
					  send_stats "全盘扫描"
					  install_docker
					  docker volume create clam_db > /dev/null 2>&1
					  clamav_freshclam
					  clamav_scan /
					  break_end

						;;
					2)
					  send_stats "重要目录扫描"
					  install_docker
					  docker volume create clam_db > /dev/null 2>&1
					  clamav_freshclam
					  clamav_scan /etc /var /usr /home /root
					  break_end
						;;
					3)
					  send_stats "自定义目录扫描"
					  read -e -p "请输入要扫描的目录，用空格分隔（例如：/etc /var /usr /home /root）: " directories
					  install_docker
					  clamav_freshclam
					  clamav_scan $directories
					  break_end
						;;
					*)
					  break  # 跳出循环，退出菜单
						;;
				esac
		  done

}


# ============================================================================
# Linux 内核调优模块（重构版）
# 统一核心函数 + 场景差异化参数 + 持久化到配置文件 + 硬件自适应
# 替换原 optimize_high_performance / optimize_balanced / optimize_web_server / restore_defaults
# ============================================================================

# 获取内存大小（MB）
_get_mem_mb() {
	awk '/MemTotal/{printf "%d", $2/1024}' /proc/meminfo
}

# 统一内核调优核心函数
# 参数: $1 = 模式名称, $2 = 场景 (high/balanced/web/stream/game)
_kernel_optimize_core() {
	local mode_name="$1"
	local scene="${2:-high}"
	local CONF="/etc/sysctl.d/99-riwi-optimize.conf"
	local MEM_MB=$(_get_mem_mb)

	echo -e "${rw_lv}切换到${mode_name}...${rw_lv}"

	# ── 根据场景设定参数 ──
	local SWAPPINESS DIRTY_RATIO DIRTY_BG_RATIO OVERCOMMIT MIN_FREE_KB VFS_PRESSURE
	local RMEM_MAX WMEM_MAX TCP_RMEM TCP_WMEM
	local SOMAXCONN BACKLOG SYN_BACKLOG
	local PORT_RANGE SCHED_AUTOGROUP THP NUMA FIN_TIMEOUT
	local KEEPALIVE_TIME KEEPALIVE_INTVL KEEPALIVE_PROBES

	case "$scene" in
		high|stream|game)
			# 高性能/直播/游戏：激进参数
			SWAPPINESS=10
			DIRTY_RATIO=15
			DIRTY_BG_RATIO=5
			OVERCOMMIT=1
			VFS_PRESSURE=50
			RMEM_MAX=67108864
			WMEM_MAX=67108864
			TCP_RMEM="4096 262144 67108864"
			TCP_WMEM="4096 262144 67108864"
			SOMAXCONN=8192
			BACKLOG=250000
			SYN_BACKLOG=8192
			PORT_RANGE="1024 65535"
			SCHED_AUTOGROUP=0
			THP="never"
			NUMA=0
			FIN_TIMEOUT=10
			KEEPALIVE_TIME=300
			KEEPALIVE_INTVL=30
			KEEPALIVE_PROBES=5
			;;
		web)
			# 网站服务器：高并发优先
			SWAPPINESS=10
			DIRTY_RATIO=20
			DIRTY_BG_RATIO=10
			OVERCOMMIT=1
			VFS_PRESSURE=50
			RMEM_MAX=33554432
			WMEM_MAX=33554432
			TCP_RMEM="4096 131072 33554432"
			TCP_WMEM="4096 131072 33554432"
			SOMAXCONN=16384
			BACKLOG=10000
			SYN_BACKLOG=16384
			PORT_RANGE="1024 65535"
			SCHED_AUTOGROUP=0
			THP="never"
			NUMA=0
			FIN_TIMEOUT=15
			KEEPALIVE_TIME=600
			KEEPALIVE_INTVL=60
			KEEPALIVE_PROBES=5
			;;
		balanced)
			# 均衡模式：适度优化
			SWAPPINESS=30
			DIRTY_RATIO=20
			DIRTY_BG_RATIO=10
			OVERCOMMIT=0
			VFS_PRESSURE=75
			RMEM_MAX=16777216
			WMEM_MAX=16777216
			TCP_RMEM="4096 87380 16777216"
			TCP_WMEM="4096 65536 16777216"
			SOMAXCONN=4096
			BACKLOG=5000
			SYN_BACKLOG=4096
			PORT_RANGE="1024 49151"
			SCHED_AUTOGROUP=1
			THP="always"
			NUMA=1
			FIN_TIMEOUT=30
			KEEPALIVE_TIME=600
			KEEPALIVE_INTVL=60
			KEEPALIVE_PROBES=5
			;;
	esac

	# ── 根据内存大小自适应调整 ──
	if [ "$MEM_MB" -ge 16384 ]; then
		MIN_FREE_KB=131072
		[ "$scene" != "balanced" ] && SWAPPINESS=5
	elif [ "$MEM_MB" -ge 4096 ]; then
		MIN_FREE_KB=65536
	elif [ "$MEM_MB" -ge 1024 ]; then
		MIN_FREE_KB=32768
		# 小内存缩小缓冲区
		if [ "$scene" != "balanced" ]; then
			RMEM_MAX=16777216
			WMEM_MAX=16777216
			TCP_RMEM="4096 87380 16777216"
			TCP_WMEM="4096 65536 16777216"
		fi
	else
		MIN_FREE_KB=16384
		SWAPPINESS=30
		OVERCOMMIT=0
		RMEM_MAX=4194304
		WMEM_MAX=4194304
		TCP_RMEM="4096 32768 4194304"
		TCP_WMEM="4096 32768 4194304"
		SOMAXCONN=1024
		BACKLOG=1000
	fi

	# ── 直播场景额外：UDP 缓冲区加大 ──
	local STREAM_EXTRA=""
	if [ "$scene" = "stream" ]; then
		STREAM_EXTRA="
# 直播推流 UDP 优化
net.ipv4.udp_rmem_min = 16384
net.ipv4.udp_wmem_min = 16384
net.ipv4.tcp_notsent_lowat = 16384"
	fi

	# ── 游戏服场景额外：低延迟优先 ──
	local GAME_EXTRA=""
	if [ "$scene" = "game" ]; then
		GAME_EXTRA="
# 游戏服低延迟优化
net.ipv4.udp_rmem_min = 16384
net.ipv4.udp_wmem_min = 16384
net.ipv4.tcp_notsent_lowat = 16384
net.ipv4.tcp_slow_start_after_idle = 0"
	fi

	# ── 加载 BBR 模块 ──
	local CC="bbr"
	local QDISC="fq"
	local KVER
	KVER=$(uname -r | sed -n -E 's/^([0-9]+\.[0-9]+).*/\1/p')
	if printf '%s\n%s' "4.9" "$KVER" | sort -V -C; then
		if ! lsmod 2>/dev/null | grep -q tcp_bbr; then
			modprobe tcp_bbr 2>/dev/null
		fi
		if ! sysctl net.ipv4.tcp_available_congestion_control 2>/dev/null | grep -q bbr; then
			CC="cubic"
			QDISC="fq_codel"
		fi
	else
		CC="cubic"
		QDISC="fq_codel"
	fi

	# ── 备份已有配置 ──
	[ -f "$CONF" ] && cp "$CONF" "${CONF}.bak.$(date +%s)"

	# ── 写入配置文件（持久化） ──
	echo -e "${rw_lv}写入优化配置...${rw_lv}"
	cat > "$CONF" << SYSCTL
# riwi 内核调优配置
# 模式: $mode_name | 场景: $scene
# 内存: ${MEM_MB}MB | 生成时间: $(date '+%Y-%m-%d %H:%M:%S')

# ── TCP 拥塞控制 ──
net.core.default_qdisc = $QDISC
net.ipv4.tcp_congestion_control = $CC

# ── TCP 缓冲区 ──
net.core.rmem_max = $RMEM_MAX
net.core.wmem_max = $WMEM_MAX
net.core.rmem_default = $(echo "$TCP_RMEM" | awk '{print $2}')
net.core.wmem_default = $(echo "$TCP_WMEM" | awk '{print $2}')
net.ipv4.tcp_rmem = $TCP_RMEM
net.ipv4.tcp_wmem = $TCP_WMEM

# ── 连接队列 ──
net.core.somaxconn = $SOMAXCONN
net.core.netdev_max_backlog = $BACKLOG
net.ipv4.tcp_max_syn_backlog = $SYN_BACKLOG

# ── TCP 连接优化 ──
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = $FIN_TIMEOUT
net.ipv4.tcp_keepalive_time = $KEEPALIVE_TIME
net.ipv4.tcp_keepalive_intvl = $KEEPALIVE_INTVL
net.ipv4.tcp_keepalive_probes = $KEEPALIVE_PROBES
net.ipv4.tcp_max_tw_buckets = 65536
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syn_retries = 3
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_window_scaling = 1

# ── 端口与内存 ──
net.ipv4.ip_local_port_range = $PORT_RANGE
net.ipv4.tcp_mem = $((MEM_MB * 1024 / 8)) $((MEM_MB * 1024 / 4)) $((MEM_MB * 1024 / 2))
net.ipv4.tcp_max_orphans = 32768

# ── 虚拟内存 ──
vm.swappiness = $SWAPPINESS
vm.dirty_ratio = $DIRTY_RATIO
vm.dirty_background_ratio = $DIRTY_BG_RATIO
vm.overcommit_memory = $OVERCOMMIT
vm.min_free_kbytes = $MIN_FREE_KB
vm.vfs_cache_pressure = $VFS_PRESSURE

# ── CPU/内核调度 ──
kernel.sched_autogroup_enabled = $SCHED_AUTOGROUP
$([ -f /proc/sys/kernel/numa_balancing ] && echo "kernel.numa_balancing = $NUMA" || echo "# numa_balancing 不支持")

# ── 安全防护 ──
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0

# ── 文件描述符 ──
fs.file-max = 1048576
fs.nr_open = 1048576

# ── 连接跟踪 ──
$(if [ -f /proc/sys/net/netfilter/nf_conntrack_max ]; then
echo "net.netfilter.nf_conntrack_max = $((SOMAXCONN * 32))"
echo "net.netfilter.nf_conntrack_tcp_timeout_established = 7200"
echo "net.netfilter.nf_conntrack_tcp_timeout_time_wait = 30"
echo "net.netfilter.nf_conntrack_tcp_timeout_close_wait = 15"
echo "net.netfilter.nf_conntrack_tcp_timeout_fin_wait = 15"
else
echo "# conntrack 未启用"
fi)
$STREAM_EXTRA
$GAME_EXTRA
SYSCTL

	# ── 应用配置（逐行，跳过不支持的参数） ──
	echo -e "${rw_lv}应用优化参数...${rw_lv}"
	local applied=0 skipped=0
	while IFS= read -r line; do
		# 跳过注释和空行
		[[ "$line" =~ ^[[:space:]]*# ]] && continue
		[[ -z "${line// /}" ]] && continue
		if sysctl -w "$line" >/dev/null 2>&1; then
			applied=$((applied + 1))
		else
			skipped=$((skipped + 1))
		fi
	done < "$CONF"
	echo -e "${rw_lv}已应用 ${applied} 项参数${skipped:+，跳过 ${skipped} 项不支持的参数}${rw_lv}"

	# ── 透明大页面 ──
	if [ -f /sys/kernel/mm/transparent_hugepage/enabled ]; then
		echo "$THP" > /sys/kernel/mm/transparent_hugepage/enabled 2>/dev/null
	fi

	# ── 文件描述符限制 ──
	if ! grep -q "# riwi-optimize" /etc/security/limits.conf 2>/dev/null; then
		cat >> /etc/security/limits.conf << 'LIMITS'

# riwi-optimize
* soft nofile 1048576
* hard nofile 1048576
root soft nofile 1048576
root hard nofile 1048576
LIMITS
	fi

	# ── BBR 持久化 ──
	if [ "$CC" = "bbr" ]; then
		echo "tcp_bbr" > /etc/modules-load.d/bbr.conf 2>/dev/null
		# 清理旧的 sysctl.conf 里的 bbr 配置（避免冲突）
		sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf 2>/dev/null
	fi

	echo -e "${rw_lv}${mode_name} 优化完成！配置已持久化到 ${CONF}${rw_lv}"
	echo -e "${rw_lv}内存: ${MEM_MB}MB | 拥塞算法: ${CC} | 队列: ${QDISC}${rw_lv}"
}

# ── 各模式入口函数（保持原有调用接口不变） ──

optimize_high_performance() {
	_kernel_optimize_core "${tiaoyou_moshi:-高性能优化模式}" "high"
}

optimize_balanced() {
	_kernel_optimize_core "均衡优化模式" "balanced"
}

optimize_web_server() {
	_kernel_optimize_core "网站搭建优化模式" "web"
}

# ── 还原默认设置（完全清理） ──
restore_defaults() {
	echo -e "${rw_lv}还原到默认设置...${rw_lv}"

	local CONF="/etc/sysctl.d/99-riwi-optimize.conf"

	# 删除优化配置文件（含外链自动调优配置）
	rm -f "$CONF"
	rm -f /etc/sysctl.d/99-network-optimize.conf

	# 清理 sysctl.conf 里可能残留的 bbr 配置
	sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf 2>/dev/null

	# 重新加载系统默认配置
	sysctl --system 2>/dev/null | tail -1

	# 还原透明大页面
	[ -f /sys/kernel/mm/transparent_hugepage/enabled ] && \
		echo always > /sys/kernel/mm/transparent_hugepage/enabled 2>/dev/null

	# 清理文件描述符配置
	if grep -q "# riwi-optimize" /etc/security/limits.conf 2>/dev/null; then
		sed -i '/# riwi-optimize/,+4d' /etc/security/limits.conf
	fi

	# 清理 BBR 持久化
	rm -f /etc/modules-load.d/bbr.conf 2>/dev/null

	echo -e "${rw_lv}系统已还原到默认设置${rw_lv}"
}


Kernel_optimize() {
	root_use
	while true; do
	  clear
	  send_stats "Linux内核调优管理"
	  local current_mode=$(grep "^# 模式:" /etc/sysctl.d/99-riwi-optimize.conf 2>/dev/null | sed 's/# 模式: //' | awk -F'|' '{print $1}' | xargs)
	  [ -z "$current_mode" ] && [ -f /etc/sysctl.d/99-network-optimize.conf ] && current_mode="自动调优模式"
	  echo "Linux系统内核参数优化"
	  if [ -n "$current_mode" ]; then
		  echo -e "当前模式: ${rw_lv}${current_mode}${rw_lv}"
	  else
		  echo -e "当前模式: ${rw_lv}未优化${rw_lv}"
	  fi
	  echo "视频介绍: https://www.bilibili.com/video/BV1Kb421J7yg?t=0.1"
	  echo -e "${rw_cheng}------------------------------------------------${rw_lv}"
	  echo "提供多种系统参数调优模式，用户可以根据自身使用场景进行选择切换。"
	  echo -e "${rw_huang}提示: ${rw_lv}生产环境请谨慎使用！"
	  echo -e "--------------------"
	  echo -e "1. 高性能优化模式：     最大化系统性能，激进的内存和网络参数。"
	  echo -e "2. 均衡优化模式：       在性能与资源消耗之间取得平衡，适合日常使用。"
	  echo -e "3. 网站优化模式：       针对网站服务器优化，超高并发连接队列。"
	  echo -e "4. 直播优化模式：       针对直播推流优化，UDP 缓冲区加大，减少延迟。"
	  echo -e "5. 游戏服优化模式：     针对游戏服务器优化，低延迟优先。"
	  echo -e "6. 还原默认设置：       将系统设置还原为默认配置。"
	  echo -e "7. 自动调优：           根据测试数据自动调优内核参数。${rw_huang}★${rw_lv}"
	  echo -e "${rw_cheng}--------------------${rw_lv}"
	  echo "0. 返回上一级选单"
	  echo -e "${rw_cheng}--------------------${rw_lv}"
	  read -e -p "请输入你的选择: " sub_choice
	  case $sub_choice in
		  1)
			  cd ~
			  clear
			  local tiaoyou_moshi="高性能优化模式"
			  optimize_high_performance
			  send_stats "高性能模式优化"
			  ;;
		  2)
			  cd ~
			  clear
			  optimize_balanced
			  send_stats "均衡模式优化"
			  ;;
		  3)
			  cd ~
			  clear
			  optimize_web_server
			  send_stats "网站优化模式"
			  ;;
		  4)
			  cd ~
			  clear
			  _kernel_optimize_core "直播优化模式" "stream"
			  send_stats "直播推流优化"
			  ;;
		  5)
			  cd ~
			  clear
			  _kernel_optimize_core "游戏服优化模式" "game"
			  send_stats "游戏服优化"
			  ;;
		  6)
			  cd ~
			  clear
			  restore_defaults
			  curl -sS ${gh_proxy}raw.githubusercontent.com/riwi/sh/refs/heads/main/network-optimize.sh -o /tmp/network-optimize.sh && source /tmp/network-optimize.sh && restore_network_defaults
			  send_stats "还原默认设置"
			  ;;

		  7)
			  cd ~
			  clear
			  curl -sS ${gh_proxy}raw.githubusercontent.com/riwi/sh/refs/heads/main/network-optimize.sh | bash
			  send_stats "内核自动调优"
			  ;;

		  *)
			  break
			  ;;
	  esac
	  break_end
	done
}







update_locale() {
	local lang=$1
	local locale_file=$2

	if [ -f /etc/os-release ]; then
		. /etc/os-release
		case $ID in
			debian|ubuntu|kali)
				install locales
				sed -i "s/^\s*#\?\s*${locale_file}/${locale_file}/" /etc/locale.gen
				locale-gen
				echo "LANG=${lang}" > /etc/default/locale
				export LANG=${lang}
				echo -e "${rw_lv}系统语言已经修改为: $lang 重新连接SSH生效。${rw_lv}"
				hash -r
				break_end

				;;
			centos|rhel|almalinux|rocky|fedora)
				install glibc-langpack-zh
				localectl set-locale LANG=${lang}
				echo "LANG=${lang}" | tee /etc/locale.conf
				echo -e "${rw_lv}系统语言已经修改为: $lang 重新连接SSH生效。${rw_lv}"
				hash -r
				break_end
				;;
			*)
				echo "不支持的系统: $ID"
				break_end
				;;
		esac
	else
		echo "不支持的系统，无法识别系统类型。"
		break_end
	fi
}




linux_language() {
root_use
send_stats "切换系统语言"
while true; do
  clear
  echo "当前系统语言: $LANG"
  echo -e "${rw_cheng}------------------------${rw_lv}"
  echo "1. 英文          2. 简体中文          3. 繁体中文"
  echo -e "${rw_cheng}------------------------${rw_lv}"
  echo "0. 返回上一级选单"
  echo -e "${rw_cheng}------------------------${rw_lv}"
  read -e -p "输入你的选择: " choice

  case $choice in
	  1)
		  update_locale "en_US.UTF-8" "en_US.UTF-8"
		  send_stats "切换到英文"
		  ;;
	  2)
		  update_locale "zh_CN.UTF-8" "zh_CN.UTF-8"
		  send_stats "切换到简体中文"
		  ;;
	  3)
		  update_locale "zh_TW.UTF-8" "zh_TW.UTF-8"
		  send_stats "切换到繁体中文"
		  ;;
	  *)
		  break
		  ;;
  esac
done
}



shell_bianse_profile() {

if command -v dnf &>/dev/null || command -v yum &>/dev/null; then
	sed -i '/^PS1=/d' ~/.bashrc
	echo "${bianse}" >> ~/.bashrc
	# source ~/.bashrc
else
	sed -i '/^PS1=/d' ~/.profile
	echo "${bianse}" >> ~/.profile
	# source ~/.profile
fi
echo -e "${rw_lv}变更完成。重新连接SSH后可查看变化！${rw_lv}"

hash -r
break_end

}



shell_bianse() {
  root_use
  send_stats "命令行美化工具"
  while true; do
	clear
	echo "命令行美化工具"
	echo -e "${rw_cheng}------------------------${rw_lv}"
	echo -e "1. \033[1;32mroot \033[1;34mlocalhost \033[1;31m~ \033[0m${rw_lv}#"
	echo -e "2. \033[1;35mroot \033[1;36mlocalhost \033[1;33m~ \033[0m${rw_lv}#"
	echo -e "3. \033[1;31mroot \033[1;32mlocalhost \033[1;34m~ \033[0m${rw_lv}#"
	echo -e "4. \033[1;36mroot \033[1;33mlocalhost \033[1;37m~ \033[0m${rw_lv}#"
	echo -e "5. \033[1;37mroot \033[1;31mlocalhost \033[1;32m~ \033[0m${rw_lv}#"
	echo -e "6. \033[1;33mroot \033[1;34mlocalhost \033[1;35m~ \033[0m${rw_lv}#"
	echo -e "7. root localhost ~ #"
	echo -e "${rw_cheng}------------------------${rw_lv}"
	echo "0. 返回上一级选单"
	echo -e "${rw_cheng}------------------------${rw_lv}"
	read -e -p "输入你的选择: " choice

	case $choice in
	  1)
		local bianse="PS1='\[\033[1;32m\]\u\[\033[0m\]@\[\033[1;34m\]\h\[\033[0m\] \[\033[1;31m\]\w\[\033[0m\] # '"
		shell_bianse_profile

		;;
	  2)
		local bianse="PS1='\[\033[1;35m\]\u\[\033[0m\]@\[\033[1;36m\]\h\[\033[0m\] \[\033[1;33m\]\w\[\033[0m\] # '"
		shell_bianse_profile
		;;
	  3)
		local bianse="PS1='\[\033[1;31m\]\u\[\033[0m\]@\[\033[1;32m\]\h\[\033[0m\] \[\033[1;34m\]\w\[\033[0m\] # '"
		shell_bianse_profile
		;;
	  4)
		local bianse="PS1='\[\033[1;36m\]\u\[\033[0m\]@\[\033[1;33m\]\h\[\033[0m\] \[\033[1;37m\]\w\[\033[0m\] # '"
		shell_bianse_profile
		;;
	  5)
		local bianse="PS1='\[\033[1;37m\]\u\[\033[0m\]@\[\033[1;31m\]\h\[\033[0m\] \[\033[1;32m\]\w\[\033[0m\] # '"
		shell_bianse_profile
		;;
	  6)
		local bianse="PS1='\[\033[1;33m\]\u\[\033[0m\]@\[\033[1;34m\]\h\[\033[0m\] \[\033[1;35m\]\w\[\033[0m\] # '"
		shell_bianse_profile
		;;
	  7)
		local bianse=""
		shell_bianse_profile
		;;
	  *)
		break
		;;
	esac

  done
}




linux_trash() {
  root_use
  send_stats "系统回收站"

  local bashrc_profile="/root/.bashrc"
  local TRASH_DIR="$HOME/.local/share/Trash/files"

  while true; do

	local trash_status
	if ! grep -q "trash-put" "$bashrc_profile"; then
		trash_status="${rw_lv}未启用${rw_lv}"
	else
		trash_status="${rw_lv}已启用${rw_lv}"
	fi

	clear
	echo -e "当前回收站 ${trash_status}"
	echo -e "启用后rm删除的文件先进入回收站，防止误删重要文件！"
	echo -e "${rw_cheng}------------------------------------------------${rw_lv}"
	ls -l --color=auto "$TRASH_DIR" 2>/dev/null || echo "回收站为空"
	echo -e "${rw_cheng}------------------------${rw_lv}"
	echo "1. 启用回收站          2. 关闭回收站"
	echo "3. 还原内容            4. 清空回收站"
	echo -e "${rw_cheng}------------------------${rw_lv}"
	echo "0. 返回上一级选单"
	echo -e "${rw_cheng}------------------------${rw_lv}"
	read -e -p "输入你的选择: " choice

	case $choice in
	  1)
		install trash-cli
		sed -i '/alias rm/d' "$bashrc_profile"
		echo "alias rm='trash-put'" >> "$bashrc_profile"
		source "$bashrc_profile"
		echo "回收站已启用，删除的文件将移至回收站。"
		sleep 2
		;;
	  2)
		remove trash-cli
		sed -i '/alias rm/d' "$bashrc_profile"
		echo "alias rm='rm -i'" >> "$bashrc_profile"
		source "$bashrc_profile"
		echo "回收站已关闭，文件将直接删除。"
		sleep 2
		;;
	  3)
		read -e -p "输入要还原的文件名: " file_to_restore
		if [ -e "$TRASH_DIR/$file_to_restore" ]; then
		  mv "$TRASH_DIR/$file_to_restore" "$HOME/"
		  echo "$file_to_restore 已还原到主目录。"
		else
		  echo "文件不存在。"
		fi
		;;
	  4)
		read -e -p "确认清空回收站？[y/n]: " confirm
		if [[ "$confirm" == "y" ]]; then
		  trash-empty
		  echo "回收站已清空。"
		fi
		;;
	  *)
		break
		;;
	esac
  done
}

linux_fav() {
send_stats "命令收藏夹"
bash <(curl -l -s ${gh_proxy}raw.githubusercontent.com/byJoey/cmdbox/refs/heads/main/install.sh)
}

# 创建备份
create_backup() {
	send_stats "创建备份"
	local TIMESTAMP=$(date +"%Y%m%d%H%M%S")

	# 提示用户输入备份目录
	echo "创建备份示例："
	echo "  - 备份单个目录: /var/www"
	echo "  - 备份多个目录: /etc /home /var/log"
	echo "  - 直接回车将使用默认目录 (/etc /usr /home)"
	read -e -p "请输入要备份的目录（多个目录用空格分隔，直接回车则使用默认目录）：" input

	# 如果用户没有输入目录，则使用默认目录
	if [ -z "$input" ]; then
		BACKUP_PATHS=(
			"/etc"              # 配置文件和软件包配置
			"/usr"              # 已安装的软件文件
			"/home"             # 用户数据
		)
	else
		# 将用户输入的目录按空格分隔成数组
		IFS=' ' read -r -a BACKUP_PATHS <<< "$input"
	fi

	# 生成备份文件前缀
	local PREFIX=""
	for path in "${BACKUP_PATHS[@]}"; do
		# 提取目录名称并去除斜杠
		dir_name=$(basename "$path")
		PREFIX+="${dir_name}_"
	done

	# 去除最后一个下划线
	local PREFIX=${PREFIX%_}

	# 生成备份文件名
	local BACKUP_NAME="${PREFIX}_$TIMESTAMP.tar.gz"

	# 打印用户选择的目录
	echo "您选择的备份目录为："
	for path in "${BACKUP_PATHS[@]}"; do
		echo "- $path"
	done

	# 创建备份
	echo "正在创建备份 $BACKUP_NAME..."
	install tar
	tar -czvf "$BACKUP_DIR/$BACKUP_NAME" "${BACKUP_PATHS[@]}"

	# 检查命令是否成功
	if [ $? -eq 0 ]; then
		echo "备份创建成功: $BACKUP_DIR/$BACKUP_NAME"
	else
		echo "备份创建失败！"
		exit 1
	fi
}

# 恢复备份
restore_backup() {
	send_stats "恢复备份"
	# 选择要恢复的备份
	read -e -p "请输入要恢复的备份文件名: " BACKUP_NAME

	# 检查备份文件是否存在
	if [ ! -f "$BACKUP_DIR/$BACKUP_NAME" ]; then
		echo "备份文件不存在！"
		exit 1
	fi

	echo "正在恢复备份 $BACKUP_NAME..."
	tar -xzvf "$BACKUP_DIR/$BACKUP_NAME" -C /

	if [ $? -eq 0 ]; then
		echo "备份恢复成功！"
	else
		echo "备份恢复失败！"
		exit 1
	fi
}

# 列出备份
list_backups() {
	echo "可用的备份："
	ls -1 "$BACKUP_DIR"
}

# 删除备份
delete_backup() {
	send_stats "删除备份"

	read -e -p "请输入要删除的备份文件名: " BACKUP_NAME

	# 检查备份文件是否存在
	if [ ! -f "$BACKUP_DIR/$BACKUP_NAME" ]; then
		echo "备份文件不存在！"
		exit 1
	fi

	# 删除备份
	rm -f "$BACKUP_DIR/$BACKUP_NAME"

	if [ $? -eq 0 ]; then
		echo "备份删除成功！"
	else
		echo "备份删除失败！"
		exit 1
	fi
}

# 备份主菜单
linux_backup() {
	BACKUP_DIR="/backups"
	mkdir -p "$BACKUP_DIR"
	while true; do
		clear
		send_stats "系统备份功能"
		echo "系统备份功能"
		echo -e "${rw_cheng}------------------------${rw_lv}"
		list_backups
		echo -e "${rw_cheng}------------------------${rw_lv}"
		echo "1. 创建备份        2. 恢复备份        3. 删除备份"
		echo -e "${rw_cheng}------------------------${rw_lv}"
		echo "0. 返回上一级选单"
		echo -e "${rw_cheng}------------------------${rw_lv}"
		read -e -p "请输入你的选择: " choice
		case $choice in
			1) create_backup ;;
			2) restore_backup ;;
			3) delete_backup ;;
			*) break ;;
		esac
		read -e -p "按回车键继续..."
	done
}









# SSH 输入标准化函数
kj_ssh_validate_host() {
	local host="$1"
	[[ -n "$host" && ! "$host" =~ [[:space:]] && "$host" =~ ^[A-Za-z0-9._:-]+$ ]]
}

kj_ssh_validate_port() {
	local port="$1"
	[[ "$port" =~ ^[0-9]+$ ]] && [ "$port" -ge 1 ] && [ "$port" -le 65535 ]
}

kj_ssh_validate_user() {
	local user="$1"
	[[ -n "$user" && "$user" =~ ^[A-Za-z_][A-Za-z0-9._-]*$ ]]
}

kj_ssh_read_host_port() {
	local host_prompt="$1"
	local port_prompt="$2"
	local default_port="${3:-22}"

	while true; do
		read -e -p "$host_prompt" KJ_SSH_HOST
		if kj_ssh_validate_host "$KJ_SSH_HOST"; then
			break
		fi
		echo "错误: 请输入有效的服务器地址。"
	done

	while true; do
		read -e -p "$port_prompt" KJ_SSH_PORT
		KJ_SSH_PORT=${KJ_SSH_PORT:-$default_port}
		if kj_ssh_validate_port "$KJ_SSH_PORT"; then
			break
		fi
		echo "错误: 端口必须是 1-65535 之间的数字。"
	done
}

kj_ssh_read_host_user_port() {
	local host_prompt="$1"
	local user_prompt="$2"
	local port_prompt="$3"
	local default_user="${4:-root}"
	local default_port="${5:-22}"

	kj_ssh_read_host_port "$host_prompt" "$port_prompt" "$default_port"

	while true; do
		read -e -p "$user_prompt" KJ_SSH_USER
		KJ_SSH_USER=${KJ_SSH_USER:-$default_user}
		if kj_ssh_validate_user "$KJ_SSH_USER"; then
			break
		fi
		echo "错误: 用户名格式不正确。"
	done
}

kj_ssh_parse_remote() {
	local remote_raw="$1"
	local default_user="${2:-root}"
	local remote_user remote_host

	if [[ "$remote_raw" == *@* ]]; then
		remote_user="${remote_raw%@*}"
		remote_host="${remote_raw#*@}"
	else
		remote_user="$default_user"
		remote_host="$remote_raw"
	fi

	if ! kj_ssh_validate_user "$remote_user"; then
		echo "错误: SSH 用户名格式不正确。"
		return 1
	fi

	if ! kj_ssh_validate_host "$remote_host"; then
		echo "错误: SSH 主机地址格式不正确。"
		return 1
	fi

	KJ_SSH_USER="$remote_user"
	KJ_SSH_HOST="$remote_host"
	KJ_SSH_REMOTE="$remote_user@$remote_host"
}

kj_ssh_read_auth() {
	local key_file="$1"
	local password_or_key=""

	echo "请选择身份验证方式:"
	echo "1. 密码"
	echo "2. 密钥"
	read -e -p "请输入选择 (1/2): " auth_choice

	case $auth_choice in
		1)
			read -s -p "请输入密码: " password_or_key
			echo
			if [ -z "$password_or_key" ]; then
				echo "错误: 密码不能为空。"
				return 1
			fi
			KJ_SSH_AUTH_METHOD="password"
			KJ_SSH_AUTH_SECRET="$password_or_key"
			;;
		2)
			echo "请粘贴密钥内容 (粘贴完成后按两次回车)："
			while IFS= read -r line; do
				if [[ -z "$line" && "$password_or_key" == *"-----BEGIN"* ]]; then
					break
				fi
				if [[ -n "$line" || "$password_or_key" == *"-----BEGIN"* ]]; then
					password_or_key+="${line}"$'\n'
				fi
			done

			if [[ "$password_or_key" != *"-----BEGIN"* || "$password_or_key" != *"PRIVATE KEY-----"* ]]; then
				echo "无效的密钥内容！"
				return 1
			fi

			mkdir -p "$(dirname "$key_file")"
			echo -n "$password_or_key" > "$key_file"
			chmod 600 "$key_file"
			KJ_SSH_AUTH_METHOD="key"
			KJ_SSH_AUTH_SECRET="$key_file"
			;;
		*)
			echo "无效的选择！"
			return 1
			;;
	esac
}

kj_ssh_read_password() {
	local prompt="${1:-请输入密码: }"
	while true; do
		read -e -s -p "$prompt" KJ_SSH_PASSWORD
		echo
		[ -n "$KJ_SSH_PASSWORD" ] && break
		echo "错误: 密码不能为空。"
	done
}

kj_ssh_read_port() {
	local port_prompt="$1"
	local default_port="${2:-22}"
	while true; do
		read -e -p "$port_prompt" KJ_SSH_PORT
		KJ_SSH_PORT=${KJ_SSH_PORT:-$default_port}
		if kj_ssh_validate_port "$KJ_SSH_PORT"; then
			return 0
		fi
		echo "错误: 端口必须是 1-65535 之间的数字。"
	done
}

# 显示连接列表
list_connections() {
	echo "已保存的连接:"
	echo -e "${rw_cheng}------------------------${rw_lv}"
	cat "$CONFIG_FILE" | awk -F'|' '{print NR " - " $1 " (" $2 ")"}'
	echo -e "${rw_cheng}------------------------${rw_lv}"
}


# 添加新连接
add_connection() {
	send_stats "添加新连接"
	echo "创建新连接示例："
	echo "  - 连接名称: my_server"
	echo "  - IP地址: 192.168.1.100"
	echo "  - 用户名: root"
	echo "  - 端口: 22"
	echo -e "${rw_cheng}------------------------${rw_lv}"
	read -e -p "请输入连接名称: " name

	kj_ssh_read_host_user_port "请输入IP地址: " "请输入用户名 (默认: root): " "请输入端口号 (默认: 22): " "root" "22"
	if ! kj_ssh_read_auth "$KEY_DIR/$name.key"; then
		return
	fi

	echo "$name|$KJ_SSH_HOST|$KJ_SSH_USER|$KJ_SSH_PORT|$KJ_SSH_AUTH_SECRET" >> "$CONFIG_FILE"
	echo "连接已保存!"
}



# 删除连接
delete_connection() {
	send_stats "删除连接"
	read -e -p "请输入要删除的连接编号: " num

	local connection=$(sed -n "${num}p" "$CONFIG_FILE")
	if [[ -z "$connection" ]]; then
		echo "错误：未找到对应的连接。"
		return
	fi

	IFS='|' read -r name ip user port password_or_key <<< "$connection"

	# 如果连接使用的是密钥文件，则删除该密钥文件
	if [[ "$password_or_key" == "$KEY_DIR"* ]]; then
		rm -f "$password_or_key"
	fi

	sed -i "${num}d" "$CONFIG_FILE"
	echo "连接已删除!"
}

# 使用连接
use_connection() {
	send_stats "使用连接"
	read -e -p "请输入要使用的连接编号: " num

	local connection=$(sed -n "${num}p" "$CONFIG_FILE")
	if [[ -z "$connection" ]]; then
		echo "错误：未找到对应的连接。"
		return
	fi

	IFS='|' read -r name ip user port password_or_key <<< "$connection"

	echo "正在连接到 $name ($ip)..."
	if [[ -f "$password_or_key" ]]; then
		# 使用密钥连接
		ssh -o StrictHostKeyChecking=no -i "$password_or_key" -p "$port" "$user@$ip"
		if [[ $? -ne 0 ]]; then
			echo "连接失败！请检查以下内容："
			echo "1. 密钥文件路径是否正确：$password_or_key"
			echo "2. 密钥文件权限是否正确（应为 600）。"
			echo "3. 目标服务器是否允许使用密钥登录。"
		fi
	else
		# 使用密码连接
		if ! command -v sshpass &> /dev/null; then
			echo "错误：未安装 sshpass，请先安装 sshpass。"
			echo "安装方法："
			echo "  - Ubuntu/Debian: apt install sshpass"
			echo "  - CentOS/RHEL: yum install sshpass"
			return
		fi
		sshpass -p "$password_or_key" ssh -o StrictHostKeyChecking=no -p "$port" "$user@$ip"
		if [[ $? -ne 0 ]]; then
			echo "连接失败！请检查以下内容："
			echo "1. 用户名和密码是否正确。"
			echo "2. 目标服务器是否允许密码登录。"
			echo "3. 目标服务器的 SSH 服务是否正常运行。"
		fi
	fi
}


ssh_manager() {
	send_stats "ssh远程连接工具"

	CONFIG_FILE="$HOME/.ssh_connections"
	KEY_DIR="$HOME/.ssh/ssh_manager_keys"

	# 检查配置文件和密钥目录是否存在，如果不存在则创建
	if [[ ! -f "$CONFIG_FILE" ]]; then
		touch "$CONFIG_FILE"
	fi

	if [[ ! -d "$KEY_DIR" ]]; then
		mkdir -p "$KEY_DIR"
		chmod 700 "$KEY_DIR"
	fi

	while true; do
		clear
		echo "SSH 远程连接工具"
		echo "可以通过SSH连接到其他Linux系统上"
		echo -e "${rw_cheng}------------------------${rw_lv}"
		list_connections
		echo "1. 创建新连接        2. 使用连接        3. 删除连接"
		echo -e "${rw_cheng}------------------------${rw_lv}"
		echo "0. 返回上一级选单"
		echo -e "${rw_cheng}------------------------${rw_lv}"
		read -e -p "请输入你的选择: " choice
		case $choice in
			1) add_connection ;;
			2) use_connection ;;
			3) delete_connection ;;
			0) break ;;
			*) echo "无效的选择，请重试。" ;;
		esac
	done
}












# 列出可用的硬盘分区
list_partitions() {
	echo "可用的硬盘分区："
	lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT | grep -v "sr\|loop"
}


# 持久化挂载分区
mount_partition() {
	send_stats "挂载分区"
	read -e -p "请输入要挂载的分区名称（例如 sda1）: " PARTITION

	DEVICE="/dev/$PARTITION"
	MOUNT_POINT="/mnt/$PARTITION"

	# 检查分区是否存在
	if ! lsblk -no NAME | grep -qw "$PARTITION"; then
		echo "分区不存在！"
		return 1
	fi

	# 检查是否已挂载
	if mount | grep -qw "$DEVICE"; then
		echo "分区已经挂载！"
		return 1
	fi

	# 获取 UUID
	UUID=$(blkid -s UUID -o value "$DEVICE")
	if [ -z "$UUID" ]; then
		echo "无法获取 UUID！"
		return 1
	fi

	# 获取文件系统类型
	FSTYPE=$(blkid -s TYPE -o value "$DEVICE")
	if [ -z "$FSTYPE" ]; then
		echo "无法获取文件系统类型！"
		return 1
	fi

	# 创建挂载点
	mkdir -p "$MOUNT_POINT"

	# 挂载
	if ! mount "$DEVICE" "$MOUNT_POINT"; then
		echo "分区挂载失败！"
		rmdir "$MOUNT_POINT"
		return 1
	fi

	echo "分区已成功挂载到 $MOUNT_POINT"

	# 检查 /etc/fstab 是否已经存在 UUID 或挂载点
	if grep -qE "UUID=$UUID|[[:space:]]$MOUNT_POINT[[:space:]]" /etc/fstab; then
		echo "/etc/fstab 中已存在该分区记录，跳过写入"
		return 0
	fi

	# 写入 /etc/fstab
	echo "UUID=$UUID $MOUNT_POINT $FSTYPE defaults,nofail 0 2" >> /etc/fstab

	echo "已写入 /etc/fstab，实现持久化挂载"
}


# 卸载分区
unmount_partition() {
	send_stats "卸载分区"
	read -e -p "请输入要卸载的分区名称（例如 sda1）: " PARTITION

	# 检查分区是否已经挂载
	MOUNT_POINT=$(lsblk -o MOUNTPOINT | grep -w "$PARTITION")
	if [ -z "$MOUNT_POINT" ]; then
		echo "分区未挂载！"
		return
	fi

	# 卸载分区
	umount "/dev/$PARTITION"

	if [ $? -eq 0 ]; then
		echo "分区卸载成功: $MOUNT_POINT"
		rmdir "$MOUNT_POINT"
	else
		echo "分区卸载失败！"
	fi
}

# 列出已挂载的分区
list_mounted_partitions() {
	echo "已挂载的分区："
	df -h | grep -v "tmpfs\|udev\|overlay"
}

# 格式化分区
format_partition() {
	send_stats "格式化分区"
	read -e -p "请输入要格式化的分区名称（例如 sda1）: " PARTITION

	# 检查分区是否存在
	if ! lsblk -o NAME | grep -w "$PARTITION" > /dev/null; then
		echo "分区不存在！"
		return
	fi

	# 检查分区是否已经挂载
	if lsblk -o MOUNTPOINT | grep -w "$PARTITION" > /dev/null; then
		echo "分区已经挂载，请先卸载！"
		return
	fi

	# 选择文件系统类型
	echo "请选择文件系统类型："
	echo "1. ext4"
	echo "2. xfs"
	echo "3. ntfs"
	echo "4. vfat"
	read -e -p "请输入你的选择: " FS_CHOICE

	case $FS_CHOICE in
		1) FS_TYPE="ext4" ;;
		2) FS_TYPE="xfs" ;;
		3) FS_TYPE="ntfs" ;;
		4) FS_TYPE="vfat" ;;
		*) echo "无效的选择！"; return ;;
	esac

	# 确认格式化
	read -e -p "确认格式化分区 /dev/$PARTITION 为 $FS_TYPE 吗？(y/n): " CONFIRM
	if [ "$CONFIRM" != "y" ]; then
		echo "操作已取消。"
		return
	fi

	# 格式化分区
	echo "正在格式化分区 /dev/$PARTITION 为 $FS_TYPE ..."
	mkfs.$FS_TYPE "/dev/$PARTITION"

	if [ $? -eq 0 ]; then
		echo "分区格式化成功！"
	else
		echo "分区格式化失败！"
	fi
}

# 检查分区状态
check_partition() {
	send_stats "检查分区状态"
	read -e -p "请输入要检查的分区名称（例如 sda1）: " PARTITION

	# 检查分区是否存在
	if ! lsblk -o NAME | grep -w "$PARTITION" > /dev/null; then
		echo "分区不存在！"
		return
	fi

	# 检查分区状态
	echo "检查分区 /dev/$PARTITION 的状态："
	fsck "/dev/$PARTITION"
}

# 主菜单
disk_manager() {
	send_stats "硬盘管理功能"
	while true; do
		clear
		echo "硬盘分区管理"
		echo -e "${rw_huang}该功能内部测试阶段，请勿在生产环境使用。${rw_lv}"
		echo -e "${rw_cheng}------------------------${rw_lv}"
		list_partitions
		echo -e "${rw_cheng}------------------------${rw_lv}"
		echo "1. 挂载分区        2. 卸载分区        3. 查看已挂载分区"
		echo "4. 格式化分区      5. 检查分区状态"
		echo -e "${rw_cheng}------------------------${rw_lv}"
		echo "0. 返回上一级选单"
		echo -e "${rw_cheng}------------------------${rw_lv}"
		read -e -p "请输入你的选择: " choice
		case $choice in
			1) mount_partition ;;
			2) unmount_partition ;;
			3) list_mounted_partitions ;;
			4) format_partition ;;
			5) check_partition ;;
			*) break ;;
		esac
		read -e -p "按回车键继续..."
	done
}




# 显示任务列表
list_tasks() {
	echo "已保存的同步任务:"
	echo -e "${rw_cheng}---------------------------------${rw_lv}"
	awk -F'|' '{print NR " - " $1 " ( " $2 " -> " $3":"$4 " )"}' "$CONFIG_FILE"
	echo -e "${rw_cheng}---------------------------------${rw_lv}"
}

# 添加新任务
add_task() {
	send_stats "添加新同步任务"
	echo "创建新同步任务示例："
	echo "  - 任务名称: backup_www"
	echo "  - 本地目录: /var/www"
	echo "  - 远程地址: user@192.168.1.100"
	echo "  - 远程目录: /backup/www"
	echo "  - 端口号 (默认 22)"
	echo -e "${rw_cheng}---------------------------------${rw_lv}"
	read -e -p "请输入任务名称: " name
	read -e -p "请输入本地目录: " local_path
	read -e -p "请输入远程目录: " remote_path

	while true; do
		read -e -p "请输入远程用户@IP: " remote
		if kj_ssh_parse_remote "$remote" "root"; then
			remote="$KJ_SSH_REMOTE"
			break
		fi
	done

	kj_ssh_read_port "请输入 SSH 端口 (默认 22): " "22"
	port="$KJ_SSH_PORT"

	if ! kj_ssh_read_auth "$KEY_DIR/${name}_sync.key"; then
		return
	fi
	auth_method="$KJ_SSH_AUTH_METHOD"
	password_or_key="$KJ_SSH_AUTH_SECRET"

	echo "请选择同步模式:"
	echo "1. 标准模式 (-avz)"
	echo "2. 删除目标文件 (-avz --delete)"
	read -e -p "请选择 (1/2): " mode
	case $mode in
		1) options="-avz" ;;
		2) options="-avz --delete" ;;
		*) echo "无效选择，使用默认 -avz"; options="-avz" ;;
	esac

	echo "$name|$local_path|$remote|$remote_path|$port|$options|$auth_method|$password_or_key" >> "$CONFIG_FILE"

	install rsync rsync

	echo "任务已保存!"
}


# 删除任务
delete_task() {
	send_stats "删除同步任务"
	read -e -p "请输入要删除的任务编号: " num

	local task=$(sed -n "${num}p" "$CONFIG_FILE")
	if [[ -z "$task" ]]; then
		echo "错误：未找到对应的任务。"
		return
	fi

	IFS='|' read -r name local_path remote remote_path port options auth_method password_or_key <<< "$task"

	# 如果任务使用的是密钥文件，则删除该密钥文件
	if [[ "$auth_method" == "key" && "$password_or_key" == "$KEY_DIR"* ]]; then
		rm -f "$password_or_key"
	fi

	sed -i "${num}d" "$CONFIG_FILE"
	echo "任务已删除!"
}


run_task() {
	send_stats "执行同步任务"

	CONFIG_FILE="$HOME/.rsync_tasks"
	CRON_FILE="$HOME/.rsync_cron"

	# 解析参数
	local direction="push"  # 默认是推送到远端
	local num

	if [[ "$1" == "push" || "$1" == "pull" ]]; then
		direction="$1"
		num="$2"
	else
		num="$1"
	fi

	# 如果没有传入任务编号，提示用户输入
	if [[ -z "$num" ]]; then
		read -e -p "请输入要执行的任务编号: " num
	fi

	local task=$(sed -n "${num}p" "$CONFIG_FILE")
	if [[ -z "$task" ]]; then
		echo "错误: 未找到该任务!"
		return
	fi

	IFS='|' read -r name local_path remote remote_path port options auth_method password_or_key <<< "$task"

	# 根据同步方向调整源和目标路径
	if [[ "$direction" == "pull" ]]; then
		echo "正在拉取同步到本地: $remote:$local_path -> $remote_path"
		source="$remote:$local_path"
		destination="$remote_path"
	else
		echo "正在推送同步到远端: $local_path -> $remote:$remote_path"
		source="$local_path"
		destination="$remote:$remote_path"
	fi

	# 添加 SSH 连接通用参数
	local ssh_options="-p $port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

	if [[ "$auth_method" == "password" ]]; then
		if ! command -v sshpass &> /dev/null; then
			echo "错误：未安装 sshpass，请先安装 sshpass。"
			echo "安装方法："
			echo "  - Ubuntu/Debian: apt install sshpass"
			echo "  - CentOS/RHEL: yum install sshpass"
			return
		fi
		sshpass -p "$password_or_key" rsync $options -e "ssh $ssh_options" "$source" "$destination"
	else
		# 检查密钥文件是否存在和权限是否正确
		if [[ ! -f "$password_or_key" ]]; then
			echo "错误：密钥文件不存在：$password_or_key"
			return
		fi

		if [[ "$(stat -c %a "$password_or_key")" != "600" ]]; then
			echo "警告：密钥文件权限不正确，正在修复..."
			chmod 600 "$password_or_key"
		fi

		rsync $options -e "ssh -i $password_or_key $ssh_options" "$source" "$destination"
	fi

	if [[ $? -eq 0 ]]; then
		echo "同步完成!"
	else
		echo "同步失败! 请检查以下内容："
		echo "1. 网络连接是否正常"
		echo "2. 远程主机是否可访问"
		echo "3. 认证信息是否正确"
		echo "4. 本地和远程目录是否有正确的访问权限"
	fi
}


# 创建定时任务
schedule_task() {
	send_stats "添加同步定时任务"

	read -e -p "请输入要定时同步的任务编号: " num
	if ! [[ "$num" =~ ^[0-9]+$ ]]; then
		echo "错误: 请输入有效的任务编号！"
		return
	fi

	echo "请选择定时执行间隔："
	echo "1) 每小时执行一次"
	echo "2) 每天执行一次"
	echo "3) 每周执行一次"
	read -e -p "请输入选项 (1/2/3): " interval

	local random_minute=$(shuf -i 0-59 -n 1)  # 生成 0-59 之间的随机分钟数
	local cron_time=""
	case "$interval" in
		1) cron_time="$random_minute * * * *" ;;  # 每小时，随机分钟执行
		2) cron_time="$random_minute 0 * * *" ;;  # 每天，随机分钟执行
		3) cron_time="$random_minute 0 * * 1" ;;  # 每周，随机分钟执行
		*) echo "错误: 请输入有效的选项！" ; return ;;
	esac

	local cron_job="$cron_time r rsync_run $num"
	local cron_job="$cron_time r rsync_run $num"

	# 检查是否已存在相同任务
	if crontab -l | grep -q "r rsync_run $num"; then
		echo "错误: 该任务的定时同步已存在！"
		return
	fi

	# 创建到用户的 crontab
	(crontab -l 2>/dev/null; echo "$cron_job") | crontab -
	echo "定时任务已创建: $cron_job"
}

# 查看定时任务
view_tasks() {
	echo "当前的定时任务:"
	echo -e "${rw_cheng}---------------------------------${rw_lv}"
	crontab -l | grep "k rsync_run"
	echo -e "${rw_cheng}---------------------------------${rw_lv}"
}

# 删除定时任务
delete_task_schedule() {
	send_stats "删除同步定时任务"
	read -e -p "请输入要删除的任务编号: " num
	if ! [[ "$num" =~ ^[0-9]+$ ]]; then
		echo "错误: 请输入有效的任务编号！"
		return
	fi

	crontab -l | grep -v "k rsync_run $num" | crontab -
	echo "已删除任务编号 $num 的定时任务"
}


# 任务管理主菜单
rsync_manager() {
	CONFIG_FILE="$HOME/.rsync_tasks"
	CRON_FILE="$HOME/.rsync_cron"

	while true; do
		clear
		echo "Rsync 远程同步工具"
		echo "远程目录之间同步，支持增量同步，高效稳定。"
		echo -e "${rw_cheng}---------------------------------${rw_lv}"
		list_tasks
		echo
		view_tasks
		echo
		echo "1. 创建新任务                 2. 删除任务"
		echo "3. 执行本地同步到远端         4. 执行远端同步到本地"
		echo "5. 创建定时任务               6. 删除定时任务"
		echo -e "${rw_cheng}---------------------------------${rw_lv}"
		echo "0. 返回上一级选单"
		echo -e "${rw_cheng}---------------------------------${rw_lv}"
		read -e -p "请输入你的选择: " choice
		case $choice in
			1) add_task ;;
			2) delete_task ;;
			3) run_task push;;
			4) run_task pull;;
			5) schedule_task ;;
			6) delete_task_schedule ;;
			0) break ;;
			*) echo "无效的选择，请重试。" ;;
		esac
		read -e -p "按回车键继续..."
	done
}









# ================================================================
# 常用快捷工具菜单 (原 riwi_Affiliates 占位，2026-06-26 重写)
# ================================================================
linux_quick_tools() {
while true; do
	clear
	send_stats "常用快捷工具"

	# ── 顶部状态速览 ──
	local _mem_total=$(free -m 2>/dev/null | awk 'NR==2{printf "%.0f", $2}')
	local _mem_used=$(free -m 2>/dev/null | awk 'NR==2{printf "%.0f", $3}')
	local _disk_root=$(df -h / 2>/dev/null | awk 'NR==2{print $5}')
	local _load1=$(awk '{print $1}' /proc/loadavg 2>/dev/null || echo "-")
	local _proc_count=$(ls /proc 2>/dev/null | grep -E '^[0-9]+$' | wc -l)

	echo -e "${rw_cheng}━━━━━━━━━━━━  常用快捷  ━━━━━━━━━━━━${rw_lv}"
	if [ -n "$_mem_total" ]; then
		echo -e " 内存 ${rw_lv}${_mem_used}/${_mem_total}MB${rw_lv}  根分区 ${rw_lv}${_disk_root}${rw_lv}  1分钟负载 ${rw_lv}${_load1}${rw_lv}  进程数 ${rw_lv}${_proc_count}${rw_lv}"
	fi
	echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"

	echo -e " ${rw_cheng}──── 进程与资源${rw_lv}"
	echo -e "  ${rw_huang}1${rw_lv}  CPU 占用 Top10           ${rw_huang}2${rw_lv}  内存占用 Top10"
	echo -e "  ${rw_huang}3${rw_lv}  磁盘大文件 Top20         ${rw_huang}4${rw_lv}  僵尸进程检测"
	echo ""
	echo -e " ${rw_cheng}──── 网络诊断${rw_lv}"
	echo -e "  ${rw_huang}5${rw_lv}  查看监听端口            ${rw_huang}6${rw_lv}  当前 TCP 连接数"
	echo -e "  ${rw_huang}7${rw_lv}  SSH 登录失败记录         ${rw_huang}8${rw_lv}  当前在线用户"
	echo ""
	echo -e " ${rw_cheng}──── 系统日志${rw_lv}"
	echo -e "  ${rw_huang}9${rw_lv}  查看系统日志            ${rw_huang}10${rw_lv} 最近登录记录"
	echo -e "  ${rw_huang}11${rw_lv} 系统启动时长与启动项"
	echo ""
	echo -e " ${rw_cheng}──── 快捷操作${rw_lv}"
	echo -e "  ${rw_huang}12${rw_lv} 清理内存缓存            ${rw_huang}13${rw_lv} 查看磁盘分区表"
	echo -e "  ${rw_huang}14${rw_lv} 查看 cron 定时任务"
	echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
	echo -e " ${rw_huang}0${rw_lv}  返回主菜单"
	echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
	read -e -p " 请选择: " _qt_choice < /dev/tty

	case $_qt_choice in
	  1)
		# CPU 占用 Top10
		echo -e "\n${rw_cheng}━━ CPU 占用 Top10 ━━${rw_lv}"
		ps -eo pid,user,%cpu,%mem,comm --sort=-%cpu 2>/dev/null | head -11 || \
			ps aux 2>/dev/null | sort -k3 -rn | head -10
		;;
	  2)
		# 内存占用 Top10
		echo -e "\n${rw_cheng}━━ 内存占用 Top10 ━━${rw_lv}"
		ps -eo pid,user,%cpu,%mem,comm --sort=-%mem 2>/dev/null | head -11 || \
			ps aux 2>/dev/null | sort -k4 -rn | head -10
		;;
	  3)
		# 磁盘大文件 Top20
		echo -e "\n${rw_cheng}━━ 磁盘大文件 Top20（可能耗时）━━${rw_lv}"
		read -e -p " 扫描目录（默认 /）: " _scan_dir < /dev/tty
		_scan_dir="${_scan_dir:-/}"
		if [ -d "$_scan_dir" ]; then
			find "$_scan_dir" -xdev -type f -size +50M 2>/dev/null | \
				xargs ls -lhS 2>/dev/null | head -20 | \
				awk '{print $5"\t"$NF}'
		else
			echo -e "${rw_hong}目录不存在${rw_lv}"
		fi
		;;
	  4)
		# 僵尸进程检测
		echo -e "\n${rw_cheng}━━ 僵尸进程检测 ━━${rw_lv}"
		local _zombie=$(ps -eo stat,pid,user,comm 2>/dev/null | awk '$1 ~ /^Z/{count++} END{print count+0}')
		if [ "$_zombie" -eq 0 ]; then
			echo -e "${rw_lv}✓ 无僵尸进程${rw_lv}"
		else
			echo -e "${rw_hong}发现 $_zombie 个僵尸进程${rw_lv}"
			ps -eo stat,pid,ppid,user,comm 2>/dev/null | awk '$1 ~ /^Z/'
			echo ""
			echo -e "${rw_huang}提示: kill 父进程 (PPID) 可清理僵尸${rw_lv}"
		fi
		;;
	  5)
		# 查看监听端口
		echo -e "\n${rw_cheng}━━ 监听端口 ━━${rw_lv}"
		if command -v ss &>/dev/null; then
			ss -tulnp 2>/dev/null | head -30
		else
			netstat -tulnp 2>/dev/null | head -30
		fi
		;;
	  6)
		# 当前 TCP 连接数
		echo -e "\n${rw_cheng}━━ TCP 连接统计 ━━${rw_lv}"
		if command -v ss &>/dev/null; then
			echo -e " 状态分布:"
			ss -ant 2>/dev/null | awk 'NR>1{count[$1]++} END{for (s in count) printf "  %-15s %d\n", s, count[s]}'
			echo ""
			echo -e " 连接数 Top10 远程 IP:"
			ss -ant 2>/dev/null | awk 'NR>1{split($5,a,":"); print a[1]}' | sort | uniq -c | sort -rn | head -10
		else
			netstat -ant 2>/dev/null | awk 'NR>2{count[$6]++} END{for (s in count) printf "  %-15s %d\n", s, count[s]}'
		fi
		;;
	  7)
		# SSH 登录失败记录
		echo -e "\n${rw_cheng}━━ SSH 登录失败记录 (最近20条) ━━${rw_lv}"
		if [ -f /var/log/auth.log ]; then
			grep -E "Failed password|Invalid user|authentication failure" /var/log/auth.log 2>/dev/null | tail -20
		elif command -v journalctl &>/dev/null; then
			journalctl -u sshd --no-pager -g "Failed\|Invalid\|failure" 2>/dev/null | tail -20
		elif [ -f /var/log/secure ]; then
			grep -E "Failed password|Invalid user" /var/log/secure 2>/dev/null | tail -20
		else
			echo -e "${rw_huang}无可用日志源${rw_lv}"
		fi
		;;
	  8)
		# 当前在线用户
		echo -e "\n${rw_cheng}━━ 当前在线用户 ━━${rw_lv}"
		w 2>/dev/null || who 2>/dev/null
		;;
	  9)
		# 系统日志
		echo -e "\n${rw_cheng}━━ 系统日志 (最近30条) ━━${rw_lv}"
		if command -v journalctl &>/dev/null; then
			journalctl --no-pager -n 30 2>/dev/null
		elif [ -f /var/log/syslog ]; then
			tail -30 /var/log/syslog 2>/dev/null
		elif [ -f /var/log/messages ]; then
			tail -30 /var/log/messages 2>/dev/null
		else
			echo -e "${rw_huang}无可用日志源${rw_lv}"
		fi
		;;
	  10)
		# 最近登录记录
		echo -e "\n${rw_cheng}━━ 最近登录记录 ━━${rw_lv}"
		last -n 20 2>/dev/null || echo -e "${rw_huang}last 命令不可用${rw_lv}"
		;;
	  11)
		# 系统启动时长与启动项
		echo -e "\n${rw_cheng}━━ 系统启动信息 ━━${rw_lv}"
		if [ -f /proc/uptime ]; then
			local _up_sec=$(awk '{print int($1)}' /proc/uptime)
			local _days=$((_up_sec / 86400))
			local _hours=$((_up_sec % 86400 / 3600))
			local _mins=$((_up_sec % 3600 / 60))
			echo -e " 已运行: ${rw_lv}${_days}天 ${_hours}时 ${_mins}分${rw_lv}"
		fi
		echo ""
		echo -e "${rw_cheng}── 自启服务 ──${rw_lv}"
		if command -v systemctl &>/dev/null; then
			systemctl list-unit-files --state=enabled --type=service 2>/dev/null | head -20
		else
			echo -e "${rw_huang}非 systemd 系统${rw_lv}"
		fi
		;;
	  12)
		# 清理内存缓存
		echo -e "\n${rw_cheng}━━ 清理内存缓存 ━━${rw_lv}"
		echo -e " ${rw_huang}说明: 仅清理 PageCache/dentries/inodes，不影响运行进程${rw_lv}"
		read -e -p " 确认清理？(y/N): " _sync_confirm < /dev/tty
		if [[ "$_sync_confirm" =~ ^[Yy]$ ]]; then
			sync
			echo 3 > /proc/sys/vm/drop_caches 2>/dev/null && \
				echo -e "${rw_lv}✓ 已清理${rw_lv}" || \
				echo -e "${rw_hong}清理失败（需 root 权限或非 Linux 系统）${rw_lv}"
		else
			echo -e " 已取消"
		fi
		;;
	  13)
		# 磁盘分区表
		echo -e "\n${rw_cheng}━━ 磁盘分区表 ━━${rw_lv}"
		lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT 2>/dev/null || \
			df -h 2>/dev/null
		;;
	  14)
		# cron 定时任务
		echo -e "\n${rw_cheng}━━ Cron 定时任务 ━━${rw_lv}"
		echo -e " ${rw_cheng}── 当前用户 crontab ──${rw_lv}"
		crontab -l 2>/dev/null || echo -e "  ${rw_huang}无${rw_lv}"
		if [ "$(id -u)" = "0" ]; then
			echo ""
			echo -e " ${rw_cheng}── 系统级 /etc/cron* ──${rw_lv}"
			ls -la /etc/cron.d/ /etc/cron.daily/ /etc/cron.hourly/ /etc/cron.weekly/ 2>/dev/null | head -20
		fi
		;;
	  0) return ;;
	  *) echo -e "${rw_hong}无效选择${rw_lv}" ;;
	esac
	break_end
done
}

linux_info() {


	clear
	echo -e "${rw_huang}系统查询${rw_lv}"
	echo -e "${rw_cheng}------------------------${rw_lv}"
	echo ""
	echo -e "${rw_huang}功能说明:${rw_lv}"
	echo -e "${rw_huang}  查询系统的基本信息，包括:${rw_lv}"
	echo -e "${rw_huang}  • IP地址和网络信息${rw_lv}"
	echo -e "${rw_huang}  • CPU型号和使用率${rw_lv}"
	echo -e "${rw_huang}  • 内存使用情况${rw_lv}"
	echo -e "${rw_huang}  • 磁盘使用情况${rw_lv}"
	echo ""
	echo -e "${rw_huang}提示: 信息将自动显示，查看后按回车继续${rw_lv}"
	echo ""
	send_stats "系统信息查询"

	ip_address

	local cpu_info=$(lscpu | awk -F': +' '/Model name:/ {print $2; exit}')

	local cpu_usage_percent=$(awk '{u=$2+$4; t=$2+$4+$5; if (NR==1){u1=u; t1=t;} else printf "%.0f\n", (($2+$4-u1) * 100 / (t-t1))}' \
		<(grep 'cpu ' /proc/stat) <(sleep 1; grep 'cpu ' /proc/stat))

	local cpu_cores=$(nproc)

	local cpu_freq=$(cat /proc/cpuinfo | grep "MHz" | head -n 1 | awk '{printf "%.1f GHz\n", $4/1000}')

	local mem_info=$(free -b | awk 'NR==2{printf "%.2f/%.2fM (%.2f%%)", $3/1024/1024, $2/1024/1024, $3*100/$2}')

	local disk_info=$(df -h | awk '$NF=="/"{printf "%s/%s (%s)", $3, $2, $5}')

	local ipinfo=$(curl -s ipinfo.io)
	local country=$(echo "$ipinfo" | grep 'country' | awk -F': ' '{print $2}' | tr -d '",')
	local city=$(echo "$ipinfo" | grep 'city' | awk -F': ' '{print $2}' | tr -d '",')
	local isp_info=$(echo "$ipinfo" | grep 'org' | awk -F': ' '{print $2}' | tr -d '",')

	local load=$(uptime | awk '{print $(NF-2), $(NF-1), $NF}')
	local dns_addresses=$(awk '/^nameserver/{printf "%s ", $2} END {print ""}' /etc/resolv.conf)


	local cpu_arch=$(uname -m)

	local hostname=$(uname -n)

	local kernel_version=$(uname -r)

	local congestion_algorithm=$(sysctl -n net.ipv4.tcp_congestion_control)
	local queue_algorithm=$(sysctl -n net.core.default_qdisc)

	local os_info=""
	if [ -f /etc/os-release ]; then
		os_info=$(grep PRETTY_NAME /etc/os-release | cut -d '=' -f2 | tr -d '"')
	else
		os_info=$(sw_vers -productName 2>/dev/null || echo "Unknown")
	fi

	output_status

	local current_time=$(date "+%Y-%m-%d %I:%M %p")


	local swap_info=$(free -m | awk 'NR==3{used=$3; total=$2; if (total == 0) {percentage=0} else {percentage=used*100/total}; printf "%dM/%dM (%d%%)", used, total, percentage}')

	local runtime=$(cat /proc/uptime | awk -F. '{run_days=int($1 / 86400);run_hours=int(($1 % 86400) / 3600);run_minutes=int(($1 % 3600) / 60); if (run_days > 0) printf("%d天 ", run_days); if (run_hours > 0) printf("%d时 ", run_hours); printf("%d分\n", run_minutes)}')

	local timezone=$(current_timezone)

	local tcp_count=$(ss -t | wc -l)
	local udp_count=$(ss -u | wc -l)

	clear
	echo -e "系统信息查询"
	echo -e "${rw_lv}-------------"
	echo -e "${rw_huang}${rw_huang}主机名${rw_huang}:         ${rw_lv}$hostname"
	echo -e "${rw_huang}${rw_huang}系统版本${rw_huang}:       ${rw_lv}$os_info"
	echo -e "${rw_huang}${rw_huang}Linux版本${rw_huang}:      ${rw_lv}$kernel_version"
	echo -e "${rw_lv}-------------"
	echo -e "${rw_huang}${rw_huang}CPU架构${rw_huang}:        ${rw_lv}$cpu_arch"
	echo -e "${rw_huang}${rw_huang}CPU型号${rw_huang}:        ${rw_lv}$cpu_info"
	echo -e "${rw_huang}${rw_huang}CPU核心数${rw_huang}:      ${rw_lv}$cpu_cores"
	echo -e "${rw_huang}${rw_huang}CPU频率${rw_huang}:        ${rw_lv}$cpu_freq"
	echo -e "${rw_lv}-------------"
	echo -e "${rw_huang}${rw_huang}CPU占用${rw_huang}:        ${rw_lv}$cpu_usage_percent%"
	echo -e "${rw_huang}${rw_huang}系统负载${rw_huang}:       ${rw_lv}$load"
	echo -e "${rw_huang}${rw_huang}TCP|UDP连接数${rw_huang}:  ${rw_lv}$tcp_count|$udp_count"
	echo -e "${rw_huang}${rw_huang}物理内存${rw_huang}:       ${rw_lv}$mem_info"
	echo -e "${rw_huang}${rw_huang}虚拟内存${rw_huang}:       ${rw_lv}$swap_info"
	echo -e "${rw_huang}${rw_huang}硬盘占用${rw_huang}:       ${rw_lv}$disk_info"
	echo -e "${rw_lv}-------------"
	echo -e "${rw_huang}${rw_huang}总接收${rw_huang}:         ${rw_lv}$rx"
	echo -e "${rw_huang}${rw_huang}总发送${rw_huang}:         ${rw_lv}$tx"
	echo -e "${rw_lv}-------------"
	echo -e "${rw_huang}${rw_huang}网络算法${rw_huang}:       ${rw_lv}$congestion_algorithm $queue_algorithm"
	echo -e "${rw_lv}-------------"
	echo -e "${rw_huang}${rw_huang}运营商${rw_huang}:         ${rw_lv}$isp_info"
	if [ -n "$ipv4_address" ]; then
		echo -e "${rw_huang}IPv4地址:       ${rw_lv}$ipv4_address"
	fi

	if [ -n "$ipv6_address" ]; then
		echo -e "${rw_huang}IPv6地址:       ${rw_lv}$ipv6_address"
	fi
	echo -e "${rw_huang}${rw_huang}DNS地址${rw_huang}:        ${rw_lv}$dns_addresses"
	echo -e "${rw_huang}${rw_huang}地理位置${rw_huang}:       ${rw_lv}$country $city"
	echo -e "${rw_huang}${rw_huang}系统时间${rw_huang}:       ${rw_lv}$timezone $current_time"
	echo -e "${rw_lv}-------------"
	echo -e "${rw_huang}${rw_huang}运行时长${rw_huang}:       ${rw_lv}$runtime"
	echo
	break_end



}



# ================================================================
# 跑分测评模块
# 功能: 服务器硬件信息展示 + CPU/内存/磁盘/网络性能测试
# ================================================================

# 硬件信息展示
_benchmark_hardware_info() {
    clear
    echo -e "${rw_cheng}━━━━━━━━━━━━  硬件信息  ━━━━━━━━━━━━${rw_lv}"
    echo ""

    # CPU 信息
    local _cpu_model _cpu_cores _cpu_freq _cpu_cache
    _cpu_model=$(lscpu 2>/dev/null | awk -F': +' '/Model name:/ {print $2; exit}')
    _cpu_model=${_cpu_model:-未知}
    _cpu_cores=$(nproc 2>/dev/null || echo "未知")
    _cpu_freq=$(lscpu 2>/dev/null | awk -F': +' '/CPU max MHz:/ {printf "%.2f GHz", $2/1000; exit}')
    _cpu_freq=${_cpu_freq:-未知}
    _cpu_cache=$(lscpu 2>/dev/null | awk -F': +' '/L3 cache:/ {print $2; exit}')
    _cpu_cache=${_cpu_cache:-未知}

    echo -e " ${rw_cheng}── CPU ──${rw_lv}"
    echo -e "  型号:     ${rw_huang}${_cpu_model}${rw_lv}"
    echo -e "  核心数:   ${rw_huang}${_cpu_cores}${rw_lv}"
    echo -e "  频率:     ${rw_huang}${_cpu_freq}${rw_lv}"
    echo -e "  L3缓存:   ${rw_huang}${_cpu_cache}${rw_lv}"
    echo ""

    # 内存信息
    local _mem_total _mem_used _mem_free _mem_usage
    _mem_total=$(free -h 2>/dev/null | awk 'NR==2{print $2}')
    _mem_used=$(free -h 2>/dev/null | awk 'NR==2{print $3}')
    _mem_free=$(free -h 2>/dev/null | awk 'NR==2{print $4}')
    _mem_usage=$(free 2>/dev/null | awk 'NR==2{printf "%.1f", $3*100/$2}')

    echo -e " ${rw_cheng}── 内存 ──${rw_lv}"
    echo -e "  总量:     ${rw_huang}${_mem_total}${rw_lv}"
    echo -e "  已用:     ${rw_huang}${_mem_used}${rw_lv} (${_mem_usage}%)"
    echo -e "  可用:     ${rw_huang}${_mem_free}${rw_lv}"
    echo ""

    # Swap 信息
    local _swap_total _swap_used
    _swap_total=$(free -h 2>/dev/null | awk 'NR==3{print $2}')
    _swap_used=$(free -h 2>/dev/null | awk 'NR==3{print $3}')
    if [ "$_swap_total" != "0B" ] && [ -n "$_swap_total" ]; then
        echo -e "  Swap:     ${rw_huang}${_swap_used}${rw_lv} / ${rw_huang}${_swap_total}${rw_lv}"
        echo ""
    fi

    # 磁盘信息
    echo -e " ${rw_cheng}── 磁盘 ──${rw_lv}"
    df -h 2>/dev/null | awk 'NR==1 || /^\/dev\// {printf "  %-20s %8s %8s %8s  %s\n", $1, $2, $3, $5, $6}'
    echo ""

    # 磁盘IO测试信息（读取）
    local _disk_read_speed
    _disk_read_speed=$(dd if=/dev/zero of=/tmp/_bench_test bs=1M count=512 oflag=direct 2>&1 | awk -F'[ ,]+' '/copied/ {print $8 " " $9}')
    rm -f /tmp/_bench_test
    echo -e "  磁盘写入: ${rw_huang}${_disk_read_speed:-测试失败}${rw_lv}"
    echo ""

    # 网络信息
    echo -e " ${rw_cheng}── 网络 ──${rw_lv}"
    local _ipv4 _ipv6
    _ipv4=$(curl -s4 --max-time 3 ifconfig.me 2>/dev/null)
    _ipv6=$(curl -s6 --max-time 3 ifconfig.me 2>/dev/null)
    [ -n "$_ipv4" ] && echo -e "  IPv4:     ${rw_huang}${_ipv4}${rw_lv}"
    [ -n "$_ipv6" ] && echo -e "  IPv6:     ${rw_huang}${_ipv6}${rw_lv}"

    # 网络带宽测试（下载）
    local _net_speed
    _net_speed=$(curl -s --max-time 10 -o /dev/null -w "%{speed_download}" http://cachefly.cachefly.net/10mb.test 2>/dev/null)
    if [ -n "$_net_speed" ]; then
        local _speed_mb
        _speed_mb=$(awk "BEGIN{printf \"%.2f\", ${_net_speed}/1024/1024}")
        echo -e "  下载速度: ${rw_huang}${_speed_mb} MB/s${rw_lv}"
    fi
    echo ""

    # 系统信息
    echo -e " ${rw_cheng}── 系统 ──${rw_lv}"
    local _os_info _kernel _uptime _arch
    _os_info=$(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d'=' -f2 | tr -d '"' || echo "未知")
    _kernel=$(uname -r 2>/dev/null || echo "未知")
    _arch=$(uname -m 2>/dev/null || echo "未知")
    _uptime=$(uptime -p 2>/dev/null | sed 's/up //' || echo "未知")
    echo -e "  系统:     ${rw_huang}${_os_info}${rw_lv}"
    echo -e "  内核:     ${rw_huang}${_kernel}${rw_lv}"
    echo -e "  架构:     ${rw_huang}${_arch}${rw_lv}"
    echo -e "  运行:     ${rw_huang}${_uptime}${rw_lv}"
    echo ""
}

# CPU 跑分测试
_benchmark_cpu() {
    echo -e "${rw_cheng}━━━━━━━━━━━━  CPU 性能测试  ━━━━━━━━━━━━${rw_lv}"
    echo ""
    echo -e " ${rw_huang}测试中，请耐心等待...${rw_lv}"
    echo ""

    # 单核性能测试 - 计算圆周率
    local _pi_start _pi_end _pi_time
    _pi_start=$(date +%s.%N)
    echo "scale=3000; 4*a(1)" | bc -l >/dev/null 2>&1
    _pi_end=$(date +%s.%N)
    _pi_time=$(awk "BEGIN{printf \"%.2f\", ${_pi_end} - ${_pi_start}}")

    echo -e " ${rw_cheng}── 单核性能 ──${rw_lv}"
    echo -e "  圆周率计算(3000位): ${rw_huang}${_pi_time}${rw_lv} 秒"
    echo ""

    # 多核性能测试 - 并行计算
    local _cores _multi_start _multi_end _multi_time
    _cores=$(nproc)
    _multi_start=$(date +%s.%N)
    for i in $(seq 1 "$_cores"); do
        echo "scale=2000; 4*a(1)" | bc -l >/dev/null 2>&1 &
    done
    wait
    _multi_end=$(date +%s.%N)
    _multi_time=$(awk "BEGIN{printf \"%.2f\", ${_multi_end} - ${_multi_start}}")

    echo -e " ${rw_cheng}── 多核性能(${_cores}核) ──${rw_lv}"
    echo -e "  并行圆周率(2000位): ${rw_huang}${_multi_time}${rw_lv} 秒"
    echo ""

    # OpenSSL 性能测试
    if command -v openssl &>/dev/null; then
        echo -e " ${rw_cheng}── OpenSSL 加密性能 ──${rw_lv}"
        openssl speed -evp aes-256-cbc 2>/dev/null | tail -2 | awk '{printf "  %s: %s bytes/s\n", $1, $NF}'
        echo ""
    fi

    # 评分
    local _score
    _score=$(awk "BEGIN{printf \"%d\", 10000 / ${_pi_time}}")
    echo -e " ${rw_cheng}── CPU 综合评分 ──${rw_lv}"
    echo -e "  ${rw_huang}${_score}${rw_lv} 分 (越高越好)"
    echo ""
}

# 内存跑分测试
_benchmark_memory() {
    echo -e "${rw_cheng}━━━━━━━━━━━━  内存性能测试  ━━━━━━━━━━━━${rw_lv}"
    echo ""
    echo -e " ${rw_huang}测试中，请耐心等待...${rw_lv}"
    echo ""

    # 内存写入测试
    local _mem_write
    _mem_write=$(dd if=/dev/zero of=/dev/null bs=1M count=4096 2>&1 | awk -F'[ ,]+' '/copied/ {print $8 " " $9}')
    echo -e " ${rw_cheng}── 内存吞吐 ──${rw_lv}"
    echo -e "  写入速度: ${rw_huang}${_mem_write:-测试失败}${rw_lv}"
    echo ""

    # 内存复制测试
    local _mem_copy
    _mem_copy=$(dd if=/dev/zero of=/tmp/_mem_test bs=1M count=2048 2>&1 | awk -F'[ ,]+' '/copied/ {print $8 " " $9}')
    rm -f /tmp/_mem_test
    echo -e "  读写速度: ${rw_huang}${_mem_copy:-测试失败}${rw_lv}"
    echo ""

    # 评分
    local _speed_num _score
    _speed_num=$(echo "$_mem_write" | grep -oE '[0-9.]+')
    if [ -n "$_speed_num" ]; then
        local _unit
        _unit=$(echo "$_mem_write" | grep -oE '[GMK]B/s')
        case "$_unit" in
            GB/s) _score=$(awk "BEGIN{printf \"%d\", ${_speed_num} * 100}") ;;
            MB/s) _score=$(awk "BEGIN{printf \"%d\", ${_speed_num}") ;;
            KB/s) _score=$(awk "BEGIN{printf \"%d\", ${_speed_num} / 1024}") ;;
            *) _score=0 ;;
        esac
    else
        _score=0
    fi

    echo -e " ${rw_cheng}── 内存综合评分 ──${rw_lv}"
    echo -e "  ${rw_huang}${_score}${rw_lv} 分 (越高越好)"
    echo ""
}

# 磁盘跑分测试
_benchmark_disk() {
    echo -e "${rw_cheng}━━━━━━━━━━━━  磁盘性能测试  ━━━━━━━━━━━━${rw_lv}"
    echo ""
    echo -e " ${rw_huang}测试中，请耐心等待...${rw_lv}"
    echo ""

    echo -e " ${rw_cheng}── 写入测试(4K块) ──${rw_lv}"
    local _write_4k
    _write_4k=$(dd if=/dev/zero of=/tmp/_disk_4k bs=4k count=10000 oflag=direct 2>&1 | awk -F'[ ,]+' '/copied/ {print $8 " " $9}')
    rm -f /tmp/_disk_4k
    echo -e "  4K写入: ${rw_huang}${_write_4k:-测试失败}${rw_lv}"
    echo ""

    echo -e " ${rw_cheng}── 写入测试(1M块) ──${rw_lv}"
    local _write_1m
    _write_1m=$(dd if=/dev/zero of=/tmp/_disk_1m bs=1M count=1024 oflag=direct 2>&1 | awk -F'[ ,]+' '/copied/ {print $8 " " $9}')
    rm -f /tmp/_disk_1m
    echo -e "  1M写入: ${rw_huang}${_write_1m:-测试失败}${rw_lv}"
    echo ""

    echo -e " ${rw_cheng}── 读取测试(1M块) ──${rw_lv}"
    # 先创建测试文件
    dd if=/dev/zero of=/tmp/_disk_read bs=1M count=1024 oflag=direct 2>/dev/null
    local _read_1m
    _read_1m=$(dd if=/tmp/_disk_read of=/dev/null bs=1M count=1024 iflag=direct 2>&1 | awk -F'[ ,]+' '/copied/ {print $8 " " $9}')
    rm -f /tmp/_disk_read
    echo -e "  1M读取: ${rw_huang}${_read_1m:-测试失败}${rw_lv}"
    echo ""

    # 评分
    local _speed_num _score _unit
    _speed_num=$(echo "$_write_1m" | grep -oE '[0-9.]+')
    _unit=$(echo "$_write_1m" | grep -oE '[GMK]B/s')
    if [ -n "$_speed_num" ]; then
        case "$_unit" in
            GB/s) _score=$(awk "BEGIN{printf \"%d\", ${_speed_num} * 100}") ;;
            MB/s) _score=$(awk "BEGIN{printf \"%d\", ${_speed_num}") ;;
            KB/s) _score=$(awk "BEGIN{printf \"%d\", ${_speed_num} / 1024}") ;;
            *) _score=0 ;;
        esac
    else
        _score=0
    fi

    echo -e " ${rw_cheng}── 磁盘综合评分 ──${rw_lv}"
    echo -e "  ${rw_huang}${_score}${rw_lv} 分 (越高越好)"
    echo ""
}

# 网络跑分测试
_benchmark_network() {
    echo -e "${rw_cheng}━━━━━━━━━━━━  网络性能测试  ━━━━━━━━━━━━${rw_lv}"
    echo ""
    echo -e " ${rw_huang}测试中，请耐心等待...${rw_lv}"
    echo ""

    # 延迟测试
    echo -e " ${rw_cheng}── 延迟测试 ──${rw_lv}"
    local _ping_cn _ping_us _ping_jp
    _ping_cn=$(ping -c 5 -W 2 baidu.com 2>/dev/null | awk -F'/' '/rtt|round-trip/ {printf "%.1f ms", $5}')
    _ping_us=$(ping -c 5 -W 2 google.com 2>/dev/null | awk -F'/' '/rtt|round-trip/ {printf "%.1f ms", $5}')
    _ping_jp=$(ping -c 5 -W 2 yahoo.co.jp 2>/dev/null | awk -F'/' '/rtt|round-trip/ {printf "%.1f ms", $5}')

    echo -e "  国内(baidu):  ${rw_huang}${_ping_cn:-超时}${rw_lv}"
    echo -e "  美国(google): ${rw_huang}${_ping_us:-超时}${rw_lv}"
    echo -e "  日本(yahoo):  ${rw_huang}${_ping_jp:-超时}${rw_lv}"
    echo ""

    # 下载速度测试
    echo -e " ${rw_cheng}── 下载速度 ──${rw_lv}"
    local _dl_speed _dl_speed_mb
    _dl_speed=$(curl -s --max-time 15 -o /dev/null -w "%{speed_download}" http://cachefly.cachefly.net/100mb.test 2>/dev/null)
    if [ -n "$_dl_speed" ] && [ "$_dl_speed" != "0.000" ]; then
        _dl_speed_mb=$(awk "BEGIN{printf \"%.2f\", ${_dl_speed}/1024/1024}")
        echo -e "  国际下载: ${rw_huang}${_dl_speed_mb} MB/s${rw_lv}"
    else
        echo -e "  国际下载: ${rw_huang}测试失败${rw_lv}"
    fi

    # 本地下载测试
    local _local_speed _local_speed_mb
    _local_speed=$(curl -s --max-time 10 -o /dev/null -w "%{speed_download}" http://speedtest.tele2.net/10MB.zip 2>/dev/null)
    if [ -n "$_local_speed" ] && [ "$_local_speed" != "0.000" ]; then
        _local_speed_mb=$(awk "BEGIN{printf \"%.2f\", ${_local_speed}/1024/1024}")
        echo -e "  备用下载: ${rw_huang}${_local_speed_mb} MB/s${rw_lv}"
    fi
    echo ""

    # 评分
    local _score=0
    if [ -n "$_dl_speed_mb" ]; then
        _score=$(awk "BEGIN{printf \"%d\", ${_dl_speed_mb} * 10}")
    fi
    echo -e " ${rw_cheng}── 网络综合评分 ──${rw_lv}"
    echo -e "  ${rw_huang}${_score}${rw_lv} 分 (越高越好)"
    echo ""
}

# 完整跑分报告
_benchmark_full() {
    clear
    echo -e "${rw_cheng}━━━━━━━━━━━━  完整跑分报告  ━━━━━━━━━━━━${rw_lv}"
    echo ""

    # 硬件信息
    _benchmark_hardware_info
    echo -e " ${rw_cheng}========================================${rw_lv}"
    echo ""

    # CPU 测试
    _benchmark_cpu
    echo -e " ${rw_cheng}========================================${rw_lv}"
    echo ""

    # 内存测试
    _benchmark_memory
    echo -e " ${rw_cheng}========================================${rw_lv}"
    echo ""

    # 磁盘测试
    _benchmark_disk
    echo -e " ${rw_cheng}========================================${rw_lv}"
    echo ""

    # 网络测试
    _benchmark_network

    echo -e " ${rw_cheng}━━━━━━━━━━━━  跑分完成  ━━━━━━━━━━━━${rw_lv}"
    echo ""
}

# ════════════════════════════════════════════════════════════════
# 函数: run_zbench
# 功能: ZBench 中文跑分脚本一键下载并执行
# 官方仓库: https://github.com/FunctionClub/ZBench
# 依赖: wget、bash
# ════════════════════════════════════════════════════════════════
run_zbench() {

	while true; do
		clear
		send_stats "ZBench跑分测评"
		echo -e "${rw_cheng}━━━━━━━━━━━━  ZBench 跑分测评  ━━━━━━━━━━━━${rw_lv}"
		echo ""
		echo -e " ${rw_lv}ZBench 是 FunctionClub 开发的中文服务器跑分脚本${rw_lv}"
		echo -e " ${rw_lv}集成 CPU/内存/磁盘性能测试 + 全国节点测速${rw_lv}"
		echo -e " ${rw_lv}仓库: ${rw_huang}https://github.com/FunctionClub/ZBench${rw_lv}"
		echo ""
		echo -e " ${rw_hong}⚠ 注意:${rw_lv}"
		echo -e "   ${rw_huang}•${rw_lv} 跑分过程耗时较长（5-15 分钟），请耐心等待"
		echo -e "   ${rw_huang}•${rw_lv} 需要服务器能访问 GitHub 和国内测速节点"
		echo -e "   ${rw_huang}•${rw_lv} 仅用于个人学习与合法用途${rw_lv}"
		echo ""
		echo -e " ${rw_cheng}────────────────────────────────────────${rw_lv}"
		echo -e " ${rw_huang}1${rw_lv}  开始一键跑分测评"
		echo -e " ${rw_huang}0${rw_lv}  返回主菜单"
		echo -e " ${rw_cheng}────────────────────────────────────────${rw_lv}"
		read -e -p " 请选择: " _zbench_choice < /dev/tty

		case "$_zbench_choice" in
			1)
				# ── 确保wget可用 ──
				if ! command -v wget &>/dev/null; then
					yellow "未检测到 wget，正在安装..."
					install wget
				fi

				# ── 下载并执行 ZBench 中文版 ──
				echo ""
				echo -e " ${rw_huang}正在下载并执行 ZBench 中文跑分脚本...${rw_lv}"
				echo -e " ${rw_cheng}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${rw_lv}"
				echo ""

				# 切到 /tmp 避免在用户目录留文件
				cd /tmp

				# 下载脚本（-N 覆盖已有文件，--no-check-certificate 跳过证书检查）
				if wget -N --no-check-certificate \
					https://raw.githubusercontent.com/FunctionClub/ZBench/master/ZBench-CN.sh 2>/dev/null; then
					# 下载成功，执行跑分
					bash ZBench-CN.sh
					local _rc=$?
					# 清理临时文件
					rm -f ZBench-CN.sh 2>/dev/null
					cd ~

					echo ""
					echo -e " ${rw_cheng}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${rw_lv}"
					if [ $_rc -eq 0 ]; then
						green "ZBench 跑分测评完成"
					else
						yellow "ZBench 跑分测评结束（退出码: $_rc）"
					fi
				else
					cd ~
					red "下载 ZBench 脚本失败"
					echo -e " ${rw_huang}可能原因:${rw_lv}"
					echo -e "   - 网络不通或 raw.githubusercontent.com 不可达"
					echo -e "   - DNS 解析失败"
					echo -e " ${rw_huang}手动执行:${rw_lv}"
					echo -e "   ${rw_lv}wget -N --no-check-certificate https://raw.githubusercontent.com/FunctionClub/ZBench/master/ZBench-CN.sh && bash ZBench-CN.sh${rw_lv}"
				fi

				# ── 跑分结束后等待用户按回车返回 ──
				echo ""
				read -e -p " 按回车键返回菜单..." _dummy < /dev/tty
				break_cancel
				;;
			0)
				# ── 返回主菜单 ──
				break_cancel
				return 0
				;;
			*)
				# ── 输入错误处理 ──
				red "输入有误，请选择 0 或 1"
				sleep 1
				continue
				;;
		esac
	done
}


# 跑分测评主菜单
benchmark_menu() {
    while true; do
        clear
        send_stats "跑分测评"
        echo -e "${rw_cheng}━━━━━━━━━━━━  跑分测评  ━━━━━━━━━━━━${rw_lv}"
        echo ""
        echo -e " ${rw_huang}1${rw_lv}  硬件信息查看"
        echo -e " ${rw_huang}2${rw_lv}  CPU性能测试"
        echo -e " ${rw_huang}3${rw_lv}  内存性能测试"
        echo -e " ${rw_huang}4${rw_lv}  磁盘性能测试"
        echo -e " ${rw_huang}5${rw_lv}  网络性能测试"
        echo -e " ${rw_huang}6${rw_lv}  完整跑分报告"
        echo ""
        echo -e " ${rw_cheng}────────────────────────────────────────${rw_lv}"
        echo -e " ${rw_huang}0${rw_lv}  返回主菜单"
        echo -e " ${rw_cheng}────────────────────────────────────────${rw_lv}"
        read -e -p " 请选择: " _bench_choice < /dev/tty
        case $_bench_choice in
            1) _benchmark_hardware_info; break_end ;;
            2) _benchmark_cpu; break_end ;;
            3) _benchmark_memory; break_end ;;
            4) _benchmark_disk; break_end ;;
            5) _benchmark_network; break_end ;;
            6) _benchmark_full; break_end ;;
            0) return ;;
            *) echo -e " ${rw_hong}无效选项${rw_lv}"; break_end ;;
        esac
    done
}



# ════════════════════════════════════════════════════════════════
# 一键换源 LinuxMirrors（独立函数）
# 来源: https://github.com/SuperManito/LinuxMirrors
# 功能: 更换系统软件源 / Docker 安装与换源 / Docker 更换镜像加速器
# 被 linux_tools (环境配置-35) 和 github_manager (版本控制-13) 共用
# ════════════════════════════════════════════════════════════════
linux_mirrors_switch() {
  clear
  cd ~
  send_stats "一键换源"
  echo -e "${rw_cheng}━━━━━━ 一键换源 LinuxMirrors ━━━━━━${rw_lv}"
  echo ""
  echo -e " ${rw_lv}SuperManito 开发的 GNU/Linux 一键换源脚本${rw_lv}"
  echo -e " ${rw_lv}支持 Debian/Ubuntu/RHEL/CentOS/Arch/Alpine 等 30+ 发行版${rw_lv}"
  echo -e " ${rw_lv}作者: ${rw_huang}https://github.com/SuperManito${rw_lv}"
  echo -e " ${rw_lv}官网: ${rw_huang}https://linuxmirrors.cn${rw_lv}"
  echo -e " ${rw_lv}仓库: ${rw_huang}https://github.com/SuperManito/LinuxMirrors${rw_lv}"
  echo ""
  echo -e " ${rw_huang}可用功能:${rw_lv}"
  echo -e "   ${rw_huang}①${rw_lv} 更换系统软件源（主功能）"
  echo -e "   ${rw_huang}②${rw_lv} Docker 安装与换源（额外脚本）"
  echo -e "   ${rw_huang}③${rw_lv} Docker 更换镜像加速器（仅改加速器）"
  echo ""
  echo -e " ${rw_hong}⚠ 注意事项:${rw_lv}"
  echo -e "   ${rw_huang}①${rw_lv} 必须 root 运行，脚本会自动备份原有源配置"
  echo -e "   ${rw_huang}②${rw_lv} 需要服务器能访问外网（linuxmirrors.cn 或 GitHub）"
  echo -e "   ${rw_huang}③${rw_lv} 换源后请执行 ${rw_lv}apt update${rw_lv} / ${rw_lv}dnf makecache${rw_lv} 刷新缓存"
  echo -e "   ${rw_huang}④${rw_lv} 每次联网拉取最新脚本执行，本地不留文件${rw_lv}"
  echo ""
  echo -e " ${rw_huang}请选择要执行的操作:${rw_lv}"
  echo -e "   ${rw_huang}1${rw_lv} 更换系统软件源（主功能）"
  echo -e "   ${rw_huang}2${rw_lv} Docker 安装与换源"
  echo -e "   ${rw_huang}3${rw_lv} Docker 更换镜像加速器"
  echo -e "   ${rw_huang}0${rw_lv} 取消"
  echo ""
  read -e -p " 请选择: " _mirror_choice < /dev/tty

  local _mirror_desc=""
  case "$_mirror_choice" in
	1)
		_mirror_desc="更换系统软件源"
		;;
	2)
		_mirror_desc="Docker 安装与换源"
		;;
	3)
		_mirror_desc="Docker 更换镜像加速器"
		;;
	0|"")
		yellow "已取消"
		return 0
		;;
	*)
		red "无效的输入!"
		return 1
		;;
  esac

  # 显示即将执行的命令
  echo ""
  echo -e " ${rw_huang}即将执行: ${rw_lv}${_mirror_desc}${rw_lv}"
  case "$_mirror_choice" in
	1)
		echo -e " ${rw_huang}命令: ${rw_lv}bash <(curl -sSL https://linuxmirrors.cn/main.sh)${rw_lv}"
		;;
	2)
		echo -e " ${rw_huang}命令: ${rw_lv}bash <(curl -sSL https://linuxmirrors.cn/docker.sh)${rw_lv}"
		;;
	3)
		echo -e " ${rw_huang}命令: ${rw_lv}bash <(curl -sSL https://linuxmirrors.cn/docker.sh) --only-registry${rw_lv}"
		;;
  esac
  echo ""
  read -e -p " 确认开始执行？(y/N): " _confirm < /dev/tty
  if [[ ! "$_confirm" =~ ^[Yy]$ ]]; then
	  yellow "已取消"
	  return 0
  fi

  # 检查 root 权限（脚本要求 root 运行）
  if [ "$EUID" -ne 0 ]; then
	  yellow "当前非 root 用户，LinuxMirrors 脚本要求 root 权限"
	  echo -e " ${rw_huang}正在尝试通过 sudo 提权执行...${rw_lv}"
	  if ! sudo -n true 2>/dev/null; then
		  echo -e " ${rw_huang}需要输入 sudo 密码（如提示）:${rw_lv}"
	  fi
  fi

  # 确保有 curl
  if ! command -v curl &>/dev/null; then
	  yellow "未检测到 curl，正在安装..."
	  install curl
  fi

  # 检查 bash 版本（LinuxMirrors 脚本需要 bash 4.0+，用了 declare -A 和 ${var,,}）
  # macOS 自带 bash 3.2 不支持，需要用 brew 安装的新版 bash
  local _bash_ver_major="${BASH_VERSINFO[0]:-0}"
  if [ "$_bash_ver_major" -lt 4 ] 2>/dev/null; then
	  yellow "检测到当前 bash 版本为 ${BASH_VERSION:-未知}（低于 4.0）"
	  echo -e " ${rw_huang}LinuxMirrors 脚本需要 bash 4.0+（使用了关联数组等特性）${rw_lv}"
	  # 尝试找系统中已安装的高版本 bash
	  local _new_bash=""
	  for _b in /opt/homebrew/bin/bash /usr/local/bin/bash /bin/bash4 /usr/bin/bash4; do
		  if [ -x "$_b" ] && "$_b" --version 2>/dev/null | grep -qE 'version [4-9]\.'; then
			  _new_bash="$_b"
			  break
		  fi
	  done
	  if [ -n "$_new_bash" ]; then
		  green "找到高版本 bash: $_new_bash"
		  echo -e " ${rw_huang}将使用 $_new_bash 执行换源脚本${rw_lv}"
		  # 用高版本 bash 执行官方命令
		  echo ""
		  echo -e " ${rw_huang}正在执行 ${_mirror_desc}（请按脚本提示交互）...${rw_lv}"
		  echo -e " ${rw_cheng}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${rw_lv}"
		  echo ""
		  local _mirror_rc=0
		  case "$_mirror_choice" in
			1)
				if [ "$EUID" -ne 0 ]; then
					sudo "$_new_bash" <(curl -sSL https://linuxmirrors.cn/main.sh)
				else
					"$_new_bash" <(curl -sSL https://linuxmirrors.cn/main.sh)
				fi
				_mirror_rc=$?
				;;
			2)
				if [ "$EUID" -ne 0 ]; then
					sudo "$_new_bash" <(curl -sSL https://linuxmirrors.cn/docker.sh)
				else
					"$_new_bash" <(curl -sSL https://linuxmirrors.cn/docker.sh)
				fi
				_mirror_rc=$?
				;;
			3)
				if [ "$EUID" -ne 0 ]; then
					sudo "$_new_bash" <(curl -sSL https://linuxmirrors.cn/docker.sh) --only-registry
				else
					"$_new_bash" <(curl -sSL https://linuxmirrors.cn/docker.sh) --only-registry
				fi
				_mirror_rc=$?
				;;
		  esac
	  else
		  red "未找到 bash 4.0+ 版本"
		  echo -e " ${rw_huang}LinuxMirrors 脚本需要 bash 4.0+，当前系统 bash 版本过低${rw_lv}"
		  echo ""
		  echo -e " ${rw_huang}解决方案:${rw_lv}"
		  if [ "$(uname)" = "Darwin" ]; then
			  echo -e "   ${rw_lv}macOS 自带 bash 3.2，请用 Homebrew 安装新版:${rw_lv}"
			  echo -e "     ${rw_huang}brew install bash${rw_lv}"
			  echo -e "   ${rw_lv}安装后重新运行本工具即可${rw_lv}"
		  else
			  echo -e "   ${rw_lv}Linux 服务器通常自带 bash 4.0+，如确为旧版:${rw_lv}"
			  echo -e "     ${rw_huang}apt install bash${rw_lv}  或  ${rw_huang}yum install bash${rw_lv}"
		  fi
		  echo -e "   ${rw_lv}或直接在 Linux 服务器上运行本工具（非 macOS）${rw_lv}"
		  return 1
	  fi
  else
	  echo ""
	  echo -e " ${rw_huang}正在执行 ${_mirror_desc}（请按脚本提示交互）...${rw_lv}"
	  echo -e " ${rw_cheng}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${rw_lv}"
	  echo ""

	  # bash 4.0+ 直接运行作者官方命令（联网拉取最新版，交互式）
	  local _mirror_rc=0
	  case "$_mirror_choice" in
		1)
			if [ "$EUID" -ne 0 ]; then
				sudo bash <(curl -sSL https://linuxmirrors.cn/main.sh)
			else
				bash <(curl -sSL https://linuxmirrors.cn/main.sh)
			fi
			_mirror_rc=$?
			;;
		2)
			if [ "$EUID" -ne 0 ]; then
				sudo bash <(curl -sSL https://linuxmirrors.cn/docker.sh)
			else
				bash <(curl -sSL https://linuxmirrors.cn/docker.sh)
			fi
			_mirror_rc=$?
			;;
		3)
			if [ "$EUID" -ne 0 ]; then
				sudo bash <(curl -sSL https://linuxmirrors.cn/docker.sh) --only-registry
			else
				bash <(curl -sSL https://linuxmirrors.cn/docker.sh) --only-registry
			fi
			_mirror_rc=$?
			;;
	  esac
  fi

  echo ""
  echo -e "${rw_cheng}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${rw_lv}"
  if [ $_mirror_rc -eq 0 ]; then
	  green "${_mirror_desc} 执行完成"
	  echo ""
	  echo -e " ${rw_huang}后续建议:${rw_lv}"
	  case "$_mirror_choice" in
		1)
			echo -e "   ${rw_lv}• 执行缓存刷新命令确认换源生效:${rw_lv}"
			echo -e "     Debian/Ubuntu: ${rw_lv}apt update${rw_lv}"
			echo -e "     RHEL系:        ${rw_lv}dnf makecache${rw_lv}"
			echo -e "     Arch系:        ${rw_lv}pacman -Sy${rw_lv}"
			echo -e "     Alpine:        ${rw_lv}apk update${rw_lv}"
			;;
		2)
			echo -e "   ${rw_lv}• 验证 Docker: ${rw_lv}docker run hello-world${rw_lv}"
			echo -e "   ${rw_lv}• 查看 Docker 源: ${rw_lv}cat /etc/docker/daemon.json${rw_lv}"
			;;
		3)
			echo -e "   ${rw_lv}• 重启 Docker 生效: ${rw_lv}systemctl restart docker${rw_lv}"
			echo -e "   ${rw_lv}• 拉取测试: ${rw_lv}docker pull hello-world${rw_lv}"
			;;
	  esac
	  echo ""
	  echo -e " ${rw_huang}如需恢复默认源，重新运行本工具并选 1，脚本有恢复选项${rw_lv}"
	  echo -e " ${rw_huang}官方文档: ${rw_lv}https://linuxmirrors.cn/use/${rw_lv}"
  else
	  red "${_mirror_desc} 执行返回非零状态码 (退出码: $_mirror_rc)"
	  echo -e " ${rw_huang}请检查上方日志中的错误信息${rw_lv}"
	  echo -e " ${rw_huang}常见原因:${rw_lv}"
	  echo -e "   - 非 root 用户且 sudo 提权失败"
	  echo -e "   - 网络不通或 linuxmirrors.cn 不可达"
	  echo -e "   - 当前系统/版本不在支持列表"
	  echo -e "   - 原有软件源配置异常"
	  echo -e " ${rw_huang}官方文档: ${rw_lv}https://linuxmirrors.cn/use/${rw_lv}"
	  echo -e " ${rw_huang}备用域名: ${rw_lv}https://edgeone.linuxmirrors.cn${rw_lv}"
  fi
}




linux_tools() {

  while true; do
	  clear
	  send_stats "安装环境"

	  # ── 检测包管理器 ──
	  local PM="unknown"
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
	  elif command -v brew >/dev/null 2>&1; then
		PM="brew"
	  elif command -v pkg >/dev/null 2>&1; then
		PM="pkg"
	  else
		echo -e "${rw_hong}未识别的包管理器，请先安装后重试${rw_lv}"
		sleep 3
		return
	  fi

	  # ── 统计已安装工具 ──
	  local _all_tools=(curl wget sudo socat htop iftop unzip tar tmux ffmpeg btop ranger ncdu fzf vim nano git opencode brew nodejs pnpm)
	  local _installed=0 _total=${#_all_tools[@]}
	  for _t in "${_all_tools[@]}"; do
		if command -v "$_t" >/dev/null 2>&1; then
		  ((_installed++))
		fi
	  done

	  # ── 安装状态标记函数 ──
	  _ist() {
		if command -v "$1" >/dev/null 2>&1; then
		  echo -ne "✅"
		else
		  echo -ne "❌"
		fi
	  }

	  echo -e "${rw_cheng}━━━━━━━━━━━━  安装环境  ━━━━━━━━━━━━${rw_lv}"
	  echo -e " 包管理器 ${rw_huang}${PM}${rw_lv}  已安装 ${rw_lv}${_installed}${rw_lv}/${_total}"
	  echo ""
	  echo -e " ${rw_cheng}──── 网络工具${rw_lv}"
	  echo -e " $(_ist curl) ${rw_huang}1${rw_lv}  curl 下载工具★        $(_ist wget) ${rw_huang}2${rw_lv}  wget 下载工具★"
	  echo -e " $(_ist sudo) ${rw_huang}3${rw_lv}  sudo 超管权限         $(_ist socat) ${rw_huang}4${rw_lv}  socat 通信工具"
	  echo ""
	  echo -e " ${rw_cheng}──── 系统监控${rw_lv}"
	  echo -e " $(_ist htop) ${rw_huang}5${rw_lv}  htop 系统监控         $(_ist iftop) ${rw_huang}6${rw_lv}  iftop 流量监控"
	  echo -e " $(_ist btop) ${rw_huang}7${rw_lv}  btop 现代监控★        $(_ist tmux) ${rw_huang}8${rw_lv}  tmux 后台多路"
	  echo ""
	  echo -e " ${rw_cheng}──── 文件工具${rw_lv}"
	  echo -e " $(_ist unzip) ${rw_huang}9${rw_lv}  unzip ZIP解压         $(_ist tar) ${rw_huang}10${rw_lv} tar GZ解压"
	  echo -e " $(_ist ranger) ${rw_huang}11${rw_lv} ranger 文件管理       $(_ist ncdu) ${rw_huang}12${rw_lv} ncdu 磁盘分析"
	  echo -e " $(_ist fzf) ${rw_huang}13${rw_lv}  fzf 全局搜索         $(_ist ffmpeg) ${rw_huang}14${rw_lv} ffmpeg 视频推流"
	  echo ""
	  echo -e " ${rw_cheng}──── 编辑器${rw_lv}"
	  echo -e " $(_ist vim) ${rw_huang}15${rw_lv}  vim 编辑器           $(_ist nano) ${rw_huang}16${rw_lv}  nano 编辑器★"
	  echo ""
	  echo -e " ${rw_cheng}──── 开发工具${rw_lv}"
	  echo -e " $(_ist git) ${rw_huang}17${rw_lv}  git 版本控制         $(_ist opencode) ${rw_huang}18${rw_lv} opencode AI编程★"
	  echo -e " $(_ist brew) ${rw_huang}19${rw_lv}  brew macOS包管理     $(_ist nodejs) ${rw_huang}20${rw_lv} nodejs JS运行时★"
	  echo -e " $(_ist pnpm) ${rw_huang}21${rw_lv}  pnpm 包管理器★"
	  echo ""
	  echo -e " ${rw_cheng}──── 批量操作${rw_lv}"
	  echo -e " ${rw_huang}31${rw_lv} 全部安装                    ${rw_huang}32${rw_lv} 全部卸载"
	  echo -e " ${rw_huang}33${rw_lv} 安装指定                    ${rw_huang}34${rw_lv} 卸载指定"
	  echo -e " ${rw_huang}35${rw_lv} 一键换源"
	  echo ""
	  echo -e " ${rw_cheng}────────────────────────────────────────${rw_lv}"
	  echo -e " ${rw_huang}0${rw_lv}  返回主菜单"
	  echo -e " ${rw_cheng}────────────────────────────────────────${rw_lv}"
	  read -e -p " 请选择: " sub_choice

	  case $sub_choice in
		  1)
			  clear; install curl; clear; curl --help
			  send_stats "安装curl" ;;
		  2)
			  clear; install wget; clear; wget --help
			  send_stats "安装wget" ;;
		  3)
			  clear; install sudo; clear; sudo --help
			  send_stats "安装sudo" ;;
		  4)
			  clear; install socat; clear; socat -h
			  send_stats "安装socat" ;;
		  5)
			  clear; install htop; clear; htop
			  send_stats "安装htop" ;;
		  6)
			  clear; install iftop; clear; iftop
			  send_stats "安装iftop" ;;
		  7)
			  clear; install btop; clear; btop
			  send_stats "安装btop" ;;
		  8)
			  clear; install tmux; clear; tmux --help
			  send_stats "安装tmux" ;;
		  9)
			  clear; install unzip; clear; unzip
			  send_stats "安装unzip" ;;
		  10)
			  clear; install tar; clear; tar --help
			  send_stats "安装tar" ;;
		  11)
			  clear; install ranger; cd /; clear; ranger; cd ~
			  send_stats "安装ranger" ;;
		  12)
			  clear; install ncdu; cd /; clear; ncdu; cd ~
			  send_stats "安装ncdu" ;;
		  13)
			  clear; install fzf; cd /; clear; fzf; cd ~
			  send_stats "安装fzf" ;;
		  14)
			  clear; install ffmpeg; clear; ffmpeg --help
			  send_stats "安装ffmpeg" ;;
		  15)
			  clear; install vim; cd /; clear; vim -h; cd ~
			  send_stats "安装vim" ;;
		  16)
			  clear; install nano; cd /; clear; nano -h; cd ~
			  send_stats "安装nano" ;;
		  17)
			  clear; install git; cd /; clear; git --help; cd ~
			  send_stats "安装git" ;;
		  18)
			  clear; cd ~
			  curl -fsSL https://opencode.ai/install | bash
			  source ~/.bashrc 2>/dev/null
			  source ~/.profile 2>/dev/null
			  opencode
			  send_stats "安装opencode" ;;
		  19)
			  clear; cd ~
			  echo -e "${rw_lv}正在安装 brew...${rw_lv}"
			  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
			  if [ $? -eq 0 ]; then
				echo -e "${rw_lv}brew 安装成功${rw_lv}"
				echo -e "${rw_huang}提示: 请运行以下命令添加到环境变量:${rw_lv}"
				echo "  echo 'export PATH=/opt/homebrew/bin:$PATH' >> ~/.zshrc"
				echo "  source ~/.zshrc"
			  else
				echo -e "${rw_hong}brew 安装失败${rw_lv}"
			  fi
			  send_stats "安装brew" ;;
		  20)
			  clear; cd ~
			  echo -e "${rw_lv}正在安装 Node.js...${rw_lv}"
			  if command -v brew >/dev/null 2>&1; then
				brew install node
			  else
				curl -fsSL https://nodejs.org/dist/v20.10.0/node-v20.10.0-darwin-arm64.tar.gz | tar -xz -C ~/.local --strip-components=1
				echo 'export PATH=~/.local/bin:$PATH' >> ~/.zshrc
				source ~/.zshrc
			  fi
			  if command -v node >/dev/null 2>&1; then
				echo -e "${rw_lv}Node.js 安装成功${rw_lv}"
				node --version
				npm --version
			  else
				echo -e "${rw_hong}Node.js 安装失败${rw_lv}"
			  fi
			  send_stats "安装nodejs" ;;
		  21)
			  clear; cd ~
			  echo -e "${rw_lv}正在安装 pnpm...${rw_lv}"
			  if command -v npm >/dev/null 2>&1; then
				npm install -g pnpm
			  elif command -v brew >/dev/null 2>&1; then
				brew install pnpm
			  else
				curl -fsSL https://get.pnpm.io/install.sh | sh -
			  fi
			  if command -v pnpm >/dev/null 2>&1; then
				echo -e "${rw_lv}pnpm 安装成功${rw_lv}"
				pnpm --version
			  else
				echo -e "${rw_hong}pnpm 安装失败${rw_lv}"
			  fi
			  send_stats "安装pnpm" ;;

		  31)
			  clear
			  send_stats "全部安装"
			  install curl wget sudo socat htop iftop unzip tar tmux ffmpeg btop ranger ncdu fzf vim nano git
			  echo -e "${rw_lv}正在安装 brew...${rw_lv}"
			  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 2>/dev/null || true
			  echo -e "${rw_lv}正在安装 Node.js...${rw_lv}"
			  if command -v brew >/dev/null 2>&1; then
				brew install node 2>/dev/null || true
			  else
				curl -fsSL https://nodejs.org/dist/v20.10.0/node-v20.10.0-darwin-arm64.tar.gz | tar -xz -C ~/.local --strip-components=1 2>/dev/null || true
				echo 'export PATH=~/.local/bin:$PATH' >> ~/.zshrc 2>/dev/null || true
			  fi
			  echo -e "${rw_lv}正在安装 pnpm...${rw_lv}"
			  if command -v npm >/dev/null 2>&1; then
				npm install -g pnpm 2>/dev/null || true
			  elif command -v brew >/dev/null 2>&1; then
				brew install pnpm 2>/dev/null || true
			  else
				curl -fsSL https://get.pnpm.io/install.sh | sh - 2>/dev/null || true
			  fi
			  echo -e "${rw_lv}全部安装完成${rw_lv}" ;;

		  32)
			  clear
			  send_stats "全部卸载"
			  remove htop iftop tmux ffmpeg btop ranger ncdu fzf vim nano git
			  opencode uninstall 2>/dev/null || true
			  rm -rf ~/.opencode
			  ;;

		  33)
			  clear
			  echo -e "${rw_huang}──── 安装指定工具 ────${rw_lv}"
			  echo -e " ${rw_lv}提示: 多个工具用空格分隔，支持工具名或编号${rw_lv}"
			  echo -e " ${rw_huang}示例:${rw_lv}"
			  echo -e "   工具名: ${rw_lv}wget curl htop vim${rw_lv}"
			  echo -e "   编号:   ${rw_lv}1 2 5 15${rw_lv}"
			  echo ""
			  read -e -p " 请输入要安装的工具: " installname
			  [ -z "$installname" ] && { echo "已取消"; continue; }
			  install $installname
			  send_stats "安装指定软件" ;;

		  34)
			  clear
			  echo -e "${rw_huang}──── 卸载指定工具 ────${rw_lv}"
			  echo -e " ${rw_lv}提示: 多个工具用空格分隔，支持工具名或编号${rw_lv}"
			  echo -e " ${rw_huang}示例:${rw_lv}"
			  echo -e "   工具名: ${rw_lv}htop iftop btop ranger${rw_lv}"
			  echo -e "   编号:   ${rw_lv}5 6 7 11${rw_lv}"
			  echo ""
			  read -e -p " 请输入要卸载的工具: " removename
			  [ -z "$removename" ] && { echo "已取消"; continue; }
			  remove $removename
			  send_stats "卸载指定软件" ;;

		  35)
			  # ── 一键换源 LinuxMirrors（调用独立函数）──
			  linux_mirrors_switch
			  ;;

		  0)
			  riwi ;;
		  *)
			  echo "无效的输入!" ;;
	  esac
	  break_cancel
  done
}



docker_ssh_migration() {

	is_compose_container() {
		local container=$1
		docker inspect "$container" | jq -e '.[0].Config.Labels["com.docker.compose.project"]' >/dev/null 2>&1
	}

	list_backups() {
		local BACKUP_ROOT="/tmp"
		echo -e "${rw_huang}当前备份列表:${rw_lv}"
		ls -1dt ${BACKUP_ROOT}/docker_backup_* 2>/dev/null || echo "无备份"
	}



	# ----------------------------
	# 备份
	# ----------------------------
	backup_docker() {
		send_stats "Docker备份"

		echo -e "${rw_huang}正在备份 Docker 容器...${rw_lv}"
		docker ps --format '{{.Names}}'
		read -e -p  "请输入要备份的容器名（多个空格分隔，回车备份全部运行中容器）: " containers

		install tar jq gzip
		install_docker

		local BACKUP_ROOT="/tmp"
		local DATE_STR=$(date +%Y%m%d_%H%M%S)
		local TARGET_CONTAINERS=()
		if [ -z "$containers" ]; then
			mapfile -t TARGET_CONTAINERS < <(docker ps --format '{{.Names}}')
		else
			read -ra TARGET_CONTAINERS <<< "$containers"
		fi
		[[ ${#TARGET_CONTAINERS[@]} -eq 0 ]] && { echo -e "${rw_hong}没有找到容器${rw_lv}"; return; }

		local BACKUP_DIR="${BACKUP_ROOT}/docker_backup_${DATE_STR}"
		mkdir -p "$BACKUP_DIR"

		local RESTORE_SCRIPT="${BACKUP_DIR}/docker_restore.sh"
		echo "#!/bin/bash" > "$RESTORE_SCRIPT"
		echo "set -e" >> "$RESTORE_SCRIPT"
		echo "# 自动生成的还原脚本" >> "$RESTORE_SCRIPT"

		# 记录已打包过的 Compose 项目路径，避免重复打包
		declare -A PACKED_COMPOSE_PATHS=()

		for c in "${TARGET_CONTAINERS[@]}"; do
			echo -e "${rw_lv}备份容器: $c${rw_lv}"
			local inspect_file="${BACKUP_DIR}/${c}_inspect.json"
			docker inspect "$c" > "$inspect_file"

			if is_compose_container "$c"; then
				echo -e "${rw_huang}检测到 $c 是 docker-compose 容器${rw_lv}"
				local project_dir=$(docker inspect "$c" | jq -r '.[0].Config.Labels["com.docker.compose.project.working_dir"] // empty')
				local project_name=$(docker inspect "$c" | jq -r '.[0].Config.Labels["com.docker.compose.project"] // empty')

				if [ -z "$project_dir" ]; then
					read -e -p  "未检测到 compose 目录，请手动输入路径: " project_dir
				fi

				# 如果该 Compose 项目已经打包过，跳过
				if [[ -n "${PACKED_COMPOSE_PATHS[$project_dir]}" ]]; then
					echo -e "${rw_huang}Compose 项目 [$project_name] 已备份过，跳过重复打包...${rw_lv}"
					continue
				fi

				if [ -f "$project_dir/docker-compose.yml" ]; then
					echo "compose" > "${BACKUP_DIR}/backup_type_${project_name}"
					echo "$project_dir" > "${BACKUP_DIR}/compose_path_${project_name}.txt"
					tar -czf "${BACKUP_DIR}/compose_project_${project_name}.tar.gz" -C "$project_dir" .
					echo "# docker-compose 恢复: $project_name" >> "$RESTORE_SCRIPT"
					echo "cd \"$project_dir\" && docker compose up -d" >> "$RESTORE_SCRIPT"
					PACKED_COMPOSE_PATHS["$project_dir"]=1
					echo -e "${rw_lv}Compose 项目 [$project_name] 已打包: ${project_dir}${rw_lv}"
				else
					echo -e "${rw_hong}未找到 docker-compose.yml，跳过此容器...${rw_lv}"
				fi
			else
				# 普通容器备份卷
				local VOL_PATHS
				VOL_PATHS=$(docker inspect "$c" --format '{{range .Mounts}}{{.Source}} {{end}}')
				for path in $VOL_PATHS; do
					echo "打包卷: $path"
					tar -czpf "${BACKUP_DIR}/${c}_$(basename $path).tar.gz" -C / "$(echo $path | sed 's/^\///')"
				done

				# 端口
				local PORT_ARGS=""
				mapfile -t PORTS < <(jq -r '.[0].HostConfig.PortBindings | to_entries[] | "\(.value[0].HostPort):\(.key | split("/")[0])"' "$inspect_file" 2>/dev/null)
				for p in "${PORTS[@]}"; do PORT_ARGS+="-p $p "; done

				# 环境变量
				local ENV_VARS=""
				mapfile -t ENVS < <(jq -r '.[0].Config.Env[] | @sh' "$inspect_file")
				for e in "${ENVS[@]}"; do ENV_VARS+="-e $e "; done

				# 卷映射
				local VOL_ARGS=""
				for path in $VOL_PATHS; do VOL_ARGS+="-v $path:$path "; done

				# 镜像
				local IMAGE
				IMAGE=$(jq -r '.[0].Config.Image' "$inspect_file")

				echo -e "\n# 还原容器: $c" >> "$RESTORE_SCRIPT"
				echo "docker run -d --name $c $PORT_ARGS $VOL_ARGS $ENV_VARS $IMAGE" >> "$RESTORE_SCRIPT"
			fi
		done


		# 备份 /home/docker 下的所有文件（不含子目录）
		if [ -d "/home/docker" ]; then
			echo -e "${rw_huang}备份 /home/docker 下的文件...${rw_lv}"
			find /home/docker -maxdepth 1 -type f | tar -czf "${BACKUP_DIR}/home_docker_files.tar.gz" -T -
			echo -e "${rw_lv}/home/docker 下的文件已打包到: ${BACKUP_DIR}/home_docker_files.tar.gz${rw_lv}"
		fi

		chmod +x "$RESTORE_SCRIPT"
		echo -e "${rw_lv}备份完成: ${BACKUP_DIR}${rw_lv}"
		echo -e "${rw_lv}可用还原脚本: ${RESTORE_SCRIPT}${rw_lv}"


	}

	# ----------------------------
	# 还原
	# ----------------------------
	restore_docker() {

		send_stats "Docker还原"
		read -e -p  "请输入要还原的备份目录: " BACKUP_DIR
		[[ ! -d "$BACKUP_DIR" ]] && { echo -e "${rw_hong}备份目录不存在${rw_lv}"; return; }

		echo -e "${rw_huang}开始执行还原操作...${rw_lv}"

		install tar jq gzip
		install_docker

		# --------- 优先还原 Compose 项目 ---------
		for f in "$BACKUP_DIR"/backup_type_*; do
			[[ ! -f "$f" ]] && continue
			if grep -q "compose" "$f"; then
				project_name=$(basename "$f" | sed 's/backup_type_//')
				path_file="$BACKUP_DIR/compose_path_${project_name}.txt"
				[[ -f "$path_file" ]] && original_path=$(cat "$path_file") || original_path=""
				[[ -z "$original_path" ]] && read -e -p  "未找到原始路径，请输入还原目录路径: " original_path

				# 检查该 compose 项目的容器是否已经在运行
				running_count=$(docker ps --filter "label=com.docker.compose.project=$project_name" --format '{{.Names}}' | wc -l)
				if [[ "$running_count" -gt 0 ]]; then
					echo -e "${rw_huang}Compose 项目 [$project_name] 已有容器在运行，跳过还原...${rw_lv}"
					continue
				fi

				read -e -p  "确认还原 Compose 项目 [$project_name] 到路径 [$original_path] ? (y/n): " confirm
				[[ "$confirm" != "y" ]] && read -e -p  "请输入新的还原路径: " original_path

				mkdir -p "$original_path"
				tar -xzf "$BACKUP_DIR/compose_project_${project_name}.tar.gz" -C "$original_path"
				echo -e "${rw_lv}Compose 项目 [$project_name] 已解压到: $original_path${rw_lv}"

				cd "$original_path" || return
				docker compose down || true
				docker compose up -d
				echo -e "${rw_lv}Compose 项目 [$project_name] 还原完成！${rw_lv}"
			fi
		done

		# --------- 继续还原普通容器 ---------
		echo -e "${rw_huang}检查并还原普通 Docker 容器...${rw_lv}"
		local has_container=false
		for json in "$BACKUP_DIR"/*_inspect.json; do
			[[ ! -f "$json" ]] && continue
			has_container=true
			container=$(basename "$json" | sed 's/_inspect.json//')
			echo -e "${rw_lv}处理容器: $container${rw_lv}"

			# 检查容器是否已经存在且正在运行
			if docker ps --format '{{.Names}}' | grep -q "^${container}$"; then
				echo -e "${rw_huang}容器 [$container] 已在运行，跳过还原...${rw_lv}"
				continue
			fi

			IMAGE=$(jq -r '.[0].Config.Image' "$json")
			[[ -z "$IMAGE" || "$IMAGE" == "null" ]] && { echo -e "${rw_hong}未找到镜像信息，跳过: $container${rw_lv}"; continue; }

			# 端口映射
			PORT_ARGS=""
			mapfile -t PORTS < <(jq -r '.[0].HostConfig.PortBindings | to_entries[]? | "\(.value[0].HostPort):\(.key | split("/")[0])"' "$json")
			for p in "${PORTS[@]}"; do
				[[ -n "$p" ]] && PORT_ARGS="$PORT_ARGS -p $p"
			done

			# 环境变量
			ENV_ARGS=""
			mapfile -t ENVS < <(jq -r '.[0].Config.Env[]' "$json")
			for e in "${ENVS[@]}"; do
				ENV_ARGS="$ENV_ARGS -e \"$e\""
			done

			# 卷映射 + 卷数据恢复
			VOL_ARGS=""
			mapfile -t VOLS < <(jq -r '.[0].Mounts[] | "\(.Source):\(.Destination)"' "$json")
			for v in "${VOLS[@]}"; do
				VOL_SRC=$(echo "$v" | cut -d':' -f1)
				VOL_DST=$(echo "$v" | cut -d':' -f2)
				mkdir -p "$VOL_SRC"
				VOL_ARGS="$VOL_ARGS -v $VOL_SRC:$VOL_DST"

				VOL_FILE="$BACKUP_DIR/${container}_$(basename $VOL_SRC).tar.gz"
				if [[ -f "$VOL_FILE" ]]; then
					echo "恢复卷数据: $VOL_SRC"
					tar -xzf "$VOL_FILE" -C /
				fi
			done

			# 删除已存在但未运行的容器
			if docker ps -a --format '{{.Names}}' | grep -q "^${container}$"; then
				echo -e "${rw_huang}容器 [$container] 存在但未运行，删除旧容器...${rw_lv}"
				docker rm -f "$container"
			fi

			# 启动容器
			echo "执行还原命令: docker run -d --name \"$container\" $PORT_ARGS $VOL_ARGS $ENV_ARGS \"$IMAGE\""
			eval "docker run -d --name \"$container\" $PORT_ARGS $VOL_ARGS $ENV_ARGS \"$IMAGE\""
		done

		[[ "$has_container" == false ]] && echo -e "${rw_huang}未找到普通容器的备份信息${rw_lv}"

		# 还原 /home/docker 下的文件
		if [ -f "$BACKUP_DIR/home_docker_files.tar.gz" ]; then
			echo -e "${rw_huang}正在还原 /home/docker 下的文件...${rw_lv}"
			mkdir -p /home/docker
			tar -xzf "$BACKUP_DIR/home_docker_files.tar.gz" -C /
			echo -e "${rw_lv}/home/docker 下的文件已还原完成${rw_lv}"
		else
			echo -e "${rw_huang}未找到 /home/docker 下文件的备份，跳过...${rw_lv}"
		fi


	}


	# ----------------------------
	# 迁移
	# ----------------------------
	migrate_docker() {
		send_stats "Docker迁移"
		install jq
		read -e -p  "请输入要迁移的备份目录: " BACKUP_DIR
		[[ ! -d "$BACKUP_DIR" ]] && { echo -e "${rw_hong}备份目录不存在${rw_lv}"; return; }

		kj_ssh_read_host_user_port "目标服务器IP: " "目标服务器SSH用户名 [默认root]: " "目标服务器SSH端口 [默认22]: " "root" "22"
		local TARGET_IP="$KJ_SSH_HOST"
		local TARGET_USER="$KJ_SSH_USER"
		local TARGET_PORT="$KJ_SSH_PORT"

		local LATEST_TAR="$BACKUP_DIR"

		echo -e "${rw_huang}传输备份中...${rw_lv}"
		if [[ -z "$TARGET_PASS" ]]; then
			# 使用密钥登录
			scp -P "$TARGET_PORT" -o StrictHostKeyChecking=no -r "$LATEST_TAR" "$TARGET_USER@$TARGET_IP:/tmp/"
		fi

	}

	# ----------------------------
	# 删除备份
	# ----------------------------
	delete_backup() {
		send_stats "Docker备份文件删除"
		read -e -p  "请输入要删除的备份目录: " BACKUP_DIR
		[[ ! -d "$BACKUP_DIR" ]] && { echo -e "${rw_hong}备份目录不存在${rw_lv}"; return; }
		rm -rf "$BACKUP_DIR"
		echo -e "${rw_lv}已删除备份: ${BACKUP_DIR}${rw_lv}"
	}

	# ----------------------------
	# 主菜单
	# ----------------------------
	main_menu() {
		send_stats "Docker备份迁移还原"
		while true; do
			clear
			echo -e "${rw_cheng}------------------------${rw_lv}"
			echo -e "Docker备份/迁移/还原工具"
			echo -e "${rw_cheng}------------------------${rw_lv}"
			list_backups
			echo -e ""
			echo -e "${rw_cheng}------------------------${rw_lv}"
			echo -e "1. 备份docker项目"
			echo -e "2. 迁移docker项目"
			echo -e "3. 还原docker项目"
			echo -e "4. 删除docker项目的备份文件"
			echo -e "${rw_cheng}------------------------${rw_lv}"
			echo -e "0. 返回上一级选单"
			echo -e "${rw_cheng}------------------------${rw_lv}"
			read -e -p  "请选择: " choice
			case $choice in
				1) backup_docker ;;
				2) migrate_docker ;;
				3) restore_docker ;;
				4) delete_backup ;;
				0) return ;;
				*) echo -e "${rw_hong}无效选项${rw_lv}" ;;
			esac
		break_end
		done
	}

	main_menu
}










docker_tato() {

	local container_count=$(docker ps -a -q 2>/dev/null | wc -l)
	local image_count=$(docker images -q 2>/dev/null | wc -l)
	local network_count=$(docker network ls -q 2>/dev/null | wc -l)
	local volume_count=$(docker volume ls -q 2>/dev/null | wc -l)

	if command -v docker &> /dev/null; then
		echo -e "${rw_lv}------------------------"
		echo -e "${rw_lv}环境已经安装${rw_lv}  容器: ${rw_lv}$container_count${rw_lv}  镜像: ${rw_lv}$image_count${rw_lv}  网络: ${rw_lv}$network_count${rw_lv}  卷: ${rw_lv}$volume_count${rw_lv}"
	fi
}



ldnmp_tato() {
local cert_count=$(ls /home/web/certs/*_cert.pem 2>/dev/null | wc -l)
local output="${rw_lv}${cert_count}${rw_lv}"

local dbrootpasswd=$(sed -n -E 's/.*MYSQL_ROOT_PASSWORD:[[:space:]]*(.*)/\1/p' /home/web/docker-compose.yml 2>/dev/null | tr -d '[:space:]')
if [ -n "$dbrootpasswd" ]; then
	local db_count=$(docker exec mysql mysql -u root -p"$dbrootpasswd" -e "SHOW DATABASES;" 2>/dev/null | grep -Ev "Database|information_schema|mysql|performance_schema|sys" | wc -l)
fi

local db_output="${rw_lv}${db_count}${rw_lv}"


if command -v docker &>/dev/null; then
	if docker ps --filter "name=nginx" --filter "status=running" | grep -q nginx; then
		echo -e "${rw_huang}------------------------"
		echo -e "${rw_lv}环境已安装${rw_lv}  站点: $output  数据库: $db_output"
	fi
fi

}


fix_phpfpm_conf() {
	local container_name=$1
	docker exec "$container_name" sh -c "mkdir -p /run/$container_name && chmod 777 /run/$container_name"
	docker exec "$container_name" sh -c "sed -i '1i [global]\\ndaemonize = no' /usr/local/etc/php-fpm.d/www.conf"
	docker exec "$container_name" sh -c "sed -i '/^listen =/d' /usr/local/etc/php-fpm.d/www.conf"
	docker exec "$container_name" sh -c "echo -e '\nlisten = /run/$container_name/php-fpm.sock\nlisten.owner = www-data\nlisten.group = www-data\nlisten.mode = 0777' >> /usr/local/etc/php-fpm.d/www.conf"
	docker exec "$container_name" sh -c "rm -f /usr/local/etc/php-fpm.d/zz-docker.conf"

	find /home/web/conf.d/ -type f -name "*.conf" -exec sed -i "s#fastcgi_pass ${container_name}:9000;#fastcgi_pass unix:/run/${container_name}/php-fpm.sock;#g" {} \;

}










# ================================================================
# LDNMP建站管理器
# ================================================================

ldnmp_builder_menu() {
  while true; do
    clear
    send_stats "LDNMP建站"

    if _should_refresh_cache; then
        refresh_status_cache
    fi

    local _nginx_stat="${rw_hong}未运行${rw_lv}"
    local _mysql_stat="${rw_hong}未运行${rw_lv}"
    local _php_stat="${rw_hong}未运行${rw_lv}"
    local _site_cnt=0
    local _ssl_cnt=0

    if docker inspect nginx &>/dev/null 2>&1; then
        docker inspect -f '{{.State.Running}}' nginx 2>/dev/null | grep -q true && _nginx_stat="${rw_lv}运行中${rw_lv}" || _nginx_stat="${rw_huang}已停止${rw_lv}"
    elif $_CACHE_NGINX_ACTIVE; then
        _nginx_stat="${rw_lv}运行中${rw_lv}"
    fi

    if docker inspect mysql &>/dev/null 2>&1 || docker inspect mariadb &>/dev/null 2>&1; then
        if docker inspect -f '{{.State.Running}}' mysql 2>/dev/null | grep -q true 2>/dev/null; then
            _mysql_stat="${rw_lv}运行中${rw_lv}"
        elif docker inspect -f '{{.State.Running}}' mariadb 2>/dev/null | grep -q true 2>/dev/null; then
            _mysql_stat="${rw_lv}运行中${rw_lv}"
        else
            _mysql_stat="${rw_huang}已停止${rw_lv}"
        fi
    elif $_CACHE_MYSQL_ACTIVE; then
        _mysql_stat="${rw_lv}运行中${rw_lv}"
    fi

    if docker inspect php &>/dev/null 2>&1 || docker inspect php-fpm &>/dev/null 2>&1; then
        if docker inspect -f '{{.State.Running}}' php 2>/dev/null | grep -q true 2>/dev/null; then
            _php_stat="${rw_lv}运行中${rw_lv}"
        elif docker inspect -f '{{.State.Running}}' php-fpm 2>/dev/null | grep -q true 2>/dev/null; then
            _php_stat="${rw_lv}运行中${rw_lv}"
        else
            _php_stat="${rw_huang}已停止${rw_lv}"
        fi
    elif $_CACHE_PHP_ACTIVE; then
        _php_stat="${rw_lv}运行中${rw_lv}"
    fi

    [ -d /home/web/conf.d ] && _site_cnt=$(ls /home/web/conf.d/*.conf 2>/dev/null | grep -vc 'map\|default')
    [ -d /etc/letsencrypt/live ] && _ssl_cnt=$(ls -d /etc/letsencrypt/live/*/ 2>/dev/null | wc -l)

    echo -e "${rw_cheng}━━━━━━━━━━━━  建站部署  ━━━━━━━━━━━━${rw_lv}"
    echo -e " Nginx ${_nginx_stat}  MySQL ${_mysql_stat}  PHP ${_php_stat}"
    echo -e " 站点 ${rw_lv}${_site_cnt}${rw_lv} 个  SSL证书 ${rw_lv}${_ssl_cnt}${rw_lv} 个"
    echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
    echo ""
    echo -e " ${rw_cheng}──── 快速开始${rw_lv}"
    echo -e "  ${rw_huang}1${rw_lv}  一键建站向导（新手推荐）"
    echo ""
    echo -e " ${rw_cheng}──── 环境安装${rw_lv}"
    echo -e "  ${rw_huang}2${rw_lv}  安装LDNMP环境        ${rw_huang}3${rw_lv}  仅安装Nginx"
    echo ""
    echo -e " ${rw_cheng}──── 站点管理${rw_lv}"
    echo -e "  ${rw_huang}4${rw_lv}  站点管理（列表/创建/删除/备份/还原）"
    echo -e "  ${rw_huang}5${rw_lv}  反向代理与重定向"
    echo -e "  ${rw_huang}6${rw_lv}  SSL证书管理"
    echo ""
    echo -e " ${rw_cheng}──── 组件管理${rw_lv}"
    echo -e "  ${rw_huang}7${rw_lv}  组件管理（Nginx / MySQL / PHP）"
    echo ""
    echo -e " ${rw_cheng}──── 运维${rw_lv}"
    echo -e "  ${rw_huang}8${rw_lv}  环境优化与安全防护"
    echo -e "  ${rw_huang}9${rw_lv}  定时远程备份        ${rw_huang}10${rw_lv} 更新LDNMP环境"
    echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
    echo -e "  ${rw_huang}0${rw_lv}  返回主菜单"
    echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
    read -e -p " 请选择: " choice < /dev/tty
    choice=${choice:-0}

    case $choice in
      1) ldnmp_quick_wizard ;;
      2) ldnmp_install_env ;;
      3) ldnmp_install_nginx_only ;;
      4) ldnmp_site_manager ;;
      5) ldnmp_proxy_manager ;;
      6) ldnmp_ssl_manager ;;
      7) ldnmp_components_manager ;;
      8) ldnmp_optimize_protect ;;
      9) ldnmp_scheduled_backup ;;
      10) ldnmp_update_env ;;
      0) break ;;
      *) echo -e "${rw_hong}无效的输入!${rw_lv}" ;;
    esac
    break_cancel
  done
}


# ================================================================
# 一键建站向导 (2026-06-26 新增)
# ================================================================
ldnmp_quick_wizard() {
  clear
  send_stats "一键建站向导"
  echo -e "${rw_cheng}━━━━━━━━━━━━  一键建站向导  ━━━━━━━━━━━━${rw_lv}"
  echo -e " ${rw_huang}本向导将引导你完成建站全流程${rw_lv}"
  echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
  echo ""
  echo -e " 流程预览:"
  echo -e "  ${rw_huang}1${rw_lv}. 检查/安装 LDNMP 环境"
  echo -e "  ${rw_huang}2${rw_lv}. 输入域名（需已解析到本机IP）"
  echo -e "  ${rw_huang}3${rw_lv}. 选择站点类型"
  echo -e "  ${rw_huang}4${rw_lv}. 自动创建数据库 + 申请 SSL 证书"
  echo -e "  ${rw_huang}5${rw_lv}. 显示访问地址和管理信息"
  echo ""
  read -e -p " 是否开始？(y/N): " _wizard_start < /dev/tty
  if ! [[ "$_wizard_start" =~ ^[Yy]$ ]]; then
    echo -e " ${rw_huang}已取消${rw_lv}"
    return
  fi

  echo ""
  echo -e "${rw_cheng}── 步骤 1/5: 检查 LDNMP 环境 ──${rw_lv}"
  if docker inspect php &>/dev/null 2>&1; then
    echo -e " ${rw_lv}✓ LDNMP 环境已安装${rw_lv}"
  else
    echo -e " ${rw_huang}LDNMP 环境未安装，开始安装...${rw_lv}"
    ldnmp_install_all
    if ! docker inspect php &>/dev/null 2>&1; then
      echo -e " ${rw_hong}环境安装失败，向导终止${rw_lv}"
      read -e -p " 按回车返回: " < /dev/tty
      return
    fi
  fi

  echo ""
  echo -e "${rw_cheng}── 步骤 2/5: 输入域名 ──${rw_lv}"
  echo -e " ${rw_huang}注意: 域名需已解析到本机IP，否则SSL申请会失败${rw_lv}"
  add_yuming
  if [ -z "$yuming" ]; then
    echo -e " ${rw_huang}未输入域名，向导终止${rw_lv}"
    return
  fi
  repeat_add_yuming

  echo ""
  echo -e "${rw_cheng}── 步骤 3/5: 选择站点类型 ──${rw_lv}"
  echo -e "  ${rw_huang}1${rw_lv}  WordPress（功能丰富的博客/CMS）"
  echo -e "  ${rw_huang}2${rw_lv}  Typecho（轻量博客）"
  echo -e "  ${rw_huang}3${rw_lv}  自定义静态站点"
  read -e -p " 请选择（默认1）: " _site_type < /dev/tty
  _site_type="${_site_type:-1}"

  echo ""
  echo -e "${rw_cheng}── 步骤 4/5: 创建站点 + 数据库 + SSL ──${rw_lv}"
  case $_site_type in
    1) echo -e " ${rw_huang}正在部署 WordPress...${rw_lv}"; ldnmp_wp ;;
    2) echo -e " ${rw_huang}正在部署 Typecho...${rw_lv}"; ldnmp_install_typecho ;;
    3) echo -e " ${rw_huang}正在创建静态站点...${rw_lv}"; ldnmp_custom_static ;;
    *) echo -e " ${rw_hong}无效选择${rw_lv}"; return ;;
  esac

  echo ""
  echo -e "${rw_cheng}── 步骤 5/5: 建站完成 ──${rw_lv}"
  echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
  echo -e " ${rw_lv}✓ 站点已创建${rw_lv}"
  echo -e " 访问地址: ${rw_huang}https://${yuming}${rw_lv}"
  echo -e " 网站根目录: ${rw_huang}/home/web/html/${yuming}${rw_lv}"
  echo -e " Nginx配置: ${rw_huang}/home/web/conf.d/${yuming}.conf${rw_lv}"
  echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
  read -e -p " 按回车返回菜单: " < /dev/tty
}


# ================================================================
# 站点管理子菜单 (2026-06-26 新增，整合原 7/12/13 选项)
# ================================================================
ldnmp_site_manager() {
  while true; do
    clear
    send_stats "站点管理"

    local _site_list=""
    local _site_total=0
    if [ -d /home/web/conf.d ]; then
      for conf in /home/web/conf.d/*.conf; do
        [ -f "$conf" ] || continue
        local _sname=$(basename "$conf" .conf)
        [ "$_sname" = "map" ] && continue
        [ "$_sname" = "default" ] && continue
        _site_total=$((_site_total + 1))
        local _ssl_mark="${rw_hong}无SSL${rw_lv}"
        [ -d "/etc/letsencrypt/live/${_sname}" ] && _ssl_mark="${rw_lv}有SSL${rw_lv}"
        local _type="未知"
        if [ -f "/home/web/html/${_sname}/wordpress/wp-config.php" ]; then
          _type="WordPress"
        elif [ -f "/home/web/html/${_sname}/index.php" ]; then
          _type="PHP"
        elif [ -f "/home/web/html/${_sname}/index.html" ]; then
          _type="静态"
        elif grep -q "proxy_pass" "$conf" 2>/dev/null; then
          _type="反代"
        elif grep -q "upstream" "$conf" 2>/dev/null; then
          _type="负载均衡"
        elif grep -q "return 30" "$conf" 2>/dev/null; then
          _type="重定向"
        fi
        _site_list+="  ${rw_huang}$(printf '%-2d' $_site_total)${rw_lv}  $(printf '%-30s' "$_sname")  $(printf '%-8s' "$_type")  $_ssl_mark\n"
      done
    fi

    echo -e "${rw_cheng}━━━━━━━━━━━━  站点管理  ━━━━━━━━━━━━${rw_lv}"
    echo -e " 共 ${rw_lv}${_site_total}${rw_lv} 个站点"
    echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
    if [ -n "$_site_list" ]; then
      echo -e " 编号  域名                            类型      SSL"
      echo -e "$_site_list"
    else
      echo -e "  ${rw_huang}暂无站点，请先创建${rw_lv}"
      echo ""
    fi
    echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
    echo -e "  ${rw_huang}1${rw_lv}  创建新站点            ${rw_huang}2${rw_lv}  查看站点配置"
    echo -e "  ${rw_huang}3${rw_lv}  删除站点              ${rw_huang}4${rw_lv}  备份站点"
    echo -e "  ${rw_huang}5${rw_lv}  还原全站数据"
    echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
    echo -e "  ${rw_huang}0${rw_lv}  返回上级菜单"
    echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
    read -e -p " 请选择: " _sm_choice < /dev/tty
    _sm_choice=${_sm_choice:-0}

    case $_sm_choice in
      1)
        clear
        echo -e "${rw_cheng}━━━━ 创建新站点 ━━━━${rw_lv}"
        echo -e "  ${rw_huang}1${rw_lv}  WordPress"
        echo -e "  ${rw_huang}2${rw_lv}  Typecho"
        echo -e "  ${rw_huang}3${rw_lv}  自定义静态站点"
        echo -e "  ${rw_huang}0${rw_lv}  取消"
        read -e -p " 请选择类型: " _new_type < /dev/tty
        case $_new_type in
          1) ldnmp_wp ;;
          2) ldnmp_install_typecho ;;
          3) ldnmp_custom_static ;;
          0) continue ;;
          *) echo -e "${rw_hong}无效选择${rw_lv}" ;;
        esac
        ;;
      2)
        if [ "$_site_total" -eq 0 ]; then
          echo -e " ${rw_huang}暂无站点${rw_lv}"
          sleep 1; continue
        fi
        echo ""
        read -e -p " 请输入站点编号（从上方列表）: " _view_idx < /dev/tty
        local _cur=0 _target=""
        for conf in /home/web/conf.d/*.conf; do
          [ -f "$conf" ] || continue
          local _sname=$(basename "$conf" .conf)
          [ "$_sname" = "map" ] && continue
          [ "$_sname" = "default" ] && continue
          _cur=$((_cur + 1))
          [ "$_cur" = "$_view_idx" ] && _target="$_sname" && break
        done
        if [ -n "$_target" ] && [ -f "/home/web/conf.d/${_target}.conf" ]; then
          clear
          echo -e "${rw_cheng}━━━━ ${_target} 配置 ━━━━${rw_lv}"
          cat "/home/web/conf.d/${_target}.conf"
          echo -e "${rw_cheng}────────────────────${rw_lv}"
          read -e -p " 按回车继续: " < /dev/tty
        else
          echo -e " ${rw_hong}无效编号${rw_lv}"
          sleep 1
        fi
        ;;
      3) web_del ;;
      4)
        clear
        echo -e "${rw_cheng}━━━━ 备份站点 ━━━━${rw_lv}"
        echo -e "  ${rw_huang}1${rw_lv}  备份指定站点"
        echo -e "  ${rw_huang}2${rw_lv}  备份所有站点"
        echo -e "  ${rw_huang}0${rw_lv}  取消"
        read -e -p " 请选择: " _bk_type < /dev/tty
        case $_bk_type in
          1)
            read -e -p " 请输入要备份的域名: " _bk_domain < /dev/tty
            if [ -n "$_bk_domain" ]; then
              local _bk_path="/home/web_backup_$(date +%Y%m%d_%H%M%S)"
              mkdir -p "$_bk_path/conf.d" "$_bk_path/html"
              cp "/home/web/conf.d/${_bk_domain}.conf" "$_bk_path/conf.d/" 2>/dev/null
              cp -r "/home/web/html/${_bk_domain}" "$_bk_path/html/" 2>/dev/null
              echo -e " ${rw_lv}✓ 已备份到 $_bk_path${rw_lv}"
            fi
            ;;
          2)
            local _bk_path="/home/web_backup_$(date +%Y%m%d_%H%M%S)"
            cp -r /home/web "$_bk_path" 2>/dev/null
            echo -e " ${rw_lv}✓ 全站已备份到 $_bk_path${rw_lv}"
            ;;
        esac
        sleep 1
        ;;
      5) ldnmp_restore_full ;;
      0) break ;;
      *) echo -e "${rw_hong}无效选择${rw_lv}" ;;
    esac
    break_cancel
  done
}


# ================================================================
# 反向代理与重定向子菜单 (2026-06-26 新增，合并原 13/14/15/16/17)
# ================================================================
ldnmp_proxy_manager() {
  while true; do
    clear
    send_stats "反向代理与重定向"

    echo -e "${rw_cheng}━━━━━━━━━━━━  反向代理与重定向  ━━━━━━━━━━━━${rw_lv}"
    echo ""
    echo -e " ${rw_cheng}── 反向代理${rw_lv}"
    echo -e "  ${rw_huang}1${rw_lv}  反代到 IP:端口       ${rw_huang}2${rw_lv}  反代到域名"
    echo -e "  ${rw_huang}3${rw_lv}  负载均衡（多后端）"
    echo ""
    echo -e " ${rw_cheng}── 重定向${rw_lv}"
    echo -e "  ${rw_huang}4${rw_lv}  站点重定向（301/302）"
    echo ""
    echo -e " ${rw_cheng}── 高级${rw_lv}"
    echo -e "  ${rw_huang}5${rw_lv}  4层负载均衡（TCP/UDP）"
    echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
    echo -e "  ${rw_huang}0${rw_lv}  返回上级菜单"
    echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
    read -e -p " 请选择: " _pm_choice < /dev/tty
    _pm_choice=${_pm_choice:-0}

    case $_pm_choice in
      1) ldnmp_proxy_ip_port ;;
      2) ldnmp_proxy_domain ;;
      3) ldnmp_proxy_load_balance ;;
      4) ldnmp_site_redirect ;;
      5) ldnmp_Proxy_backend_stream ;;
      0) break ;;
      *) echo -e "${rw_hong}无效选择${rw_lv}" ;;
    esac
    break_cancel
  done
}


# ================================================================
# SSL 证书管理子菜单 (2026-06-26 新增)
# ================================================================
ldnmp_ssl_manager() {
  while true; do
    clear
    send_stats "SSL证书管理"

    local _cert_total=0
    local _cert_list=""
    if [ -d /etc/letsencrypt/live ]; then
      for cert_dir in /etc/letsencrypt/live/*/; do
        [ -d "$cert_dir" ] || continue
        local _domain=$(basename "$cert_dir")
        local _cert_file="${cert_dir}fullchain.pem"
        local _expire="" _days_left="" _status=""
        if [ -f "$_cert_file" ]; then
          _cert_total=$((_cert_total + 1))
          local _expire_date=$(openssl x509 -noout -enddate -in "$_cert_file" 2>/dev/null | awk -F'=' '{print $2}')
          _expire=$(portable_date "$_expire_date" '+%Y-%m-%d' 2>/dev/null || echo "?")
          if [ -n "$_expire_date" ]; then
            local _expire_epoch=$(portable_date "$_expire_date" '+%s' 2>/dev/null)
            local _now_epoch=$(date '+%s')
            _days_left=$(( ( _expire_epoch - _now_epoch ) / 86400 ))
            if [ "$_days_left" -lt 0 ]; then
              _status="${rw_hong}已过期${rw_lv}"
            elif [ "$_days_left" -lt 7 ]; then
              _status="${rw_hong}即将过期(${_days_left}天)${rw_lv}"
            elif [ "$_days_left" -lt 30 ]; then
              _status="${rw_huang}剩余${_days_left}天${rw_lv}"
            else
              _status="${rw_lv}剩余${_days_left}天${rw_lv}"
            fi
          fi
          _cert_list+="  ${rw_huang}$(printf '%-2d' $_cert_total)${rw_lv}  $(printf '%-30s' "$_domain")  $_expire  $_status\n"
        fi
      done
    fi

    echo -e "${rw_cheng}━━━━━━━━━━━━  SSL 证书管理  ━━━━━━━━━━━━${rw_lv}"
    echo -e " 共 ${rw_lv}${_cert_total}${rw_lv} 个证书"
    echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
    if [ -n "$_cert_list" ]; then
      echo -e " 编号  域名                            到期时间    状态"
      echo -e "$_cert_list"
    else
      echo -e "  ${rw_huang}暂无证书${rw_lv}"
    fi
    echo ""
    echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
    echo -e "  ${rw_huang}1${rw_lv}  申请SSL证书          ${rw_huang}2${rw_lv}  查看证书详情"
    echo -e "  ${rw_huang}3${rw_lv}  删除SSL证书          ${rw_huang}4${rw_lv}  手动续签所有证书"
    echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
    echo -e "  ${rw_huang}0${rw_lv}  返回上级菜单"
    echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
    read -e -p " 请选择: " _ssl_choice < /dev/tty
    _ssl_choice=${_ssl_choice:-0}

    case $_ssl_choice in
      1)
        clear
        echo -e "${rw_cheng}━━━━ 申请 SSL 证书 ━━━━${rw_lv}"
        echo -e " ${rw_huang}注意: 域名需已解析到本机IP且80端口可访问${rw_lv}"
        echo ""
        add_ssl
        ;;
      2)
        if [ "$_cert_total" -eq 0 ]; then
          echo -e " ${rw_huang}暂无证书${rw_lv}"
          sleep 1; continue
        fi
        echo ""
        read -e -p " 请输入证书编号: " _cert_idx < /dev/tty
        local _cur=0 _target=""
        for cert_dir in /etc/letsencrypt/live/*/; do
          [ -d "$cert_dir" ] || continue
          _cur=$((_cur + 1))
          [ "$_cur" = "$_cert_idx" ] && _target=$(basename "$cert_dir") && break
        done
        if [ -n "$_target" ]; then
          clear
          echo -e "${rw_cheng}━━━━ 证书: $_target ━━━━${rw_lv}"
          openssl x509 -in "/etc/letsencrypt/live/${_target}/fullchain.pem" -noout -subject -issuer -dates -ext subjectAltName 2>/dev/null
          echo -e "${rw_cheng}────────────────────${rw_lv}"
          read -e -p " 按回车继续: " < /dev/tty
        else
          echo -e " ${rw_hong}无效编号${rw_lv}"
          sleep 1
        fi
        ;;
      3)
        if [ "$_cert_total" -eq 0 ]; then
          echo -e " ${rw_huang}暂无证书${rw_lv}"
          sleep 1; continue
        fi
        echo ""
        read -e -p " 请输入要删除的证书域名: " _del_domain < /dev/tty
        if [ -n "$_del_domain" ] && [ -d "/etc/letsencrypt/live/${_del_domain}" ]; then
          read -e -p " $(echo -e "${rw_hong}确认删除 ${_del_domain} 的证书？(y/N): ${rw_lv}")" _del_confirm < /dev/tty
          if [[ "$_del_confirm" =~ ^[Yy]$ ]]; then
            docker run --rm -v /etc/letsencrypt/:/etc/letsencrypt certbot/certbot delete --cert-name "$_del_domain" -n 2>/dev/null
            echo -e " ${rw_lv}✓ 证书已删除${rw_lv}"
          fi
        else
          echo -e " ${rw_hong}证书不存在${rw_lv}"
        fi
        sleep 1
        ;;
      4)
        clear
        echo -e "${rw_cheng}━━━━ 手动续签所有证书 ━━━━${rw_lv}"
        echo -e " ${rw_huang}正在续签...${rw_lv}"
        docker run --rm -v /etc/letsencrypt/:/etc/letsencrypt certbot/certbot renew 2>/dev/null
        echo -e " ${rw_lv}✓ 续签完成${rw_lv}"
        if docker inspect nginx &>/dev/null 2>&1; then
          docker exec nginx nginx -s reload 2>/dev/null
          echo -e " ${rw_lv}Nginx 已重载${rw_lv}"
        fi
        read -e -p " 按回车继续: " < /dev/tty
        ;;
      0) break ;;
      *) echo -e "${rw_hong}无效选择${rw_lv}" ;;
    esac
    break_cancel
  done
}


# ================================================================
# 组件管理子菜单 (2026-06-26 新增，整合原 4/5/6 选项)
# ================================================================
ldnmp_components_manager() {
  while true; do
    clear
    send_stats "组件管理"

    echo -e "${rw_cheng}━━━━━━━━━━━━  组件管理  ━━━━━━━━━━━━${rw_lv}"
    echo ""
    echo -e "  ${rw_huang}1${rw_lv}  Nginx 管理"
    echo -e "  ${rw_huang}2${rw_lv}  MySQL 管理"
    echo -e "  ${rw_huang}3${rw_lv}  PHP 管理"
    echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
    echo -e "  ${rw_huang}0${rw_lv}  返回上级菜单"
    echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
    read -e -p " 请选择: " _cm_choice < /dev/tty
    _cm_choice=${_cm_choice:-0}

    case $_cm_choice in
      1) ldnmp_nginx_manage ;;
      2) ldnmp_mysql_manager ;;
      3) ldnmp_php_manager ;;
      0) break ;;
      *) echo -e "${rw_hong}无效选择${rw_lv}" ;;
    esac
    break_cancel
  done
}


# ================================================================
# 环境优化与安全防护子菜单 (2026-06-26 新增，合并原 9/11)
# ================================================================
ldnmp_optimize_protect() {
  while true; do
    clear
    send_stats "环境优化与安全防护"

    local _gzip_stat="${rw_hong}未开启${rw_lv}" _brotli_stat="${rw_hong}未开启${rw_lv}"
    local _f2b_stat="${rw_hong}未运行${rw_lv}" _ngx_ver_stat="${rw_huang}显示${rw_lv}"

    if [ -f /home/web/nginx.conf ]; then
      grep -q "^gzip on;" /home/web/nginx.conf 2>/dev/null && _gzip_stat="${rw_lv}已开启${rw_lv}"
      grep -q "^brotli on;" /home/web/nginx.conf 2>/dev/null && _brotli_stat="${rw_lv}已开启${rw_lv}"
      grep -q "server_tokens off;" /home/web/nginx.conf 2>/dev/null && _ngx_ver_stat="${rw_lv}已隐藏${rw_lv}"
    fi
    if command -v fail2ban-client &>/dev/null && fail2ban-client ping &>/dev/null 2>&1; then
      _f2b_stat="${rw_lv}运行中${rw_lv}"
    elif command -v fail2ban-client &>/dev/null; then
      _f2b_stat="${rw_huang}已安装未运行${rw_lv}"
    fi

    echo -e "${rw_cheng}━━━━━━━━━━━━  环境优化与安全防护  ━━━━━━━━━━━━${rw_lv}"
    echo -e " Gzip ${_gzip_stat}  Brotli ${_brotli_stat}  Nginx版本 ${_ngx_ver_stat}  fail2ban ${_f2b_stat}"
    echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
    echo ""
    echo -e " ${rw_cheng}── 性能优化${rw_lv}"
    echo -e "  ${rw_huang}1${rw_lv}  开启Gzip压缩        ${rw_huang}2${rw_lv}  开启Brotli压缩"
    echo -e "  ${rw_huang}3${rw_lv}  配置缓存策略        ${rw_huang}4${rw_lv}  优化PHP配置"
    echo ""
    echo -e " ${rw_cheng}── 安全防护${rw_lv}"
    echo -e "  ${rw_huang}5${rw_lv}  安装fail2ban防护    ${rw_huang}6${rw_lv}  开放80/443端口"
    echo -e "  ${rw_huang}7${rw_lv}  隐藏Nginx版本号     ${rw_huang}8${rw_lv}  禁用不安全HTTP方法"
    echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
    echo -e "  ${rw_huang}0${rw_lv}  返回上级菜单"
    echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
    read -e -p " 请选择: " _op_choice < /dev/tty
    _op_choice=${_op_choice:-0}

    case $_op_choice in
      1) _ldnmp_gzip_on ;;
      2) _ldnmp_brotli_on ;;
      3) _ldnmp_cache_on ;;
      4) _ldnmp_php_optimize ;;
      5) _ldnmp_install_fail2ban ;;
      6) _ldnmp_open_web_ports ;;
      7) _ldnmp_hide_nginx_ver ;;
      8) _ldnmp_disable_unsafe_methods ;;
      0) break ;;
      *) echo -e "${rw_hong}无效选择${rw_lv}" ;;
    esac
    break_cancel
  done
}

# ── 优化与防护的原子操作 ──
_ldnmp_gzip_on() {
  clear
  echo -e "${rw_huang}开启Gzip压缩...${rw_lv}"
  if [ -f /home/web/nginx.conf ]; then
    sed -i 's/# gzip on;/gzip on;/' /home/web/nginx.conf 2>/dev/null
    sed -i 's/# gzip_vary on;/gzip_vary on;/' /home/web/nginx.conf 2>/dev/null
    sed -i 's/# gzip_proxied any;/gzip_proxied any;/' /home/web/nginx.conf 2>/dev/null
    docker exec nginx nginx -s reload 2>/dev/null
    echo -e "${rw_lv}✓ 已开启Gzip压缩${rw_lv}"
  else
    echo -e "${rw_hong}Nginx配置文件不存在${rw_lv}"
  fi
  sleep 1
}

_ldnmp_brotli_on() {
  clear
  echo -e "${rw_huang}开启Brotli压缩...${rw_lv}"
  if [ -f /home/web/nginx.conf ]; then
    sed -i 's/# brotli on;/brotli on;/' /home/web/nginx.conf 2>/dev/null
    docker exec nginx nginx -s reload 2>/dev/null
    echo -e "${rw_lv}✓ 已开启Brotli压缩${rw_lv}"
  else
    echo -e "${rw_hong}Nginx配置文件不存在${rw_lv}"
  fi
  sleep 1
}

_ldnmp_cache_on() {
  clear
  echo -e "${rw_huang}配置缓存策略...${rw_lv}"
  if [ -f /home/web/nginx.conf ]; then
    sed -i 's/# proxy_cache_path/proxy_cache_path/' /home/web/nginx.conf 2>/dev/null
    docker exec nginx nginx -s reload 2>/dev/null
    echo -e "${rw_lv}✓ 已配置缓存策略${rw_lv}"
  else
    echo -e "${rw_hong}Nginx配置文件不存在${rw_lv}"
  fi
  sleep 1
}

_ldnmp_php_optimize() {
  clear
  echo -e "${rw_huang}优化PHP配置...${rw_lv}"
  if docker ps --filter "name=php" --filter "status=running" 2>/dev/null | grep -q php; then
    docker exec php sed -i 's/memory_limit = .*/memory_limit = 256M/' /usr/local/etc/php/conf.d/zzz-custom.ini 2>/dev/null || \
        docker exec php bash -c 'echo "memory_limit = 256M" >> /usr/local/etc/php/conf.d/zzz-custom.ini'
    docker exec php sed -i 's/upload_max_filesize = .*/upload_max_filesize = 100M/' /usr/local/etc/php/conf.d/zzz-custom.ini 2>/dev/null
    docker exec php sed -i 's/post_max_size = .*/post_max_size = 100M/' /usr/local/etc/php/conf.d/zzz-custom.ini 2>/dev/null
    docker exec php php-fpm 2>/dev/null
    echo -e "${rw_lv}✓ 已优化PHP配置${rw_lv}"
  else
    echo -e "${rw_hong}PHP容器未运行${rw_lv}"
  fi
  sleep 1
}

_ldnmp_install_fail2ban() {
  clear
  echo -e "${rw_huang}安装fail2ban...${rw_lv}"
  if command -v dnf &>/dev/null; then
    dnf install -y fail2ban 2>/dev/null
  elif command -v yum &>/dev/null; then
    yum install -y fail2ban 2>/dev/null
  elif command -v apt &>/dev/null || command -v apt-get &>/dev/null; then
    apt-get update -qq && apt-get install -y fail2ban 2>/dev/null
  fi
  systemctl enable fail2ban 2>/dev/null
  systemctl start fail2ban 2>/dev/null
  echo -e "${rw_lv}✓ fail2ban安装完成${rw_lv}"
  sleep 1
}

_ldnmp_open_web_ports() {
  clear
  echo -e "${rw_huang}开放80/443端口...${rw_lv}"
  if command -v firewall-cmd &>/dev/null; then
    firewall-cmd --permanent --add-port=80/tcp 2>/dev/null
    firewall-cmd --permanent --add-port=443/tcp 2>/dev/null
    firewall-cmd --reload 2>/dev/null
    echo -e "${rw_lv}✓ firewalld: 已开放80/443端口${rw_lv}"
  elif command -v ufw &>/dev/null; then
    ufw allow 80/tcp 2>/dev/null
    ufw allow 443/tcp 2>/dev/null
    echo -e "${rw_lv}✓ ufw: 已开放80/443端口${rw_lv}"
  elif command -v iptables &>/dev/null; then
    iptables -I INPUT -p tcp --dport 80 -j ACCEPT 2>/dev/null
    iptables -I INPUT -p tcp --dport 443 -j ACCEPT 2>/dev/null
    echo -e "${rw_lv}✓ iptables: 已开放80/443端口${rw_lv}"
  else
    echo -e "${rw_hong}未检测到支持的防火墙工具${rw_lv}"
  fi
  sleep 1
}

_ldnmp_hide_nginx_ver() {
  clear
  echo -e "${rw_huang}隐藏Nginx版本号...${rw_lv}"
  if [ -f /home/web/nginx.conf ]; then
    sed -i 's/^server_tokens .*/server_tokens off;/' /home/web/nginx.conf 2>/dev/null
    sed -i 's/^server_names_hash_bucket_size.*/server_names_hash_bucket_size 512;/' /home/web/nginx.conf 2>/dev/null
    docker exec nginx nginx -s reload 2>/dev/null
    echo -e "${rw_lv}✓ 已隐藏Nginx版本号${rw_lv}"
  else
    echo -e "${rw_hong}Nginx配置文件不存在${rw_lv}"
  fi
  sleep 1
}

_ldnmp_disable_unsafe_methods() {
  clear
  echo -e "${rw_huang}禁用不安全HTTP方法...${rw_lv}"
  if [ -f /home/web/nginx.conf ]; then
    if ! grep -q "if (\$request_method !~" /home/web/nginx.conf; then
      sed -i '/http {/a\    if ($request_method !~ ^(GET|HEAD|POST|PUT|DELETE)$) { return 444; }' /home/web/nginx.conf
    fi
    docker exec nginx nginx -s reload 2>/dev/null
    echo -e "${rw_lv}✓ 已禁用不安全HTTP方法${rw_lv}"
  else
    echo -e "${rw_hong}Nginx配置文件不存在${rw_lv}"
  fi
  sleep 1
}




ldnmp_install_env() {
  clear
  send_stats "安装LDNMP环境"
  echo -e "${rw_huang}正在安装LDNMP环境...${rw_lv}"
  echo -e "${rw_cheng}------------------------${rw_lv}"
  ldnmp_install_status_one
  ldnmp_install_all
  echo -e "${rw_lv}LDNMP环境安装完成！${rw_lv}"
  read -e -p "按回车返回菜单: "
}

ldnmp_install_typecho() {
  clear
  send_stats "安装Typecho轻量博客网站"
  echo -e "${rw_huang}安装Typecho轻量博客网站${rw_lv}"
  echo -e "${rw_cheng}------------------------${rw_lv}"
  echo -e "示例域名：blog.example.com（请先将域名解析到本机IP）"
  echo ""
  add_yuming
  if [ -z "$yuming" ]; then return; fi
  repeat_add_yuming
  ldnmp_install_status
  install_ssltls
  certs_status
  add_db
  mkdir -p /home/web/html/${yuming}
  cd /home/web/html/${yuming}
  echo -e "${rw_huang}正在下载Typecho...${rw_lv}"
  curl -sSL "https://github.com/typecho/typecho/releases/latest/download/typecho.zip" -o typecho.zip 2>/dev/null ||     wget -q "https://github.com/typecho/typecho/releases/latest/download/typecho.zip" -O typecho.zip 2>/dev/null
  if [ -f typecho.zip ]; then
    unzip -o typecho.zip >/dev/null 2>&1
    mv typecho/* . 2>/dev/null
    rm -rf typecho typecho.zip
    chmod -R 755 /home/web/html/${yuming}
  else
    echo -e "${rw_hong}下载失败，请手动下载Typecho${rw_lv}"
  fi
  wget -q -O /home/web/conf.d/map.conf "${gh_proxy}raw.githubusercontent.com/riwi/nginx/main/map.conf" 2>/dev/null
  wget -q -O /home/web/conf.d/${yuming}.conf "${gh_proxy}raw.githubusercontent.com/riwi/nginx/main/default10.conf" 2>/dev/null
  sed -i "s/yuming.com/${yuming}/g" /home/web/conf.d/${yuming}.conf
  nginx_http_on
  restart_ldnmp
  ldnmp_web_on
  echo -e "${rw_lv}Typecho站点 ${yuming} 创建成功！${rw_lv}"
  echo -e "访问地址: ${rw_huang}http://${yuming}${rw_lv}"
  read -e -p "按回车返回菜单: "
}

ldnmp_install_nginx_only() {
  clear
  send_stats "仅安装Nginx"
  echo -e "${rw_huang}正在安装Nginx...${rw_lv}"
  echo -e "${rw_cheng}------------------------${rw_lv}"
  nginx_install_all
  echo -e "${rw_lv}Nginx安装完成！${rw_lv}"
  read -e -p "按回车返回菜单: "
}

# ── MySQL 管理子菜单 ──
ldnmp_mysql_manager() {
while true; do
	clear

	# ── 状态探测 ──
	local _my_stat="${rw_hong}未安装${rw_lv}" _my_ver="" _my_port="" _my_img=""
	local _my_root_pwd="" _my_user="" _my_user_pwd="" _my_dbs=""

	if docker inspect mysql &>/dev/null 2>&1 || docker inspect mariadb &>/dev/null 2>&1; then
		_my_stat="${rw_huang}已停止${rw_lv}"
		# 运行状态
		if docker inspect -f '{{.State.Running}}' mysql 2>/dev/null | grep -q true; then
			_my_stat="${rw_lv}运行中${rw_lv}"
		elif docker inspect -f '{{.State.Running}}' mariadb 2>/dev/null | grep -q true; then
			_my_stat="${rw_lv}运行中${rw_lv}"
		fi
		# 版本
		_my_ver=$(docker exec mysql mysql -V 2>/dev/null | sed -n -E 's/.*([0-9]+\.[0-9]+\.[0-9]+).*/\1/p' | head -1)
		[ -z "$_my_ver" ] && _my_ver=$(docker exec mariadb mysql -V 2>/dev/null | sed -n -E 's/.*([0-9]+\.[0-9]+\.[0-9]+).*/\1/p' | head -1)
		# 镜像名
		_my_img=$(docker inspect --format='{{.Config.Image}}' mysql 2>/dev/null || docker inspect --format='{{.Config.Image}}' mariadb 2>/dev/null)
		# 端口
		_my_port=$(docker port mysql 3306 2>/dev/null | head -1 || docker port mariadb 3306 2>/dev/null | head -1)
		# 从 docker-compose.yml 读取凭据
		if [ -f /home/web/docker-compose.yml ]; then
			_my_root_pwd=$(sed -n -E 's/.*MYSQL_ROOT_PASSWORD:[[:space:]]*(.*)/\1/p' /home/web/docker-compose.yml | tr -d '[:space:]' | head -1)
			_my_user=$(sed -n -E 's/.*MYSQL_USER:[[:space:]]*(.*)/\1/p' /home/web/docker-compose.yml | tr -d '[:space:]' | head -1)
			_my_user_pwd=$(sed -n -E 's/.*MYSQL_PASSWORD:[[:space:]]*(.*)/\1/p' /home/web/docker-compose.yml | tr -d '[:space:]' | head -1)
		fi
		# 数据库列表
		if [ -n "$_my_root_pwd" ]; then
			_my_dbs=$(docker exec mysql mysql -u root -p"$_my_root_pwd" -e "SHOW DATABASES;" 2>/dev/null | grep -v "Database\|information_schema\|performance_schema\|mysql\|sys" | tr '\n' ' ' | sed 's/ *$//')
		fi
	else
		# 检查 docker-compose.yml 是否配置了 mysql
		if [ -f /home/web/docker-compose.yml ] && grep -q "mysql\|mariadb" /home/web/docker-compose.yml 2>/dev/null; then
			_my_stat="${rw_huang}未启动${rw_lv}"
		fi
	fi

	echo -e "${rw_cheng}━━━━━━━━━━━━  MySQL 管理  ━━━━━━━━━━━━${rw_lv}"
	echo -e " 状态 ${_my_stat}  v${_my_ver:-?}  镜像 ${rw_lv}${_my_img:-?}${rw_lv}"
	[ -n "$_my_port" ] && echo -e " 端口映射 ${rw_lv}${_my_port}${rw_lv}"
	[ -n "$_my_dbs" ] && echo -e " 数据库 ${rw_lv}${_my_dbs}${rw_lv}"
	echo ""
	echo -e " ${rw_cheng}──── 服务${rw_lv}"
	echo -e " ${rw_huang}1${rw_lv}  安装MySQL           ${rw_huang}2${rw_lv}  启动"
	echo -e " ${rw_huang}3${rw_lv}  停止                ${rw_huang}4${rw_lv}  重启"
	echo ""
	echo -e " ${rw_cheng}──── 版本管理${rw_lv}"
	echo -e " ${rw_huang}5${rw_lv}  更新MySQL           ${rw_huang}6${rw_lv}  切换MySQL版本"
	echo ""
	echo -e " ${rw_cheng}──── 数据${rw_lv}"
	echo -e " ${rw_huang}7${rw_lv}  查看连接信息        ${rw_huang}8${rw_lv}  查看数据库列表"
	echo ""
	echo -e " ${rw_cheng}──── 卸载${rw_lv}"
	echo -e " ${rw_huang}9${rw_lv}  卸载MySQL"
	echo ""
	echo -e " ${rw_cheng}────────────────────────────────────────${rw_lv}"
	echo -e " ${rw_huang}0${rw_lv}  返回上级菜单"
	echo -e " ${rw_cheng}────────────────────────────────────────${rw_lv}"
	read -e -p " 请选择: " _my_choice

	case $_my_choice in
		1)
			send_stats "安装MySQL"
			root_use
			echo -e "${rw_huang}正在安装MySQL...${rw_lv}"
			echo -e "${rw_cheng}------------------------${rw_lv}"
			install_dependency
			install_docker
			install_ldnmp_conf
			cd /home/web && docker compose up -d mysql
			sleep 3
			# mysql调优
			wget -O /home/custom_mysql_config.cnf ${gh_proxy}raw.githubusercontent.com/riwi/sh/main/custom_mysql_config-1.cnf 2>/dev/null
			docker cp /home/custom_mysql_config.cnf mysql:/etc/mysql/conf.d/ 2>/dev/null
			rm -rf /home/custom_mysql_config.cnf
			docker restart mysql 2>/dev/null
			sleep 1
			# ── 显示安装信息 ──
			local _ins_ver=$(docker exec mysql mysql -V 2>/dev/null | sed -n -E 's/.*([0-9]+\.[0-9]+\.[0-9]+).*/\1/p' | head -1)
			local _ins_root_pwd=$(sed -n -E 's/.*MYSQL_ROOT_PASSWORD:[[:space:]]*(.*)/\1/p' /home/web/docker-compose.yml | tr -d '[:space:]' | head -1)
			local _ins_user=$(sed -n -E 's/.*MYSQL_USER:[[:space:]]*(.*)/\1/p' /home/web/docker-compose.yml | tr -d '[:space:]' | head -1)
			local _ins_user_pwd=$(sed -n -E 's/.*MYSQL_PASSWORD:[[:space:]]*(.*)/\1/p' /home/web/docker-compose.yml | tr -d '[:space:]' | head -1)
			echo ""
			echo -e "${rw_cheng}────────────────────────────────────${rw_lv}"
			echo -e "${rw_lv}MySQL 安装完成！${rw_lv}"
			[ -n "$_ins_ver" ] && echo -e "  版本:        ${rw_huang}v${_ins_ver}${rw_lv}"
			[ -n "$_ins_root_pwd" ] && echo -e "  Root密码:    ${rw_huang}${_ins_root_pwd}${rw_lv}"
			[ -n "$_ins_user" ] && echo -e "  用户名:      ${rw_huang}${_ins_user}${rw_lv}"
			[ -n "$_ins_user_pwd" ] && echo -e "  用户密码:    ${rw_huang}${_ins_user_pwd}${rw_lv}"
			echo -e "  容器名:      ${rw_huang}mysql${rw_lv}"
			echo -e "  数据目录:    ${rw_huang}/home/web/mysql${rw_lv}"
			echo -e "  管理命令:    ${rw_huang}docker exec -it mysql mysql -u root -p${rw_lv}"
			echo -e "${rw_cheng}────────────────────────────────────${rw_lv}"
			read -e -p "按回车返回菜单: "
			;;
		2)
			send_stats "启动MySQL"
			if docker inspect mysql &>/dev/null 2>&1; then
				docker start mysql && echo -e "${rw_lv}MySQL 已启动${rw_lv}" || echo -e "${rw_hong}MySQL 启动失败${rw_lv}"
			elif docker inspect mariadb &>/dev/null 2>&1; then
				docker start mariadb && echo -e "${rw_lv}MariaDB 已启动${rw_lv}" || echo -e "${rw_hong}MariaDB 启动失败${rw_lv}"
			else
				echo -e "${rw_hong}MySQL 容器不存在，请先安装${rw_lv}"
			fi
			;;
		3)
			send_stats "停止MySQL"
			if docker inspect mysql &>/dev/null 2>&1; then
				docker stop mysql && echo -e "${rw_lv}MySQL 已停止${rw_lv}"
			elif docker inspect mariadb &>/dev/null 2>&1; then
				docker stop mariadb && echo -e "${rw_lv}MariaDB 已停止${rw_lv}"
			else
				echo -e "${rw_hong}MySQL 容器不存在${rw_lv}"
			fi
			;;
		4)
			send_stats "重启MySQL"
			if docker inspect mysql &>/dev/null 2>&1; then
				docker restart mysql && echo -e "${rw_lv}MySQL 已重启${rw_lv}"
			elif docker inspect mariadb &>/dev/null 2>&1; then
				docker restart mariadb && echo -e "${rw_lv}MariaDB 已重启${rw_lv}"
			else
				echo -e "${rw_hong}MySQL 容器不存在${rw_lv}"
			fi
			;;
		5)
			send_stats "更新MySQL"
			root_use
			if ! docker inspect mysql &>/dev/null 2>&1 && ! docker inspect mariadb &>/dev/null 2>&1; then
				echo -e "${rw_hong}MySQL 容器不存在，请先安装${rw_lv}"
			else
				echo -e "${rw_huang}正在更新MySQL...${rw_lv}"
				cd /home/web/
				local _my_container="mysql"
				docker inspect mysql &>/dev/null 2>&1 || _my_container="mariadb"
				# 保存数据
				docker stop $_my_container 2>/dev/null
				docker rm $_my_container 2>/dev/null
				docker images --filter=reference="*${_my_container}*" -q | xargs docker rmi 2>/dev/null
				docker compose up -d --force-recreate $_my_container
				# 重新应用调优配置
				wget -O /home/custom_mysql_config.cnf ${gh_proxy}raw.githubusercontent.com/riwi/sh/main/custom_mysql_config-1.cnf 2>/dev/null
				docker cp /home/custom_mysql_config.cnf ${_my_container}:/etc/mysql/conf.d/ 2>/dev/null
				rm -rf /home/custom_mysql_config.cnf
				docker restart $_my_container 2>/dev/null
				local _new_ver=$(docker exec $_my_container mysql -V 2>/dev/null | sed -n -E 's/.*([0-9]+\.[0-9]+\.[0-9]+).*/\1/p' | head -1)
				echo -e "${rw_lv}MySQL 更新完成！${rw_lv}"
				[ -n "$_new_ver" ] && echo -e "当前版本: ${rw_huang}v${_new_ver}${rw_lv}"
			fi
			;;
		6)
			send_stats "切换MySQL版本"
			root_use
			if [ ! -f /home/web/docker-compose.yml ]; then
				echo -e "${rw_hong}未找到 docker-compose.yml，请先安装LDNMP环境${rw_lv}"
			else
				echo -e "${rw_huang}可选MySQL版本:${rw_lv}"
				echo -e "  ${rw_huang}1${rw_lv}  MySQL 5.7"
				echo -e "  ${rw_huang}2${rw_lv}  MySQL 8.0"
				echo -e "  ${rw_huang}3${rw_lv}  MySQL 8.4"
				echo -e "  ${rw_huang}4${rw_lv}  MariaDB 10.11"
				echo -e "  ${rw_huang}5${rw_lv}  MariaDB 11.4"
				echo ""
				read -e -p "请选择版本: " _my_ver_choice
				local _new_img=""
				case $_my_ver_choice in
					1) _new_img="mysql:5.7" ;;
					2) _new_img="mysql:8.0" ;;
					3) _new_img="mysql:8.4" ;;
					4) _new_img="mariadb:10.11" ;;
					5) _new_img="mariadb:11.4" ;;
					*) echo -e "${rw_hong}无效选择${rw_lv}" ; continue ;;
				esac
				echo -e "${rw_huang}正在切换到 ${_new_img}...${rw_lv}"
				# 停止并移除旧容器
				docker stop mysql mariadb 2>/dev/null
				docker rm mysql mariadb 2>/dev/null
				# 修改 docker-compose.yml 中的镜像
				sed -i -E "s|image: mysql:[0-9.]+|image: ${_new_img}|g; s|image: mariadb:[0-9.]+|image: ${_new_img}|g" /home/web/docker-compose.yml
				# 修改容器名（mariadb → mysql 或反之）
				if echo "$_new_img" | grep -q "mariadb"; then
					sed -i -E "s|container_name: mysql|container_name: mariadb|g" /home/web/docker-compose.yml
				else
					sed -i -E "s|container_name: mariadb|container_name: mysql|g" /home/web/docker-compose.yml
				fi
				cd /home/web && docker compose up -d --force-recreate
				sleep 3
				# 重新应用调优配置
				wget -O /home/custom_mysql_config.cnf ${gh_proxy}raw.githubusercontent.com/riwi/sh/main/custom_mysql_config-1.cnf 2>/dev/null
				local _my_new_name=$(echo "$_new_img" | sed -E 's/[:/].*//')
				docker cp /home/custom_mysql_config.cnf ${_my_new_name}:/etc/mysql/conf.d/ 2>/dev/null
				rm -rf /home/custom_mysql_config.cnf
				docker restart $_my_new_name 2>/dev/null
				echo -e "${rw_lv}MySQL 版本切换完成！${rw_lv}"
				echo -e "当前镜像: ${rw_huang}${_new_img}${rw_lv}"
			fi
			;;
		7)
			send_stats "查看MySQL连接信息"
			if [ ! -f /home/web/docker-compose.yml ]; then
				echo -e "${rw_hong}未找到 docker-compose.yml${rw_lv}"
			else
				local _info_root_pwd=$(sed -n -E 's/.*MYSQL_ROOT_PASSWORD:[[:space:]]*(.*)/\1/p' /home/web/docker-compose.yml | tr -d '[:space:]' | head -1)
				local _info_user=$(sed -n -E 's/.*MYSQL_USER:[[:space:]]*(.*)/\1/p' /home/web/docker-compose.yml | tr -d '[:space:]' | head -1)
				local _info_user_pwd=$(sed -n -E 's/.*MYSQL_PASSWORD:[[:space:]]*(.*)/\1/p' /home/web/docker-compose.yml | tr -d '[:space:]' | head -1)
				echo -e "${rw_cheng}────────────────────────────────────${rw_lv}"
				[ -n "$_info_root_pwd" ] && echo -e "  Root密码:    ${rw_huang}${_info_root_pwd}${rw_lv}"
				[ -n "$_info_user" ] && echo -e "  用户名:      ${rw_huang}${_info_user}${rw_lv}"
				[ -n "$_info_user_pwd" ] && echo -e "  用户密码:    ${rw_huang}${_info_user_pwd}${rw_lv}"
				echo -e "  主机:        ${rw_huang}127.0.0.1${rw_lv}"
				echo -e "  端口:        ${rw_huang}3306${rw_lv}"
				echo -e "  连接命令:    ${rw_huang}docker exec -it mysql mysql -u root -p${rw_lv}"
				echo -e "${rw_cheng}────────────────────────────────────${rw_lv}"
			fi
			;;
		8)
			send_stats "查看数据库列表"
			if docker inspect mysql &>/dev/null 2>&1; then
				local _list_root_pwd=$(sed -n -E 's/.*MYSQL_ROOT_PASSWORD:[[:space:]]*(.*)/\1/p' /home/web/docker-compose.yml | tr -d '[:space:]' | head -1)
				if [ -n "$_list_root_pwd" ]; then
					echo -e "${rw_cheng}────────────────────────────────────${rw_lv}"
					docker exec mysql mysql -u root -p"$_list_root_pwd" -e "SHOW DATABASES;" 2>/dev/null
					echo -e "${rw_cheng}────────────────────────────────────${rw_lv}"
				else
					echo -e "${rw_hong}无法读取Root密码${rw_lv}"
				fi
			else
				echo -e "${rw_hong}MySQL 容器不存在或未运行${rw_lv}"
			fi
			;;
		9)
			send_stats "卸载MySQL"
			root_use
			echo -e "${rw_hong}⚠️  卸载将删除MySQL容器和数据，此操作不可逆！${rw_lv}"
			read -e -p "确认卸载MySQL？输入 YES 继续: " _uninstall_confirm
			if [ "$_uninstall_confirm" = "YES" ]; then
				echo -e "${rw_huang}正在卸载MySQL...${rw_lv}"
				docker stop mysql mariadb 2>/dev/null
				docker rm -f mysql mariadb 2>/dev/null
				docker images --filter=reference="*mysql*" -q | xargs docker rmi 2>/dev/null
				docker images --filter=reference="*mariadb*" -q | xargs docker rmi 2>/dev/null
				echo -e "${rw_huang}注意: 数据目录 /home/web/mysql 已保留${rw_lv}"
				echo -e "${rw_lv}MySQL 已卸载${rw_lv}"
			else
				echo -e "${rw_huang}已取消卸载${rw_lv}"
			fi
			;;
		0)
			break
			;;
		*)
			echo -e "${rw_hong}无效的输入!${rw_lv}"
			;;
	esac
	break_cancel
done
}

# ── PHP 管理子菜单 ──
ldnmp_php_manager() {
while true; do
	clear

	# ── 状态探测 ──
	local _php_stat="${rw_hong}未安装${rw_lv}" _php_ver="" _php74_ver="" _php_img=""
	local _php_modules=""

	if docker inspect php &>/dev/null 2>&1; then
		if docker inspect -f '{{.State.Running}}' php 2>/dev/null | grep -q true; then
			_php_stat="${rw_lv}运行中${rw_lv}"
		else
			_php_stat="${rw_huang}已停止${rw_lv}"
		fi
		_php_ver=$(docker exec php php -v 2>/dev/null | sed -n -E 's/.*PHP ([0-9]+\.[0-9]+\.[0-9]+).*/\1/p' | head -1)
		_php_img=$(docker inspect --format='{{.Config.Image}}' php 2>/dev/null)
		_php_modules=$(docker exec php php -m 2>/dev/null | head -20 | tr '\n' ' ' | sed 's/ *$//')
	fi
	local _php74_stat="${rw_hong}未安装${rw_lv}"
	if docker inspect php74 &>/dev/null 2>&1; then
		_php74_ver=$(docker exec php74 php -v 2>/dev/null | sed -n -E 's/.*PHP ([0-9]+\.[0-9]+\.[0-9]+).*/\1/p' | head -1)
		if docker inspect -f '{{.State.Running}}' php74 2>/dev/null | grep -q true; then
			_php74_stat="${rw_lv}运行中${rw_lv}"
		else
			_php74_stat="${rw_huang}已停止${rw_lv}"
		fi
	fi

	echo -e "${rw_cheng}━━━━━━━━━━━━  PHP 管理  ━━━━━━━━━━━━${rw_lv}"
	echo -e " PHP ${_php_stat}  v${_php_ver:-?}  镜像 ${rw_lv}${_php_img:-?}${rw_lv}"
	[ -n "$_php74_ver" ] && echo -e " PHP74 ${_php74_stat}  v${_php74_ver}"
	echo ""
	echo -e " ${rw_cheng}──── 服务${rw_lv}"
	echo -e " ${rw_huang}1${rw_lv}  安装PHP             ${rw_huang}2${rw_lv}  启动"
	echo -e " ${rw_huang}3${rw_lv}  停止                ${rw_huang}4${rw_lv}  重启"
	echo ""
	echo -e " ${rw_cheng}──── 版本管理${rw_lv}"
	echo -e " ${rw_huang}5${rw_lv}  更新PHP             ${rw_huang}6${rw_lv}  切换PHP版本"
	echo ""
	echo -e " ${rw_cheng}──── 信息${rw_lv}"
	echo -e " ${rw_huang}7${rw_lv}  查看已安装模块      ${rw_huang}8${rw_lv}  查看php.ini配置"
	echo ""
	echo -e " ${rw_cheng}──── 卸载${rw_lv}"
	echo -e " ${rw_huang}9${rw_lv}  卸载PHP"
	echo ""
	echo -e " ${rw_cheng}────────────────────────────────────────${rw_lv}"
	echo -e " ${rw_huang}0${rw_lv}  返回上级菜单"
	echo -e " ${rw_cheng}────────────────────────────────────────${rw_lv}"
	read -e -p " 请选择: " _php_choice

	case $_php_choice in
		1)
			send_stats "安装PHP"
			root_use
			echo -e "${rw_huang}正在安装PHP...${rw_lv}"
			echo -e "${rw_cheng}------------------------${rw_lv}"
			install_dependency
			install_docker
			install_ldnmp_conf
			cd /home/web && docker compose up -d php php74 2>/dev/null
			sleep 3
			fix_phpfpm_conf php 2>/dev/null
			fix_phpfpm_conf php74 2>/dev/null
			docker restart php php74 2>/dev/null
			sleep 1
			# ── 显示安装信息 ──
			local _ins_php_ver=$(docker exec php php -v 2>/dev/null | sed -n -E 's/.*PHP ([0-9]+\.[0-9]+\.[0-9]+).*/\1/p' | head -1)
			local _ins_php74_ver=$(docker exec php74 php -v 2>/dev/null | sed -n -E 's/.*PHP ([0-9]+\.[0-9]+\.[0-9]+).*/\1/p' | head -1)
			local _ins_php_img=$(docker inspect --format='{{.Config.Image}}' php 2>/dev/null)
			echo ""
			echo -e "${rw_cheng}────────────────────────────────────${rw_lv}"
			echo -e "${rw_lv}PHP 安装完成！${rw_lv}"
			[ -n "$_ins_php_ver" ] && echo -e "  PHP 版本:      ${rw_huang}v${_ins_php_ver}${rw_lv}"
			[ -n "$_ins_php74_ver" ] && echo -e "  PHP74 版本:    ${rw_huang}v${_ins_php74_ver}${rw_lv}"
			[ -n "$_ins_php_img" ] && echo -e "  镜像:          ${rw_huang}${_ins_php_img}${rw_lv}"
			echo -e "  容器名:        ${rw_huang}php / php74${rw_lv}"
			echo -e "  网站根目录:    ${rw_huang}/home/web/html${rw_lv}"
			echo -e "  fpm配置:       ${rw_huang}/usr/local/etc/php-fpm.d/www.conf${rw_lv}"
			echo -e "  管理命令:      ${rw_huang}docker exec -it php bash${rw_lv}"
			echo -e "${rw_cheng}────────────────────────────────────${rw_lv}"
			read -e -p "按回车返回菜单: "
			;;
		2)
			send_stats "启动PHP"
			if docker inspect php &>/dev/null 2>&1; then
				docker start php php74 2>/dev/null && echo -e "${rw_lv}PHP 已启动${rw_lv}" || echo -e "${rw_hong}PHP 启动失败${rw_lv}"
			else
				echo -e "${rw_hong}PHP 容器不存在，请先安装${rw_lv}"
			fi
			;;
		3)
			send_stats "停止PHP"
			if docker inspect php &>/dev/null 2>&1; then
				docker stop php php74 2>/dev/null && echo -e "${rw_lv}PHP 已停止${rw_lv}"
			else
				echo -e "${rw_hong}PHP 容器不存在${rw_lv}"
			fi
			;;
		4)
			send_stats "重启PHP"
			if docker inspect php &>/dev/null 2>&1; then
				docker restart php php74 2>/dev/null && echo -e "${rw_lv}PHP 已重启${rw_lv}"
			else
				echo -e "${rw_hong}PHP 容器不存在${rw_lv}"
			fi
			;;
		5)
			send_stats "更新PHP"
			root_use
			if ! docker inspect php &>/dev/null 2>&1; then
				echo -e "${rw_hong}PHP 容器不存在，请先安装${rw_lv}"
			else
				echo -e "${rw_huang}正在更新PHP...${rw_lv}"
				cd /home/web/
				docker stop php php74 2>/dev/null
				docker rm php php74 2>/dev/null
				docker images --filter=reference="*php*" -q | xargs docker rmi 2>/dev/null
				docker compose up -d --force-recreate php php74 2>/dev/null
				sleep 2
				fix_phpfpm_conf php 2>/dev/null
				fix_phpfpm_conf php74 2>/dev/null
				docker restart php php74 2>/dev/null
				local _new_php_ver=$(docker exec php php -v 2>/dev/null | sed -n -E 's/.*PHP ([0-9]+\.[0-9]+\.[0-9]+).*/\1/p' | head -1)
				local _new_php74_ver=$(docker exec php74 php -v 2>/dev/null | sed -n -E 's/.*PHP ([0-9]+\.[0-9]+\.[0-9]+).*/\1/p' | head -1)
				echo -e "${rw_lv}PHP 更新完成！${rw_lv}"
				[ -n "$_new_php_ver" ] && echo -e "PHP 版本: ${rw_huang}v${_new_php_ver}${rw_lv}"
				[ -n "$_new_php74_ver" ] && echo -e "PHP74 版本: ${rw_huang}v${_new_php74_ver}${rw_lv}"
			fi
			;;
		6)
			send_stats "切换PHP版本"
			root_use
			if [ ! -f /home/web/docker-compose.yml ]; then
				echo -e "${rw_hong}未找到 docker-compose.yml，请先安装LDNMP环境${rw_lv}"
			else
				echo -e "${rw_huang}可选PHP版本:${rw_lv}"
				echo -e "  ${rw_huang}1${rw_lv}  PHP 7.4"
				echo -e "  ${rw_huang}2${rw_lv}  PHP 8.0"
				echo -e "  ${rw_huang}3${rw_lv}  PHP 8.1"
				echo -e "  ${rw_huang}4${rw_lv}  PHP 8.2"
				echo -e "  ${rw_huang}5${rw_lv}  PHP 8.3"
				echo ""
				read -e -p "请选择PHP主版本: " _php_ver_choice
				local _new_php_img=""
				case $_php_ver_choice in
					1) _new_php_img="php:7.4-fpm" ;;
					2) _new_php_img="php:8.0-fpm" ;;
					3) _new_php_img="php:8.1-fpm" ;;
					4) _new_php_img="php:8.2-fpm" ;;
					5) _new_php_img="php:8.3-fpm" ;;
					*) echo -e "${rw_hong}无效选择${rw_lv}" ; continue ;;
				esac
				echo -e "${rw_huang}正在切换PHP到 ${_new_php_img}...${rw_lv}"
				docker stop php php74 2>/dev/null
				docker rm php php74 2>/dev/null
				# 修改 docker-compose.yml 中的PHP镜像
				sed -i -E "s|image: php:[0-9.]+-fpm|image: ${_new_php_img}|g" /home/web/docker-compose.yml
				cd /home/web && docker compose up -d --force-recreate php php74 2>/dev/null
				sleep 3
				fix_phpfpm_conf php 2>/dev/null
				fix_phpfpm_conf php74 2>/dev/null
				docker restart php php74 2>/dev/null
				local _switched_ver=$(docker exec php php -v 2>/dev/null | sed -n -E 's/.*PHP ([0-9]+\.[0-9]+\.[0-9]+).*/\1/p' | head -1)
				echo -e "${rw_lv}PHP 版本切换完成！${rw_lv}"
				[ -n "$_switched_ver" ] && echo -e "当前版本: ${rw_huang}v${_switched_ver}${rw_lv}"
			fi
			;;
		7)
			send_stats "查看PHP模块"
			if docker inspect php &>/dev/null 2>&1; then
				echo -e "${rw_cheng}────────────────────────────────────${rw_lv}"
				docker exec php php -m 2>/dev/null | sort
				echo -e "${rw_cheng}────────────────────────────────────${rw_lv}"
			else
				echo -e "${rw_hong}PHP 容器不存在${rw_lv}"
			fi
			;;
		8)
			send_stats "查看php.ini配置"
			if docker inspect php &>/dev/null 2>&1; then
				echo -e "${rw_cheng}────────────────────────────────────${rw_lv}"
				docker exec php php -i 2>/dev/null | grep -E "^(php.ini|Configuration File|Loaded Configuration|memory_limit|max_execution_time|upload_max_filesize|post_max_size|display_errors)" | head -20
				echo -e "${rw_cheng}────────────────────────────────────${rw_lv}"
			else
				echo -e "${rw_hong}PHP 容器不存在${rw_lv}"
			fi
			;;
		9)
			send_stats "卸载PHP"
			root_use
			echo -e "${rw_hong}⚠️  卸载将删除PHP容器，此操作不可逆！${rw_lv}"
			read -e -p "确认卸载PHP？输入 YES 继续: " _php_uninstall_confirm
			if [ "$_php_uninstall_confirm" = "YES" ]; then
				echo -e "${rw_huang}正在卸载PHP...${rw_lv}"
				docker stop php php74 2>/dev/null
				docker rm -f php php74 2>/dev/null
				docker images --filter=reference="*php*fpm*" -q | xargs docker rmi 2>/dev/null
				echo -e "${rw_lv}PHP 已卸载${rw_lv}"
			else
				echo -e "${rw_huang}已取消卸载${rw_lv}"
			fi
			;;
		0)
			break
			;;
		*)
			echo -e "${rw_hong}无效的输入!${rw_lv}"
			;;
	esac
	break_cancel
done
}

ldnmp_proxy_ip_port() {
  clear
  send_stats "站点反向代理+IP+端口"
  echo -e "${rw_huang}站点反向代理+IP+端口${rw_lv}"
  echo -e "${rw_cheng}------------------------${rw_lv}"
  echo -e "示例：域名 blog.example.com，反向代理到后端 192.168.1.10:8080"
  echo ""
  read -e -p "请输入域名或IP（回车默认本机IP）: " proxy_domain
  proxy_domain=${proxy_domain:-$(curl -s --max-time 5 ifconfig.me 2>/dev/null || echo "localhost")}
  read -e -p "请输入后端IP（回车默认127.0.0.1）: " target_ip
  target_ip=${target_ip:-127.0.0.1}
  read -e -p "请输入后端端口（回车默认80）: " target_port
  target_port=${target_port:-80}
  # 创建nginx配置
  mkdir -p /home/web/conf.d
  cat > /home/web/conf.d/${proxy_domain}.conf << 'PROXYEOF'
server {
    listen 80;
    listen [::]:80;
    server_name DOMAIN_PLACEHOLDER;
    location / {
        proxy_pass http://TARGET_IP:TARGET_PORT;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
PROXYEOF
  sed -i "s/DOMAIN_PLACEHOLDER/${proxy_domain}/g" /home/web/conf.d/${proxy_domain}.conf
  sed -i "s/TARGET_IP:TARGET_PORT/${target_ip}:${target_port}/g" /home/web/conf.d/${proxy_domain}.conf
  nginx_upgrade
  echo -e "${rw_lv}反向代理站点 ${proxy_domain} 创建成功！${rw_lv}"
  echo -e "代理地址: ${rw_huang}http://${proxy_domain} -> http://${target_ip}:${target_port}${rw_lv}"
  read -e -p "按回车返回菜单: "
}

ldnmp_scheduled_backup() {
  while true; do
    clear
    send_stats "定时远程备份"
    echo -e "${rw_huang}定时远程备份${rw_lv}"
    echo -e "${rw_cheng}------------------------${rw_lv}"
    echo ""
    echo -e "${rw_huang}请选择操作：${rw_lv}"
    echo -e "${rw_cheng}------------------------${rw_lv}"
    echo -e "${rw_huang}1.   ${rw_lv}配置rclone远程存储"
    echo -e "${rw_huang}2.   ${rw_lv}设置定时备份任务"
    echo -e "${rw_huang}3.   ${rw_lv}查看当前备份任务"
    echo -e "${rw_huang}4.   ${rw_lv}立即执行一次备份"
    echo -e "${rw_huang}5.   ${rw_lv}删除备份任务"
    echo -e "${rw_cheng}------------------------${rw_lv}"
    echo -e "${rw_huang}0.   ${rw_lv}返回上级菜单"
    echo -e "${rw_cheng}------------------------${rw_lv}"
    read -e -p "请输入你的选择（回车默认0返回）: " sub_choice
    sub_choice=${sub_choice:-0}
    case $sub_choice in
      1)
        clear
        echo -e "${rw_huang}配置rclone远程存储${rw_lv}"
        echo -e "${rw_cheng}------------------------${rw_lv}"
        if ! command -v rclone &>/dev/null; then
          echo "正在安装rclone..."
          curl -sSL https://rclone.org/install.sh | bash 2>/dev/null || echo "rclone安装失败，请手动安装"
        fi
        echo -e "${rw_huang}请按提示配置远程存储，配置完成后按回车继续${rw_lv}"
        rclone config
        ;;
      2)
        clear
        echo -e "${rw_huang}设置定时备份任务${rw_lv}"
        echo -e "${rw_cheng}------------------------${rw_lv}"
        read -e -p "请输入rclone远程路径（如 gdrive:backup）: " remote_path
        read -e -p "请输入备份频率Cron表达式（回车默认每天2点: 0 2 * * *）: " cron_expr
        cron_expr=${cron_expr:-"0 2 * * *"}
        cron_job="$cron_expr rclone sync /home/web $remote_path >> /var/log/ldnmp_backup.log 2>&1"
        (crontab -l 2>/dev/null; echo "$cron_job") | crontab -
        echo -e "${rw_lv}备份任务已设置${rw_lv}"
        echo "  Cron: $cron_expr"
        echo "  远程: $remote_path"
        sleep 1
        ;;
      3)
        clear
        echo -e "${rw_huang}当前备份任务：${rw_lv}"
        echo -e "${rw_cheng}------------------------${rw_lv}"
        crontab -l 2>/dev/null | grep "rclone.*sync.*backup" || echo "  暂无备份任务"
        echo ""
        read -e -p "按回车继续..."
        ;;
      4)
        clear
        read -e -p "请输入rclone远程路径（如 gdrive:backup）: " remote_path
        if [ -n "$remote_path" ]; then
          echo -e "${rw_huang}正在执行备份...${rw_lv}"
          rclone sync /home/web "$remote_path" -P 2>&1 | tail -5
          echo -e "${rw_lv}备份执行完毕${rw_lv}"
        fi
        sleep 1
        ;;
      5)
        clear
        echo -e "${rw_huang}删除备份任务${rw_lv}"
        echo -e "${rw_cheng}------------------------${rw_lv}"
        crontab -l 2>/dev/null | grep -n "rclone.*sync.*backup" || echo "  暂无备份任务"
        read -e -p "确认删除所有备份任务？(Y/N，回车默认N): " confirm
        confirm=${confirm:-N}
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
          crontab -l 2>/dev/null | grep -v "rclone.*sync.*backup" | crontab -
          echo "备份任务已删除"
        fi
        sleep 1
        ;;
      0) break ;;
      *) echo "无效的输入!" ;;
    esac
    break_cancel
  done
}

ldnmp_update_env() {
  clear
  send_stats "更新LDNMP环境"
  echo -e "${rw_huang}更新LDNMP环境${rw_lv}"
  echo -e "${rw_cheng}------------------------${rw_lv}"
  if [ ! -f /home/web/docker-compose.yml ]; then
    echo -e "${rw_hong}LDNMP环境未安装，请先安装${rw_lv}"
    sleep 1
    return
  fi
  cd /home/web
  echo -e "${rw_huang}正在更新LDNMP环境...${rw_lv}"
  docker compose pull 2>/dev/null
  docker compose up -d 2>/dev/null
  echo -e "${rw_lv}LDNMP环境更新完成${rw_lv}"
  read -e -p "按回车返回菜单: "
}

ldnmp_restore_full() {
  clear
  send_stats "还原全站数据"
  echo -e "${rw_huang}还原全站数据${rw_lv}"
  echo -e "${rw_cheng}------------------------${rw_lv}"
  echo -e "${rw_hong}警告：这将覆盖当前 /home/web 数据！${rw_lv}"
  echo ""
  echo -e "可用的备份列表："
  ls -d /home/web_backup_* 2>/dev/null | head -10
  echo ""
  read -e -p "请输入要恢复的备份目录路径（如 /home/web_backup_20240101_120000）: " restore_path
  if [ -d "$restore_path" ]; then
    read -e -p "$(echo -e "${rw_hong}确认恢复？(Y/N，回车默认N): ${rw_lv}")" confirm
    confirm=${confirm:-N}
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      rm -rf /home/web 2>/dev/null
      cp -r "$restore_path" /home/web 2>/dev/null
      if [ $? -eq 0 ]; then
        echo -e "${rw_lv}恢复完成！${rw_lv}"
        echo -e "正在重启LDNMP环境..."
        cd /home/web && docker compose restart 2>/dev/null
      else
        echo -e "${rw_hong}恢复失败${rw_lv}"
      fi
    fi
  else
    echo -e "${rw_hong}错误：备份目录不存在${rw_lv}"
  fi
  sleep 1
  read -e -p "按回车返回菜单: "
}

ldnmp_custom_static() {
  clear
  send_stats "自定义静态站点"
  echo -e "${rw_huang}自定义静态站点${rw_lv}"
  echo -e "${rw_cheng}------------------------${rw_lv}"
  echo -e "示例域名：static.example.com"
  echo ""
  add_yuming
  if [ -z "$yuming" ]; then return; fi
  repeat_add_yuming
  mkdir -p /home/web/html/${yuming}
  echo -e "${rw_huang}请输入静态页面内容（输入空行结束）：${rw_lv}"
  static_content=""
  while IFS= read -r line; do
    [[ -z "$line" ]] && break
    static_content+="${line}"$'
'
  done
  if [ -z "$static_content" ]; then
    # 使用默认页面
    cat > /home/web/html/${yuming}/index.html << 'HTMLEOF'
<!DOCTYPE html>
<html>
<head>
    <title>Welcome</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; padding: 50px; background: #f5f5f5; }
        h1 { color: #333; }
        p { color: #666; }
    </style>
</head>
<body>
    <h1>Welcome to ${yuming}</h1>
    <p>您的静态站点已创建。</p>
</body>
</html>
HTMLEOF
  else
    echo "$static_content" > /home/web/html/${yuming}/index.html
  fi
  wget -q -O /home/web/conf.d/map.conf "${gh_proxy}raw.githubusercontent.com/riwi/nginx/main/map.conf" 2>/dev/null
  wget -q -O /home/web/conf.d/${yuming}.conf "${gh_proxy}raw.githubusercontent.com/riwi/nginx/main/default10.conf" 2>/dev/null
  sed -i "s/yuming.com/${yuming}/g" /home/web/conf.d/${yuming}.conf
  nginx_http_on
  nginx_upgrade
  echo -e "${rw_lv}静态站点 ${yuming} 创建成功！${rw_lv}"
  echo -e "访问地址: ${rw_huang}http://${yuming}${rw_lv}"
  read -e -p "按回车返回菜单: "
}

ldnmp_proxy_load_balance() {
  clear
  send_stats "站点反向代理-负载均衡"
  echo -e "${rw_huang}站点反向代理-负载均衡${rw_lv}"
  echo -e "${rw_cheng}------------------------${rw_lv}"
  echo -e "示例：域名 app.example.com，后端服务器 192.168.1.10:80 和 192.168.1.11:80"
  echo ""
  read -e -p "请输入域名: " lb_domain
  if [ -z "$lb_domain" ]; then return; fi
  read -e -p "请输入后端服务器1（IP:端口，如 192.168.1.10:80）: " backend1
  read -e -p "请输入后端服务器2（IP:端口，如 192.168.1.11:80）: " backend2
  read -e -p "请输入更多后端服务器（可选，空格分隔）: " backends_more
  mkdir -p /home/web/conf.d
  cat > /home/web/conf.d/${lb_domain}.conf << 'LBEOF'
upstream BACKEND_PLACEHOLDER {
    server BACKEND1_PLACEHOLDER;
    server BACKEND2_PLACEHOLDER;
    # 可添加更多后端服务器
}
server {
    listen 80;
    listen [::]:80;
    server_name DOMAIN_PLACEHOLDER;
    location / {
        proxy_pass http://BACKEND_PLACEHOLDER;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
LBEOF
  sed -i "s/DOMAIN_PLACEHOLDER/${lb_domain}/g" /home/web/conf.d/${lb_domain}.conf
  sed -i "s/BACKEND1_PLACEHOLDER/${backend1}/g" /home/web/conf.d/${lb_domain}.conf
  sed -i "s/BACKEND2_PLACEHOLDER/${backend2}/g" /home/web/conf.d/${lb_domain}.conf
  sed -i "s/BACKEND_PLACEHOLDER/BACKEND_PLACEHOLDER/g" /home/web/conf.d/${lb_domain}.conf
  nginx_upgrade
  echo -e "${rw_lv}负载均衡站点 ${lb_domain} 创建成功！${rw_lv}"
  echo -e "访问地址: ${rw_huang}http://${lb_domain}${rw_lv}"
  read -e -p "按回车返回菜单: "
}

ldnmp_proxy_domain() {
  clear
  send_stats "站点反向代理+域名"
  echo -e "${rw_huang}站点反向代理+域名${rw_lv}"
  echo -e "${rw_cheng}------------------------${rw_lv}"
  echo -e "示例：域名 api.example.com，反向代理到 https://api.backend.com"
  echo ""
  read -e -p "请输入域名: " proxy_domain
  if [ -z "$proxy_domain" ]; then return; fi
  read -e -p "请输入后端域名（如 api.backend.com）: " target_domain
  read -e -p "请输入后端端口（回车默认443）: " target_port
  target_port=${target_port:-443}
  mkdir -p /home/web/conf.d
  proto="https"
  if [ "$target_port" = "80" ]; then proto="http"; fi
  cat > /home/web/conf.d/${proxy_domain}.conf << 'PDEOF'
server {
    listen 80;
    listen [::]:80;
    server_name DOMAIN_PLACEHOLDER;
    location / {
        proxy_pass PROTO_PLACEHOLDER://TARGET_PLACEHOLDER:TARGET_PORT_PLACEHOLDER;
        proxy_ssl_server_name on;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
PDEOF
  sed -i "s/DOMAIN_PLACEHOLDER/${proxy_domain}/g" /home/web/conf.d/${proxy_domain}.conf
  sed -i "s/PROTO_PLACEHOLDER/${proto}/g" /home/web/conf.d/${proxy_domain}.conf
  sed -i "s/TARGET_PLACEHOLDER/${target_domain}/g" /home/web/conf.d/${proxy_domain}.conf
  sed -i "s/TARGET_PORT_PLACEHOLDER/${target_port}/g" /home/web/conf.d/${proxy_domain}.conf
  nginx_upgrade
  echo -e "${rw_lv}反向代理站点 ${proxy_domain} -> ${proto}://${target_domain}:${target_port} 创建成功！${rw_lv}"
  echo -e "访问地址: ${rw_huang}http://${proxy_domain}${rw_lv}"
  read -e -p "按回车返回菜单: "
}

ldnmp_site_redirect() {
  clear
  send_stats "站点重定向"
  echo -e "${rw_huang}站点重定向${rw_lv}"
  echo -e "${rw_cheng}------------------------${rw_lv}"
  echo -e "示例：旧域名 old.example.com 重定向到新域名 new.example.com"
  echo ""
  read -e -p "请输入源域名（重定向来源）: " src_domain
  if [ -z "$src_domain" ]; then return; fi
  read -e -p "请输入目标域名（重定向目标）: " dst_domain
  if [ -z "$dst_domain" ]; then return; fi
  read -e -p "请输入重定向类型（301永久/302临时，回车默认301）: " redirect_type
  redirect_type=${redirect_type:-301}
  mkdir -p /home/web/conf.d
  cat > /home/web/conf.d/${src_domain}.conf << 'REOF'
server {
    listen 80;
    listen [::]:80;
    server_name SRC_PLACEHOLDER;
    return REDIRECT_TYPE_PLACEHOLDER https://DST_PLACEHOLDER$request_uri;
}
REOF
  sed -i "s/SRC_PLACEHOLDER/${src_domain}/g" /home/web/conf.d/${src_domain}.conf
  sed -i "s/DST_PLACEHOLDER/${dst_domain}/g" /home/web/conf.d/${src_domain}.conf
  sed -i "s/REDIRECT_TYPE_PLACEHOLDER/${redirect_type}/g" /home/web/conf.d/${src_domain}.conf
  nginx_upgrade
  echo -e "${rw_lv}重定向规则已创建：${src_domain} -> ${dst_domain} (${redirect_type})${rw_lv}"
  read -e -p "按回车返回菜单: "
}

ldnmp_nginx_manage() {
  while true; do
    clear
    send_stats "Nginx管理"

    # ── 状态探测 ──
    local _ngx_ver="" _ngx_stat="${rw_hong}未运行${rw_lv}"
    if docker inspect nginx &>/dev/null; then
      _ngx_ver=$(docker exec nginx nginx -v 2>&1 | sed -n -E 's/.*nginx\/([0-9.]+).*/\1/p')
      docker exec nginx nginx -t &>/dev/null && _ngx_stat="${rw_lv}运行中${rw_lv}" || _ngx_stat="${rw_hong}异常${rw_lv}"
    elif command -v nginx &>/dev/null; then
      _ngx_ver=$(nginx -v 2>&1 | sed -n -E 's/.*nginx\/([0-9.]+).*/\1/p')
      pgrep -x nginx &>/dev/null && _ngx_stat="${rw_lv}运行中${rw_lv}" || _ngx_stat="${rw_hong}未运行${rw_lv}"
    else
      _ngx_stat="${rw_hong}未安装${rw_lv}"
    fi

    echo -e "${rw_cheng}━━━━━━━━━━━━  Nginx 管理  ━━━━━━━━━━━━${rw_lv}"
    echo -e " ${_ngx_stat}  v${_ngx_ver:-?}"
    echo ""
    echo -e " ${rw_lv}──── 控制${rw_lv}"
    echo -e " ${rw_huang}1${rw_lv}  启动    ${rw_huang}2${rw_lv}  停止    ${rw_huang}3${rw_lv}  重启    ${rw_huang}4${rw_lv}  重载    ${rw_huang}5${rw_lv}  测试配置"
    echo ""
    echo -e " ${rw_lv}──── 日志${rw_lv}"
    echo -e " ${rw_huang}6${rw_lv}  访问日志    ${rw_huang}7${rw_lv}  错误日志    ${rw_huang}8${rw_lv}  进程    ${rw_huang}9${rw_lv}  监听端口"
    echo ""
    echo -e " ${rw_cheng}────────────────────────────────────────${rw_lv}"
    echo -e " ${rw_huang}0${rw_lv}  返回上级菜单"
    echo -e " ${rw_cheng}────────────────────────────────────────${rw_lv}"
    read -e -p " 请选择: " sub_choice
    sub_choice=${sub_choice:-0}
    case $sub_choice in
      1)
        send_stats "启动Nginx"
        if docker inspect nginx &>/dev/null; then
          cd /home/web && docker compose start nginx && echo -e "${rw_lv}Nginx 已启动${rw_lv}"
        elif command -v nginx &>/dev/null; then
          nginx_start
          echo -e "${rw_lv}Nginx 启动完成${rw_lv}"
        else
          echo -e "${rw_hong}Nginx 未安装${rw_lv}"
        fi
        ;;
      2)
        send_stats "停止Nginx"
        if docker inspect nginx &>/dev/null; then
          cd /home/web && docker compose stop nginx && echo -e "${rw_lv}Nginx 已停止${rw_lv}"
        elif command -v nginx &>/dev/null; then
          nginx_stop
          echo -e "${rw_lv}Nginx 已停止${rw_lv}"
        else
          echo -e "${rw_hong}Nginx 未安装${rw_lv}"
        fi
        ;;
      3)
        send_stats "重启Nginx"
        if docker inspect nginx &>/dev/null; then
          cd /home/web && docker compose restart nginx && echo -e "${rw_lv}Nginx 已重启${rw_lv}"
        elif command -v nginx &>/dev/null; then
          nginx_stop; sleep 1; nginx_start
          echo -e "${rw_lv}Nginx 重启完成${rw_lv}"
        else
          echo -e "${rw_hong}Nginx 未安装${rw_lv}"
        fi
        ;;
      4)
        send_stats "重新加载Nginx配置"
        if docker inspect nginx &>/dev/null; then
          docker exec nginx nginx -s reload && echo -e "${rw_lv}配置已重载${rw_lv}" || echo -e "${rw_hong}重载失败${rw_lv}"
        elif command -v nginx &>/dev/null; then
          nginx -s reload 2>&1
          [ $? -eq 0 ] && echo -e "${rw_lv}配置已重载${rw_lv}" || echo -e "${rw_hong}重载失败${rw_lv}"
        else
          echo -e "${rw_hong}Nginx 未安装${rw_lv}"
        fi
        ;;
      5)
        send_stats "测试Nginx配置语法"
        if docker inspect nginx &>/dev/null; then
          docker exec nginx nginx -t 2>&1
        elif command -v nginx &>/dev/null; then
          nginx -t 2>&1
        else
          echo -e "${rw_hong}Nginx 未安装${rw_lv}"
        fi
        ;;
      6)
        send_stats "查看Nginx访问日志"
        if [ -f /home/web/logs/access.log ]; then
          tail -n 50 /home/web/logs/access.log
        elif [ -f /var/log/nginx/access.log ]; then
          tail -n 50 /var/log/nginx/access.log
        else
          echo -e "${rw_hong}未找到访问日志${rw_lv}"
        fi
        ;;
      7)
        send_stats "查看Nginx错误日志"
        if [ -f /home/web/logs/error.log ]; then
          tail -n 50 /home/web/logs/error.log
        elif [ -f /var/log/nginx/error.log ]; then
          tail -n 50 /var/log/nginx/error.log
        else
          echo -e "${rw_hong}未找到错误日志${rw_lv}"
        fi
        ;;
      8)
        send_stats "查看Nginx进程"
        if docker inspect nginx &>/dev/null; then
          docker top nginx
        elif pgrep -x nginx &>/dev/null; then
          ps aux | grep nginx | grep -v grep
        else
          echo -e "${rw_hong}Nginx 未运行${rw_lv}"
        fi
        ;;
      9)
        send_stats "查看Nginx监听端口"
        if command -v ss &>/dev/null; then
          ss -tlnp | grep nginx
        elif command -v netstat &>/dev/null; then
          netstat -tlnp | grep nginx
        else
          echo -e "${rw_hong}未找到 ss 或 netstat${rw_lv}"
        fi
        ;;
      0) break ;;
      *) echo -e "${rw_hong}无效选择${rw_lv}" ;;
    esac
    break_cancel
  done
}

moltbot_menu() {
	local app_id="114"

	send_stats "clawdbot/moltbot管理"

	check_openclaw_update() {
		if ! command -v npm >/dev/null 2>&1; then
			return 1
		fi

		# 加上 --no-update-notifier，并确保错误重定向位置正确
		local_version=$(npm list -g openclaw --depth=0 --no-update-notifier 2>/dev/null | grep openclaw | awk '{print $NF}' | sed 's/^.*@//')

		if [ -z "$local_version" ]; then
			return 1
		fi

		remote_version=$(npm view openclaw version --no-update-notifier 2>/dev/null)

		if [ -z "$remote_version" ]; then
			return 1
		fi

		if [ "$local_version" != "$remote_version" ]; then
			echo "${rw_huang}检测到新版本:$remote_version${rw_lv}"
		else
			echo "${rw_lv}当前版本已是最新:$local_version${rw_lv}"
		fi
	}


	get_install_status() {
		if command -v openclaw >/dev/null 2>&1; then
			echo "${rw_lv}已安装${rw_lv}"
		else
			echo "${rw_lv}未安装${rw_lv}"
		fi
	}

	get_running_status() {		
		if pgrep -f "openclaw.*gateway" >/dev/null 2>&1; then
			echo "${rw_lv}运行中${rw_lv}"
		else
			echo "${rw_lv}未运行${rw_lv}"
		fi
	}


	show_menu() {


		clear

		local install_status=$(get_install_status)
		local running_status=$(get_running_status)
		local update_message=$(check_openclaw_update)

		echo -e "${rw_cheng}=======================================${rw_lv}"
		echo -e "🦞 OPENCLAW 管理工具 by Riou 🦞"
		echo -e "💡 终端执行 \033[1;33mk claw\033[0m 快速进入菜单"
		echo -e "$install_status $running_status $update_message"
		echo -e "${rw_cheng}=======================================${rw_lv}"
		echo "1.  安装"
		echo "2.  启动"
		echo "3.  停止"
		echo -e "${rw_cheng}--------------------${rw_lv}"
		echo "4.  状态日志查看"
		echo "5.  换模型"
		echo "6.  API管理"
		echo "7.  机器人连接对接"
		echo "8.  插件管理（安装/删除）"
		echo "9.  技能管理（安装/删除）"
		echo "10. 编辑主配置文件"
		echo "11. 配置向导"
		echo "12. 健康检测与修复"
		echo "13. WebUI访问与设置"
		echo "14. TUI命令行对话窗口"
		echo "15. 记忆/Memory"
		echo "16. 权限管理"
		echo "17. 多智能体管理"
		echo -e "${rw_cheng}--------------------${rw_lv}"
		echo "18. 备份与还原"
		echo "19. 更新"
		echo "20. 卸载"
		echo -e "${rw_cheng}--------------------${rw_lv}"
		echo "0. 返回上一级选单"
		echo -e "${rw_cheng}--------------------${rw_lv}"
		printf "请输入选项并回车: "
	}


	start_gateway() {
		openclaw gateway stop
		openclaw gateway start
		sleep 3
	}


	install_node_and_tools() {
		if command -v dnf &>/dev/null; then
			curl -fsSL https://rpm.nodesource.com/setup_24.x | sudo bash -
			dnf update -y
			dnf group install -y "Development Tools" "Development Libraries"
			dnf install -y cmake libatomic nodejs
		fi

		if command -v apt &>/dev/null; then
			curl -fsSL https://deb.nodesource.com/setup_24.x | bash -
			apt update -y
			apt install build-essential python3 libatomic1 nodejs -y
		fi
	}

	sync_openclaw_api_models() {
		local config_file
		config_file=$(openclaw_get_config_file)

		[ ! -f "$config_file" ] && return 0

		install jq curl >/dev/null 2>&1

		python3 - "$config_file" "$ENABLE_STATS" "$sh_v" <<'PY'
import copy
import json
import os
import platform
import sys
import time
import urllib.request
from datetime import datetime, timezone

path = sys.argv[1]
stats_enabled = (sys.argv[2].lower() == "true") if len(sys.argv) > 2 else True
script_version = sys.argv[3] if len(sys.argv) > 3 else ""

def send_stat(action):
    if not stats_enabled:
        return
    payload = {
        "action": action,
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S"),
        "country": "",
        "os_info": platform.platform(),
        "cpu_arch": platform.machine(),
        "version": script_version,
    }
    try:
        req = urllib.request.Request(
            "https://api.riwi.pro/api/log",
            data=json.dumps(payload).encode("utf-8"),
            headers={"Content-Type": "application/json"},
            method="POST",
        )
        with urllib.request.urlopen(req, timeout=3):
            pass
    except Exception:
        pass

with open(path, 'r', encoding='utf-8') as f:
    obj = json.load(f)

work = copy.deepcopy(obj)
models_cfg = work.setdefault('models', {})
providers = models_cfg.get('providers', {})
if not isinstance(providers, dict) or not providers:
    print('ℹ️ 未检测到 API providers，跳过模型同步')
    raise SystemExit(0)

agents = work.setdefault('agents', {})
defaults = agents.setdefault('defaults', {})
defaults_models_raw = defaults.get('models')
if isinstance(defaults_models_raw, dict):
    defaults_models = defaults_models_raw
elif isinstance(defaults_models_raw, list):
    defaults_models = {str(x): {} for x in defaults_models_raw if isinstance(x, str)}
else:
    defaults_models = {}
defaults['models'] = defaults_models

SUPPORTED_APIS = {'openai-completions', 'openai-responses'}

changed = False
fatal_errors = []
summary = []


def model_ref(provider_name, model_id):
    return f"{provider_name}/{model_id}"


def get_primary_ref(defaults_obj):
    model_obj = defaults_obj.get('model')
    if isinstance(model_obj, str):
        return model_obj
    if isinstance(model_obj, dict):
        primary = model_obj.get('primary')
        if isinstance(primary, str):
            return primary
    return None


def set_primary_ref(defaults_obj, new_ref):
    model_obj = defaults_obj.get('model')
    if isinstance(model_obj, str):
        defaults_obj['model'] = new_ref
    elif isinstance(model_obj, dict):
        model_obj['primary'] = new_ref
    else:
        defaults_obj['model'] = {'primary': new_ref}


def ref_provider(ref):
    if not isinstance(ref, str) or '/' not in ref:
        return None
    return ref.split('/', 1)[0]


def collect_available_refs(exclude_provider=None):
    refs = []
    if not isinstance(providers, dict):
        return refs
    for pname, p in providers.items():
        if exclude_provider and pname == exclude_provider:
            continue
        if not isinstance(p, dict):
            continue
        for m in p.get('models', []) or []:
            if isinstance(m, dict) and m.get('id'):
                refs.append(model_ref(pname, str(m['id'])))
    return refs


def prompt_delete_provider(name):
    prompt = f"⚠️ {name} /models 探测连续失败 3 次。是否删除该 API 供应商及其全部相关模型？[y/N]: "
    try:
        ans = input(prompt).strip().lower()
    except EOFError:
        return False
    return ans in ('y', 'yes')


def rebind_defaults_before_delete(name):
    global changed

    replacement = None

    def get_replacement():
        nonlocal replacement
        if replacement is None:
            candidates = collect_available_refs(exclude_provider=name)
            replacement = candidates[0] if candidates else None
        return replacement

    primary_ref = get_primary_ref(defaults)
    if ref_provider(primary_ref) == name:
        repl = get_replacement()
        if not repl:
            summary.append(f'❌ {name}: 默认主模型指向该 provider，但无可用替代模型，已中止删除')
            return False
        set_primary_ref(defaults, repl)
        changed = True
        summary.append(f'🔁 删除前已切换默认主模型: {primary_ref} -> {repl}')

    for fk in ('modelFallback', 'imageModelFallback'):
        val = defaults.get(fk)
        if ref_provider(val) == name:
            repl = get_replacement()
            if not repl:
                summary.append(f'❌ {name}: {fk} 指向该 provider，但无可用替代模型，已中止删除')
                return False
            defaults[fk] = repl
            changed = True
            summary.append(f'🔁 删除前已切换 {fk}: {val} -> {repl}')

    return True


def delete_provider_and_refs(name):
    global changed

    if not rebind_defaults_before_delete(name):
        return False

    removed_refs = [r for r in list(defaults_models.keys()) if r.startswith(name + '/')]
    for r in removed_refs:
        defaults_models.pop(r, None)
    if removed_refs:
        changed = True

    if name in providers:
        providers.pop(name, None)
        changed = True

    summary.append(f'🗑️ 已删除 provider {name}，并移除 defaults.models 下 {len(removed_refs)} 个模型引用')
    return True


def fetch_remote_models_with_retry(name, base_url, api_key, retries=3):
    last_error = None
    for attempt in range(1, retries + 1):
        req = urllib.request.Request(
            base_url.rstrip('/') + '/models',
            headers={
                'Authorization': f'Bearer {api_key}',
                'User-Agent': 'Mozilla/5.0',
            },
        )
        try:
            with urllib.request.urlopen(req, timeout=12) as resp:
                payload = resp.read().decode('utf-8', 'ignore')
            data = json.loads(payload)
            return data, None, attempt
        except Exception as e:
            last_error = e
            if attempt < retries:
                time.sleep(1)
    return None, last_error, retries


for name, provider in list(providers.items()):
    if not isinstance(provider, dict):
        summary.append(f'ℹ️ 跳过 {name}: provider 结构非法')
        continue

    api = provider.get('api', '')
    base_url = provider.get('baseUrl')
    api_key = provider.get('apiKey')
    model_list = provider.get('models', [])

    if not base_url or not api_key or not isinstance(model_list, list) or not model_list:
        summary.append(f'ℹ️ 跳过 {name}: 无 baseUrl/apiKey/models')
        continue

    if api not in SUPPORTED_APIS:
        summary.append(f'🔁 {name}: 发现非法协议 {api or "(unset)"}，将重新探测')
        provider['api'] = ''
        api = ''
        changed = True

    data, err, attempts = fetch_remote_models_with_retry(name, base_url, api_key, retries=3)
    if err is not None:
        summary.append(f'⚠️ {name}: /models 探测失败，已重试 {attempts} 次 ({type(err).__name__}: {err})')
        send_stat('OpenClaw API确认介入')
        if prompt_delete_provider(name):
            deleted = delete_provider_and_refs(name)
            if deleted:
                send_stat('OpenClaw API删失败Provider-确认')
                summary.append(f'✅ {name}: 用户已确认删除该 provider 及全部相关模型引用')
        else:
            send_stat('OpenClaw API删失败Provider-拒绝')
            summary.append(f'ℹ️ {name}: 用户未确认删除，保留现有 provider 配置')
        continue

    if attempts > 1:
        summary.append(f'🔁 {name}: /models 第 {attempts} 次重试后成功')

    if not (isinstance(data, dict) and isinstance(data.get('data'), list)):
        summary.append(f'⚠️ 跳过 {name}: /models 返回结构不可识别')
        continue

    remote_ids = []
    for item in data['data']:
        if isinstance(item, dict) and item.get('id'):
            remote_ids.append(str(item['id']))
    remote_set = set(remote_ids)

    if not remote_set:
        fatal_errors.append(f'❌ {name} 上游 /models 为空，无法为该 provider 提供兜底模型')
        continue

    local_models = [m for m in model_list if isinstance(m, dict) and m.get('id')]
    local_ids = [str(m['id']) for m in local_models]
    local_set = set(local_ids)

    template = None
    for m in local_models:
        template = copy.deepcopy(m)
        break
    if template is None:
        summary.append(f'⚠️ 跳过 {name}: 本地 models 无有效模板模型')
        continue

    removed_ids = [mid for mid in local_ids if mid not in remote_set]
    added_ids = [mid for mid in remote_ids if mid not in local_set]

    kept_models = [copy.deepcopy(m) for m in local_models if str(m['id']) in remote_set]
    new_models = kept_models[:]

    for mid in added_ids:
        nm = copy.deepcopy(template)
        nm['id'] = mid
        if isinstance(nm.get('name'), str):
            nm['name'] = f'{name} / {mid}'
        new_models.append(nm)

    if not new_models:
        fatal_errors.append(f'❌ {name} 同步后无可用模型，无法保障默认模型/回退模型兜底')
        continue

    expected_refs = {model_ref(name, str(m['id'])) for m in new_models if isinstance(m, dict) and m.get('id')}
    local_refs = {model_ref(name, mid) for mid in local_ids}

    first_ref = model_ref(name, str(new_models[0]['id']))

    primary_ref = get_primary_ref(defaults)
    if isinstance(primary_ref, str) and primary_ref in (local_refs - expected_refs):
        set_primary_ref(defaults, first_ref)
        changed = True
        summary.append(f'🔁 默认模型已兜底替换: {primary_ref} -> {first_ref}')

    for fk in ('modelFallback', 'imageModelFallback'):
        val = defaults.get(fk)
        if isinstance(val, str) and val in (local_refs - expected_refs):
            defaults[fk] = first_ref
            changed = True
            summary.append(f'🔁 {fk} 已兜底替换: {val} -> {first_ref}')

    stale_refs = [r for r in list(defaults_models.keys()) if r.startswith(name + '/') and r not in expected_refs]
    for r in stale_refs:
        defaults_models.pop(r, None)
        changed = True

    for r in sorted(expected_refs):
        if r not in defaults_models:
            defaults_models[r] = {}
            changed = True

    if removed_ids or added_ids or len(local_models) != len(new_models):
        provider['models'] = new_models
        changed = True

    summary.append(f'✅ {name}: 新增 {len(added_ids)} 个，删除 {len(removed_ids)} 个，当前 {len(new_models)} 个')

    if added_ids:
        summary.append(f'➕ 新增模型({len(added_ids)}):')
        for mid in added_ids:
            summary.append(f'  + {mid}')
    if removed_ids:
        summary.append(f'➖ 删除模型({len(removed_ids)}):')
        for mid in removed_ids:
            summary.append(f'  - {mid}')


if fatal_errors:
    for line in summary:
        print(line)
    for err in fatal_errors:
        print(err)
    print('❌ 模型同步失败：存在 provider 同步后无可用模型，已中止写入')
    raise SystemExit(2)

if changed:
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(work, f, ensure_ascii=False, indent=2)
        f.write('\n')
    for line in summary:
        print(line)
    print('✅ OpenClaw API 模型一致性同步完成并已写入配置')
else:
    for line in summary:
        print(line)
    print('ℹ️ 无需同步：配置已与上游 /models 保持一致')
PY
	}



	install_moltbot() {
		echo "开始安装 OpenClaw..."
		send_stats "开始安装 OpenClaw..."
		install git jq

		install_node_and_tools

		country=$(curl -s ipinfo.io/country)
		if [[ "$country" == "CN" || "$country" == "HK" ]]; then
			npm config set registry https://registry.npmmirror.com
		fi

		git config --global url."${gh_proxy}github.com/".insteadOf ssh://git@github.com/
		git config --global url."${gh_proxy}github.com/".insteadOf git@github.com:

		npm install -g openclaw@latest
		openclaw onboard --install-daemon
		start_gateway
		add_app_id
		break_end

	}


	start_bot() {
		echo "启动 OpenClaw..."
		send_stats "启动 OpenClaw..."
		start_gateway
		break_end
	}

	stop_bot() {
		echo "停止 OpenClaw..."
		send_stats "停止 OpenClaw..."
		tmux kill-session -t gateway > /dev/null 2>&1
		openclaw gateway stop
		break_end
	}

	view_logs() {
		echo "查看 OpenClaw 状态日志"
		send_stats "查看 OpenClaw 日志"
		openclaw status
		openclaw gateway status
		openclaw logs
		break_end
	}





	# OpenClaw API 协议探测逻辑已移除：不再自动探测/判定 API 类型。
	# 说明：API 类型由用户显式配置（models.providers.<name>.api），脚本不再尝试调用 /responses 做推断。

	# 构造模型配置 JSON
	build-openclaw-provider-models-json() {
		local provider_name="$1"
		local model_ids="$2"
		local models_array="["
		local first=true

		while read -r model_id; do
			[ -z "$model_id" ] && continue
			[[ $first == false ]] && models_array+=","
			first=false

			local context_window=1048576
			local max_tokens=128000
			local input_cost=0.15
			local output_cost=0.60

			case "$model_id" in
				*opus*|*pro*|*preview*|*thinking*|*sonnet*)
					input_cost=2.00
					output_cost=12.00
					;;
				*gpt-5*|*codex*)
					input_cost=1.25
					output_cost=10.00
					;;
				*flash*|*lite*|*haiku*|*mini*|*nano*)
					input_cost=0.10
					output_cost=0.40
					;;
			esac

			models_array+=$(cat <<EOF
{
	"id": "$model_id",
	"name": "$provider_name / $model_id",
	"input": ["text", "image"],
	"contextWindow": $context_window,
	"maxTokens": $max_tokens,
	"cost": {
		"input": $input_cost,
		"output": $output_cost,
		"cacheRead": 0,
		"cacheWrite": 0
	}
}
EOF
)
		done <<< "$model_ids"

		models_array+="]"
		echo "$models_array"
	}

	# 写入 provider 与模型配置
	write-openclaw-provider-models() {
		local provider_name="$1"
		local base_url="$2"
		local api_key="$3"
		local models_array="$4"
		local config_file
		config_file=$(openclaw_get_config_file)

		# 不再自动探测/纠正 API 协议；保持用户配置为准
		DETECTED_API="openai-completions"

		[[ -f "$config_file" ]] && cp "$config_file" "${config_file}.bak.$(date +%s)"

		jq --arg prov "$provider_name" \
		   --arg url "$base_url" \
		   --arg key "$api_key" \
		   --arg api "$DETECTED_API" \
		   --argjson models "$models_array" \
		'
		.models |= (
			(. // { mode: "merge", providers: {} })
			| .mode = "merge"
			| .providers[$prov] = {
				baseUrl: $url,
				apiKey: $key,
				api: $api,
				models: $models
			}
		)
		| .agents |= (. // {})
		| .agents.defaults |= (. // {})
		| .agents.defaults.models |= (
			(if type == "object" then .
			 elif type == "array" then reduce .[] as $m ({}; if ($m|type) == "string" then .[$m] = {} else . end)
			 else {}
			 end) as $existing
			| reduce ($models[]? | .id? // empty | tostring) as $mid (
				$existing;
				if ($mid | length) > 0 then
					.["\($prov)/\($mid)"] //= {}
				else
					.
				end
			)
		)
		' "$config_file" > "${config_file}.tmp" && mv "${config_file}.tmp" "$config_file"
	}

	# 核心函数：获取并添加所有模型
	add-all-models-from-provider() {
		local provider_name="$1"
		local base_url="$2"
		local api_key="$3"

		echo "🔍 正在获取 $provider_name 的所有可用模型..."

		local models_json=$(curl -s -m 10 \
			-H "Authorization: Bearer $api_key" \
			"${base_url}/models")

		if [[ -z "$models_json" ]]; then
			echo "❌ 无法获取模型列表"
			return 1
		fi

		local model_ids=$(echo "$models_json" | sed -n 's/.*"id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')

		if [[ -z "$model_ids" ]]; then
			echo "❌ 未找到任何模型"
			return 1
		fi

		local model_count=$(echo "$model_ids" | wc -l)
		echo "✅ 发现 $model_count 个模型"

		local models_array
		models_array=$(build-openclaw-provider-models-json "$provider_name" "$model_ids")

		write-openclaw-provider-models "$provider_name" "$base_url" "$api_key" "$models_array"

		if [[ $? -eq 0 ]]; then
			echo "✅ 成功添加 $model_count 个模型到 $provider_name"
			echo "📦 模型引用格式: $provider_name/<model-id>"
			return 0
		else
			echo "❌ 配置注入失败"
			return 1
		fi
	}

	# 仅添加默认模型并保留 provider
	add-default-model-only-to-provider() {
		local provider_name="$1"
		local base_url="$2"
		local api_key="$3"
		local default_model="$4"

		if [[ -z "$default_model" ]]; then
			echo "❌ 默认模型不能为空"
			return 1
		fi

		local models_array
		models_array=$(build-openclaw-provider-models-json "$provider_name" "$default_model")

		write-openclaw-provider-models "$provider_name" "$base_url" "$api_key" "$models_array"

		if [[ $? -eq 0 ]]; then
			echo "✅ 已添加 provider：$provider_name"
			echo "✅ 仅写入默认模型：$default_model"
			return 0
		else
			echo "❌ 配置注入失败"
			return 1
		fi
	}

	add-openclaw-provider-interactive() {
		send_stats "OpenClaw API添加"
		echo -e "${rw_cheng}=== 交互式添加 OpenClaw Provider (全量模型) ===${rw_lv}"

		# 1. Provider 名称
		read -erp "请输入 Provider 名称 (如: deepseek): " provider_name
		while [[ -z "$provider_name" ]]; do
			echo "❌ Provider 名称不能为空"
			read -erp "请输入 Provider 名称: " provider_name
		done

		# 2. Base URL
		read -erp "请输入 Base URL (如: https://api.xxx.com/v1): " base_url
		while [[ -z "$base_url" ]]; do
			echo "❌ Base URL 不能为空"
			read -erp "请输入 Base URL: " base_url
		done
		base_url="${base_url%/}"

		# 3. API Key
		read -rsp "请输入 API Key (输入不显示): " api_key
		echo
		while [[ -z "$api_key" ]]; do
			echo "❌ API Key 不能为空"
			read -rsp "请输入 API Key: " api_key
			echo
		done

		# 4. 不再探测/判断 API 类型；协议由用户自行选择与维护

		# 5. 获取模型列表
		echo "🔍 正在获取可用模型列表..."
		models_json=$(curl -s -m 10 \
			-H "Authorization: Bearer $api_key" \
			"${base_url}/models")

		if [[ -n "$models_json" ]]; then
			available_models=$(echo "$models_json" | sed -n 's/.*"id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | sort)

			if [[ -n "$available_models" ]]; then
				model_count=$(echo "$available_models" | wc -l)
				echo "✅ 发现 $model_count 个可用模型："
				echo -e "${rw_cheng}--------------------------------${rw_lv}"
				# 全部显示，带序号
				i=1
				model_list=()
				while read -r model; do
					echo "[$i] $model"
					model_list+=("$model")
					((i++))
				done <<< "$available_models"
				echo -e "${rw_cheng}--------------------------------${rw_lv}"
			fi
		fi

		# 5. 选择默认模型
		echo
		read -erp "请输入默认 Model ID (或序号，留空则使用第一个): " input_model

		if [[ -z "$input_model" && -n "$available_models" ]]; then
			default_model=$(echo "$available_models" | head -1)
			echo "🎯 使用第一个模型: $default_model"
		elif [[ "$input_model" =~ ^[0-9]+$ ]] && [ "${#model_list[@]}" -gt 0 ] && [ "$input_model" -ge 1 ] && [ "$input_model" -le "${#model_list[@]}" ]; then
			default_model="${model_list[$((input_model-1))]}"
			echo "🎯 已选择模型: $default_model"
		else
			default_model="$input_model"
		fi

		# 6. 确认信息
		echo
		echo -e "${rw_cheng}====== 确认信息 ======${rw_lv}"
		echo "Provider    : $provider_name"
		echo "Base URL    : $base_url"
		echo "API Key     : ${api_key:0:8}****"
		echo "默认模型    : $default_model"
		echo "模型总数    : $model_count"
		echo -e "${rw_cheng}======================${rw_lv}"

		read -erp "是否同时添加其他所有可用模型？(y/N): " confirm

		install jq
		if [[ "$confirm" =~ ^[Yy]$ ]]; then
			add-all-models-from-provider "$provider_name" "$base_url" "$api_key"
			add_result=$?
			finish_msg="✅ 完成！所有 $model_count 个模型已加载"
		else
			add-default-model-only-to-provider "$provider_name" "$base_url" "$api_key" "$default_model"
			add_result=$?
			finish_msg="✅ 完成！已保留 provider，并仅加载默认模型：$default_model"
		fi

		if [[ $add_result -eq 0 ]]; then
			echo
			echo "🔄 设置默认模型并重启网关..."
			openclaw models set "$provider_name/$default_model"
			openclaw_sync_sessions_model "$provider_name/$default_model"
			start_gateway
			echo "$finish_msg"
			echo "✅ 当前 API 协议类型: $DETECTED_API"
		fi

		break_end
	}



openclaw_api_manage_list() {
	local config_file="${HOME}/.openclaw/openclaw.json"
	send_stats "OpenClaw API列表"

	while IFS=$'\t' read -r rec_type idx name base_url model_count api_type latency_txt latency_level; do
		case "$rec_type" in
			MSG)
				echo "$idx"
				;;
			ROW)
				local latency_color="$rw_bai"
				case "$latency_level" in
					low) latency_color="$rw_lv" ;;
					medium) latency_color="$rw_huang" ;;
					high|unavailable) latency_color="$rw_hong" ;;
					unchecked) latency_color="$rw_bai" ;;
				esac

				printf '%b\n' "[$idx] ${name} | API: ${base_url} | 协议: ${api_type} | 模型数量: ${rw_huang}${model_count}${rw_lv} | 延迟/状态: ${latency_color}${latency_txt}${rw_lv}"
				;;
		esac
	done < <(python3 - "$config_file" <<-'PY'
import json
import sys
import time
import urllib.request

path = sys.argv[1]
SUPPORTED_APIS = {'openai-completions', 'openai-responses'}


def ping_models(base_url, api_key):
    req = urllib.request.Request(
        base_url.rstrip('/') + '/models',
        headers={
            'Authorization': f'Bearer {api_key}',
            'User-Agent': 'OpenClaw-API-Manage/1.0',
        },
    )
    start = time.perf_counter()
    with urllib.request.urlopen(req, timeout=4) as resp:
        resp.read(2048)
    return int((time.perf_counter() - start) * 1000)


def classify_latency(latency):
    if latency == '不可用':
        return '不可用', 'unavailable'
    if latency == '未检测':
        return '未检测', 'unchecked'
    if isinstance(latency, int):
        if latency <= 800:
            level = 'low'
        elif latency <= 2000:
            level = 'medium'
        else:
            level = 'high'
        return f'{latency}ms', level
    return str(latency), 'unchecked'


try:
    with open(path, 'r', encoding='utf-8') as f:
        obj = json.load(f)
except FileNotFoundError:
    print('MSG\tℹ️ 未找到 openclaw.json，请先完成安装/初始化。')
    raise SystemExit(0)
except Exception as e:
    print(f'MSG\t❌ 读取配置失败: {type(e).__name__}: {e}')
    raise SystemExit(0)

providers = ((obj.get('models') or {}).get('providers') or {})
if not isinstance(providers, dict) or not providers:
    print('MSG\tℹ️ 当前未配置任何 API provider。')
    raise SystemExit(0)

print('MSG\t--- 已配置 API 列表 ---')

for idx, name in enumerate(sorted(providers.keys()), start=1):
    provider = providers.get(name)
    if not isinstance(provider, dict):
        base_url = '-'
        model_count = 0
        latency_raw = '不可用'
    else:
        base_url = provider.get('baseUrl') or provider.get('url') or provider.get('endpoint') or '-'
        models = provider.get('models') if isinstance(provider.get('models'), list) else []
        model_count = sum(1 for m in models if isinstance(m, dict) and m.get('id'))
        api = provider.get('api', '')
        api_key = provider.get('apiKey')

        latency_raw = '未检测'
        if api in SUPPORTED_APIS:
            if isinstance(base_url, str) and base_url != '-' and isinstance(api_key, str) and api_key:
                try:
                    latency_raw = ping_models(base_url, api_key)
                except Exception:
                    latency_raw = '不可用'
            else:
                latency_raw = '不可用'

    latency_text, latency_level = classify_latency(latency_raw)
    api_label = api if api in SUPPORTED_APIS else '-'
    print(
        'ROW\t' + '\t'.join([
            str(idx),
            str(name),
            str(base_url),
            str(model_count),
            str(api_label),
            str(latency_text),
            str(latency_level),
        ])
    )
PY
)
}
sync-openclaw-provider-interactive() {
	local config_file="${HOME}/.openclaw/openclaw.json"
	send_stats "OpenClaw API按Provider同步"

	if [ ! -f "$config_file" ]; then
		echo "❌ 未找到配置文件: $config_file"
		break_end
		return 1
	fi

	read -erp "请输入要同步的 API 名称(provider)，直接回车同步全部: " provider_name
	if [ -z "$provider_name" ]; then
		if sync_openclaw_api_models; then
			start_gateway
		else
			echo "❌ API 模型同步失败，已中止重启网关。请检查 provider /models 返回后重试。"
			return 1
		fi
		break_end
		return 0
	fi

	install jq curl >/dev/null 2>&1

	python3 - "$config_file" "$provider_name" <<'PY2'
import copy
import json
import sys
import time
import urllib.request

path = sys.argv[1]
target = sys.argv[2]
SUPPORTED_APIS = {'openai-completions', 'openai-responses'}

with open(path, 'r', encoding='utf-8') as f:
    obj = json.load(f)

work = copy.deepcopy(obj)
models_cfg = work.setdefault('models', {})
providers = models_cfg.get('providers', {})
if not isinstance(providers, dict) or not providers:
    print('❌ 未检测到 API providers，无法同步')
    raise SystemExit(2)

provider = providers.get(target)
if not isinstance(provider, dict):
    print(f'❌ 未找到 provider: {target}')
    raise SystemExit(2)

agents = work.setdefault('agents', {})
defaults = agents.setdefault('defaults', {})
defaults_models_raw = defaults.get('models')
if isinstance(defaults_models_raw, dict):
    defaults_models = defaults_models_raw
elif isinstance(defaults_models_raw, list):
    defaults_models = {str(x): {} for x in defaults_models_raw if isinstance(x, str)}
else:
    defaults_models = {}
defaults['models'] = defaults_models


def model_ref(provider_name, model_id):
    return f"{provider_name}/{model_id}"


def get_primary_ref(defaults_obj):
    model_obj = defaults_obj.get('model')
    if isinstance(model_obj, str):
        return model_obj
    if isinstance(model_obj, dict):
        primary = model_obj.get('primary')
        if isinstance(primary, str):
            return primary
    return None


def set_primary_ref(defaults_obj, new_ref):
    model_obj = defaults_obj.get('model')
    if isinstance(model_obj, str):
        defaults_obj['model'] = new_ref
    elif isinstance(model_obj, dict):
        model_obj['primary'] = new_ref
    else:
        defaults_obj['model'] = {'primary': new_ref}


def fetch_remote_models_with_retry(base_url, api_key, retries=3):
    last_error = None
    for attempt in range(1, retries + 1):
        req = urllib.request.Request(
            base_url.rstrip('/') + '/models',
            headers={
                'Authorization': f'Bearer {api_key}',
                'User-Agent': 'Mozilla/5.0',
            },
        )
        try:
            with urllib.request.urlopen(req, timeout=12) as resp:
                payload = resp.read().decode('utf-8', 'ignore')
            return json.loads(payload), None, attempt
        except Exception as e:
            last_error = e
            if attempt < retries:
                time.sleep(1)
    return None, last_error, retries


api = provider.get('api', '')
base_url = provider.get('baseUrl')
api_key = provider.get('apiKey')
model_list = provider.get('models', [])

if not base_url or not api_key or not isinstance(model_list, list) or not model_list:
    print(f'❌ provider {target} 缺少 baseUrl/apiKey/models，无法执行同步')
    raise SystemExit(3)

if api not in SUPPORTED_APIS:
    print(f'ℹ️ provider {target} 当前 api={api}，但脚本已不再探测/纠正协议；请手动设置为 openai-completions 或 openai-responses')

protocol_msg = None

data, err, attempts = fetch_remote_models_with_retry(base_url, api_key, retries=3)
if err is not None:
    print(f'❌ {target}: /models 探测失败，已重试 {attempts} 次 ({type(err).__name__}: {err})')
    raise SystemExit(4)

if not (isinstance(data, dict) and isinstance(data.get('data'), list)):
    print(f'❌ {target}: /models 返回结构不可识别')
    raise SystemExit(4)

remote_ids = []
for item in data['data']:
    if isinstance(item, dict) and item.get('id'):
        remote_ids.append(str(item['id']))
remote_set = set(remote_ids)
if not remote_set:
    print(f'❌ {target}: 上游 /models 为空，已中止同步')
    raise SystemExit(5)

local_models = [m for m in model_list if isinstance(m, dict) and m.get('id')]
local_ids = [str(m['id']) for m in local_models]
local_set = set(local_ids)

template = copy.deepcopy(local_models[0]) if local_models else None
if template is None:
    print(f'❌ {target}: 本地 models 无有效模板模型，无法补全新增模型')
    raise SystemExit(3)

removed_ids = [mid for mid in local_ids if mid not in remote_set]
added_ids = [mid for mid in remote_ids if mid not in local_set]

kept_models = [copy.deepcopy(m) for m in local_models if str(m['id']) in remote_set]
new_models = kept_models[:]
for mid in added_ids:
    nm = copy.deepcopy(template)
    nm['id'] = mid
    if isinstance(nm.get('name'), str):
        nm['name'] = f'{target} / {mid}'
    new_models.append(nm)

if not new_models:
    print(f'❌ {target}: 同步后无可用模型，已中止写入')
    raise SystemExit(5)

expected_refs = {model_ref(target, str(m['id'])) for m in new_models if isinstance(m, dict) and m.get('id')}
local_refs = {model_ref(target, mid) for mid in local_ids}
removed_refs = local_refs - expected_refs
first_ref = model_ref(target, str(new_models[0]['id']))

changed = False
primary_ref = get_primary_ref(defaults)
if isinstance(primary_ref, str) and primary_ref in removed_refs:
    set_primary_ref(defaults, first_ref)
    changed = True
    print(f'🔁 默认模型已兜底替换: {primary_ref} -> {first_ref}')

for fk in ('modelFallback', 'imageModelFallback'):
    val = defaults.get(fk)
    if isinstance(val, str) and val in removed_refs:
        defaults[fk] = first_ref
        changed = True
        print(f'🔁 {fk} 已兜底替换: {val} -> {first_ref}')

stale_refs = [r for r in list(defaults_models.keys()) if r.startswith(target + '/') and r not in expected_refs]
for r in stale_refs:
    defaults_models.pop(r, None)
    changed = True

for r in sorted(expected_refs):
    if r not in defaults_models:
        defaults_models[r] = {}
        changed = True

if removed_ids or added_ids or len(local_models) != len(new_models):
    provider['models'] = new_models
    changed = True


if changed:
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(work, f, ensure_ascii=False, indent=2)
        f.write('\n')

print(f'✅ {target}: 新增 {len(added_ids)} 个，删除 {len(removed_ids)} 个，当前 {len(new_models)} 个')

if added_ids:
    print(f'➕ 新增模型({len(added_ids)}):')
    for mid in added_ids:
        print(f'  + {mid}')
if removed_ids:
    print(f'➖ 删除模型({len(removed_ids)}):')
    for mid in removed_ids:
        print(f'  - {mid}')

if changed:
    print('✅ 指定 provider 模型一致性同步完成并已写入配置')
else:
    print('ℹ️ 无需同步：该 provider 配置已与上游 /models 保持一致')
PY2
	local rc=$?
	case "$rc" in
		0)
			echo "✅ 同步执行完成"
			start_gateway
			;;
		2)
			echo "❌ 同步失败：provider 不存在或未配置"
			;;
		3)
			echo "❌ 同步失败：provider 配置不完整或类型不支持"
			;;
		4)
			echo "❌ 同步失败：上游 /models 请求失败"
			;;
		5)
			echo "❌ 同步失败：上游模型为空或同步后无可用模型"
			;;
		*)
			echo "❌ 同步失败：请检查配置文件结构或日志输出"
			;;
	esac

	break_end
}

openclaw_detect_api_protocol_by_provider() {
	# 协议探测逻辑已移除：脚本不再自动探测/判定 API 类型。
	# 保留函数以兼容菜单调用，但不做任何改写。
	echo "ℹ️ 已关闭协议探测：请手动在 ${HOME}/.openclaw/openclaw.json 中设置 provider.api 为 openai-completions 或 openai-responses"
	return 0
}

fix-openclaw-provider-protocol-interactive() {
	local config_file="${HOME}/.openclaw/openclaw.json"
	send_stats "OpenClaw API协议切换"

	if [ ! -f "$config_file" ]; then
		echo "❌ 未找到配置文件: $config_file"
		break_end
		return 1
	fi

	read -erp "请输入要切换协议的 API 名称(provider): " provider_name
	if [ -z "$provider_name" ]; then
		echo "❌ provider 名称不能为空"
		break_end
		return 1
	fi

	echo "请选择要设置的 API 类型："
	echo "1. openai-completions"
	echo "2. openai-responses"
	read -erp "请输入你的选择 (1/2): " proto_choice

	local new_api=""
	case "$proto_choice" in
		1) new_api="openai-completions" ;;
		2) new_api="openai-responses" ;;
		*)
			echo "❌ 无效选择"
			break_end
			return 1
			;;
	esac

	install python3 >/dev/null 2>&1

	python3 - "$config_file" "$provider_name" "$new_api" <<'PY'
import copy
import json
import sys

path = sys.argv[1]
name = sys.argv[2]
new_api = sys.argv[3]

SUPPORTED_APIS = {'openai-completions', 'openai-responses'}
if new_api not in SUPPORTED_APIS:
    print('❌ 非法协议值')
    raise SystemExit(3)

with open(path, 'r', encoding='utf-8') as f:
    obj = json.load(f)

work = copy.deepcopy(obj)
providers = ((work.get('models') or {}).get('providers') or {})
if not isinstance(providers, dict) or name not in providers or not isinstance(providers.get(name), dict):
    print(f'❌ 未找到 provider: {name}')
    raise SystemExit(2)

providers[name]['api'] = new_api

with open(path, 'w', encoding='utf-8') as f:
    json.dump(work, f, ensure_ascii=False, indent=2)
    f.write('\n')

print(f'✅ 已更新 provider {name} 协议为: {new_api}')
PY
	local rc=$?
	case "$rc" in
		0)
			start_gateway
			;;
		2)
			echo "❌ 切换失败：provider 不存在或未配置"
			;;
		3)
			echo "❌ 切换失败：协议值非法"
			;;
		*)
			echo "❌ 切换失败：请检查配置文件结构或日志输出"
			;;
	esac

	break_end
}

	delete-openclaw-provider-interactive() {
		local config_file
		config_file=$(openclaw_get_config_file)
		send_stats "OpenClaw API删除入口"

		if [ ! -f "$config_file" ]; then
			echo "❌ 未找到配置文件: $config_file"
			break_end
			return 1
		fi

		read -erp "请输入要删除的 API 名称(provider): " provider_name
		if [ -z "$provider_name" ]; then
			send_stats "OpenClaw API删除取消"
			echo "❌ provider 名称不能为空"
			break_end
			return 1
		fi

		python3 - "$config_file" "$provider_name" <<'PY'
import copy
import json
import sys

path = sys.argv[1]
name = sys.argv[2]

with open(path, 'r', encoding='utf-8') as f:
    obj = json.load(f)

work = copy.deepcopy(obj)
models_cfg = work.setdefault('models', {})
providers = models_cfg.get('providers', {})
if not isinstance(providers, dict) or name not in providers:
    print(f'❌ 未找到 provider: {name}')
    raise SystemExit(2)

agents = work.setdefault('agents', {})
defaults = agents.setdefault('defaults', {})
defaults_models_raw = defaults.get('models')
if isinstance(defaults_models_raw, dict):
    defaults_models = defaults_models_raw
elif isinstance(defaults_models_raw, list):
    defaults_models = {str(x): {} for x in defaults_models_raw if isinstance(x, str)}
else:
    defaults_models = {}
defaults['models'] = defaults_models


def model_ref(provider_name, model_id):
    return f"{provider_name}/{model_id}"


def ref_provider(ref):
    if not isinstance(ref, str) or '/' not in ref:
        return None
    return ref.split('/', 1)[0]


def get_primary_ref(defaults_obj):
    model_obj = defaults_obj.get('model')
    if isinstance(model_obj, str):
        return model_obj
    if isinstance(model_obj, dict):
        primary = model_obj.get('primary')
        if isinstance(primary, str):
            return primary
    return None


def set_primary_ref(defaults_obj, new_ref):
    model_obj = defaults_obj.get('model')
    if isinstance(model_obj, str):
        defaults_obj['model'] = new_ref
    elif isinstance(model_obj, dict):
        model_obj['primary'] = new_ref
    else:
        defaults_obj['model'] = {'primary': new_ref}


def collect_available_refs(exclude_provider=None):
    refs = []
    if not isinstance(providers, dict):
        return refs
    for pname, p in providers.items():
        if exclude_provider and pname == exclude_provider:
            continue
        if not isinstance(p, dict):
            continue
        for m in p.get('models', []) or []:
            if isinstance(m, dict) and m.get('id'):
                refs.append(model_ref(pname, str(m['id'])))
    return refs


replacement_candidates = collect_available_refs(exclude_provider=name)
replacement = replacement_candidates[0] if replacement_candidates else None

primary_ref = get_primary_ref(defaults)
if ref_provider(primary_ref) == name:
    if not replacement:
        print('❌ 删除中止：默认主模型指向该 provider，且无可用替代模型')
        raise SystemExit(3)
    set_primary_ref(defaults, replacement)
    print(f'🔁 默认主模型切换: {primary_ref} -> {replacement}')

for fk in ('modelFallback', 'imageModelFallback'):
    val = defaults.get(fk)
    if ref_provider(val) == name:
        if not replacement:
            print(f'❌ 删除中止：{fk} 指向该 provider，且无可用替代模型')
            raise SystemExit(3)
        defaults[fk] = replacement
        print(f'🔁 {fk} 切换: {val} -> {replacement}')

removed_refs = [r for r in list(defaults_models.keys()) if r.startswith(name + '/')]
for r in removed_refs:
    defaults_models.pop(r, None)

providers.pop(name, None)

with open(path, 'w', encoding='utf-8') as f:
    json.dump(work, f, ensure_ascii=False, indent=2)
    f.write('\n')

print(f'🗑️ 已删除 provider: {name}')
print(f'🧹 已清理 defaults.models 中 {len(removed_refs)} 个关联模型引用')
PY
		local rc=$?
		case "$rc" in
			0)
				send_stats "OpenClaw API删除确认"
				echo "✅ 删除完成"
				start_gateway
				;;
			2)
				echo "❌ 删除失败：provider 不存在"
				;;
			3)
				send_stats "OpenClaw API删除取消"
				echo "❌ 删除失败：无可用替代模型，已保持原配置"
				;;
			*)
				echo "❌ 删除失败：请检查配置文件结构或日志输出"
				;;
		esac

		break_end
	}

	openclaw_api_providers_showcase() {
		send_stats "OpenClaw API厂商推荐"

		clear
		echo ""
		echo -e "${rw_huang}╔════════════════════════════════════════════════════════════╗${rw_lv}"
		echo -e "${rw_huang}║${rw_lv}            ${rw_huang}🌟 API 厂商推荐列表${rw_lv}                          ${rw_huang}║${rw_lv}"
		echo -e "${rw_huang}║${rw_lv}            ${rw_huang}部分入口含 AFF${rw_lv}                            ${rw_huang}║${rw_lv}"
		echo -e "${rw_huang}╚════════════════════════════════════════════════════════════╝${rw_lv}"
		echo ""
		echo -e "  ${rw_lv}● DeepSeek${rw_lv}"
		echo -e "    ${rw_huang}https://api-docs.deepseek.com/${rw_lv}"
		echo ""
		echo -e "  ${rw_lv}● OpenRouter${rw_lv}"
		echo -e "    ${rw_huang}https://openrouter.ai/${rw_lv}"
		echo ""
		echo -e "  ${rw_lv}● Kimi${rw_lv}"
		echo -e "    ${rw_huang}https://platform.moonshot.cn/docs/guide/start-using-kimi-api${rw_lv}"
		echo ""
		echo -e "  ${rw_lv}● 超算互联网${rw_lv}"
		echo -e "    ${rw_huang}https://www.scnet.cn/${rw_lv}"
		echo ""
		echo -e "  ${rw_huang}● 优云智算${rw_lv} ${rw_huang}[AFF]${rw_lv}"
		echo -e "    ${rw_huang}https://passport.compshare.cn/register?referral_code=4mscFZXfutfFi8swMVsPuf${rw_lv}"
		echo ""
		echo -e "  ${rw_huang}● 硅基流动${rw_lv} ${rw_huang}[AFF]${rw_lv}"
		echo -e "    ${rw_huang}https://cloud.siliconflow.cn/i/irWVdPic${rw_lv}"
		echo ""
		echo -e "  ${rw_huang}● 智谱 GLM${rw_lv} ${rw_huang}[AFF]${rw_lv}"
		echo -e "    ${rw_huang}https://www.bigmodel.cn/glm-coding?ic=HYOTDOAJMR${rw_lv}"
		echo ""
		echo -e "  ${rw_huang}● PackyAPI${rw_lv} ${rw_huang}[AFF]${rw_lv}"
		echo -e "    ${rw_huang}https://www.packyapi.com/register?aff=wHri${rw_lv}"
		echo ""
		echo -e "  ${rw_huang}● 云雾 API${rw_lv} ${rw_huang}[AFF]${rw_lv}"
		echo -e "    ${rw_huang}https://yunwu.ai/register?aff=ZuyK${rw_lv}"
		echo ""
		echo -e "  ${rw_huang}● 柏拉图AI${rw_lv} ${rw_huang}[AFF]${rw_lv}"
		echo -e "    ${rw_huang}https://api.bltcy.ai/register?aff=TBzb114019${rw_lv}"
		echo ""
		echo -e "  ${rw_lv}● MiniMax${rw_lv}"
		echo -e "    ${rw_huang}https://www.minimaxi.com/${rw_lv}"
		echo ""
		echo -e "  ${rw_lv}● NVIDIA${rw_lv}"
		echo -e "    ${rw_huang}https://build.nvidia.com/settings/api-keys${rw_lv}"
		echo ""
		echo -e "  ${rw_lv}● Ollama${rw_lv}"
		echo -e "    ${rw_huang}https://ollama.com/${rw_lv}"
		echo ""
		echo -e "  ${rw_lv}● 白山云${rw_lv}"
		echo -e "    ${rw_huang}https://ai.baishan.com/${rw_lv}"
		echo ""
		echo -e "${rw_huang}────────────────────────────────────────────────────────────${rw_lv}"
		echo -e "  ${rw_huang}图例：${rw_lv}● 官方入口${rw_lv}  ${rw_huang}● AFF 推荐入口${rw_lv}"
		echo ""
		echo -e "${rw_huang}提示：复制链接到浏览器打开即可访问${rw_lv}"
		echo ""
		read -erp "按回车键返回..." dummy
	}

	openclaw_api_manage_menu() {
		send_stats "OpenClaw API入口"
		while true; do
			clear
			echo -e "${rw_cheng}=======================================${rw_lv}"
			echo "OpenClaw API 管理"
			echo -e "${rw_cheng}=======================================${rw_lv}"
			openclaw_api_manage_list
			echo -e "${rw_cheng}---------------------------------------${rw_lv}"
			echo "1. 添加API"
			echo "2. 同步API供应商模型列表"
			echo "3. 切换 API 类型（completions / responses）"
			echo "4. 删除API"
			echo "5. API 厂商推荐"
			echo "0. 退出"
			echo -e "${rw_cheng}---------------------------------------${rw_lv}"
			read -erp "请输入你的选择: " api_choice

			case "$api_choice" in
				1)
					add-openclaw-provider-interactive
					;;
				2)
					sync-openclaw-provider-interactive
					;;
				3)
					fix-openclaw-provider-protocol-interactive
					;;
				4)
					delete-openclaw-provider-interactive
					;;
				5)
					openclaw_api_providers_showcase
					;;
				0)
					return 0
					;;
				*)
					echo "无效的选择，请重试。"
					sleep 1
					;;
			esac
		done
	}



	install_gum() {
	    if command -v gum >/dev/null 2>&1; then
	        return 0
	    fi

 		if command -v apt >/dev/null 2>&1; then
	        mkdir -p /etc/apt/keyrings
	        curl -fsSL https://repo.charm.sh/apt/gpg.key | gpg --dearmor -o /etc/apt/keyrings/charm.gpg
	        echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | tee /etc/apt/sources.list.d/charm.list > /dev/null
	        apt update && apt install -y gum
	    elif command -v dnf >/dev/null 2>&1 || command -v yum >/dev/null 2>&1; then
	        cat > /etc/yum.repos.d/charm.repo <<'REPO'
[charm]
name=Charm
baseurl=https://repo.charm.sh/yum/
enabled=1
gpgcheck=1
gpgkey=https://repo.charm.sh/yum/gpg.key
REPO
	        rpm --import https://repo.charm.sh/yum/gpg.key
	        if command -v dnf >/dev/null 2>&1; then
	            dnf install -y gum
	        else
	            yum install -y gum
	        fi
	    elif command -v zypper >/dev/null 2>&1; then
	        zypper --non-interactive refresh
	        zypper --non-interactive install gum
	    fi
	}



	change_model() {
		send_stats "换模型"

		local orange="#FF8C00"

		openclaw_probe_status_line() {
			local status_text="$1"
			local status_color_ok='[32m'
			local status_color_fail='[31m'
			local status_color_reset='[0m'
			if [ "$status_text" = "可用" ]; then
				printf "%b最小检测结果：%s%b
" "$status_color_ok" "$status_text" "$status_color_reset"
			else
				printf "%b最小检测结果：%s%b
" "$status_color_fail" "$status_text" "$status_color_reset"
			fi
		}

		openclaw_model_probe() {
			local target_model="$1"
			local probe_timeout=25
			local tmp_payload tmp_response probe_result probe_status reply_preview reply_trimmed
			local oc_config provider_name base_url api_key request_model
			local first_endpoint second_endpoint
			local first_exit first_http first_latency second_exit second_http second_latency
			local first_reply second_reply

			oc_config=$(openclaw_get_config_file)
			[ ! -f "$oc_config" ] && {
				OPENCLAW_PROBE_STATUS="ERROR"
				OPENCLAW_PROBE_MESSAGE="未找到 openclaw 配置文件"
				OPENCLAW_PROBE_LATENCY="-"
				OPENCLAW_PROBE_REPLY="-"
				return 1
			}

			provider_name="${target_model%%/*}"
			request_model="${target_model#*/}"
			base_url=$(jq -r --arg provider "$provider_name" '.models.providers[$provider].baseUrl // empty' "$oc_config" 2>/dev/null)
			api_key=$(jq -r --arg provider "$provider_name" '.models.providers[$provider].apiKey // empty' "$oc_config" 2>/dev/null)
			if [ -z "$provider_name" ] || [ -z "$base_url" ] || [ -z "$api_key" ]; then
				OPENCLAW_PROBE_STATUS="ERROR"
				OPENCLAW_PROBE_MESSAGE="未读取到 provider/baseUrl/apiKey"
				OPENCLAW_PROBE_LATENCY="-"
				OPENCLAW_PROBE_REPLY="-"
				return 1
			fi

			base_url="${base_url%/}"
			first_endpoint="/responses"
			second_endpoint="/chat/completions"

			openclaw_extract_probe_reply() {
				python3 - "$1" <<'PYTHON_EOF'
import json
import sys
from pathlib import Path
path = Path(sys.argv[1])
raw = path.read_text(encoding='utf-8', errors='replace').strip()
reply = ''
if raw:
    try:
        data = json.loads(raw)
        if isinstance(data, dict):
            choices = data.get('choices') or []
            if choices and isinstance(choices[0], dict):
                message = choices[0].get('message') or {}
                if isinstance(message, dict):
                    reply = message.get('content') or ''
            if not reply:
                output = data.get('output') or []
                if isinstance(output, list):
                    texts = []
                    for item in output:
                        if not isinstance(item, dict):
                            continue
                        for content in item.get('content') or []:
                            if not isinstance(content, dict):
                                continue
                            text = content.get('text')
                            if isinstance(text, str) and text.strip():
                                texts.append(text.strip())
                        if texts:
                            break
                    if texts:
                        reply = ' '.join(texts)
            if not reply:
                for key in ('error', 'message', 'detail'):
                    value = data.get(key)
                    if isinstance(value, str) and value.strip():
                        reply = value.strip()
                        break
                    if isinstance(value, dict):
                        nested = value.get('message')
                        if isinstance(nested, str) and nested.strip():
                            reply = nested.strip()
                            break
    except Exception:
        reply = raw
reply = ' '.join(str(reply).split())
print(reply)
PYTHON_EOF
			}

			openclaw_run_probe() {
				local endpoint="$1"
				tmp_payload=$(mktemp)
				tmp_response=$(mktemp)
				if [ "$endpoint" = "/responses" ]; then
					printf '{"model":"%s","input":"hi","temperature":0,"max_output_tokens":16}' "$request_model" > "$tmp_payload"
				else
					printf '{"model":"%s","messages":[{"role":"user","content":"hi"}],"temperature":0,"max_tokens":16}' "$request_model" > "$tmp_payload"
				fi

				probe_result=$(python3 - "$base_url" "$api_key" "$tmp_payload" "$tmp_response" "$probe_timeout" "$endpoint" <<'PYTHON_EOF'
import sys
import time
import urllib.error
import urllib.request

base_url, api_key, payload_path, response_path, timeout, endpoint = sys.argv[1:7]
timeout = int(timeout)
url = base_url + endpoint
payload = open(payload_path, 'rb').read()
req = urllib.request.Request(
    url,
    data=payload,
    headers={
        'Content-Type': 'application/json',
        'Authorization': f'Bearer {api_key}',
    },
    method='POST',
)
start = time.time()
body = b''
status = 0
exit_code = 0
try:
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        status = getattr(resp, 'status', 200)
        body = resp.read()
except urllib.error.HTTPError as e:
    status = getattr(e, 'code', 0) or 0
    body = e.read()
    exit_code = 22
except Exception as e:
    body = str(e).encode('utf-8', errors='replace')
    exit_code = 1
elapsed = int((time.time() - start) * 1000)
with open(response_path, 'wb') as f:
    f.write(body)
print(f"{exit_code}|{status}|{elapsed}")
PYTHON_EOF
)
				probe_status=$?
				reply_preview=$(openclaw_extract_probe_reply "$tmp_response")
				rm -f "$tmp_payload" "$tmp_response"
				return $probe_status
			}

			openclaw_run_probe "$first_endpoint"
			first_exit=${probe_result%%|*}
			first_http=${probe_result#*|}
			first_http=${first_http%%|*}
			first_latency=${probe_result##*|}
			first_reply="$reply_preview"

			reply_trimmed=$(printf '%s' "$first_reply" | cut -c1-120)
			[ -z "$reply_trimmed" ] && reply_trimmed="(空返回)"

			if [ "$first_exit" = "0" ] && [ "$first_http" -ge 200 ] && [ "$first_http" -lt 300 ]; then
				OPENCLAW_PROBE_STATUS="OK"
				OPENCLAW_PROBE_MESSAGE="${first_endpoint} -> HTTP ${first_http}"
				OPENCLAW_PROBE_LATENCY="${first_latency}ms"
				OPENCLAW_PROBE_REPLY="$reply_trimmed"
				return 0
			fi

			openclaw_run_probe "$second_endpoint"
			second_exit=${probe_result%%|*}
			second_http=${probe_result#*|}
			second_http=${second_http%%|*}
			second_latency=${probe_result##*|}
			second_reply="$reply_preview"

			reply_trimmed=$(printf '%s' "$second_reply" | cut -c1-120)
			[ -z "$reply_trimmed" ] && reply_trimmed="(空返回)"

			if [ "$second_exit" = "0" ] && [ "$second_http" -ge 200 ] && [ "$second_http" -lt 300 ]; then
				OPENCLAW_PROBE_STATUS="OK"
				OPENCLAW_PROBE_MESSAGE="${first_endpoint} -> HTTP ${first_http:-0}，切换 ${second_endpoint} -> HTTP ${second_http}"
				OPENCLAW_PROBE_LATENCY="${second_latency}ms"
				OPENCLAW_PROBE_REPLY="$reply_trimmed"
				return 0
			fi

			reply_trimmed=$(printf '%s' "$first_reply" | cut -c1-120)
			[ -z "$reply_trimmed" ] && reply_trimmed=$(printf '%s' "$second_reply" | cut -c1-120)
			[ -z "$reply_trimmed" ] && reply_trimmed="(空返回)"

			OPENCLAW_PROBE_STATUS="FAIL"
			OPENCLAW_PROBE_MESSAGE="${first_endpoint} -> HTTP ${first_http:-0} / exit ${first_exit:-1}；${second_endpoint} -> HTTP ${second_http:-0} / exit ${second_exit:-1}"
			OPENCLAW_PROBE_LATENCY="${first_latency:-?}ms -> ${second_latency:-?}ms"
			OPENCLAW_PROBE_REPLY="$reply_trimmed"
			return 1
		}

		clear

		while true; do
			local models_raw models_list default_model model_count selected_model confirm_switch

			# 从配置文件读取模型键（不调用 openclaw models list）
			local oc_config
			oc_config=$(openclaw_get_config_file)

			models_raw=$(jq -r '.agents.defaults.models | if type == "object" then keys[] else .[] end' "$oc_config" 2>/dev/null | sed '/^\s*$/d')
			if [ -z "$models_raw" ]; then
				echo "获取模型列表失败：配置文件中未找到 agents.defaults.models。"
				break_end
				return 1
			fi

			# 为每个模型加编号，便于快速定位（例如："(10) or-api/...:free"）
			models_list=$(echo "$models_raw" | awk '{print "(" NR ") " $0}')
			model_count=$(echo "$models_list" | sed '/^\s*$/d' | wc -l | tr -d ' ')

			# 从配置文件读取默认模型（更快）；失败再回退到 openclaw 命令
			default_model=$(jq -r '.agents.defaults.model.primary // empty' "$oc_config" 2>/dev/null)
			[ -z "$default_model" ] && default_model="(unknown)"

			clear

			install_gum
			install gum

			# 若 gum 不存在，降级为原始手动输入流程
			if ! command -v gum >/dev/null 2>&1 || ! gum --version >/dev/null 2>&1; then
				echo "--- 模型管理 ---"
				echo "当前可用模型:"
				jq -r '.agents.defaults.models | if type == "object" then keys[] else .[] end' "$oc_config" 2>/dev/null | sed '/^\s*$/d'
				echo -e "${rw_cheng}----------------${rw_lv}"
				read -e -p "请输入要设置的模型名称 (例如 openrouter/openai/gpt-4o)（输入 0 退出）： " selected_model

				if [ "$selected_model" = "0" ]; then
					echo "操作已取消，正在退出..."
					break
				fi

				if [ -z "$selected_model" ]; then
					echo "错误：模型名称不能为空。请重试。"
					echo ""
					continue
				fi

				echo "正在切换模型为: $selected_model ..."
				if ! openclaw models set "$selected_model"; then
					echo "切换失败：openclaw models set 返回错误。"
					break_end
					return 1
				fi
				openclaw_sync_sessions_model "$selected_model"
				start_gateway

				break_end
				return 0
			else
				if ! command -v gum >/dev/null 2>&1 || ! gum --version >/dev/null 2>&1; then
					echo "gum 不可用，返回旧版输入模式。"
					sleep 1
					continue
				fi
				gum style --foreground "$orange" --bold "模型管理"
				gum style --foreground "$orange" "可用模型（Auth=yes）：${model_count}"
				gum style --foreground "$orange" "当前默认：${default_model}"
				echo ""
				gum style --faint "↑↓ 选择 / Enter 测试 / Esc 退出"
				echo ""

				selected_model=$(echo "$models_list" | gum filter 					--placeholder "搜索模型（如 cli-api/gpt-5.2）" 					--prompt "选择模型 > " 					--indicator "➜ " 					--prompt.foreground "$orange" 					--indicator.foreground "$orange" 					--cursor-text.foreground "$orange" 					--match.foreground "$orange" 					--header "" 					--height 35)

				if [ -z "$selected_model" ] || echo "$selected_model" | head -n 1 | grep -iqE '^(error|usage|gum:)'; then
					echo "操作已取消，正在退出..."
					break
				fi
			fi

			selected_model=$(echo "$selected_model" | sed -E 's/^\([0-9]+\)[[:space:]]+//')

			echo ""
			echo "正在检测模型: $selected_model"
			if openclaw_model_probe "$selected_model"; then
				openclaw_probe_status_line "可用"
			else
				openclaw_probe_status_line "不可用"
			fi
			echo "状态：$OPENCLAW_PROBE_MESSAGE"
			echo "延迟：$OPENCLAW_PROBE_LATENCY"
			echo "摘要：$OPENCLAW_PROBE_REPLY"
			echo ""

			printf "是否切换到该模型？[y/N，Esc 返回列表]: "
			IFS= read -rsn1 confirm_switch
			echo ""
			if [ "$confirm_switch" = $'' ]; then
				confirm_switch="no"
			else
				case "$confirm_switch" in
					[yY])
						IFS= read -rsn1 -t 5 _enter_key
						confirm_switch="yes"
						;;
					[nN]|"") confirm_switch="no" ;;
					*) confirm_switch="no" ;;
				esac
			fi

			if [ "$confirm_switch" != "yes" ]; then
				echo "已返回模型选择列表。"
				sleep 1
				continue
			fi

			echo "正在切换模型为: $selected_model ..."
			if ! openclaw models set "$selected_model"; then
				echo "切换失败：openclaw models set 返回错误。"
				break_end
				return 1
			fi
			openclaw_sync_sessions_model "$selected_model"
			start_gateway

			break_end
			done
		}


		openclaw_get_config_file() {
			local user_config="${HOME}/.openclaw/openclaw.json"
			local root_config="/root/.openclaw/openclaw.json"
			if [ -f "$user_config" ]; then
				echo "$user_config"
			elif [ "$HOME" = "/root" ] && [ -f "$root_config" ]; then
				echo "$root_config"
			else
				echo "$user_config"
			fi
		}

		openclaw_get_agents_dir() {
			local user_agents="${HOME}/.openclaw/agents"
			local root_agents="/root/.openclaw/agents"
			if [ -d "$user_agents" ]; then
				echo "$user_agents"
			elif [ "$HOME" = "/root" ] && [ -d "$root_agents" ]; then
				echo "$root_agents"
			else
				echo "$user_agents"
			fi
		}

		openclaw_sync_sessions_model() {
			local model_ref="$1"
			[ -z "$model_ref" ] && return 1

			local agents_dir
			agents_dir=$(openclaw_get_agents_dir)
			[ ! -d "$agents_dir" ] && return 0

			local provider="${model_ref%%/*}"
			local model="${model_ref#*/}"
			[ "$provider" = "$model_ref" ] && { provider=""; model="$model_ref"; }

			local count=0
			local agent_dir sessions_file backup_file

			for agent_dir in "$agents_dir"/*/; do
				[ ! -d "$agent_dir" ] && continue
				sessions_file="$agent_dir/sessions/sessions.json"
				[ ! -f "$sessions_file" ] && continue

				backup_file="${sessions_file}.bak"
				cp "$sessions_file" "$backup_file" 2>/dev/null || continue

				if command -v jq >/dev/null 2>&1; then
					local tmp_json
					tmp_json=$(mktemp)
					if [ -n "$provider" ]; then
						jq --arg model "$model" --arg provider "$provider" \
							'to_entries | map(.value.modelOverride = $model | .value.providerOverride = $provider) | from_entries' \
							"$sessions_file" > "$tmp_json" 2>/dev/null && \
							mv "$tmp_json" "$sessions_file" && \
							count=$((count + 1))
					else
						jq --arg model "$model" \
							'to_entries | map(.value.modelOverride = $model | del(.value.providerOverride)) | from_entries' \
							"$sessions_file" > "$tmp_json" 2>/dev/null && \
							mv "$tmp_json" "$sessions_file" && \
							count=$((count + 1))
					fi
				fi
			done

			[ "$count" -gt 0 ] && echo "✅ 已同步 $count 个 agent 的会话模型为 $model_ref"
			return 0
		}

		resolve_openclaw_plugin_id() {
			local raw_input="$1"
			local plugin_id="$raw_input"

			plugin_id="${plugin_id#@openclaw/}"
			if [[ "$plugin_id" == @*/* ]]; then
				plugin_id="${plugin_id##*/}"
			fi
			plugin_id="${plugin_id%%@*}"
			echo "$plugin_id"
		}

		sync_openclaw_plugin_allowlist() {
			local plugin_id="$1"
			[ -z "$plugin_id" ] && return 1

			local config_file
			config_file=$(openclaw_get_config_file)

			mkdir -p "$(dirname "$config_file")"
			if [ ! -s "$config_file" ]; then
				echo '{}' > "$config_file"
			fi

			if command -v jq >/dev/null 2>&1; then
				local tmp_json
				tmp_json=$(mktemp)
				if jq --arg pid "$plugin_id" '
					.plugins = (if (.plugins | type) == "object" then .plugins else {} end)
					| .plugins.allow = (if (.plugins.allow | type) == "array" then .plugins.allow else [] end)
					| if (.plugins.allow | index($pid)) == null then .plugins.allow += [$pid] else . end
				' "$config_file" > "$tmp_json" 2>/dev/null && mv "$tmp_json" "$config_file"; then
					echo "✅ 已同步 plugins.allow 白名单: $plugin_id"
					return 0
				fi
				rm -f "$tmp_json"
			fi

			if command -v python3 >/dev/null 2>&1; then
				if python3 - "$config_file" "$plugin_id" <<'PYTHON_EOF'
import json
import sys
from pathlib import Path

config_file = Path(sys.argv[1])
plugin_id = sys.argv[2]

try:
    data = json.loads(config_file.read_text(encoding='utf-8')) if config_file.exists() else {}
    if not isinstance(data, dict):
        data = {}
except Exception:
    data = {}

plugins = data.get('plugins')
if not isinstance(plugins, dict):
    plugins = {}

a = plugins.get('allow')
if not isinstance(a, list):
    a = []

if plugin_id not in a:
    a.append(plugin_id)

plugins['allow'] = a
data['plugins'] = plugins
config_file.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding='utf-8')
PYTHON_EOF
				then
					echo "✅ 已同步 plugins.allow 白名单: $plugin_id"
					return 0
				fi
			fi

			echo "⚠️ 已安装插件，但同步 plugins.allow 失败，请手动检查: $config_file"
			return 1
		}

		sync_openclaw_plugin_denylist() {
			local plugin_id="$1"
			[ -z "$plugin_id" ] && return 1

			local config_file
			config_file=$(openclaw_get_config_file)

			mkdir -p "$(dirname "$config_file")"
			if [ ! -s "$config_file" ]; then
				echo '{}' > "$config_file"
			fi

			if command -v jq >/dev/null 2>&1; then
				local tmp_json
				tmp_json=$(mktemp)
				if jq --arg pid "$plugin_id" '
					.plugins = (if (.plugins | type) == "object" then .plugins else {} end)
					| .plugins.allow = (if (.plugins.allow | type) == "array" then .plugins.allow else [] end)
					| .plugins.allow = (.plugins.allow | map(select(. != $pid)))
				' "$config_file" > "$tmp_json" 2>/dev/null && mv "$tmp_json" "$config_file"; then
					echo "✅ 已从 plugins.allow 移除: $plugin_id"
					return 0
				fi
				rm -f "$tmp_json"
			fi

			if command -v python3 >/dev/null 2>&1; then
				if python3 - "$config_file" "$plugin_id" <<'PYTHON_EOF'
import json
import sys
from pathlib import Path

config_file = Path(sys.argv[1])
plugin_id = sys.argv[2]

try:
    data = json.loads(config_file.read_text(encoding='utf-8')) if config_file.exists() else {}
    if not isinstance(data, dict):
        data = {}
except Exception:
    data = {}

plugins = data.get('plugins')
if not isinstance(plugins, dict):
    plugins = {}

a = plugins.get('allow')
if not isinstance(a, list):
    a = []

a = [x for x in a if x != plugin_id]
plugins['allow'] = a
data['plugins'] = plugins
config_file.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding='utf-8')
PYTHON_EOF
				then
					echo "✅ 已从 plugins.allow 移除: $plugin_id"
					return 0
				fi
			fi

			echo "⚠️ plugins.allow 移除失败，请手动检查: $config_file"
			return 1
		}






		install_plugin() {
		send_stats "插件管理"
		while true; do
			clear
			echo -e "${rw_cheng}========================================${rw_lv}"
			echo "            插件管理 (安装/删除)            "
			echo -e "${rw_cheng}========================================${rw_lv}"
			echo "当前插件列表:"
			openclaw plugins list
			echo -e "${rw_cheng}--------------------------------------------------------${rw_lv}"
			echo "推荐的常用插件 ID (直接复制括号内的 ID 即可):"
			echo -e "${rw_cheng}--------------------------------------------------------${rw_lv}"
			echo "📱 通讯渠道:"
			echo "  - [feishu]       	# 飞书/Lark 集成"
			echo "  - [telegram]     	# Telegram 机器人"
			echo "  - [slack]        	# Slack 企业通讯"
			echo "  - [msteams]      	# Microsoft Teams"
			echo "  - [discord]      	# Discord 社区管理"
			echo "  - [whatsapp]     	# WhatsApp 自动化"
			echo ""
			echo "🧠 记忆与 AI:"
			echo "  - [memory-core]  	# 基础记忆 (文件检索)"
			echo "  - [memory-lancedb]	# 增强记忆 (向量数据库)"
			echo "  - [copilot-proxy]	# Copilot 接口转发"
			echo ""
			echo "⚙️ 功能扩展:"
			echo "  - [lobster]      	# 审批流 (带人工确认)"
			echo "  - [voice-call]   	# 语音通话能力"
			echo "  - [nostr]        	# 加密隐私聊天"
			echo -e "${rw_cheng}--------------------------------------------------------${rw_lv}"

			echo "1) 安装/启用插件"
			echo "2) 删除/禁用插件"
			echo "0) 返回"
			read -e -p "请选择操作：" plugin_action

			[ "$plugin_action" = "0" ] && break
			[ -z "$plugin_action" ] && continue

			read -e -p "请输入插件 ID（空格分隔，输入 0 退出）： " raw_input
			[ "$raw_input" = "0" ] && break
			[ -z "$raw_input" ] && continue

			local success_list=""
			local failed_list=""
			local skipped_list=""
			local changed=false
			local token

			for token in $raw_input; do
				local plugin_id
				local plugin_full
				plugin_id=$(resolve_openclaw_plugin_id "$token")
				plugin_full="$token"
				[ -z "$plugin_id" ] && continue

				if [ "$plugin_action" = "1" ]; then
					echo "🔍 正在检查插件状态: $plugin_id"
					local plugin_list
					plugin_list=$(openclaw plugins list 2>/dev/null)

					if echo "$plugin_list" | grep -qw "$plugin_id" && echo "$plugin_list" | grep "$plugin_id" | grep -q "disabled"; then
						echo "💡 插件 [$plugin_id] 已预装，正在激活..."
						if openclaw plugins enable "$plugin_id"; then
							sync_openclaw_plugin_allowlist "$plugin_id"
							success_list="$success_list $plugin_id"
							changed=true
						else
							failed_list="$failed_list $plugin_id"
						fi
						continue
					fi

					if [ -d "/usr/lib/node_modules/openclaw/extensions/$plugin_id" ]; then
						echo "💡 发现系统内置目录存在该插件，尝试直接启用..."
						if openclaw plugins enable "$plugin_id"; then
							sync_openclaw_plugin_allowlist "$plugin_id"
							success_list="$success_list $plugin_id"
							changed=true
						else
							failed_list="$failed_list $plugin_id"
						fi
						continue
					fi

					echo "📥 本地未发现，尝试下载安装: $plugin_full"
					rm -rf "${HOME}/.openclaw/extensions/$plugin_id"
					[ "$HOME" != "/root" ] && rm -rf "/root/.openclaw/extensions/$plugin_id"
					if openclaw plugins install "$plugin_full"; then
						echo "✅ 下载成功，正在启用..."
						if openclaw plugins enable "$plugin_id"; then
							sync_openclaw_plugin_allowlist "$plugin_id"
							success_list="$success_list $plugin_id"
							changed=true
						else
							failed_list="$failed_list $plugin_id"
						fi
					else
						echo "❌ 安装失败：$plugin_full"
						failed_list="$failed_list $plugin_id"
					fi
				else
					echo "🗑️ 正在删除/禁用插件: $plugin_id"
					openclaw plugins disable "$plugin_id" >/dev/null 2>&1
					if openclaw plugins uninstall "$plugin_id"; then
						echo "✅ 已卸载: $plugin_id"
					else
						echo "⚠️ 卸载失败，可能为预装插件，仅禁用: $plugin_id"
					fi
					sync_openclaw_plugin_denylist "$plugin_id" >/dev/null 2>&1
					success_list="$success_list $plugin_id"
					changed=true
				fi
			done

			echo ""
			echo -e "${rw_cheng}====== 操作汇总 ======${rw_lv}"
			echo "✅ 成功:$success_list"
			[ -n "$failed_list" ] && echo "❌ 失败:$failed_list"
			[ -n "$skipped_list" ] && echo "⏭️ 跳过:$skipped_list"

			if [ "$changed" = true ]; then
				echo "🔄 正在重启 OpenClaw 服务以加载变更..."
				start_gateway
			fi
			break_end
		done
	}


	install_skill() {
		send_stats "技能管理"
		while true; do
			clear
			echo -e "${rw_cheng}========================================${rw_lv}"
			echo "            技能管理 (安装/删除)            "
			echo -e "${rw_cheng}========================================${rw_lv}"
			echo "当前已安装技能:"
			openclaw skills list
			echo -e "${rw_cheng}----------------------------------------${rw_lv}"

			# 输出推荐的实用技能列表
			echo "推荐的实用技能（可直接复制名称输入）："
			echo "github             # 管理 GitHub Issues/PR/CI (gh CLI)"
			echo "notion             # 操作 Notion 页面、数据库和块"
			echo "apple-notes        # macOS 原生笔记管理 (创建/编辑/搜索)"
			echo "apple-reminders    # macOS 提醒事项管理 (待办清单)"
			echo "1password          # 自动化读取和注入 1Password 密钥"
			echo "gog                # Google Workspace (Gmail/云盘/文档) 全能助手"
			echo "things-mac         # 深度整合 Things 3 任务管理"
			echo "bluebubbles        # 通过 BlueBubbles 完美收发 iMessage"
			echo "himalaya           # 终端邮件管理 (IMAP/SMTP 强力工具)"
			echo "summarize          # 网页/播客/YouTube 视频内容一键总结"
			echo "openhue            # 控制 Philips Hue 智能灯光场景"
			echo "video-frames       # 视频抽帧与短片剪辑 (ffmpeg 驱动)"
			echo "openai-whisper     # 本地音频转文字 (离线隐私保护)"
			echo "coding-agent       # 自动运行 Claude Code/Codex 等编程助手"
			echo -e "${rw_cheng}----------------------------------------${rw_lv}"

			echo "1) 安装技能"
			echo "2) 删除技能"
			echo "0) 返回"
			read -e -p "请选择操作：" skill_action

			[ "$skill_action" = "0" ] && break
			[ -z "$skill_action" ] && continue

			read -e -p "请输入技能名称（空格分隔，输入 0 退出）： " skill_input
			[ "$skill_input" = "0" ] && break
			[ -z "$skill_input" ] && continue

			local success_list=""
			local failed_list=""
			local skipped_list=""
			local changed=false
			local token

			if [ "$skill_action" = "2" ]; then
				read -e -p "二次确认：删除仅影响用户目录 ~/.openclaw/workspace/skills，确认继续？(y/N): " confirm_del
				if [[ ! "$confirm_del" =~ ^[Yy]$ ]]; then
					echo "已取消删除。"
					break_cancel
					continue
				fi
			fi

			for token in $skill_input; do
				local skill_name
				skill_name="$token"
				[ -z "$skill_name" ] && continue

				if [ "$skill_action" = "1" ]; then
					local skill_found=false
					if [ -d "${HOME}/.openclaw/workspace/skills/${skill_name}" ]; then
						echo "💡 技能 [$skill_name] 已在用户目录安装。"
						skill_found=true
					elif [ -d "/usr/lib/node_modules/openclaw/skills/${skill_name}" ]; then
						echo "💡 技能 [$skill_name] 已在系统目录安装。"
						skill_found=true
					fi

					if [ "$skill_found" = true ]; then
						read -e -p "技能 [$skill_name] 已安装，是否重新安装？(y/N): " reinstall
						if [[ ! "$reinstall" =~ ^[Yy]$ ]]; then
							skipped_list="$skipped_list $skill_name"
							continue
						fi
					fi

					echo "正在安装技能：$skill_name ..."
					if npx clawhub install "$skill_name" --yes --no-input 2>/dev/null || npx clawhub install "$skill_name"; then
						echo "✅ 技能 $skill_name 安装成功。"
						success_list="$success_list $skill_name"
						changed=true
					else
						echo "❌ 安装失败：$skill_name"
						failed_list="$failed_list $skill_name"
					fi
				else
					echo "🗑️ 正在删除技能: $skill_name"
					npx clawhub uninstall "$skill_name" --yes --no-input 2>/dev/null || npx clawhub uninstall "$skill_name" >/dev/null 2>&1
					if [ -d "${HOME}/.openclaw/workspace/skills/${skill_name}" ]; then
						rm -rf "${HOME}/.openclaw/workspace/skills/${skill_name}"
						echo "✅ 已删除用户技能目录: $skill_name"
						success_list="$success_list $skill_name"
						changed=true
					else
						echo "⏭️ 未发现用户技能目录: $skill_name"
						skipped_list="$skipped_list $skill_name"
					fi
				fi
			done

			echo ""
			echo -e "${rw_cheng}====== 操作汇总 ======${rw_lv}"
			echo "✅ 成功:$success_list"
			[ -n "$failed_list" ] && echo "❌ 失败:$failed_list"
			[ -n "$skipped_list" ] && echo "⏭️ 跳过:$skipped_list"

			if [ "$changed" = true ]; then
				echo "🔄 正在重启 OpenClaw 服务以加载变更..."
				start_gateway
			fi
			break_end
		done
	}

openclaw_json_get_bool() {
		local expr="$1"
		local config_file
		config_file=$(openclaw_get_config_file)
		if [ ! -s "$config_file" ]; then
			echo "false"
			return
		fi
		jq -r "$expr" "$config_file" 2>/dev/null || echo "false"
	}

	openclaw_channel_has_cfg() {
		local channel="$1"
		local config_file
		config_file=$(openclaw_get_config_file)
		if [ ! -s "$config_file" ]; then
			echo "false"
			return
		fi
		jq -r --arg c "$channel" '
			(.channels[$c] // null) as $v
			| if ($v | type) != "object" then
				false
			  else
				([ $v
				   | to_entries[]
				   | select((.key == "enabled" or .key == "dmPolicy" or .key == "groupPolicy" or .key == "streaming") | not)
				   | .value
				   | select(. != null and . != "" and . != false)
				 ] | length) > 0
			  end
		' "$config_file" 2>/dev/null || echo "false"
	}

	openclaw_dir_has_files() {
		local dir="$1"
		[ -d "$dir" ] && find "$dir" -type f -print -quit 2>/dev/null | grep -q .
	}

	openclaw_plugin_local_installed() {
		local plugin="$1"
		local config_file
		config_file=$(openclaw_get_config_file)
		if [ -s "$config_file" ] && jq -e --arg p "$plugin" '.plugins.installs[$p]' "$config_file" >/dev/null 2>&1; then
			return 0
		fi

		# 兼容两种常见目录命名：
		# - ~/.openclaw/extensions/qqbot
		# - ~/.openclaw/extensions/openclaw-qqbot
		# 避免无脑 substring，优先精确匹配与 openclaw- 前缀匹配。
		[ -d "${HOME}/.openclaw/extensions/${plugin}" ] \
			|| [ -d "${HOME}/.openclaw/extensions/openclaw-${plugin}" ] \
			|| [ -d "/usr/lib/node_modules/openclaw/extensions/${plugin}" ] \
			|| [ -d "/usr/lib/node_modules/openclaw/extensions/openclaw-${plugin}" ]
	}

	openclaw_bot_status_text() {
		local enabled="$1"
		local configured="$2"
		local connected="$3"
		local abnormal="$4"
		if [ "$abnormal" = "true" ]; then
			echo "异常"
		elif [ "$enabled" != "true" ]; then
			echo "未启用"
		elif [ "$connected" = "true" ]; then
			echo "已连接"
		elif [ "$configured" = "true" ]; then
			echo "已配置"
		else
			echo "未配置"
		fi
	}

	openclaw_colorize_bot_status() {
		local status="$1"
		case "$status" in
			已连接) echo -e "${rw_lv}${status}${rw_lv}" ;;
			已配置) echo -e "${rw_huang}${status}${rw_lv}" ;;
			异常) echo -e "${rw_hong}${status}${rw_lv}" ;;
			*) echo "$status" ;;
		esac
	}

	openclaw_print_bot_status_line() {
		local label="$1"
		local status="$2"
		echo -e "- ${label}: $(openclaw_colorize_bot_status "$status")"
	}

	openclaw_show_bot_local_status_block() {
		local config_file
		config_file=$(openclaw_get_config_file)
		local json_ok="false"
		if [ -s "$config_file" ] && jq empty "$config_file" >/dev/null 2>&1; then
			json_ok="true"
		fi

		local tg_enabled tg_cfg tg_connected tg_abnormal tg_status
		tg_enabled=$(openclaw_json_get_bool '.channels.telegram.enabled // .plugins.entries.telegram.enabled // false')
		tg_cfg=$(openclaw_channel_has_cfg "telegram")
		tg_connected="false"
		if openclaw_dir_has_files "${HOME}/.openclaw/telegram"; then
			tg_connected="true"
		fi
		tg_abnormal="false"
		if [ "$tg_enabled" = "true" ] && [ "$json_ok" != "true" ]; then
			tg_abnormal="true"
		fi
		tg_status=$(openclaw_bot_status_text "$tg_enabled" "$tg_cfg" "$tg_connected" "$tg_abnormal")

		local feishu_enabled feishu_cfg feishu_connected feishu_abnormal feishu_status
		feishu_enabled=$(openclaw_json_get_bool '.plugins.entries.feishu.enabled // .plugins.entries["openclaw-lark"].enabled // .channels.feishu.enabled // .channels.lark.enabled // false')
		feishu_cfg=$(openclaw_channel_has_cfg "feishu")
		if [ "$feishu_cfg" != "true" ]; then
			feishu_cfg=$(openclaw_channel_has_cfg "lark")
		fi
		feishu_connected="false"
		if openclaw_dir_has_files "${HOME}/.openclaw/feishu" || openclaw_dir_has_files "${HOME}/.openclaw/lark" || openclaw_dir_has_files "${HOME}/.openclaw/openclaw-lark"; then
			feishu_connected="true"
		fi
		feishu_abnormal="false"
		if [ "$feishu_enabled" = "true" ] && ! openclaw_plugin_local_installed "feishu" && ! openclaw_plugin_local_installed "lark" && ! openclaw_plugin_local_installed "openclaw-lark"; then
			feishu_abnormal="true"
		fi
		if [ "$feishu_enabled" = "true" ] && [ "$json_ok" != "true" ]; then
			feishu_abnormal="true"
		fi
		if [ "$feishu_connected" != "true" ] && [ "$feishu_enabled" = "true" ] && [ "$feishu_cfg" = "true" ] && { openclaw_plugin_local_installed "feishu" || openclaw_plugin_local_installed "lark" || openclaw_plugin_local_installed "openclaw-lark"; }; then
			feishu_connected="true"
		fi
		feishu_status=$(openclaw_bot_status_text "$feishu_enabled" "$feishu_cfg" "$feishu_connected" "$feishu_abnormal")

		local wa_enabled wa_cfg wa_connected wa_abnormal wa_status
		wa_enabled=$(openclaw_json_get_bool '.plugins.entries.whatsapp.enabled // .channels.whatsapp.enabled // false')
		wa_cfg=$(openclaw_channel_has_cfg "whatsapp")
		wa_connected="false"
		if openclaw_dir_has_files "${HOME}/.openclaw/whatsapp"; then
			wa_connected="true"
		fi
		wa_abnormal="false"
		if [ "$wa_enabled" = "true" ] && ! openclaw_plugin_local_installed "whatsapp"; then
			wa_abnormal="true"
		fi
		if [ "$wa_enabled" = "true" ] && [ "$json_ok" != "true" ]; then
			wa_abnormal="true"
		fi
		wa_status=$(openclaw_bot_status_text "$wa_enabled" "$wa_cfg" "$wa_connected" "$wa_abnormal")

		local dc_enabled dc_cfg dc_connected dc_abnormal dc_status
		dc_enabled=$(openclaw_json_get_bool '.channels.discord.enabled // .plugins.entries.discord.enabled // false')
		dc_cfg=$(openclaw_channel_has_cfg "discord")
		dc_connected="false"
		if openclaw_dir_has_files "${HOME}/.openclaw/discord"; then
			dc_connected="true"
		fi
		dc_abnormal="false"
		if [ "$dc_enabled" = "true" ] && [ "$json_ok" != "true" ]; then
			dc_abnormal="true"
		fi
		dc_status=$(openclaw_bot_status_text "$dc_enabled" "$dc_cfg" "$dc_connected" "$dc_abnormal")

		local slack_enabled slack_cfg slack_connected slack_abnormal slack_status
		slack_enabled=$(openclaw_json_get_bool '.plugins.entries.slack.enabled // .channels.slack.enabled // false')
		slack_cfg=$(openclaw_channel_has_cfg "slack")
		slack_connected="false"
		if openclaw_dir_has_files "${HOME}/.openclaw/slack"; then
			slack_connected="true"
		fi
		slack_abnormal="false"
		if [ "$slack_enabled" = "true" ] && ! openclaw_plugin_local_installed "slack"; then
			slack_abnormal="true"
		fi
		if [ "$slack_enabled" = "true" ] && [ "$json_ok" != "true" ]; then
			slack_abnormal="true"
		fi
		slack_status=$(openclaw_bot_status_text "$slack_enabled" "$slack_cfg" "$slack_connected" "$slack_abnormal")

		local qq_enabled qq_cfg qq_connected qq_abnormal qq_status
		qq_enabled=$(openclaw_json_get_bool '.plugins.entries.qqbot.enabled // .channels.qqbot.enabled // false')
		qq_cfg=$(openclaw_channel_has_cfg "qqbot")
		qq_connected="false"
		if openclaw_dir_has_files "${HOME}/.openclaw/qqbot/sessions" || openclaw_dir_has_files "${HOME}/.openclaw/qqbot/data"; then
			qq_connected="true"
		fi
		qq_abnormal="false"
		if [ "$qq_enabled" = "true" ] && ! openclaw_plugin_local_installed "qqbot"; then
			qq_abnormal="true"
		fi
		if [ "$qq_enabled" = "true" ] && [ "$json_ok" != "true" ]; then
			qq_abnormal="true"
		fi
		qq_status=$(openclaw_bot_status_text "$qq_enabled" "$qq_cfg" "$qq_connected" "$qq_abnormal")

		local wx_enabled wx_cfg wx_connected wx_abnormal wx_status
		wx_enabled=$(openclaw_json_get_bool '.plugins.entries.weixin.enabled // .plugins.entries["openclaw-weixin"].enabled // .channels.weixin.enabled // .channels["openclaw-weixin"].enabled // false')
		wx_cfg=$(openclaw_channel_has_cfg "weixin")
		if [ "$wx_cfg" != "true" ]; then
			wx_cfg=$(openclaw_channel_has_cfg "openclaw-weixin")
		fi
		wx_connected="false"
		if openclaw_dir_has_files "${HOME}/.openclaw/weixin" || openclaw_dir_has_files "${HOME}/.openclaw/openclaw-weixin"; then
			wx_connected="true"
		fi
		wx_abnormal="false"
		if [ "$wx_enabled" = "true" ] && ! openclaw_plugin_local_installed "weixin" && ! openclaw_plugin_local_installed "openclaw-weixin"; then
			wx_abnormal="true"
		fi
		if [ "$wx_enabled" = "true" ] && [ "$json_ok" != "true" ]; then
			wx_abnormal="true"
		fi
		wx_status=$(openclaw_bot_status_text "$wx_enabled" "$wx_cfg" "$wx_connected" "$wx_abnormal")

		echo "本地状态（仅本机配置/缓存，不做网络探测）："
		openclaw_print_bot_status_line "Telegram" "$tg_status"
		openclaw_print_bot_status_line "飞书(Lark)" "$feishu_status"
		openclaw_print_bot_status_line "WhatsApp" "$wa_status"
		openclaw_print_bot_status_line "Discord" "$dc_status"
		openclaw_print_bot_status_line "Slack" "$slack_status"
		openclaw_print_bot_status_line "QQ Bot" "$qq_status"
		openclaw_print_bot_status_line "微信 (Weixin)" "$wx_status"
	}

	change_tg_bot_code() {
		send_stats "机器人对接"
		while true; do
			clear
			echo -e "${rw_cheng}========================================${rw_lv}"
			echo "            机器人连接对接            "
			echo -e "${rw_cheng}========================================${rw_lv}"
			openclaw_show_bot_local_status_block
			echo -e "${rw_cheng}----------------------------------------${rw_lv}"
			echo "1. Telegram 机器人对接"
			echo "2. 飞书 (Lark) 机器人对接"
			echo "3. WhatsApp 机器人对接"
			echo "4. QQ 机器人对接"
			echo "5. 微信机器人对接"
			echo -e "${rw_cheng}----------------------------------------${rw_lv}"
			echo "0. 返回上一级选单"
			echo -e "${rw_cheng}----------------------------------------${rw_lv}"
			read -e -p "请输入你的选择: " bot_choice

			case $bot_choice in
				1)
					read -e -p "请输入TG机器人收到的连接码 (例如 NYA99R2F)（输入 0 退出）： " code
					if [ "$code" = "0" ]; then continue; fi
					if [ -z "$code" ]; then echo "错误：连接码不能为空。"; sleep 1; continue; fi
					openclaw pairing approve telegram "$code"
					break_end
					;;
				2)
					npx -y @larksuite/openclaw-lark install
					openclaw config set channels.feishu.streaming true
					openclaw config set channels.feishu.requireMention true --json
					break_end
					;;
				3)
					read -e -p "请输入WhatsApp收到的连接码 (例如 NYA99R2F)（输入 0 退出）： " code
					if [ "$code" = "0" ]; then continue; fi
					if [ -z "$code" ]; then echo "错误：连接码不能为空。"; sleep 1; continue; fi
					openclaw pairing approve whatsapp "$code"
					break_end
					;;
				4)
					echo "QQ 官方对接地址："
					echo "https://q.qq.com/qqbot/openclaw/login.html"
					break_end
					;;
				5)
					npx -y @tencent-weixin/openclaw-weixin-cli@latest install
					break_end
					;;
				0)
					return 0
					;;
				*)
					echo "无效的选择，请重试。"
					sleep 1
					;;
			esac
		done
	}


	openclaw_backup_root() {
		echo "${HOME}/.openclaw/backups"
	}

	openclaw_is_interactive_terminal() {
		[ -t 0 ] && [ -t 1 ]
	}

	openclaw_has_command() {
		command -v "$1" >/dev/null 2>&1
	}


	openclaw_is_safe_relpath() {
		local rel="$1"
		[ -z "$rel" ] && return 1
		[[ "$rel" = /* ]] && return 1
		[[ "$rel" == *"//"* ]] && return 1
		[[ "$rel" == *$'\n'* ]] && return 1
		[[ "$rel" == *$'\r'* ]] && return 1
		case "$rel" in
			../*|*/../*|*/..|..)
				return 1
				;;
		esac
		return 0
	}

	openclaw_restore_path_allowed() {
		local mode="$1"
		local rel="$2"
		case "$mode" in
			memory)
				case "$rel" in
					MEMORY.md|AGENTS.md|USER.md|SOUL.md|TOOLS.md|memory/*) return 0 ;;
					*) return 1 ;;
				esac
				;;
			project)
				case "$rel" in
					openclaw.json|workspace/*|extensions/*|skills/*|prompts/*|tools/*|telegram/*|feishu/*|whatsapp/*|discord/*|slack/*|qqbot/*|logs/*) return 0 ;;
					*) return 1 ;;
				esac
				;;
			*)
				return 1
				;;
		esac
	}

	openclaw_pack_backup_archive() {
		local backup_type="$1"
		local export_mode="$2"
		local payload_dir="$3"
		local output_file="$4"

		local tmp_root
		tmp_root=$(mktemp -d) || return 1
		local pack_dir="$tmp_root/package"
		mkdir -p "$pack_dir"

		cp -a "$payload_dir" "$pack_dir/payload"

		(
			cd "$pack_dir/payload" || exit 1
			find . -type f | sed 's|^\./||' | sort > "$pack_dir/manifest.files"
			: > "$pack_dir/manifest.sha256"
			while IFS= read -r f; do
				[ -z "$f" ] && continue
				sha256sum "$f" >> "$pack_dir/manifest.sha256"
			done < "$pack_dir/manifest.files"
		) || { rm -rf "$tmp_root"; return 1; }

		cat > "$pack_dir/backup.meta" <<EOF
TYPE=$backup_type
MODE=$export_mode
CREATED_AT=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
HOST=$(hostname)
EOF

		mkdir -p "$(dirname "$output_file")"
		tar -C "$pack_dir" -czf "$output_file" backup.meta manifest.files manifest.sha256 payload
		local rc=$?
		rm -rf "$tmp_root"
		return $rc
	}

	openclaw_offer_transfer_hint() {
		local file_path="$1"

		echo "可使用以下方式下载备份文件："
		echo "- 本地路径: $file_path"
		echo "- scp 示例: scp root@你的服务器:$file_path ./"
		echo "- 或使用 SFTP 客户端下载"
	}

	openclaw_prepare_import_archive() {
		local expected_type="$1"
		local archive_path="$2"
		local unpack_root="$3"

		[ ! -f "$archive_path" ] && { echo "❌ 文件不存在: $archive_path"; return 1; }
		mkdir -p "$unpack_root"
		tar -xzf "$archive_path" -C "$unpack_root" || { echo "❌ 备份包解压失败"; return 1; }

		local pkg_dir="$unpack_root/package"
		if [ -f "$unpack_root/backup.meta" ]; then
			pkg_dir="$unpack_root"
		fi

		for required in backup.meta manifest.files manifest.sha256 payload; do
			[ -e "$pkg_dir/$required" ] || { echo "❌ 备份包缺少必要文件: $required"; return 1; }
		done

		local real_type
		real_type=$(grep '^TYPE=' "$pkg_dir/backup.meta" | head -n1 | cut -d'=' -f2-)
		if [ "$real_type" != "$expected_type" ]; then
			echo "❌ 备份类型不匹配，期望: $expected_type，实际: ${real_type:-未知}"
			return 1
		fi

		(
			cd "$pkg_dir/payload" || exit 1
			sha256sum -c ../manifest.sha256 >/dev/null
		) || { echo "❌ sha256 校验失败，拒绝还原"; return 1; }

		echo "$pkg_dir"
		return 0
	}

	openclaw_get_all_agent_workspaces() {
		local config_file
		config_file=$(openclaw_get_config_file)
		if [ -f "$config_file" ]; then
			python3 - "$config_file" <<'PY'
import json, sys, os
try:
    with open(sys.argv[1]) as f: data = json.load(f)
    agents = data.get("agents", {}).get("list", [])
    results = [{"id": "main", "ws": os.path.expanduser("~/.openclaw/workspace")}]
    for a in agents:
        aid = a.get("id"); ws = a.get("workspace")
        if aid and ws and aid != "main": results.append({"id": aid, "ws": os.path.expanduser(ws)})
    print(json.dumps(results))
except: print("[]")
PY
		else
			echo '[{"id": "main", "ws": "'"${HOME}"'/.openclaw/workspace"}]'
		fi
	}

	openclaw_memory_backup_export() {
		send_stats "OpenClaw记忆全量备份"
		local backup_root=$(openclaw_backup_root)
		local ts=$(date +%Y%m%d-%H%M%S)
		local out_file="$backup_root/openclaw-memory-full-${ts}.tar.gz"
		mkdir -p "$backup_root"
		local tmp_payload=$(mktemp -d) || return 1
		local workspaces_json=$(openclaw_get_all_agent_workspaces)
		python3 -c "import json, sys, os, shutil;
workspaces = json.loads(sys.argv[1]); tmp_payload = sys.argv[2]
for item in workspaces:
    aid = item['id']; ws = item['ws']
    if not os.path.isdir(ws): continue
    target_dir = os.path.join(tmp_payload, 'agents', aid)
    os.makedirs(target_dir, exist_ok=True)
    for f in ['MEMORY.md', 'memory']:
        src = os.path.join(ws, f)
        if os.path.exists(src):
            if os.path.isfile(src): shutil.copy2(src, target_dir)
            else: shutil.copytree(src, os.path.join(target_dir, f), dirs_exist_ok=True)
" "$workspaces_json" "$tmp_payload"
		if ! find "$tmp_payload" -mindepth 1 -print -quit | grep -q .; then
			echo "❌ 未找到可备份的记忆文件"; rm -rf "$tmp_payload"; break_end; return 1
		fi
		if openclaw_pack_backup_archive "memory-full" "multi-agent" "$tmp_payload" "$out_file"; then
			echo "✅ 记忆全量备份完成 (含多智能体): $out_file"; openclaw_offer_transfer_hint "$out_file"
		else
			echo "❌ 记忆全量备份失败"
		fi
		rm -rf "$tmp_payload"; break_end
	}

	openclaw_memory_backup_import() {
		send_stats "OpenClaw记忆全量还原"
		local archive_path=$(openclaw_read_import_path "还原记忆全量 (支持多智能体)")
		[ -z "$archive_path" ] && { echo "❌ 未输入路径"; break_end; return 1; }
		local tmp_unpack=$(mktemp -d) || return 1
		local pkg_dir=$(openclaw_prepare_import_archive "memory-full" "$archive_path" "$tmp_unpack") || { rm -rf "$tmp_unpack"; break_end; return 1; }
		local workspaces_json=$(openclaw_get_all_agent_workspaces)
		python3 -c 'import json, sys, os, shutil;
workspaces = {item["id"]: item["ws"] for item in json.loads(sys.argv[1])};
payload_dir = sys.argv[2]; agents_root = os.path.join(payload_dir, "agents")
if os.path.isdir(agents_root):
    for aid in os.listdir(agents_root):
        if aid in workspaces:
            src_agent_dir = os.path.join(agents_root, aid); dest_ws = workspaces[aid]
            os.makedirs(dest_ws, exist_ok=True)
            for f in os.listdir(src_agent_dir):
                src = os.path.join(src_agent_dir, f); dest = os.path.join(dest_ws, f)
                if os.path.isfile(src): shutil.copy2(src, dest)
                else: shutil.copytree(src, dest, dirs_exist_ok=True)
            print(f"✅ 已还原智能体记忆: {aid}")' "$workspaces_json" "$pkg_dir/payload"
		rm -rf "$tmp_unpack"; echo "✅ 记忆全量还原完成"; break_end
	}


	openclaw_project_backup_export() {
		send_stats "OpenClaw项目备份"
		local config_file
		config_file=$(openclaw_get_config_file)
		local openclaw_root
		openclaw_root=$(dirname "$config_file")
		if [ ! -d "$openclaw_root" ]; then
			echo "❌ 未找到 OpenClaw 根目录: $openclaw_root"
			break_end
			return 1
		fi

		echo "备份模式："
		echo "1. 安全模式（默认，推荐）：workspace + openclaw.json + extensions/skills/prompts/tools（如存在）"
		echo "2. 完整模式（含更多状态，敏感风险更高）"
		read -e -p "请选择备份模式（默认 1）: " export_mode
		[ -z "$export_mode" ] && export_mode="1"

		local mode_label="safe"
		local tmp_payload
		tmp_payload=$(mktemp -d) || return 1

		if [ "$export_mode" = "2" ]; then
			mode_label="full"
			for d in workspace extensions skills prompts tools; do
				[ -e "$openclaw_root/$d" ] && cp -a "$openclaw_root/$d" "$tmp_payload/"
			done
			[ -f "$openclaw_root/openclaw.json" ] && cp -a "$openclaw_root/openclaw.json" "$tmp_payload/"
			for d in telegram feishu whatsapp discord slack qqbot logs; do
				[ -e "$openclaw_root/$d" ] && cp -a "$openclaw_root/$d" "$tmp_payload/"
			done
		else
			[ -d "$openclaw_root/workspace" ] && cp -a "$openclaw_root/workspace" "$tmp_payload/"
			[ -f "$openclaw_root/openclaw.json" ] && cp -a "$openclaw_root/openclaw.json" "$tmp_payload/"
			for d in extensions skills prompts tools; do
				[ -e "$openclaw_root/$d" ] && cp -a "$openclaw_root/$d" "$tmp_payload/"
			done
		fi

		if ! find "$tmp_payload" -mindepth 1 -print -quit | grep -q .; then
			echo "❌ 未找到可备份的 OpenClaw 项目内容"
			rm -rf "$tmp_payload"
			break_end
			return 1
		fi

		local backup_root
		backup_root=$(openclaw_backup_root)
		mkdir -p "$backup_root"
		local out_file="$backup_root/openclaw-project-${mode_label}-$(date +%Y%m%d-%H%M%S).tar.gz"

		if openclaw_pack_backup_archive "openclaw-project" "$mode_label" "$tmp_payload" "$out_file"; then
			echo "✅ OpenClaw 项目备份完成 (${mode_label}): $out_file"
			openclaw_offer_transfer_hint "$out_file"
		else
			echo "❌ OpenClaw 项目备份失败"
		fi

		rm -rf "$tmp_payload"
		break_end
	}

	openclaw_project_backup_import() {
		send_stats "OpenClaw项目还原"
		local config_file
		config_file=$(openclaw_get_config_file)
		local openclaw_root
		openclaw_root=$(dirname "$config_file")
		mkdir -p "$openclaw_root"

		echo "⚠️ 高风险操作：项目还原会覆盖 OpenClaw 配置与工作区内容。"
		echo "⚠️ 还原前将执行 manifest/sha256 校验、白名单恢复、gateway 停启与健康检查。"
		read -e -p "请输入确认词【我已知晓高风险并继续还原】后继续: " confirm_text
		if [ "$confirm_text" != "我已知晓高风险并继续还原" ]; then
			echo "❌ 确认词不匹配，已取消还原"
			break_cancel
			return 1
		fi

		local archive_path
		archive_path=$(openclaw_read_import_path "请输入 OpenClaw 项目备份包路径")
		[ -z "$archive_path" ] && { echo "❌ 未输入备份路径"; break_end; return 1; }

		local tmp_unpack
		tmp_unpack=$(mktemp -d) || return 1
		local pkg_dir
		pkg_dir=$(openclaw_prepare_import_archive "openclaw-project" "$archive_path" "$tmp_unpack") || { rm -rf "$tmp_unpack"; break_end; return 1; }

		local invalid=0
		local valid_list
		valid_list=$(mktemp)
		while IFS= read -r rel; do
			[ -z "$rel" ] && continue
			if ! openclaw_is_safe_relpath "$rel" || ! openclaw_restore_path_allowed project "$rel"; then
				echo "❌ 检测到非法或越权路径: $rel"
				invalid=1
				break
			fi
			echo "$rel" >> "$valid_list"
		done < "$pkg_dir/manifest.files"

		if [ "$invalid" -ne 0 ]; then
			rm -f "$valid_list"
			rm -rf "$tmp_unpack"
			echo "❌ 还原中止：存在不安全路径"
			break_end
			return 1
		fi


		if command -v openclaw >/dev/null 2>&1; then
			echo "⏸️ 还原前停止 OpenClaw gateway..."
			openclaw gateway stop >/dev/null 2>&1
		fi

		while IFS= read -r rel; do
			mkdir -p "$openclaw_root/$(dirname "$rel")"
			cp -a "$pkg_dir/payload/$rel" "$openclaw_root/$rel"
		done < "$valid_list"

		if command -v openclaw >/dev/null 2>&1; then
			echo "▶️ 还原后启动 OpenClaw gateway..."
			openclaw gateway start >/dev/null 2>&1
			sleep 2
			echo "🩺 gateway 健康检查："
			openclaw gateway status || true
		fi

		rm -f "$valid_list"
		rm -rf "$tmp_unpack"
		echo "✅ OpenClaw 项目还原完成"
		break_end
	}

	openclaw_backup_detect_type() {
		local file_name="$1"
		if [[ "$file_name" == openclaw-memory-full-*.tar.gz ]]; then
			echo "记忆备份文件"
		elif [[ "$file_name" == openclaw-project-*.tar.gz ]]; then
			echo "项目备份文件"
		else
			echo "其他备份文件"
		fi
	}

	openclaw_backup_collect_files() {
		local backup_root
		backup_root=$(openclaw_backup_root)
		mkdir -p "$backup_root"
		mapfile -t OPENCLAW_BACKUP_FILES < <(find "$backup_root" -maxdepth 1 -type f -name '*.tar.gz' -printf '%f\n' | sort -r)
	}


	openclaw_backup_render_file_list() {
		local backup_root i file_name file_path file_type file_size file_time
		local has_memory=0 has_project=0 has_other=0
		backup_root=$(openclaw_backup_root)
		openclaw_backup_collect_files

		echo "备份目录: $backup_root"
		if [ ${#OPENCLAW_BACKUP_FILES[@]} -eq 0 ]; then
			echo "暂无备份文件"
			return 0
		fi

		for i in "${!OPENCLAW_BACKUP_FILES[@]}"; do
			file_type=$(openclaw_backup_detect_type "${OPENCLAW_BACKUP_FILES[$i]}")
			case "$file_type" in
				"记忆备份文件") has_memory=1 ;;
				"项目备份文件") has_project=1 ;;
				"其他备份文件") has_other=1 ;;
			esac
		done

		if [ "$has_memory" -eq 1 ]; then
			echo "记忆备份文件"
			for i in "${!OPENCLAW_BACKUP_FILES[@]}"; do
				file_name="${OPENCLAW_BACKUP_FILES[$i]}"
				file_type=$(openclaw_backup_detect_type "$file_name")
				[ "$file_type" != "记忆备份文件" ] && continue
				file_path="$backup_root/$file_name"
				file_size=$(ls -lh "$file_path" | awk '{print $5}')
				file_time=$(portable_file_mtime "$file_path")
				printf "%s | %s | %s\n" "$file_name" "$file_size" "$file_time"
			done
		fi

		if [ "$has_project" -eq 1 ]; then
			echo "项目备份文件"
			for i in "${!OPENCLAW_BACKUP_FILES[@]}"; do
				file_name="${OPENCLAW_BACKUP_FILES[$i]}"
				file_type=$(openclaw_backup_detect_type "$file_name")
				[ "$file_type" != "项目备份文件" ] && continue
				file_path="$backup_root/$file_name"
				file_size=$(ls -lh "$file_path" | awk '{print $5}')
				file_time=$(portable_file_mtime "$file_path")
				printf "%s | %s | %s\n" "$file_name" "$file_size" "$file_time"
			done
		fi

		if [ "$has_other" -eq 1 ]; then
			echo "其他备份文件"
			for i in "${!OPENCLAW_BACKUP_FILES[@]}"; do
				file_name="${OPENCLAW_BACKUP_FILES[$i]}"
				file_type=$(openclaw_backup_detect_type "$file_name")
				[ "$file_type" != "其他备份文件" ] && continue
				file_path="$backup_root/$file_name"
				file_size=$(ls -lh "$file_path" | awk '{print $5}')
				file_time=$(portable_file_mtime "$file_path")
				printf "%s | %s | %s\n" "$file_name" "$file_size" "$file_time"
			done
		fi
	}

	openclaw_backup_file_exists_in_list() {
		local target_file="$1"
		local item
		for item in "${OPENCLAW_BACKUP_FILES[@]}"; do
			[ "$item" = "$target_file" ] && return 0
		done
		return 1
	}

	openclaw_backup_delete_file() {
		send_stats "OpenClaw删除备份文件"
		local backup_root backup_root_real user_input target_file target_path target_type
		backup_root=$(openclaw_backup_root)

		openclaw_backup_render_file_list
		if [ ${#OPENCLAW_BACKUP_FILES[@]} -eq 0 ]; then
			break_end
			return 0
		fi

		read -e -p "请输入要删除的文件名或完整路径（0 取消）: " user_input
		if [ "$user_input" = "0" ]; then
			echo "已取消删除。"
			break_cancel
			return 0
		fi
		if [ -z "$user_input" ]; then
			echo "❌ 输入不能为空。"
			break_end
			return 1
		fi

		backup_root_real=$(realpath -m "$backup_root")
		if [[ "$user_input" == /* ]]; then
			target_path=$(realpath -m "$user_input")
			case "$target_path" in
				"$backup_root_real"/*) ;;
				*)
					echo "❌ 路径越界：仅允许删除备份根目录内的文件。"
					break_end
					return 1
					;;
			esac
			target_file=$(basename "$target_path")
		else
			target_file=$(basename -- "$user_input")
			target_path="$backup_root/$target_file"
		fi

		if [ ! -f "$target_path" ]; then
			echo "❌ 目标文件不存在: $target_path"
			break_end
			return 1
		fi

		if ! openclaw_backup_file_exists_in_list "$target_file"; then
			echo "❌ 目标文件不在当前备份列表中。"
			break_end
			return 1
		fi

		target_type=$(openclaw_backup_detect_type "$target_file")

		echo "即将删除: [$target_type] $target_path"
		read -e -p "第一次确认：输入 yes 确认继续: " confirm_step1
		if [ "$confirm_step1" != "yes" ]; then
			echo "已取消删除。"
			break_cancel
			return 0
		fi
		read -e -p "二次确认：输入 DELETE 执行删除: " confirm_step2
		if [ "$confirm_step2" != "DELETE" ]; then
			echo "已取消删除。"
			break_cancel
			return 0
		fi

		if rm -f -- "$target_path"; then
			echo "✅ 删除成功: $target_file"
		else
			echo "❌ 删除失败: $target_file"
		fi
		break_end
	}

	openclaw_backup_list_files() {
		openclaw_backup_render_file_list
		break_end
	}

	openclaw_memory_config_file() {
		local user_config="${HOME}/.openclaw/openclaw.json"
		local root_config="/root/.openclaw/openclaw.json"
		if [ -f "$user_config" ]; then
			echo "$user_config"
		elif [ "$HOME" = "/root" ] && [ -f "$root_config" ]; then
			echo "$root_config"
		else
			echo "$user_config"
		fi
	}

	openclaw_memory_config_get() {
		local key="$1"
		local default_value="${2:-}"
		local value
		value=$(openclaw config get "$key" 2>/dev/null | head -n 1 | sed -e 's/^"//' -e 's/"$//')
		if [ -z "$value" ] || [ "$value" = "null" ] || [ "$value" = "undefined" ]; then
			echo "$default_value"
			return 0
		fi
		echo "$value"
	}

	openclaw_memory_config_set() {
		local key="$1"
		shift
		openclaw config set "$key" "$@" >/dev/null 2>&1
	}

	openclaw_memory_config_unset() {
		local key="$1"
		openclaw config unset "$key" >/dev/null 2>&1
	}

	openclaw_memory_cleanup_legacy_keys() {
		openclaw_memory_config_unset "memory.local"
	}

	openclaw_memory_list_agents() {
		if command -v openclaw >/dev/null 2>&1; then
			local agents_json
			agents_json=$(openclaw agents list --json 2>/dev/null || true)
			if [ -n "$agents_json" ]; then
				python3 - "$agents_json" <<'PY'
import json, os, sys
raw = sys.argv[1]
try:
    data = json.loads(raw)
except Exception:
    data = None
seen = set()
results = []
if isinstance(data, list):
    for item in data:
        if not isinstance(item, dict):
            continue
        aid = item.get('id')
        if not aid or aid in seen:
            continue
        ws = item.get('workspace') or ("~/.openclaw/workspace" if aid == 'main' else f"~/.openclaw/workspace-{aid}")
        results.append((aid, os.path.expanduser(ws)))
        seen.add(aid)
if results:
    for aid, ws in results:
        print(f"{aid}\t{ws}")
    raise SystemExit(0)
raise SystemExit(1)
PY
				[ $? -eq 0 ] && return 0
			fi
		fi
		local config_path
		config_path=$(openclaw_memory_config_file)
		python3 - "$config_path" <<'PY'
import json, os, sys
config_path = sys.argv[1]
results = [("main", os.path.expanduser("~/.openclaw/workspace"))]
seen = {"main"}
try:
    if os.path.exists(config_path):
        with open(config_path, encoding='utf-8') as f:
            data = json.load(f)
        agents = data.get('agents', {}).get('list', [])
        if isinstance(agents, list):
            for item in agents:
                if not isinstance(item, dict):
                    continue
                aid = item.get('id')
                ws = item.get('workspace')
                if not aid or aid in seen:
                    continue
                if not ws:
                    ws = f"~/.openclaw/workspace-{aid}"
                results.append((aid, os.path.expanduser(ws)))
                seen.add(aid)
except Exception:
    pass
for aid, ws in results:
    print(f"{aid}\t{ws}")
PY
	}

	openclaw_memory_status_value() {
		local key="$1"
		local agent_id="${2:-}"
		if [ -n "$agent_id" ]; then
			openclaw memory status --agent "$agent_id" 2>/dev/null | awk -F': ' -v k="$key" '$1==k {print $2; exit}'
		else
			openclaw memory status 2>/dev/null | awk -F': ' -v k="$key" '$1==k {print $2; exit}'
		fi
	}

	openclaw_memory_expand_path() {
		local raw_path="$1"
		if [ -z "$raw_path" ]; then
			echo ""
			return 0
		fi
		raw_path=$(echo "$raw_path" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
		if [[ "$raw_path" == ~* ]]; then
			echo "${raw_path/#\~/$HOME}"
		else
			echo "$raw_path"
		fi
	}

	openclaw_memory_rebuild_index_single() {
		local agent_id="${1:-main}"
		local store_raw store_file ts backup_file
		store_raw=$(openclaw_memory_status_value "Store" "$agent_id")
		store_file=$(openclaw_memory_expand_path "$store_raw")
		if [ -z "$store_file" ] || [ ! -f "$store_file" ]; then
			echo "⚠️ [$agent_id] 未找到索引库文件，可能为空或不存在。"
			echo "   Store 原始值: ${store_raw:-<空>}"
			echo "   仍将执行重建索引。"
		else
			ts=$(date +%Y%m%d_%H%M%S)
			backup_file="${store_file}.bak.${ts}"
			if mv "$store_file" "$backup_file"; then
				echo "✅ [$agent_id] 已备份索引: $backup_file"
			else
				echo "⚠️ [$agent_id] 索引备份失败，继续重建。"
			fi
		fi
		openclaw memory index --agent "$agent_id" --force
	}

	openclaw_memory_rebuild_index_safe() {
		local agent_id="${1:-main}"
		openclaw_memory_rebuild_index_single "$agent_id"
		openclaw gateway restart
		echo "✅ 索引已重建并自动重启网关"
		echo ""
		openclaw_memory_render_status
	}

	openclaw_memory_rebuild_index_all() {
		local count=0
		local agent_lines agent_id workspace
		agent_lines=$(openclaw_memory_list_agents)
		while IFS=$'\t' read -r agent_id workspace; do
			[ -z "$agent_id" ] && continue
			openclaw_memory_rebuild_index_single "$agent_id"
			count=$((count+1))
		done <<EOF
$agent_lines
EOF
		openclaw gateway restart
		echo "✅ 索引已重建并自动重启网关"
		echo "✅ 已为 ${count} 个智能体重建索引"
		echo ""
		openclaw_memory_render_status
	}

	openclaw_memory_prepare_workspace() {
		local agent_id="${1:-main}"
		local workspace memory_dir
		workspace=$(openclaw_memory_status_value "Workspace" "$agent_id")
		if [ -z "$workspace" ]; then
			workspace="$HOME/.openclaw/workspace"
			[ "$agent_id" != "main" ] && workspace="$HOME/.openclaw/workspace-$agent_id"
		fi
		memory_dir="$workspace/memory"
		if [ ! -d "$memory_dir" ]; then
			echo "🔧 [$agent_id] 记忆目录不存在，已自动创建: $memory_dir"
			mkdir -p "$memory_dir"
		fi
		return 0
	}

	openclaw_memory_prepare_workspace_all() {
		local count=0
		local agent_lines agent_id workspace
		agent_lines=$(openclaw_memory_list_agents)
		echo "检查并准备 $(printf '%s\n' "$agent_lines" | sed '/^\s*$/d' | wc -l | tr -d ' ') 个智能体工作区"
		while IFS=$'\t' read -r agent_id workspace; do
			[ -z "$agent_id" ] && continue
			openclaw_memory_prepare_workspace "$agent_id"
			count=$((count+1))
		done <<EOF
$agent_lines
EOF
		return 0
	}

	openclaw_memory_render_status() {
		local json_output
		json_output=$(openclaw memory status --json 2>/dev/null)
		if [ -z "$json_output" ]; then
			echo "获取记忆状态失败（openclaw memory status --json 无输出）"
			return 1
		fi
		python3 - "$json_output" <<'PY'
import json, sys
raw = sys.argv[1]
try:
    data = json.loads(raw)
except Exception:
    print("获取记忆状态失败（JSON 解析错误）")
    raise SystemExit(1)
if not isinstance(data, list) or len(data) == 0:
    print("未检测到任何智能体记忆状态。")
    raise SystemExit(0)
first = True
for entry in data:
    if not isinstance(entry, dict):
        continue
    agent_id = entry.get("agentId", "?")
    s = entry.get("status", {})
    if not isinstance(s, dict):
        s = {}
    if not first:
        print("")
    first = False
    print("Agent: %s" % agent_id)
    backend = s.get("backend") or s.get("provider") or "-"
    print("  底层方案: %s" % backend)
    files = s.get("files", 0)
    chunks = s.get("chunks", 0)
    print("  已收录: %s 文件 / %s 块" % (files, chunks))
    dirty = s.get("dirty")
    dirty_str = "是" if dirty else "否"
    print("  待刷新: %s" % dirty_str)
    vec = s.get("vector", {})
    if isinstance(vec, dict) and vec.get("enabled"):
        vec_str = "就绪" if vec.get("available") else "已启用(不可用)"
    else:
        vec_str = "未启用"
    print("  向量库: %s" % vec_str)
    ws = s.get("workspaceDir") or "-"
    print("  工作区: %s" % ws)
    db = s.get("dbPath") or "-"
    print("  索引库: %s" % db)
    scan = entry.get("scan", {})
    if isinstance(scan, dict):
        issues = scan.get("issues", [])
        if issues:
            for issue in issues[:3]:
                print("  ⚠️ %s" % issue)
PY
	}

	openclaw_memory_get_backend() {
		local backend
		backend=$(openclaw_memory_config_get "memory.backend")
		if [ "$backend" = "local" ]; then
			echo "builtin"
		else
			echo "$backend"
		fi
	}

	openclaw_memory_get_local_model_path() {
		openclaw_memory_config_get "agents.defaults.memorySearch.local.modelPath"
	}

	openclaw_memory_local_model_status() {
		local model_path="$1"
		if [ -z "$model_path" ]; then
			echo "missing"
			return
		fi
		if [[ "$model_path" == hf:* ]]; then
			echo "hf"
			return
		fi
		if [ -f "$model_path" ]; then
			echo "ok"
		else
			echo "missing"
		fi
	}

	openclaw_memory_qmd_available() {
		if command -v qmd >/dev/null 2>&1; then
			echo "true"
			return
		fi
		local backend
		backend=$(openclaw_memory_config_get "memory.backend")
		if [ "$backend" = "qmd" ]; then
			echo "true"
			return
		fi
		echo "false"
	}

	openclaw_memory_probe_url() {
		local url="$1"
		if ! command -v curl >/dev/null 2>&1; then
			echo "unknown"
			return
		fi
		if [ -z "$url" ]; then
			echo "unknown"
			return
		fi
		if curl -I -m 2 -s "$url" >/dev/null 2>&1; then
			echo "ok"
		else
			echo "fail"
		fi
	}

	openclaw_memory_recommend() {
		local qmd_ok model_path model_status hf_ok mirror_ok
		qmd_ok=$(openclaw_memory_qmd_available)
		model_path=$(openclaw_memory_get_local_model_path)
		model_status=$(openclaw_memory_local_model_status "$model_path")
		hf_ok=$(openclaw_memory_probe_url "https://huggingface.co")
		mirror_ok=$(openclaw_memory_probe_url "https://hf-mirror.com")

		OPENCLAW_MEMORY_RECOMMEND_REASON=()
		if [ "$qmd_ok" = "true" ]; then
			OPENCLAW_MEMORY_RECOMMEND_REASON+=("QMD 可用")
		else
			OPENCLAW_MEMORY_RECOMMEND_REASON+=("未检测到 QMD")
		fi
		if [ -n "$model_path" ]; then
			OPENCLAW_MEMORY_RECOMMEND_REASON+=("本地模型路径: $model_path")
		else
			OPENCLAW_MEMORY_RECOMMEND_REASON+=("未配置本地模型路径")
		fi
		case "$model_status" in
			ok) OPENCLAW_MEMORY_RECOMMEND_REASON+=("本地模型文件存在") ;;
			hf) OPENCLAW_MEMORY_RECOMMEND_REASON+=("模型来自 HF 下载源（国内可能慢/失败）") ;;
			*) OPENCLAW_MEMORY_RECOMMEND_REASON+=("本地模型文件不存在或不可用") ;;
		esac
		if [ "$hf_ok" = "ok" ]; then
			OPENCLAW_MEMORY_RECOMMEND_REASON+=("huggingface.co 可访问")
		elif [ "$mirror_ok" = "ok" ]; then
			OPENCLAW_MEMORY_RECOMMEND_REASON+=("hf-mirror.com 可访问")
		else
			OPENCLAW_MEMORY_RECOMMEND_REASON+=("huggingface.co / hf-mirror.com 可能不可达（疑似国内/受限网络）")
		fi

		if [ "$qmd_ok" = "true" ]; then
			if [ "$model_status" = "ok" ]; then
				OPENCLAW_MEMORY_RECOMMEND="local"
			elif [ "$model_status" = "hf" ] && { [ "$hf_ok" = "ok" ] || [ "$mirror_ok" = "ok" ]; }; then
				OPENCLAW_MEMORY_RECOMMEND="local"
			elif [ "$model_status" = "hf" ] && [ "$hf_ok" = "fail" ] && [ "$mirror_ok" = "fail" ]; then
				OPENCLAW_MEMORY_RECOMMEND="qmd"
			else
				OPENCLAW_MEMORY_RECOMMEND="qmd"
			fi
		else
			if [ "$model_status" = "ok" ]; then
				OPENCLAW_MEMORY_RECOMMEND="local"
			else
				OPENCLAW_MEMORY_RECOMMEND="qmd"
			fi
		fi
	}


	openclaw_memory_detect_region() {
		OPENCLAW_MEMORY_COUNTRY="unknown"
		OPENCLAW_MEMORY_USE_MIRROR="false"
		if command -v curl >/dev/null 2>&1; then
			OPENCLAW_MEMORY_COUNTRY=$(curl -s -m 2 ipinfo.io/country | tr -d '
' | tr -d '
')
		fi
		case "$OPENCLAW_MEMORY_COUNTRY" in
			CN|HK)
				OPENCLAW_MEMORY_USE_MIRROR="true"
				;;
		esac
	}

	openclaw_memory_select_sources() {
		local hf_ok mirror_ok
		hf_ok=$(openclaw_memory_probe_url "https://huggingface.co")
		mirror_ok=$(openclaw_memory_probe_url "https://hf-mirror.com")
		OPENCLAW_MEMORY_HF_OK="$hf_ok"
		OPENCLAW_MEMORY_MIRROR_OK="$mirror_ok"
		if [ "$OPENCLAW_MEMORY_USE_MIRROR" = "true" ]; then
			if [ "$mirror_ok" = "ok" ]; then
				OPENCLAW_MEMORY_HF_BASE="https://hf-mirror.com"
			elif [ "$hf_ok" = "ok" ]; then
				OPENCLAW_MEMORY_HF_BASE="https://huggingface.co"
			else
				OPENCLAW_MEMORY_HF_BASE="https://hf-mirror.com"
			fi
			OPENCLAW_MEMORY_GH_PROXY="https://gh.riwi.pro/"
		else
			if [ "$hf_ok" = "ok" ]; then
				OPENCLAW_MEMORY_HF_BASE="https://huggingface.co"
			elif [ "$mirror_ok" = "ok" ]; then
				OPENCLAW_MEMORY_HF_BASE="https://hf-mirror.com"
			else
				OPENCLAW_MEMORY_HF_BASE="https://huggingface.co"
			fi
			OPENCLAW_MEMORY_GH_PROXY="https://"
		fi
	}

	openclaw_memory_download_file() {
		local url="$1"
		local dest="$2"
		mkdir -p "$(dirname "$dest")"
		if command -v curl >/dev/null 2>&1; then
			curl -L --fail --retry 2 -o "$dest" "$url"
			return $?
		fi
		if command -v wget >/dev/null 2>&1; then
			wget -O "$dest" "$url"
			return $?
		fi
		echo "❌ 未检测到 curl 或 wget，无法下载。"
		return 1
	}

	openclaw_memory_check_sqlite() {
		if ! command -v sqlite3 >/dev/null 2>&1; then
			echo "⚠️ 未检测到 sqlite3，QMD 可能无法正常运行。"
			return 1
		fi
		local ver
		ver=$(sqlite3 --version 2>/dev/null | awk '{print $1}')
		echo "✅ sqlite3 可用: ${ver:-unknown}"
		echo "ℹ️ sqlite 扩展支持无法可靠检测，将继续。"
		return 0
	}

	openclaw_memory_ensure_bun() {
		if [ -x "$HOME/.bun/bin/bun" ]; then
			export PATH="$HOME/.bun/bin:$PATH"
		fi
		if command -v bun >/dev/null 2>&1; then
			echo "✅ bun 已存在"
			return 0
		fi
		echo "⬇️ 安装 bun..."
		if command -v curl >/dev/null 2>&1; then
			curl -fsSL https://bun.sh/install | bash
		elif command -v wget >/dev/null 2>&1; then
			wget -qO- https://bun.sh/install | bash
		else
			echo "❌ 未检测到 curl 或 wget，无法安装 bun。"
			return 1
		fi
		if [ -d "$HOME/.bun/bin" ]; then
			export PATH="$HOME/.bun/bin:$PATH"
		fi
		if command -v bun >/dev/null 2>&1; then
			echo "✅ bun 安装完成"
			return 0
		fi
		echo "❌ bun 安装失败"
		return 1
	}

	openclaw_memory_ensure_qmd() {
		local qmd_path
		qmd_path=$(command -v qmd 2>/dev/null || true)
		if [ -n "$qmd_path" ]; then
			if qmd --version >/dev/null 2>&1; then
				echo "✅ qmd 已存在且可用: $qmd_path"
				OPENCLAW_MEMORY_QMD_PATH="$qmd_path"
				return 0
			else
				echo "⚠️ qmd 命令存在但模块损坏，重新安装..."
			fi
		fi
		echo "⬇️ 通过 npm 安装 qmd: @tobilu/qmd"
		npm install -g @tobilu/qmd
		qmd_path=$(command -v qmd 2>/dev/null || true)
		if [ -z "$qmd_path" ]; then
			echo "❌ qmd 安装失败"
			return 1
		fi
		if ! qmd --version >/dev/null 2>&1; then
			echo "❌ qmd 安装后仍无法运行"
			return 1
		fi
		OPENCLAW_MEMORY_QMD_PATH="$qmd_path"
		echo "✅ qmd 安装完成: $qmd_path"
		return 0
	}

	openclaw_memory_render_auto_summary() {
		echo -e "${rw_cheng}---------------------------------------${rw_lv}"
		echo "✅ 环境就绪"
		echo "方案: ${OPENCLAW_MEMORY_AUTO_SCHEME:-unknown}"
		if [ "$OPENCLAW_MEMORY_CONFIG_ONLY" = "true" ]; then
			echo "模式: 仅写配置（未安装/未下载）"
		fi
		if [ "$OPENCLAW_MEMORY_PREHEAT" = "true" ]; then
			echo "索引: 已执行"
		else
			echo "索引: 已跳过"
		fi
		if [ "$OPENCLAW_MEMORY_RESTARTED" = "true" ]; then
			echo "重启: 已执行"
		else
			echo "重启: 已跳过"
		fi
		if [ -n "$OPENCLAW_MEMORY_QMD_PATH" ]; then
			echo "qmd: $OPENCLAW_MEMORY_QMD_PATH"
		fi
		if [ -n "$OPENCLAW_MEMORY_MODEL_PATH" ]; then
			echo "模型: $OPENCLAW_MEMORY_MODEL_PATH"
		fi
		if [ -n "$OPENCLAW_MEMORY_COUNTRY" ]; then
			echo "地区: $OPENCLAW_MEMORY_COUNTRY"
		fi
		if [ -n "$OPENCLAW_MEMORY_HF_BASE" ]; then
			echo "下载源: $OPENCLAW_MEMORY_HF_BASE"
		fi
		echo "最终状态:"
		openclaw_memory_render_status
		echo -e "${rw_cheng}---------------------------------------${rw_lv}"
	}

	openclaw_memory_auto_confirm() {
		local scheme_label="$1"
		OPENCLAW_MEMORY_PREHEAT="true"
		OPENCLAW_MEMORY_RESTARTED="false"
		OPENCLAW_MEMORY_CONFIG_ONLY="false"
		echo "即将执行自动部署（详细模式）"
		echo "目标方案: $scheme_label"
		echo "地区: ${OPENCLAW_MEMORY_COUNTRY:-unknown}"
		echo "镜像源探测: huggingface.co=${OPENCLAW_MEMORY_HF_OK:-unknown} hf-mirror.com=${OPENCLAW_MEMORY_MIRROR_OK:-unknown}"
		echo "下载源: ${OPENCLAW_MEMORY_HF_BASE:-unknown}"
		if [ -n "$OPENCLAW_MEMORY_EXPECT_PATH" ]; then
			echo "预计下载路径: $OPENCLAW_MEMORY_EXPECT_PATH"
		fi
		if [ -n "$OPENCLAW_MEMORY_EXPECT_SIZE" ]; then
			echo "可能流量/磁盘占用: $OPENCLAW_MEMORY_EXPECT_SIZE"
		else
			echo "可能流量/磁盘占用: 视实际情况而定"
		fi
		echo "确认后将自动安装/下载、写入配置、构建索引并重启网关"
		echo "高级选项: 输入 config 仅写配置（不安装不下载、不索引、不重启）"
		read -e -p "输入 yes 确认继续（默认 N）: " confirm_step
		case "$confirm_step" in
			yes|YES)
				OPENCLAW_MEMORY_PREHEAT="true"
				;;
			config|CONFIG)
				OPENCLAW_MEMORY_CONFIG_ONLY="true"
				OPENCLAW_MEMORY_PREHEAT="false"
				;;
			*)
				echo "已取消自动部署。"
				return 1
				;;
		esac
		if [ "$OPENCLAW_MEMORY_CONFIG_ONLY" = "true" ]; then
			echo "⚠️ 已选择仅写配置，不安装不下载"
		else
			echo "✅ 将自动构建索引并重启网关"
		fi
		return 0
	}

	openclaw_memory_auto_setup_qmd() {
		echo "🔍 检测 QMD 环境"
		openclaw_memory_cleanup_legacy_keys
		openclaw_memory_check_sqlite || true
		if [ "$OPENCLAW_MEMORY_CONFIG_ONLY" = "true" ]; then
			if command -v qmd >/dev/null 2>&1; then
				OPENCLAW_MEMORY_QMD_PATH=$(command -v qmd)
			else
				OPENCLAW_MEMORY_QMD_PATH="qmd"
			fi
		else
			openclaw_memory_ensure_qmd || return 1
		fi
		local backend
		backend=$(openclaw_memory_get_backend)
		if [ "$backend" = "qmd" ]; then
			echo "✅ memory.backend 已是 qmd"
		else
			openclaw_memory_config_set "memory.backend" "qmd"
			echo "✅ 已设置 memory.backend=qmd"
		fi
		local qmd_cmd
		qmd_cmd=$(openclaw_memory_config_get "memory.qmd.command")
		if [ -z "$qmd_cmd" ] || [[ "$qmd_cmd" != /* ]] || [ "$qmd_cmd" != "$OPENCLAW_MEMORY_QMD_PATH" ]; then
			openclaw_memory_config_set "memory.qmd.command" "$OPENCLAW_MEMORY_QMD_PATH"
			echo "✅ 已写入 memory.qmd.command: $OPENCLAW_MEMORY_QMD_PATH"
		else
			echo "✅ memory.qmd.command 已正确"
		fi
		if [ "$OPENCLAW_MEMORY_PREHEAT" = "true" ]; then
			echo "🔥 预热索引（可能下载模型）"
			openclaw_memory_prepare_workspace_all
			local preh_agent_lines preh_agent_id preh_workspace
			preh_agent_lines=$(openclaw_memory_list_agents)
			while IFS=$'\t' read -r preh_agent_id preh_workspace; do
				[ -z "$preh_agent_id" ] && continue
				openclaw memory index --agent "$preh_agent_id" --force
			done <<EOF
$preh_agent_lines
EOF
		else
			echo "⏭️ 已跳过预热"
		fi
		echo "✅ QMD 自动部署完成"
	}

	openclaw_memory_auto_setup_local() {
		echo "🔍 检测 Local 环境"
		openclaw_memory_cleanup_legacy_keys
		local backend provider
		backend=$(openclaw_memory_get_backend)
		if [ "$backend" = "builtin" ] || [ "$backend" = "local" ]; then
			echo "✅ memory.backend 已是 builtin"
		else
			openclaw_memory_config_set "memory.backend" "builtin"
			echo "✅ 已设置 memory.backend=builtin"
		fi
		provider=$(openclaw_memory_config_get "agents.defaults.memorySearch.provider")
		if [ "$provider" = "local" ]; then
			echo "✅ memorySearch.provider 已是 local"
		else
			openclaw_memory_config_set "agents.defaults.memorySearch.provider" "local"
			echo "✅ 已设置 agents.defaults.memorySearch.provider=local"
		fi

		local model_path model_status
		model_path=$(openclaw_memory_get_local_model_path)
		model_path=$(openclaw_memory_expand_path "$model_path")
		model_status=$(openclaw_memory_local_model_status "$model_path")
		if [ "$model_status" = "ok" ]; then
			echo "✅ 模型文件已存在: $model_path"
			OPENCLAW_MEMORY_MODEL_PATH="$model_path"
		else
			local model_name="embeddinggemma-300M-Q8_0.gguf"
			local model_dir="$HOME/.openclaw/models/embedding"
			local model_dest="$model_dir/$model_name"
			local model_url="${OPENCLAW_MEMORY_HF_BASE}/ggml-org/embeddinggemma-300M-GGUF/resolve/main/$model_name"
			if [ "$OPENCLAW_MEMORY_CONFIG_ONLY" = "true" ]; then
				echo "ℹ️ 仅写配置模式：跳过模型下载"
				OPENCLAW_MEMORY_MODEL_PATH="$model_dest"
			else
				if [ -f "$model_dest" ]; then
					echo "✅ 已发现默认模型文件: $model_dest"
				else
					echo "⬇️ 下载模型: $model_url"
					openclaw_memory_download_file "$model_url" "$model_dest" || return 1
					echo "✅ 模型已下载: $model_dest"
				fi
				OPENCLAW_MEMORY_MODEL_PATH="$model_dest"
			fi
			openclaw_memory_config_set "agents.defaults.memorySearch.local.modelPath" "$model_dest"
			echo "✅ 已写入模型路径"
		fi
		if [ "$OPENCLAW_MEMORY_PREHEAT" = "true" ]; then
			echo "🔥 预热索引（可能下载模型）"
			openclaw_memory_prepare_workspace_all
			local preh_agent_lines preh_agent_id preh_workspace
			preh_agent_lines=$(openclaw_memory_list_agents)
			while IFS=$'\t' read -r preh_agent_id preh_workspace; do
				[ -z "$preh_agent_id" ] && continue
				openclaw memory index --agent "$preh_agent_id" --force
			done <<EOF
$preh_agent_lines
EOF
		else
			echo "⏭️ 已跳过预热"
		fi
		echo "✅ Local 自动部署完成"
	}

	openclaw_memory_auto_setup_run() {
		local scheme="$1"
		local scheme_label
		OPENCLAW_MEMORY_QMD_PATH=""
		OPENCLAW_MEMORY_MODEL_PATH=""
		OPENCLAW_MEMORY_EXPECT_PATH=""
		OPENCLAW_MEMORY_EXPECT_SIZE=""
		openclaw_memory_detect_region
		openclaw_memory_select_sources
		if [ "$scheme" = "auto" ]; then
			openclaw_memory_recommend
			scheme="$OPENCLAW_MEMORY_RECOMMEND"
		fi
		case "$scheme" in
			qmd)
				scheme_label="QMD"
				OPENCLAW_MEMORY_EXPECT_PATH="$HOME/.bun (qmd 安装目录)"
				OPENCLAW_MEMORY_EXPECT_SIZE="约 20-50MB"
				;;
			local)
				scheme_label="Local"
				OPENCLAW_MEMORY_EXPECT_PATH="$HOME/.openclaw/models/embedding/embeddinggemma-300M-Q8_0.gguf"
				OPENCLAW_MEMORY_EXPECT_SIZE="约 350-600MB"
				;;
			*)
				echo "❌ 未知方案: $scheme"
				return 1
				;;
		esac
		OPENCLAW_MEMORY_AUTO_SCHEME="$scheme_label"
		openclaw_memory_auto_confirm "$scheme_label" || return 0
		case "$scheme" in
			qmd) openclaw_memory_auto_setup_qmd || return 1 ;;
			local) openclaw_memory_auto_setup_local || return 1 ;;
			*) return 1 ;;
		esac
		if [ "$OPENCLAW_MEMORY_CONFIG_ONLY" = "true" ]; then
			OPENCLAW_MEMORY_RESTARTED="false"
			openclaw_memory_render_auto_summary
			return 0
		fi
		echo "♻️ 重启 OpenClaw 网关"
		if declare -F start_gateway >/dev/null 2>&1; then
			start_gateway
		else
			openclaw gateway restart
		fi
		OPENCLAW_MEMORY_RESTARTED="true"
		openclaw_memory_render_auto_summary
		return 0
	}

	openclaw_memory_auto_setup_menu() {
		while true; do
			clear
			echo -e "${rw_cheng}=======================================${rw_lv}"
			echo "记忆方案自动部署"
			echo -e "${rw_cheng}=======================================${rw_lv}"
			echo "1. QMD"
			echo "2. Local"
			echo "3. Auto（自动选择）"
			echo "0. 返回上一级"
			echo -e "${rw_cheng}---------------------------------------${rw_lv}"
			read -e -p "请输入你的选择: " auto_choice
			case "$auto_choice" in
				1)
					openclaw_memory_auto_setup_run "qmd"
					break_end
					;;
				2)
					openclaw_memory_auto_setup_run "local"
					break_end
					;;
				3)
					openclaw_memory_auto_setup_run "auto"
					break_end
					;;
				0)
					return 0
					;;
				*)
					echo "无效的选择，请重试。"
					sleep 1
					;;
			esac
		done
	}

	openclaw_memory_apply_scheme() {
		local scheme="$1"
		openclaw_memory_cleanup_legacy_keys
		case "$scheme" in
			qmd)
				openclaw_memory_config_set "memory.backend" "qmd"
				if [ $? -ne 0 ]; then
					echo "❌ 写入配置失败"
					return 1
				fi
				openclaw_memory_config_set "memory.qmd.command" "qmd" >/dev/null 2>&1
				;;
			local)
				openclaw_memory_config_set "memory.backend" "builtin"
				if [ $? -ne 0 ]; then
					echo "❌ 写入配置失败"
					return 1
				fi
				openclaw_memory_config_set "agents.defaults.memorySearch.provider" "local" >/dev/null 2>&1
				;;
			*)
				echo "❌ 未知方案: $scheme"
				return 1
			esac
		echo "✅ 已更新记忆方案配置"
		return 0
	}

	openclaw_memory_offer_restart() {
		echo "配置已写入，需要重启 OpenClaw 网关后生效。"
		read -e -p "是否立即重启 OpenClaw 网关？(Y/n): " restart_choice
		if [[ "$restart_choice" =~ ^[Nn]$ ]]; then
			echo "已跳过重启，可稍后执行: openclaw gateway restart"
			return 0
		fi
		if declare -F start_gateway >/dev/null 2>&1; then
			start_gateway
		else
			openclaw gateway restart
		fi
	}

	openclaw_memory_fix_index() {
		local backend include_dm
		backend=$(openclaw_memory_get_backend)
		if [ "$backend" = "qmd" ] && ! command -v qmd >/dev/null 2>&1; then
			echo "⚠️ 检测到当前方案为 QMD，但未安装 qmd 命令。"
			echo "   可切换 Local，或安装 bun + qmd 后再试。"
		fi
		include_dm=$(openclaw config get memory.qmd.includeDefaultMemory 2>/dev/null)
		echo -e "${rw_cheng}=======================================${rw_lv}"
		echo "索引修复诊断"
		echo -e "${rw_cheng}=======================================${rw_lv}"
		echo "当前 includeDefaultMemory: ${include_dm:-未设置}"
		echo ""
		if [ "$include_dm" = "false" ]; then
			echo "⚠️ 检测到 includeDefaultMemory=false"
			echo "   这会导致默认记忆文件（MEMORY.md + memory/*.md）不被索引"
			echo "   所以 Indexed 会一直显示 0/N"
			echo ""
			read -e -p "是否恢复为 true 并重建索引？(Y/n): " fix_choice
			if [[ ! "$fix_choice" =~ ^[Nn]$ ]]; then
				openclaw_memory_config_set "memory.qmd.includeDefaultMemory" true
				if [ $? -ne 0 ]; then
					echo "❌ 写入配置失败"
					break_end
					return 1
				fi
				echo "✅ 已恢复 includeDefaultMemory=true"
				openclaw_memory_rebuild_index_all
			else
				echo "已取消。"
			fi
		else
			echo "includeDefaultMemory 配置正常。"
			echo "将执行：清理旧索引 → 全量重建所有智能体索引"
			echo ""
			read -e -p "确认执行？(Y/n): " confirm_fix
			if [[ ! "$confirm_fix" =~ ^[Nn]$ ]]; then
				openclaw_memory_rebuild_index_all
				break_end
			else
				echo "已取消。"
			fi
		fi
	}

	openclaw_memory_scheme_menu() {
		while true; do
			clear
			echo -e "${rw_cheng}=======================================${rw_lv}"
			echo "OpenClaw 记忆方案"
			echo -e "${rw_cheng}=======================================${rw_lv}"
			local backend current_label
			backend=$(openclaw_memory_get_backend)
			case "$backend" in
				qmd) current_label="QMD" ;;
				builtin|local) current_label="Local" ;;
				*) current_label="未配置" ;;
			esac
			echo "当前方案: $current_label"
			echo ""
			echo "QMD  : 轻量索引，依赖 qmd 命令（适合网络受限）"
			echo "Local: 本地向量检索，依赖 embedding 模型文件"
			echo "Auto : 自动推荐（基于可用性 + 网络探测）"
			echo -e "${rw_cheng}---------------------------------------${rw_lv}"
			echo "1. 切换 QMD（自动部署/已装则跳过）"
			echo "2. 切换 Local（自动部署/已装则跳过）"
			echo "3. Auto（自动推荐并自动部署）"
			echo "0. 返回上一级"
			echo -e "${rw_cheng}---------------------------------------${rw_lv}"
			read -e -p "请输入你的选择: " scheme_choice
			case "$scheme_choice" in
				1)
					openclaw_memory_auto_setup_run "qmd"
					break_end
					;;
				2)
					openclaw_memory_auto_setup_run "local"
					break_end
					;;
				3)
					openclaw_memory_auto_setup_run "auto"
					break_end
					;;
				0)
					return 0
					;;
				*)
					echo "无效的选择，请重试。"
					sleep 1
					;;
			esac
		done
	}

	openclaw_memory_file_collect() {
		OPENCLAW_MEMORY_FILES=()
		OPENCLAW_MEMORY_FILE_LABELS=()
		local agent_lines agent_id base_dir memory_dir memory_file rel
		agent_lines=$(openclaw_memory_list_agents)
		while IFS=$'\t' read -r agent_id base_dir; do
			[ -z "$agent_id" ] && continue
			memory_dir="$base_dir/memory"
			memory_file="$base_dir/MEMORY.md"
			if [ -f "$memory_file" ]; then
				OPENCLAW_MEMORY_FILES+=("$memory_file")
				OPENCLAW_MEMORY_FILE_LABELS+=("$agent_id/MEMORY.md")
			fi
			if [ -d "$memory_dir" ]; then
				while IFS= read -r file; do
					[ -f "$file" ] || continue
					rel="${file#$base_dir/}"
					OPENCLAW_MEMORY_FILES+=("$file")
					OPENCLAW_MEMORY_FILE_LABELS+=("$agent_id/$rel")
				done < <(find "$memory_dir" -type f -name '*.md' | sort)
			fi
		done <<EOF
$agent_lines
EOF
	}

	openclaw_memory_file_render_list() {
		openclaw_memory_file_collect
		if [ ${#OPENCLAW_MEMORY_FILES[@]} -eq 0 ]; then
			echo "未找到记忆文件。"
			return 0
		fi
		echo "编号 | 归属 | 大小 | 修改时间"
		echo -e "${rw_cheng}---------------------------------------${rw_lv}"
		local i file rel size mtime
		for i in "${!OPENCLAW_MEMORY_FILES[@]}"; do
			file="${OPENCLAW_MEMORY_FILES[$i]}"
			rel="${OPENCLAW_MEMORY_FILE_LABELS[$i]}"
			size=$(ls -lh "$file" | awk '{print $5}')
			mtime=$(portable_file_mtime "$file")
			printf "%s | %s | %s | %s\\n" "$((i+1))" "$rel" "$size" "$mtime"
		done
	}

	openclaw_memory_view_file() {
		local file="$1"
		[ -f "$file" ] || {
			echo "❌ 文件不存在: $file"
			return 1
		}
		local total_lines
		total_lines=$(wc -l < "$file" 2>/dev/null || echo 0)
		local default_lines=120
		local start_line count
		echo "文件: $file"
		echo "总行数: $total_lines"
		read -e -p "请输入起始行（回车默认末尾 $default_lines 行）: " start_line
		read -e -p "请输入显示行数（回车默认 $default_lines）: " count
		[ -z "$count" ] && count=$default_lines
		if [ -z "$start_line" ]; then
			if [ "$total_lines" -le "$count" ]; then
				start_line=1
			else
				start_line=$((total_lines - count + 1))
			fi
		fi
		if ! [[ "$start_line" =~ ^[0-9]+$ ]] || ! [[ "$count" =~ ^[0-9]+$ ]]; then
			echo "❌ 请输入有效的数字。"
			return 1
		fi
		if [ "$start_line" -lt 1 ]; then
			start_line=1
		fi
		if [ "$count" -le 0 ]; then
			echo "❌ 行数必须大于 0。"
			return 1
		fi
		local end_line=$((start_line + count - 1))
		if [ "$end_line" -gt "$total_lines" ]; then
			end_line=$total_lines
		fi
		if [ "$total_lines" -eq 0 ]; then
			echo "(空文件)"
			return 0
		fi
		echo -e "${rw_cheng}---------------------------------------${rw_lv}"
		sed -n "${start_line},${end_line}p" "$file"
		echo -e "${rw_cheng}---------------------------------------${rw_lv}"
	}

	openclaw_memory_files_menu() {
		while true; do
			clear
			echo -e "${rw_cheng}=======================================${rw_lv}"
			echo "OpenClaw 记忆文件"
			echo -e "${rw_cheng}=======================================${rw_lv}"
			openclaw_memory_file_render_list
			echo -e "${rw_cheng}---------------------------------------${rw_lv}"
			read -e -p "请输入文件编号查看（0 返回）: " file_choice
			if [ "$file_choice" = "0" ]; then
				return 0
			fi
			if ! [[ "$file_choice" =~ ^[0-9]+$ ]]; then
				echo "无效的选择，请重试。"
				sleep 1
				continue
			fi
			openclaw_memory_file_collect
			if [ ${#OPENCLAW_MEMORY_FILES[@]} -eq 0 ]; then
				read -p "未找到记忆文件，按回车返回..."
				return 0
			fi
			local idx=$((file_choice-1))
			if [ "$idx" -lt 0 ] || [ "$idx" -ge ${#OPENCLAW_MEMORY_FILES[@]} ]; then
				echo "无效的编号，请重试。"
				sleep 1
				continue
			fi
			openclaw_memory_view_file "${OPENCLAW_MEMORY_FILES[$idx]}"
			read -p "按回车返回列表..."
			done
	}


	openclaw_memory_search_test() {
		read -e -p "输入搜索关键词: " query
		if [ -z "$query" ]; then
			echo "关键词不能为空。"
			return 1
		fi
		echo "正在搜索记忆..."
		openclaw memory search "$query" --max-results 5
	}

	openclaw_memory_deep_status() {
		echo "正在探测嵌入模型就绪状态..."
		openclaw memory status --deep
	}

	openclaw_memory_menu() {
		send_stats "OpenClaw记忆管理"
		while true; do
			clear
			echo -e "${rw_cheng}=======================================${rw_lv}"
			echo "OpenClaw 记忆管理"
			echo -e "${rw_cheng}=======================================${rw_lv}"
			openclaw_memory_render_status
			echo "1. 更新记忆索引"
			echo "2. 查看记忆文件"
			echo "3. 索引修复（Indexed 异常）"
			echo "4. 记忆方案（QMD/Local/Auto）"
			echo "5. 搜索测试（验证索引是否工作）"
			echo "6. 深度状态探测（检查嵌入模型）"
			echo "0. 返回上一级"
			echo -e "${rw_cheng}---------------------------------------${rw_lv}"
			read -e -p "请输入你的选择: " memory_choice
			case "$memory_choice" in
				1)
					echo "即将更新记忆索引。"
					read -e -p "第一次确认：输入 yes 继续: " confirm_step1
					if [ "$confirm_step1" != "yes" ]; then
						echo "已取消。"
						break_cancel
						continue
					fi
				openclaw_memory_prepare_workspace_all
				read -e -p "二次确认：输入 force 使用全量（留空为增量）: " confirm_step2
				if [ "$confirm_step2" = "force" ]; then
					echo "⚠️ 全量重建更彻底，但耗时更长。"
					echo "推荐：输入 rebuild 进行安全重建（先备份索引库）。"
					read -e -p "第三次确认：输入 rebuild 执行安全重建；直接回车继续普通 force: " confirm_step3
					if [ "$confirm_step3" = "rebuild" ]; then
						openclaw_memory_rebuild_index_all
					else
						local fl_agent_lines fl_agent_id fl_workspace
						fl_agent_lines=$(openclaw_memory_list_agents)
						while IFS=$'\t' read -r fl_agent_id fl_workspace; do
							[ -z "$fl_agent_id" ] && continue
							openclaw memory index --agent "$fl_agent_id" --force
						done <<EOF
$fl_agent_lines
EOF
						openclaw gateway restart
						echo "✅ 已对所有智能体执行 force 重建并自动重启网关"
					fi
				else
					openclaw memory index
				fi
				break_end
					;;
				2)
					openclaw_memory_files_menu
					;;
				3)
					openclaw_memory_fix_index
					;;
				4)
					openclaw_memory_scheme_menu
					;;
				5)
					openclaw_memory_search_test
					break_end
					;;
				6)
					openclaw_memory_deep_status
					break_end
					;;
				0)
					return 0
					;;
				*)
					echo "无效的选择，请重试。"
					sleep 1
					;;
			esac
		done
	}

	openclaw_permission_config_file() {
		echo "$(openclaw_get_config_file)"
	}

	openclaw_permission_backup_file() {
		local backup_root
		backup_root=$(openclaw_backup_root)
		echo "${backup_root}/openclaw-permission-last.json"
	}

	openclaw_permission_require_openclaw() {
		if ! openclaw_has_command openclaw; then
			echo "❌ 未检测到 openclaw 命令，请先安装或初始化 OpenClaw。"
			return 1
		fi
		return 0
	}

	openclaw_permission_backup_current() {
		local config_file backup_file
		config_file=$(openclaw_permission_config_file)
		backup_file=$(openclaw_permission_backup_file)
		if [ ! -s "$config_file" ]; then
			echo "⚠️ 未找到 OpenClaw 配置文件，跳过权限备份。"
			return 1
		fi
		mkdir -p "$(dirname "$backup_file")"
		cp -f "$config_file" "$backup_file" >/dev/null 2>&1 || {
			echo "⚠️ 权限备份失败：$backup_file"
			return 1
		}
		echo "✅ 已备份当前权限配置: $backup_file"
		return 0
	}

	openclaw_permission_restore_backup() {
		local config_file backup_file
		config_file=$(openclaw_permission_config_file)
		backup_file=$(openclaw_permission_backup_file)
		if [ ! -s "$backup_file" ]; then
			echo "❌ 未找到可恢复的权限备份文件。"
			return 1
		fi
		cp -f "$backup_file" "$config_file" >/dev/null 2>&1 || {
			echo "❌ 权限恢复失败：$backup_file"
			return 1
		}
		echo "✅ 已恢复切换前权限配置"
		openclaw_permission_restart_gateway || true
		return 0
	}

	openclaw_permission_restart_gateway() {
		if ! openclaw_has_command openclaw; then
			echo "❌ 未检测到 openclaw，无法重启 OpenClaw Gateway。"
			return 1
		fi
		echo "正在重启 OpenClaw Gateway..."
		openclaw gateway restart >/dev/null 2>&1 || {
			openclaw gateway stop >/dev/null 2>&1
			openclaw gateway start >/dev/null 2>&1
		}
	}

	openclaw_permission_get_value() {
		local path="$1"
		local config_file
		config_file=$(openclaw_permission_config_file)

		if openclaw_has_command openclaw; then
			local value
			value=$(openclaw config get "$path" 2>&1 | head -n 1)
			if [ -n "$value" ]; then
				if echo "$value" | grep -qi "config path not found"; then
					echo "(unset)"
					return 0
				fi
				if [ "$value" = "null" ]; then
					echo "(unset)"
				else
					if echo "$value" | grep -q '^".*"$'; then
						value=$(echo "$value" | sed -e 's/^"//' -e 's/"$//')
					fi
					echo "$value"
				fi
				return 0
			fi
		fi

		[ -f "$config_file" ] || { echo "(unset)"; return 0; }

		if openclaw_has_command jq; then
			local jq_value
			jq_value=$(jq -r --arg p "$path" 'getpath($p|split(".")) // "(unset)"' "$config_file" 2>/dev/null) || jq_value="(unset)"
			[ "$jq_value" = "null" ] && jq_value="(unset)"
			echo "$jq_value"
			return 0
		fi

		if openclaw_has_command python3; then
			python3 - "$config_file" "$path" <<'PY'
import json, sys
path = sys.argv[2]
with open(sys.argv[1], 'r', encoding='utf-8') as f:
    obj = json.load(f)
cur = obj
for part in path.split('.'):
    if isinstance(cur, dict) and part in cur:
        cur = cur[part]
    else:
        print('(unset)')
        raise SystemExit(0)
if isinstance(cur, bool):
    print('true' if cur else 'false')
elif cur is None:
    print('(unset)')
else:
    print(json.dumps(cur, ensure_ascii=False) if isinstance(cur, (dict, list)) else str(cur))
PY
			return 0
		fi

		echo "(unset)"
		return 0
	}

	openclaw_permission_unset_optional() {
		local key="$1"
		local probe
		if ! openclaw_has_command openclaw; then
			return 1
		fi
		if openclaw config unset "$key" >/dev/null 2>&1; then
			return 0
		fi
		probe=$(openclaw config get "$key" 2>&1 | head -n 1)
		if [ -z "$probe" ] || [ "$probe" = "null" ] || [ "$probe" = "(unset)" ] || echo "$probe" | grep -qi "config path not found"; then
			return 0
		fi
		return 1
	}

	openclaw_permission_detect_mode() {
		local config_file
		config_file=$(openclaw_permission_config_file)
		[ ! -f "$config_file" ] && { echo "未知模式"; return; }

		python3 - "$config_file" <<'PY'
import json, sys

def get_v(o, p):
    for k in p.split('.'):
        if isinstance(o, dict) and k in o:
            o = o[k]
        else:
            return "(unset)"
    return str(o).lower()

try:
    with open(sys.argv[1], 'r', encoding='utf-8') as f:
        d = json.load(f)
    p = get_v(d, "tools.profile")
    s = get_v(d, "tools.exec.security")
    a = get_v(d, "tools.exec.ask")
    e = get_v(d, "tools.elevated.enabled")
    b = get_v(d, "commands.bash")
    ap = get_v(d, "tools.exec.applyPatch.enabled")
    w = get_v(d, "tools.exec.applyPatch.workspaceOnly")

    if p == "coding" and s == "allowlist" and a == "on-miss" and e == "false" and b == "false" and ap == "false":
        print("标准安全模式")
    elif p == "coding" and s == "allowlist" and a == "on-miss" and e == "true" and b == "true" and ap == "true" and w == "true":
        print("开发增强模式")
    elif (p == "full" or p == "(unset)") and s == "full" and a == "off" and e == "true" and b == "true" and ap == "true":
        print("完全开放模式")
    else:
        print("自定义模式")
except Exception:
    print("自定义模式")
PY
	}

		openclaw_permission_update_exec_approvals() {
		local sec="$1"
		local ask="$2"
		local fallback="$3"
		local approvals_file="$HOME/.openclaw/exec-approvals.json"

		mkdir -p "$HOME/.openclaw"

		# 生成 JSON 并通过 openclaw approvals set --stdin 写入（优先）
		# 若 CLI 不支持则回退直接写文件
		local json_payload
		json_payload=$(python3 -c '
import json, sys, os
path = sys.argv[1]
try:
    if os.path.exists(path):
        with open(path, "r") as f:
            data = json.load(f)
    else:
        data = {"version": 1, "defaults": {}}
except Exception:
    data = {"version": 1, "defaults": {}}
if "defaults" not in data:
    data["defaults"] = {}
data["defaults"]["security"] = sys.argv[2]
data["defaults"]["ask"] = sys.argv[3]
data["defaults"]["askFallback"] = sys.argv[4]
data["defaults"]["autoAllowSkills"] = True
print(json.dumps(data, indent=2))
' "$approvals_file" "$sec" "$ask" "$fallback")

		if openclaw_has_command openclaw && echo "$json_payload" | openclaw approvals set --stdin >/dev/null 2>&1; then
			return 0
		fi
		# 回退：直接写文件
		echo "$json_payload" > "$approvals_file"
	}

	openclaw_permission_render_status() {
		echo "应用层配置: ~/.openclaw/openclaw.json"
		echo "宿主机审批: ~/.openclaw/exec-approvals.json"
		echo -e "${rw_cheng}---------------------------------------${rw_lv}"
		local current_profile current_sec current_ask current_elevated
		current_profile=$(openclaw config get tools.profile 2>/dev/null | head -n 1 | sed 's/^"//;s/"$//')
		current_sec=$(openclaw config get tools.exec.security 2>/dev/null | head -n 1 | sed 's/^"//;s/"$//')
		current_ask=$(openclaw config get tools.exec.ask 2>/dev/null | head -n 1 | sed 's/^"//;s/"$//')
		current_elevated=$(openclaw config get tools.elevated.enabled 2>/dev/null | head -n 1 | sed 's/^"//;s/"$//')
		# 清理空值
		[ -z "$current_profile" ] || echo "$current_profile" | grep -qi "config path not found" && current_profile=""
		[ -z "$current_sec" ] || echo "$current_sec" | grep -qi "config path not found" && current_sec=""
		[ -z "$current_ask" ] || echo "$current_ask" | grep -qi "config path not found" && current_ask=""
		[ -z "$current_elevated" ] || echo "$current_elevated" | grep -qi "config path not found" && current_elevated=""

		local current_mode="未知 / 自定义"
		if [ "$current_profile" = "full" ] && [ "$current_sec" = "full" ] && [ "$current_ask" = "off" ]; then
			current_mode="\033[1;31m完全开放模式\033[0m"
		elif [ "$current_profile" = "coding" ] && [ "$current_sec" = "allowlist" ] && [ "$current_ask" = "on-miss" ] && [ "$current_elevated" = "true" ]; then
			current_mode="\033[1;33m开发增强模式\033[0m"
		elif [ "$current_profile" = "coding" ] && [ "$current_sec" = "allowlist" ] && [ "$current_ask" = "on-miss" ] && [ "$current_elevated" != "true" ]; then
			current_mode="\033[1;32m标准安全模式\033[0m"
		elif [ -z "$current_profile" ] && [ -z "$current_sec" ]; then
			current_mode="\033[1;36m官方沙盒兜底\033[0m"
		fi
		echo -e "  当前综合安全等级: ${current_mode}"
		echo -e "${rw_cheng}---------------------------------------${rw_lv}"
		echo -e "${rw_huang}[应用层 Tool Policy 状态]${rw_lv}"
		echo "  Profile (预设): ${current_profile:-(unset)}"
		echo "  Exec 限制: ${current_sec:-(unset)}"
		echo "  审批提示: ${current_ask:-(unset)}"
		echo "  提权开关: ${current_elevated:-(unset)}"

		echo -e "\n${rw_huang}[底层 Exec Approvals 状态]${rw_lv}"
		if openclaw_has_command openclaw; then
			local approvals_json
			approvals_json=$(openclaw approvals get --json 2>/dev/null)
			if [ -n "$approvals_json" ]; then
				python3 -c '
import json, sys
try:
    d = json.loads(sys.argv[1])
    defaults = d.get("file", {}).get("defaults", {})
    if not defaults:
        defaults = d.get("defaults", {})
    sec = defaults.get("security", "(unset)")
    ask = defaults.get("ask", "(unset)")
    fb = defaults.get("askFallback", "(unset)")
    auto = defaults.get("autoAllowSkills", False)
    print("  拦截策略 (Security): " + str(sec))
    print("  提示策略 (Ask): " + str(ask))
    print("  无UI兜底 (AskFallback): " + str(fb))
    print("  自动放行技能 (autoAllowSkills): " + ("on" if auto else "off"))
    exists = d.get("exists", True)
    if not exists:
        print("  (审批文件不存在，使用系统内置安全兜底)")
except Exception as e:
    print("  (解析失败: " + str(e) + ")")
' "$approvals_json"
			else
				echo "  (openclaw approvals get --json 无输出)"
			fi
		elif [ -f "$HOME/.openclaw/exec-approvals.json" ]; then
			python3 -c '
import json, os
path = os.path.expanduser("~/.openclaw/exec-approvals.json")
try:
    with open(path) as f:
        d = json.load(f).get("defaults", {})
    print("  拦截策略 (Security): " + str(d.get("security", "(unset)")))
    print("  提示策略 (Ask): " + str(d.get("ask", "(unset)")))
    print("  无UI兜底 (AskFallback): " + str(d.get("askFallback", "(unset)")))
except Exception:
    print("  (配置文件解析失败)")
'
		else
			echo "  (未配置，强制使用系统内置安全兜底策略)"
		fi
	}

	openclaw_permission_apply_standard() {
		send_stats "OpenClaw权限-标准安全模式"
		openclaw_permission_require_openclaw || return 1

		echo "正在配置应用层策略..."
		openclaw config set tools.profile coding >/dev/null 2>&1
		openclaw config set tools.exec.security allowlist >/dev/null 2>&1
		openclaw config set tools.exec.ask on-miss >/dev/null 2>&1
		openclaw config set tools.elevated.enabled false >/dev/null 2>&1
		openclaw config set tools.exec.strictInlineEval true >/dev/null 2>&1  # 拦截危险的内联代码
		openclaw config unset commands.bash >/dev/null 2>&1 # 废弃旧版参数

		echo "正在配置宿主机审批拦截..."
		openclaw_permission_update_exec_approvals "allowlist" "on-miss" "deny"

		openclaw_permission_restart_gateway
		echo -e "${rw_lv}✅ 已切换为标准安全模式 (所有危险命令将通过UI/TG请求你的审批)${rw_lv}"
	}

	openclaw_permission_apply_developer() {
		send_stats "OpenClaw权限-开发增强模式"
		openclaw_permission_require_openclaw || return 1

		echo "正在配置应用层策略..."
		openclaw config set tools.profile coding >/dev/null 2>&1
		openclaw config set tools.exec.security allowlist >/dev/null 2>&1
		openclaw config set tools.exec.ask on-miss >/dev/null 2>&1
		openclaw config set tools.elevated.enabled true >/dev/null 2>&1 # 允许智能体申请提权
		openclaw config set tools.exec.strictInlineEval false >/dev/null 2>&1

		echo "正在配置宿主机审批拦截..."
		openclaw_permission_update_exec_approvals "allowlist" "on-miss" "deny"

		openclaw_permission_restart_gateway
		echo -e "${rw_lv}✅ 已切换为开发增强模式 (允许提权，但常规危险命令依然需要审批)${rw_lv}"
	}

	openclaw_permission_apply_full() {
		send_stats "OpenClaw权限-完全开放模式"
		openclaw_permission_require_openclaw || return 1

		echo "正在配置应用层策略..."
		openclaw config set tools.profile full >/dev/null 2>&1
		openclaw config set tools.exec.security full >/dev/null 2>&1
		openclaw config set tools.exec.ask off >/dev/null 2>&1
		openclaw config set tools.elevated.enabled true >/dev/null 2>&1
		openclaw config set tools.exec.strictInlineEval false >/dev/null 2>&1

		echo "正在瓦解宿主机拦截防御..."
		# 这里的 full 和 off 将彻底绕过底层宿主机的 exec 审批系统
		openclaw_permission_update_exec_approvals "full" "off" "full"

		openclaw_permission_restart_gateway
		echo -e "${rw_lv}✅ 已切换为完全开放模式 (警告：所有宿主机命令拦截已失效，智能体具有最高权限)${rw_lv}"
	}

	openclaw_permission_restore_official_defaults() {
		send_stats "OpenClaw权限-恢复官方默认"
		openclaw_permission_require_openclaw || return 1

		echo "清理应用层强制覆盖..."
		openclaw config unset tools.profile >/dev/null 2>&1
		openclaw config unset tools.exec.security >/dev/null 2>&1
		openclaw config unset tools.exec.ask >/dev/null 2>&1
		openclaw config unset tools.elevated.enabled >/dev/null 2>&1
		openclaw config unset tools.exec.strictInlineEval >/dev/null 2>&1

		echo "清理宿主机拦截配置..."
		# 优先通过 CLI 清空审批配置，回退直接删文件
		if echo '{"version":1,"defaults":{}}' | openclaw approvals set --stdin >/dev/null 2>&1; then
			true
		else
			rm -f "$HOME/.openclaw/exec-approvals.json"
		fi

		openclaw_permission_restart_gateway
		echo -e "${rw_lv}✅ 已恢复到 OpenClaw 官方安全沙盒防御机制${rw_lv}"
	}

	openclaw_permission_run_audit() {
		echo -e "${rw_cheng}=======================================${rw_lv}"
		echo "运行 OpenClaw 官方安全审计与体检..."
		echo -e "${rw_cheng}=======================================${rw_lv}"
		openclaw security audit
		echo -e "${rw_cheng}---------------------------------------${rw_lv}"
		read -e -p "是否尝试自动修复发现的安全隐患？(y/n): " fix_choice
		if [[ "$fix_choice" == "y" || "$fix_choice" == "Y" || "$fix_choice" == "yes" ]]; then
			openclaw security audit --fix
			echo -e "${rw_lv}✅ 自动修复完成。${rw_lv}"
		fi
		echo "按任意键返回..."
		read -n 1 -s
	}


	openclaw_permission_manage_allowlist() {
		while true; do
			clear
			echo -e "${rw_cheng}=======================================${rw_lv}"
			echo " Exec 命令白名单管理"
			echo -e "${rw_cheng}=======================================${rw_lv}"
			echo "当前白名单："
			local allowlist_json
			allowlist_json=$(openclaw approvals get --json 2>/dev/null)
			if [ -n "$allowlist_json" ]; then
				python3 -c '
import json, sys
try:
    d = json.loads(sys.argv[1])
    f = d.get("file", {})
    agents = f.get("agents", {})
    found = False
    for agent_id, agent_data in agents.items():
        al = agent_data.get("allowlist", [])
        if al:
            found = True
            print("  智能体 [%s]:" % agent_id)
            for item in al:
                print("    - %s" % item)
    if not found:
        print("  (空，未配置任何白名单规则)")
except Exception as e:
    print("  (解析失败: " + str(e) + ")")
' "$allowlist_json"
			else
				echo "  (无法获取)"
			fi
			echo -e "${rw_cheng}---------------------------------------${rw_lv}"
			echo "1. 添加白名单规则"
			echo "2. 移除白名单规则"
			echo "0. 返回"
			echo -e "${rw_cheng}---------------------------------------${rw_lv}"
			read -e -p "请选择: " al_choice
			case "$al_choice" in
				1)
					read -e -p "输入要放行的命令路径 (支持 glob，如 /usr/bin/git): " pattern
					[ -z "$pattern" ] && { echo "不能为空"; break_end; continue; }
					read -e -p "指定智能体ID (留空=所有智能体 *): " agent_id
					agent_id="${agent_id:-*}"
					openclaw approvals allowlist add --agent "$agent_id" "$pattern"
					break_end
					;;
				2)
					read -e -p "输入要移除的命令路径: " pattern
					[ -z "$pattern" ] && { echo "不能为空"; break_end; continue; }
					openclaw approvals allowlist remove "$pattern"
					break_end
					;;
				0) return 0 ;;
				*) echo "无效选择"; sleep 1 ;;
			esac
		done
	}

	openclaw_permission_menu() {
		send_stats "OpenClaw权限管理"
		while true; do
			clear
			echo -e "${rw_cheng}=======================================${rw_lv}"
			echo " OpenClaw 权限管理 (双层架构深度适配)"
			echo -e "${rw_cheng}=======================================${rw_lv}"
			openclaw_permission_render_status
			echo -e "${rw_cheng}---------------------------------------${rw_lv}"
			echo -e "${rw_huang}1.   ${rw_lv}${rw_lv} 切换为标准安全模式（日常推荐，弹卡片审批）${rw_lv}"
			echo -e "${rw_huang}2.   ${rw_lv}${rw_lv} 切换为开发增强模式（允许智能体申请提权）${rw_lv}"
			echo -e "${rw_huang}3.   ${rw_lv}${rw_lv} 切换为完全开放模式（${rw_lv}${rw_hong}高风险！彻底解除所有宿主机拦截${rw_lv}）"
			echo -e "${rw_huang}4.   ${rw_lv}${rw_lv} 恢复官方默认沙盒防御策略${rw_lv}"
			echo -e "${rw_huang}5.   ${rw_lv}${rw_lv} 运行底层安全审计与自动修复${rw_lv}"
			echo -e "${rw_huang}6.   ${rw_lv}${rw_lv} 管理 Exec 命令白名单${rw_lv}"
			echo -e "${rw_huang}0.   ${rw_lv}${rw_lv} 返回上一级${rw_lv}"
			echo -e "${rw_cheng}---------------------------------------${rw_lv}"
			read -e -p "请输入你的选择: " perm_choice
			case "$perm_choice" in
				1)
					echo "准备应用：标准安全模式"
					read -e -p "输入 yes 确认: " confirm
					if [ "$confirm" = "yes" ]; then openclaw_permission_apply_standard; else echo "已取消"; fi
					break_cancel
					;;
				2)
					echo "准备应用：开发增强模式"
					read -e -p "输入 yes 确认: " confirm
					if [ "$confirm" = "yes" ]; then openclaw_permission_apply_developer; else echo "已取消"; fi
					break_cancel
					;;
				3)
					echo -e "${rw_hong}⚠️ 完全开放模式会彻底瓦解 exec 审批并自动放行高危代码。${rw_lv}"
					read -e -p "输入 FULL 确认继续: " confirm
					if [ "$confirm" = "FULL" ]; then openclaw_permission_apply_full; else echo "已取消"; fi
					break_cancel
					;;
				4)
					echo "将清除所有定制覆盖，恢复 OpenClaw 刚安装时的严格沙盒状态。"
					read -e -p "输入 yes 确认: " confirm
					if [ "$confirm" = "yes" ]; then openclaw_permission_restore_official_defaults; else echo "已取消"; fi
					break_cancel
					;;
				5)
					openclaw_permission_run_audit
					;;
				6)
					openclaw_permission_manage_allowlist
					;;
				0)
					return 0
					;;
				*)
					echo "无效的选择，请重试。"
					sleep 1
					;;
			esac
		done
	}

	openclaw_multiagent_config_file() {
		local config_file
		config_file=$(openclaw_permission_config_file)
		if [ -s "$config_file" ]; then
			echo "$config_file"
			return 0
		fi
		openclaw config file 2>/dev/null | tail -n 1
	}

	openclaw_multiagent_default_agent() {
		local config_file
		config_file=$(openclaw_permission_config_file)
		if [ -s "$config_file" ]; then
			python3 - "$config_file" <<'PY'
import json,sys,os
path=sys.argv[1]
value="(unset)"
try:
    with open(path) as f:
        data=json.load(f)
    defaults=data.get("agents",{}).get("defaults",{}) if isinstance(data,dict) else {}
    value=defaults.get("agent") or None
    if not value:
        for item in data.get("agents",{}).get("list",[]) or []:
            if isinstance(item,dict) and (item.get("isDefault") or item.get("default")):
                value=item.get("id")
                break
    if not value:
        for item in data.get("agents",{}).get("list",[]) or []:
            if isinstance(item,dict) and item.get("id"):
                value=item.get("id")
                break
except Exception:
    value="(unset)"
print(value or "(unset)")
PY
			return 0
		fi
		local value
		value=$(openclaw config get agents.defaults.agent 2>&1 | head -n 1)
		if [ -z "$value" ] || echo "$value" | grep -qi "config path not found"; then
			value=$(openclaw agents list --json 2>/dev/null | python3 -c 'import json,sys
try:
 data=json.load(sys.stdin)
 print(next((x.get("id","(unset)") for x in data if x.get("isDefault")), "(unset)"))
except Exception:
 print("(unset)")' 2>/dev/null)
		fi
		[ -z "$value" ] && value="(unset)"
		if echo "$value" | grep -q '^".*"$'; then
			value=$(echo "$value" | sed -e 's/^"//' -e 's/"$//')
		fi
		echo "$value"
	}

	openclaw_multiagent_require_openclaw() {
		if ! openclaw_has_command openclaw; then
			echo "❌ 未检测到 openclaw 命令，请先安装或初始化 OpenClaw。"
			return 1
		fi
		return 0
	}

	openclaw_multiagent_agents_json() {
		local result
		if openclaw_has_command openclaw; then
			result=$(openclaw agents list --json 2>/dev/null)
			if [ -n "$result" ] && python3 -c "import json,sys; json.loads(sys.argv[1])" "$result" 2>/dev/null; then
				echo "$result"
				return 0
			fi
		fi
		# 回退：从配置文件读取
		local config_file
		config_file=$(openclaw_permission_config_file)
		if [ -s "$config_file" ]; then
			python3 - "$config_file" <<'PY'
import json,sys,os
path=sys.argv[1]
try:
    with open(path) as f:
        data=json.load(f)
    agents=data.get("agents",{}).get("list",[])
    if not isinstance(agents,list):
        agents=[]
    print(json.dumps(agents, ensure_ascii=False))
except Exception:
    print("[]")
PY
			return 0
		fi
		echo '[]'
	}

	openclaw_multiagent_bindings_json() {
		local result
		if openclaw_has_command openclaw; then
			result=$(openclaw agents bindings --json 2>/dev/null)
			if [ -n "$result" ] && python3 -c "import json,sys; json.loads(sys.argv[1])" "$result" 2>/dev/null; then
				echo "$result"
				return 0
			fi
		fi
		# 回退：从配置文件读取
		local config_file
		config_file=$(openclaw_permission_config_file)
		if [ -s "$config_file" ]; then
			python3 - "$config_file" <<'PY'
import json,sys
path=sys.argv[1]
try:
    with open(path) as f:
        data=json.load(f)
    bindings=data.get("agents",{}).get("bindings",[])
    if not isinstance(bindings,list):
        bindings=[]
    results=[]
    for item in bindings:
        if not isinstance(item,dict):
            continue
        results.append({"agentId": item.get("agentId") or item.get("agent") or "?", "description": item.get("description") or "-"})
    print(json.dumps(results, ensure_ascii=False))
except Exception:
    print("[]")
PY
			return 0
		fi
		echo '[]'
	}

	openclaw_multiagent_sessions_json() {
		local result
		if openclaw_has_command openclaw; then
			result=$(openclaw sessions --json 2>/dev/null | grep -v '^\[')
			if [ -n "$result" ] && python3 -c "import json,sys; json.loads(sys.argv[1])" "$result" 2>/dev/null; then
				echo "$result"
				return 0
			fi
		fi
		# 回退：从文件系统读取
		python3 <<'PY'
import json,os
base=os.path.expanduser("~/.openclaw/agents")
sessions=[]
try:
    agent_dirs=[d for d in os.listdir(base) if os.path.isdir(os.path.join(base,d))]
except Exception:
    agent_dirs=[]
for agent_id in agent_dirs:
    path=os.path.join(base,agent_id,"sessions","sessions.json")
    if not os.path.exists(path):
        continue
    try:
        with open(path) as f:
            data=json.load(f)
    except Exception:
        continue
    if isinstance(data,dict):
        items=data.items()
    elif isinstance(data,list):
        items=[(item.get("key") or "?", item) for item in data if isinstance(item,dict)]
    else:
        continue
    for key,item in items:
        if not isinstance(item,dict):
            continue
        model=item.get("model") or "-"
        sessions.append({"agentId": agent_id, "key": key, "model": model})
print(json.dumps({"path":"(filesystem)","count":len(sessions),"sessions":sessions}, ensure_ascii=False))
PY
	}

	openclaw_multiagent_render_status() {
		local config_file default_agent
		config_file=$(openclaw_multiagent_config_file)
		default_agent=$(openclaw_multiagent_default_agent)
		echo "配置文件: ${config_file:-$(openclaw_permission_config_file)}"
		echo "默认智能体: $default_agent"
		python3 -c '
import json,sys
agents=json.loads(sys.argv[1] or "[]")
bindings=json.loads(sys.argv[2] or "[]")
sess_obj=json.loads(sys.argv[3] or "{}")
sessions=sess_obj.get("sessions",[]) if isinstance(sess_obj,dict) else []
print("已配置智能体数: %s" % len(agents))
print("路由绑定数: %s" % len(bindings))
print("会话总数: %s" % len(sessions))
print("---------------------------------------")
if not agents:
    print("当前未配置任何多智能体。")
else:
    for item in agents[:8]:
        aid = item.get("id","?")
        identity = item.get("identityName") or item.get("name") or "-"
        emoji = item.get("identityEmoji") or ""
        ws = item.get("workspace") or "-"
        model = item.get("model") or "-"
        is_default = item.get("isDefault", False)
        bcount = item.get("bindings", 0)
        default_tag = " [默认]" if is_default else ""
        print("- 智能体ID: \033[1;36m%s\033[0m%s" % (aid, default_tag))
        print("  身份名称: %s %s" % (identity, emoji))
        print("  模型: %s" % model)
        print("  工作目录: %s" % ws)
        print("  绑定数: %s" % bcount)
' "$(openclaw_multiagent_agents_json)" "$(openclaw_multiagent_bindings_json)" "$(openclaw_multiagent_sessions_json)"
	}

	openclaw_multiagent_list_agents() {
		send_stats "OpenClaw多智能体-列出Agent"
		python3 -c 'import json,sys; agents=json.loads(sys.argv[1] or "[]");
if not agents: print("暂无已配置 Agent。"); raise SystemExit(0)
for idx,item in enumerate(agents,1):
 print("%s. %s" % (idx, item.get("id","?"))); print("   workspace : %s" % item.get("workspace","-")); ident=(item.get("identityName") or "-") + ((" " + item.get("identityEmoji")) if item.get("identityEmoji") else ""); print("   identity  : %s" % ident.strip()); print("   model     : %s" % (item.get("model") or "-")); print("   bindings  : %s" % item.get("bindings",0)); print("   default   : %s" % ("yes" if item.get("isDefault") else "no"))' "$(openclaw_multiagent_agents_json)"
	}

	openclaw_multiagent_add_agent() {
		send_stats "OpenClaw多智能体-新增Agent"
		openclaw_multiagent_require_openclaw || return 1
		local agent_id workspace confirm
		read -e -p "请输入新的 Agent ID: " agent_id
		[ -z "$agent_id" ] && echo "已取消：Agent ID 不能为空。" && return 1
		read -e -p "请输入 workspace 路径（默认 ~/.openclaw/workspace-${agent_id}）: " workspace
		[ -z "$workspace" ] && workspace="~/.openclaw/workspace-${agent_id}"
		echo "将创建智能体: $agent_id"
		echo "工作目录: $workspace"
		read -e -p "输入 yes 确认继续: " confirm
		[ "$confirm" = "yes" ] || { echo "已取消"; return 1; }
		if openclaw agents add "$agent_id" --workspace "$workspace"; then
			echo "✅ 智能体创建成功: $agent_id"
			local name theme
			read -e -p "请输入智能体身份名称 (如: 代码专家): " name
			[ -z "$name" ] && name="$agent_id"
			read -e -p "请输入智能体性格主题 (如: 严谨、高效): " theme
			[ -z "$theme" ] && theme="助手"
			echo "正在配置智能体身份..."
			openclaw agents set-identity --agent "$agent_id" --name "$name" --theme "$theme"
		else
			echo "❌ 智能体创建失败"
			return 1
		fi
	}

	openclaw_multiagent_delete_agent() {
		send_stats "OpenClaw多智能体-删除Agent"
		openclaw_multiagent_require_openclaw || return 1
		local agent_id confirm
		read -e -p "请输入要删除的 Agent ID: " agent_id
		[ -z "$agent_id" ] && echo "已取消：Agent ID 不能为空。" && return 1
		echo "⚠️ 删除智能体可能影响其工作目录、路由绑定与会话路由。"
		read -e -p "输入 DELETE 确认删除 ${agent_id}: " confirm
		[ "$confirm" = "DELETE" ] || { echo "已取消"; return 1; }
		if openclaw agents delete "$agent_id"; then
			echo "✅ 智能体删除成功: $agent_id"
		else
			echo "❌ 智能体删除失败"
			return 1
		fi
	}

	openclaw_multiagent_list_bindings() {
		send_stats "OpenClaw多智能体-查看路由绑定"
		python3 -c '
import json,sys
bindings=json.loads(sys.argv[1] or "[]")
if not bindings:
    print("暂无路由绑定。")
    raise SystemExit(0)
for idx,item in enumerate(bindings,1):
    desc = item.get("description") or "-"
    print("%s. agent=%s | %s" % (idx, item.get("agentId","?"), desc))
' "$(openclaw_multiagent_bindings_json)"
	}

	openclaw_multiagent_add_binding() {
		send_stats "OpenClaw多智能体-新增路由绑定"
		openclaw_multiagent_require_openclaw || return 1
		local agent_id bind_value confirm
		read -e -p "请输入智能体 ID: " agent_id
		read -e -p "请输入路由绑定值（如 telegram:ops / discord:guild-a）: " bind_value
		{ [ -z "$agent_id" ] || [ -z "$bind_value" ]; } && echo "已取消：参数不能为空。" && return 1
		echo "将绑定智能体 [$agent_id] -> [$bind_value]"
		read -e -p "输入 yes 确认继续: " confirm
		[ "$confirm" = "yes" ] || { echo "已取消"; return 1; }
		if openclaw agents bind --agent "$agent_id" --bind "$bind_value"; then
			echo "✅ 路由绑定添加成功"
		else
			echo "❌ 路由绑定添加失败"
			return 1
		fi
	}

	openclaw_multiagent_remove_binding() {
		send_stats "OpenClaw多智能体-移除路由绑定"
		openclaw_multiagent_require_openclaw || return 1
		local agent_id bind_value confirm
		read -e -p "请输入智能体 ID: " agent_id
		read -e -p "请输入要移除的路由绑定值: " bind_value
		{ [ -z "$agent_id" ] || [ -z "$bind_value" ]; } && echo "已取消：参数不能为空。" && return 1
		echo "将移除智能体 [$agent_id] 的路由绑定 [$bind_value]"
		read -e -p "输入 yes 确认继续: " confirm
		[ "$confirm" = "yes" ] || { echo "已取消"; return 1; }
		if openclaw agents unbind --agent "$agent_id" --bind "$bind_value"; then
			echo "✅ 路由绑定移除成功"
		else
			echo "❌ 路由绑定移除失败"
			return 1
		fi
	}


	openclaw_multiagent_show_sessions() {
		send_stats "OpenClaw多智能体-会话概况"
		python3 -c '
import json,sys
sess_obj=json.loads(sys.argv[1] or "{}")
sessions=sess_obj.get("sessions",[]) if isinstance(sess_obj,dict) else []
if not sessions:
    print("暂无 session 数据。")
    raise SystemExit(0)
by_agent={}
for item in sessions:
    aid = item.get("agentId","?")
    by_agent[aid] = by_agent.get(aid, 0) + 1
print("会话汇总:")
for agent_id,count in sorted(by_agent.items()):
    print("- %s: %s" % (agent_id, count))
print("---------------------------------------")
for item in sessions[:10]:
    key = item.get("key","-")
    model = item.get("model") or "-"
    aid = item.get("agentId","?")
    tokens = ""
    it = item.get("inputTokens")
    ot = item.get("outputTokens")
    if it is not None:
        tokens = " | in=%s out=%s" % (it, ot or 0)
    print("%s | %s | %s%s" % (aid, key, model, tokens))
' "$(openclaw_multiagent_sessions_json)"
	}

	openclaw_multiagent_health_check() {
		send_stats "OpenClaw多智能体-健康检查"
		openclaw_multiagent_require_openclaw || return 1
		local config_file
		config_file=$(openclaw_multiagent_config_file)
		echo "检查配置文件: ${config_file:-$(openclaw_permission_config_file)}"
		openclaw config validate || echo "⚠️ 配置校验未通过，请检查上方输出。"
		python3 -c '
import json,sys,os
agents=json.loads(sys.argv[1] or "[]")
bindings=json.loads(sys.argv[2] or "[]")
print("---------------------------------------")
if not agents:
    print("⚠️ 未发现已配置智能体。")
else:
    for item in agents:
        ws = item.get("workspace") or ""
        aid = item.get("id","?")
        if ws and os.path.isdir(os.path.expanduser(ws)):
            state = "OK"
        elif aid == "main":
            state = "OK"
        else:
            state = "MISSING"
        model = item.get("model") or "-"
        bcount = item.get("bindings", 0)
        print("agent=%s workspace=%s model=%s bindings=%s [%s]" % (aid, ws or "-", model, bcount, state))
print("路由绑定数=%s" % len(bindings))
print("✅ 多智能体健康检查完成")
' "$(openclaw_multiagent_agents_json)" "$(openclaw_multiagent_bindings_json)"
		echo ""
		echo "运行安全审计..."
		openclaw security audit 2>/dev/null || echo "⚠️ 安全审计命令不可用"
	}


	openclaw_multiagent_set_identity() {
		openclaw_multiagent_require_openclaw || return 1
		openclaw_multiagent_list_agents
		read -e -p "输入要修改身份的智能体ID: " agent_id
		[ -z "$agent_id" ] && { echo "ID 不能为空"; return 1; }
		echo "修改选项（留空跳过）："
		read -e -p "  新名称: " new_name
		read -e -p "  新 Emoji: " new_emoji
		local cmd="openclaw agents set-identity --agent $agent_id"
		[ -n "$new_name" ] && cmd="$cmd --name $new_name"
		[ -n "$new_emoji" ] && cmd="$cmd --emoji $new_emoji"
		echo "也可以从 IDENTITY.md 自动读取身份信息。"
		read -e -p "是否从 IDENTITY.md 读取？(y/n): " from_id
		if [ "$from_id" = "y" ]; then
			cmd="openclaw agents set-identity --agent $agent_id --from-identity"
		fi
		eval "$cmd"
	}

	openclaw_multiagent_cleanup_sessions() {
		openclaw_multiagent_require_openclaw || return 1
		echo "即将清理过期/冗余会话数据..."
		read -e -p "输入 yes 确认: " confirm
		[ "$confirm" != "yes" ] && { echo "已取消"; return 0; }
		openclaw sessions cleanup
	}

	openclaw_multiagent_menu() {
		send_stats "OpenClaw多智能体管理"
		while true; do
			clear
			echo -e "${rw_cheng}=======================================${rw_lv}"
			echo "OpenClaw 多智能体管理"
			echo -e "${rw_cheng}=======================================${rw_lv}"
			openclaw_multiagent_render_status
			echo -e "${rw_cheng}---------------------------------------${rw_lv}"
			echo "1. 新增智能体"
			echo "2. 删除智能体"
			echo "3. 查看路由绑定"
			echo "4. 新增路由绑定"
			echo "5. 移除路由绑定"
			echo "6. 查看会话概况"
			echo "7. 运行多智能体健康检查"
			echo "8. 修改智能体身份（名称/Emoji）"
			echo "9. 清理过期会话"
			echo "0. 返回上一级"
			echo -e "${rw_cheng}---------------------------------------${rw_lv}"
			read -e -p "请输入你的选择: " multi_choice
			case "$multi_choice" in
				1) openclaw_multiagent_add_agent; break_end ;;
				2) openclaw_multiagent_delete_agent; break_end ;;
				3) openclaw_multiagent_list_bindings; break_end ;;
				4) openclaw_multiagent_add_binding; break_end ;;
				5) openclaw_multiagent_remove_binding; break_end ;;
				6) openclaw_multiagent_show_sessions; break_end ;;
				7) openclaw_multiagent_health_check; break_end ;;
				8) openclaw_multiagent_set_identity; break_end ;;
				9) openclaw_multiagent_cleanup_sessions; break_end ;;
				0) return 0 ;;
				*) echo "无效的选择，请重试。"; sleep 1 ;;
			esac
		done
	}


openclaw_backup_restore_menu() {

		send_stats "OpenClaw备份与还原"
		while true; do
			clear
			echo -e "${rw_cheng}=======================================${rw_lv}"
			echo "OpenClaw 备份与还原"
			echo -e "${rw_cheng}=======================================${rw_lv}"
			openclaw_backup_render_file_list
			echo -e "${rw_cheng}---------------------------------------${rw_lv}"
			echo "1. 备份记忆全量"
			echo "2. 还原记忆全量"
			echo "3. 备份 OpenClaw 项目（默认安全模式）"
			echo "4. 还原 OpenClaw 项目（高级/高风险）"
			echo "5. 删除备份文件"
			echo "0. 返回上一级"
			echo -e "${rw_cheng}---------------------------------------${rw_lv}"
			read -e -p "请输入你的选择: " backup_choice

			case "$backup_choice" in
				1) openclaw_memory_backup_export ;;
				2) openclaw_memory_backup_import ;;
				3) openclaw_project_backup_export ;;
				4) openclaw_project_backup_import ;;
				5) openclaw_backup_delete_file ;;
				0) return 0 ;;
				*)
					echo "无效的选择，请重试。"
					sleep 1
					;;
			esac
		done
	}


	update_moltbot() {
		echo "更新 OpenClaw..."
		send_stats "更新 OpenClaw..."
		install_node_and_tools
		git config --global url."${gh_proxy}github.com/".insteadOf ssh://git@github.com/
		git config --global url."${gh_proxy}github.com/".insteadOf git@github.com:
		npm install -g openclaw@latest
		crontab -l 2>/dev/null | grep -v "s gateway" | crontab -
		start_gateway
		hash -r
		add_app_id
		echo "更新完成"
		break_end
	}


	uninstall_moltbot() {
		echo "卸载 OpenClaw..."
		send_stats "卸载 OpenClaw..."
		openclaw uninstall
		npm uninstall -g openclaw
		crontab -l 2>/dev/null | grep -v "s gateway" | crontab -
		rm -rf "$HOME/.openclaw"
		[ "$HOME" != "/root" ] && [ -d /root/.openclaw ] && echo "⚠️ 检测到 root 目录下仍存在 /root/.openclaw，如需清理请手动处理"
		hash -r
		sed -i "/\b${app_id}\b/d" /home/docker/appno.txt
		echo "卸载完成"
		break_end
	}

	nano_openclaw_json() {
		send_stats "编辑 OpenClaw 配置文件"
		install nano
		nano "$(openclaw_get_config_file)"
		start_gateway
	}






	openclaw_find_webui_domain() {
		local conf domain_list

		domain_list=$(
			grep -R "18789" /home/web/conf.d/*.conf 2>/dev/null \
			| awk -F: '{print $1}' \
			| sort -u \
			| while read conf; do
				basename "$conf" .conf
			done
		)

		if [ -n "$domain_list" ]; then
			echo "$domain_list"
		fi
	}



	openclaw_show_webui_addr() {
		local local_ip token domains

		echo -e "${rw_cheng}==================================${rw_lv}"
		echo "OpenClaw WebUI 访问地址"
		local_ip="127.0.0.1"

		token=$(
			openclaw dashboard 2>/dev/null \
			| sed -n 's/.*:18789\/#token=\([a-f0-9]\+\).*/\1/p' \
			| head -n 1
		)
		echo
		echo "本机地址："
		echo "http://${local_ip}:18789/#token=${token}"

		domains=$(openclaw_find_webui_domain)
		if [ -n "$domains" ]; then
			echo "域名地址："
			echo "$domains" | while read d; do
				echo "https://${d}/#token=${token}"
			done
		fi

		echo -e "${rw_cheng}==================================${rw_lv}"
	}



	# 添加域名（调用你给的函数）
	openclaw_domain_webui() {
		add_yuming
		ldnmp_Proxy ${yuming} 127.0.0.1 18789

		token=$(
			openclaw dashboard 2>/dev/null \
			| sed -n 's/.*:18789\/#token=\([a-f0-9]\+\).*/\1/p' \
			| head -n 1
		)

		clear
		echo "访问地址:"
		echo "https://${yuming}/#token=$token"
		echo "先访问URL触发设备ID，然后回车下一步进行配对。"
		read
		echo -e "${rw_huang}正在加载设备列表……${rw_lv}"
		# 自动添加域名到 allowedOrigins
		config_file=$(openclaw_get_config_file)
		if [ -f "$config_file" ]; then
			new_origin="https://${yuming}"
			# 使用 jq 安全修改 JSON，确保结构存在且不重复添加域名
			if command -v jq >/dev/null 2>&1; then
				tmp_json=$(mktemp)
				jq 'if .gateway.controlUi == null then .gateway.controlUi = {"allowedOrigins": ["http://127.0.0.1"]} else . end | if (.gateway.controlUi.allowedOrigins | contains([$origin]) | not) then .gateway.controlUi.allowedOrigins += [$origin] else . end' --arg origin "$new_origin" "$config_file" > "$tmp_json" && mv "$tmp_json" "$config_file"
				echo -e "${rw_huang}已将域名 ${yuming} 加入 allowedOrigins 配置${rw_lv}"
				openclaw gateway restart >/dev/null 2>&1
			fi
		fi

		openclaw devices list

		read -e -p "请输入 Request_Key: " Request_Key

		[ -z "$Request_Key" ] && {
			echo "Request_Key 不能为空"
			return 1
		}

		openclaw devices approve "$Request_Key"

	}

	# 删除域名
	openclaw_remove_domain() {
		echo "域名格式 example.com 不带https://"
		web_del
	}

	# 主菜单
	openclaw_webui_menu() {

		send_stats "WebUI访问与设置"
		while true; do
			clear
			openclaw_show_webui_addr
			echo
			echo "1. 添加域名访问"
			echo "2. 删除域名访问"
			echo "0. 退出"
			echo
			read -e -p "请选择: " choice

			case "$choice" in
				1)
					openclaw_domain_webui
					echo
					read -p "按回车返回菜单..."
					;;
				2)
					openclaw_remove_domain
					read -p "按回车返回菜单..."
					;;
				0)
					break
					;;
				*)
					echo "无效选项"
					sleep 1
					;;
			esac
		done
	}



	# 主循环
	while true; do
		show_menu
		read choice
		case $choice in
			1) install_moltbot ;;
			2) start_bot ;;
			3) stop_bot ;;
			4) view_logs ;;
			5) change_model ;;
			6) openclaw_api_manage_menu ;;
			7) change_tg_bot_code ;;
			8) install_plugin ;;
			9) install_skill ;;
			10) nano_openclaw_json ;;
			11) send_stats "初始化配置向导"
				openclaw onboard --install-daemon
				break_end
				;;
			12) send_stats "健康检测与修复"
				openclaw doctor --fix
				break_end
				;;
			13) openclaw_webui_menu ;;
			14) send_stats "TUI命令行对话"
				openclaw tui
				break_end
			 	;;
			15) openclaw_memory_menu ;;
			16) openclaw_permission_menu ;;
			17) openclaw_multiagent_menu ;;
			18) openclaw_backup_restore_menu ;;
			19) update_moltbot ;;
			20) uninstall_moltbot ;;
			*) break ;;
		esac
	done

}






# ═══════════════════════════════════════════════════════════════
# 函数: install_3xui
# 功能: 3X-UI 多协议代理面板一键安装
#       直接调用官方脚本，不重新发明轮子
# 官方脚本: https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh
# 依赖: curl、bash、systemd
# ═══════════════════════════════════════════════════════════════
install_3xui() {

	# ── 面板信息展示 ──
	echo ""
	echo -e "${rw_cheng}━━━━━━ 3X-UI 多协议代理面板 ━━━━━━${rw_lv}"
	echo ""
	echo -e " ${rw_lv}3X-UI 是基于 Xray Core 的开源多协议代理 Web 面板${rw_lv}"
	echo -e " ${rw_lv}特性: VMess / VLESS / Trojan / Shadowsocks / WireGuard 多协议支持${rw_lv}"
	echo -e " ${rw_lv}       多用户管理 / 流量限制 / 到期时间 / IP 数量限制 / Reality 支持${rw_lv}"
	echo -e " ${rw_lv}       多语言界面 / SSL 证书管理 / 流量统计 / 订阅管理${rw_lv}"
	echo -e " ${rw_lv}依赖: 系统服务（systemd），无需 Docker${rw_lv}"
	echo -e " ${rw_lv}官方: ${rw_huang}https://github.com/MHSanaei/3x-ui${rw_lv}"
	echo -e " ${rw_lv}文档: ${rw_huang}https://docs.sanaei.dev${rw_lv}"
	echo ""

	# ── 确认是否开始安装 ──
	read -e -p " 确认开始安装 3X-UI？(y/N): " _confirm < /dev/tty
	if [[ ! "$_confirm" =~ ^[Yy]$ ]]; then
		yellow "已取消"
		return 0
	fi

	# ── 系统架构检查 ──
	local _arch
	_arch=$(uname -m 2>/dev/null || echo "")
	local _arch_ok=false
	case "$_arch" in
		x86_64|amd64|x64) _arch_ok=true ;;
		aarch64|arm64|armv8*) _arch_ok=true ;;
		armv7*) _arch_ok=true ;;
		armv6*) _arch_ok=true ;;
		armv5*) _arch_ok=true ;;
		i*86|x86) _arch_ok=true ;;
		s390x) _arch_ok=true ;;
		*)
			red "不支持的系统架构: ${_arch:-未知}"
			echo -e " ${rw_huang}3X-UI 支持 amd64 / 386 / arm64 / armv7 / armv6 / armv5 / s390x 架构${rw_lv}"
			return 1
			;;
	esac

	# ── 检查是否已安装（x-ui 命令或 systemd 服务） ──
	if command -v x-ui &>/dev/null || systemctl is-active --quiet x-ui 2>/dev/null; then
		green "检测到 3X-UI 已安装"
		echo -e " ${rw_huang}管理命令: x-ui${rw_lv}"
		echo -e " ${rw_huang}查看状态: x-ui status${rw_lv}"
		echo -e " ${rw_huang}查看设置: x-ui settings${rw_lv}"
		echo -e " ${rw_huang}启动面板: x-ui start${rw_lv}"
		echo ""
		read -e -p " 是否重新安装/升级到最新版？(y/N): " _reinstall < /dev/tty
		if [[ ! "$_reinstall" =~ ^[Yy]$ ]]; then
			yellow "已取消"
			return 0
		fi
	fi

	# ── 确保依赖可用（curl） ──
	if ! command -v curl &>/dev/null; then
		yellow "未检测到 curl，正在安装..."
		install curl
	fi

	# ── 官方脚本地址 ──
	local _script_url="https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh"

	# ── 执行官方安装脚本（联网拉取最新版，交互式） ──
	echo ""
	echo -e " ${rw_huang}正在调用官方脚本安装 3X-UI...${rw_lv}"
	echo -e " ${rw_lv}命令: bash <(curl -Ls ${_script_url})${rw_lv}"
	echo -e " ${rw_cheng}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${rw_lv}"
	echo ""

	bash <(curl -Ls "$_script_url")
	local _install_rc=$?

	# ── 安装结果提示 ──
	echo ""
	echo -e "${rw_cheng}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${rw_lv}"
	if [ $_install_rc -eq 0 ]; then
		green "3X-UI 安装流程结束"
		echo ""
		echo -e " ${rw_huang}常用管理命令:${rw_lv}"
		echo -e "   ${rw_lv}x-ui${rw_lv}                — 打开管理菜单（交互式）"
		echo -e "   ${rw_lv}x-ui status${rw_lv}         — 查看服务状态"
		echo -e "   ${rw_lv}x-ui start${rw_lv}          — 启动 3X-UI 服务"
		echo -e "   ${rw_lv}x-ui stop${rw_lv}           — 停止 3X-UI 服务"
		echo -e "   ${rw_lv}x-ui restart${rw_lv}        — 重启 3X-UI 服务"
		echo -e "   ${rw_lv}x-ui settings${rw_lv}       — 查看面板设置（端口/路径/账号）"
		echo -e "   ${rw_lv}x-ui update${rw_lv}         — 升级到最新版"
		echo -e "   ${rw_lv}x-ui uninstall${rw_lv}      — 卸载 3X-UI"
		echo ""
		echo -e " ${rw_huang}官方文档: ${rw_lv}https://docs.sanaei.dev${rw_lv}"
		echo -e " ${rw_huang}如忘记登录信息，执行: ${rw_lv}x-ui settings${rw_lv}"
	else
		red "3X-UI 安装过程返回非零状态码 (退出码: $_install_rc)"
		echo -e " ${rw_huang}请检查上方日志中的错误信息${rw_lv}"
		echo -e " ${rw_huang}常见原因:${rw_lv}"
		echo -e "   - 网络不通或 raw.githubusercontent.com 不可达（国内服务器常见）"
		echo -e "   - 系统架构不匹配或 systemd 不可用"
		echo -e "   - 端口被占用或防火墙拦截"
		echo -e " ${rw_huang}参考文档: ${rw_lv}https://docs.sanaei.dev${rw_lv}"
	fi
}


# ═══════════════════════════════════════════════════════════════
# 函数: install_xray_lite
# 功能: xray 迷你版（xray-cf-lite）一键安装
#       直接调用作者官方脚本，不重新发明轮子
# 官方脚本: https://raw.githubusercontent.com/byJoey/xray-cf-lite/main/xray_cf_lite.sh
# 依赖: curl、bash
# ═══════════════════════════════════════════════════════════════
install_xray_lite() {

	# ── 面板信息展示 ──
	echo ""
	echo -e "${rw_cheng}━━━━━━ 3XUI迷你版 xray-cf-lite ━━━━━━${rw_lv}"
	echo ""
	echo -e " ${rw_lv}xray-cf-lite 是 byJoey 开发的轻量级 xray + Cloudflare 一键脚本${rw_lv}"
	echo -e " ${rw_lv}适用场景: NAT 小鸡 / 256MB 内存 / Alpine 容器等资源极度受限环境${rw_lv}"
	echo -e " ${rw_lv}轻量高效：无面板裸跑仅 14MB，三协议全开，支持 CF+WSS 代理。${rw_lv}"
	echo -e " ${rw_lv}自动配置：一键搞定 CF DNS/SSL/Origin Rules 及订阅链接。${rw_lv}"
	echo -e " ${rw_lv}作者: ${rw_huang}https://joeyblog.net${rw_lv}"
	echo -e " ${rw_lv}仓库: ${rw_huang}https://github.com/byJoey/xray-cf-lite${rw_lv}"
	echo -e " ${rw_lv}博文: ${rw_huang}https://joeyblog.net/xray-cf-lite-blog.html${rw_lv}"
	echo ""

	# ── 使用前准备提醒 ──
	echo -e " ${rw_hong}⚠ 使用前必须准备:${rw_lv}"
	echo -e "   ${rw_huang}①${rw_lv} 一个在 Cloudflare 托管的域名"
	echo -e "   ${rw_huang}②${rw_lv} Cloudflare Global API Key（注意：不是 API Token）"
	echo -e "   ${rw_huang}③${rw_lv} 如果是 NAT 小鸡，需知道端口映射关系（外部端口 → 内部端口）"
	echo ""
	echo -e " ${rw_hong}⚠ 特点:${rw_lv}"
	echo -e "   - ${rw_lv}没有 Web 管理界面 / 流量统计 / 多用户管理${rw_lv}"
	echo -e "   - ${rw_lv}优势: 内存占用从几百 MB 降到 14MB${rw_lv}"
	echo -e "   - ${rw_lv}轻量极简，只要能跑节点选本项${rw_lv}"
	echo ""
	echo -e " ${rw_hong}⚠ 合规提醒:${rw_lv}"
	echo -e "   - 仅用于个人学习与合法用途，请遵守当地法律法规"
	echo -e "   - 每次联网拉取最新脚本执行，本地不留文件"
	echo ""

	# ── 确认是否开始安装 ──
	read -e -p " 确认开始安装 3XUI迷你版？(y/N): " _confirm < /dev/tty
	if [[ ! "$_confirm" =~ ^[Yy]$ ]]; then
		yellow "已取消"
		return 0
	fi

	# ── 系统架构检查 ──
	local _arch
	_arch=$(uname -m 2>/dev/null || echo "")
	local _arch_ok=false
	case "$_arch" in
		x86_64|amd64|x64) _arch_ok=true ;;
		aarch64|arm64|armv8*) _arch_ok=true ;;
		*)
			red "不支持的系统架构: ${_arch:-未知}"
			echo -e " ${rw_huang}xray-cf-lite 主要支持 x86_64 / arm64 架构${rw_lv}"
			return 1
			;;
	esac

	# ── 检查是否已安装（快捷命令 x 或 xray 进程） ──
	if command -v x &>/dev/null || pgrep -x xray &>/dev/null; then
		green "检测到 xray-cf-lite 可能已安装"
		echo -e " ${rw_huang}快捷命令: x${rw_lv}"
		echo -e " ${rw_huang}如需重新配置/更新，直接运行 x 打开菜单${rw_lv}"
		echo ""
		read -e -p " 是否重新运行安装脚本？(y/N): " _reinstall < /dev/tty
		if [[ ! "$_reinstall" =~ ^[Yy]$ ]]; then
			yellow "已取消"
			return 0
		fi
	fi

	# ── 确保依赖可用（curl + bash） ──
	if ! command -v curl &>/dev/null; then
		yellow "未检测到 curl，正在安装..."
		install curl
	fi
	# Alpine 等环境可能没有 bash
	if [ -z "$(command -v bash 2>/dev/null)" ]; then
		yellow "未检测到 bash，正在安装..."
		install bash
	fi

	# ── 安装前再次提醒准备 CF 信息 ──
	echo ""
	echo -e " ${rw_cheng}━━━━━━ 安装前请准备好以下信息 ━━━━━━${rw_lv}"
	echo -e "   ${rw_huang}•${rw_lv} Cloudflare 托管的域名"
	echo -e "   ${rw_huang}•${rw_lv} Cloudflare 账号邮箱"
	echo -e "   ${rw_huang}•${rw_lv} Cloudflare Global API Key（Dashboard → My Profile → API Tokens → Global API Key → View）"
	echo -e "   ${rw_huang}•${rw_lv} 若为 NAT 环境：外部端口 → 内部端口的映射关系"
	echo -e " ${rw_cheng}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${rw_lv}"
	echo ""
	read -e -p " 已准备好以上信息，开始执行？(y/N): " _ready < /dev/tty
	if [[ ! "$_ready" =~ ^[Yy]$ ]]; then
		yellow "已取消，请准备好信息后再试"
		return 0
	fi

	# ── 官方脚本地址 ──
	local _script_url="https://raw.githubusercontent.com/byJoey/xray-cf-lite/main/xray_cf_lite.sh"

	# ── 执行官方安装脚本（联网拉取最新版，交互式） ──
	echo ""
	echo -e " ${rw_huang}正在调用官方脚本安装 xray 迷你版...${rw_lv}"
	echo -e " ${rw_lv}命令: bash <(curl -fsSL ${_script_url})${rw_lv}"
	echo -e " ${rw_cheng}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${rw_lv}"
	echo ""

	bash <(curl -fsSL "$_script_url")
	local _install_rc=$?

	# ── 安装结果提示 ──
	echo ""
	echo -e "${rw_cheng}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${rw_lv}"
	if [ $_install_rc -eq 0 ]; then
		green "xray-cf-lite 安装流程结束"
		echo ""
		echo -e " ${rw_huang}使用方式:${rw_lv}"
		echo -e "   ${rw_lv}x${rw_lv}                    — 打开管理菜单（快捷命令，首次安装后注册）"
		echo -e "   ${rw_lv}菜单 1-5${rw_lv}              — 安装/配置/查看订阅等"
		echo -e "   ${rw_lv}菜单 6${rw_lv}                — 更新外部端口（NAT 端口变更时用）"
		echo -e "   ${rw_lv}菜单 7${rw_lv}                — 手动重启 xray"
		echo ""
		echo -e " ${rw_huang}如快捷命令 x 未生效，重新登录终端或执行:${rw_lv}"
		echo -e "   ${rw_lv}bash <(curl -fsSL ${_script_url})${rw_lv}"
		echo ""
		echo -e " ${rw_huang}常见问题排查:${rw_lv}"
		echo -e "   ${rw_lv}• 节点全 -1:${rw_lv} 检查 CF Bot Fight Mode 是否关闭"
		echo -e "   ${rw_lv}• TCP 连不上:${rw_lv} 检查容器 MTU 是否与宿主机一致（尝试 1500）"
		echo -e "   ${rw_lv}• 端口变更:${rw_lv} 用菜单 6 更新外部端口，无需重启 xray"
	else
		red "xray-cf-lite 安装过程返回非零状态码 (退出码: $_install_rc)"
		echo -e " ${rw_huang}请检查上方日志中的错误信息${rw_lv}"
		echo -e " ${rw_huang}常见原因:${rw_lv}"
		echo -e "   - 网络不通或 raw.githubusercontent.com 不可达（国内服务器常见）"
		echo -e "   - Cloudflare API Key / 域名信息填写有误"
		echo -e "   - Alpine 环境缺少 bash 或 curl"
		echo -e " ${rw_huang}参考博文: ${rw_lv}https://joeyblog.net/xray-cf-lite-blog.html${rw_lv}"
		echo -e " ${rw_huang}TG 交流群: ${rw_lv}https://t.me/+ft-zI76oovgwNmRh${rw_lv}"
	fi
}


linux_panel() {

local sub_choice="$1"

clear
cd ~
send_stats "应用市场"
echo -e "${rw_huang}应用市场${rw_lv}"
echo -e "${rw_cheng}------------------------${rw_lv}"
echo ""

while true; do

	if [ -z "$sub_choice" ]; then
	  clear
	  echo -e "${rw_cheng}━━━━━━━━━━━━  应用市场  ━━━━━━━━━━━━${rw_lv}"
	  echo ""
	  echo -e " ${rw_huang}1.   ${rw_lv}1Panel 新一代管理面板${rw_lv}"
	  echo -e " ${rw_huang}2.   ${rw_lv}xray 迷你版${rw_lv}"
	  echo -e " ${rw_huang}3.   ${rw_lv}3X-UI 多协议代理面板${rw_lv}"
	  echo -e " ${rw_huang}4.   ${rw_lv}虚拟机 Quickemu${rw_lv}"
	  echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
	  echo -e " ${rw_huang}0.   ${rw_lv}返回主菜单${rw_lv}"
	  echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
	  read -e -p " 请输入你的选择: " sub_choice
	fi

	case "$sub_choice" in
	  1)
		# ── 1Panel 新一代管理面板 ──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 1Panel 新一代管理面板 ━━━━━━${rw_lv}"
		echo ""
		echo -e " ${rw_lv}1Panel 是飞致云开源的现代 Linux 服务器运维面板${rw_lv}"
		echo -e " ${rw_lv}特性: 可视化界面 / 应用商店 / Docker 管理 / 网站管理 / 防火墙 / 计划任务${rw_lv}"
		echo -e " ${rw_lv}依赖: Docker（安装脚本会自动检测并安装）${rw_lv}"
		echo -e " ${rw_lv}官网: ${rw_huang}https://1panel.cn${rw_lv}"
		echo -e " ${rw_lv}开源: ${rw_huang}https://github.com/1Panel-dev/1Panel${rw_lv}"
		echo ""
		echo -e " ${rw_huang}即将执行:${rw_lv}"
		echo -e "   1) 检测系统环境（Linux x86_64 / arm64）"
		echo -e "   2) 下载并运行 1Panel 官方 install.sh 在线脚本"
		echo -e "   3) 脚本会自动安装 Docker（如未安装）并启动 1Panel 服务"
		echo -e "   4) 安装完成后终端会显示访问地址 / 用户名 / 密码"
		echo ""
		echo -e " ${rw_hong}⚠ 注意:${rw_lv}"
		echo -e "   - 官方脚本来自 ${rw_huang}https://resource.fit2cloud.com/1panel/package/install.sh${rw_lv}"
		echo -e "   - 安装过程需要交互（设置端口/入口/用户名/密码），请按提示操作"
		echo -e "   - 如网络较慢，可先用本工具箱的「换源」功能切换镜像源"
		echo ""
		read -e -p " 确认开始安装 1Panel？(y/N): " _confirm < /dev/tty
		if [[ ! "$_confirm" =~ ^[Yy]$ ]]; then
			yellow "已取消"
			break_cancel
			sub_choice=""
			continue
		fi

		# 系统架构检查
		local _arch
		_arch=$(uname -m 2>/dev/null || echo "")
		case "$_arch" in
			x86_64|amd64) _arch_ok=1 ;;
			aarch64|arm64) _arch_ok=1 ;;
			*)
				red "不支持的系统架构: ${_arch:-未知}"
				echo -e " ${rw_huang}1Panel 仅支持 x86_64 / arm64 架构${rw_lv}"
				break_end
				sub_choice=""
				continue
				;;
		esac

		# 检查是否已安装
		if command -v 1pctl &>/dev/null || systemctl is-active --quiet 1panel 2>/dev/null; then
			green "检测到 1Panel 已安装"
			echo -e " ${rw_huang}管理命令: 1pctl${rw_lv}"
			echo -e " ${rw_huang}查看状态: 1pctl status${rw_lv}"
			echo -e " ${rw_huang}查看访问信息: 1pctl user-info${rw_lv}"
			echo ""
			read -e -p " 是否重新安装/升级？(y/N): " _reinstall < /dev/tty
			if [[ ! "$_reinstall" =~ ^[Yy]$ ]]; then
				yellow "已取消"
				break_cancel
				sub_choice=""
				continue
			fi
		fi

		# 下载并执行官方安装脚本
		echo ""
		echo -e " ${rw_huang}正在下载 1Panel 官方安装脚本...${rw_lv}"
		local _install_script="/tmp/1panel_install_$$.sh"
		local _download_ok=false

		# 优先使用 curl，回退 wget
		if command -v curl &>/dev/null; then
			if curl -fsSL "https://resource.fit2cloud.com/1panel/package/install.sh" -o "$_install_script" 2>/dev/null; then
				_download_ok=true
			fi
		elif command -v wget &>/dev/null; then
			if wget -q -O "$_install_script" "https://resource.fit2cloud.com/1panel/package/install.sh" 2>/dev/null; then
				_download_ok=true
			fi
		else
			# 都没有就装一个
			install curl
			if curl -fsSL "https://resource.fit2cloud.com/1panel/package/install.sh" -o "$_install_script" 2>/dev/null; then
				_download_ok=true
			fi
		fi

		if ! $_download_ok || [ ! -s "$_install_script" ]; then
			red "下载安装脚本失败"
			echo -e " ${rw_huang}可能原因:${rw_lv}"
			echo -e "   - 网络不通或 DNS 解析失败"
			echo -e "   - resource.fit2cloud.com 不可达"
			echo -e " ${rw_huang}解决方案:${rw_lv}"
			echo -e "   - 检查服务器网络和 DNS"
			echo -e "   - 手动执行: ${rw_lv}curl -sSL https://resource.fit2cloud.com/1panel/package/install.sh | bash${rw_lv}"
			rm -f "$_install_script" 2>/dev/null
			break_end
			sub_choice=""
			continue
		fi

		green "安装脚本下载成功"
		echo ""
		echo -e " ${rw_huang}正在执行 1Panel 安装（请按提示交互）...${rw_lv}"
		echo -e " ${rw_cheng}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${rw_lv}"
		echo ""

		# 执行官方安装脚本（交互式）
		bash "$_install_script"
		local _install_rc=$?

		# 清理临时脚本
		rm -f "$_install_script" 2>/dev/null

		echo ""
		echo -e "${rw_cheng}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${rw_lv}"
		if [ $_install_rc -eq 0 ]; then
			green "1Panel 安装流程结束"
			echo ""
			echo -e " ${rw_huang}常用管理命令:${rw_lv}"
			echo -e "   ${rw_lv}1pctl status${rw_lv}          — 查看服务状态"
			echo -e "   ${rw_lv}1pctl user-info${rw_lv}       — 查看访问地址/用户名/密码"
			echo -e "   ${rw_lv}1pctl restart${rw_lv}         — 重启 1Panel 服务"
			echo -e "   ${rw_lv}1pctl stop${rw_lv}            — 停止 1Panel 服务"
			echo -e "   ${rw_lv}1pctl version${rw_lv}         — 查看版本"
			echo -e "   ${rw_lv}1pctl update${rw_lv}          — 升级到最新版"
			echo ""
			echo -e " ${rw_huang}官方文档: ${rw_lv}https://1panel.cn/docs${rw_lv}"
			echo -e " ${rw_huang}如忘记访问信息，执行: ${rw_lv}1pctl user-info${rw_lv}"
		else
			red "1Panel 安装过程返回非零状态码 (退出码: $_install_rc)"
			echo -e " ${rw_huang}请检查上方安装日志中的错误信息${rw_lv}"
			echo -e " ${rw_huang}或参考官方文档: ${rw_lv}https://1panel.cn/docs${rw_lv}"
		fi
		;;
	  2)
		# ── 3XUI迷你版 xray-cf-lite（调用 install_xray_lite 函数） ──
		install_xray_lite
		break_end
		sub_choice=""
		continue
		;;
	  3)
		# ── 3X-UI 多协议代理面板（调用 install_3xui 函数） ──
		install_3xui
		break_end
		sub_choice=""
		continue
		;;
	  4)
		# ── 虚拟机 Quickemu ──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 虚拟机 Quickemu ━━━━━━${rw_lv}"
		echo ""
		echo -e " ${rw_lv}Quickemu 是 QEMU 的封装脚本，快速创建和运行虚拟机${rw_lv}"
		echo -e " ${rw_lv}特性: 无需复杂配置，自动为你的硬件选择最优配置${rw_lv}"
		echo -e " ${rw_lv}自动配置：quickget 自动下载系统镜像，quickemu 自动匹配硬件最优配置。${rw_lv}"
		echo -e " ${rw_lv}广泛支持：支持近 1000 种系统，包括 Windows 10/11 (含 TPM 2.0)、macOS 及主流 Linux 发行版。${rw_lv}"
		echo -e " ${rw_lv}丰富特性：支持 SPICE 远程桌面、USB 透传、文件共享及 ARM64 客户机。${rw_lv}"
		echo -e " ${rw_lv}宿主要求: Linux 或 macOS（需图形界面）${rw_lv}"
		echo -e " ${rw_lv}官网: ${rw_huang}https://github.com/quickemu-project/quickemu${rw_lv}"
		echo -e " ${rw_lv}文档: ${rw_huang}https://github.com/quickemu-project/quickemu/wiki${rw_lv}"
		echo ""
		echo -e " ${rw_hong}⚠ 提醒事项:${rw_lv}"
		echo -e "   ${rw_huang}①${rw_lv} quickget自动下载上游操作系统并创建配置"
		echo -e "   ${rw_huang}②${rw_lv} quickemu列举您的硬件，并以最适合您计算机的最佳配置启动虚拟机 "
		echo -e "   ${rw_lv}仓库: ${rw_huang}https://github.com/quickemu-project/quickgui${rw_lv}"
		echo ""
		read -e -p " 确认开始安装 Quickemu？(y/N): " _confirm < /dev/tty
		if [[ ! "$_confirm" =~ ^[Yy]$ ]]; then
			yellow "已取消"
			break_cancel
			sub_choice=""
			continue
		fi

		# 系统架构检查
		local _arch
		_arch=$(uname -m 2>/dev/null || echo "")
		case "$_arch" in
			x86_64|amd64) : ;;
			aarch64|arm64) : ;;
			*)
				red "不支持的系统架构: ${_arch:-未知}"
				echo -e " ${rw_huang}Quickemu 主要支持 x86_64 / arm64 架构${rw_lv}"
				break_end
				sub_choice=""
				continue
				;;
		esac

		# 检查是否已安装
		if command -v quickemu &>/dev/null; then
			green "检测到 Quickemu 已安装"
			echo -e " ${rw_huang}版本: $(quickemu --version 2>/dev/null | head -1 || echo 未知)${rw_lv}"
			echo -e " ${rw_huang}使用: quickget <OS> <版本> <类型> 下载镜像${rw_lv}"
			echo -e " ${rw_huang}使用: quickemu --vm <配置>.conf 启动虚拟机${rw_lv}"
			echo ""
			read -e -p " 是否重新安装/升级？(y/N): " _reinstall < /dev/tty
			if [[ ! "$_reinstall" =~ ^[Yy]$ ]]; then
				yellow "已取消"
				break_cancel
				sub_choice=""
				continue
			fi
		fi

		# 根据发行版选择安装方式
		local _quickemu_install_ok=false
		echo ""
		echo -e " ${rw_huang}正在检测系统发行版并安装 Quickemu...${rw_lv}"
		echo ""

		# 检测包管理器和发行版
		if command -v apt-get &>/dev/null; then
			# Debian/Ubuntu 系
			echo -e " ${rw_lv}检测到 Debian/Ubuntu 系发行版${rw_lv}"
			# 检查是否是 Ubuntu（支持 PPA）
			if [ -f /etc/os-release ] && grep -qi ubuntu /etc/os-release 2>/dev/null; then
				echo -e " ${rw_huang}使用 Ubuntu PPA 安装...${rw_lv}"
				install software-properties-common 2>/dev/null
				sudo apt-add-repository -y ppa:flexiondotorg/quickemu 2>/dev/null
				sudo apt-get update -qq 2>/dev/null
				sudo apt-get install -y quickemu qemu-system-modules-spice 2>/dev/null
				[ $? -eq 0 ] && _quickemu_install_ok=true
			else
				# Debian 系：从 GitHub releases 下载 .deb
				echo -e " ${rw_huang}从 GitHub releases 下载 .deb 安装...${rw_lv}"
				local _deb_url
				_deb_url=$(curl -fsSL "https://api.github.com/repos/quickemu-project/quickemu/releases/latest" 2>/dev/null | \
					grep -o '"browser_download_url": *"[^"]*\.deb"' | head -1 | sed 's/.*"\(https[^"]*\.deb\)"/\1/')
				if [ -n "$_deb_url" ]; then
					local _deb_file="/tmp/quickemu_$$.deb"
					if curl -fsSL "$_deb_url" -o "$_deb_file" 2>/dev/null; then
						sudo apt-get install -y "$_deb_file" 2>/dev/null
						[ $? -eq 0 ] && _quickemu_install_ok=true
						rm -f "$_deb_file" 2>/dev/null
					fi
				fi
				# 如果 .deb 安装失败，回退到源码安装
				if ! $_quickemu_install_ok; then
					echo -e " ${rw_huang}.deb 安装失败，回退到源码安装...${rw_lv}"
					sudo apt-get install -y bash coreutils curl gdisk genisoimage grep jq mesa-utils mtools ovmf pciutils procps python3 qemu sed socat spice-client-gtk swtpm-tools unzip usbutils util-linux xdg-user-dirs xrandr zsync 2>/dev/null
				fi
			fi

		elif command -v dnf &>/dev/null; then
			# Fedora
			echo -e " ${rw_lv}检测到 Fedora/RHEL 系发行版${rw_lv}"
			sudo dnf install -y quickemu 2>/dev/null
			[ $? -eq 0 ] && _quickemu_install_ok=true

		elif command -v pacman &>/dev/null; then
			# Arch
			echo -e " ${rw_lv}检测到 Arch Linux 系发行版${rw_lv}"
			if command -v yay &>/dev/null; then
				yay -Sy --noconfirm quickemu 2>/dev/null
				[ $? -eq 0 ] && _quickemu_install_ok=true
			else
				echo -e " ${rw_huang}需要 AUR 助手 yay，正在安装...${rw_lv}"
				sudo pacman -S --needed --noconfirm base-devel git 2>/dev/null
				git clone https://aur.archlinux.org/yay.git /tmp/yay_$$ 2>/dev/null
				cd /tmp/yay_$$ && makepkg -si --noconfirm 2>/dev/null
				cd ~
				rm -rf /tmp/yay_$$
				if command -v yay &>/dev/null; then
					yay -Sy --noconfirm quickemu 2>/dev/null
					[ $? -eq 0 ] && _quickemu_install_ok=true
				fi
			fi

		elif command -v brew &>/dev/null; then
			# macOS
			echo -e " ${rw_lv}检测到 macOS (Homebrew)${rw_lv}"
			brew tap quickemu-project/quickemu 2>/dev/null
			brew install quickemu 2>/dev/null
			[ $? -eq 0 ] && _quickemu_install_ok=true

		else
			red "未识别的包管理器"
			echo -e " ${rw_huang}请参考官方安装文档手动安装:${rw_lv}"
			echo -e "   ${rw_lv}https://github.com/quickemu-project/quickemu/wiki/01-Installation${rw_lv}"
		fi

		# 如果包管理器安装失败，回退到源码安装
		if ! $_quickemu_install_ok && ! command -v quickemu &>/dev/null; then
			echo ""
			echo -e " ${rw_huang}包管理器安装未成功，尝试源码编译安装...${rw_lv}"
			local _src_dir="/tmp/quickemu_src_$$"
			if git clone --filter=blob:none https://github.com/quickemu-project/quickemu "$_src_dir" 2>/dev/null; then
				cd "$_src_dir/docs"
				sudo make install 2>/dev/null
				local _make_rc=$?
				cd ~
				rm -rf "$_src_dir" 2>/dev/null
				if [ $_make_rc -eq 0 ]; then
					_quickemu_install_ok=true
				else
					red "源码安装失败"
				fi
			else
				red "克隆仓库失败"
			fi
		fi

		echo ""
		if command -v quickemu &>/dev/null || $_quickemu_install_ok; then
			green "Quickemu 安装成功"
			echo ""
			echo -e " ${rw_huang}使用方法:${rw_lv}"
			echo -e "   ${rw_lv}①${rw_lv} 下载OS镜像并生成配置:"
			echo -e "      ${rw_lv}quickget <操作系统> <版本> <类型>${rw_lv}"
			echo -e "      ${rw_huang}示例:${rw_lv} ${rw_lv}quickget nixos unstable minimal${rw_lv}"
			echo -e "      ${rw_huang}示例:${rw_lv} ${rw_lv}quickget ubuntu 24.04 desktop${rw_lv}"
			echo -e "   ${rw_lv}②${rw_lv} 启动虚拟机:"
			echo -e "      ${rw_lv}quickemu --vm <配置文件>.conf${rw_lv}"
			echo -e "      ${rw_huang}示例:${rw_lv} ${rw_lv}quickemu --vm nixos-unstable-minimal.conf${rw_lv}"
			echo ""
			echo -e " ${rw_huang}查看所有支持的操作系统:${rw_lv}"
			echo -e "   ${rw_lv}quickget${rw_lv}（不带参数运行即可列出全部支持的OS）"
			echo ""
			echo -e " ${rw_huang}可选: 安装图形前端 Quickgui${rw_lv}"
			echo -e "   ${rw_lv}仓库: https://github.com/quickemu-project/quickgui${rw_lv}"
			echo ""
			echo -e " ${rw_huang}官方文档: ${rw_lv}https://github.com/quickemu-project/quickemu/wiki${rw_lv}"
		else
			red "Quickemu 安装失败"
			echo -e " ${rw_huang}请参考官方安装文档手动安装:${rw_lv}"
			echo -e "   ${rw_lv}https://github.com/quickemu-project/quickemu/wiki/01-Installation${rw_lv}"
			echo -e " ${rw_huang}常见原因:${rw_lv}"
			echo -e "   - 系统发行版不在支持列表"
			echo -e "   - 缺少必要依赖（QEMU/Python3/jq 等）"
			echo -e "   - 网络不通导致下载失败"
			echo -e "   - macOS 宿主需用 brew 安装"
		fi
		;;
	  0)
		break
		;;
	  *)
		red "无效的输入!"
		;;
	esac
	break_cancel
	sub_choice=""

done
}



linux_work() {
while true; do
	clear

	# ── 状态探测 ──
	local _tmux_stat="${rw_hong}未安装${rw_lv}" _session_count=0 _session_list=""
	if command -v tmux &>/dev/null; then
		if pgrep -x tmux &>/dev/null; then
			_tmux_stat="${rw_lv}运行中${rw_lv}"
		else
			_tmux_stat="${rw_huang}已安装${rw_lv}"
		fi
		_session_list=$(tmux list-sessions 2>/dev/null)
		_session_count=$(echo "$_session_list" | grep -c . 2>/dev/null || echo 0)
		[ "$_session_count" -le 0 ] && _session_count=0
	fi

	echo -e "${rw_cheng}━━━━━━━━━━━━  后台工作区  ━━━━━━━━━━━━${rw_lv}"
	echo -e " tmux ${_tmux_stat}   活跃会话 ${rw_huang}${_session_count}${rw_lv} 个"
	echo ""

	# 显示当前会话列表（如果有）
	if [ "$_session_count" -gt 0 ] && [ -n "$_session_list" ]; then
		echo -e " ${rw_cheng}── 当前会话 ──${rw_lv}"
		echo "$_session_list" | while IFS= read -r _line; do
			local _name="${_line%%:*}"
			echo -e "   ${rw_huang}•${rw_lv} ${_name}"
		done
		echo ""
	fi

	echo -e " ${rw_cheng}──── 快速操作 ──${rw_lv}"
	echo -e " ${rw_huang}1${rw_lv}  新建工作区并进入"
	echo -e " ${rw_huang}2${rw_lv}  进入已有会话（选择编号）"
	echo -e " ${rw_huang}3${rw_lv}  后台执行命令（不进入）"
	echo -e " ${rw_huang}4${rw_lv}  删除会话"
	echo -e " ${rw_huang}5${rw_lv}  删除全部会话"
	echo ""
	echo -e " ${rw_cheng}──── SSH 常驻 ──${rw_lv}"
	echo -e " ${rw_huang}6${rw_lv}  开启（登录自动进入 tmux）"
	echo -e " ${rw_huang}7${rw_lv}  关闭"
	echo ""
	echo -e " ${rw_lv}提示: 退出工作区按 Ctrl+b 再按 d${rw_lv}"
	echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
	echo -e " ${rw_huang}0${rw_lv}  返回主菜单"
	echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
	read -e -p " 请选择: " _wk_choice

	case $_wk_choice in
		1)
			# 新建工作区
			read -e -p " 工作区名称 [默认: work]: " _name < /dev/tty
			_name="${_name:-work}"
			install tmux
			if tmux has-session -t "$_name" 2>/dev/null; then
				echo -e " ${rw_huang}会话 $_name 已存在，直接进入${rw_lv}"
			else
				send_stats "新建工作区 $_name"
			fi
			tmux new -s "$_name" 2>/dev/null || tmux attach-session -t "$_name"
			;;
		2)
			# 进入已有会话
			if [ "$_session_count" -eq 0 ]; then
				echo -e " ${rw_hong}当前无活跃会话${rw_lv}"
				break_end
				continue
			fi
			echo ""
			echo "$_session_list" | nl -ba | sed 's/^/   /'
			echo ""
			read -e -p " 选择会话编号: " _idx < /dev/tty
			local _target
			_target=$(echo "$_session_list" | sed -n "${_idx}p" | cut -d: -f1)
			if [ -z "$_target" ]; then
				echo -e " ${rw_hong}无效选择${rw_lv}"
				break_end
				continue
			fi
			tmux attach-session -t "$_target"
			;;
		3)
			# 后台执行命令
			read -e -p " 要后台执行的命令: " _cmd < /dev/tty
			if [ -z "$_cmd" ]; then
				echo -e " ${rw_hong}命令不能为空${rw_lv}"
				break_end
				continue
			fi
			install tmux
			local _bg_name="bg1"
			local _n=1
			while tmux has-session -t "$_bg_name" 2>/dev/null; do
				_n=$((_n + 1))
				_bg_name="bg${_n}"
			done
			tmux new -d -s "$_bg_name" "$_cmd"
			echo -e " ${rw_lv}✓ 已在后台会话 ${rw_huang}${_bg_name}${rw_lv}${rw_lv} 执行${rw_lv}"
			echo -e " ${rw_huang}查看: tmux attach -t ${_bg_name}${rw_lv}"
			send_stats "后台执行命令"
			break_end
			;;
		4)
			# 删除单个会话
			if [ "$_session_count" -eq 0 ]; then
				echo -e " ${rw_hong}当前无活跃会话${rw_lv}"
				break_end
				continue
			fi
			echo ""
			echo "$_session_list" | nl -ba | sed 's/^/   /'
			echo ""
			read -e -p " 选择要删除的会话编号: " _idx < /dev/tty
			local _target
			_target=$(echo "$_session_list" | sed -n "${_idx}p" | cut -d: -f1)
			if [ -n "$_target" ]; then
				tmux kill-session -t "$_target" 2>/dev/null && \
					green "✓ 会话 $_target 已删除" || red "删除失败"
			else
				red "无效选择"
			fi
			break_end
			;;
		5)
			# 删除全部会话
			if [ "$_session_count" -eq 0 ]; then
				echo -e " ${rw_hong}当前无活跃会话${rw_lv}"
				break_end
				continue
			fi
			read -e -p " 确认删除全部 ${_session_count} 个会话？(y/N): " _confirm < /dev/tty
			if [[ "$_confirm" =~ ^[Yy]$ ]]; then
				tmux kill-server 2>/dev/null
				green "✓ 全部会话已删除"
			else
				yellow "已取消"
			fi
			break_cancel
			;;
		6)
			# 开启 SSH 常驻
			install tmux
			if ! grep -q "tmux attach-session -t sshd" ~/.bashrc 2>/dev/null; then
				cat >> ~/.bashrc << 'BASHEOF'

# riwi SSH 常驻模式: 登录自动进入 tmux
if [[ -z "$TMUX" ]]; then
    tmux attach-session -t sshd 2>/dev/null || tmux new-session -s sshd
fi
BASHEOF
				green "✓ SSH 常驻已开启（下次登录自动进入 tmux）"
			else
				yellow "SSH 常驻已开启，无需重复操作"
			fi
			send_stats "开启SSH常驻"
			break_end
			;;
		7)
			# 关闭 SSH 常驻
			sed -i '/# riwi SSH 常驻模式/,+4d' ~/.bashrc 2>/dev/null
			sed -i '/tmux attach-session -t sshd/d' ~/.bashrc 2>/dev/null
			tmux kill-session -t sshd 2>/dev/null
			green "✓ SSH 常驻已关闭"
			send_stats "关闭SSH常驻"
			break_end
			;;
		0)
			break
			;;
		*)
			red "无效的输入!"
			sleep 1
			;;
	esac
	break_cancel
done
}










# 智能切换镜像源函数
switch_mirror() {
	# 可选参数，默认为 false
	local upgrade_software=${1:-false}
	local clean_cache=${2:-false}

	# 获取用户国家
	local country
	country=$(curl -s ipinfo.io/country)

	echo "检测到国家：$country"

	if [ "$country" = "CN" ]; then
		echo "使用国内镜像源..."
		bash <(curl -sSL https://linuxmirrors.cn/main.sh) \
		  --source mirrors.huaweicloud.com \
		  --protocol https \
		  --use-intranet-source false \
		  --backup true \
		  --upgrade-software "$upgrade_software" \
		  --clean-cache "$clean_cache" \
		  --ignore-backup-tips \
		  --install-epel false \
		  --pure-mode
	else
		echo "使用海外镜像源..."
		if [ -f /etc/os-release ] && grep -qi "oracle" /etc/os-release; then
			bash <(curl -sSL https://linuxmirrors.cn/main.sh) \
			  --source mirrors.xtom.com \
			  --protocol https \
			  --use-intranet-source false \
			  --backup true \
			  --upgrade-software "$upgrade_software" \
			  --clean-cache "$clean_cache" \
			  --ignore-backup-tips \
			  --install-epel false \
			  --pure-mode
		else
			bash <(curl -sSL https://linuxmirrors.cn/main.sh) \
				--use-official-source true \
				--protocol https \
				--use-intranet-source false \
				--backup true \
				--upgrade-software "$upgrade_software" \
				--clean-cache "$clean_cache" \
				--ignore-backup-tips \
				--install-epel false \
				--pure-mode
		fi
	fi
}


fail2ban_panel() {
		  root_use
		  send_stats "ssh防御"
		  while true; do

				check_f2b_status
				echo -e "SSH防御程序 $check_f2b_status"
				echo "fail2ban是一个SSH防止暴力破解工具"
				echo "官网介绍: ${gh_proxy}github.com/fail2ban/fail2ban"
				echo -e "${rw_cheng}------------------------${rw_lv}"
				echo "1. 安装防御程序"
				echo -e "${rw_cheng}------------------------${rw_lv}"
				echo "2. 查看SSH拦截记录"
				echo "3. 日志实时监控"
				echo -e "${rw_cheng}------------------------${rw_lv}"
				echo "4. 基础参数配置（封禁时长/时间窗口/重试次数）"
				echo "5. 编辑配置文件（nano）"
				echo -e "${rw_cheng}------------------------${rw_lv}"
				echo "9. 卸载防御程序"
				echo -e "${rw_cheng}------------------------${rw_lv}"
				echo "0. 返回上一级选单"
				echo -e "${rw_cheng}------------------------${rw_lv}"
				read -e -p "请输入你的选择: " sub_choice
				case $sub_choice in
					1)
						f2b_install_sshd
						cd ~
						f2b_status
						break_end
						;;
					2)
						echo -e "${rw_cheng}------------------------${rw_lv}"
						f2b_sshd
						echo -e "${rw_cheng}------------------------${rw_lv}"
						break_end
						;;
					3)
						tail -f /var/log/fail2ban.log
						break
						;;
					4)
						send_stats "SSH防御基础参数配置"
						f2b_basic_config
						break_end
						;;
					5)
						send_stats "SSH防御编辑配置文件"
						f2b_edit_config
						break_end
						;;
					9)
						remove fail2ban
						rm -rf /etc/fail2ban
						echo "Fail2Ban防御程序已卸载"
						break
						;;
					*)
						break
						;;
				esac
		  done

}





net_menu() {

	send_stats "网卡管理工具"
	show_nics() {
		echo -e "${rw_cheng}================ 当前网卡信息 ================${rw_lv}"
		printf "%-18s %-12s %-20s %-26s\n" "网卡名" "状态" "IP地址" "MAC地址"
		echo -e "${rw_cheng}------------------------------------------------${rw_lv}"
		for nic in $(ls /sys/class/net); do
			state=$(cat /sys/class/net/$nic/operstate 2>/dev/null)
			ipaddr=$(ip -4 addr show $nic | awk '/inet /{print $2}' | head -n1)
			mac=$(cat /sys/class/net/$nic/address 2>/dev/null)
			printf "%-15s %-10s %-18s %-20s\n" "$nic" "$state" "${ipaddr:-无}" "$mac"
		done
		echo -e "${rw_cheng}================================================${rw_lv}"
	}

	while true; do
		clear
		show_nics
		echo
		echo -e "${rw_cheng}=========== 网卡管理菜单 ===========${rw_lv}"
		echo "1. 启用网卡"
		echo "2. 禁用网卡"
		echo "3. 查看网卡详细信息"
		echo "4. 刷新网卡信息"
		echo "0. 返回上一级选单"
		echo -e "${rw_cheng}====================================${rw_lv}"
		read -erp "请选择操作: " choice

		case $choice in
			1)
				send_stats "启用网卡"
				read -erp "请输入要启用的网卡名: " nic
				if ip link show "$nic" &>/dev/null; then
					ip link set "$nic" up && echo "✔ 网卡 $nic 已启用"
				else
					echo "✘ 网卡不存在"
				fi
				read -erp "按回车继续..."
				;;
			2)
				send_stats "禁用网卡"
				read -erp "请输入要禁用的网卡名: " nic
				if ip link show "$nic" &>/dev/null; then
					ip link set "$nic" down && echo "✔ 网卡 $nic 已禁用"
				else
					echo "✘ 网卡不存在"
				fi
				read -erp "按回车继续..."
				;;
			3)
				send_stats "查看网卡详情"
				read -erp "请输入要查看的网卡名: " nic
				if ip link show "$nic" &>/dev/null; then
					echo -e "${rw_cheng}========== $nic 详细信息 ==========${rw_lv}"
					ip addr show "$nic"
					ethtool "$nic" 2>/dev/null | head -n 10
				else
					echo "✘ 网卡不存在"
				fi
				read -erp "按回车继续..."
				;;
			4)
				send_stats "刷新网卡信息"
				continue
				;;
			*)
				break
				;;
		esac
	done
}



log_menu() {
	send_stats "系统日志管理工具"

	show_log_overview() {
		echo -e "${rw_cheng}============= 系统日志概览 =============${rw_lv}"
		echo "主机名: $(hostname)"
		echo "系统时间: $(date)"
		echo
		echo "[ /var/log 目录占用 ]"
		du -sh /var/log 2>/dev/null
		echo
		echo "[ journal 日志占用 ]"
		journalctl --disk-usage 2>/dev/null
		echo -e "${rw_cheng}========================================${rw_lv}"
	}

	while true; do
		clear
		show_log_overview
		echo
		echo -e "${rw_cheng}=========== 系统日志管理菜单 ===========${rw_lv}"
		echo "1. 查看最近系统日志（journal）"
		echo "2. 查看指定服务日志"
		echo "3. 查看登录/安全日志"
		echo "4. 实时跟踪日志"
		echo "5. 清理旧 journal 日志"
		echo "0. 返回上一级选单"
		echo -e "${rw_cheng}=======================================${rw_lv}"
		read -erp "请选择操作: " choice

		case $choice in
			1)
				send_stats "查看最近日志"
				read -erp "查看最近多少行日志？[默认 100]: " lines
				lines=${lines:-100}
				journalctl -n "$lines" --no-pager
				read -erp "按回车继续..."
				;;
			2)
				send_stats "查看指定服务日志"
				read -erp "请输入服务名（如 sshd、nginx）: " svc
				if systemctl list-unit-files | grep -q "^$svc"; then
					journalctl -u "$svc" -n 100 --no-pager
				else
					echo "✘ 服务不存在或无日志"
				fi
				read -erp "按回车继续..."
				;;
			3)
				send_stats "查看登录/安全日志"
				echo -e "${rw_cheng}====== 最近登录日志 ======${rw_lv}"
				last -n 10
				echo
				echo -e "${rw_cheng}====== 认证日志 ======${rw_lv}"
				if [ -f /var/log/secure ]; then
					tail -n 20 /var/log/secure
				elif [ -f /var/log/auth.log ]; then
					tail -n 20 /var/log/auth.log
				else
					echo "未找到安全日志文件"
				fi
				read -erp "按回车继续..."
				;;
			4)
				send_stats "实时跟踪日志"
				echo "1) 系统日志"
				echo "2) 指定服务日志"
				read -erp "选择跟踪类型: " t
				if [ "$t" = "1" ]; then
					journalctl -f
				elif [ "$t" = "2" ]; then
					read -erp "输入服务名: " svc
					journalctl -u "$svc" -f
				else
					echo "无效选择"
				fi
				;;
			5)
				send_stats "清理旧 journal 日志"
				echo "⚠️ 清理 journal 日志（安全方式）"
				echo "1) 保留最近 7 天"
				echo "2) 保留最近 3 天"
				echo "3) 限制日志最大 500M"
				read -erp "请选择清理方式: " c
				case $c in
					1) journalctl --vacuum-time=7d ;;
					2) journalctl --vacuum-time=3d ;;
					3) journalctl --vacuum-size=500M ;;
					*) echo "无效选项" ;;
				esac
				echo "✔ journal 日志清理完成"
				sleep 2
				;;
			*)
				break
				;;
		esac
	done
}



env_menu() {

	BASHRC="$HOME/.bashrc"
	PROFILE="$HOME/.profile"

	send_stats "系统变量管理工具"

	show_env_vars() {
		clear
		send_stats "当前已生效环境变量"
		echo -e "${rw_cheng}========== 当前已生效环境变量（节选） ==========${rw_lv}"
		printf "%-20s %s\n" "变量名" "值"
		echo -e "${rw_cheng}-----------------------------------------------${rw_lv}"
		for v in USER HOME SHELL LANG PWD; do
			printf "%-20s %s\n" "$v" "${!v}"
		done

		echo
		echo "PATH:"
		echo "$PATH" | tr ':' '\n' | nl -ba

		echo
		echo -e "${rw_cheng}========== 配置文件中定义的变量（解析） ==========${rw_lv}"

		parse_file_vars() {
			local file="$1"
			[ -f "$file" ] || return

			echo
			echo ">>> 来源文件：$file"
			echo -e "${rw_cheng}-----------------------------------------------${rw_lv}"

			# 提取 export VAR=xxx 或 VAR=xxx
			grep -Ev '^\s*#|^\s*$' "$file" \
			| grep -E '^(export[[:space:]]+)?[A-Za-z_][A-Za-z0-9_]*=' \
			| while read -r line; do
				var=$(echo "$line" | sed -E 's/^(export[[:space:]]+)?([A-Za-z_][A-Za-z0-9_]*).*/\2/')
				val=$(echo "$line" | sed -E 's/^[^=]+=//')
				printf "%-20s %s\n" "$var" "$val"
			done
		}

		parse_file_vars "$HOME/.bashrc"
		parse_file_vars "$HOME/.profile"

		echo
		echo -e "${rw_cheng}===============================================${rw_lv}"
		read -erp "按回车继续..."
	}


	view_file() {
		local file="$1"
		send_stats "查看变量文件 $file"
		clear
		if [ -f "$file" ]; then
			echo -e "${rw_cheng}========== 查看文件：$file ==========${rw_lv}"
			cat -n "$file"
			echo -e "${rw_cheng}====================================${rw_lv}"
		else
			echo "文件不存在：$file"
		fi
		read -erp "按回车继续..."
	}

	edit_file() {
		local file="$1"
		send_stats "编辑变量文件 $file"
		install nano
		nano "$file"
	}

	source_files() {
		echo "正在重新加载环境变量..."
		send_stats "正在重新加载环境变量"
		source "$BASHRC"
		source "$PROFILE"
		echo "✔ 环境变量已重新加载"
		read -erp "按回车继续..."
	}

	while true; do
		clear
		echo -e "${rw_cheng}=========== 系统环境变量管理 ==========${rw_lv}"
		echo "当前用户：$USER"
		echo -e "${rw_cheng}--------------------------------------${rw_lv}"
		echo "1. 查看当前常用环境变量"
		echo "2. 查看 ~/.bashrc"
		echo "3. 查看 ~/.profile"
		echo "4. 编辑 ~/.bashrc"
		echo "5. 编辑 ~/.profile"
		echo "6. 重新加载环境变量（source）"
		echo -e "${rw_cheng}--------------------------------------${rw_lv}"
		echo "0. 返回上一级选单"
		echo -e "${rw_cheng}--------------------------------------${rw_lv}"
		read -erp "请选择操作: " choice

		case "$choice" in
			1)
				show_env_vars
				;;
			2)
				view_file "$BASHRC"
				;;
			3)
				view_file "$PROFILE"
				;;
			4)
				edit_file "$BASHRC"
				;;
			5)
				edit_file "$PROFILE"
				;;
			6)
				source_files
				;;
			0)
				break
				;;
			*)
				echo "无效选项"
				sleep 1
				;;
		esac
	done
}


create_user_with_sshkey() {
	local new_username="$1"
	local sshkey_vl

	if [[ -z "$new_username" ]]; then
		echo "用法：create_user_with_sshkey <用户名>"
		return 1
	fi

	# 检查用户是否已存在
	if id "$new_username" &>/dev/null; then
		echo -e "${rw_hong}错误：用户 $new_username 已存在！${rw_lv}"
		return 1
	fi

	# ====== 第1步：创建用户 ======
	echo -e "${rw_huang}[1/5] 创建用户 $new_username ...${rw_lv}"
	useradd -m -s /bin/bash "$new_username" || return 1
	echo -e "${rw_lv}  ✓ 用户 $new_username 创建成功${rw_lv}"

	# ====== 第2步：设置密码 ======
	echo -e "${rw_huang}[2/5] 设置用户密码 ...${rw_lv}"
	passwd "$new_username"

	# ====== 第3步：导入 SSH 公钥 ======
	echo -e "${rw_huang}[3/5] 导入 SSH 公钥 ...${rw_lv}"
	echo "导入公钥范例："
	echo "  - URL：      ${gh_https_url}github.com/torvalds.keys"
	echo "  - 直接粘贴： ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI..."
	read -e -p "请导入 ${new_username} 的公钥（留空跳过）: " sshkey_vl

	case "$sshkey_vl" in
		http://*|https://*)
			send_stats "从 URL 导入 SSH 公钥"
			fetch_remote_ssh_keys "$sshkey_vl" "/home/$new_username"
			;;
		ssh-rsa*|ssh-ed25519*|ssh-ecdsa*)
			send_stats "公钥直接导入"
			import_sshkey "$sshkey_vl" "/home/$new_username"
			;;
		"")
			echo -e "${rw_huang}  - 跳过 SSH 公钥导入${rw_lv}"
			;;
		*)
			echo -e "${rw_hong}错误：未知公钥格式，跳过导入${rw_lv}"
			;;
	esac

	# 修正 .ssh 权限
	chown -R "$new_username:$new_username" "/home/$new_username/.ssh" 2>/dev/null

	# ====== 第4步：赋予 sudo 最高权限 ======
	echo -e "${rw_huang}[4/5] 赋予 sudo 最高权限 ...${rw_lv}"
	install sudo
	cat >"/etc/sudoers.d/$new_username" <<EOF
$new_username ALL=(ALL) NOPASSWD:ALL
EOF
	chmod 440 "/etc/sudoers.d/$new_username"
	echo -e "${rw_lv}  ✓ 已写入 /etc/sudoers.d/$new_username → NOPASSWD:ALL${rw_lv}"

	# ====== 第5步：配置 SSH + 锁定密码登录 ======
	echo -e "${rw_huang}[5/5] 配置 SSH 并锁定密码登录 ...${rw_lv}"
	# 安全设置 UsePAM：修改已有行（取消注释），而不是追加到文件末尾
	# 原因：>> 追加会把 UsePAM 写到 Match 块后面，导致语法错误/认证失败
	if grep -qE '^#?[[:space:]]*UsePAM' /etc/ssh/sshd_config 2>/dev/null; then
		sed -i -E 's/^#?[[:space:]]*UsePAM[[:space:]]+.*/UsePAM yes/' /etc/ssh/sshd_config
	else
		# 不存在：追加到文件末尾（确保不在 Match 块内）
		echo '' >> /etc/ssh/sshd_config
		echo '# PAM 认证（由创建用户脚本添加）' >> /etc/ssh/sshd_config
		echo 'UsePAM yes' >> /etc/ssh/sshd_config
	fi
	passwd -l "$new_username" &>/dev/null
	restart_ssh
	echo -e "${rw_lv}  ✓ SSH 配置完成，密码登录已锁定（仅密钥登录）${rw_lv}"

	echo ""
	echo -e "${rw_cheng}============================================${rw_lv}"
	echo -e "${rw_cheng}  用户 $new_username 创建完成！${rw_lv}"
	echo -e "${rw_cheng}============================================${rw_lv}"

	# ====== 自动探测：用户组 & sudo 权限 ======
	echo ""
	echo -e "${rw_huang}>>> 自动探测验证 <<<${rw_lv}"

	# 用户组探测
	local user_groups=$(groups "$new_username" 2>/dev/null | cut -d : -f 2 | xargs)
	echo -e "  用户组: ${rw_lv}${user_groups}${rw_lv}"

	# sudo 权限探测（文件级 + 组级）
	local sudo_ok="否"
	if [[ -f "/etc/sudoers.d/$new_username" ]] && grep -qE "^\s*${new_username}\s+ALL=\(ALL\)" "/etc/sudoers.d/$new_username" 2>/dev/null; then
		sudo_ok="是"
	elif grep -qE "^\s*${new_username}\s+ALL=\(ALL\)" /etc/sudoers 2>/dev/null; then
		sudo_ok="是"
	elif echo "$user_groups" | grep -qE '(^|[[:space:]])(sudo|wheel)($|[[:space:]])'; then
		sudo_ok="是"
	fi

	if [[ "$sudo_ok" == "是" ]]; then
		echo -e "  sudo权限: ${rw_lv}✓ 已配置 NOPASSWD:ALL${rw_lv}"
	else
		echo -e "  sudo权限: ${rw_hong}✗ 未探测到，请手动检查${rw_lv}"
	fi

	# 密码状态探测
	local passwd_status=$(passwd -S "$new_username" 2>/dev/null | awk '{print $2}')
	echo -e "  密码状态: ${rw_huang}${passwd_status}${rw_lv} (L=锁定, P=可用)"
	echo ""
}





















linux_file() {
	root_use
	send_stats "文件管理器"
	while true; do
		clear
		echo "文件管理器"
		echo -e "${rw_cheng}------------------------${rw_lv}"
		echo "当前路径"
		pwd
		echo -e "${rw_cheng}------------------------${rw_lv}"
		ls --color=auto -x
		echo -e "${rw_cheng}------------------------${rw_lv}"
		echo "1.  进入目录           2.  创建目录             3.  修改目录权限         4.  重命名目录"
		echo "5.  删除目录           6.  返回上一级选单目录"
		echo -e "${rw_cheng}------------------------${rw_lv}"
		echo "11. 创建文件           12. 编辑文件             13. 修改文件权限         14. 重命名文件"
		echo "15. 删除文件"
		echo -e "${rw_cheng}------------------------${rw_lv}"
		echo "21. 压缩文件目录       22. 解压文件目录         23. 移动文件目录         24. 复制文件目录"
		echo "25. 传文件至其他服务器"
		echo -e "${rw_cheng}------------------------${rw_lv}"
		echo "0.  返回上一级选单"
		echo -e "${rw_cheng}------------------------${rw_lv}"
		read -e -p "请输入你的选择: " Limiting

		case "$Limiting" in
			1)  # 进入目录
				read -e -p "请输入目录名: " dirname
				cd "$dirname" 2>/dev/null || echo "无法进入目录"
				send_stats "进入目录"
				;;
			2)  # 创建目录
				read -e -p "请输入要创建的目录名: " dirname
				mkdir -p "$dirname" && echo "目录已创建" || echo "创建失败"
				send_stats "创建目录"
				;;
			3)  # 修改目录权限
				read -e -p "请输入目录名: " dirname
				read -e -p "请输入权限 (如 755): " perm
				chmod "$perm" "$dirname" && echo "权限已修改" || echo "修改失败"
				send_stats "修改目录权限"
				;;
			4)  # 重命名目录
				read -e -p "请输入当前目录名: " current_name
				read -e -p "请输入新目录名: " new_name
				mv "$current_name" "$new_name" && echo "目录已重命名" || echo "重命名失败"
				send_stats "重命名目录"
				;;
			5)  # 删除目录
				read -e -p "请输入要删除的目录名: " dirname
				rm -rf "$dirname" && echo "目录已删除" || echo "删除失败"
				send_stats "删除目录"
				;;
			6)  # 返回上一级选单目录
				cd ..
				send_stats "返回上一级选单目录"
				;;
			11) # 创建文件
				read -e -p "请输入要创建的文件名: " filename
				touch "$filename" && echo "文件已创建" || echo "创建失败"
				send_stats "创建文件"
				;;
			12) # 编辑文件
				read -e -p "请输入要编辑的文件名: " filename
				install nano
				nano "$filename"
				send_stats "编辑文件"
				;;
			13) # 修改文件权限
				read -e -p "请输入文件名: " filename
				read -e -p "请输入权限 (如 755): " perm
				chmod "$perm" "$filename" && echo "权限已修改" || echo "修改失败"
				send_stats "修改文件权限"
				;;
			14) # 重命名文件
				read -e -p "请输入当前文件名: " current_name
				read -e -p "请输入新文件名: " new_name
				mv "$current_name" "$new_name" && echo "文件已重命名" || echo "重命名失败"
				send_stats "重命名文件"
				;;
			15) # 删除文件
				read -e -p "请输入要删除的文件名: " filename
				rm -f "$filename" && echo "文件已删除" || echo "删除失败"
				send_stats "删除文件"
				;;
			21) # 压缩文件/目录
				read -e -p "请输入要压缩的文件/目录名: " name
				install tar
				tar -czvf "$name.tar.gz" "$name" && echo "已压缩为 $name.tar.gz" || echo "压缩失败"
				send_stats "压缩文件/目录"
				;;
			22) # 解压文件/目录
				read -e -p "请输入要解压的文件名 (.tar.gz): " filename
				install tar
				tar -xzvf "$filename" && echo "已解压 $filename" || echo "解压失败"
				send_stats "解压文件/目录"
				;;

			23) # 移动文件或目录
				read -e -p "请输入要移动的文件或目录路径: " src_path
				if [ ! -e "$src_path" ]; then
					echo "错误: 文件或目录不存在。"
					send_stats "移动文件或目录失败: 文件或目录不存在"
					continue
				fi

				read -e -p "请输入目标路径 (包括新文件名或目录名): " dest_path
				if [ -z "$dest_path" ]; then
					echo "错误: 请输入目标路径。"
					send_stats "移动文件或目录失败: 目标路径未指定"
					continue
				fi

				mv "$src_path" "$dest_path" && echo "文件或目录已移动到 $dest_path" || echo "移动文件或目录失败"
				send_stats "移动文件或目录"
				;;


		   24) # 复制文件目录
				read -e -p "请输入要复制的文件或目录路径: " src_path
				if [ ! -e "$src_path" ]; then
					echo "错误: 文件或目录不存在。"
					send_stats "复制文件或目录失败: 文件或目录不存在"
					continue
				fi

				read -e -p "请输入目标路径 (包括新文件名或目录名): " dest_path
				if [ -z "$dest_path" ]; then
					echo "错误: 请输入目标路径。"
					send_stats "复制文件或目录失败: 目标路径未指定"
					continue
				fi

				# 使用 -r 选项以递归方式复制目录
				cp -r "$src_path" "$dest_path" && echo "文件或目录已复制到 $dest_path" || echo "复制文件或目录失败"
				send_stats "复制文件或目录"
				;;


			 25) # 传送文件至远端服务器
				read -e -p "请输入要传送的文件路径: " file_to_transfer
				if [ ! -f "$file_to_transfer" ]; then
					echo "错误: 文件不存在。"
					send_stats "传送文件失败: 文件不存在"
					continue
				fi

				kj_ssh_read_host_user_port "请输入远端服务器IP: " "请输入远端服务器用户名 (默认root): " "请输入登录端口 (默认22): " "root" "22"
				local remote_ip="$KJ_SSH_HOST"
				local remote_user="$KJ_SSH_USER"
				local remote_port="$KJ_SSH_PORT"

				kj_ssh_read_password "请输入远端服务器密码: "
				local remote_password="$KJ_SSH_PASSWORD"

				# 清除已知主机的旧条目
				ssh-keygen -f "/root/.ssh/known_hosts" -R "$remote_ip"
				sleep 2  # 等待时间

				# 使用scp传输文件
				scp -P "$remote_port" -o StrictHostKeyChecking=no "$file_to_transfer" "$remote_user@$remote_ip:/home/" <<EOF
$remote_password
EOF

				if [ $? -eq 0 ]; then
					echo "文件已传送至远程服务器home目录。"
					send_stats "文件传送成功"
				else
					echo "文件传送失败。"
					send_stats "文件传送失败"
				fi

				break_end
				;;



			0)  # 返回上一级选单
				send_stats "返回上一级选单菜单"
				break
				;;
			*)  # 处理无效输入
				echo "无效的选择，请重新输入"
				send_stats "无效选择"
				;;
		esac
	done
}






cluster_python3() {
	install python3 python3-paramiko
	cd ~/cluster/
	curl -sS -O ${gh_proxy}raw.githubusercontent.com/riwi/python-for-vps/main/cluster/$py_task
	python3 ~/cluster/$py_task
}


# ================================================================
# 批量在多台服务器上执行命令
# ================================================================
# 功能: 从 ~/cluster/servers.py 读取服务器列表，批量执行指定命令
# 参数: $1 - 要在远程服务器执行的命令
# 返回: 无
# 服务器配置格式 (servers.py):
#   servers = [
#       {"name": "服务器名", "hostname": "IP地址", "port": 端口, 
#        "username": "用户名", "password": "密码"},
#       ...
#   ]
# 流程:
#   1. 安装sshpass依赖
#   2. 读取并解析服务器配置
#   3. 逐个连接服务器并执行命令
# ================================================================
run_commands_on_servers() {

	install sshpass

	local SERVERS_FILE="$HOME/cluster/servers.py"
	local SERVERS=""
	
	# 便携式提取服务器信息（替代 grep -oP）
	while IFS= read -r line; do
		if echo "$line" | grep -q '"name"'; then
			_name=$(echo "$line" | sed -n 's/.*"name": "\([^"]*\)".*/\1/p')
			_hostname=$(echo "$line" | sed -n 's/.*"hostname": "\([^"]*\)".*/\1/p')
			_port=$(echo "$line" | sed -n 's/.*"port": \([^,]*\).*/\1/p')
			_username=$(echo "$line" | sed -n 's/.*"username": "\([^"]*\)".*/\1/p')
			_password=$(echo "$line" | sed -n 's/.*"password": "\([^"]*\)".*/\1/p')
			SERVERS="$SERVERS$_name"$'\n'"$_hostname"$'\n'"$_port"$'\n'"$_username"$'\n'"$_password"$'\n'
		fi
	done < "$SERVERS_FILE"

	# 将提取的信息转换为数组
	IFS=$'\n' read -r -d '' -a SERVER_ARRAY <<< "$SERVERS"

	# 遍历服务器并执行命令
	for ((i=0; i<${#SERVER_ARRAY[@]}; i+=5)); do
		local name=${SERVER_ARRAY[i]}
		local hostname=${SERVER_ARRAY[i+1]}
		local port=${SERVER_ARRAY[i+2]}
		local username=${SERVER_ARRAY[i+3]}
		local password=${SERVER_ARRAY[i+4]}
		echo
		echo -e "${rw_huang}连接到 $name ($hostname)...${rw_lv}"
		# 使用sshpass自动输入密码，通过SSH在远程服务器执行命令（旧版本，无-t参数）
		# sshpass -p "$password" ssh -o StrictHostKeyChecking=no "$username@$hostname" -p "$port" "$1"
		# 使用sshpass自动输入密码，通过SSH在远程服务器执行命令
		# 参数说明：
		#   -p "$password": 自动提供SSH密码
		#   -t: 强制分配伪终端（支持交互式命令和sudo等需要终端的操作）
		#   -o StrictHostKeyChecking=no: 跳过主机密钥检查，避免首次连接提示
		sshpass -p "$password" ssh -t -o StrictHostKeyChecking=no "$username@$hostname" -p "$port" "$1"
	done
	echo
	break_end

}



basic_settings_menu() {
  while true; do
    clear
    send_stats "基础设置"
    echo -e "${rw_huang}基础设置${rw_lv}"
    echo -e "${rw_cheng}------------------------${rw_lv}"
    echo ""
    echo -e "${rw_huang}请选择操作:${rw_lv}"
    echo -e "${rw_huang}1.   ${rw_lv}${rw_lv}设置脚本启动快捷键${rw_lv}"
    echo -e "${rw_huang}2.   ${rw_lv}${rw_lv}修改登录密码${rw_lv}"
    echo -e "${rw_huang}3.   ${rw_lv}${rw_lv}用户密码登录模式${rw_lv}"
    echo -e "${rw_huang}4.   ${rw_lv}${rw_lv}安装Python指定版本${rw_lv}"
    echo -e "${rw_huang}5.   ${rw_lv}${rw_lv}开放所有端口${rw_lv}"
    echo -e "${rw_cheng}------------------------${rw_lv}"
    echo -e "${rw_huang}0.   ${rw_lv}${rw_lv}返回上级菜单${rw_lv}"
    echo -e "${rw_cheng}------------------------${rw_lv}"
    read -e -p "请输入你的选择: " basic_choice

    case $basic_choice in
      1)
        while true; do
          clear
          read -e -p "请输入你的快捷按键（输入0退出）: " kuaijiejian
          if [ "$kuaijiejian" == "0" ]; then
            break
          fi
          find /usr/local/bin/ -type l -exec bash -c 'test "$(readlink -f {})" = "/usr/local/bin/r" && rm -f {}' \;
          if [ "$kuaijiejian" != "k" ]; then
            ln -sf /usr/local/bin/r /usr/local/bin/$kuaijiejian
          fi
          ln -sf /usr/local/bin/r /usr/bin/$kuaijiejian > /dev/null 2>&1
          echo "快捷键已设置"
          send_stats "脚本快捷键已设置"
          break
        done
        break_end
        ;;

      2)
        clear
        send_stats "设置你的登录密码"
        echo "设置你的登录密码"
        passwd
        break_end
        ;;

      3)
        clear
        add_sshpasswd
        break_end
        ;;

      4)
        clear
        send_stats "py版本管理"
        echo "python版本管理"
        echo "视频介绍: https://www.bilibili.com/video/BV1Pm42157cK?t=0.1"
        echo -e "${rw_cheng}---------------------------------------${rw_lv}"
        echo "该功能可无缝安装python官方支持的任何版本！"
        local VERSION=$(python3 -V 2>&1 | awk '{print $2}')
        echo -e "当前python版本号: ${rw_huang}$VERSION${rw_lv}"
        echo -e "${rw_cheng}------------${rw_lv}"
        echo "推荐版本:  3.12    3.11    3.10    3.9    3.8    2.7"
        echo "查询更多版本: https://www.python.org/downloads/"
        echo -e "${rw_cheng}------------${rw_lv}"
        read -e -p "输入你要安装的python版本号（输入0退出）: " py_new_v

        if [[ "$py_new_v" == "0" ]]; then
          send_stats "脚本PY管理"
          break_end
          continue
        fi

        if ! grep -q 'export PYENV_ROOT="\$HOME/.pyenv"' ~/.bashrc; then
          if command -v yum &>/dev/null; then
            yum update -y && yum install git -y
            yum groupinstall "Development Tools" -y
            yum install openssl-devel bzip2-devel libffi-devel ncurses-devel zlib-devel readline-devel sqlite-devel xz-devel findutils -y

            curl -O https://www.openssl.org/source/openssl-1.1.1u.tar.gz
            tar -xzf openssl-1.1.1u.tar.gz
            cd openssl-1.1.1u
            ./config --prefix=/usr/local/openssl --openssldir=/usr/local/openssl shared zlib
            make
            make install
            echo "/usr/local/openssl/lib" > /etc/ld.so.conf.d/openssl-1.1.1u.conf
            ldconfig -v
            cd ..

            export LDFLAGS="-L/usr/local/openssl/lib"
            export CPPFLAGS="-I/usr/local/openssl/include"
            export PKG_CONFIG_PATH="/usr/local/openssl/lib/pkgconfig"

          elif command -v apt &>/dev/null; then
            apt update -y && apt install git -y
            apt install build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev libgdbm-dev libnss3-dev libedit-dev -y
          elif command -v apk &>/dev/null; then
            apk update && apk add git
            apk add --no-cache bash gcc musl-dev libffi-dev openssl-dev bzip2-dev zlib-dev readline-dev sqlite-dev libc6-compat linux-headers make xz-dev build-base  ncurses-dev
          else
            echo "未知的包管理器!"
            break_end
            continue
          fi

          curl https://pyenv.run | bash
          cat >> ~/.bashrc << EOF

export PYENV_ROOT="\$HOME/.pyenv"
if [[ -d "\$PYENV_ROOT/bin" ]]; then
  export PATH="\$PYENV_ROOT/bin:\$PATH"
fi
eval "\$(pyenv init --path)"
eval "\$(pyenv init -)"
eval "\$(pyenv virtualenv-init -)"

EOF

        fi

        sleep 1
        source ~/.bashrc
        sleep 1
        pyenv install $py_new_v
        pyenv global $py_new_v

        rm -rf /tmp/python-build.*
        rm -rf $(pyenv root)/cache/*

        local VERSION=$(python -V 2>&1 | awk '{print $2}')
        echo -e "当前python版本号: ${rw_huang}$VERSION${rw_lv}"
        send_stats "脚本PY版本切换"
        break_end
        ;;

      5)
        clear
        root_use
        send_stats "开放端口"
        iptables_open
        remove iptables-persistent ufw firewalld iptables-services > /dev/null 2>&1
        echo "端口已全部开放"
        break_end
        ;;

      0)
        break
        ;;

      *)
        echo -e "${rw_hong}无效的输入!${rw_lv}"
        ;;
    esac
  done
}

# ================================================================
# 服务器集群控制函数
# ================================================================

# ── 集群配置解析器 ──
# 读取 ~/cluster/servers.conf（KEY=VALUE 简单格式，每行一台），输出到全局数组
# 格式: name|ip|port|user   （#开头为注释，空行跳过）
# 全局变量:
#   _CLUSTER_COUNT  — 服务器数量
#   _CLUSTER_NAME[]  _CLUSTER_IP[]  _CLUSTER_PORT[]  _CLUSTER_USER[]
_cluster_load() {
	_CLUSTER_COUNT=0
	_CLUSTER_NAME=()
	_CLUSTER_IP=()
	_CLUSTER_PORT=()
	_CLUSTER_USER=()
	local _f="${HOME}/cluster/servers.conf"
	[ ! -f "$_f" ] && return 0
	local _line _n _ip _p _u
	while IFS= read -r _line || [ -n "$_line" ]; do
		_line="${_line%%#*}"          # 去注释
		_line="${_line#"${_line%%[![:space:]]*}"}"  # 去前导空格
		_line="${_line%"${_line##*[![:space:]]}"}"  # 去尾随空格
		[ -z "$_line" ] && continue
		IFS='|' read -r _n _ip _p _u <<< "$_line"
		[ -z "$_n" ] && continue
		_p="${_p:-22}"
		_u="${_u:-root}"
		_CLUSTER_NAME+=("$_n")
		_CLUSTER_IP+=("$_ip")
		_CLUSTER_PORT+=("$_p")
		_CLUSTER_USER+=("$_u")
		_CLUSTER_COUNT=$((_CLUSTER_COUNT + 1))
	done < "$_f"
}

# ── 保存单台服务器到配置 ──
_cluster_add_server() {
	local _n="$1" _ip="$2" _p="$3" _u="$4"
	mkdir -p "${HOME}/cluster"
	local _f="${HOME}/cluster/servers.conf"
	[ ! -f "$_f" ] && echo "# 集群服务器配置 格式: name|ip|port|user" > "$_f"
	echo "${_n}|${_ip}|${_p}|${_u}" >> "$_f"
}

# ── 删除单台服务器 ──
_cluster_del_server() {
	local _n="$1"
	local _f="${HOME}/cluster/servers.conf"
	[ ! -f "$_f" ] && return 1
	# 用 awk 精确匹配行首 name|，跨平台兼容（BSD sed 不支持 \#分隔符）
	local _tmp="${_f}.tmp.$$"
	awk -v n="$_n" 'BEGIN{FS="|"} $1!=n' "$_f" > "$_tmp" && mv "$_tmp" "$_f"
}

# ── 通过 SSH 在单台服务器执行命令（带超时）──
# 用法: _cluster_ssh_exec <index> <command>
_cluster_ssh_exec() {
	local _idx="$1" _cmd="$2"
	[ "$_idx" -ge "$_CLUSTER_COUNT" ] 2>/dev/null && return 1
	ssh -o ConnectTimeout=8 -o StrictHostKeyChecking=no -o BatchMode=yes \
		-p "${_CLUSTER_PORT[$_idx]}" "${_CLUSTER_USER[$_idx]}@${_CLUSTER_IP[$_idx]}" "$_cmd" 2>&1
}

# ── 批量并发执行命令并汇总 ──
# 用法: _cluster_run_all <command>
# 依赖: _cluster_load 已调用
_cluster_run_all() {
	local _cmd="$1"
	local _i _tmpdir
	_tmpdir=$(mktemp -d)
	for _i in $(seq 0 $((_CLUSTER_COUNT - 1))); do
		(
			local _out
			_out=$(_cluster_ssh_exec "$_i" "$_cmd" 2>&1)
			printf '%s\n' "$_out" > "${_tmpdir}/${_i}.out"
		) &
	done
	wait
	for _i in $(seq 0 $((_CLUSTER_COUNT - 1))); do
		echo -e " ${rw_huang}[$((_i + 1))] ${_CLUSTER_NAME[$_i]} (${_CLUSTER_IP[$_i]})${rw_lv}"
		if [ -s "${_tmpdir}/${_i}.out" ]; then
			sed 's/^/   /' "${_tmpdir}/${_i}.out"
		else
			echo -e "   ${rw_lv}(无输出)${rw_lv}"
		fi
	done
	rm -rf "$_tmpdir"
}

linux_cluster() {
  mkdir -p ~/cluster
  while true; do
    clear
    send_stats "集群控制中心"

    # 加载配置
    _cluster_load
    # 兼容旧 servers.py: 如果存在旧文件但新文件不存在，提示迁移
    if [ "$_CLUSTER_COUNT" -eq 0 ] && [ -f ~/cluster/servers.py ] && [ ! -f ~/cluster/servers.conf ]; then
      echo -e " ${rw_huang}检测到旧配置 servers.py，建议迁移到新格式 servers.conf${rw_lv}"
      echo -e " ${rw_huang}可在选项 6「迁移旧配置」一键完成${rw_lv}"
      echo ""
    fi

    echo -e "${rw_cheng}━━━━━━━━━━━━  服务器集群控制  ━━━━━━━━━━━━${rw_lv}"
    echo -e " 集群服务器数量 ${rw_lv}${_CLUSTER_COUNT}${rw_lv} 台  配置文件 ${rw_huang}~/cluster/servers.conf${rw_lv}"
    echo ""
    echo -e " ${rw_cheng}──── 服务器管理${rw_lv}"
    echo -e " ${rw_huang}1${rw_lv}  添加服务器           ${rw_huang}2${rw_lv}  删除服务器"
    echo -e " ${rw_huang}3${rw_lv}  查看服务器列表       ${rw_huang}4${rw_lv}  测试连接"
    echo -e " ${rw_huang}5${rw_lv}  编辑服务器配置       ${rw_huang}6${rw_lv}  迁移旧 servers.py"
    echo ""
    echo -e " ${rw_cheng}──── 批量执行任务${rw_lv}"
    echo -e " ${rw_huang}11${rw_lv} 批量执行命令         ${rw_huang}12${rw_lv} 批量上传文件"
    echo -e " ${rw_huang}13${rw_lv} 批量下载文件         ${rw_huang}14${rw_lv} 批量安装软件"
    echo -e " ${rw_huang}15${rw_lv} 查看集群状态"
    echo ""
    echo -e " ${rw_cheng}──── 集群监控${rw_lv}"
    echo -e " ${rw_huang}21${rw_lv} 实时监控             ${rw_huang}22${rw_lv} 资源统计"
    echo -e " ${rw_huang}23${rw_lv} 告警设置"
    echo ""
    echo -e " ${rw_cheng}────────────────────────────────────────${rw_lv}"
    echo -e " ${rw_huang}0${rw_lv}  返回主菜单"
    echo -e " ${rw_cheng}────────────────────────────────────────${rw_lv}"
    read -e -p " 请选择: " sub_choice

    case $sub_choice in
      1)
        clear
        send_stats "添加服务器"
        echo -e "${rw_huang}添加服务器到集群${rw_lv}"
        echo -e "${rw_cheng}------------------------${rw_lv}"
        echo ""
        read -e -p "请输入服务器名称 [示例:web01]: " server_name
        read -e -p "请输入服务器IP地址 [示例:192.168.1.10]: " server_ip
        read -e -p "请输入SSH端口 [默认:22]: " ssh_port
        ssh_port=${ssh_port:-22}
        read -e -p "请输入用户名 [默认:root]: " ssh_user
        ssh_user=${ssh_user:-root}

        if [ -z "$server_name" ] || [ -z "$server_ip" ]; then
          red "服务器名称和IP不能为空"
          break_end
          continue
        fi
        # 检查重名
        _cluster_load
        local _i
        for _i in $(seq 0 $((_CLUSTER_COUNT - 1))); do
          if [ "${_CLUSTER_NAME[$_i]}" = "$server_name" ]; then
            red "服务器名称 $server_name 已存在"
            break_end
            continue 2
          fi
        done
        _cluster_add_server "$server_name" "$server_ip" "$ssh_port" "$ssh_user"
        green "✓ 服务器 $server_name 添加成功"
        break_end
        ;;

      2)
        clear
        send_stats "删除服务器"
        echo -e "${rw_huang}从集群删除服务器${rw_lv}"
        echo -e "${rw_cheng}------------------------${rw_lv}"
        echo ""
        _cluster_load
        if [ $_CLUSTER_COUNT -eq 0 ]; then
          red "没有服务器配置"
          break_end
          continue
        fi
        local _i
        for _i in $(seq 0 $((_CLUSTER_COUNT - 1))); do
          echo -e " ${rw_huang}$((_i + 1)).${rw_lv} ${_CLUSTER_NAME[$_i]} (${_CLUSTER_IP[$_i]})"
        done
        echo ""
        read -e -p "请输入要删除的服务器名称或编号: " server_name
        [ -z "$server_name" ] && { red "不能为空"; break_end; continue; }
        # 编号删除
        if [[ "$server_name" =~ ^[0-9]+$ ]] && [ "$server_name" -ge 1 ] 2>/dev/null && [ "$server_name" -le $_CLUSTER_COUNT ] 2>/dev/null; then
          server_name="${_CLUSTER_NAME[$((server_name - 1))]}"
        fi
        _cluster_del_server "$server_name"
        green "✓ 服务器 $server_name 已删除"
        break_end
        ;;

      3)
        clear
        send_stats "查看服务器列表"
        echo -e "${rw_huang}集群服务器列表${rw_lv}"
        echo -e "${rw_cheng}------------------------${rw_lv}"
        echo ""
        _cluster_load
        if [ $_CLUSTER_COUNT -eq 0 ]; then
          red "没有服务器配置"
          break_end
          continue
        fi
        printf "  %-4s %-15s %-18s %-8s %-12s\n" "序号" "名称" "IP" "端口" "用户"
        echo "  ──────────────────────────────────────────────────"
        local _i
        for _i in $(seq 0 $((_CLUSTER_COUNT - 1))); do
          printf "  ${rw_huang}%-4s${rw_lv} %-15s %-18s %-8s %-12s\n" \
            "$((_i + 1))" "${_CLUSTER_NAME[$_i]}" "${_CLUSTER_IP[$_i]}" "${_CLUSTER_PORT[$_i]}" "${_CLUSTER_USER[$_i]}"
        done
        echo ""
        break_end
        ;;

      4)
        clear
        send_stats "测试连接"
        echo -e "${rw_huang}测试集群服务器连接${rw_lv}"
        echo -e "${rw_cheng}------------------------${rw_lv}"
        echo ""
        _cluster_load
        if [ $_CLUSTER_COUNT -eq 0 ]; then
          red "没有服务器配置"
          break_end
          continue
        fi
        echo -e "${rw_huang}正在测试连接（SSH + Ping 双重检测）...${rw_lv}"
        local _i _ok=0 _fail=0
        for _i in $(seq 0 $((_CLUSTER_COUNT - 1))); do
          local _ip="${_CLUSTER_IP[$_i]}" _name="${_CLUSTER_NAME[$_i]}"
          printf "  %-15s (%-15s): " "$_name" "$_ip"
          # 先 ping
          if ! ping -c 1 -W 2 "$_ip" &>/dev/null; then
            echo -e "${rw_hong}✗ Ping 不通${rw_lv}"
            _fail=$((_fail + 1))
            continue
          fi
          # 再测 SSH 端口
          if _cluster_ssh_exec "$_i" "echo ok" 2>/dev/null | grep -q "ok"; then
            echo -e "${rw_lv}✓ SSH 可连接${rw_lv}"
            _ok=$((_ok + 1))
          else
            echo -e "${rw_huang}△ Ping 通但 SSH 不通（需配免密或检查 sshd）${rw_lv}"
            _fail=$((_fail + 1))
          fi
        done
        echo ""
        echo -e " 汇总: ${rw_lv}SSH 可连 ${_ok}${rw_lv} 台    ${rw_hong}不可连 ${_fail}${rw_lv} 台"
        echo ""
        break_end
        ;;

      5)
        clear
        send_stats "编辑服务器配置"
        echo -e "${rw_huang}编辑服务器配置文件${rw_lv}"
        echo -e "${rw_cheng}------------------------${rw_lv}"
        echo ""
        local _f="${HOME}/cluster/servers.conf"
        [ ! -f "$_f" ] && echo "# 集群服务器配置 格式: name|ip|port|user" > "$_f"
        echo -e " ${rw_huang}格式说明: 每行一台，字段用 | 分隔${rw_lv}"
        echo -e " ${rw_huang}示例: web01|192.168.1.10|22|root${rw_lv}"
        echo -e " ${rw_huang}# 开头为注释${rw_lv}"
        echo ""
        if command -v vim &>/dev/null; then
          vim "$_f"
        elif command -v nano &>/dev/null; then
          nano "$_f"
        else
          echo -e "${rw_hong}未找到编辑器 (vim/nano)${rw_lv}"
        fi
        break_end
        ;;

      6)
        # ── 迁移旧 servers.py 到 servers.conf ──
        clear
        send_stats "迁移旧配置"
        echo -e "${rw_huang}迁移旧 servers.py 到新 servers.conf${rw_lv}"
        echo -e "${rw_cheng}------------------------${rw_lv}"
        echo ""
        if [ ! -f ~/cluster/servers.py ]; then
          yellow "未找到旧配置 servers.py，无需迁移"
          break_end
          continue
        fi
        if [ -f ~/cluster/servers.conf ] && [ -s ~/cluster/servers.conf ]; then
          echo -e "${rw_huang}servers.conf 已存在内容，将备份后合并${rw_lv}"
          cp -a ~/cluster/servers.conf ~/cluster/servers.conf.bak.$(date +%Y%m%d%H%M%S)
        fi
        # 用 python 解析旧 JSON-like 格式更可靠
        local _migrated=0
        python3 - <<'PYEOF' 2>/dev/null
import re, os
src = os.path.expanduser('~/cluster/servers.py')
dst = os.path.expanduser('~/cluster/servers.conf')
content = open(src, encoding='utf-8', errors='ignore').read()
# 提取 {"name": "...", "ip": "...", "port": N, "user": "..."}
pattern = r'\{\s*"name":\s*"([^"]+)"\s*,\s*"ip":\s*"([^"]+)"\s*,\s*"port":\s*(\d+)\s*,\s*"user":\s*"([^"]+)"\s*\}'
items = re.findall(pattern, content)
with open(dst, 'a', encoding='utf-8') as f:
    for n, ip, p, u in items:
        f.write(f'{n}|{ip}|{p}|{u}\n')
print(len(items))
PYEOF
        _migrated=$?
        if [ "$_migrated" -gt 0 ]; then
          green "✓ 已迁移 ${_migrated} 台服务器到 servers.conf"
          echo -e " ${rw_huang}旧文件已保留为 servers.py（可手动删除）${rw_lv}"
        else
          yellow "未解析到服务器记录，或 python3 不可用"
          echo -e " ${rw_huang}建议手动编辑 servers.conf${rw_lv}"
        fi
        break_end
        ;;

      11)
        clear
        send_stats "批量执行命令"
        echo -e "${rw_huang}批量在集群服务器执行命令${rw_lv}"
        echo -e "${rw_cheng}------------------------${rw_lv}"
        echo ""
        _cluster_load
        if [ $_CLUSTER_COUNT -eq 0 ]; then
          red "没有服务器配置"
          break_end
          continue
        fi
        read -e -p "请输入要执行的命令: " cmd
        if [ -z "$cmd" ]; then
          red "命令不能为空"
          break_end
          continue
        fi
        echo -e "${rw_huang}正在并发执行: $cmd${rw_lv}"
        echo ""
        _cluster_run_all "$cmd"
        echo ""
        break_end
        ;;

      12)
        clear
        send_stats "批量上传文件"
        echo -e "${rw_huang}批量上传文件到集群服务器${rw_lv}"
        echo -e "${rw_cheng}------------------------${rw_lv}"
        echo ""
        _cluster_load
        if [ $_CLUSTER_COUNT -eq 0 ]; then
          red "没有服务器配置"
          break_end
          continue
        fi
        read -e -p "请输入本地文件/目录路径: " local_file
        read -e -p "请输入远程目标路径: " remote_file
        if [ -z "$local_file" ] || [ -z "$remote_file" ]; then
          red "路径不能为空"
          break_end
          continue
        fi
        if [ ! -e "$local_file" ]; then
          red "本地文件/目录不存在"
          break_end
          continue
        fi
        # 目录用 -r
        local _scp_opt=""
        [ -d "$local_file" ] && _scp_opt="-r"
        echo -e "${rw_huang}正在并发上传...${rw_lv}"
        local _i _ok=0 _fail=0
        local _tmpdir
        _tmpdir=$(mktemp -d)
        for _i in $(seq 0 $((_CLUSTER_COUNT - 1))); do
          (
            scp -o ConnectTimeout=8 -o StrictHostKeyChecking=no -o BatchMode=yes $_scp_opt \
              -P "${_CLUSTER_PORT[$_i]}" "$local_file" \
              "${_CLUSTER_USER[$_i]}@${_CLUSTER_IP[$_i]}:$remote_file" >/dev/null 2>&1 \
              && echo ok > "${_tmpdir}/${_i}.st" || echo fail > "${_tmpdir}/${_i}.st"
          ) &
        done
        wait
        for _i in $(seq 0 $((_CLUSTER_COUNT - 1))); do
          printf "  %-15s: " "${_CLUSTER_NAME[$_i]}"
          if [ "$(cat "${_tmpdir}/${_i}.st")" = "ok" ]; then
            echo -e "${rw_lv}✓ 成功${rw_lv}"
            _ok=$((_ok + 1))
          else
            echo -e "${rw_hong}✗ 失败${rw_lv}"
            _fail=$((_fail + 1))
          fi
        done
        rm -rf "$_tmpdir"
        echo ""
        echo -e " 汇总: ${rw_lv}成功 ${_ok}${rw_lv}    ${rw_hong}失败 ${_fail}${rw_lv}"
        echo ""
        break_end
        ;;

      13)
        # ── 批量下载文件 ──
        clear
        send_stats "批量下载文件"
        echo -e "${rw_huang}批量从集群服务器下载文件${rw_lv}"
        echo -e "${rw_cheng}------------------------${rw_lv}"
        echo ""
        _cluster_load
        if [ $_CLUSTER_COUNT -eq 0 ]; then
          red "没有服务器配置"
          break_end
          continue
        fi
        read -e -p "请输入远程文件路径: " remote_file
        read -e -p "请输入本地保存目录 [默认:~/cluster/downloads]: " local_dir
        local_dir="${local_dir:-${HOME}/cluster/downloads}"
        if [ -z "$remote_file" ]; then
          red "远程文件路径不能为空"
          break_end
          continue
        fi
        mkdir -p "$local_dir"
        echo -e "${rw_huang}正在并发下载到 ${local_dir} ...${rw_lv}"
        local _i _ok=0 _fail=0
        local _tmpdir
        _tmpdir=$(mktemp -d)
        for _i in $(seq 0 $((_CLUSTER_COUNT - 1))); do
          (
            local _name="${_CLUSTER_NAME[$_i]}"
            # 文件名加服务器名后缀避免覆盖
            local _base
            _base=$(basename "$remote_file")
            scp -o ConnectTimeout=8 -o StrictHostKeyChecking=no -o BatchMode=yes \
              -P "${_CLUSTER_PORT[$_i]}" \
              "${_CLUSTER_USER[$_i]}@${_CLUSTER_IP[$_i]}:$remote_file" \
              "${local_dir}/${_name}_${_base}" >/dev/null 2>&1 \
              && echo ok > "${_tmpdir}/${_i}.st" || echo fail > "${_tmpdir}/${_i}.st"
          ) &
        done
        wait
        for _i in $(seq 0 $((_CLUSTER_COUNT - 1))); do
          printf "  %-15s: " "${_CLUSTER_NAME[$_i]}"
          if [ "$(cat "${_tmpdir}/${_i}.st")" = "ok" ]; then
            echo -e "${rw_lv}✓ 已下载到 ${local_dir}/${_CLUSTER_NAME[$_i]}_*${rw_lv}"
            _ok=$((_ok + 1))
          else
            echo -e "${rw_hong}✗ 失败${rw_lv}"
            _fail=$((_fail + 1))
          fi
        done
        rm -rf "$_tmpdir"
        echo ""
        echo -e " 汇总: ${rw_lv}成功 ${_ok}${rw_lv}    ${rw_hong}失败 ${_fail}${rw_lv}"
        echo ""
        break_end
        ;;

      14)
        # ── 批量安装软件 ──
        clear
        send_stats "批量安装软件"
        echo -e "${rw_huang}批量在集群服务器安装软件${rw_lv}"
        echo -e "${rw_cheng}------------------------${rw_lv}"
        echo ""
        _cluster_load
        if [ $_CLUSTER_COUNT -eq 0 ]; then
          red "没有服务器配置"
          break_end
          continue
        fi
        echo -e " ${rw_huang}支持 apt/dnf/yum 自动识别${rw_lv}"
        echo ""
        read -e -p "请输入软件包名（多个用空格分隔）: " pkgs
        if [ -z "$pkgs" ]; then
          red "软件包名不能为空"
          break_end
          continue
        fi
        echo -e "${rw_huang}正在并发安装: $pkgs${rw_lv}"
        echo ""
        # 远程执行: 自动判断包管理器
        local _remote_cmd
        _remote_cmd="if command -v apt-get >/dev/null 2>&1; then DEBIAN_FRONTEND=noninteractive apt-get update -y && apt-get install -y $pkgs; elif command -v dnf >/dev/null 2>&1; then dnf install -y $pkgs; elif command -v yum >/dev/null 2>&1; then yum install -y $pkgs; else echo '未识别的包管理器'; exit 1; fi"
        _cluster_run_all "$_remote_cmd"
        echo ""
        break_end
        ;;

      15)
        # ── 查看集群状态（增强版：CPU/内存/磁盘/负载/uptime）──
        clear
        send_stats "查看集群状态"
        echo -e "${rw_huang}集群服务器状态${rw_lv}"
        echo -e "${rw_cheng}------------------------${rw_lv}"
        echo ""
        _cluster_load
        if [ $_CLUSTER_COUNT -eq 0 ]; then
          red "没有服务器配置"
          break_end
          continue
        fi
        echo -e "${rw_huang}正在并发采集状态...${rw_lv}"
        echo ""
        # 远程采集脚本：输出 TSV 格式  status|uptime|load|cpu%|mem_used|mem_total|disk_used|disk_total
        local _stat_cmd
        _stat_cmd='
_out=""
ping -c 1 -W 1 127.0.0.1 >/dev/null 2>&1 || true
# uptime
_up=$(uptime -p 2>/dev/null | sed "s/up //" || echo "?")
# load avg
_load=$(cat /proc/loadavg 2>/dev/null | awk "{print \$1,\$2,\$3}" || echo "? ? ?")
# CPU 使用率（采样1秒）
_cpu=$(top -bn1 2>/dev/null | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk "{print 100-\$1}" || echo "?")
# 内存
_mem_u=$(free -m 2>/dev/null | awk "/Mem:/{print \$3}")
_mem_t=$(free -m 2>/dev/null | awk "/Mem:/{print \$2}")
# 磁盘根分区
_dsk_u=$(df -m / 2>/dev/null | awk "NR==2{print \$3}")
_dsk_t=$(df -m / 2>/dev/null | awk "NR==2{print \$2}")
printf "OK\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" "$_up" "$_load" "$_cpu" "$_mem_u" "$_mem_t" "$_dsk_u" "$_dsk_t"
'
        local _tmpdir
        _tmpdir=$(mktemp -d)
        local _i
        for _i in $(seq 0 $((_CLUSTER_COUNT - 1))); do
          (
            _cluster_ssh_exec "$_i" "$_stat_cmd" > "${_tmpdir}/${_i}.out" 2>&1
          ) &
        done
        wait
        # 表格输出
        printf "  %-15s %-8s %-18s %-10s %-12s %-12s %-10s\n" "服务器" "状态" "负载(1/5/15)" "CPU%" "内存(M)" "磁盘(M)" "Uptime"
        echo "  ──────────────────────────────────────────────────────────────────────────"
        for _i in $(seq 0 $((_CLUSTER_COUNT - 1))); do
          local _name="${_CLUSTER_NAME[$_i]}" _ip="${_CLUSTER_IP[$_i]}"
          local _line _status="离线" _up="-" _load="-" _cpu="-" _mem="-" _dsk="-"
          if [ -s "${_tmpdir}/${_i}.out" ]; then
            _line=$(head -1 "${_tmpdir}/${_i}.out")
            if [[ "$_line" == OK* ]]; then
              _status="在线"
              IFS=$'\t' read -r _ _up _load _cpu _mem_u _mem_t _dsk_u _dsk_t <<< "$_line"
              [ -n "$_mem_u" ] && [ -n "$_mem_t" ] && _mem="${_mem_u}/${_mem_t}"
              [ -n "$_dsk_u" ] && [ -n "$_dsk_t" ] && _dsk="${_dsk_u}/${_dsk_t}"
            fi
          fi
          local _color="${rw_hong}"
          [ "$_status" = "在线" ] && _color="${rw_lv}"
          printf "  ${rw_huang}%-15s${rw_lv} ${_color}%-8s${rw_lv} %-18s %-10s %-12s %-12s %-10s\n" \
            "$_name" "$_status" "$_load" "${_cpu}%" "$_mem" "$_dsk" "$_up"
        done
        rm -rf "$_tmpdir"
        echo ""
        break_end
        ;;

      21)
        # ── 实时监控（每 N 秒刷新集群状态）──
        clear
        send_stats "实时监控"
        echo -e "${rw_huang}集群服务器实时监控${rw_lv}"
        echo -e "${rw_cheng}------------------------${rw_lv}"
        echo ""
        _cluster_load
        if [ $_CLUSTER_COUNT -eq 0 ]; then
          red "没有服务器配置"
          break_end
          continue
        fi
        read -e -p "刷新间隔秒数 [默认:5]: " _interval
        _interval="${_interval:-5}"
        if ! [[ "$_interval" =~ ^[0-9]+$ ]] || [ "$_interval" -lt 1 ]; then
          red "无效间隔"
          break_end
          continue
        fi
        echo -e " ${rw_huang}每 ${_interval} 秒刷新一次，按 Ctrl+C 退出${rw_lv}"
        echo ""
        read -e -p "按回车开始监控..." _dummy < /dev/tty
        while true; do
          clear
          echo -e "${rw_cheng}━━━━━━ 集群实时监控 ($(date '+%H:%M:%S')) ━━━━━━${rw_lv}"
          echo ""
          local _i
          local _tmpdir
          _tmpdir=$(mktemp -d)
          for _i in $(seq 0 $((_CLUSTER_COUNT - 1))); do
            (
              _cluster_ssh_exec "$_i" "uptime; free -m | grep Mem; df -m / | tail -1" > "${_tmpdir}/${_i}.out" 2>&1
            ) &
          done
          wait
          printf "  %-15s %-8s %-22s %-12s %-15s\n" "服务器" "状态" "负载" "内存(M)" "磁盘"
          echo "  ────────────────────────────────────────────────────────────"
          for _i in $(seq 0 $((_CLUSTER_COUNT - 1))); do
            local _name="${_CLUSTER_NAME[$_i]}"
            if [ -s "${_tmpdir}/${_i}.out" ]; then
              local _load _mem _dsk
              _load=$(grep -oE 'load average:.*' "${_tmpdir}/${_i}.out" | sed 's/load average: //' || echo "-")
              _mem=$(grep '^Mem:' "${_tmpdir}/${_i}.out" | awk '{printf "%s/%s", $3, $2}' || echo "-")
              _dsk=$(grep '^/' "${_tmpdir}/${_i}.out" | awk '{printf "%s%%", $5}' || echo "-")
              printf "  ${rw_huang}%-15s${rw_lv} ${rw_lv}%-8s${rw_lv} %-22s %-12s %-15s\n" "$_name" "在线" "$_load" "$_mem" "$_dsk"
            else
              printf "  ${rw_huang}%-15s${rw_lv} ${rw_hong}%-8s${rw_lv} %-22s %-12s %-15s\n" "$_name" "离线" "-" "-" "-"
            fi
          done
          rm -rf "$_tmpdir"
          echo ""
          echo -e " ${rw_huang}下次刷新: ${_interval} 秒后  (Ctrl+C 退出)${rw_lv}"
          sleep "$_interval"
        done
        ;;

      22)
        # ── 资源统计（汇总集群总资源）──
        clear
        send_stats "资源统计"
        echo -e "${rw_huang}集群服务器资源统计${rw_lv}"
        echo -e "${rw_cheng}------------------------${rw_lv}"
        echo ""
        _cluster_load
        if [ $_CLUSTER_COUNT -eq 0 ]; then
          red "没有服务器配置"
          break_end
          continue
        fi
        echo -e "${rw_huang}正在并发采集资源数据...${rw_lv}"
        echo ""
        local _stat_cmd
        _stat_cmd='
_cpu=$(nproc 2>/dev/null || echo 0)
_mem_t=$(free -m 2>/dev/null | awk "/Mem:/{print \$2}")
_mem_u=$(free -m 2>/dev/null | awk "/Mem:/{print \$3}")
_dsk_t=$(df -m / 2>/dev/null | awk "NR==2{print \$2}")
_dsk_u=$(df -m / 2>/dev/null | awk "NR==2{print \$3}")
_dsk_p=$(df / 2>/dev/null | awk "NR==2{print \$5}")
printf "%s\t%s\t%s\t%s\t%s\t%s\n" "$_cpu" "$_mem_t" "$_mem_u" "$_dsk_t" "$_dsk_u" "$_dsk_p"
'
        local _tmpdir
        _tmpdir=$(mktemp -d)
        local _i
        for _i in $(seq 0 $((_CLUSTER_COUNT - 1))); do
          (
            _cluster_ssh_exec "$_i" "$_stat_cmd" > "${_tmpdir}/${_i}.out" 2>&1
          ) &
        done
        wait
        # 明细表
        printf "  %-15s %-6s %-14s %-14s %-10s\n" "服务器" "CPU核" "内存(M)" "磁盘(M)" "磁盘用%"
        echo "  ──────────────────────────────────────────────────"
        local _tot_cpu=0 _tot_mem_t=0 _tot_mem_u=0 _tot_dsk_t=0 _tot_dsk_u=0 _alive=0
        for _i in $(seq 0 $((_CLUSTER_COUNT - 1))); do
          local _name="${_CLUSTER_NAME[$_i]}"
          if [ -s "${_tmpdir}/${_i}.out" ]; then
            local _cpu _mt _mu _dt _du _dp
            IFS=$'\t' read -r _cpu _mt _mu _dt _du _dp <<< "$(head -1 "${_tmpdir}/${_i}.out")"
            if [ -n "$_cpu" ] && [ "$_cpu" != "?" ]; then
              printf "  ${rw_huang}%-15s${rw_lv} %-6s %-14s %-14s %-10s\n" "$_name" "$_cpu" "${_mu}/${_mt}" "${_du}/${_dt}" "$_dp"
              _tot_cpu=$((_tot_cpu + _cpu))
              _tot_mem_t=$((_tot_mem_t + _mt))
              _tot_mem_u=$((_tot_mem_u + _mu))
              _tot_dsk_t=$((_tot_dsk_t + _dt))
              _tot_dsk_u=$((_tot_dsk_u + _du))
              _alive=$((_alive + 1))
            else
              printf "  ${rw_huang}%-15s${rw_lv} ${rw_hong}%-6s${rw_lv} %-14s %-14s %-10s\n" "$_name" "离线" "-" "-" "-"
            fi
          else
            printf "  ${rw_huang}%-15s${rw_lv} ${rw_hong}%-6s${rw_lv} %-14s %-14s %-10s\n" "$_name" "离线" "-" "-" "-"
          fi
        done
        rm -rf "$_tmpdir"
        echo ""
        echo -e " ${rw_cheng}── 集群资源汇总（${_alive}/${_CLUSTER_COUNT} 台在线）──${rw_lv}"
        printf "  总 CPU 核心: ${rw_huang}%s${rw_lv}    总内存: ${rw_huang}%s/%s M${rw_lv}    总磁盘: ${rw_huang}%s/%s M${rw_lv}\n" \
          "$_tot_cpu" "$_tot_mem_u" "$_tot_mem_t" "$_tot_dsk_u" "$_tot_dsk_t"
        if [ $_tot_mem_t -gt 0 ] 2>/dev/null; then
          local _mem_pct=$((_tot_mem_u * 100 / _tot_mem_t))
          echo -e "  内存使用率: ${rw_huang}${_mem_pct}%${rw_lv}"
        fi
        echo ""
        break_end
        ;;

      23)
        # ── 告警设置（配置 CPU/内存/磁盘 阈值，生成 cron 检测脚本）──
        clear
        send_stats "告警设置"
        echo -e "${rw_huang}集群告警设置${rw_lv}"
        echo -e "${rw_cheng}------------------------${rw_lv}"
        echo ""
        local _alert_conf="${HOME}/cluster/alert.conf"
        if [ -f "$_alert_conf" ]; then
          echo -e " ${rw_huang}当前告警配置:${rw_lv}"
          cat "$_alert_conf" | sed 's/^/   /'
          echo ""
        fi
        echo -e " ${rw_huang}设置阈值（留空使用默认值）${rw_lv}"
        read -e -p " CPU 使用率告警阈值% [默认:80]: " _cpu_thr
        _cpu_thr="${_cpu_thr:-80}"
        read -e -p " 内存使用率告警阈值% [默认:85]: " _mem_thr
        _mem_thr="${_mem_thr:-85}"
        read -e -p " 磁盘使用率告警阈值% [默认:90]: " _dsk_thr
        _dsk_thr="${_dsk_thr:-90}"
        read -e -p " 检查间隔分钟 [默认:5]: " _check_int
        _check_int="${_check_int:-5}"
        read -e -p " 告警日志路径 [默认:~/cluster/alert.log]: " _alert_log
        _alert_log="${_alert_log:-${HOME}/cluster/alert.log}"

        # 校验
        for _v in "$_cpu_thr" "$_mem_thr" "$_dsk_thr" "$_check_int"; do
          if ! [[ "$_v" =~ ^[0-9]+$ ]]; then
            red "阈值必须是数字"
            break_end
            continue 2
          fi
        done

        mkdir -p "${HOME}/cluster"
        cat > "$_alert_conf" << EOF
# 集群告警配置
CPU_THRESHOLD=$_cpu_thr
MEM_THRESHOLD=$_mem_thr
DSK_THRESHOLD=$_dsk_thr
CHECK_INTERVAL=$_check_int
ALERT_LOG=$_alert_log
EOF

        # 生成检测脚本
        local _check_script="${HOME}/cluster/alert_check.sh"
        cat > "$_check_script" << 'SCRIPT'
#!/bin/bash
# 集群告警检测脚本（由 riwi.sh 集群控制生成）
CONF="${HOME}/cluster/alert.conf"
[ -f "$CONF" ] || exit 0
source "$CONF"
LOG="${ALERT_LOG:-${HOME}/cluster/alert.log}"
_cluster_load() {
  _CLUSTER_COUNT=0
  _CLUSTER_NAME=(); _CLUSTER_IP=(); _CLUSTER_PORT=(); _CLUSTER_USER=()
  local _f="${HOME}/cluster/servers.conf"
  [ ! -f "$_f" ] && return 0
  while IFS= read -r _line || [ -n "$_line" ]; do
    _line="${_line%%#*}"
    [ -z "${_line// }" ] && continue
    IFS='|' read -r _n _ip _p _u <<< "$_line"
    [ -z "$_n" ] && continue
    _CLUSTER_NAME+=("$_n"); _CLUSTER_IP+=("$_ip")
    _CLUSTER_PORT+=("${_p:-22}"); _CLUSTER_USER+=("${_u:-root}")
    _CLUSTER_COUNT=$((_CLUSTER_COUNT + 1))
  done < "$_f"
}
_cluster_load
[ $_CLUSTER_COUNT -eq 0 ] && exit 0
_now=$(date '+%Y-%m-%d %H:%M:%S')
for _i in $(seq 0 $((_CLUSTER_COUNT - 1))); do
  _out=$(ssh -o ConnectTimeout=5 -o BatchMode=yes -p "${_CLUSTER_PORT[$_i]}" \
    "${_CLUSTER_USER[$_i]}@${_CLUSTER_IP[$_i]}" \
    "top -bn1|grep Cpu|sed 's/.*, *\([0-9.]*\)%* id.*/\1/'|awk '{print 100-\$1}'; \
     free|awk '/Mem:/{printf \"%s %s\", \$3, \$2}'; \
     df /|awk 'NR==2{print \$5}'" 2>/dev/null)
  [ -z "$_out" ] && continue
  _cpu=$(echo "$_out" | sed -n '1p' | awk '{printf "%.0f", $1}')
  _mem_u=$(echo "$_out" | sed -n '2p' | awk '{print $1}')
  _mem_t=$(echo "$_out" | sed -n '2p' | awk '{print $2}')
  _dsk_p=$(echo "$_out" | sed -n '3p' | tr -d '%')
  _mem_p=0
  [ -n "$_mem_t" ] && [ "$_mem_t" -gt 0 ] 2>/dev/null && _mem_p=$(( _mem_u * 100 / _mem_t ))
  _name="${_CLUSTER_NAME[$_i]}"
  _alerts=""
  (( $(echo "${_cpu:-0} > $CPU_THRESHOLD" | bc -l 2>/dev/null || echo 0) )) && _alerts="CPU=${_cpu}% "
  [ -n "$_mem_p" ] && [ "$_mem_p" -gt "$MEM_THRESHOLD" ] 2>/dev/null && _alerts="${_alerts}MEM=${_mem_p}% "
  [ -n "$_dsk_p" ] && [ "$_dsk_p" -gt "$DSK_THRESHOLD" ] 2>/dev/null && _alerts="${_alerts}DSK=${_dsk_p}% "
  if [ -n "$_alerts" ]; then
    echo "[${_now}] ${_name} (${_CLUSTER_IP[$_i]}) 告警: ${_alerts}" >> "$LOG"
  fi
done
SCRIPT
        chmod +x "$_check_script"

        # 写入 crontab（去重）
        local _cron_job="*/${_check_int} * * * * ${_check_script}"
        (crontab -l 2>/dev/null | grep -v "alert_check.sh"; echo "$_cron_job") | crontab -
        green "✓ 告警配置已保存"
        echo -e "   阈值: CPU>${_cpu_thr}%  内存>${_mem_thr}%  磁盘>${_dsk_thr}%"
        echo -e "   间隔: 每 ${_check_int} 分钟"
        echo -e "   日志: ${_alert_log}"
        echo -e "   检测脚本: ${_check_script}"
        echo -e "   已写入 crontab"
        echo ""
        echo -e " ${rw_huang}查看告警: tail -f ${_alert_log}${rw_lv}"
        echo -e " ${rw_huang}停止告警: crontab -l | grep -v alert_check.sh | crontab -${rw_lv}"
        echo ""
        break_end
        ;;


      0)
        return
        ;;

      *)
        echo -e "${rw_hong}无效的输入!${rw_lv}"
        sleep 1
        ;;
    esac
  done
}



















riwi_update() {

send_stats "脚本更新"
cd ~
while true; do
	clear
	echo "更新日志"
	echo -e "${rw_cheng}------------------------${rw_lv}"
	echo "全部日志: ${gh_proxy}raw.githubusercontent.com/riwi/sh/main/riwi_sh_log.txt"
	echo -e "${rw_cheng}------------------------${rw_lv}"

	curl -s --max-time 15 ${gh_proxy}raw.githubusercontent.com/riwi/sh/main/riwi_sh_log.txt | tail -n 30
	# 只下载前5行获取版本号，避免下载整个脚本
	local sh_v_new=$(curl -s --max-time 15 -r 0-200 ${gh_proxy}raw.githubusercontent.com/riwi/sh/main/riwi.sh | grep -o 'sh_v="[0-9.]*"' | head -1 | cut -d '"' -f 2)

	if [ -z "$sh_v_new" ]; then
		echo -e "${rw_hong}无法获取最新版本信息，请检查网络连接${rw_lv}"
	elif [ "$sh_v" = "$sh_v_new" ]; then
		echo -e "${rw_lv}你已经是最新版本！${rw_huang}v$sh_v${rw_lv}"
		send_stats "脚本已经最新了，无需更新"
	else
		echo "发现新版本！"
		echo -e "当前版本 v$sh_v        最新版本 ${rw_huang}v$sh_v_new${rw_lv}"
	fi


	local cron_job="riwi.sh"
	local existing_cron=$(crontab -l 2>/dev/null | grep -F "$cron_job")

	if [ -n "$existing_cron" ]; then
		echo -e "${rw_cheng}------------------------${rw_lv}"
		echo -e "${rw_lv}自动更新已开启，每天凌晨2点脚本会自动更新！${rw_lv}"
	fi

	echo -e "${rw_cheng}------------------------${rw_lv}"
	echo "1. 现在更新            2. 开启自动更新            3. 关闭自动更新"
	echo -e "${rw_cheng}------------------------${rw_lv}"
	echo "0. 返回主菜单"
	echo -e "${rw_cheng}------------------------${rw_lv}"
	read -e -p "请输入你的选择: " choice
	case "$choice" in
		1)
			clear
			local country=$(curl -s --max-time 5 ipinfo.io/country)
			local download_url
			if [ "$country" = "CN" ]; then
				download_url="${gh_proxy}raw.githubusercontent.com/riwi/sh/main/cn/riwi.sh"
			else
				download_url="${gh_proxy}raw.githubusercontent.com/riwi/sh/main/riwi.sh"
			fi

			# 备份当前脚本
			cp -f ~/riwi.sh ~/riwi.sh.bak 2>/dev/null

			# 下载到临时文件，校验后再替换
			local tmp_file=$(mktemp ~/riwi_tmp.XXXXXX)
			if curl -sS --max-time 60 --fail -o "$tmp_file" "$download_url" && \
			   [ -s "$tmp_file" ] && \
			   head -1 "$tmp_file" | grep -q '^#!/bin/bash'; then
				chmod +x "$tmp_file"
				mv -f "$tmp_file" ~/riwi.sh
				canshu_v6
				CheckFirstRun_true
				yinsiyuanquan2
				cp -f ~/riwi.sh /usr/local/bin/r > /dev/null 2>&1
				ln -sf /usr/local/bin/r /usr/bin/r > /dev/null 2>&1
				echo -e "${rw_lv}脚本已更新到最新版本！${rw_huang}v$sh_v_new${rw_lv}"
				send_stats "脚本已经最新$sh_v_new"
			else
				rm -f "$tmp_file"
				# 恢复备份
				if [ -f ~/riwi.sh.bak ]; then
					mv -f ~/riwi.sh.bak ~/riwi.sh
				fi
				echo -e "${rw_hong}更新失败！下载出错或文件校验不通过，已恢复原版本${rw_lv}"
				send_stats "脚本更新失败"
			fi
			break_end
			~/riwi.sh
			exit
			;;
		2)
			clear
			local country=$(curl -s --max-time 5 ipinfo.io/country)
			local ipv6_address=$(curl -s --max-time 1 ipv6.ip.sb)
			local cron_proxy cron_sed_cmd
			if [ "$country" = "CN" ]; then
				cron_proxy="https://gh.riwi.pro/"
				cron_sed_cmd="sed -i 's/canshu=\"default\"/canshu=\"CN\"/g' ~/riwi.sh"
			elif [ -n "$ipv6_address" ]; then
				cron_proxy="https://gh.riwi.pro/"
				cron_sed_cmd="sed -i 's/canshu=\"default\"/canshu=\"V6\"/g' ~/riwi.sh"
			else
				cron_proxy="https://"
				cron_sed_cmd=""
			fi

			# 构建健壮的自动更新命令：下载到临时文件 → 校验 → 备份 → 替换 → 恢复本地设置 → 部署
			SH_Update_task="cd ~ && tmp=\$(mktemp ~/riwi_tmp.XXXXXX) && curl -sS --max-time 60 --fail -o \"\$tmp\" ${cron_proxy}raw.githubusercontent.com/riwi/sh/main/riwi.sh && [ -s \"\$tmp\" ] && head -1 \"\$tmp\" | grep -q '^#!/bin/bash' && cp -f ~/riwi.sh ~/riwi.sh.bak 2>/dev/null && chmod +x \"\$tmp\" && mv -f \"\$tmp\" ~/riwi.sh"
			# 追加设置恢复
			if [ -n "$cron_sed_cmd" ]; then
				SH_Update_task="$SH_Update_task && $cron_sed_cmd"
			fi
			# 从旧脚本恢复 permission_granted 和 ENABLE_STATS 设置
			SH_Update_task="$SH_Update_task && grep -q 'permission_granted=\"true\"' ~/riwi.sh.bak 2>/dev/null && sed -i 's/permission_granted=\"false\"/permission_granted=\"true\"/' ~/riwi.sh; grep -q 'ENABLE_STATS=\"false\"' ~/riwi.sh.bak 2>/dev/null && sed -i 's/ENABLE_STATS=\"true\"/ENABLE_STATS=\"false\"/' ~/riwi.sh"
			# 部署到 /usr/local/bin/r 和 /usr/bin/r
			SH_Update_task="$SH_Update_task; cp -f ~/riwi.sh /usr/local/bin/r 2>/dev/null; ln -sf /usr/local/bin/r /usr/bin/r 2>/dev/null"
			# 下载失败时清理临时文件
			SH_Update_task="$SH_Update_task || rm -f \"\$tmp\" 2>/dev/null"

			check_crontab_installed
			(crontab -l | grep -v "riwi.sh") | crontab -
			(crontab -l 2>/dev/null; echo "$(shuf -i 0-59 -n 1) 2 * * * bash -c '$SH_Update_task'") | crontab -
			echo -e "${rw_lv}自动更新已开启，每天凌晨2点脚本会自动更新！${rw_lv}"
			send_stats "开启脚本自动更新"
			break_end
			;;
		3)
			clear
			(crontab -l | grep -v "riwi.sh") | crontab -
			echo -e "${rw_lv}自动更新已关闭${rw_lv}"
			send_stats "关闭脚本自动更新"
			break_end
			;;
		*)
			riwi_sh
			;;
	esac
done

}





# ════════════════════════════════════════════════════════════════
# 日常运维模块 - 子菜单函数 (2026-06-26 重写)
# 原 46 项扁平菜单 → 10 项 + 6 个二级子菜单
# ════════════════════════════════════════════════════════════════

# ────────────────────────────────────────────────────────────────
# 子菜单1: 安全加固
# 原 1-7 合并
# ────────────────────────────────────────────────────────────────
_maint_security_menu() {
  while true; do
    clear
    send_stats "安全加固"
    echo -e "${rw_cheng}━━━━━━━━━━━━  安全加固  ━━━━━━━━━━━━${rw_lv}"
    echo ""
    # 状态探测
    local _ssh_port _root_login _f2b_stat _fw_stat
    _ssh_port=$(grep -E '^ *Port [0-9]+' /etc/ssh/sshd_config 2>/dev/null | awk '{print $2}' | head -1)
    _ssh_port=${_ssh_port:-22}
    if grep -q "^PermitRootLogin no" /etc/ssh/sshd_config 2>/dev/null; then
        _root_login="${rw_hong}已禁用${rw_lv}"
    else
        _root_login="${rw_lv}允许${rw_lv}"
    fi
    if command -v fail2ban-client &>/dev/null && fail2ban-client ping &>/dev/null 2>&1; then
        _f2b_stat="${rw_lv}运行中${rw_lv}"
    elif command -v fail2ban-client &>/dev/null; then
        _f2b_stat="${rw_huang}已安装未运行${rw_lv}"
    else
        _f2b_stat="${rw_hong}未安装${rw_lv}"
    fi
    if command -v firewall-cmd &>/dev/null && firewall-cmd --state &>/dev/null 2>&1; then
        _fw_stat="${rw_lv}firewalld${rw_lv}"
    elif command -v ufw &>/dev/null && ufw status | grep -q "active" 2>/dev/null; then
        _fw_stat="${rw_lv}ufw${rw_lv}"
    else
        _fw_stat="${rw_hong}未运行${rw_lv}"
    fi
    echo -e " 防火墙 ${_fw_stat}  SSH端口 ${rw_huang}${_ssh_port}${rw_lv}  Root登录 ${_root_login}"
    echo -e " fail2ban ${_f2b_stat}"
    echo ""
    echo -e " ${rw_cheng}──── SSH 安全 ────${rw_lv}"
    echo -e "  ${rw_huang}1${rw_lv}  修改SSH端口           ${rw_huang}2${rw_lv}  禁用ROOT创建新用户"
    echo -e "  ${rw_huang}3${rw_lv}  用户密钥登录          ${rw_huang}4${rw_lv}  SSH防御程序(fail2ban)"
    echo -e "  ${rw_huang}5${rw_lv}  修复OpenSSH高危漏洞   ${rw_huang}6${rw_lv}  SSH免密登录权限检查"
    echo ""
    echo -e " ${rw_cheng}──── 系统防护 ────${rw_lv}"
    echo -e "  ${rw_huang}7${rw_lv}  病毒扫描工具          ${rw_huang}8${rw_lv}  防火墙高级管理器"
    echo -e "  ${rw_huang}9${rw_lv}  隐私与数据采集"
    echo ""
    echo -e " ${rw_cheng}────────────────────────────────────────${rw_lv}"
    echo -e "  ${rw_huang}0${rw_lv}  返回日常运维"
    echo -e " ${rw_cheng}────────────────────────────────────────${rw_lv}"
    read -e -p " 请选择: " sub_choice < /dev/tty
    sub_choice=${sub_choice:-0}
    case $sub_choice in
      1)
        root_use
        send_stats "修改SSH端口"
        while true; do
          clear
          sed -i 's/^[[:space:]]*#\?[[:space:]]*Port/Port/' /etc/ssh/sshd_config
          local current_port=$(grep -E '^ *Port [0-9]+' /etc/ssh/sshd_config | awk '{print $2}')
          echo -e "当前的 SSH 端口号是:  ${rw_huang}$current_port ${rw_lv}"
          echo -e "${rw_cheng}------------------------${rw_lv}"
          echo "端口号范围1到65535之间的数字。（输入0退出）"
          read -e -p "请输入新的 SSH 端口号: " new_port < /dev/tty
          if [[ $new_port =~ ^[0-9]+$ ]]; then
            if [[ $new_port -ge 1 && $new_port -le 65535 ]]; then
              send_stats "SSH端口已修改"
              new_ssh_port $new_port
            elif [[ $new_port -eq 0 ]]; then
              break
            else
              echo "端口号无效，请输入1到65535之间的数字。"
              break_end
            fi
          else
            echo "输入无效，请输入数字。"
            break_end
          fi
        done
        ;;
      2)
        root_use
        send_stats "新用户禁用root"
        read -e -p "请输入新用户名（输入0退出）: " new_username < /dev/tty
        [ "$new_username" = "0" ] && continue
        create_user_with_sshkey $new_username true
        ssh-keygen -l -f /home/$new_username/.ssh/authorized_keys &>/dev/null && {
          passwd -l root &>/dev/null
          sed -i 's/^[[:space:]]*#\?[[:space:]]*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
        }
        ;;
      3) sshkey_panel ;;
      4) fail2ban_panel ;;
      5)
        root_use
        send_stats "修复SSH高危漏洞"
        clear
        echo -e "${rw_cheng}━━━━━━━━━━━━  修复OpenSSH高危漏洞  ━━━━━━━━━━━━${rw_lv}"
        echo ""
        # 检测当前OpenSSH版本
        local _ssh_ver _ssh_ver_num
        _ssh_ver=$(ssh -V 2>&1 | head -1)
        _ssh_ver_num=$(echo "$_ssh_ver" | grep -oE '[0-9]+\.[0-9]+p[0-9]+' | head -1)
        echo -e " ${rw_cheng}当前 OpenSSH 版本:${rw_lv} ${rw_huang}${_ssh_ver}${rw_lv}"
        echo ""

        # 检测系统类型
        local _os_type _pkg_mgr
        if [ -f /etc/debian_version ]; then
            _os_type="Debian/Ubuntu"
            _pkg_mgr="apt"
        elif [ -f /etc/redhat-release ]; then
            _os_type="RHEL/CentOS"
            _pkg_mgr="yum/dnf"
        elif [ -f /etc/alpine-release ]; then
            _os_type="Alpine"
            _pkg_mgr="apk"
        else
            _os_type="未知"
            _pkg_mgr="未知"
        fi
        echo -e " ${rw_cheng}系统类型:${rw_lv} ${rw_huang}${_os_type}${rw_lv}"
        echo -e " ${rw_cheng}包管理器:${rw_lv} ${rw_huang}${_pkg_mgr}${rw_lv}"
        echo ""

        # 检查是否已安装编译依赖
        echo -e " ${rw_cheng}────────────────────────────────────────${rw_lv}"
        echo -e " ${rw_huang}此操作将:${rw_lv}"
        echo -e "  1. 下载并编译安装 OpenSSH 9.8p1（修复CVE-2024-6387等高危漏洞）"
        echo -e "  2. 安装编译依赖（gcc, make, zlib, openssl-dev等）"
        echo -e "  3. ${rw_hong}重启SSH服务${rw_lv}（连接会短暂中断）"
        echo ""
        echo -e " ${rw_hong}⚠ 警告:${rw_lv}"
        echo -e "  - 升级期间SSH连接可能中断，建议保留其他会话"
        echo -e "  - 请确保已配置其他访问方式（如控制台）"
        echo -e "  - 升级后需验证SSH配置和端口"
        echo ""
        echo -e " ${rw_cheng}────────────────────────────────────────${rw_lv}"
        echo -e " ${rw_huang}1${rw_lv} 确认升级    ${rw_huang}0${rw_lv} 取消"
        read -e -p " 请选择: " _ssh_upgrade_choice < /dev/tty
        [ "$_ssh_upgrade_choice" != "1" ] && echo -e " ${rw_huang}已取消${rw_lv}" && break_cancel && continue

        # 二次确认
        echo ""
        read -e -p "$(echo -e "${rw_hong}再次确认升级OpenSSH？(输入 YES): ${rw_lv}")" _ssh_confirm < /dev/tty
        [ "$_ssh_confirm" != "YES" ] && echo -e " ${rw_huang}已取消${rw_lv}" && break_cancel && continue

        echo ""
        echo -e " ${rw_cheng}开始下载升级脚本...${rw_lv}"
        cd ~
        # 下载升级脚本，添加错误处理
        if ! curl -sS -O ${gh_proxy}raw.githubusercontent.com/riwi/sh/main/upgrade_openssh9.8p1.sh 2>&1; then
            echo -e " ${rw_hong}✗ 下载升级脚本失败${rw_lv}"
            echo -e " ${rw_huang}请检查网络连接或稍后重试${rw_lv}"
            rm -f ~/upgrade_openssh9.8p1.sh
            break_end
            continue
        fi

        # 验证脚本是否下载成功
        if [ ! -f ~/upgrade_openssh9.8p1.sh ] || [ ! -s ~/upgrade_openssh9.8p1.sh ]; then
            echo -e " ${rw_hong}✗ 升级脚本下载不完整${rw_lv}"
            rm -f ~/upgrade_openssh9.8p1.sh
            break_end
            continue
        fi

        chmod +x ~/upgrade_openssh9.8p1.sh
        echo -e " ${rw_lv}✓ 升级脚本下载完成${rw_lv}"
        echo -e " ${rw_cheng}开始执行升级（过程可能较长，请耐心等待）...${rw_lv}"
        echo ""

        # 执行升级脚本
        if ~/upgrade_openssh9.8p1.sh; then
            echo ""
            local _new_ssh_ver
            _new_ssh_ver=$(ssh -V 2>&1 | head -1)
            echo -e " ${rw_lv}✓ 升级完成${rw_lv}"
            echo -e " ${rw_cheng}升级前版本:${rw_lv} ${rw_huang}${_ssh_ver}${rw_lv}"
            echo -e " ${rw_cheng}升级后版本:${rw_lv} ${rw_lv}${_new_ssh_ver}${rw_lv}"
        else
            echo ""
            echo -e " ${rw_hong}✗ 升级过程出现错误${rw_lv}"
            echo -e " ${rw_huang}请检查错误信息，SSH服务可能需要手动恢复${rw_lv}"
        fi

        # 清理临时文件
        rm -f ~/upgrade_openssh9.8p1.sh
        ;;
      6) ssh_key_permission_check ;;
      7) clamav ;;
      8) iptables_panel ;;
      9)
        root_use
        while true; do
          clear
          if grep -q '^ENABLE_STATS="true"' /usr/local/bin/r 2>/dev/null; then
            local status_message="${rw_lv}正在采集数据${rw_lv}"
          elif grep -q '^ENABLE_STATS="false"' /usr/local/bin/r 2>/dev/null; then
            local status_message="${rw_lv}采集已关闭${rw_lv}"
          else
            local status_message="无法确定的状态"
          fi
          echo "隐私与安全"
          echo "脚本将收集用户使用功能的数据，优化脚本体验"
          echo "收集：脚本版本号、使用时间、系统版本、CPU架构、所属国家、功能名称"
          echo -e "${rw_cheng}------------------------------------------------${rw_lv}"
          echo -e "当前状态: $status_message"
          echo -e "${rw_cheng}--------------------${rw_lv}"
          echo "1. 开启采集          2. 关闭采集"
          echo -e "${rw_cheng}--------------------${rw_lv}"
          echo "0. 返回上一级"
          echo -e "${rw_cheng}--------------------${rw_lv}"
          read -e -p "请选择: " p_choice < /dev/tty
          case $p_choice in
            1)
              cd ~
              sed -i 's/^ENABLE_STATS="false"/ENABLE_STATS="true"/' /usr/local/bin/r 2>/dev/null
              sed -i 's/^ENABLE_STATS="false"/ENABLE_STATS="true"/' ~/riwi.sh 2>/dev/null
              echo "已开启采集"
              send_stats "隐私与安全已开启采集"
              ;;
            2)
              cd ~
              sed -i 's/^ENABLE_STATS="true"/ENABLE_STATS="false"/' /usr/local/bin/r 2>/dev/null
              sed -i 's/^ENABLE_STATS="true"/ENABLE_STATS="false"/' ~/riwi.sh 2>/dev/null
              echo "已关闭采集"
              send_stats "隐私与安全已关闭采集"
              ;;
            *) break ;;
          esac
        done
        ;;
      0) break ;;
      *) echo "无效的输入!" ;;
    esac
    break_cancel
  done
}

# ────────────────────────────────────────────────────────────────
# 子菜单2: 性能优化
# 原 8-13 合并
# ────────────────────────────────────────────────────────────────
_maint_perf_menu() {
  while true; do
    clear
    send_stats "性能优化"
    echo -e "${rw_cheng}━━━━━━━━━━━━  性能优化  ━━━━━━━━━━━━${rw_lv}"
    echo ""
    # BBR + Swap 状态
    local _bbr_stat _swap_size
    if grep -q "bbr" /proc/sys/net/ipv4/tcp_congestion_control 2>/dev/null; then
        _bbr_stat="${rw_lv}已开启${rw_lv}"
    else
        _bbr_stat="${rw_hong}未开启${rw_lv}"
    fi
    _swap_size=$(free -m 2>/dev/null | awk 'NR==3{print $2}')
    if [ -z "$_swap_size" ] || [ "$_swap_size" = "0" ]; then
        _swap_size="${rw_hong}未设置${rw_lv}"
    else
        _swap_size="${rw_lv}${_swap_size}MB${rw_lv}"
    fi
    echo -e " BBR ${_bbr_stat}  虚拟内存 ${_swap_size}"
    echo ""
    echo -e " ${rw_cheng}──── 网络与内核 ────${rw_lv}"
    echo -e "  ${rw_huang}1${rw_lv}  设置BBR3加速          ${rw_huang}2${rw_lv}  内核参数优化"
    echo -e "  ${rw_huang}3${rw_lv}  红帽系Linux内核升级"
    echo ""
    echo -e " ${rw_cheng}──── 内存与调度 ────${rw_lv}"
    echo -e "  ${rw_huang}4${rw_lv}  修改虚拟内存大小      ${rw_huang}5${rw_lv}  限流自动关机"
    echo ""
    echo -e " ${rw_cheng}──── 一键优化 ────${rw_lv}"
    echo -e "  ${rw_huang}6${rw_lv}  一条龙系统调优"
    echo -e " ${rw_cheng}────────────────────────────────────────${rw_lv}"
    echo -e "  ${rw_huang}0${rw_lv}  返回日常运维"
    echo -e " ${rw_cheng}────────────────────────────────────────${rw_lv}"
    read -e -p " 请选择: " sub_choice < /dev/tty
    sub_choice=${sub_choice:-0}
    case $sub_choice in
      1) bbrv3 ;;
      2) Kernel_optimize ;;
      3) elrepo ;;
      4)
        root_use
        send_stats "设置虚拟内存"
        while true; do
          clear
          echo "设置虚拟内存"
          local swap_used=$(free -m | awk 'NR==3{print $3}')
          local swap_total=$(free -m | awk 'NR==3{print $2}')
          local swap_info=$(free -m | awk 'NR==3{used=$3; total=$2; if (total == 0) {percentage=0} else {percentage=used*100/total}; printf "%dM/%dM (%d%%)", used, total, percentage}')
          echo -e "当前虚拟内存: ${rw_huang}$swap_info${rw_lv}"
          echo -e "${rw_cheng}------------------------${rw_lv}"
          echo "1. 分配1024M         2. 分配2048M         3. 分配4096M         4. 自定义大小"
          echo -e "${rw_cheng}------------------------${rw_lv}"
          echo "0. 返回上一级"
          echo -e "${rw_cheng}------------------------${rw_lv}"
          read -e -p "请输入你的选择: " vm_choice < /dev/tty
          case "$vm_choice" in
            1) send_stats "已设置1G虚拟内存" ; add_swap 1024 ;;
            2) send_stats "已设置2G虚拟内存" ; add_swap 2048 ;;
            3) send_stats "已设置4G虚拟内存" ; add_swap 4096 ;;
            4) read -e -p "请输入虚拟内存大小（单位M）: " new_swap < /dev/tty ; add_swap "$new_swap" ; send_stats "已设置自定义虚拟内存" ;;
            *) break ;;
          esac
        done
        ;;
      5)
        root_use
        send_stats "限流关机功能"
        while true; do
          clear
          echo "限流关机功能"
          echo "视频介绍: https://www.bilibili.com/video/BV1mC411j7Qd?t=0.1"
          echo -e "${rw_cheng}------------------------------------------------${rw_lv}"
          echo "当前流量使用情况，重启服务器流量计算会清零！"
          output_status
          echo -e "${rw_huang}总接收${rw_huang}: ${rw_lv}$rx"
          echo -e "${rw_huang}总发送${rw_huang}: ${rw_lv}$tx"
          if [ -f ~/Limiting_Shut_down.sh ]; then
            local rx_threshold_gb=$(sed -n 's/.*rx_threshold_gb=\([0-9]\+\).*/\1/p' ~/Limiting_Shut_down.sh)
            local tx_threshold_gb=$(sed -n 's/.*tx_threshold_gb=\([0-9]\+\).*/\1/p' ~/Limiting_Shut_down.sh)
            echo -e "${rw_lv}当前进站限流阈值: ${rw_huang}${rx_threshold_gb}${rw_lv}G${rw_lv}"
            echo -e "${rw_lv}当前出站限流阈值: ${rw_huang}${tx_threshold_gb}${rw_lv}GB${rw_lv}"
          else
            echo -e "${rw_lv}当前未启用限流关机${rw_lv}"
          fi
          echo
          echo -e "${rw_cheng}------------------------------------------------${rw_lv}"
          echo "系统每分钟检测流量，到达阈值后自动关机"
          echo -e "${rw_cheng}------------------------${rw_lv}"
          echo "1. 开启限流关机          2. 停用限流关机"
          echo -e "${rw_cheng}------------------------${rw_lv}"
          echo "0. 返回上一级"
          echo -e "${rw_cheng}------------------------${rw_lv}"
          read -e -p "请选择: " Limiting < /dev/tty
          case "$Limiting" in
            1)
              echo "如服务器有100G流量，可设置95G提前关机"
              read -e -p "进站流量阈值（G，默认100）: " rx_threshold_gb < /dev/tty
              rx_threshold_gb=${rx_threshold_gb:-100}
              read -e -p "出站流量阈值（G，默认100）: " tx_threshold_gb < /dev/tty
              tx_threshold_gb=${tx_threshold_gb:-100}
              read -e -p "流量重置日期（默认每月1日）: " cz_day < /dev/tty
              cz_day=${cz_day:-1}
              cd ~
              curl -Ss -o ~/Limiting_Shut_down.sh ${gh_proxy}raw.githubusercontent.com/riwi/sh/main/Limiting_Shut_down1.sh
              chmod +x ~/Limiting_Shut_down.sh
              sed -i "s/110/$rx_threshold_gb/g" ~/Limiting_Shut_down.sh
              sed -i "s/120/$tx_threshold_gb/g" ~/Limiting_Shut_down.sh
              check_crontab_installed
              crontab -l | grep -v '~/Limiting_Shut_down.sh' | crontab -
              (crontab -l ; echo "* * * * * ~/Limiting_Shut_down.sh") | crontab - > /dev/null 2>&1
              crontab -l | grep -v 'reboot' | crontab -
              (crontab -l ; echo "0 1 $cz_day * * reboot") | crontab - > /dev/null 2>&1
              echo "限流关机已设置"
              send_stats "限流关机已设置"
              ;;
            2)
              check_crontab_installed
              crontab -l | grep -v '~/Limiting_Shut_down.sh' | crontab -
              crontab -l | grep -v 'reboot' | crontab -
              rm -f ~/Limiting_Shut_down.sh
              echo "已关闭限流关机"
              ;;
            *) break ;;
          esac
        done
        ;;
      6)
        root_use
        send_stats "一条龙调优"
        echo "一条龙系统调优"
        echo -e "${rw_cheng}------------------------------------------------${rw_lv}"
        echo "将对以下内容进行操作与优化"
        echo "1.  优化系统更新源，更新系统到最新"
        echo "2.  清理系统垃圾文件"
        echo -e "3.  设置虚拟内存${rw_huang}1G${rw_lv}"
        echo -e "4.  设置SSH端口号为${rw_huang}5522${rw_lv}"
        echo -e "5.  启动fail2ban防御SSH暴力破解"
        echo -e "6.  开放所有端口"
        echo -e "7.  开启${rw_huang}BBR${rw_lv}加速"
        echo -e "8.  设置时区到${rw_huang}上海${rw_lv}"
        echo -e "9.  自动优化DNS（海外:1.1.1.1 8.8.8.8  国内:223.5.5.5）${rw_lv}"
        echo -e "10. 设置网络为${rw_huang}ipv4优先${rw_lv}"
        echo -e "11. 安装基础工具${rw_huang}docker wget sudo tar unzip socat btop nano vim${rw_lv}"
        echo -e "12. Linux系统内核参数优化${rw_huang}自动根据网络环境调优${rw_lv}"
        echo -e "${rw_cheng}------------------------------------------------${rw_lv}"
        read -e -p "确定一键保养吗？(Y/N): " choice < /dev/tty
        case "$choice" in
          [Yy])
            clear
            send_stats "一条龙调优启动"
            echo -e "${rw_cheng}------------------------------------------------${rw_lv}"
            switch_mirror false false
            linux_update
            echo -e "[${rw_lv}OK${rw_lv}] 1/12. 更新系统到最新"
            echo -e "${rw_cheng}------------------------------------------------${rw_lv}"
            linux_clean
            echo -e "[${rw_lv}OK${rw_lv}] 2/12. 清理系统垃圾文件"
            echo -e "${rw_cheng}------------------------------------------------${rw_lv}"
            add_swap 1024
            echo -e "[${rw_lv}OK${rw_lv}] 3/12. 设置虚拟内存${rw_huang}1G${rw_lv}"
            echo -e "${rw_cheng}------------------------------------------------${rw_lv}"
            new_ssh_port 5522
            echo -e "[${rw_lv}OK${rw_lv}] 4/12. 设置SSH端口${rw_huang}5522${rw_lv}"
            echo -e "${rw_cheng}------------------------------------------------${rw_lv}"
            f2b_install_sshd
            cd ~
            f2b_status
            echo -e "[${rw_lv}OK${rw_lv}] 5/12. 启动fail2ban"
            echo -e "${rw_cheng}------------------------------------------------${rw_lv}"
            echo -e "[${rw_lv}OK${rw_lv}] 6/12. 开放所有端口"
            echo -e "${rw_cheng}------------------------------------------------${rw_lv}"
            bbr_on
            echo -e "[${rw_lv}OK${rw_lv}] 7/12. 开启${rw_huang}BBR${rw_lv}加速"
            echo -e "${rw_cheng}------------------------------------------------${rw_lv}"
            set_timedate Asia/Shanghai
            echo -e "[${rw_lv}OK${rw_lv}] 8/12. 设置时区${rw_huang}上海${rw_lv}"
            echo -e "${rw_cheng}------------------------------------------------${rw_lv}"
            auto_optimize_dns
            echo -e "[${rw_lv}OK${rw_lv}] 9/12. 优化DNS"
            echo -e "${rw_cheng}------------------------------------------------${rw_lv}"
            prefer_ipv4
            echo -e "[${rw_lv}OK${rw_lv}] 10/12. ipv4优先"
            echo -e "${rw_cheng}------------------------------------------------${rw_lv}"
            install_docker
            install wget sudo tar unzip socat btop nano vim
            echo -e "[${rw_lv}OK${rw_lv}] 11/12. 安装基础工具"
            echo -e "${rw_cheng}------------------------------------------------${rw_lv}"
            curl -sS ${gh_proxy}raw.githubusercontent.com/riwi/sh/refs/heads/main/network-optimize.sh | bash
            echo -e "[${rw_lv}OK${rw_lv}] 12/12. 内核参数优化"
            echo -e "${rw_lv}一条龙系统调优已完成${rw_lv}"
            ;;
          [Nn]) echo "已取消" ;;
          *) echo "无效的选择" ;;
        esac
        ;;
      0) break ;;
      *) echo "无效的输入!" ;;
    esac
    break_cancel
  done
}

# ────────────────────────────────────────────────────────────────
# 子菜单3: 网络管理
# 原 14-17(部分) + 22-25 合并
# ────────────────────────────────────────────────────────────────
_maint_network_menu() {
  while true; do
    clear
    send_stats "网络管理"
    echo -e "${rw_cheng}━━━━━━━━━━━━  网络管理  ━━━━━━━━━━━━${rw_lv}"
    echo ""
    echo -e " ${rw_cheng}──── DNS与解析 ────${rw_lv}"
    echo -e "  ${rw_huang}1${rw_lv}  优化DNS地址           ${rw_huang}2${rw_lv}  本机host解析"
    echo -e "  ${rw_huang}3${rw_lv}  切换优先ipv4/ipv6"
    echo ""
    echo -e " ${rw_cheng}──── 网络工具 ────${rw_lv}"
    echo -e "  ${rw_huang}4${rw_lv}  查看端口             ${rw_huang}5${rw_lv}  网卡管理"
    echo -e "  ${rw_huang}6${rw_lv}  防火墙高级管理器"
    echo ""
    echo -e " ${rw_cheng}──── 监控预警 ────${rw_lv}"
    echo -e "  ${rw_huang}7${rw_lv}  系统日志             ${rw_huang}8${rw_lv}  TG-bot预警"
    echo -e " ${rw_cheng}────────────────────────────────────────${rw_lv}"
    echo -e "  ${rw_huang}0${rw_lv}  返回日常运维"
    echo -e " ${rw_cheng}────────────────────────────────────────${rw_lv}"
    read -e -p " 请选择: " sub_choice < /dev/tty
    sub_choice=${sub_choice:-0}
    case $sub_choice in
      1) set_dns_ui ;;
      2)
        root_use
        send_stats "本地host解析"
        while true; do
          clear
          echo "本机host解析列表"
          echo "添加解析后将不再使用动态解析"
          cat /etc/hosts
          echo ""
          echo -e "${rw_cheng}------------------------${rw_lv}"
          echo "1. 添加新的解析          2. 删除解析地址"
          echo -e "${rw_cheng}------------------------${rw_lv}"
          echo "0. 返回上一级"
          echo -e "${rw_cheng}------------------------${rw_lv}"
          read -e -p "请选择: " host_dns < /dev/tty
          case $host_dns in
            1)
              read -e -p "格式 110.25.5.33 riwi.pro : " addhost < /dev/tty
              echo "$addhost" >> /etc/hosts
              send_stats "本地host解析新增"
              ;;
            2)
              read -e -p "输入要删除的解析关键字: " delhost < /dev/tty
              sed -i "/$delhost/d" /etc/hosts
              send_stats "本地host解析删除"
              ;;
            *) break ;;
          esac
        done
        ;;
      3)
        root_use
        send_stats "设置v4/v6优先级"
        while true; do
          clear
          echo "设置v4/v6优先级"
          echo -e "${rw_cheng}------------------------${rw_lv}"
          if grep -Eq '^[[:space:]]*precedence[[:space:]]+::ffff:0:0/96[[:space:]]+100[[:space:]]*$' /etc/gai.conf 2>/dev/null; then
            echo -e "当前网络优先级: ${rw_huang}IPv4${rw_lv} 优先"
          else
            echo -e "当前网络优先级: ${rw_huang}IPv6${rw_lv} 优先"
          fi
          echo ""
          echo -e "${rw_cheng}------------------------${rw_lv}"
          echo "1. IPv4 优先          2. IPv6 优先          3. IPv6 修复工具"
          echo -e "${rw_cheng}------------------------${rw_lv}"
          echo "0. 返回上一级"
          echo -e "${rw_cheng}------------------------${rw_lv}"
          read -e -p "选择优先网络: " choice < /dev/tty
          case $choice in
            1) prefer_ipv4 ;;
            2)
              rm -f /etc/gai.conf
              echo "已切换为 IPv6 优先"
              send_stats "已切换为 IPv6 优先"
              ;;
            3)
              clear
              bash <(curl -L -s jhb.ovh/jb/v6.sh)
              echo "该功能由jhb大神提供"
              send_stats "ipv6修复"
              ;;
            *) break ;;
          esac
        done
        ;;
      4) clear ; ss -tulnape ;;
      5) clear ; net_menu ;;
      6) iptables_panel ;;
      7) clear ; log_menu ;;
      8)
        root_use
        send_stats "电报预警"
        echo "TG-bot监控预警功能"
        echo "视频介绍: https://youtu.be/vLL-eb3Z_TY"
        echo -e "${rw_cheng}------------------------------------------------${rw_lv}"
        echo "配置tg机器人API和用户ID，实现CPU/内存/硬盘/流量/SSH登录监控预警"
        echo -e "${rw_lv}-关于流量，重启服务器将重新计算-${rw_lv}"
        read -e -p "确定继续吗？(Y/N): " tg_choice < /dev/tty
        case "$tg_choice" in
          [Yy])
            send_stats "电报预警启用"
            cd ~
            install nano tmux bc jq
            check_crontab_installed
            if [ -f ~/TG-check-notify.sh ]; then
              chmod +x ~/TG-check-notify.sh
              nano ~/TG-check-notify.sh
            else
              curl -sS -O ${gh_proxy}raw.githubusercontent.com/riwi/sh/main/TG-check-notify.sh
              chmod +x ~/TG-check-notify.sh
              nano ~/TG-check-notify.sh
            fi
            tmux kill-session -t TG-check-notify > /dev/null 2>&1
            tmux new -d -s TG-check-notify "~/TG-check-notify.sh"
            crontab -l | grep -v '~/TG-check-notify.sh' | crontab - > /dev/null 2>&1
            (crontab -l ; echo "@reboot tmux new -d -s TG-check-notify '~/TG-check-notify.sh'") | crontab - > /dev/null 2>&1
            curl -sS -O ${gh_proxy}raw.githubusercontent.com/riwi/sh/main/TG-SSH-check-notify.sh > /dev/null 2>&1
            sed -i "3i$(grep '^TELEGRAM_BOT_TOKEN=' ~/TG-check-notify.sh)" TG-SSH-check-notify.sh > /dev/null 2>&1
            sed -i "4i$(grep '^CHAT_ID=' ~/TG-check-notify.sh)" TG-SSH-check-notify.sh
            chmod +x ~/TG-SSH-check-notify.sh
            if ! grep -q 'bash ~/TG-SSH-check-notify.sh' ~/.profile > /dev/null 2>&1; then
              echo 'bash ~/TG-SSH-check-notify.sh' >> ~/.profile
              if command -v dnf &>/dev/null || command -v yum &>/dev/null; then
                echo 'source ~/.profile' >> ~/.bashrc
              fi
            fi
            source ~/.profile 2>/dev/null
            clear
            echo "TG-bot预警系统已启动"
            echo -e "${rw_lv}可将root目录中的TG-check-notify.sh放到其他机器使用${rw_lv}"
            ;;
          [Nn]) echo "已取消" ;;
          *) echo "无效的选择" ;;
        esac
        ;;
      0) break ;;
      *) echo "无效的输入!" ;;
    esac
    break_cancel
  done
}

# ────────────────────────────────────────────────────────────────
# 子菜单4: 系统配置
# 原 29-33 + 30(时区) + 31(主机名) + 32(语言) + 33(源) 合并
# ────────────────────────────────────────────────────────────────
_maint_config_menu() {
  while true; do
    clear
    send_stats "系统配置"
    echo -e "${rw_cheng}━━━━━━━━━━━━  系统配置  ━━━━━━━━━━━━${rw_lv}"
    echo ""
    local _tz _host
    _tz=$(current_timezone 2>/dev/null || echo "?")
    _host=$(uname -n 2>/dev/null || echo "?")
    echo -e " 时区 ${rw_huang}${_tz}${rw_lv}  主机名 ${rw_huang}${_host}${rw_lv}"
    echo ""
    echo -e " ${rw_cheng}──── 基础设置 ────${rw_lv}"
    echo -e "  ${rw_huang}1${rw_lv}  基础设置             ${rw_huang}2${rw_lv}  系统时区调整"
    echo -e "  ${rw_huang}3${rw_lv}  修改主机名           ${rw_huang}4${rw_lv}  切换系统语言"
    echo -e "  ${rw_huang}5${rw_lv}  切换系统更新源"
    echo -e " ${rw_cheng}────────────────────────────────────────${rw_lv}"
    echo -e "  ${rw_huang}0${rw_lv}  返回日常运维"
    echo -e " ${rw_cheng}────────────────────────────────────────${rw_lv}"
    read -e -p " 请选择: " sub_choice < /dev/tty
    sub_choice=${sub_choice:-0}
    case $sub_choice in
      1) basic_settings_menu ;;
      2)
        root_use
        send_stats "换时区"
        while true; do
          clear
          echo "系统时间信息"
          local timezone=$(current_timezone)
          local current_time=$(date +"%Y-%m-%d %H:%M:%S")
          echo "当前系统时区：$timezone"
          echo "当前系统时间：$current_time"
          echo ""
          echo "时区切换"
          echo -e "${rw_cheng}------------------------${rw_lv}"
          echo "亚洲"
          echo "1.  中国上海时间             2.  中国香港时间"
          echo "3.  日本东京时间             4.  韩国首尔时间"
          echo "5.  新加坡时间               6.  印度加尔各答时间"
          echo "7.  阿联酋迪拜时间           8.  澳大利亚悉尼时间"
          echo "9.  泰国曼谷时间"
          echo -e "${rw_cheng}------------------------${rw_lv}"
          echo "欧洲"
          echo "11. 英国伦敦时间             12. 法国巴黎时间"
          echo "13. 德国柏林时间             14. 俄罗斯莫斯科时间"
          echo "15. 荷兰尤特赖赫特时间       16. 西班牙马德里时间"
          echo -e "${rw_cheng}------------------------${rw_lv}"
          echo "美洲"
          echo "21. 美国西部时间             22. 美国东部时间"
          echo "23. 加拿大时间               24. 墨西哥时间"
          echo "25. 巴西时间                 26. 阿根廷时间"
          echo -e "${rw_cheng}------------------------${rw_lv}"
          echo "31. UTC全球标准时间"
          echo -e "${rw_cheng}------------------------${rw_lv}"
          echo "0. 返回上一级"
          echo -e "${rw_cheng}------------------------${rw_lv}"
          read -e -p "请选择: " tz_choice < /dev/tty
          case $tz_choice in
            1) set_timedate Asia/Shanghai ;;
            2) set_timedate Asia/Hong_Kong ;;
            3) set_timedate Asia/Tokyo ;;
            4) set_timedate Asia/Seoul ;;
            5) set_timedate Asia/Singapore ;;
            6) set_timedate Asia/Kolkata ;;
            7) set_timedate Asia/Dubai ;;
            8) set_timedate Australia/Sydney ;;
            9) set_timedate Asia/Bangkok ;;
            11) set_timedate Europe/London ;;
            12) set_timedate Europe/Paris ;;
            13) set_timedate Europe/Berlin ;;
            14) set_timedate Europe/Moscow ;;
            15) set_timedate Europe/Amsterdam ;;
            16) set_timedate Europe/Madrid ;;
            21) set_timedate America/Los_Angeles ;;
            22) set_timedate America/New_York ;;
            23) set_timedate America/Vancouver ;;
            24) set_timedate America/Mexico_City ;;
            25) set_timedate America/Sao_Paulo ;;
            26) set_timedate America/Argentina/Buenos_Aires ;;
            31) set_timedate UTC ;;
            *) break ;;
          esac
        done
        ;;
      3)
        root_use
        send_stats "修改主机名"
        while true; do
          clear
          local current_hostname=$(uname -n)
          echo -e "当前主机名: ${rw_huang}$current_hostname${rw_lv}"
          echo -e "${rw_cheng}------------------------${rw_lv}"
          read -e -p "请输入新的主机名（0退出）: " new_hostname < /dev/tty
          if [ -n "$new_hostname" ] && [ "$new_hostname" != "0" ]; then
            if [ -f /etc/alpine-release ]; then
              echo "$new_hostname" > /etc/hostname
              hostname "$new_hostname"
            else
              hostnamectl set-hostname "$new_hostname"
              sed -i "s/$current_hostname/$new_hostname/g" /etc/hostname
              systemctl restart systemd-hostnamed
            fi
            if grep -q "127.0.0.1" /etc/hosts; then
              sed -i "s/127.0.0.1 .*/127.0.0.1       $new_hostname localhost localhost.localdomain/g" /etc/hosts
            else
              echo "127.0.0.1       $new_hostname localhost localhost.localdomain" >> /etc/hosts
            fi
            if grep -q "^::1" /etc/hosts; then
              sed -i "s/^::1 .*/::1             $new_hostname localhost localhost.localdomain ipv6-localhost ipv6-loopback/g" /etc/hosts
            else
              echo "::1             $new_hostname localhost localhost.localdomain ipv6-localhost ipv6-loopback" >> /etc/hosts
            fi
            echo "主机名已更改为: $new_hostname"
            send_stats "主机名已更改"
            sleep 1
          else
            break
          fi
        done
        ;;
      4) linux_language ;;
      5)
        root_use
        send_stats "换系统更新源"
        clear
        echo "选择更新源区域"
        echo "接入LinuxMirrors切换系统更新源"
        echo -e "${rw_cheng}------------------------${rw_lv}"
        echo "1. 中国大陆【默认】          2. 中国大陆【教育网】"
        echo "3. 海外地区                  4. 智能切换更新源"
        echo -e "${rw_cheng}------------------------${rw_lv}"
        echo "0. 返回上一级"
        echo -e "${rw_cheng}------------------------${rw_lv}"
        read -e -p "请选择: " src_choice < /dev/tty
        case $src_choice in
          1) send_stats "中国大陆默认源" ; bash <(curl -sSL https://linuxmirrors.cn/main.sh) ;;
          2) send_stats "中国大陆教育源" ; bash <(curl -sSL https://linuxmirrors.cn/main.sh) --edu ;;
          3) send_stats "海外源" ; bash <(curl -sSL https://linuxmirrors.cn/main.sh) --abroad ;;
          4) send_stats "智能切换更新源" ; switch_mirror false false ;;
          *) echo "已取消" ;;
        esac
        ;;
      0) break ;;
      *) echo "无效的输入!" ;;
    esac
    break_cancel
  done
}

# ────────────────────────────────────────────────────────────────
# 子菜单5: 用户管理
# 原 26-28 + 46 + 27 合并
# ────────────────────────────────────────────────────────────────
_maint_user_menu() {
  while true; do
    root_use
    send_stats "用户管理"
    clear
    echo -e "${rw_cheng}━━━━━━━━━━━━  用户管理  ━━━━━━━━━━━━${rw_lv}"
    echo ""
    # 用户统计
    local total_users=0 sudo_users=0
    while IFS=: read -r username _ userid _ _ _ shell; do
      ((total_users++))
      local g=$(groups "$username" 2>/dev/null | cut -d : -f 2)
      local has_sudo=0
      [[ -f "/etc/sudoers.d/$username" ]] && grep -qE "^\s*${username}\s+ALL=\(ALL\)" "/etc/sudoers.d/$username" 2>/dev/null && has_sudo=1
      grep -qE "^\s*${username}\s+ALL=\(ALL\)" /etc/sudoers 2>/dev/null && has_sudo=1
      [[ "$g" =~ (^|[[:space:]])sudo($|[[:space:]]) ]] && has_sudo=1
      [[ "$g" =~ (^|[[:space:]])wheel($|[[:space:]]) ]] && has_sudo=1
      [[ "$has_sudo" -eq 1 ]] && ((sudo_users++))
    done < /etc/passwd
    echo -e " 总用户: ${rw_huang}${total_users}${rw_lv}  sudo用户: ${rw_lv}${sudo_users}${rw_lv}"
    echo ""
    echo -e " ${rw_cheng}──── 账户管理 ────${rw_lv}"
    echo -e "  ${rw_huang}1${rw_lv}  创建用户（密码+密钥+sudo）   ${rw_huang}2${rw_lv}  取消sudo权限"
    echo -e "  ${rw_huang}3${rw_lv}  删除账号"
    echo ""
    echo -e " ${rw_cheng}──── SSH与密钥 ────${rw_lv}"
    echo -e "  ${rw_huang}4${rw_lv}  SSH远程连接工具       ${rw_huang}5${rw_lv}  SSH免密登录权限检查"
    echo ""
    echo -e " ${rw_cheng}──── 生成器 ────${rw_lv}"
    echo -e "  ${rw_huang}6${rw_lv}  用户/密码生成器"
    echo -e " ${rw_cheng}────────────────────────────────────────${rw_lv}"
    echo -e "  ${rw_huang}0${rw_lv}  返回日常运维"
    echo -e " ${rw_cheng}────────────────────────────────────────${rw_lv}"
    read -e -p " 请选择: " sub_choice < /dev/tty
    sub_choice=${sub_choice:-0}
    case $sub_choice in
      1)
        read -e -p "请输入新用户名: " new_username < /dev/tty
        create_user_with_sshkey "$new_username"
        ;;
      2)
        read -e -p "请输入用户名: " username < /dev/tty
        if [[ -f "/etc/sudoers.d/$username" ]]; then
          grep -lR "^$username" /etc/sudoers.d/ 2>/dev/null | xargs rm -f
        fi
        sed -i "/^$username\s*ALL=(ALL)/d" /etc/sudoers
        if [[ -f "/etc/sudoers.d/$username" ]] && grep -qE "^\s*${username}\s+ALL=\(ALL\)" "/etc/sudoers.d/$username" 2>/dev/null; then
          echo -e "${rw_huang}[提示] $username 仍有 sudoers.d 权限残留${rw_lv}"
        elif grep -qE "^\s*${username}\s+ALL=\(ALL\)" /etc/sudoers 2>/dev/null; then
          echo -e "${rw_huang}[提示] $username 在 /etc/sudoers 中仍有权限残留${rw_lv}"
        else
          echo -e "${rw_lv}[OK] $username 的 sudo 权限已取消${rw_lv}"
        fi
        ;;
      3)
        read -e -p "请输入要删除的用户名: " username < /dev/tty
        userdel -r "$username"
        ;;
      4) ssh_manager ;;
      5) ssh_key_permission_check ;;
      6)
        clear
        send_stats "用户信息生成器"
        echo "随机用户名"
        echo -e "${rw_cheng}------------------------${rw_lv}"
        for i in {1..5}; do
          username="user$(< /dev/urandom tr -dc _a-z0-9 | head -c6)"
          echo "随机用户名 $i: $username"
        done
        echo ""
        echo "随机姓名"
        echo -e "${rw_cheng}------------------------${rw_lv}"
        local first_names=("John" "Jane" "Michael" "Emily" "David" "Sophia" "William" "Olivia" "James" "Emma" "Ava" "Liam" "Mia" "Noah" "Isabella")
        local last_names=("Smith" "Johnson" "Brown" "Davis" "Wilson" "Miller" "Jones" "Garcia" "Martinez" "Williams" "Lee" "Gonzalez" "Rodriguez" "Hernandez")
        for i in {1..5}; do
          local first_name_index=$((RANDOM % ${#first_names[@]}))
          local last_name_index=$((RANDOM % ${#last_names[@]}))
          echo "随机姓名 $i: ${first_names[$first_name_index]} ${last_names[$last_name_index]}"
        done
        echo ""
        echo "随机UUID"
        echo -e "${rw_cheng}------------------------${rw_lv}"
        for i in {1..5}; do
          echo "UUID $i: $(cat /proc/sys/kernel/random/uuid)"
        done
        echo ""
        echo "16位随机密码"
        echo -e "${rw_cheng}------------------------${rw_lv}"
        for i in {1..5}; do
          echo "密码 $i: $(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c16)"
        done
        echo ""
        echo "32位随机密码"
        echo -e "${rw_cheng}------------------------${rw_lv}"
        for i in {1..5}; do
          echo "密码 $i: $(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c32)"
        done
        echo ""
        ;;
      0) break ;;
      *) echo "无效的输入!" ;;
    esac
    break_cancel
  done
}

# ────────────────────────────────────────────────────────────────
# 子菜单6: 高级工具
# 原 34-39 合并
# ────────────────────────────────────────────────────────────────
_maint_advanced_menu() {
  while true; do
    clear
    send_stats "高级工具"
    echo -e "${rw_cheng}━━━━━━━━━━━━  高级工具  ━━━━━━━━━━━━${rw_lv}"
    echo ""
    echo -e " ${rw_cheng}──── 命令行增强 ────${rw_lv}"
    echo -e "  ${rw_huang}1${rw_lv}  命令行美化工具       ${rw_huang}2${rw_lv}  命令行历史记录"
    echo -e "  ${rw_huang}3${rw_lv}  命令收藏夹           ${rw_huang}4${rw_lv}  r命令高级用法"
    echo ""
    echo -e " ${rw_cheng}──── 系统工具 ────${rw_lv}"
    echo -e "  ${rw_huang}5${rw_lv}  系统变量管理工具     ${rw_huang}6${rw_lv}  设置系统回收站"
    echo -e " ${rw_cheng}────────────────────────────────────────${rw_lv}"
    echo -e "  ${rw_huang}0${rw_lv}  返回日常运维"
    echo -e " ${rw_cheng}────────────────────────────────────────${rw_lv}"
    read -e -p " 请选择: " sub_choice < /dev/tty
    sub_choice=${sub_choice:-0}
    case $sub_choice in
      1) shell_bianse ;;
      2)
        clear
        send_stats "命令行历史记录"
        get_history_file() {
          for file in "$HOME"/.bash_history "$HOME"/.ash_history "$HOME"/.zsh_history "$HOME"/.local/share/fish/fish_history; do
            [ -f "$file" ] && { echo "$file"; return; }
          done
          return 1
        }
        history_file=$(get_history_file) && cat -n "$history_file"
        ;;
      3) clear ; linux_fav ;;
      4) clear ; k_info ;;
      5) clear ; env_menu ;;
      6) linux_trash ;;
      0) break ;;
      *) echo "无效的输入!" ;;
    esac
    break_cancel
  done
}

# ════════════════════════════════════════════════════════════════
# 主菜单: 日常运维 (重写)
# 原 46 项 → 10 项扁平菜单 + 6 个二级子菜单
# ════════════════════════════════════════════════════════════════
update_clean_menu() {
while true; do
  clear
  send_stats "日常运维"

    # ── 使用缓存的状态探测 ──
    if _should_refresh_cache; then
        refresh_status_cache
    fi

    # ── 顶部状态面板 ──
    local _ssh_port="22"
    local _bbr_stat="${rw_hong}未开启${rw_lv}"
    local _swap_size="未设置"
    local _fw_stat="${rw_hong}未运行${rw_lv}"

    _ssh_port=$(grep -E '^ *Port [0-9]+' /etc/ssh/sshd_config 2>/dev/null | awk '{print $2}' | head -1)
    _ssh_port=${_ssh_port:-22}

    if grep -q "bbr" /proc/sys/net/ipv4/tcp_congestion_control 2>/dev/null; then
      _bbr_stat="${rw_lv}已开启${rw_lv}"
    fi

    _swap_size=$(free -m 2>/dev/null | awk 'NR==3{print $2}')
    if [ "$_swap_size" = "0" ] || [ -z "$_swap_size" ]; then
      _swap_size="${rw_hong}未设置${rw_lv}"
    else
      _swap_size="${rw_lv}${_swap_size}MB${rw_lv}"
    fi

    if $_CACHE_FIREWALLD_ACTIVE 2>/dev/null; then
      _fw_stat="${rw_lv}firewalld${rw_lv}"
    elif $_CACHE_UFW_ACTIVE 2>/dev/null; then
      _fw_stat="${rw_lv}ufw${rw_lv}"
    fi

    echo -e "${rw_cheng}━━━━━━━━━━━━  日常运维  ━━━━━━━━━━━━${rw_lv}"
    echo -e " 防火墙 ${_fw_stat}  SSH端口 ${rw_huang}${_ssh_port}${rw_lv}  BBR ${_bbr_stat}  虚拟内存 ${_swap_size}"
    echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
    echo ""
    echo -e " ${rw_cheng}──── 核心功能（最常用）────${rw_lv}"
    echo -e "  ${rw_huang}1${rw_lv}  安全加固             ${rw_huang}2${rw_lv}  性能优化"
    echo -e "  ${rw_huang}3${rw_lv}  网络管理             ${rw_huang}4${rw_lv}  系统配置"
    echo ""
    echo -e " ${rw_cheng}──── 系统维护 ────${rw_lv}"
    echo -e "  ${rw_huang}5${rw_lv}  系统更新             ${rw_huang}6${rw_lv}  系统清理"
    echo -e "  ${rw_huang}7${rw_lv}  硬盘分区             ${rw_huang}8${rw_lv}  备份与同步"
    echo ""
    echo -e " ${rw_cheng}──── 用户与工具 ────${rw_lv}"
    echo -e "  ${rw_huang}9${rw_lv}  用户管理            ${rw_huang}10${rw_lv} 高级工具"
    echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
    echo -e "  ${rw_huang}11${rw_lv} 定时任务管理         ${rw_huang}12${rw_lv} 一键重装系统"
    echo -e "  ${rw_huang}13${rw_lv} 重启服务器           ${rw_huang}14${rw_lv} 卸载Riou脚本"
    echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
    echo -e "  ${rw_huang}0${rw_lv}  返回主菜单"
    echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
    read -e -p " 请选择: " choice < /dev/tty

  case ${choice:-0} in
    1) _maint_security_menu ;;
    2) _maint_perf_menu ;;
    3) _maint_network_menu ;;
    4) _maint_config_menu ;;
    5) clear ; send_stats "系统更新" ; linux_update ;;
    6) clear ; send_stats "系统清理" ; linux_clean ;;
    7) disk_manager ;;
    8)
      # 备份与同步子菜单
      while true; do
        clear
        send_stats "备份与同步"
        echo -e "${rw_cheng}━━━━━━━━━━━━  备份与同步  ━━━━━━━━━━━━${rw_lv}"
        echo ""
        echo -e "  ${rw_huang}1${rw_lv}  文件管理器           ${rw_huang}2${rw_lv}  rsync同步"
        echo -e "  ${rw_huang}3${rw_lv}  备份与恢复"
        echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
        echo -e "  ${rw_huang}0${rw_lv}  返回日常运维"
        echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
        read -e -p " 请选择: " bk_choice < /dev/tty
        case ${bk_choice:-0} in
          1) linux_file ;;
          2) rsync_manager ;;
          3) linux_backup ;;
          0) break ;;
          *) echo "无效的输入!" ;;
        esac
        break_cancel
      done
      ;;
    9) _maint_user_menu ;;
    10) _maint_advanced_menu ;;
    11)
      send_stats "定时任务管理"
      while true; do
        clear
        check_crontab_installed
        clear
        echo "定时任务列表"
        crontab -l 2>/dev/null
        echo ""
        echo -e "${rw_cheng}------------------------${rw_lv}"
        echo "1. 添加定时任务          2. 删除定时任务          3. 编辑定时任务"
        echo -e "${rw_cheng}------------------------${rw_lv}"
        echo "0. 返回上一级"
        echo -e "${rw_cheng}------------------------${rw_lv}"
        read -e -p "请选择: " cron_sub_choice < /dev/tty
        case $cron_sub_choice in
          1)
            read -e -p "请输入新任务的执行命令: " newquest < /dev/tty
            echo -e "${rw_cheng}------------------------${rw_lv}"
            echo "1. 每月任务                 2. 每周任务"
            echo "3. 每天任务                 4. 每小时任务"
            echo -e "${rw_cheng}------------------------${rw_lv}"
            read -e -p "请选择: " dingshi < /dev/tty
            case $dingshi in
              1) read -e -p "选择每月的几号执行任务？ (1-30): " day < /dev/tty ; (crontab -l ; echo "0 0 $day * * $newquest") | crontab - > /dev/null 2>&1 ;;
              2) read -e -p "选择周几执行任务？ (0-6，0代表星期日): " weekday < /dev/tty ; (crontab -l ; echo "0 0 * * $weekday $newquest") | crontab - > /dev/null 2>&1 ;;
              3) read -e -p "选择每天几点执行任务？（小时，0-23）: " hour < /dev/tty ; (crontab -l ; echo "0 $hour * * * $newquest") | crontab - > /dev/null 2>&1 ;;
              4) read -e -p "输入每小时的第几分钟执行任务？（分钟，0-60）: " minute < /dev/tty ; (crontab -l ; echo "$minute * * * * $newquest") | crontab - > /dev/null 2>&1 ;;
              *) break ;;
            esac
            send_stats "添加定时任务"
            ;;
          2) read -e -p "请输入需要删除任务的关键字: " kquest < /dev/tty ; crontab -l | grep -v "$kquest" | crontab - ; send_stats "删除定时任务" ;;
          3) crontab -e ; send_stats "编辑定时任务" ;;
          *) break ;;
        esac
      done
      ;;
    12) dd_xitong ;;
    13)
      clear
      send_stats "重启系统"
      server_reboot
      ;;
    14)
      clear
      send_stats "卸载Riou脚本"
      echo "卸载Riou脚本"
      echo -e "${rw_cheng}------------------------------------------------${rw_lv}"
      echo "将彻底卸载riwi脚本，不影响其他功能"
      read -e -p "确定继续吗？(Y/N): " choice < /dev/tty
      case "$choice" in
        [Yy])
          clear
          (crontab -l | grep -v "riwi.sh") | crontab -
          rm -f /usr/local/bin/r
          rm -f ~/riwi.sh
          echo "脚本已卸载，再见！"
          break_end
          clear
          exit
          ;;
        [Nn]) echo "已取消" ;;
        *) echo "无效的选择" ;;
      esac
      ;;
    0) break ;;
    *) echo "无效的输入!" ;;
  esac
  break_cancel
done
}



# SSH 免密登录权限检查与修复
ssh_key_permission_check() {
  root_use
  send_stats "SSH免密登录权限检查"

  clear
  echo -e "${rw_cheng}╔══════════════════════════════════════════════════════════════╗${rw_lv}"
  echo -e "${rw_cheng}║           SSH 免密登录权限检查与修复工具                     ║${rw_lv}"
  echo -e "${rw_cheng}╚══════════════════════════════════════════════════════════════╝${rw_lv}"
  echo ""

  # 列出系统中所有有 .ssh 目录的用户
  echo -e "${rw_huang}正在扫描系统中存在 SSH 配置的用户...${rw_lv}"
  echo ""

  local found_any=0
  while IFS=: read -r username _ uid _ _ _ homedir shell; do
    # 跳过系统用户（UID < 1000 且不是 root）
    [[ "$uid" -lt 1000 && "$username" != "root" ]] && continue
    # 跳过无家目录或家目录不存在的用户
    [[ -z "$homedir" || ! -d "$homedir" ]] && continue

    local ssh_dir="${homedir}/.ssh"
    local auth_keys="${ssh_dir}/authorized_keys"

    if [[ -d "$ssh_dir" ]]; then
      found_any=1
      echo -e "${rw_cheng}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${rw_lv}"
      echo -e "  用户: ${rw_huang}${username}${rw_lv}  (UID: ${uid})"
      echo -e "  家目录: ${homedir}"
      echo ""

      # 1. 检查 .ssh 目录权限 (应为 700 / drwx------)
      local ssh_perm=$(stat -c "%a" "$ssh_dir" 2>/dev/null)
      local ssh_perm_display=$(stat -c "%A" "$ssh_dir" 2>/dev/null)
      echo -ne "  .ssh 目录权限: ${ssh_perm_display} (${ssh_perm})  →  "
      if [[ "$ssh_perm" == "700" ]]; then
        echo -e "${rw_lv}✓ 正确${rw_lv}"
      else
        echo -e "${rw_hong}✗ 应修复为 700 (drwx------)${rw_lv}"
      fi

      # 2. 检查 .ssh 目录所有者
      local ssh_owner=$(stat -c "%U:%G" "$ssh_dir" 2>/dev/null)
      echo -ne "  .ssh 目录所有者: ${ssh_owner}  →  "
      if [[ "$ssh_owner" == "${username}:"* ]]; then
        echo -e "${rw_lv}✓ 正确${rw_lv}"
      else
        echo -e "${rw_hong}✗ 应修复为 ${username}:${username}${rw_lv}"
      fi

      # 3. 检查 authorized_keys 文件
      if [[ -f "$auth_keys" ]]; then
        local ak_perm=$(stat -c "%a" "$auth_keys" 2>/dev/null)
        local ak_perm_display=$(stat -c "%A" "$auth_keys" 2>/dev/null)
        local ak_owner=$(stat -c "%U:%G" "$auth_keys" 2>/dev/null)
        local key_count=$(grep -cE '^(ssh-rsa|ssh-ed25519|ssh-ecdsa|ecdsa-sha2)' "$auth_keys" 2>/dev/null)

        echo ""
        echo -e "  ${rw_huang}authorized_keys 文件:${rw_lv}"
        echo -ne "    权限: ${ak_perm_display} (${ak_perm})  →  "
        if [[ "$ak_perm" == "600" ]]; then
          echo -e "${rw_lv}✓ 正确${rw_lv}"
        else
          echo -e "${rw_hong}✗ 应修复为 600 (-rw-------)${rw_lv}"
        fi

        echo -ne "    所有者: ${ak_owner}  →  "
        if [[ "$ak_owner" == "${username}:"* ]]; then
          echo -e "${rw_lv}✓ 正确${rw_lv}"
        else
          echo -e "${rw_hong}✗ 应修复为 ${username}:${username}${rw_lv}"
        fi

        echo -e "    公钥数量: ${rw_lv}${key_count}${rw_lv} 个"
      else
        echo ""
        echo -e "  ${rw_huang}authorized_keys: ${rw_hong}文件不存在${rw_lv}"
      fi
    fi
  done < /etc/passwd

  if [[ "$found_any" -eq 0 ]]; then
    echo -e "${rw_huang}系统中未发现任何用户的 .ssh 配置目录。${rw_lv}"
  fi

  echo ""
  echo -e "${rw_cheng}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${rw_lv}"
  echo ""
  echo -e "${rw_cheng}------------------------${rw_lv}"
  echo "1. 一键修复所有权限问题"
  echo "2. 修复指定用户"
  echo -e "${rw_cheng}------------------------${rw_lv}"
  echo "0. 返回上一级选单"
  echo -e "${rw_cheng}------------------------${rw_lv}"
  read -e -p "请输入你的选择: " fix_choice

  case $fix_choice in
    1)
      echo ""
      echo -e "${rw_huang}正在一键修复所有用户的 SSH 权限...${rw_lv}"
      while IFS=: read -r username _ uid _ _ _ homedir shell; do
        [[ "$uid" -lt 1000 && "$username" != "root" ]] && continue
        [[ -z "$homedir" || ! -d "$homedir" ]] && continue
        local ssh_dir="${homedir}/.ssh"

        if [[ -d "$ssh_dir" ]]; then
          chmod 700 "$ssh_dir"
          chown -R "${username}:${username}" "$ssh_dir"
          [[ -f "${ssh_dir}/authorized_keys" ]] && chmod 600 "${ssh_dir}/authorized_keys"
          echo -e "  ${rw_lv}✓ 已修复用户 ${username}${rw_lv}"
        fi
      done < /etc/passwd
      echo ""
      echo -e "${rw_lv}全部修复完成！${rw_lv}"
      ;;
    2)
      echo ""
      read -e -p "请输入要修复的用户名: " target_user
      if ! id "$target_user" &>/dev/null; then
        echo -e "${rw_hong}错误：用户 $target_user 不存在！${rw_lv}"
      else
        local target_home=$(eval echo "~$target_user")
        local target_ssh="${target_home}/.ssh"
        if [[ -d "$target_ssh" ]]; then
          chmod 700 "$target_ssh"
          chown -R "${target_user}:${target_user}" "$target_ssh"
          [[ -f "${target_ssh}/authorized_keys" ]] && chmod 600 "${target_ssh}/authorized_keys"
          echo -e "${rw_lv}✓ 已修复用户 ${target_user} 的 SSH 权限${rw_lv}"
        else
          echo -e "${rw_huang}用户 ${target_user} 没有 .ssh 目录，无需修复${rw_lv}"
        fi
      fi
      ;;
    *)
      ;;
  esac

  echo ""
  echo -e "${rw_huang}💡 安全说明：${rw_lv}"
  echo -e "  • .ssh 目录权限必须为 ${rw_lv}700 (drwx------)${rw_lv}，否则 SSH 拒绝使用密钥"
  echo -e "  • authorized_keys 权限必须为 ${rw_lv}600 (-rw-------)${rw_lv}，否则 SSH 拒绝免密登录"
  echo -e "  • .ssh 目录及 authorized_keys 的所有者必须为用户本人"
  echo -e "  • 以上三项全部正确，才能正常使用 SSH 密钥免密登录"
  break_end
}



riwi_sh() {

# ── 首次运行许可协议检查 ──
if [ ! -f ~/.riwi_license_agreed ]; then
	clear
	echo -e "${rw_cheng}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${rw_lv}"
	echo -e "${rw_lv}  欢迎使用 Riou 脚本工具箱${rw_lv}"
	echo -e "${rw_cheng}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${rw_lv}"
	echo ""
	echo -e "  首次使用脚本，请先阅读并同意用户许可协议。"
	echo ""
	echo -e "  用户许可协议: ${rw_huang}https://github.com/riwi002/mybox/blob/main/LICENSE${rw_lv}"
	echo -e "${rw_cheng}────────────────────────────────────────────────${rw_lv}"
	echo ""
	read -e -p "  是否同意以上条款？(y/n): " _license_agree < /dev/tty
	if [ "$_license_agree" = "y" ] || [ "$_license_agree" = "Y" ]; then
		touch ~/.riwi_license_agreed
		echo -e "\n  ${rw_lv}感谢同意！即将进入脚本...${rw_lv}"
		sleep 1
	else
		echo -e "\n  ${rw_hong}未同意许可协议，脚本退出。${rw_lv}"
		exit 1
	fi
fi

while true; do
clear
echo -e "$(orange "Riou脚本工具箱 v$sh_v")"
echo -e "命令行输入$(orange "r")可快速启动脚本${rw_lv}"
echo -e "${rw_cheng}------------------------${rw_lv}"
echo -e "${rw_huang}1.   ${rw_lv}${rw_lv}系统查询${rw_lv}"
echo -e "${rw_huang}2.   ${rw_lv}${rw_lv}日常运维${rw_lv}"
echo -e "${rw_huang}3.   ${rw_lv}${rw_lv}环境配置${rw_lv}"
echo -e "${rw_huang}4.   ${rw_lv}${rw_lv}版本控制${rw_lv}"
echo -e "${rw_huang}5.   ${rw_lv}${rw_lv}应用市场${rw_lv}"
echo -e "${rw_huang}6.   ${rw_lv}${rw_lv}常用快捷${rw_lv}"
echo -e "${rw_huang}7.   ${rw_lv}${rw_lv}综合管理${rw_lv}"
echo -e "${rw_huang}8.   ${rw_lv}${rw_lv}后台工作${rw_lv}"
echo -e "${rw_huang}9.   ${rw_lv}${rw_lv}容器管理${rw_lv}"
echo -e "${rw_huang}10.  ${rw_lv}${rw_lv}建站部署${rw_lv}"
echo -e "${rw_huang}11.  ${rw_lv}${rw_lv}集群控制${rw_lv}"
echo -e "${rw_huang}12.  ${rw_lv}${rw_lv}密钥管理${rw_lv}"
echo -e "${rw_huang}13.  ${rw_lv}${rw_lv}跑分测评${rw_lv}"
echo -e "${rw_cheng}------------------------${rw_lv}"
echo -e "${rw_huang}0.   ${rw_lv}${rw_lv}退出脚本${rw_lv}"
echo -e "${rw_cheng}------------------------${rw_lv}"
read -e -p "请输入你的选择: " choice

case $choice in
  1) linux_info ;;
  2) update_clean_menu ;;
  3) linux_tools ;;
  4) github_manager ;;
  5) linux_panel ;;
  6) linux_quick_tools ;;
  7) other_panel_manager ;;
  8) linux_work ;;
  9) docker_manager_menu ;;
  10) ldnmp_builder_menu ;;
  11) linux_cluster ;;
  12) user_manager ;;
  13) run_zbench ;;
  0) clear ; exit ;;
  *) echo "无效的输入!" ;;
esac
	break_cancel
done
}

# ================================================================
# 用户管理器
# ================================================================

# ── root 管理 ──
root_manager() {
while true; do
	clear

	# ── 状态面板: 列出当前普通用户 ──
	echo -e "${rw_cheng}━━━━━━━━━━━━  创建用户  ━━━━━━━━━━━━${rw_lv}"
	echo ""
	echo -e " ${rw_cheng}── 当前普通用户（uid≥1000）──${rw_lv}"
	local _has_user=0
	while IFS=: read -r _u _p _uid _gid _gcos _home _shell; do
		[ "$_uid" -lt 1000 ] && [ "$_u" != "root" ] && continue
		[ -n "$_shell" ] || continue
		local _sudo_mark=""
		if getent group sudo 2>/dev/null | grep -q "$_u" || \
		   getent group wheel 2>/dev/null | grep -q "$_u"; then
			_sudo_mark="${rw_lv}[sudo]${rw_lv}"
		fi
		local _pw_mark=""
		[ -n "$_p" ] && [ "$_p" != "x" ] && [ "$_p" != "*" ] && [ "$_p" != "!" ] && _pw_mark="${rw_lv}[有密码]${rw_lv}"
		printf "  ${rw_huang}%-12s${rw_lv}  uid=%-6s  shell=%-12s %s %s\n" "$_u" "$_uid" "$(basename "$_shell")" "$_sudo_mark" "$_pw_mark"
		_has_user=1
	done </etc/passwd 2>/dev/null
	[ $_has_user -eq 0 ] && echo -e "  ${rw_huang}暂无普通用户${rw_lv}"
	echo ""

	echo -e " ${rw_cheng}──── 用户管理 ────${rw_lv}"
	echo -e " ${rw_huang}1.   ${rw_lv}创建普通用户${rw_lv}"
	echo -e " ${rw_huang}2.   ${rw_lv}为用户设置密码${rw_lv}"
	echo -e " ${rw_huang}3.   ${rw_lv}为用户设置 sudo 权限${rw_lv}"
	echo -e " ${rw_huang}4.   ${rw_lv}撤销用户 sudo 权限${rw_lv}"
	echo -e " ${rw_huang}5.   ${rw_lv}删除用户${rw_lv}"
	echo -e " ${rw_huang}6.   ${rw_lv}修改用户 Shell${rw_lv}"
	echo ""
	echo -e " ${rw_cheng}──── 查看 ────${rw_lv}"
	echo -e " ${rw_huang}7.   ${rw_lv}查看 sudo 权限用户${rw_lv}"
	echo -e " ${rw_huang}8.   ${rw_lv}查看所有用户详情${rw_lv}"
	echo ""
	echo -e " ${rw_cheng}──── SSH 设置 ────${rw_lv}"
	echo -e " ${rw_huang}9.   ${rw_lv}SSH 设置（端口/root登录/密码认证/安全项）${rw_lv}"
	echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
	echo -e " ${rw_huang}0.   ${rw_lv}返回上级菜单${rw_lv}"
	echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
	read -e -p " 请输入你的选择: " _rm_choice

	case $_rm_choice in
	  1)
		# ── 创建普通用户 ──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 创建普通用户 ━━━━━━${rw_lv}"
		echo ""
		read -e -p " 请输入用户名: " _newuser < /dev/tty
		if [ -z "$_newuser" ]; then
			red "用户名不能为空"
			break_end
			continue
		fi
		if id "$_newuser" &>/dev/null; then
			yellow "用户 $_newuser 已存在"
			break_end
			continue
		fi
		# 选 shell
		echo ""
		echo -e " Shell 选择:"
		echo -e " ${rw_huang}1.${rw_lv} /bin/bash（默认，推荐）"
		echo -e " ${rw_huang}2.${rw_lv} /bin/sh"
		echo -e " ${rw_huang}3.${rw_lv} /usr/sbin/nologin（不允许登录）"
		read -e -p " 请选择（默认1）: " _shell_choice < /dev/tty
		_shell_choice="${_shell_choice:-1}"
		local _user_shell="/bin/bash"
		case $_shell_choice in
			2) _user_shell="/bin/sh" ;;
			3) _user_shell="/usr/sbin/nologin" ;;
		esac
		# 创建
		useradd -m -s "$_user_shell" "$_newuser"
		if [ $? -ne 0 ]; then
			red "创建失败"
			break_end
			continue
		fi
		green "✓ 用户 $_newuser 创建成功 (shell: $_user_shell)"
		# 询问是否设密码
		echo ""
		read -e -p " 是否立即设置密码？(y/N): " _setpw < /dev/tty
		if [[ "$_setpw" =~ ^[Yy]$ ]]; then
			passwd "$_newuser"
		fi
		# 询问是否加 sudo
		echo ""
		read -e -p " 是否赋予 sudo 权限？(y/N): " _setsudo < /dev/tty
		if [[ "$_setsudo" =~ ^[Yy]$ ]]; then
			usermod -aG sudo "$_newuser" 2>/dev/null || usermod -aG wheel "$_newuser" 2>/dev/null
			green "✓ 已为 $_newuser 添加 sudo 权限"
		fi
		;;
	  2)
		# ── 设置密码 ──
		echo ""
		# 列出用户供选择
		echo -e " ${rw_cheng}── 可选用户 ──${rw_lv}"
		local _users=()
		local _ui=1
		while IFS=: read -r _u _p _uid _gid _gcos _home _shell; do
			[ "$_uid" -lt 1000 ] && [ "$_u" != "root" ] && continue
			[ -n "$_shell" ] || continue
			echo -e " ${rw_huang}${_ui}.${rw_lv} $_u"
			_users+=("$_u")
			((_ui++))
		done </etc/passwd
		echo -e " ${rw_huang}${_ui}.${rw_lv} root"
		_users+=("root")
		echo -e " ${rw_huang}0.${rw_lv} 取消"
		echo ""
		read -e -p " 请选择: " _idx < /dev/tty
		[ "$_idx" = "0" ] && continue
		[ -z "$_idx" ] && { red "无效选择"; break_end; continue; }
		local _target=""
		_ui=1
		for _u in "${_users[@]}"; do
			[ "$_ui" -eq "$_idx" ] && { _target="$_u"; break; }
			((_ui++))
		done
		[ -z "$_target" ] && { red "无效选择"; break_end; continue; }
		echo ""
		passwd "$_target"
		;;
	  3)
		# ── 设置 sudo 权限 ──
		echo ""
		echo -e " ${rw_cheng}── 选择用户 ──${rw_lv}"
		local _users=()
		local _ui=1
		while IFS=: read -r _u _p _uid _gid _gcos _home _shell; do
			[ "$_uid" -lt 1000 ] && [ "$_u" != "root" ] && continue
			[ -n "$_shell" ] || continue
			local _m=""
			if getent group sudo 2>/dev/null | grep -q "$_u" || \
			   getent group wheel 2>/dev/null | grep -q "$_u"; then
				_m="${rw_lv}[已有sudo]${rw_lv}"
			fi
			echo -e " ${rw_huang}${_ui}.${rw_lv} $_u $_m"
			_users+=("$_u")
			((_ui++))
		done </etc/passwd
		echo -e " ${rw_huang}0.${rw_lv} 取消"
		echo ""
		read -e -p " 请选择: " _idx < /dev/tty
		[ "$_idx" = "0" ] && continue
		[ -z "$_idx" ] && { red "无效选择"; break_end; continue; }
		local _target=""
		_ui=1
		for _u in "${_users[@]}"; do
			[ "$_ui" -eq "$_idx" ] && { _target="$_u"; break; }
			((_ui++))
		done
		[ -z "$_target" ] && { red "无效选择"; break_end; continue; }
		usermod -aG sudo "$_target" 2>/dev/null || usermod -aG wheel "$_target" 2>/dev/null
		green "✓ 已为 $_target 添加 sudo 权限"
		;;
	  4)
		# ── 撤销 sudo 权限 ──
		echo ""
		echo -e " ${rw_cheng}── 当前 sudo 用户 ──${rw_lv}"
		local _sudo_users=""
		_sudo_users=$(getent group sudo 2>/dev/null | awk -F: '{print $4}' | tr ',' '\n')
		[ -z "$_sudo_users" ] && _sudo_users=$(getent group wheel 2>/dev/null | awk -F: '{print $4}' | tr ',' '\n')
		if [ -z "$_sudo_users" ]; then
			yellow "  暂无 sudo 用户"
			break_end
			continue
		fi
		local _users=()
		local _ui=1
		while IFS= read -r _u; do
			[ -n "$_u" ] && {
				echo -e " ${rw_huang}${_ui}.${rw_lv} $_u"
				_users+=("$_u")
				((_ui++))
			}
		done <<< "$_sudo_users"
		echo -e " ${rw_huang}0.${rw_lv} 取消"
		echo ""
		read -e -p " 请选择要撤销的用户: " _idx < /dev/tty
		[ "$_idx" = "0" ] && continue
		[ -z "$_idx" ] && { red "无效选择"; break_end; continue; }
		local _target=""
		_ui=1
		for _u in "${_users[@]}"; do
			[ "$_ui" -eq "$_idx" ] && { _target="$_u"; break; }
			((_ui++))
		done
		[ -z "$_target" ] && { red "无效选择"; break_end; continue; }
		read -e -p " 确认撤销 $_target 的 sudo 权限？(y/N): " _confirm < /dev/tty
		if [[ "$_confirm" =~ ^[Yy]$ ]]; then
			gpasswd -d "$_target" sudo 2>/dev/null
			gpasswd -d "$_target" wheel 2>/dev/null
			green "✓ 已撤销 $_target 的 sudo 权限"
		else
			yellow "已取消"
		fi
		;;
	  5)
		# ── 删除用户 ──
		echo ""
		echo -e " ${rw_cheng}── 选择要删除的用户 ──${rw_lv}"
		local _users=()
		local _ui=1
		while IFS=: read -r _u _p _uid _gid _gcos _home _shell; do
			[ "$_uid" -lt 1000 ] && [ "$_u" != "root" ] && continue
			[ -n "$_shell" ] || continue
			echo -e " ${rw_huang}${_ui}.${rw_lv} $_u → ${_home}"
			_users+=("$_u")
			((_ui++))
		done </etc/passwd
		echo -e " ${rw_huang}0.${rw_lv} 取消"
		echo ""
		read -e -p " 请选择: " _idx < /dev/tty
		[ "$_idx" = "0" ] && continue
		[ -z "$_idx" ] && { red "无效选择"; break_end; continue; }
		local _target=""
		_ui=1
		for _u in "${_users[@]}"; do
			[ "$_ui" -eq "$_idx" ] && { _target="$_u"; break; }
			((_ui++))
		done
		[ -z "$_target" ] && { red "无效选择"; break_end; continue; }
		echo ""
		echo -e " ${rw_hong}⚠ 将删除用户 $_target${rw_lv}"
		echo -e " ${rw_huang}1.${rw_lv} 仅删除用户（保留 home 目录）"
		echo -e " ${rw_huang}2.${rw_lv} 删除用户 + home 目录"
		echo -e " ${rw_huang}0.${rw_lv} 取消"
		read -e -p " 请选择: " _del_mode < /dev/tty
		case $_del_mode in
			1)
				userdel "$_target" && green "✓ 已删除用户 $_target（home 保留）" || red "删除失败"
				;;
			2)
				read -e -p " 确认删除 $_target 及其 home 目录？(yes确认): " _confirm < /dev/tty
				if [ "$_confirm" = "yes" ]; then
					userdel -r "$_target" && green "✓ 已删除用户 $_target 及 home 目录" || red "删除失败"
				else
					yellow "已取消"
				fi
				;;
			*) yellow "已取消" ;;
		esac
		;;
	  6)
		# ── 修改用户 Shell ──
		echo ""
		echo -e " ${rw_cheng}── 选择用户 ──${rw_lv}"
		local _users=()
		local _ui=1
		while IFS=: read -r _u _p _uid _gid _gcos _home _shell; do
			[ "$_uid" -lt 1000 ] && [ "$_u" != "root" ] && continue
			[ -n "$_shell" ] || continue
			echo -e " ${rw_huang}${_ui}.${rw_lv} $_u  (当前: $_shell)"
			_users+=("$_u")
			((_ui++))
		done </etc/passwd
		echo -e " ${rw_huang}0.${rw_lv} 取消"
		echo ""
		read -e -p " 请选择: " _idx < /dev/tty
		[ "$_idx" = "0" ] && continue
		[ -z "$_idx" ] && { red "无效选择"; break_end; continue; }
		local _target=""
		_ui=1
		for _u in "${_users[@]}"; do
			[ "$_ui" -eq "$_idx" ] && { _target="$_u"; break; }
			((_ui++))
		done
		[ -z "$_target" ] && { red "无效选择"; break_end; continue; }
		echo ""
		echo -e " Shell 选择:"
		echo -e " ${rw_huang}1.${rw_lv} /bin/bash"
		echo -e " ${rw_huang}2.${rw_lv} /bin/sh"
		echo -e " ${rw_huang}3.${rw_lv} /usr/sbin/nologin（不允许登录）"
		echo -e " ${rw_huang}4.${rw_lv} /bin/zsh"
		read -e -p " 请选择: " _sc < /dev/tty
		local _new_shell=""
		case $_sc in
			1) _new_shell="/bin/bash" ;;
			2) _new_shell="/bin/sh" ;;
			3) _new_shell="/usr/sbin/nologin" ;;
			4) _new_shell="/bin/zsh" ;;
			*) yellow "已取消"; break_cancel; continue ;;
		esac
		usermod -s "$_new_shell" "$_target" && green "✓ $_target 的 shell 已改为 $_new_shell" || red "修改失败"
		;;
	  7)
		# ── 查看 sudo 用户 ──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 当前 sudo 权限用户 ━━━━━━${rw_lv}"
		echo ""
		local _sudo_users=""
		_sudo_users=$(getent group sudo 2>/dev/null | awk -F: '{print $4}' | tr ',' '\n')
		[ -z "$_sudo_users" ] && _sudo_users=$(getent group wheel 2>/dev/null | awk -F: '{print $4}' | tr ',' '\n')
		if [ -n "$_sudo_users" ]; then
			while IFS= read -r _u; do
				[ -n "$_u" ] && echo -e "   ${rw_lv}✓${rw_lv}  ${_u}"
			done <<< "$_sudo_users"
		else
			echo -e "   ${rw_huang}暂无 sudo 权限用户${rw_lv}"
		fi
		;;
	  8)
		# ── 查看所有用户详情 ──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 所有用户详情 ━━━━━━${rw_lv}"
		echo ""
		printf "  ${rw_huang}%-12s %-6s %-10s %-20s %s${rw_lv}\n" "用户名" "UID" "Shell" "HOME" "备注"
		while IFS=: read -r _u _p _uid _gid _gcos _home _shell; do
			[ "$_uid" -lt 1000 ] && [ "$_u" != "root" ] && continue
			[ -n "$_shell" ] || continue
			local _note=""
			if getent group sudo 2>/dev/null | grep -q "$_u" || \
			   getent group wheel 2>/dev/null | grep -q "$_u"; then
				_note="sudo"
			fi
			[ -n "$_p" ] && [ "$_p" != "x" ] && [ "$_p" != "*" ] && [ "$_p" != "!" ] && _note="${_note} 有密码"
			printf "  %-12s %-6s %-10s %-20s %s\n" "$_u" "$_uid" "$(basename "$_shell")" "$_home" "$_note"
		done </etc/passwd
		;;
	  9)
		# ── SSH 设置 ──
		ssh_config_manager
		;;
	  0)
		break
		;;
	  *)
		red "无效的输入!"
		;;
	esac
	break_cancel
done
}

# ================================================================
# SSH 设置管理器
# 功能: 端口 / root 登录 / 密码认证 / 公钥认证 / 安全加固 / 重启
# ================================================================
ssh_config_manager() {
while true; do
	clear

	# ── 读取当前状态 ──
	local _ssh_port _root_login _pass_auth _pubkey_auth _maxauth _ssh_status
	_ssh_port=$(grep -E '^#?Port[[:space:]]+' /etc/ssh/sshd_config 2>/dev/null | awk '{print $2}' | head -1)
	_ssh_port="${_ssh_port:-22}"

	_root_login="未设置"
	grep -qE '^PermitRootLogin[[:space:]]+yes' /etc/ssh/sshd_config 2>/dev/null && _root_login="${rw_hong}允许${rw_lv}"
	grep -qE '^PermitRootLogin[[:space:]]+no' /etc/ssh/sshd_config 2>/dev/null && _root_login="${rw_lv}禁止${rw_lv}"
	grep -qE '^PermitRootLogin[[:space:]]+prohibit-password' /etc/ssh/sshd_config 2>/dev/null && _root_login="${rw_huang}仅密钥${rw_lv}"

	_pass_auth="未设置"
	grep -qE '^PasswordAuthentication[[:space:]]+yes' /etc/ssh/sshd_config 2>/dev/null && _pass_auth="${rw_hong}允许${rw_lv}"
	grep -qE '^PasswordAuthentication[[:space:]]+no' /etc/ssh/sshd_config 2>/dev/null && _pass_auth="${rw_lv}禁止${rw_lv}"

	_pubkey_auth="未设置"
	grep -qE '^PubkeyAuthentication[[:space:]]+yes' /etc/ssh/sshd_config 2>/dev/null && _pubkey_auth="${rw_lv}允许${rw_lv}"
	grep -qE '^PubkeyAuthentication[[:space:]]+no' /etc/ssh/sshd_config 2>/dev/null && _pubkey_auth="${rw_hong}禁止${rw_lv}"

	_maxauth=$(grep -E '^#?MaxAuthTries[[:space:]]+' /etc/ssh/sshd_config 2>/dev/null | awk '{print $2}' | head -1)
	_maxauth="${_maxauth:-6}"

	if systemctl is-active --quiet sshd 2>/dev/null || systemctl is-active --quiet ssh 2>/dev/null; then
		_ssh_status="${rw_lv}运行中${rw_lv}"
	else
		_ssh_status="${rw_hong}未运行${rw_lv}"
	fi

	echo -e "${rw_cheng}━━━━━━━━━━━━  SSH 设置  ━━━━━━━━━━━━${rw_lv}"
	echo -e " 端口: ${rw_huang}${_ssh_port}${rw_lv}   服务: ${_ssh_status}"
	echo -e " Root登录: ${_root_login}   密码: ${_pass_auth}   公钥: ${_pubkey_auth}"
	echo -e " 最大尝试: ${rw_huang}${_maxauth}${rw_lv}"
	echo ""
	echo -e " ${rw_cheng}──── 基本设置 ────${rw_lv}"
	echo -e " ${rw_huang}1.   ${rw_lv}修改 SSH 端口${rw_lv}"
	echo -e " ${rw_huang}2.   ${rw_lv}Root 登录设置${rw_lv}"
	echo -e " ${rw_huang}3.   ${rw_lv}密码认证设置${rw_lv}"
	echo -e " ${rw_huang}4.   ${rw_lv}公钥认证设置${rw_lv}"
	echo -e " ${rw_huang}5.   ${rw_lv}限制认证尝试次数${rw_lv}"
	echo ""
	echo -e " ${rw_cheng}──── 安全加固 ────${rw_lv}"
	echo -e " ${rw_huang}6.   ${rw_lv}禁止 root SSH 登录${rw_lv}"
	echo -e " ${rw_huang}7.   ${rw_lv}禁止密码登录（仅密钥）${rw_lv}"
	echo -e " ${rw_huang}8.   ${rw_lv}禁用端口转发/X11${rw_lv}"
	echo -e " ${rw_huang}9.   ${rw_lv}限制登录用户/组（AllowUsers/AllowGroups）${rw_lv}"
	echo ""
	echo -e " ${rw_cheng}──── 服务管理 ────${rw_lv}"
	echo -e " ${rw_huang}10.  ${rw_lv}查看当前 SSH 配置${rw_lv}"
	echo -e " ${rw_huang}11.  ${rw_lv}测试配置语法 (sshd -t)${rw_lv}"
	echo -e " ${rw_huang}12.  ${rw_lv}重启 SSH 服务${rw_lv}"
	echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
	echo -e " ${rw_huang}0.   ${rw_lv}返回上级菜单${rw_lv}"
	echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
	read -e -p " 请输入你的选择: " _sc_choice

	case $_sc_choice in
	  1)
		# ── 修改端口 ──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 修改 SSH 端口 ━━━━━━${rw_lv}"
		echo -e " 当前端口: ${rw_huang}${_ssh_port}${rw_lv}"
		echo ""
		read -e -p " 新端口号（1-65535）: " _new_port < /dev/tty
		if [ -z "$_new_port" ]; then
			red "不能为空"
			break_end
			continue
		fi
		if ! [[ "$_new_port" =~ ^[0-9]+$ ]] || [ "$_new_port" -lt 1 ] || [ "$_new_port" -gt 65535 ]; then
			red "无效端口号"
			break_end
			continue
		fi
		_ssh_backup_configs
		if grep -qE '^#?Port[[:space:]]+' /etc/ssh/sshd_config; then
			sed -i -E "s/^#?Port[[:space:]]+.*/Port ${_new_port}/" /etc/ssh/sshd_config
		else
			echo "Port ${_new_port}" >> /etc/ssh/sshd_config
		fi
		green "✓ 端口已改为 ${_new_port}"
		echo -e " ${rw_hong}⚠ 记得放行防火墙/安全组的 ${_new_port} 端口！${rw_lv}"
		_ssh_apply_and_restart
		;;
	  2)
		# ── Root 登录设置 ──
		echo ""
		echo -e "${rw_cheng}━━━━━━ Root 登录设置 ━━━━━━${rw_lv}"
		echo -e " 当前: ${_root_login}"
		echo ""
		echo -e " ${rw_huang}1.${rw_lv} 允许 root 登录（含密码）"
		echo -e " ${rw_huang}2.${rw_lv} 仅允许 root 密钥登录（prohibit-password）"
		echo -e " ${rw_huang}3.${rw_lv} 禁止 root SSH 登录"
		echo -e " ${rw_huang}0.${rw_lv} 取消"
		read -e -p " 请选择: " _rl < /dev/tty
		local _rl_val=""
		case $_rl in
			1) _rl_val="yes" ;;
			2) _rl_val="prohibit-password" ;;
			3) _rl_val="no" ;;
			*) continue ;;
		esac
		_ssh_backup_configs
		_ssh_cfg_set PermitRootLogin "$_rl_val"
		green "✓ PermitRootLogin 已设为 $_rl_val"
		_ssh_apply_and_restart
		;;
	  3)
		# ── 密码认证设置 ──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 密码认证设置 ━━━━━━${rw_lv}"
		echo -e " 当前: ${_pass_auth}"
		echo ""
		echo -e " ${rw_huang}1.${rw_lv} 允许密码登录"
		echo -e " ${rw_huang}2.${rw_lv} 禁止密码登录（仅密钥）"
		echo -e " ${rw_huang}0.${rw_lv} 取消"
		read -e -p " 请选择: " _pa < /dev/tty
		local _pa_val=""
		case $_pa in
			1) _pa_val="yes" ;;
			2)
			_pa_val="no"
			# 禁用密码全局生效，审计所有可登录用户是否都有公钥
			_ssh_audit_auth_users
			echo ""
			echo -e " ${rw_cheng}── 公钥审计（禁用密码后将仅靠公钥登录）──${rw_lv}"
			echo -e "   可登录用户: ${rw_huang}${_AUDIT_USERS}${rw_lv}    有公钥: ${rw_huang}${_AUDIT_HAS_PUBKEY}${rw_lv}"
			if [ $_AUDIT_USERS -gt 0 ] && [ $_AUDIT_HAS_PUBKEY -lt $_AUDIT_USERS ]; then
				echo -e " ${rw_hong}⚠ 以下用户没有公钥，禁用密码后将无法 SSH 登录：${rw_lv}"
				echo "$_AUDIT_MISSING" | grep '无公钥' | sed 's/^/   /'
				echo ""
				echo -e " ${rw_huang}请先到「密钥管理 → 公钥配置」为这些用户部署公钥${rw_lv}"
				read -e -p " 仍要禁用密码？(yes确认): " _confirm < /dev/tty
				[ "$_confirm" != "yes" ] && { yellow "已取消"; break_cancel; continue; }
			elif [ $_AUDIT_USERS -eq 0 ]; then
				echo -e " ${rw_hong}⚠ 未发现可登录用户，禁用密码有锁死风险${rw_lv}"
				read -e -p " 仍要禁用密码？(yes确认): " _confirm < /dev/tty
				[ "$_confirm" != "yes" ] && { yellow "已取消"; break_cancel; continue; }
			else
				green "✓ 所有可登录用户均已配置公钥"
			fi
			;;
			*) continue ;;
		esac
		_ssh_backup_configs
		_ssh_cfg_set PasswordAuthentication "$_pa_val"
		green "✓ PasswordAuthentication 已设为 $_pa_val"
		_ssh_apply_and_restart
		;;
	  4)
		# ── 公钥认证设置 ──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 公钥认证设置 ━━━━━━${rw_lv}"
		echo -e " 当前: ${_pubkey_auth}"
		echo ""
		echo -e " ${rw_huang}1.${rw_lv} 允许公钥登录"
		echo -e " ${rw_huang}2.${rw_lv} 禁止公钥登录"
		echo -e " ${rw_huang}0.${rw_lv} 取消"
		read -e -p " 请选择: " _pk < /dev/tty
		local _pk_val=""
		case $_pk in
			1) _pk_val="yes" ;;
			2) _pk_val="no" ;;
			*) continue ;;
		esac
		_ssh_backup_configs
		_ssh_cfg_set PubkeyAuthentication "$_pk_val"
		green "✓ PubkeyAuthentication 已设为 $_pk_val"
		_ssh_apply_and_restart
		;;
	  5)
		# ── 限制认证尝试次数 ──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 限制认证尝试次数 ━━━━━━${rw_lv}"
		echo -e " 当前: ${rw_huang}${_maxauth}${rw_lv} 次"
		echo -e " ${rw_lv}连续 N 次失败后断开连接，建议 3-6${rw_lv}"
		echo ""
		read -e -p " 新次数（1-10，默认3）: " _new_max < /dev/tty
		_new_max="${_new_max:-3}"
		if ! [[ "$_new_max" =~ ^[0-9]+$ ]] || [ "$_new_max" -lt 1 ] || [ "$_new_max" -gt 10 ]; then
			red "无效次数"
			break_end
			continue
		fi
		_ssh_backup_configs
		_ssh_cfg_set MaxAuthTries "$_new_max"
		green "✓ MaxAuthTries 已设为 $_new_max"
		_ssh_apply_and_restart
		;;
	  6)
		# ── 禁止 root SSH 登录（快捷）──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 禁止 root SSH 登录 ━━━━━━${rw_lv}"
		echo -e " ${rw_hong}⚠ 将禁止 root 通过 SSH 登录${rw_lv}"
		echo -e " ${rw_huang}确保有其他 sudo 用户可登录，否则将锁死！${rw_lv}"
		echo ""
		read -e -p " 确认？(y/N): " _confirm < /dev/tty
		if [[ "$_confirm" =~ ^[Yy]$ ]]; then
			_ssh_backup_configs
			_ssh_cfg_set PermitRootLogin no
			green "✓ 已禁止 root SSH 登录"
			_ssh_apply_and_restart
		else
			yellow "已取消"
		fi
		;;
	  7)
	# ── 禁止密码登录（快捷）──
	echo ""
	echo -e "${rw_cheng}━━━━━━ 禁止密码登录（仅密钥）━━━━━━${rw_lv}"
	echo -e " ${rw_hong}⚠ 将禁止密码登录，仅允许密钥登录${rw_lv}"
	# 全局审计公钥
	_ssh_audit_auth_users
	echo ""
	echo -e " ${rw_cheng}── 公钥审计 ──${rw_lv}"
	echo -e "   可登录用户: ${rw_huang}${_AUDIT_USERS}${rw_lv}    有公钥: ${rw_huang}${_AUDIT_HAS_PUBKEY}${rw_lv}"
	if [ $_AUDIT_USERS -eq 0 ]; then
		red "⚠ 未发现可登录用户，禁用密码有锁死风险！"
		break_end
		continue
	fi
	if [ $_AUDIT_HAS_PUBKEY -lt $_AUDIT_USERS ]; then
		echo -e " ${rw_hong}⚠ 以下用户没有公钥，禁用密码后将无法 SSH 登录：${rw_lv}"
		echo "$_AUDIT_MISSING" | grep '无公钥' | sed 's/^/   /'
		echo ""
		echo -e " ${rw_huang}请先到「密钥管理 → 公钥配置」为这些用户部署公钥${rw_lv}"
		break_end
		continue
	fi
	green "✓ 所有可登录用户均已配置公钥"
	echo ""
		read -e -p " 确认禁止密码登录？(y/N): " _confirm < /dev/tty
		if [[ "$_confirm" =~ ^[Yy]$ ]]; then
			_ssh_backup_configs
			_ssh_cfg_set PasswordAuthentication no
			_ssh_cfg_set PubkeyAuthentication yes
			green "✓ 已禁止密码登录，仅允许密钥"
			_ssh_apply_and_restart
		else
			yellow "已取消"
		fi
		;;
	  8)
		# ── 禁用端口转发/X11 ──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 禁用端口转发/X11 ━━━━━━${rw_lv}"
		echo -e " 将设置: AllowTcpForwarding no / X11Forwarding no / AllowAgentForwarding no"
		echo ""
		read -e -p " 确认？(y/N): " _confirm < /dev/tty
		if [[ "$_confirm" =~ ^[Yy]$ ]]; then
			_ssh_backup_configs
			_ssh_cfg_set AllowTcpForwarding no
			_ssh_cfg_set X11Forwarding no
			_ssh_cfg_set AllowAgentForwarding no
			green "✓ 已禁用端口转发/X11/Agent 转发"
			_ssh_apply_and_restart
		else
			yellow "已取消"
		fi
		;;
	  9)
		# ── 限制登录用户/组 ──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 限制登录用户/组 ━━━━━━${rw_lv}"
		echo -e " ${rw_lv}使用 AllowUsers/AllowGroups 明确指定允许登录的用户${rw_lv}"
		echo -e " ${rw_hong}⚠ 配置后只有列表中的用户能登录，其他用户被拒绝！${rw_lv}"
		echo ""
		# 显示当前设置
		local _cur_allow_u _cur_allow_g
		_cur_allow_u=$(grep -E '^AllowUsers' /etc/ssh/sshd_config 2>/dev/null | awk '{print $2}')
		_cur_allow_g=$(grep -E '^AllowGroups' /etc/ssh/sshd_config 2>/dev/null | awk '{print $2}')
		[ -n "$_cur_allow_u" ] && echo -e " 当前 AllowUsers: ${rw_huang}${_cur_allow_u}${rw_lv}"
		[ -n "$_cur_allow_g" ] && echo -e " 当前 AllowGroups: ${rw_huang}${_cur_allow_g}${rw_lv}"
		echo ""
		read -e -p " 允许登录的用户（空格分隔，留空跳过）: " _au < /dev/tty
		read -e -p " 允许登录的用户组（空格分隔，留空跳过）: " _ag < /dev/tty
		_ssh_backup_configs
		if [ -n "$_au" ]; then
			sed -i -E '/^AllowUsers/d' /etc/ssh/sshd_config
			echo "AllowUsers $_au" >> /etc/ssh/sshd_config
			green "✓ AllowUsers 已设置: $_au"
		fi
		if [ -n "$_ag" ]; then
			sed -i -E '/^AllowGroups/d' /etc/ssh/sshd_config
			echo "AllowGroups $_ag" >> /etc/ssh/sshd_config
			green "✓ AllowGroups 已设置: $_ag"
		fi
		[ -z "$_au" ] && [ -z "$_ag" ] && yellow "未输入任何内容，跳过"
		_ssh_apply_and_restart
		;;
	  10)
		# ── 查看当前 SSH 配置 ──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 当前 SSH 关键配置 ━━━━━━${rw_lv}"
		echo ""
		local _keys="Port PermitRootLogin PasswordAuthentication PubkeyAuthentication MaxAuthTries KbdInteractiveAuthentication ChallengeResponseAuthentication UsePAM AllowUsers AllowGroups AllowTcpForwarding X11Forwarding"
		for _k in $_keys; do
			local _v
			_v=$(grep -E "^${_k}[[:space:]]+" /etc/ssh/sshd_config 2>/dev/null | head -1 | awk '{print $2}')
			[ -n "$_v" ] && printf "  ${rw_huang}%-30s${rw_lv} %s\n" "$_k" "$_v"
		done
		;;
	  11)
		# ── 测试配置语法 ──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 测试 SSH 配置语法 ━━━━━━${rw_lv}"
		echo ""
		if sshd -t 2>&1; then
			green "✓ 语法检查通过"
		else
			red "✗ 语法检查失败，请检查配置"
		fi
		;;
	  12)
		# ── 重启 SSH 服务 ──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 重启 SSH 服务 ━━━━━━${rw_lv}"
		echo ""
		read -e -p " 确认重启 SSH 服务？(y/N): " _confirm < /dev/tty
		if [[ "$_confirm" =~ ^[Yy]$ ]]; then
			if sshd -t 2>/dev/null; then
				if systemctl restart sshd 2>/dev/null || service ssh restart 2>/dev/null || systemctl restart ssh 2>/dev/null; then
					green "✓ SSH 服务已重启"
				else
					red "重启失败"
				fi
			else
				red "配置语法错误，已取消重启"
			fi
		else
			yellow "已取消"
		fi
		;;
	  0)
		break
		;;
	  *)
		red "无效的输入!"
		;;
	esac
	break_cancel
done
}
user_manager() {
while true; do
	clear
	echo -e "${rw_cheng}━━━━━━━━━━━━  用户管理器  ━━━━━━━━━━━━${rw_lv}"
	echo ""
	echo -e " ${rw_huang}1.   ${rw_lv}创建用户${rw_lv}"
	echo -e " ${rw_huang}2.   ${rw_lv}公钥配置（一键部署 / 生成 / 管理）${rw_lv}"
	echo -e " ${rw_huang}3.   ${rw_lv}双证登录（公钥 + OTP 动态码）${rw_lv}"
	echo -e " ${rw_huang}4.   ${rw_lv}三证登录（公钥 + 密码 + OTP 动态码）${rw_lv}"
	echo -e " ${rw_huang}5.   ${rw_lv}硬证登录（FIDO2 硬件密钥）${rw_lv}"
	echo -e " ${rw_huang}6.   ${rw_lv}飞书扫码（SSH 登录飞书确认）${rw_lv}"
	echo -e " ${rw_huang}7.   ${rw_lv}${rw_hong}应急救援（一键恢复登录 / 解锁 / 诊断）${rw_lv}"
	echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
	echo -e " ${rw_huang}0.   ${rw_lv}返回主菜单${rw_lv}"
	echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
	read -e -p " 请输入你的选择: " um_choice

	case $um_choice in
	  1) root_manager ;;
	  2) ssh_pubkey_manager ;;
	  3) ssh_two_factor_manager ;;
	  4) ssh_three_factor_manager ;;
	  5) ssh_fido2_manager ;;
	  6) feishu_ssh_manager ;;
	  7) ssh_emergency_rescue ;;
	  0) break ;;
	  *) red "无效的输入!" ;;
	esac
done
}

# ================================================================
# SSH 应急救援管理器
# 场景: 双证/三证/禁密码后把自己锁外面，或 PAM 配错 sshd 起不来
# 前提: 已通过 VNC/物理终端进入服务器，运行本脚本
# 功能: 一键恢复登录 / 解锁用户 / 诊断 / 查看日志 / 回滚配置
# ================================================================
ssh_emergency_rescue() {
while true; do
	clear
	echo -e "${rw_cheng}━━━━━━━━━━━━  SSH 应急救援  ━━━━━━━━━━━━${rw_lv}"
	echo ""

	# ── 紧急状态速览 ──
	local _sshd_stat="未知" _sshd_mode="未知" _lock_warn=""
	if systemctl is-active sshd &>/dev/null || systemctl is-active ssh &>/dev/null; then
		_sshd_stat="${rw_lv}运行中${rw_lv}"
	else
		_sshd_stat="${rw_hong}已停止${rw_lv}"
		_lock_warn="1"
	fi
	_ssh_current_auth_mode
	_sshd_mode="${_SSH_MODE_DESC}"

	# 检查是否有锁死风险
	local _passauth _pubkeyauth _authmethods
	_passauth=$(_ssh_cfg_get PasswordAuthentication yes)
	_pubkeyauth=$(_ssh_cfg_get PubkeyAuthentication yes)
	_authmethods=$(_ssh_cfg_get AuthenticationMethods "")
	if [ "$_passauth" = "no" ] && [ "$_pubkeyauth" = "no" ]; then
		_lock_warn="1"
	elif [ -n "$_authmethods" ]; then
		# 有 AuthenticationMethods 但密码和公钥都关了 = 锁死
		if ! echo "$_authmethods" | grep -qE 'password|publickey|keyboard-interactive'; then
			_lock_warn="1"
		fi
	fi

	echo -e " SSH 服务: ${_sshd_stat}    认证模式: ${rw_huang}${_sshd_mode}${rw_lv}"
	if [ -n "$_lock_warn" ]; then
		echo -e " ${rw_hong}⚠ 检测到锁死风险！建议立即执行选项 1 恢复${rw_lv}"
	fi
	echo ""
	echo -e " ${rw_cheng}──── 紧急恢复 ──${rw_lv}"
	echo -e " ${rw_huang}1${rw_lv}  ${rw_hong}一键恢复登录（恢复密码+公钥，清除所有认证限制）${rw_lv}"
	echo -e " ${rw_huang}2${rw_lv}  仅清除双证/三证（保留密码+公钥登录）"
	echo -e " ${rw_huang}3${rw_lv}  重启 SSH 服务"
	echo -e " ${rw_huang}4${rw_lv}  解锁用户（清除 faillock / pam_tally2 失败计数）"
	echo ""
	echo -e " ${rw_cheng}──── 诊断 ──${rw_lv}"
	echo -e " ${rw_huang}11${rw_lv} SSH 配置语法检查 (sshd -t)"
	echo -e " ${rw_huang}12${rw_lv} 查看当前认证配置"
	echo -e " ${rw_huang}13${rw_lv} 查看最近 SSH 登录日志"
	echo -e " ${rw_huang}14${rw_lv} 查看所有用户公钥状态"
	echo ""
	echo -e " ${rw_cheng}──── 回滚 ──${rw_lv}"
	echo -e " ${rw_huang}21${rw_lv} 列出配置备份并回滚"
	echo -e " ${rw_huang}22${rw_lv} 清理 /tmp 下的旧备份"
	echo ""
	echo -e " ${rw_cheng}────────────────────────────────────────${rw_lv}"
	echo -e " ${rw_huang}0${rw_lv}  返回上级菜单"
	echo -e " ${rw_cheng}────────────────────────────────────────${rw_lv}"
	read -e -p " 请选择: " er_choice

	case $er_choice in
	  1)
		# ── 一键恢复登录 ──
		clear
		echo -e "${rw_huang}━━━━━━ 一键恢复登录 ━━━━━━${rw_lv}"
		echo ""
		echo -e " ${rw_hong}⚠ 此操作将:${rw_lv}"
		echo -e "   1) 备份当前 sshd_config + pam.d/sshd"
		echo -e "   2) 注释掉 AuthenticationMethods"
		echo -e "   3) PasswordAuthentication = yes"
		echo -e "   4) PubkeyAuthentication = yes"
		echo -e "   5) KbdInteractiveAuthentication = no"
		echo -e "   6) ChallengeResponseAuthentication = no"
		echo -e "   7) 从 PAM 移除 pam_google_authenticator"
		echo -e "   8) 从 PAM 移除 riwi_feishu_ssh_notify"
		echo -e "   9) 清理所有 Match 块中的认证字段"
		echo -e "  10) sshd -t 检查 → 重启 SSH"
		echo ""
		read -e -p " 确认执行？(y/N): " _confirm < /dev/tty
		if [[ ! "$_confirm" =~ ^[Yy]$ ]]; then
			yellow "已取消"
			break_cancel
			continue
		fi

		# 备份
		_ssh_backup_configs
		local _bk_dir="$_SSH_BACKUP_DIR"

		# 1-2: 注释 AuthenticationMethods
		if grep -qE '^[[:space:]]*AuthenticationMethods' /etc/ssh/sshd_config 2>/dev/null; then
			sed -i -E 's/^([[:space:]]*)(AuthenticationMethods[[:space:]].*)/#riwi-rescue \1\2/' /etc/ssh/sshd_config
			green "✓ 已注释 AuthenticationMethods"
		fi

		# 3-6: 恢复基础认证
		_ssh_cfg_set PasswordAuthentication yes
		_ssh_cfg_set PubkeyAuthentication yes
		_ssh_cfg_set KbdInteractiveAuthentication no
		_ssh_cfg_set ChallengeResponseAuthentication no
		green "✓ 已恢复 PasswordAuthentication=yes, PubkeyAuthentication=yes"

		# 7: 移除 PAM google_authenticator
		if grep -q "pam_google_authenticator.so" /etc/pam.d/sshd 2>/dev/null; then
			sed -i '/pam_google_authenticator.so/d' /etc/pam.d/sshd 2>/dev/null
			green "✓ 已从 PAM 移除 google_authenticator"
		fi

		# 8: 移除 PAM feishu notify
		if grep -q "riwi_feishu_ssh_notify" /etc/pam.d/sshd 2>/dev/null; then
			sed -i '/riwi_feishu_ssh_notify/d' /etc/pam.d/sshd 2>/dev/null
			green "✓ 已从 PAM 移除 feishu_notify"
		fi

		# 9: 清理 Match 块中的认证字段
		if grep -qE '^[[:space:]]*Match[[:space:]]' /etc/ssh/sshd_config 2>/dev/null; then
			awk '
				/^[[:space:]]*Match[[:space:]]/ { in_match=1 }
				{
					if (in_match && /^[[:space:]]*(AuthenticationMethods|KbdInteractiveAuthentication|ChallengeResponseAuthentication|PasswordAuthentication|PubkeyAuthentication)[[:space:]]/) {
						print "#riwi-rescue " $0
					} else {
						print
					}
				}
			' /etc/ssh/sshd_config > /tmp/riwi_rescue_sshd.$$.tmp && mv /tmp/riwi_rescue_sshd.$$.tmp /etc/ssh/sshd_config
			green "✓ 已清理 Match 块中的认证字段"
		fi

		# 10: 语法检查 + 重启
		echo ""
		local _sshd_err
		_sshd_err=$(sshd -t 2>&1)
		if [ $? -ne 0 ]; then
			red "✗ sshd -t 失败: $_sshd_err"
			echo -e " ${rw_huang}备份在 ${_bk_dir}，可手动回滚${rw_lv}"
			break_end
			continue
		fi
		green "✓ sshd -t 通过"

		if systemctl restart sshd 2>/dev/null || service ssh restart 2>/dev/null || systemctl restart ssh 2>/dev/null; then
			green "✓ SSH 服务已重启"
		else
			red "✗ SSH 重启失败，请手动: systemctl restart sshd"
		fi
		echo ""
		echo -e " ${rw_lv}现在可以用密码或公钥登录了${rw_lv}"
		echo -e " ${rw_huang}备份目录: ${_bk_dir}${rw_lv}"
		echo ""
		break_end
		;;

	  2)
		# ── 仅清除双证/三证（保留密码+公钥）──
		clear
		echo -e "${rw_huang}━━━━━━ 清除双证/三证 ━━━━━━${rw_lv}"
		echo ""
		echo -e " ${rw_lv}比选项1温和: 只移除 OTP/认证链，不改动密码/公钥开关${rw_lv}"
		echo ""
		read -e -p " 确认执行？(y/N): " _confirm < /dev/tty
		if [[ ! "$_confirm" =~ ^[Yy]$ ]]; then
			yellow "已取消"
			break_cancel
			continue
		fi
		_ssh_backup_configs
		_ssh_clear_conflicting_auth
		_ssh_cfg_set KbdInteractiveAuthentication no
		_ssh_cfg_set ChallengeResponseAuthentication no
		_ssh_cfg_set PasswordAuthentication yes
		_ssh_cfg_set PubkeyAuthentication yes
		sed -i '/pam_google_authenticator.so/d' /etc/pam.d/sshd 2>/dev/null
		green "✓ 已清除双证/三证配置"
		_ssh_apply_and_restart
		;;

	  3)
		# ── 重启 SSH 服务 ──
		clear
		echo -e "${rw_huang}━━━━━━ 重启 SSH 服务 ━━━━━━${rw_lv}"
		echo ""
		local _sshd_err
		_sshd_err=$(sshd -t 2>&1)
		if [ $? -ne 0 ]; then
			red "✗ 语法检查失败，拒绝重启: $_sshd_err"
			echo -e " ${rw_huang}建议先执行选项 1 恢复${rw_lv}"
			break_end
			continue
		fi
		green "✓ 语法检查通过"
		if systemctl restart sshd 2>/dev/null || service ssh restart 2>/dev/null || systemctl restart ssh 2>/dev/null; then
			green "✓ SSH 服务已重启"
		else
			red "✗ 重启失败，请手动检查"
		fi
		break_end
		;;

	  4)
		# ── 解锁用户（清除登录失败计数）──
		clear
		echo -e "${rw_huang}━━━━━━ 解锁用户 ━━━━━━${rw_lv}"
		echo ""
		echo -e " ${rw_lv}清除 faillock / pam_tally2 记录的登录失败次数${rw_lv}"
		echo ""

		# 列出被锁定的用户
		local _locked_users=""
		if command -v faillock &>/dev/null; then
			echo -e " ${rw_huang}通过 faillock 检测:${rw_lv}"
			while IFS=: read -r _u _ _ _ _ _ _ _; do
				if faillock --user "$_u" 2>/dev/null | grep -q "Authentication failure"; then
					_locked_users="${_locked_users}$_u "
					echo -e "   ${rw_hong}$_u 有失败记录${rw_lv}"
				fi
			done </etc/passwd 2>/dev/null
		elif command -v pam_tally2 &>/dev/null; then
			echo -e " ${rw_huang}通过 pam_tally2 检测:${rw_lv}"
			pam_tally2 2>/dev/null | grep -v "Login" | while read -r _u _c _r _l; do
				[ -n "$_u" ] && echo -e "   ${rw_hong}$_u 失败 $_c 次${rw_lv}"
			done
		else
			yellow "faillock 和 pam_tally2 都不可用，将解锁所有普通用户"
		fi
		echo ""
		read -e -p " 输入要解锁的用户名（留空=解锁所有）: " _target_u < /dev/tty
		if [ -z "$_target_u" ]; then
			# 解锁所有
			while IFS=: read -r _u _ _ _ _ _ _ _; do
				[ "$_u" = "root" ] && continue
				command -v faillock &>/dev/null && faillock --user "$_u" --reset 2>/dev/null
				command -v pam_tally2 &>/dev/null && pam_tally2 --user "$_u" --reset 2>/dev/null
			done </etc/passwd 2>/dev/null
			# root 也解
			command -v faillock &>/dev/null && faillock --user root --reset 2>/dev/null
			command -v pam_tally2 &>/dev/null && pam_tally2 --user root --reset 2>/dev/null
			green "✓ 已解锁所有用户"
		else
			command -v faillock &>/dev/null && faillock --user "$_target_u" --reset 2>/dev/null
			command -v pam_tally2 &>/dev/null && pam_tally2 --user "$_target_u" --reset 2>/dev/null
			green "✓ 用户 $_target_u 已解锁"
		fi
		echo ""
		break_end
		;;

	  11)
		# ── sshd -t 语法检查 ──
		clear
		echo -e "${rw_huang}━━━━━━ SSH 配置语法检查 ━━━━━━${rw_lv}"
		echo ""
		local _sshd_err
		_sshd_err=$(sshd -t 2>&1)
		if [ $? -eq 0 ]; then
			green "✓ 语法检查通过"
		else
			red "✗ 语法错误:"
			echo -e " ${rw_hong}$_sshd_err${rw_lv}"
			echo ""
			echo -e " ${rw_huang}常见原因:${rw_lv}"
			echo -e "   - AuthenticationMethods 拼写错误"
			echo -e "   - Match 块未正确闭合"
			echo -e "   - PAM 模块路径不对"
		fi
		echo ""
		break_end
		;;

	  12)
		# ── 查看当前认证配置 ──
		clear
		echo -e "${rw_huang}━━━━━━ 当前 SSH 认证配置 ━━━━━━${rw_lv}"
		echo ""
		_ssh_current_auth_mode
		echo -e " 认证模式: ${rw_huang}${_SSH_MODE_DESC}${rw_lv}"
		echo -e " 判断依据: ${_SSH_MODE_REASON}"
		echo ""
		echo -e " ${rw_cheng}── sshd_config 关键项 ──${rw_lv}"
		local _k
		for _k in Port PermitRootLogin PasswordAuthentication PubkeyAuthentication \
				  KbdInteractiveAuthentication ChallengeResponseAuthentication AuthenticationMethods; do
			local _v
			_v=$(grep -E "^[[:space:]]*#?${_k}[[:space:]]+" /etc/ssh/sshd_config 2>/dev/null | tail -1 | awk '{print $2}')
			[ -n "$_v" ] && printf "  %-40s %s\n" "$_k" "$_v"
		done
		echo ""
		echo -e " ${rw_cheng}── PAM sshd 中的 OTP/飞书 ──${rw_lv}"
		grep -E "pam_google_authenticator|riwi_feishu" /etc/pam.d/sshd 2>/dev/null | sed 's/^/  /' || echo "  (无)"
		echo ""
		echo -e " ${rw_cheng}── Match 块 ──${rw_lv}"
		if grep -qE '^[[:space:]]*Match' /etc/ssh/sshd_config 2>/dev/null; then
			grep -nE '^[[:space:]]*Match' /etc/ssh/sshd_config | sed 's/^/  /'
		else
			echo "  (无 Match 块)"
		fi
		echo ""
		break_end
		;;

	  13)
		# ── 查看最近 SSH 登录日志 ──
		clear
		echo -e "${rw_huang}━━━━━━ 最近 SSH 登录日志 ━━━━━━${rw_lv}"
		echo ""
		echo -e " ${rw_huang}最近 50 条 SSH 相关日志:${rw_lv}"
		echo ""
		if [ -f /var/log/auth.log ]; then
			grep -iE 'sshd|accepted|failed|invalid' /var/log/auth.log 2>/dev/null | tail -50 | sed 's/^/  /'
		elif command -v journalctl &>/dev/null; then
			journalctl -u sshd --no-pager -n 50 2>/dev/null | sed 's/^/  /'
		elif [ -f /var/log/secure ]; then
			grep -iE 'sshd|accepted|failed|invalid' /var/log/secure 2>/dev/null | tail -50 | sed 's/^/  /'
		else
			yellow "未找到 SSH 日志文件"
		fi
		echo ""
		break_end
		;;

	  14)
		# ── 查看所有用户公钥状态 ──
		clear
		echo -e "${rw_huang}━━━━━━ 用户公钥状态 ━━━━━━${rw_lv}"
		echo ""
		printf "  %-15s %-25s %-8s %-8s %-8s\n" "用户" "HOME" "公钥数" "OTP" "状态"
		echo "  ────────────────────────────────────────────────────────"
		local _u _uid _home _pk_cnt _has_otp
		while IFS=: read -r _u _ _uid _ _ _home _; do
			[ "$_uid" -lt 1000 ] 2>/dev/null && [ "$_u" != "root" ] && continue
			[ -z "$_home" ] && continue
			_pk_cnt=0
			_has_otp="无"
			[ -f "${_home}/.ssh/authorized_keys" ] && _pk_cnt=$(grep -cE '^(ssh-|ecdsa-|sk-)' "${_home}/.ssh/authorized_keys" 2>/dev/null || echo 0)
			[ -f "${_home}/.google_authenticator" ] && _has_otp="有"
			local _status="${rw_lv}正常${rw_lv}"
			# 检查 .ssh 权限
			if [ -d "${_home}/.ssh" ]; then
				local _perm
				_perm=$(stat -c '%a' "${_home}/.ssh" 2>/dev/null || stat -f '%Lp' "${_home}/.ssh" 2>/dev/null)
				[ "$_perm" != "700" ] && _status="${rw_hong}权限异常(${_perm})${rw_lv}"
			fi
			printf "  ${rw_huang}%-15s${rw_lv} %-25s %-8s %-8s %-8s\n" "$_u" "$_home" "$_pk_cnt" "$_has_otp" "$_status"
		done </etc/passwd 2>/dev/null
		echo ""
		break_end
		;;

	  21)
		# ── 列出备份并回滚 ──
		clear
		echo -e "${rw_huang}━━━━━━ 配置备份回滚 ━━━━━━${rw_lv}"
		echo ""
		echo -e " ${rw_huang}可用备份（/tmp/riwi_ssh_backup_*）:${rw_lv}"
		echo ""
		local _backups=()
		local _bk
		while IFS= read -r _bk; do
			_backups+=("$_bk")
		done < <(ls -d /tmp/riwi_ssh_backup_* 2>/dev/null | sort -r)
		if [ ${#_backups[@]} -eq 0 ]; then
			yellow "没有找到备份"
			break_end
			continue
		fi
		local _i=1
		for _bk in "${_backups[@]}"; do
			local _time _files
			_time=$(basename "$_bk" | sed 's/riwi_ssh_backup_//')
			_files=$(ls "$_bk" 2>/dev/null | tr '\n' ' ')
			echo -e " ${rw_huang}${_i}.${rw_lv} ${_time}  文件: ${_files}"
			((_i++))
		done
		echo -e " ${rw_huang}0.${rw_lv} 取消"
		echo ""
		read -e -p " 选择要回滚的备份编号: " _bk_idx < /dev/tty
		[ "$_bk_idx" = "0" ] && continue
		[ -z "$_bk_idx" ] && { red "无效选择"; break_end; continue; }
		local _target_bk="${_backups[$((_bk_idx - 1))]}"
		[ -z "$_target_bk" ] && { red "无效选择"; break_end; continue; }

		echo ""
		echo -e " ${rw_hong}⚠ 将回滚到: ${_target_bk}${rw_lv}"
		echo -e " ${rw_hong}当前配置会被覆盖${rw_lv}"
		read -e -p " 确认回滚？(y/N): " _confirm < /dev/tty
		if [[ ! "$_confirm" =~ ^[Yy]$ ]]; then
			yellow "已取消"
			break_cancel
			continue
		fi

		_SSH_BACKUP_DIR="$_target_bk"
		_ssh_restore_backup

		# 回滚后检查语法
		local _sshd_err
		_sshd_err=$(sshd -t 2>&1)
		if [ $? -ne 0 ]; then
			red "✗ 回滚后语法检查失败: $_sshd_err"
			echo -e " ${rw_huang}建议手动检查 /etc/ssh/sshd_config${rw_lv}"
		else
			green "✓ 语法检查通过"
			read -e -p " 是否重启 SSH 使回滚生效？(y/N): " _restart < /dev/tty
			if [[ "$_restart" =~ ^[Yy]$ ]]; then
				systemctl restart sshd 2>/dev/null || service ssh restart 2>/dev/null || systemctl restart ssh 2>/dev/null
				green "✓ SSH 已重启"
			fi
		fi
		echo ""
		break_end
		;;

	  22)
		# ── 清理旧备份 ──
		clear
		echo -e "${rw_huang}━━━━━━ 清理旧备份 ━━━━━━${rw_lv}"
		echo ""
		local _cnt
		_cnt=$(ls -d /tmp/riwi_ssh_backup_* 2>/dev/null | wc -l)
		if [ "$_cnt" -eq 0 ]; then
			yellow "没有旧备份可清理"
			break_end
			continue
		fi
		echo -e " 发现 ${rw_huang}${_cnt}${rw_lv} 个备份，占用:"
		du -sh /tmp/riwi_ssh_backup_* 2>/dev/null | sed 's/^/  /'
		echo ""
		read -e -p " 确认删除所有旧备份？(y/N): " _confirm < /dev/tty
		if [[ "$_confirm" =~ ^[Yy]$ ]]; then
			rm -rf /tmp/riwi_ssh_backup_*
			green "✓ 已清理"
		else
			yellow "已取消"
		fi
		break_cancel
		;;

	  0)
		break
		;;
	  *)
		red "无效的输入!"
		sleep 1
		;;
	esac
done
}

# ================================================================
# 公钥配置管理器（一键部署 / 生成 / 管理 SSH 公钥）
# 功能: 粘贴公钥 / 生成密钥对 / 查看已授权 / 删除公钥 / 权限修复
# 支持为任意普通用户（含 root）配置，自动修正 .ssh 与 authorized_keys 权限
# ================================================================
# ================================================================
# 公钥配置管理器（一键部署 / 生成 / 管理 SSH 公钥）
# 设计原则: 逻辑分层清晰 — 状态面板 → 子菜单 → 执行
# 支持任意普通用户（含 root），自动修正权限，sudo 场景安全
# ================================================================

# ── 辅助: 列出可选用户（uid≥1000 + root），返回数组 _PK_USERS ──
_pk_list_users() {
	_PK_USERS=()
	local _u _p _uid _gid _gcos _home _shell
	while IFS=: read -r _u _p _uid _gid _gcos _home _shell; do
		[ "$_uid" -lt 1000 ] && [ "$_u" != "root" ] && continue
		[ -d "$_home" ] && _PK_USERS+=("$_u")
	done </etc/passwd 2>/dev/null
	# root 始终加入
	_PK_USERS+=("root")
}

# ── 辅助: 交互选择用户，结果写入 _PK_TARGET_U / _PK_TARGET_HOME ──
_pk_pick_user() {
	_pk_list_users
	echo -e " ${rw_cheng}── 选择目标用户 ──${rw_lv}"
	local _i=1
	for _u in "${_PK_USERS[@]}"; do
		local _h
		_h=$(getent passwd "$_u" | cut -d: -f6)
		local _mark=""
		[ -f "${_h}/.ssh/authorized_keys" ] && [ -s "${_h}/.ssh/authorized_keys" ] && \
			_mark="${rw_lv}[已配公钥]${rw_lv}"
		echo -e " ${rw_huang}${_i}.${rw_lv} $_u → ${_h} ${_mark}"
		((_i++))
	done
	echo -e " ${rw_huang}0.${rw_lv} 取消"
	echo ""
	read -e -p " 请选择用户编号: " _idx < /dev/tty
	[ "$_idx" = "0" ] && return 1
	[ -z "$_idx" ] && return 1
	if ! [[ "$_idx" =~ ^[0-9]+$ ]] || [ "$_idx" -lt 1 ] || [ "$_idx" -gt ${#_PK_USERS[@]} ]; then
		return 1
	fi
	_PK_TARGET_U="${_PK_USERS[$((_idx - 1))]}"
	_PK_TARGET_HOME=$(getent passwd "$_PK_TARGET_U" | cut -d: -f6)
	[ -z "$_PK_TARGET_HOME" ] || [ ! -d "$_PK_TARGET_HOME" ] && return 1
	return 0
}

# ── 辅助: 为指定用户追加公钥（去重 + 权限 + chown）──
# 用法: _pk_add_pubkey <user> <home> <pubkey>
_pk_add_pubkey() {
	local _user="$1" _home="$2" _pubkey="$3"
	local _ssh_dir="${_home}/.ssh"
	local _auth_file="${_ssh_dir}/authorized_keys"

	mkdir -p "$_ssh_dir"
	chmod 700 "$_ssh_dir"
	if [ ! -f "$_auth_file" ]; then
		touch "$_auth_file"
	fi
	if grep -qF "$_pubkey" "$_auth_file" 2>/dev/null; then
		yellow "  该公钥已存在，跳过添加"
		return 0
	fi
	echo "$_pubkey" >> "$_auth_file"
	chmod 600 "$_auth_file"
	chown -R "$_user":"$(id -gn "$_user" 2>/dev/null || echo "$_user")" "$_ssh_dir" 2>/dev/null
	green "  公钥已添加到 ${_auth_file}"
	return 0
}

# ── 辅助: 显示某用户的 authorized_keys（带行号）──
# 用法: _pk_show_authkeys <home>
_pk_show_authkeys() {
	local _home="$1"
	local _auth_file="${_home}/.ssh/authorized_keys"
	if [ ! -f "$_auth_file" ] || [ ! -s "$_auth_file" ]; then
		yellow "  文件为空或不存在: ${_auth_file}"
		return 1
	fi
	local _ln=0
	while IFS= read -r _line; do
		_ln=$((_ln + 1))
		if echo "$_line" | grep -qE '^(ssh-|ecdsa-|sk-)'; then
			local _kt _kc
			_kt=$(echo "$_line" | awk '{print $1}')
			_kc=$(echo "$_line" | awk '{print $NF}')
			printf "  ${rw_huang}%-3s${rw_lv} %-20s %s\n" "$_ln" "$_kt" "${_kc:-无注释}"
		elif [ -n "$_line" ]; then
			printf "  ${rw_huang}%-3s${rw_lv} %s\n" "$_ln" "(非公钥行) ${_line}"
		fi
	done < "$_auth_file"
	echo ""
	echo -e "  共 ${rw_huang}${_ln}${rw_lv} 行"
}

ssh_pubkey_manager() {
while true; do
	clear
	echo -e "${rw_cheng}━━━━━━━━━━━━  公钥配置  ━━━━━━━━━━━━${rw_lv}"
	echo ""

	# ── 状态面板: 扫描所有用户的公钥配置情况 ──
	echo -e " ${rw_cheng}── 已配置公钥的用户 ──${rw_lv}"
	local _has_any=0 _total_keys=0
	while IFS=: read -r _u _p _uid _gid _gcos _home _shell; do
		[ "$_uid" -lt 1000 ] && [ "$_u" != "root" ] && continue
		if [ -f "${_home}/.ssh/authorized_keys" ] && [ -s "${_home}/.ssh/authorized_keys" ]; then
			local _cnt
			_cnt=$(grep -cE '^(ssh-|ecdsa-|sk-)' "${_home}/.ssh/authorized_keys" 2>/dev/null || echo 0)
			if [ "$_cnt" -gt 0 ]; then
				printf "  ${rw_huang}%-12s${rw_lv}  %s 个公钥  %s\n" "$_u" "$_cnt" "${_home}/.ssh/authorized_keys"
				_has_any=1
				_total_keys=$((_total_keys + _cnt))
			fi
		fi
	done </etc/passwd 2>/dev/null
	[ $_has_any -eq 0 ] && echo -e "  ${rw_huang}暂无用户配置公钥${rw_lv}" || \
		echo -e "  ${rw_lv}合计 ${rw_huang}${_total_keys}${rw_lv} 个公钥${rw_lv}"
	echo ""

	echo -e " ${rw_cheng}──── 添加公钥 ────${rw_lv}"
	echo -e " ${rw_huang}1.   ${rw_lv}粘贴公钥 → 当前用户${rw_lv}"
	echo -e " ${rw_huang}2.   ${rw_lv}粘贴公钥 → 指定用户${rw_lv}"
	echo -e " ${rw_huang}3.   ${rw_lv}生成新密钥对 → 当前用户（自动部署）${rw_lv}"
	echo -e " ${rw_huang}4.   ${rw_lv}生成新密钥对 → 指定用户（自动部署）${rw_lv}"
	echo -e " ${rw_huang}5.   ${rw_lv}从其他服务器拉取公钥（ssh-copy-id 反向）${rw_lv}"
	echo ""
	echo -e " ${rw_cheng}──── 查看与管理 ────${rw_lv}"
	echo -e " ${rw_huang}6.   ${rw_lv}查看指定用户的已授权公钥${rw_lv}"
	echo -e " ${rw_huang}7.   ${rw_lv}删除指定公钥（按行号）${rw_lv}"
	echo -e " ${rw_huang}8.   ${rw_lv}清空指定用户的全部公钥${rw_lv}"
	echo -e " ${rw_huang}9.   ${rw_lv}修复 .ssh 与 authorized_keys 权限${rw_lv}"
	echo ""
	echo -e " ${rw_cheng}──── 批量与导入 ────${rw_lv}"
	echo -e " ${rw_huang}10.  ${rw_lv}批量导入公钥（从文件，每行一个）${rw_lv}"
	echo -e " ${rw_huang}11.  ${rw_lv}导出指定用户的公钥到文件${rw_lv}"
	echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
	echo -e " ${rw_huang}0.   ${rw_lv}返回上级菜单${rw_lv}"
	echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
	read -e -p " 请输入你的选择: " pk_choice

	case $pk_choice in
	  1)
		# ── 粘贴公钥 → 当前用户 ──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 粘贴公钥 → 当前用户 ━━━━━━${rw_lv}"
		echo ""
		local _cur_u _cur_home
		_cur_u=$(whoami)
		_cur_home=$(getent passwd "$_cur_u" | cut -d: -f6)
		[ -z "$_cur_home" ] && _cur_home="$HOME"
		echo -e " 目标用户: ${rw_huang}${_cur_u}${rw_lv}  →  ${_cur_home}/.ssh/authorized_keys"
		echo ""
		read -e -p " 请粘贴 SSH 公钥（以 ssh-rsa/ssh-ed25519/ecdsa/sk- 开头）: " _pubkey < /dev/tty
		if [ -z "$_pubkey" ]; then
			red "公钥不能为空"
			break_end
			continue
		fi
		_pk_add_pubkey "$_cur_u" "$_cur_home" "$_pubkey"
		;;
	  2)
		# ── 粘贴公钥 → 指定用户 ──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 粘贴公钥 → 指定用户 ━━━━━━${rw_lv}"
		echo ""
		if ! _pk_pick_user; then
			red "无效选择"
			break_end
			continue
		fi
		echo ""
		echo -e " 目标用户: ${rw_huang}${_PK_TARGET_U}${rw_lv}  →  ${_PK_TARGET_HOME}/.ssh/authorized_keys"
		echo ""
		read -e -p " 请粘贴 SSH 公钥（以 ssh-rsa/ssh-ed25519/ecdsa/sk- 开头）: " _pubkey < /dev/tty
		if [ -z "$_pubkey" ]; then
			red "公钥不能为空"
			break_end
			continue
		fi
		_pk_add_pubkey "$_PK_TARGET_U" "$_PK_TARGET_HOME" "$_pubkey"
		;;
	  3)
		# ── 生成新密钥对 → 当前用户 ──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 生成新密钥对 → 当前用户 ━━━━━━${rw_lv}"
		echo ""
		local _cur_u _cur_home
		_cur_u=$(whoami)
		_cur_home=$(getent passwd "$_cur_u" | cut -d: -f6)
		[ -z "$_cur_home" ] && _cur_home="$HOME"
		echo -e " 目标用户: ${rw_huang}${_cur_u}${rw_lv}  →  ${_cur_home}/.ssh"
		echo ""

		read -e -p " 请输入密钥名称（默认: id_ed25519）: " _key_name < /dev/tty
		_key_name="${_key_name:-id_ed25519}"
		local _key_path="${_cur_home}/.ssh/${_key_name}"
		if [ -f "$_key_path" ]; then
			yellow "密钥文件 ${_key_name} 已存在"
			read -e -p " 是否覆盖？(y/N): " _ow < /dev/tty
			[[ ! "$_ow" =~ ^[Yy]$ ]] && { yellow "已取消"; break_cancel; continue; }
		fi

		echo -e " 密钥类型:"
		echo -e " ${rw_huang}1.   ${rw_lv}ed25519（推荐，更安全更快）${rw_lv}"
		echo -e " ${rw_huang}2.   ${rw_lv}RSA 4096 位（兼容性更好）${rw_lv}"
		echo -e " ${rw_huang}3.   ${rw_lv}ECDSA 521 位${rw_lv}"
		read -e -p " 请选择（默认1）: " _kt < /dev/tty
		_kt="${_kt:-1}"

		echo ""
		echo -e " ${rw_huang}正在生成密钥对...${rw_lv}"
		mkdir -p "${_cur_home}/.ssh" && chmod 700 "${_cur_home}/.ssh"
		local _gen_ok=false
		case "$_kt" in
			2) ssh-keygen -t rsa -b 4096 -f "$_key_path" -N "" -q 2>/dev/null && _gen_ok=true ;;
			3) ssh-keygen -t ecdsa -b 521 -f "$_key_path" -N "" -q 2>/dev/null && _gen_ok=true ;;
			*) ssh-keygen -t ed25519 -f "$_key_path" -N "" -q 2>/dev/null && _gen_ok=true ;;
		esac

		if $_gen_ok && [ -f "$_key_path" ]; then
			_pk_add_pubkey "$_cur_u" "$_cur_home" "$(cat ${_key_path}.pub)"
			echo ""
			echo -e " ${rw_huang}私钥位置:${rw_lv} ${_key_path}"
			echo -e " ${rw_huang}公钥位置:${rw_lv} ${_key_path}.pub"
			echo ""
			echo -e " ${rw_hong}⚠ 请立即下载私钥保存到本地，否则无法 SSH 登录！${rw_lv}"
			echo -e "   ${rw_lv}下载方式: scp 或 SFTP 下载 ${_key_path}${rw_lv}"
			echo ""
			echo -e " 公钥内容:"
			cat "${_key_path}.pub"
		else
			red "密钥生成失败"
		fi
		;;
	  4)
		# ── 生成新密钥对 → 指定用户 ──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 生成新密钥对 → 指定用户 ━━━━━━${rw_lv}"
		echo ""
		if ! _pk_pick_user; then
			red "无效选择"
			break_end
			continue
		fi
		local _tu _th
		_tu="$_PK_TARGET_U"
		_th="$_PK_TARGET_HOME"
		echo ""
		echo -e " 目标用户: ${rw_huang}${_tu}${rw_lv}  →  ${_th}/.ssh"
		echo ""

		read -e -p " 请输入密钥名称（默认: id_ed25519）: " _key_name < /dev/tty
		_key_name="${_key_name:-id_ed25519}"
		local _key_path="${_th}/.ssh/${_key_name}"
		if [ -f "$_key_path" ]; then
			yellow "密钥文件 ${_key_name} 已存在"
			read -e -p " 是否覆盖？(y/N): " _ow < /dev/tty
			[[ ! "$_ow" =~ ^[Yy]$ ]] && { yellow "已取消"; break_cancel; continue; }
		fi

		echo -e " 密钥类型:"
		echo -e " ${rw_huang}1.   ${rw_lv}ed25519（推荐）${rw_lv}"
		echo -e " ${rw_huang}2.   ${rw_lv}RSA 4096 位${rw_lv}"
		echo -e " ${rw_huang}3.   ${rw_lv}ECDSA 521 位${rw_lv}"
		read -e -p " 请选择（默认1）: " _kt < /dev/tty
		_kt="${_kt:-1}"

		echo ""
		echo -e " ${rw_huang}正在为 ${_tu} 生成密钥对...${rw_lv}"
		mkdir -p "${_th}/.ssh" && chmod 700 "${_th}/.ssh"

		# 用目标用户身份生成（确保私钥属主正确）
		local _gen_ok=false
		case "$_kt" in
			2) su - "$_tu" -c "ssh-keygen -t rsa -b 4096 -f '${_key_path}' -N '' -q" 2>/dev/null && _gen_ok=true ;;
			3) su - "$_tu" -c "ssh-keygen -t ecdsa -b 521 -f '${_key_path}' -N '' -q" 2>/dev/null && _gen_ok=true ;;
			*) su - "$_tu" -c "ssh-keygen -t ed25519 -f '${_key_path}' -N '' -q" 2>/dev/null && _gen_ok=true ;;
		esac

		if $_gen_ok && [ -f "$_key_path" ]; then
			_pk_add_pubkey "$_tu" "$_th" "$(cat ${_key_path}.pub)"
			echo ""
			echo -e " ${rw_huang}私钥位置:${rw_lv} ${_key_path}"
			echo -e " ${rw_huang}公钥位置:${rw_lv} ${_key_path}.pub"
			echo -e " ${rw_hong}⚠ 私钥属主为 ${_tu}，请用对应账号下载${rw_lv}"
			echo ""
			echo -e " 公钥内容:"
			cat "${_key_path}.pub"
		else
			red "密钥生成失败"
		fi
		;;
	  5)
		# ── 从其他服务器拉取公钥 ──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 从其他服务器拉取公钥 ━━━━━━${rw_lv}"
		echo ""
		echo -e " ${rw_lv}从远程服务器抓取指定用户的 authorized_keys 内容，追加到本地${rw_lv}"
		echo ""
		read -e -p " 远程服务器 (user@host): " _remote < /dev/tty
		[ -z "$_remote" ] && { red "不能为空"; break_end; continue; }
		read -e -p " SSH 端口（默认 22）: " _rport < /dev/tty
		_rport="${_rport:-22}"
		read -e -p " 远程用户名（抓取谁的公钥，默认 root）: " _ruser < /dev/tty
		_ruser="${_ruser:-root}"

		echo ""
		echo -e " ${rw_huang}正在从 ${_remote} 抓取 ${_ruser} 的公钥...${rw_lv}"
		local _remote_keys
		_remote_keys=$(ssh -p "$_rport" "$_remote" "cat ~${_ruser}/.ssh/authorized_keys 2>/dev/null" 2>/dev/null)
		if [ -z "$_remote_keys" ]; then
			red "抓取失败或远程无公钥"
			break_end
			continue
		fi
		local _remote_cnt
		_remote_cnt=$(echo "$_remote_keys" | grep -cE '^(ssh-|ecdsa-|sk-)' 2>/dev/null || echo 0)
		green "抓取到 ${_remote_cnt} 个公钥"
		echo ""

		# 选择本地目标用户
		if ! _pk_pick_user; then
			red "无效选择"
			break_end
			continue
		fi
		echo ""
		echo -e " ${rw_huang}正在追加到 ${_PK_TARGET_U} ...${rw_lv}"
		local _added=0
		while IFS= read -r _line; do
			echo "$_line" | grep -qE '^(ssh-|ecdsa-|sk-)' || continue
			_pk_add_pubkey "$_PK_TARGET_U" "$_PK_TARGET_HOME" "$_line"
			_added=$((_added + 1))
		done <<< "$_remote_keys"
		green "完成，共处理 ${_added} 个公钥"
		;;
	  6)
		# ── 查看指定用户的已授权公钥 ──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 查看已授权公钥 ━━━━━━${rw_lv}"
		echo ""
		if ! _pk_pick_user; then
			red "无效选择"
			break_end
			continue
		fi
		echo ""
		echo -e " ${rw_cheng}── ${_PK_TARGET_U} 的 authorized_keys ──${rw_lv}"
		_pk_show_authkeys "$_PK_TARGET_HOME"
		;;
	  7)
		# ── 删除指定公钥（按行号）──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 删除指定公钥 ━━━━━━${rw_lv}"
		echo ""
		if ! _pk_pick_user; then
			red "无效选择"
			break_end
			continue
		fi
		local _auth_file="${_PK_TARGET_HOME}/.ssh/authorized_keys"
		echo ""
		echo -e " ${rw_cheng}── ${_PK_TARGET_U} 的 authorized_keys ──${rw_lv}"
		if [ ! -f "$_auth_file" ] || [ ! -s "$_auth_file" ]; then
			yellow "  文件为空或不存在"
			break_end
			continue
		fi
		_pk_show_authkeys "$_PK_TARGET_HOME"
		echo ""
		read -e -p " 请输入要删除的公钥行号: " _del_idx < /dev/tty
		[ -z "$_del_idx" ] && { red "无效行号"; break_end; continue; }
		if ! [[ "$_del_idx" =~ ^[0-9]+$ ]] || [ "$_del_idx" -lt 1 ]; then
			red "无效行号"
			break_end
			continue
		fi
		# 检查行号是否存在
		local _total_lines
		_total_lines=$(wc -l < "$_auth_file" 2>/dev/null || echo 0)
		if [ "$_del_idx" -gt "$_total_lines" ]; then
			red "行号超出范围（文件共 ${_total_lines} 行）"
			break_end
			continue
		fi
		read -e -p " 确认删除第 ${_del_idx} 行？(y/N): " _confirm < /dev/tty
		if [[ "$_confirm" =~ ^[Yy]$ ]]; then
			local _del_line
			_del_line=$(sed -n "${_del_idx}p" "$_auth_file")
			sed -i "${_del_idx}d" "$_auth_file"
			green "已删除第 ${_del_idx} 行:"
			echo -e "   ${rw_lv}$(echo "$_del_line" | head -c 80)...${rw_lv}"
		else
			yellow "已取消"
		fi
		;;
	  8)
		# ── 清空指定用户的全部公钥 ──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 清空指定用户的全部公钥 ━━━━━━${rw_lv}"
		echo ""
		echo -e " ${rw_hong}⚠ 此操作将清空 authorized_keys 中的所有公钥！${rw_lv}"
		echo -e " ${rw_hong}⚠ 清空后该用户将无法通过公钥登录，请确保有其他登录方式！${rw_lv}"
		echo ""
		if ! _pk_pick_user; then
			red "无效选择"
			break_end
			continue
		fi
		local _auth_file="${_PK_TARGET_HOME}/.ssh/authorized_keys"
		echo ""
		if [ ! -f "$_auth_file" ] || [ ! -s "$_auth_file" ]; then
			yellow "  文件已为空或不存在"
			break_end
			continue
		fi
		local _cnt
		_cnt=$(grep -cE '^(ssh-|ecdsa-|sk-)' "$_auth_file" 2>/dev/null || echo 0)
		echo -e " ${rw_huang}${_PK_TARGET_U}${rw_lv} 当前有 ${rw_huang}${_cnt}${rw_lv} 个公钥"
		echo ""
		read -e -p " 确认清空全部公钥？输入 yes 确认: " _confirm < /dev/tty
		if [ "$_confirm" = "yes" ]; then
			# 备份后清空
			cp -a "$_auth_file" "${_auth_file}.bak.$(date +%Y%m%d%H%M%S)" 2>/dev/null
			> "$_auth_file"
			green "已清空 ${_auth_file}"
			echo -e " ${rw_huang}备份已保存为 ${_auth_file}.bak.*${rw_lv}"
		else
			yellow "已取消（需输入 yes 才会执行）"
		fi
		;;
	  9)
		# ── 修复权限 ──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 修复 .ssh 与 authorized_keys 权限 ━━━━━━${rw_lv}"
		echo ""
		echo -e " ${rw_huang}即将修复所有用户的 SSH 相关权限:${rw_lv}"
		echo -e "   .ssh/              → 700"
		echo -e "   authorized_keys    → 600"
		echo -e "   私钥文件 (id_*)    → 600"
		echo -e "   .ssh/config        → 600"
		echo -e "   known_hosts        → 644"
		echo ""
		read -e -p " 确认执行？(y/N): " _confirm < /dev/tty
		if [[ ! "$_confirm" =~ ^[Yy]$ ]]; then
			yellow "已取消"
			break_cancel
			continue
		fi
		local _fixed=0
		while IFS=: read -r _u _p _uid _gid _gcos _home _shell; do
			[ "$_uid" -lt 1000 ] && [ "$_u" != "root" ] && continue
			[ -d "${_home}/.ssh" ] || continue
			chmod 700 "${_home}/.ssh" 2>/dev/null
			chown -R "$_u":"$(id -gn "$_u" 2>/dev/null || echo "$_u")" "${_home}/.ssh" 2>/dev/null
			[ -f "${_home}/.ssh/authorized_keys" ] && chmod 600 "${_home}/.ssh/authorized_keys" 2>/dev/null
			[ -f "${_home}/.ssh/config" ] && chmod 600 "${_home}/.ssh/config" 2>/dev/null
			[ -f "${_home}/.ssh/known_hosts" ] && chmod 644 "${_home}/.ssh/known_hosts" 2>/dev/null
			for _kf in "${_home}/.ssh"/id_*; do
				[ -f "$_kf" ] && [[ "$_kf" != *.pub ]] && chmod 600 "$_kf" 2>/dev/null
			done
			_fixed=$((_fixed + 1))
		done </etc/passwd
		green "已修复 ${_fixed} 个用户的 SSH 相关权限"
		;;
	  10)
		# ── 批量导入公钥（从文件）──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 批量导入公钥（从文件）━━━━━━${rw_lv}"
		echo ""
		echo -e " ${rw_lv}从文本文件读取公钥（每行一个），批量追加到指定用户${rw_lv}"
		echo ""
		read -e -p " 请输入公钥文件路径: " _import_file < /dev/tty
		if [ -z "$_import_file" ] || [ ! -f "$_import_file" ]; then
			red "文件不存在: ${_import_file:-空}"
			break_end
			continue
		fi
		# 统计文件中的公钥数
		local _file_cnt
		_file_cnt=$(grep -cE '^(ssh-|ecdsa-|sk-)' "$_import_file" 2>/dev/null || echo 0)
		if [ "$_file_cnt" -eq 0 ]; then
			red "文件中未找到有效的公钥行（需以 ssh-/ecdsa-/sk- 开头）"
			break_end
			continue
		fi
		echo -e " 文件中检测到 ${rw_huang}${_file_cnt}${rw_lv} 个公钥"
		echo ""
		if ! _pk_pick_user; then
			red "无效选择"
			break_end
			continue
		fi
		echo ""
		echo -e " ${rw_huang}正在导入到 ${_PK_TARGET_U} ...${rw_lv}"
		local _imported=0 _skipped=0
		while IFS= read -r _line; do
			echo "$_line" | grep -qE '^(ssh-|ecdsa-|sk-)' || continue
			if grep -qF "$_line" "${_PK_TARGET_HOME}/.ssh/authorized_keys" 2>/dev/null; then
				_skipped=$((_skipped + 1))
			else
				_pk_add_pubkey "$_PK_TARGET_U" "$_PK_TARGET_HOME" "$_line" 2>/dev/null
				_imported=$((_imported + 1))
			fi
		done < "$_import_file"
		echo ""
		green "导入完成: 新增 ${_imported} 个, 跳过已存在 ${_skipped} 个"
		;;
	  11)
		# ── 导出指定用户的公钥到文件 ──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 导出指定用户的公钥到文件 ━━━━━━${rw_lv}"
		echo ""
		if ! _pk_pick_user; then
			red "无效选择"
			break_end
			continue
		fi
		local _auth_file="${_PK_TARGET_HOME}/.ssh/authorized_keys"
		if [ ! -f "$_auth_file" ] || [ ! -s "$_auth_file" ]; then
			yellow "  ${_PK_TARGET_U} 无公钥可导出"
			break_end
			continue
		fi
		local _export_file
		_export_file="${HOME}/${_PK_TARGET_U}_authorized_keys_$(date +%Y%m%d%H%M%S).txt"
		cp -a "$_auth_file" "$_export_file"
		chmod 644 "$_export_file"
		local _cnt
		_cnt=$(grep -cE '^(ssh-|ecdsa-|sk-)' "$_export_file" 2>/dev/null || echo 0)
		green "已导出 ${_cnt} 个公钥到:"
		echo -e "   ${rw_huang}${_export_file}${rw_lv}"
		;;
	  0)
		break
		;;
	  *)
		red "无效的输入!"
		;;
	esac
	break_cancel
done
}

# ================================================================
# 飞书扫码 SSH 登录管理器
# 原理: SSH 协议不支持飞书扫码，这里用 pam_exec 在 SSH 登录时
#       向飞书群机器人推送一条确认消息，管理员在飞书 App 里
#       看到登录提醒（含用户/IP/时间）。属于"登录通知"而非严格认证。
# 可选严格模式: 推送后等待管理员在指定文件里写 OK 才放行（见选项4）
# 依赖: curl + 飞书群机器人 Webhook URL
# ================================================================

# ── 飞书配置文件路径 ──
FEISHU_CONF="/etc/riwi/feishu_ssh.conf"
FEISHU_HOOK_SCRIPT="/usr/local/bin/riwi_feishu_ssh_notify.sh"

feishu_ssh_manager() {
while true; do
	clear
	echo -e "${rw_cheng}━━━━━━━━━━━━  飞书扫码 SSH 登录  ━━━━━━━━━━━━${rw_lv}"
	echo ""

	# ── 状态探测 ──
	local _fs_conf_stat="${rw_hong}未配置${rw_lv}" _fs_hook_stat="${rw_hong}未部署${rw_lv}" _fs_pam_stat="${rw_hong}未启用${rw_lv}"
	[ -f "$FEISHU_CONF" ] && [ -s "$FEISHU_CONF" ] && _fs_conf_stat="${rw_lv}已配置${rw_lv}"
	[ -f "$FEISHU_HOOK_SCRIPT" ] && [ -x "$FEISHU_HOOK_SCRIPT" ] && _fs_hook_stat="${rw_lv}已部署${rw_lv}"
	if grep -q "riwi_feishu_ssh_notify" /etc/pam.d/sshd 2>/dev/null; then
		_fs_pam_stat="${rw_lv}已启用${rw_lv}"
	fi
	local _fs_webhook=""
	if [ -f "$FEISHU_CONF" ]; then
		_fs_webhook=$(grep -E "^WEBHOOK=" "$FEISHU_CONF" 2>/dev/null | cut -d'=' -f2-)
	fi
	local _fs_mode="通知模式"
	if [ -f "$FEISHU_CONF" ] && grep -q "^STRICT_MODE=1" "$FEISHU_CONF" 2>/dev/null; then
		_fs_mode="严格模式（需确认）"
	fi

	echo -e " 配置: ${_fs_conf_stat}   脚本: ${_fs_hook_stat}   PAM: ${_fs_pam_stat}"
	echo -e " 当前模式: ${rw_huang}${_fs_mode}${rw_lv}"
	if [ -n "$_fs_webhook" ]; then
		local _fs_short="${_fs_webhook:0:50}..."
		echo -e " Webhook: ${rw_lv}${_fs_short}${rw_lv}"
	else
		echo -e " Webhook: ${rw_hong}未设置${rw_lv}"
	fi
	echo ""
	echo -e " ${rw_cheng}──── 配置 ────${rw_lv}"
	echo -e " ${rw_huang}1.   ${rw_lv}配置飞书机器人 Webhook${rw_lv}"
	echo -e " ${rw_huang}2.   ${rw_lv}测试飞书推送${rw_lv}"
	echo ""
	echo -e " ${rw_cheng}──── 启用 / 禁用 ────${rw_lv}"
	echo -e " ${rw_huang}3.   ${rw_lv}启用飞书 SSH 登录通知${rw_lv}"
	echo -e " ${rw_huang}4.   ${rw_lv}启用严格模式（推送后需手动确认才放行）${rw_lv}"
	echo -e " ${rw_huang}5.   ${rw_lv}禁用飞书 SSH 登录通知${rw_lv}"
	echo ""
	echo -e " ${rw_cheng}──── 管理 ────${rw_lv}"
	echo -e " ${rw_huang}6.   ${rw_lv}查看当前配置${rw_lv}"
	echo -e " ${rw_huang}7.   ${rw_lv}查看最近登录记录${rw_lv}"
	echo -e " ${rw_huang}8.   ${rw_lv}卸载飞书 SSH 通知${rw_lv}"
	echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
	echo -e " ${rw_huang}0.   ${rw_lv}返回上级菜单${rw_lv}"
	echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
	read -e -p " 请输入你的选择: " fs_choice

	case $fs_choice in
	  1)
		# ── 配置飞书 Webhook ──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 配置飞书机器人 Webhook ━━━━━━${rw_lv}"
		echo ""
		echo -e " ${rw_huang}获取 Webhook 步骤:${rw_lv}"
		echo -e "   1. 飞书群聊 → 设置 → 群机器人 → 添加机器人"
		echo -e "   2. 选择「自定义机器人」"
		echo -e "   3. 安全设置: 勾选「自定义关键词」填 ${rw_lv}SSH${rw_lv}（消息必须含此词才发送）"
		echo -e "   4. 复制 Webhook 地址（形如 https://open.feishu.cn/open-apis/bot/v2/hook/xxxx）"
		echo ""
		read -e -p " 请粘贴 Webhook URL: " _fs_webhook < /dev/tty
		if [ -z "$_fs_webhook" ]; then
			red "Webhook 不能为空"
			break_end
			continue
		fi
		if ! echo "$_fs_webhook" | grep -qE "^https://open.feishu.cn/open-apis/bot/v2/hook/"; then
			red "URL 格式不对，应以 https://open.feishu.cn/open-apis/bot/v2/hook/ 开头"
			break_end
			continue
		fi
		mkdir -p /etc/riwi
		# 保留旧的 STRICT_MODE 设置
		local _old_strict=""
		[ -f "$FEISHU_CONF" ] && _old_strict=$(grep "^STRICT_MODE=" "$FEISHU_CONF" 2>/dev/null | cut -d'=' -f2)
		[ -z "$_old_strict" ] && _old_strict=0
		cat > "$FEISHU_CONF" <<EOF
# 飞书 SSH 登录通知配置
# 生成时间: $(date '+%Y-%m-%d %H:%M:%S')
WEBHOOK=${_fs_webhook}
# 严格模式: 0=仅通知  1=需在 ${_FS_CONFIRM_FILE:-/tmp/riwi_fs_confirm} 写 OK 才放行
STRICT_MODE=${_old_strict}
# 确认文件路径（严格模式用）
CONFIRM_FILE=/tmp/riwi_fs_confirm
# 确认超时秒数（严格模式用）
CONFIRM_TIMEOUT=60
EOF
		chmod 600 "$FEISHU_CONF"
		green "✓ 配置已保存到 ${FEISHU_CONF}"
		echo ""
		echo -e " ${rw_huang}建议立即执行选项 2 测试推送是否成功${rw_lv}"
		;;
	  2)
		# ── 测试推送 ──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 测试飞书推送 ━━━━━━${rw_lv}"
		echo ""
		if [ ! -f "$FEISHU_CONF" ]; then
			red "未配置 Webhook，请先执行选项 1"
			break_end
			continue
		fi
		local _wh
		_wh=$(grep "^WEBHOOK=" "$FEISHU_CONF" | cut -d'=' -f2-)
		if [ -z "$_wh" ]; then
			red "Webhook 为空，请重新配置"
			break_end
			continue
		fi
		echo -e " ${rw_huang}正在向飞书推送测试消息...${rw_lv}"
		local _test_msg
		_test_msg=$(cat <<EOF
{
  "msg_type": "text",
  "content": {
    "text": "【SSH 登录通知测试】\n服务器: $(hostname)\n时间: $(date '+%Y-%m-%d %H:%M:%S')\n这是一条来自 riwi 脚本工具箱的测试消息，如果你收到了说明飞书机器人配置成功。"
  }
}
EOF
)
		local _resp
		_resp=$(curl -s -m 10 -X POST "$_wh" -H "Content-Type: application/json" -d "$_test_msg" 2>/dev/null)
		if echo "$_resp" | grep -q '"StatusCode":0\|"code":0'; then
			green "✓ 推送成功，请到飞书群查看"
		else
			red "推送失败，飞书返回: $_resp"
			echo -e " ${rw_huang}常见原因:${rw_lv}"
			echo -e "   - Webhook URL 错误或已失效"
			echo -e "   - 安全设置关键词不匹配（需含 SSH）"
			echo -e "   - 服务器无法访问 open.feishu.cn"
		fi
		;;
	  3)
		# ── 启用飞书 SSH 登录通知（通知模式）──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 启用飞书 SSH 登录通知 ━━━━━━${rw_lv}"
		echo ""
		if [ ! -f "$FEISHU_CONF" ]; then
			red "未配置 Webhook，请先执行选项 1"
			break_end
			continue
		fi

		echo -e " ${rw_huang}即将执行:${rw_lv}"
		echo -e "   1) 部署通知脚本到 ${FEISHU_HOOK_SCRIPT}"
		echo -e "   2) 设置 STRICT_MODE=0（仅通知，不拦截登录）"
		echo -e "   3) 备份 /etc/pam.d/sshd"
		echo -e "   4) 在 PAM 中添加 pam_exec 调用"
		echo -e "   5) sshd -t 检查 → 询问重启"
		echo ""
		echo -e " ${rw_lv}登录流程: SSH 登录成功后，飞书群收到登录通知（用户/IP/时间）${rw_lv}"
		echo -e " ${rw_hong}注意: 通知模式不拦截登录，只提醒${rw_lv}"
		echo ""
		read -e -p " 确认启用？(y/N): " _confirm < /dev/tty
		if [[ ! "$_confirm" =~ ^[Yy]$ ]]; then
			yellow "已取消"
			break_cancel
			continue
		fi

		# 设置为通知模式
		sed -i 's/^STRICT_MODE=.*/STRICT_MODE=0/' "$FEISHU_CONF" 2>/dev/null

		# 部署通知脚本
		_feishu_deploy_hook_script
		if [ ! -f "$FEISHU_HOOK_SCRIPT" ]; then
			red "脚本部署失败"
			break_end
			continue
		fi

		# 备份 + 写入 PAM
		_ssh_backup_configs
		if ! grep -q "riwi_feishu_ssh_notify" /etc/pam.d/sshd 2>/dev/null; then
			# pam_exec 放在 session 阶段，登录成功后执行
			if grep -q "pam_unix.so" /etc/pam.d/sshd 2>/dev/null; then
				sed -i '/^session.*pam_unix.so/a session    optional    pam_exec.so '"$FEISHU_HOOK_SCRIPT" /etc/pam.d/sshd
			else
				echo "session    optional    pam_exec.so $FEISHU_HOOK_SCRIPT" >> /etc/pam.d/sshd
			fi
			green "PAM 已添加 pam_exec 调用"
		else
			yellow "PAM 中已存在飞书通知调用（保留）"
		fi

		# sshd 需要启用 UsePAM
		if grep -qE "^#?UsePAM" /etc/ssh/sshd_config 2>/dev/null; then
			sed -i -E 's/^#?UsePAM.*/UsePAM yes/' /etc/ssh/sshd_config
		else
			echo "UsePAM yes" >> /etc/ssh/sshd_config
		fi
		green "sshd_config 已确保 UsePAM yes"

		_ssh_apply_and_restart
		;;
	  4)
		# ── 启用严格模式（需确认才放行）──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 启用严格模式 ━━━━━━${rw_lv}"
		echo ""
		if [ ! -f "$FEISHU_CONF" ]; then
			red "未配置 Webhook，请先执行选项 1"
			break_end
			continue
		fi
		if [ ! -f "$FEISHU_HOOK_SCRIPT" ]; then
			red "通知脚本未部署，请先执行选项 3"
			break_end
			continue
		fi

		echo -e " ${rw_huang}严格模式说明:${rw_lv}"
		echo -e "   SSH 登录时推送飞书消息，然后在服务器上等待管理员"
		echo -e "   在 ${rw_huang}/tmp/riwi_fs_confirm${rw_lv} 文件中写入 OK 才放行登录"
		echo -e "   超时（默认60秒）未确认则登录失败"
		echo ""
		echo -e " ${rw_hong}⚠ 严格模式会拦截登录，配置失误可能导致无法 SSH 登录！${rw_lv}"
		echo -e " ${rw_hong}⚠ 启用前请确保有 VNC/控制台等备用登录方式！${rw_lv}"
		echo ""
		echo -e " ${rw_huang}确认方式: 登录时飞书收到通知后，管理员在服务器执行:${rw_lv}"
		echo -e "   ${rw_lv}echo OK > /tmp/riwi_fs_confirm${rw_lv}"
		echo ""
		read -e -p " 确认启用严格模式？(y/N): " _confirm < /dev/tty
		if [[ ! "$_confirm" =~ ^[Yy]$ ]]; then
			yellow "已取消"
			break_cancel
			continue
		fi
		read -e -p " 再次确认（输入 yes）: " _confirm2 < /dev/tty
		if [ "$_confirm2" != "yes" ]; then
			yellow "已取消"
			break_cancel
			continue
		fi

		_ssh_backup_configs
		sed -i 's/^STRICT_MODE=.*/STRICT_MODE=1/' "$FEISHU_CONF" 2>/dev/null
		green "已切换为严格模式"

		# 确保 PAM 中是 required（强制执行）
		if grep -q "riwi_feishu_ssh_notify" /etc/pam.d/sshd 2>/dev/null; then
			sed -i -E "s|^(session[[:space:]]+)(optional|required)[[:space:]]+(pam_exec.so.*riwi_feishu)|\1required \3|" /etc/pam.d/sshd
			green "PAM 已改为 required（强制执行）"
		else
			# 没有就先走选项3的流程
			_feishu_deploy_hook_script
			if grep -q "pam_unix.so" /etc/pam.d/sshd 2>/dev/null; then
				sed -i '/^session.*pam_unix.so/a session    required    pam_exec.so '"$FEISHU_HOOK_SCRIPT" /etc/pam.d/sshd
			else
				echo "session    required    pam_exec.so $FEISHU_HOOK_SCRIPT" >> /etc/pam.d/sshd
			fi
			green "PAM 已添加 pam_exec（required）"
		fi

		if grep -qE "^#?UsePAM" /etc/ssh/sshd_config 2>/dev/null; then
			sed -i -E 's/^#?UsePAM.*/UsePAM yes/' /etc/ssh/sshd_config
		else
			echo "UsePAM yes" >> /etc/ssh/sshd_config
		fi

		_ssh_apply_and_restart
		;;
	  5)
		# ── 禁用 ──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 禁用飞书 SSH 登录通知 ━━━━━━${rw_lv}"
		echo ""
		if ! grep -q "riwi_feishu_ssh_notify" /etc/pam.d/sshd 2>/dev/null; then
			yellow "PAM 中未找到飞书通知调用，可能未启用"
			break_end
			continue
		fi
		echo -e " ${rw_huang}即将执行:${rw_lv}"
		echo -e "   1) 备份 /etc/pam.d/sshd"
		echo -e "   2) 从 PAM 移除 riwi_feishu_ssh_notify 行"
		echo -e "   3) sshd -t 检查 → 询问重启"
		echo ""
		read -e -p " 确认禁用？(y/N): " _confirm < /dev/tty
		if [[ ! "$_confirm" =~ ^[Yy]$ ]]; then
			yellow "已取消"
			break_cancel
			continue
		fi
		_ssh_backup_configs
		sed -i '/riwi_feishu_ssh_notify/d' /etc/pam.d/sshd 2>/dev/null
		green "已从 PAM 移除飞书通知调用"
		_ssh_apply_and_restart
		;;
	  6)
		# ── 查看当前配置 ──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 当前飞书 SSH 配置 ━━━━━━${rw_lv}"
		echo ""
		if [ ! -f "$FEISHU_CONF" ]; then
			yellow "配置文件不存在: $FEISHU_CONF"
		else
			echo -e " ${rw_huang}配置文件:${rw_lv} $FEISHU_CONF"
			echo ""
			cat "$FEISHU_CONF" | while read -r _line; do
				echo "$_line" | grep -q "^#" && echo -e " ${rw_lv}$_line${rw_lv}" || \
					echo -e " ${rw_huang}$_line${rw_lv}"
			done
		fi
		echo ""
		echo -e " ${rw_huang}通知脚本:${rw_lv} $([ -f "$FEISHU_HOOK_SCRIPT" ] && echo "${rw_lv}存在${rw_lv}" || echo "${rw_hong}不存在${rw_lv}")"
		echo -e " ${rw_huang}PAM 状态:${rw_lv} $(grep -q "riwi_feishu_ssh_notify" /etc/pam.d/sshd 2>/dev/null && echo "${rw_lv}已启用${rw_lv}" || echo "${rw_hong}未启用${rw_lv}")"
		;;
	  7)
		# ── 查看最近登录记录 ──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 最近 SSH 登录记录 ━━━━━━${rw_lv}"
		echo ""
		if ! command -v last &>/dev/null; then
			yellow "last 命令不可用"
			break_end
			continue
		fi
		last -n 20 -a 2>/dev/null | head -25 || last -n 20 2>/dev/null | head -25
		;;
	  8)
		# ── 卸载 ──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 卸载飞书 SSH 通知 ━━━━━━${rw_lv}"
		echo ""
		echo -e " ${rw_hong}⚠ 将删除:${rw_lv}"
		echo -e "   - $FEISHU_CONF（配置文件）"
		echo -e "   - $FEISHU_HOOK_SCRIPT（通知脚本）"
		echo -e "   - /etc/pam.d/sshd 中的飞书 PAM 行"
		echo ""
		read -e -p " 确认卸载？(yes确认): " _confirm < /dev/tty
		if [ "$_confirm" != "yes" ]; then
			yellow "已取消"
			break_cancel
			continue
		fi
		_ssh_backup_configs
		sed -i '/riwi_feishu_ssh_notify/d' /etc/pam.d/sshd 2>/dev/null
		green "PAM 已清理"
		rm -f "$FEISHU_CONF" "$FEISHU_HOOK_SCRIPT" 2>/dev/null
		green "✓ 配置和脚本已删除"
		_ssh_apply_and_restart
		;;
	  0)
		break
		;;
	  *)
		red "无效的输入!"
		;;
	esac
	break_cancel
done
}

# ── 辅助: 部署飞书通知脚本 ──
_feishu_deploy_hook_script() {
	mkdir -p /usr/local/bin
	cat > "$FEISHU_HOOK_SCRIPT" <<'SCRIPT'
#!/bin/bash
# riwi 飞书 SSH 登录通知脚本（由 pam_exec 调用）
# 环境变量: PAM_TYPE (auth/account/session/open_session/close_session)
#           PAM_USER (用户名)  PAM_RHOST (远程IP)

CONF="/etc/riwi/feishu_ssh.conf"
LOG="/var/log/riwi_feishu_ssh.log"

# 只在 session open 时触发（登录成功）
[ "$PAM_TYPE" = "open_session" ] || exit 0

# 读配置
[ ! -f "$CONF" ] && exit 0
source "$CONF" 2>/dev/null
[ -z "$WEBHOOK" ] && exit 0

# 基本变量
_USER="${PAM_USER:-unknown}"
_RHOST="${PAM_RHOST:-未知}"
_HOST=$(hostname 2>/dev/null || echo "未知")
_TIME=$(date '+%Y-%m-%d %H:%M:%S')

# 记录日志
mkdir -p "$(dirname "$LOG")" 2>/dev/null
echo "$_TIME | user=$_USER | rhost=$_RHOST | host=$_HOST" >> "$LOG" 2>/dev/null

# 构造消息
MSG="【SSH 登录通知】
服务器: $_HOST
用户: $_USER
来源IP: $_RHOST
时间: $_TIME"

# 严格模式: 推送后等待确认
if [ "${STRICT_MODE:-0}" = "1" ]; then
	MSG="$MSG

⚠ 严格模式: 等待管理员确认
确认命令: echo OK > ${CONFIRM_FILE:-/tmp/riwi_fs_confirm}
超时: ${CONFIRM_TIMEOUT:-60} 秒"
fi

# 发送到飞书
PAYLOAD=$(cat <<EOF
{
  "msg_type": "text",
  "content": {
    "text": "$MSG"
  }
}
EOF
)

curl -s -m 10 -X POST "$WEBHOOK" -H "Content-Type: application/json" -d "$PAYLOAD" >/dev/null 2>&1

# 严格模式: 等待确认
if [ "${STRICT_MODE:-0}" = "1" ]; then
	_CONFIRM_FILE="${CONFIRM_FILE:-/tmp/riwi_fs_confirm}"
	_TIMEOUT="${CONFIRM_TIMEOUT:-60}"
	# 清空旧确认文件
	rm -f "$_CONFIRM_FILE" 2>/dev/null
	# 轮询等待
	_i=0
	while [ $_i -lt "$_TIMEOUT" ]; do
		if [ -f "$_CONFIRM_FILE" ] && grep -q "OK" "$_CONFIRM_FILE" 2>/dev/null; then
			rm -f "$_CONFIRM_FILE" 2>/dev/null
			echo "$_TIME | user=$_USER | CONFIRMED" >> "$LOG" 2>/dev/null
			exit 0
		fi
		sleep 1
		_i=$((_i + 1))
	done
	# 超时
	echo "$_TIME | user=$_USER | TIMEOUT_DENIED" >> "$LOG" 2>/dev/null
	exit 1
fi

exit 0
SCRIPT
	chmod 755 "$FEISHU_HOOK_SCRIPT"
}

# ================================================================
# SSH 认证管理 — 共用辅助函数
# 以下函数被双证/三证/硬证三个管理器复用，统一状态探测、备份、
# 冲突清理、语法检查、重启、回滚的执行逻辑。
# ================================================================

# ── 读取 sshd_config 中某个指令的生效值（去掉注释行，取第一个匹配）──
# 用法: _ssh_cfg_get <key> [default]
_ssh_cfg_get() {
	local _key="$1" _default="${2:-}"
	local _val
	_val=$(grep -E "^[[:space:]]*${_key}[[:space:]]+" /etc/ssh/sshd_config 2>/dev/null | head -1 | awk '{print $2}')
	[ -n "$_val" ] && echo "$_val" || echo "$_default"
}

# ── 探测当前实际生效的 SSH 认证模式 ──
# 输出到全局变量 _SSH_MODE / _SSH_MODE_DESC / _SSH_MODE_REASON
_ssh_current_auth_mode() {
	_ssh_mode="unknown"
	_ssh_mode_desc="未知"
	_ssh_mode_reason=""

	local _auth_methods _passauth _pubkeyauth _kbdint _pam_otp _has_sk

	_auth_methods=$(_ssh_cfg_get AuthenticationMethods "")
	_passauth=$(_ssh_cfg_get PasswordAuthentication yes)
	_pubkeyauth=$(_ssh_cfg_get PubkeyAuthentication yes)
	_kbdint=$(_ssh_cfg_get KbdInteractiveAuthentication "$(_ssh_cfg_get ChallengeResponseAuthentication no)")
	if grep -q "pam_google_authenticator.so" /etc/pam.d/sshd 2>/dev/null; then
		_pam_otp=1
	else
		_pam_otp=0
	fi
	if [ -f "$HOME/.ssh/authorized_keys" ] && grep -q "^sk-" "$HOME/.ssh/authorized_keys" 2>/dev/null; then
		_has_sk=1
	else
		_has_sk=0
	fi

	# 优先用 AuthenticationMethods 判断（最权威）
	case "$_auth_methods" in
		*publickey*keyboard-interactive*|*keyboard-interactive*publickey*)
			if echo "$_auth_methods" | grep -q "password"; then
				_ssh_mode="3fa"
				_ssh_mode_desc="三证（公钥+密码+OTP）"
				_ssh_mode_reason="AuthenticationMethods=$_auth_methods, PAM OTP=$([ $_pam_otp -eq 1 ] && echo on || echo off)"
			else
				_ssh_mode="2fa"
				_ssh_mode_desc="双证（公钥+OTP）"
				_ssh_mode_reason="AuthenticationMethods=$_auth_methods, PAM OTP=$([ $_pam_otp -eq 1 ] && echo on || echo off)"
			fi
			;;
		*publickey*password*|*password*publickey*)
			_ssh_mode="pubkey-password"
			_ssh_mode_desc="双证（公钥+密码）"
			_ssh_mode_reason="AuthenticationMethods=$_auth_methods"
			;;
		"")
			# 没有强制 AuthenticationMethods，看密码/公钥开关
			if [ "$_passauth" = "no" ] && [ "$_pubkeyauth" = "yes" ]; then
				if [ $_has_sk -eq 1 ] && [ "$_kbdint" != "yes" ]; then
					_ssh_mode="fido2"
					_ssh_mode_desc="硬证（FIDO2）"
					_ssh_mode_reason="PubkeyAuthentication=yes, PasswordAuthentication=no, authorized_keys 含 sk- 公钥"
				else
					_ssh_mode="pubkey-only"
					_ssh_mode_desc="仅公钥"
					_ssh_mode_reason="PasswordAuthentication=no, PubkeyAuthentication=yes"
				fi
			elif [ "$_passauth" = "yes" ] && [ "$_pubkeyauth" = "yes" ]; then
				_ssh_mode="pubkey-or-password"
				_ssh_mode_desc="公钥或密码（任一即可）"
				_ssh_mode_reason="PasswordAuthentication=yes, PubkeyAuthentication=yes, 无 AuthenticationMethods"
			elif [ "$_passauth" = "yes" ] && [ "$_pubkeyauth" = "no" ]; then
				_ssh_mode="password-only"
				_ssh_mode_desc="仅密码"
				_ssh_mode_reason="PasswordAuthentication=yes, PubkeyAuthentication=no"
			else
				_ssh_mode="unknown"
				_ssh_mode_desc="未知"
				_ssh_mode_reason="无法识别的组合: pass=$_passauth pubkey=$_pubkeyauth kbdint=$_kbdint"
			fi
			;;
		*)
			_ssh_mode="unknown"
			_ssh_mode_desc="未知（自定义）"
			_ssh_mode_reason="AuthenticationMethods=$_auth_methods"
			;;
	esac

	# 导出给调用方
	_SSH_MODE="$_ssh_mode"
	_SSH_MODE_DESC="$_ssh_mode_desc"
	_SSH_MODE_REASON="$_ssh_mode_reason"
}

# ── 统一状态面板（三个管理器顶部共用）──
_ssh_status_panel() {
	_ssh_current_auth_mode
	local _port _root _pass _pubkey _kbdint _sshd_stat
	_port=$(_ssh_cfg_get Port 22)
	_root=$(_ssh_cfg_get PermitRootLogin prohibit-password)
	_pass=$(_ssh_cfg_get PasswordAuthentication yes)
	_pubkey=$(_ssh_cfg_get PubkeyAuthentication yes)
	_kbdint=$(_ssh_cfg_get KbdInteractiveAuthentication "$(_ssh_cfg_get ChallengeResponseAuthentication no)")
	if systemctl is-active --quiet sshd 2>/dev/null || systemctl is-active --quiet ssh 2>/dev/null; then
		_sshd_stat="${rw_lv}运行中${rw_lv}"
	else
		_sshd_stat="${rw_hong}未运行${rw_lv}"
	fi

	# 颜色映射
	local _c_root _c_pass _c_pubkey
	case "$_root" in
		yes) _c_root="${rw_hong}$_root${rw_lv}" ;;
		no) _c_root="${rw_lv}$_root${rw_lv}" ;;
		*) _c_root="${rw_huang}$_root${rw_lv}" ;;
	esac
	[ "$_pass" = "yes" ] && _c_pass="${rw_hong}yes${rw_lv}" || _c_pass="${rw_lv}no${rw_lv}"
	[ "$_pubkey" = "yes" ] && _c_pubkey="${rw_lv}yes${rw_lv}" || _c_pubkey="${rw_hong}no${rw_lv}"

	echo -e "${rw_cheng}━━━━━━━━━━━━  SSH 认证状态  ━━━━━━━━━━━━${rw_lv}"
	echo -e " 当前模式: ${rw_huang}${_SSH_MODE_DESC}${rw_lv}"
	echo -e " 端口: ${rw_huang}${_port}${rw_lv}   服务: ${_sshd_stat}"
	echo -e " Root登录: ${_c_root}   密码: ${_c_pass}   公钥: ${_c_pubkey}   KbdInteractive: ${_kbdint}"
	if [ -n "$_SSH_MODE_REASON" ]; then
		echo -e " ${rw_lv}依据: ${_SSH_MODE_REASON}${rw_lv}"
	fi
	echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
}

# ── 统一备份 sshd_config + pam.d/sshd ──
# 备份路径写入全局 _SSH_BACKUP_TAG / _SSH_BACKUP_DIR
# 同时备份所有有 authorized_keys 的可登录用户公钥文件
_ssh_backup_configs() {
	_SSH_BACKUP_TAG=$(date +%Y%m%d%H%M%S)
	_SSH_BACKUP_DIR="/tmp/riwi_ssh_backup_${_SSH_BACKUP_TAG}"
	mkdir -p "$_SSH_BACKUP_DIR"
	local _bk_count=0
	if [ -f /etc/ssh/sshd_config ]; then
		cp -a /etc/ssh/sshd_config "$_SSH_BACKUP_DIR/sshd_config"
		_bk_count=$((_bk_count + 1))
	fi
	if [ -f /etc/pam.d/sshd ]; then
		cp -a /etc/pam.d/sshd "$_SSH_BACKUP_DIR/pam_sshd"
		_bk_count=$((_bk_count + 1))
	fi
	# 备份当前用户 authorized_keys（兼容旧逻辑）
	if [ -f "$HOME/.ssh/authorized_keys" ]; then
		cp -a "$HOME/.ssh/authorized_keys" "$_SSH_BACKUP_DIR/authorized_keys"
		_bk_count=$((_bk_count + 1))
	fi
	# 额外备份所有有 authorized_keys 的普通用户+root，避免遗漏实际登录用户
	local _u _uid _home
	while IFS=: read -r _u _ _uid _ _ _home _; do
		[ "$_uid" -lt 1000 ] 2>/dev/null && [ "$_u" != "root" ] && continue
		[ -z "$_home" ] && continue
		[ "$_home" = "$HOME" ] && continue  # 已备份过
		if [ -f "${_home}/.ssh/authorized_keys" ]; then
			# 文件名用用户名避免冲突
			local _safe_u
			_safe_u=$(printf '%s' "$_u" | tr -c 'A-Za-z0-9_-' '_')
			cp -a "${_home}/.ssh/authorized_keys" "$_SSH_BACKUP_DIR/authorized_keys.${_safe_u}" 2>/dev/null
			_bk_count=$((_bk_count + 1))
		fi
	done </etc/passwd 2>/dev/null
	echo -e " ${rw_lv}已备份 ${_bk_count} 个文件到 ${rw_huang}${_SSH_BACKUP_DIR}${rw_lv}"
}

# ── 清理上一个认证模式留下的冲突项 ──
# 清理目标: AuthenticationMethods / KbdInteractiveAuthentication /
# ChallengeResponseAuthentication / PAM 中的 google_authenticator 行 /
# 所有 Match User 块中的认证相关字段（不再只清 whoami，避免误伤其他登录用户）
_ssh_clear_conflicting_auth() {
	# 1. 注释掉全局 AuthenticationMethods（用 #riwi-disabled 前缀，方便追溯）
	if grep -qE '^[[:space:]]*AuthenticationMethods' /etc/ssh/sshd_config 2>/dev/null; then
		sed -i -E 's/^([[:space:]]*)(AuthenticationMethods[[:space:]].*)/#riwi-disabled \1\2/' /etc/ssh/sshd_config
		echo -e " ${rw_lv}已注释全局 AuthenticationMethods${rw_lv}"
	fi

	# 2. 清理【所有】Match User/Match Group 块中认证相关字段
	#    不再只清 whoami，否则其他登录用户（如 root 跑脚本但实际用 xin 登录）的残留限制会被遗漏
	#    sshd_config 的 Match 块边界: 从 Match 行开始，到下一个 Match 行或文件末尾
	#    策略：在 Match 块范围内，注释掉认证字段行（保留块本身和无关字段如 AllowTcpForwarding）
	local _match_cleaned=0
	if grep -qE '^[[:space:]]*Match[[:space:]]' /etc/ssh/sshd_config 2>/dev/null; then
		awk '
			# 遇到新的 Match 行：进入 match 块
			/^[[:space:]]*Match[[:space:]]/ { in_match=1 }
			# 在 match 块内遇到认证字段：注释掉
			{
				if (in_match && /^[[:space:]]*(AuthenticationMethods|KbdInteractiveAuthentication|ChallengeResponseAuthentication|PasswordAuthentication|PubkeyAuthentication)[[:space:]]/) {
					print "#riwi-disabled " $0
					cleaned=1
				} else {
					print
				}
			}
			END { if (cleaned) exit 0; else exit 1 }
		' /etc/ssh/sshd_config > /tmp/riwi_sshd_clean.$$.tmp
		if [ $? -eq 0 ]; then
			mv /tmp/riwi_sshd_clean.$$.tmp /etc/ssh/sshd_config
			_match_cleaned=1
		else
			rm -f /tmp/riwi_sshd_clean.$$.tmp
		fi
	fi
	[ $_match_cleaned -eq 1 ] && echo -e " ${rw_lv}已清理所有 Match 块中的旧认证字段${rw_lv}"

	# 3. 移除 PAM 中的 google_authenticator 行（除非调用方明确要保留）
	#    由调用方决定是否重新写入
	if grep -q "pam_google_authenticator.so" /etc/pam.d/sshd 2>/dev/null; then
		sed -i '/pam_google_authenticator.so/d' /etc/pam.d/sshd 2>/dev/null
		echo -e " ${rw_lv}已移除 PAM 中的 google_authenticator 行${rw_lv}"
	fi
}

# ── 设置 sshd_config 指令（存在则改，不存在则追加）──
# 用法: _ssh_cfg_set <key> <value>
_ssh_cfg_set() {
	local _key="$1" _val="$2"
	if grep -qE "^[[:space:]]*#?${_key}[[:space:]]+" /etc/ssh/sshd_config 2>/dev/null; then
		sed -i -E "s|^[[:space:]]*#?${_key}[[:space:]].*|${_key} ${_val}|" /etc/ssh/sshd_config
	else
		echo "${_key} ${_val}" >> /etc/ssh/sshd_config
	fi
}

# ── 语法检查 + 询问重启 ──
# 失败时自动回滚 _SSH_BACKUP_DIR 中的备份
# 用法: _ssh_apply_and_restart
_ssh_apply_and_restart() {
	if [ -z "$_SSH_BACKUP_DIR" ] || [ ! -d "$_SSH_BACKUP_DIR" ]; then
		red "内部错误: 未找到备份目录，无法安全应用配置"
		return 1
	fi

	echo ""
	echo -e " ${rw_huang}正在执行 SSH 配置语法检查 (sshd -t)...${rw_lv}"
	local _sshd_err
	_sshd_err=$(sshd -t 2>&1)
	if [ $? -ne 0 ]; then
		red "SSH 配置语法检查失败！"
		echo -e " ${rw_hong}错误信息: ${_sshd_err}${rw_lv}"
		echo ""
		echo -e " ${rw_huang}正在自动回滚备份...${rw_lv}"
		_ssh_restore_backup
		return 1
	fi
	green "SSH 配置语法检查通过"

	echo ""
	read -e -p " 是否立即重启 SSH 服务使配置生效？(y/N): " _restart < /dev/tty
	if [[ "$_restart" =~ ^[Yy]$ ]]; then
		if systemctl restart sshd 2>/dev/null || service ssh restart 2>/dev/null || systemctl restart ssh 2>/dev/null; then
			green "SSH 服务已重启，配置已生效"
		else
			red "SSH 服务重启失败，请手动检查"
			echo -e " ${rw_huang}备份目录: ${_SSH_BACKUP_DIR}${rw_lv}"
		fi
	else
		yellow "配置已保存，请稍后手动重启 SSH 服务使配置生效"
		echo -e " ${rw_huang}提示: systemctl restart sshd${rw_lv}"
	fi
	return 0
}

# ── 从 _SSH_BACKUP_DIR 回滚 ──
_ssh_restore_backup() {
	if [ -z "$_SSH_BACKUP_DIR" ] || [ ! -d "$_SSH_BACKUP_DIR" ]; then
		red "未找到备份目录，无法回滚"
		return 1
	fi
	if [ -f "$_SSH_BACKUP_DIR/sshd_config" ]; then
		cp -a "$_SSH_BACKUP_DIR/sshd_config" /etc/ssh/sshd_config
		echo -e " ${rw_lv}已回滚 /etc/ssh/sshd_config${rw_lv}"
	fi
	if [ -f "$_SSH_BACKUP_DIR/pam_sshd" ]; then
		cp -a "$_SSH_BACKUP_DIR/pam_sshd" /etc/pam.d/sshd
		echo -e " ${rw_lv}已回滚 /etc/pam.d/sshd${rw_lv}"
	fi
	if [ -f "$_SSH_BACKUP_DIR/authorized_keys" ]; then
		cp -a "$_SSH_BACKUP_DIR/authorized_keys" "$HOME/.ssh/authorized_keys"
		echo -e " ${rw_lv}已回滚 ~/.ssh/authorized_keys${rw_lv}"
	fi
	# 回滚其它用户的 authorized_keys
	local _bk_file _dest_home _bk_user
	for _bk_file in "$_SSH_BACKUP_DIR"/authorized_keys.*; do
		[ -f "$_bk_file" ] || continue
		# 从文件名提取用户名（authorized_keys.<user>）
		_bk_user="${_bk_file##*.}"
		_dest_home=$(getent passwd "$_bk_user" | cut -d: -f6)
		[ -z "$_dest_home" ] && continue
		if [ -d "$_dest_home/.ssh" ]; then
			cp -a "$_bk_file" "$_dest_home/.ssh/authorized_keys"
			echo -e " ${rw_lv}已回滚 ${_bk_user} 的 authorized_keys${rw_lv}"
		fi
	done
	green "回滚完成"
}

# ── 为指定用户配置 OTP（交互式运行 google-authenticator）──
# 用法: _ssh_otp_configure_user <username>
_ssh_otp_configure_user() {
	local _target_u="$1"
	local _target_home
	_target_home=$(getent passwd "$_target_u" | cut -d: -f6)
	[ ! -d "$_target_home" ] && { red "无法获取用户 ${_target_u} 的 home 目录"; return 1; }

	echo ""
	echo -e " ${rw_huang}目标用户: ${rw_lv}${_target_u}"
	echo -e " ${rw_hong}注意: 接下来会以 ${_target_u} 身份运行 google-authenticator${rw_lv}"
	echo -e " ${rw_hong}请用手机 App (Google/Microsoft Authenticator) 扫码${rw_lv}"
	echo ""
	echo -e " ${rw_huang}google-authenticator 推荐回答:${rw_lv}"
	echo -e "   Q1: 是否基于时间?                → ${rw_lv}y${rw_lv}"
	echo -e "   Q2: 是否更新 ~/.google_authenticator? → ${rw_lv}y${rw_lv}"
	echo -e "   Q3: 是否禁止多地点复用令牌?      → ${rw_lv}y${rw_lv}"
	echo -e "   Q4: 是否扩大时间窗口?            → ${rw_lv}n${rw_lv}"
	echo -e "   Q5: 是否启用限速?                → ${rw_lv}y${rw_lv}"
	echo ""
	read -e -p " 按回车开始交互配置（需手动操作）..." _dummy < /dev/tty
	echo ""

	# 优先用非交互参数生成，失败再退回交互
	su - "$_target_u" -c "google-authenticator -t -d -f -W -r 3 -R 30" 2>&1 || \
		su - "$_target_u" -c "google-authenticator" 2>&1

	echo ""
	if [ -f "${_target_home}/.google_authenticator" ]; then
		green "OTP 配置文件已生成: ${_target_home}/.google_authenticator"
		echo -e " ${rw_hong}⚠ 请务必保存好紧急备用码（无法找回）！${rw_lv}"
		return 0
	else
		red "配置文件未生成，可能配置未完成"
		return 1
	fi
}

# ── 删除指定用户的 OTP 配置（~/.google_authenticator）──
# 用途: OTP 配置错了（手机丢失/扫错码/紧急码丢失），删掉重来
# 用法: _ssh_otp_delete_user <username>
_ssh_otp_delete_user() {
	local _target_u="$1"
	local _target_home
	_target_home=$(getent passwd "$_target_u" | cut -d: -f6)
	[ ! -d "$_target_home" ] && { red "无法获取用户 ${_target_u} 的 home 目录"; return 1; }

	local _ga_file="${_target_home}/.google_authenticator"
	if [ ! -f "$_ga_file" ]; then
		yellow "用户 ${_target_u} 本来就没有 OTP 配置"
		return 0
	fi

	# 备份再删（防止误删，留 7 天恢复窗口）
	local _bk_dir="/tmp/riwi_otp_backup_$(date +%Y%m%d%H%M%S)"
	mkdir -p "$_bk_dir"
	cp -a "$_ga_file" "$_bk_dir/.google_authenticator.${_target_u}" 2>/dev/null
	# 同时备份同目录可能存在的 .google_authenticator~ 临时文件
	[ -f "${_ga_file}~" ] && cp -a "${_ga_file}~" "$_bk_dir/.google_authenticator~.${_target_u}" 2>/dev/null

	# 修正属主（备份+删除都保持原用户）
	chown -R "$_target_u":"$(id -gn "$_target_u" 2>/dev/null)" "$_bk_dir" 2>/dev/null

	rm -f "$_ga_file" "${_ga_file}~"
	if [ ! -f "$_ga_file" ]; then
		green "✓ 已删除 ${_target_u} 的 OTP 配置"
		echo -e " ${rw_lv}备份位置: ${rw_huang}${_bk_dir}/${rw_lv}"
		echo -e " ${rw_huang}现在可以重新执行「为用户配置 OTP 动态码」${rw_lv}"
		return 0
	else
		red "删除失败，请检查权限"
		return 1
	fi
}

# ── 辅助: 审计所有可登录用户的公钥/OTP 配置状态 ──
# 用途: 启用双证/三证/禁用密码登录前，全局检查哪些用户会受影响
# 输出:
#   $_AUDIT_USERS        — 可登录用户总数
#   $_AUDIT_HAS_PUBKEY   — 有公钥的用户数
#   $_AUDIT_HAS_OTP      — 有OTP的用户数
#   $_AUDIT_MISSING      — 缺公钥或缺OTP的用户清单（换行分隔）
#   $_AUDIT_OK           — 1=全部齐备, 0=有缺失
_ssh_audit_auth_users() {
	_AUDIT_USERS=0
	_AUDIT_HAS_PUBKEY=0
	_AUDIT_HAS_OTP=0
	_AUDIT_MISSING=""
	_AUDIT_OK=1

	local _u _uid _home _shell _missing_pub _missing_otp _has_pub _has_otp
	while IFS=: read -r _u _ _uid _ _ _home _shell; do
		# 跳过无登录 shell 的系统用户（保留 root）
		case "$_shell" in
			""|/sbin/nologin|/usr/sbin/nologin|/bin/false|/usr/bin/false|/bin/sync|/sbin/halt|/sbin/shutdown)
				[ "$_u" != "root" ] && continue
				;;
		esac
		# 跳过 UID<1000 的非 root 系统用户
		[ "$_uid" -lt 1000 ] 2>/dev/null && [ "$_u" != "root" ] && continue
		[ -z "$_shell" ] && [ "$_u" != "root" ] && continue

		_AUDIT_USERS=$((_AUDIT_USERS + 1))
		# 解析 home（兜底用 $HOME 仅对当前用户）
		[ -z "$_home" ] && [ "$_u" = "$(whoami)" ] && _home="$HOME"
		[ -z "$_home" ] && continue

		_has_pub=0
		_has_otp=0
		[ -f "${_home}/.ssh/authorized_keys" ] && [ -s "${_home}/.ssh/authorized_keys" ] && _has_pub=1
		[ -f "${_home}/.google_authenticator" ] && _has_otp=1

		[ $_has_pub -eq 1 ] && _AUDIT_HAS_PUBKEY=$((_AUDIT_HAS_PUBKEY + 1))
		[ $_has_otp -eq 1 ]  && _AUDIT_HAS_OTP=$((_AUDIT_HAS_OTP + 1))

		_missing_pub=""
		_missing_otp=""
		[ $_has_pub -eq 0 ] && _missing_pub="无公钥"
		[ $_has_otp -eq 0 ]  && _missing_otp="无OTP"
		if [ -n "$_missing_pub" ] || [ -n "$_missing_otp" ]; then
			_AUDIT_OK=0
			local _gap=""
			[ -n "$_missing_pub" ] && _gap="$_missing_pub"
			[ -n "$_missing_otp" ]  && _gap="${_gap:+$_gap, }$_missing_otp"
			_AUDIT_MISSING="${_AUDIT_MISSING}${_u} (${_gap}) -> ${_home}
"
		fi
	done </etc/passwd 2>/dev/null

	# 去掉末尾换行
	_AUDIT_MISSING="${_AUDIT_MISSING%$'\n'}"
}

# ================================================================
# 双证登录管理器（公钥 + OTP 动态码，不需要密码）
# 登录流程: 1) 客户端用私钥通过公钥认证  2) 输入手机 App 中的 6 位 OTP
# 依赖: google-authenticator (PAM 模块) + 已部署的 SSH 公钥
# ================================================================
ssh_two_factor_manager() {
while true; do
	clear
	_ssh_status_panel

	# 探测 OTP 依赖状态
	local _otp_pkg _otp_pam _otp_users
	if command -v google-authenticator &>/dev/null || \
	   dpkg -l libpam-google-authenticator 2>/dev/null | grep -q "^ii" || \
	   rpm -q google-authenticator 2>/dev/null | grep -q "google-authenticator"; then
		_otp_pkg="${rw_lv}已安装${rw_lv}"
	else
		_otp_pkg="${rw_hong}未安装${rw_lv}"
	fi
	if grep -q "pam_google_authenticator.so" /etc/pam.d/sshd 2>/dev/null; then
		_otp_pam="${rw_lv}已加载${rw_lv}"
	else
		_otp_pam="${rw_hong}未加载${rw_lv}"
	fi
	_otp_users=0
	while IFS=: read -r _u _p _uid _gid _gcos _home _shell; do
		[ "$_uid" -lt 1000 ] && [ "$_u" != "root" ] && continue
		[ -f "${_home}/.google_authenticator" ] && _otp_users=$((_otp_users + 1))
	done </etc/passwd 2>/dev/null

	echo -e " OTP 软件包: ${_otp_pkg}   PAM 模块: ${_otp_pam}   已配 OTP 用户: ${rw_huang}${_otp_users}${rw_lv}"
	echo ""
	echo -e " ${rw_cheng}──── 双证登录（公钥 + OTP）────${rw_lv}"
	echo -e " ${rw_huang}1.   ${rw_lv}安装 google-authenticator${rw_lv}"
	echo -e " ${rw_huang}2.   ${rw_lv}为用户配置 OTP 动态码${rw_lv}"
	echo -e " ${rw_huang}3.   ${rw_lv}启用双证登录（公钥 + OTP）${rw_lv}"
	echo -e " ${rw_huang}4.   ${rw_lv}禁用双证登录（恢复单一认证）${rw_lv}"
	echo -e " ${rw_huang}5.   ${rw_lv}查看已配置 OTP 的用户${rw_lv}"
	echo -e " ${rw_huang}6.   ${rw_lv}删除用户 OTP 配置（配置错了可重配）${rw_lv}"
	echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
	echo -e " ${rw_huang}0.   ${rw_lv}返回上级菜单${rw_lv}"
	echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
	read -e -p " 请输入你的选择: " tf_choice

	case $tf_choice in
	  1)
		# ── 安装 google-authenticator ──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 安装 google-authenticator ━━━━━━${rw_lv}"
		echo ""
		if command -v google-authenticator &>/dev/null; then
			green "google-authenticator 已经安装"
			break_end
			continue
		fi
		if command -v apt-get &>/dev/null; then
			echo -e " 检测到 Debian/Ubuntu，使用 apt 安装..."
			read -e -p " 确认安装 libpam-google-authenticator？(y/N): " _confirm < /dev/tty
			if [[ "$_confirm" =~ ^[Yy]$ ]]; then
				apt-get update -y && apt-get install -y libpam-google-authenticator
				[ $? -eq 0 ] && green "安装成功！" || red "安装失败，请手动安装 libpam-google-authenticator"
			else
				yellow "已取消"
			fi
		elif command -v dnf &>/dev/null; then
			echo -e " 检测到 Fedora/RHEL9+，使用 dnf 安装..."
			read -e -p " 确认安装 google-authenticator？(y/N): " _confirm < /dev/tty
			if [[ "$_confirm" =~ ^[Yy]$ ]]; then
				dnf install -y google-authenticator
				[ $? -eq 0 ] && green "安装成功！" || red "安装失败"
			else
				yellow "已取消"
			fi
		elif command -v yum &>/dev/null; then
			echo -e " 检测到 CentOS/RHEL，使用 yum 安装..."
			echo -e " ${rw_hong}提示: EPEL 仓库可能需要先启用${rw_lv}"
			read -e -p " 确认安装？(y/N): " _confirm < /dev/tty
			if [[ "$_confirm" =~ ^[Yy]$ ]]; then
				yum install -y google-authenticator
				[ $? -eq 0 ] && green "安装成功！" || red "安装失败"
			else
				yellow "已取消"
			fi
		elif command -v apk &>/dev/null; then
			echo -e " 检测到 Alpine，使用 apk 安装..."
			read -e -p " 确认安装？(y/N): " _confirm < /dev/tty
			if [[ "$_confirm" =~ ^[Yy]$ ]]; then
				apk add --no-cache google-authenticator
				[ $? -eq 0 ] && green "安装成功！" || red "安装失败"
			else
				yellow "已取消"
			fi
		else
			red "无法识别包管理器，请手动安装"
			echo -e " Debian/Ubuntu: ${rw_huang}apt-get install libpam-google-authenticator${rw_lv}"
			echo -e " CentOS/RHEL:   ${rw_huang}yum install google-authenticator${rw_lv}"
		fi
		;;
	  2)
		# ── 为用户配置 OTP ──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 为用户配置 OTP ━━━━━━${rw_lv}"
		echo ""
		if ! command -v google-authenticator &>/dev/null; then
			red "google-authenticator 未安装，请先执行选项 1"
			break_end
			continue
		fi

		# 列出可用用户
		echo -e " ${rw_cheng}── 可用用户 ──${rw_lv}"
		local _avail_users=()
		while IFS=: read -r _u _p _uid _gid _gcos _home _shell; do
			[ "$_uid" -lt 1000 ] && [ "$_u" != "root" ] && continue
			[ -n "$_shell" ] && _avail_users+=("$_u")
		done </etc/passwd
		# root 也列入
		_avail_users+=("root")
		local _ui=1
		for _u in "${_avail_users[@]}"; do
			local _h=$(getent passwd "$_u" | cut -d: -f6)
			local _otp_mark=""
			[ -f "${_h}/.google_authenticator" ] && _otp_mark="${rw_lv}[已配OTP]${rw_lv}"
			echo -e " ${rw_huang}${_ui}.${rw_lv} $_u → ${_h} ${_otp_mark}"
			((_ui++))
		done
		echo -e " ${rw_huang}0.   ${rw_lv}取消${rw_lv}"
		echo ""
		read -e -p " 请选择用户编号: " _user_idx < /dev/tty
		[ "$_user_idx" = "0" ] && continue
		[ -z "$_user_idx" ] && { red "无效选择"; break_end; continue; }
		local _target_u=""
		_ui=1
		for _u in "${_avail_users[@]}"; do
			if [ "$_ui" -eq "$_user_idx" ]; then
				_target_u="$_u"
				break
			fi
			((_ui++))
		done
		[ -z "$_target_u" ] && { red "无效选择"; break_end; continue; }

		_ssh_otp_configure_user "$_target_u"
		;;
	  3)
		# ── 启用双证登录（公钥 + OTP）──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 启用双证登录（公钥 + OTP）━━━━━━${rw_lv}"
		echo ""

		# 前置检查
		if ! command -v google-authenticator &>/dev/null; then
			red "google-authenticator 未安装，请先执行选项 1"
			break_end
			continue
		fi

		# 多用户审计：双证全局生效，必须确认所有可登录用户都齐备
		_ssh_audit_auth_users
		echo -e " ${rw_cheng}── 可登录用户审计 ──${rw_lv}"
		echo -e "   可登录用户: ${rw_huang}${_AUDIT_USERS}${rw_lv}    有公钥: ${rw_huang}${_AUDIT_HAS_PUBKEY}${rw_lv}    有OTP: ${rw_huang}${_AUDIT_HAS_OTP}${rw_lv}"
		echo ""
		if [ $_AUDIT_USERS -eq 0 ]; then
			red "未发现可登录用户，无法启用双证"
			break_end
			continue
		fi
		# 双证 = 公钥 + OTP，所以两个都必须有
		if [ $_AUDIT_OK -eq 0 ]; then
			echo -e " ${rw_hong}⚠ 以下用户缺少公钥或 OTP，启用后这些用户将无法 SSH 登录：${rw_lv}"
			echo "$_AUDIT_MISSING" | sed 's/^/   /'
			echo ""
			echo -e " ${rw_huang}双证全局生效，建议先为所有用户补齐公钥+OTP${rw_lv}"
			echo -e " ${rw_huang}公钥: 主菜单 → 12.密钥管理 → SSH 配置 → 添加 SSH 公钥${rw_lv}"
			echo -e " ${rw_huang}OTP : 本菜单选项 2「为用户配置 OTP 动态码」${rw_lv}"
			echo ""
			read -e -p " 仍要强制启用双证？(输入 yes 继续): " _force < /dev/tty
			if [ "$_force" != "yes" ]; then
				yellow "已取消"
				break_cancel
				continue
			fi
		else
			green "✓ 所有可登录用户均已配置公钥 + OTP"
		fi

		echo -e " ${rw_huang}即将执行的变更:${rw_lv}"
		echo -e "   1) 备份 sshd_config + pam.d/sshd + authorized_keys"
		echo -e "   2) 清理旧的认证模式残留 (AuthenticationMethods / Match 块 / PAM OTP)"
		echo -e "   3) 写入 PAM: ${rw_huang}auth required pam_google_authenticator.so nullok${rw_lv}"
		echo -e "   4) sshd_config:"
		echo -e "      ${rw_huang}PasswordAuthentication no${rw_lv}        (双证不使用密码)"
		echo -e "      ${rw_huang}PubkeyAuthentication yes${rw_lv}"
		echo -e "      ${rw_huang}KbdInteractiveAuthentication yes${rw_lv} (新版 OpenSSH)"
		echo -e "      ${rw_huang}ChallengeResponseAuthentication yes${rw_lv} (旧版兼容)"
		echo -e "      ${rw_huang}AuthenticationMethods publickey,keyboard-interactive${rw_lv}"
		echo -e "   5) sshd -t 语法检查 → 失败自动回滚 → 询问重启"
		echo ""
		echo -e " ${rw_hong}⚠ 登录流程将变为: 1) 客户端用私钥通过公钥认证  2) 输入手机 App 6 位 OTP${rw_lv}"
		echo -e " ${rw_hong}⚠ 操作失误可通过腾讯云 VNC 控制台救援${rw_lv}"
		echo ""
		read -e -p " 确认启用双证登录？(y/N): " _confirm < /dev/tty
		if [[ ! "$_confirm" =~ ^[Yy]$ ]]; then
			yellow "已取消"
			break_cancel
			continue
		fi

		# 1) 备份
		_ssh_backup_configs

		# 2) 清理冲突项
		_ssh_clear_conflicting_auth

		# 3) 写入 PAM（在 pam_unix.so 之后追加）
		if ! grep -q "pam_google_authenticator.so" /etc/pam.d/sshd 2>/dev/null; then
			if grep -q "pam_unix.so" /etc/pam.d/sshd 2>/dev/null; then
				sed -i '/^auth.*pam_unix.so/a auth       required     pam_google_authenticator.so nullok' /etc/pam.d/sshd
			else
				echo "auth       required     pam_google_authenticator.so nullok" >> /etc/pam.d/sshd
			fi
			green "PAM 已加载 google_authenticator"
		else
			yellow "PAM 中已存在 google_authenticator（保留）"
		fi

		# 4) 写入 sshd_config
		_ssh_cfg_set PasswordAuthentication no
		_ssh_cfg_set PubkeyAuthentication yes
		_ssh_cfg_set KbdInteractiveAuthentication yes
		_ssh_cfg_set ChallengeResponseAuthentication yes
		_ssh_cfg_set AuthenticationMethods "publickey,keyboard-interactive"
		green "sshd_config 已更新"

		# 5) 应用 + 重启
		_ssh_apply_and_restart
		;;
	  4)
		# ── 禁用双证登录 ──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 禁用双证登录 ━━━━━━${rw_lv}"
		echo ""
		_ssh_current_auth_mode
		if [ "$_SSH_MODE" != "2fa" ]; then
			yellow "当前认证模式为「${_SSH_MODE_DESC}」，并非双证模式"
			echo -e " ${rw_huang}仍可继续清理 OTP 相关配置${rw_lv}"
		fi
		echo ""
		echo -e " ${rw_huang}即将执行:${rw_lv}"
		echo -e "   1) 备份当前配置"
		echo -e "   2) 注释掉 AuthenticationMethods"
		echo -e "   3) 设置 KbdInteractiveAuthentication no / ChallengeResponseAuthentication no"
		echo -e "   4) 从 PAM 移除 google_authenticator 行"
		echo -e "   5) PasswordAuthentication 恢复为 yes（避免锁死）"
		echo -e "   6) sshd -t 检查 → 询问重启"
		echo ""
		echo -e " ${rw_hong}⚠ 禁用后将退回「公钥或密码」模式，OTP 不再要求${rw_lv}"
		read -e -p " 确认禁用双证登录？(y/N): " _confirm < /dev/tty
		if [[ ! "$_confirm" =~ ^[Yy]$ ]]; then
			yellow "已取消"
			break_cancel
			continue
		fi

		_ssh_backup_configs
		_ssh_clear_conflicting_auth
		_ssh_cfg_set KbdInteractiveAuthentication no
		_ssh_cfg_set ChallengeResponseAuthentication no
		_ssh_cfg_set PasswordAuthentication yes
		_ssh_cfg_set PubkeyAuthentication yes
		green "已禁用双证相关配置"

		_ssh_apply_and_restart
		;;
	  5)
		# ── 查看已配置 OTP 的用户 ──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 已配置 OTP 的用户 ━━━━━━${rw_lv}"
		echo ""
		local _found=0
		while IFS=: read -r _u _p _uid _gid _gcos _home _shell; do
			[ "$_uid" -lt 1000 ] && [ "$_u" != "root" ] && continue
			if [ -f "${_home}/.google_authenticator" ]; then
				_found=1
				local _ga_mtime
				_ga_mtime=$(stat -c '%y' "${_home}/.google_authenticator" 2>/dev/null | cut -d' ' -f1 || \
							stat -f '%Sm' -t '%Y-%m-%d' "${_home}/.google_authenticator" 2>/dev/null || echo "未知")
				printf "  ${rw_huang}%-15s${rw_lv}  HOME: %-25s  配置时间: %s\n" "$_u" "${_home}" "$_ga_mtime"
			fi
		done </etc/passwd
		[ $_found -eq 0 ] && yellow "暂无用户配置 OTP"
		echo ""
		;;
	  6)
		# ── 删除用户 OTP 配置 ──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 删除用户 OTP 配置 ━━━━━━${rw_lv}"
		echo ""
		# 列出已配置 OTP 的用户
		local _otp_users=()
		local _ui=1
		while IFS=: read -r _u _p _uid _gid _gcos _home _shell; do
			[ "$_uid" -lt 1000 ] && [ "$_u" != "root" ] && continue
			if [ -f "${_home}/.google_authenticator" ]; then
				_otp_users+=("$_u")
				local _ga_mtime
				_ga_mtime=$(stat -c '%y' "${_home}/.google_authenticator" 2>/dev/null | cut -d' ' -f1 || \
							stat -f '%Sm' -t '%Y-%m-%d' "${_home}/.google_authenticator" 2>/dev/null || echo "未知")
				echo -e " ${rw_huang}${_ui}.${rw_lv} $_u → ${_home}  (配置于: ${_ga_mtime})"
				((_ui++))
			fi
		done </etc/passwd
		if [ ${#_otp_users[@]} -eq 0 ]; then
			yellow "暂无用户配置 OTP，无需删除"
			break_end
			continue
		fi
		echo -e " ${rw_huang}0.${rw_lv} 取消"
		echo ""
		read -e -p " 请选择要删除 OTP 的用户编号: " _del_idx < /dev/tty
		[ "$_del_idx" = "0" ] && continue
		[ -z "$_del_idx" ] && { red "无效选择"; break_end; continue; }
		local _target_u=""
		_ui=1
		for _u in "${_otp_users[@]}"; do
			if [ "$_ui" -eq "$_del_idx" ]; then
				_target_u="$_u"
				break
			fi
			((_ui++))
		done
		[ -z "$_target_u" ] && { red "无效选择"; break_end; continue; }

		echo ""
		echo -e " ${rw_hong}⚠ 即将删除用户 ${rw_huang}${_target_u}${rw_hong} 的 OTP 配置${rw_lv}"
		echo -e " ${rw_hong}删除后该用户的双证/三证登录将失效，需重新配置 OTP${rw_lv}"
		echo -e " ${rw_huang}（配置文件会备份到 /tmp，可恢复）${rw_lv}"
		echo ""
		read -e -p " 确认删除？(y/N): " _confirm < /dev/tty
		if [[ "$_confirm" =~ ^[Yy]$ ]]; then
			_ssh_otp_delete_user "$_target_u"
		else
			yellow "已取消"
		fi
		;;
	  0)
		break
		;;
	  *)
		red "无效的输入!"
		;;
	esac
	break_cancel
done
}

# ================================================================
# 三证登录管理器（公钥 + 密码 + OTP 动态码）
# 登录流程: 1) 客户端用私钥通过公钥认证  2) 输入账号密码  3) 输入手机 App OTP
# 依赖: google-authenticator (PAM 模块) + 已部署的 SSH 公钥 + 用户密码
# ================================================================
ssh_three_factor_manager() {
while true; do
	clear
	_ssh_status_panel

	local _otp_pkg _otp_pam _otp_users
	if command -v google-authenticator &>/dev/null || \
	   dpkg -l libpam-google-authenticator 2>/dev/null | grep -q "^ii" || \
	   rpm -q google-authenticator 2>/dev/null | grep -q "google-authenticator"; then
		_otp_pkg="${rw_lv}已安装${rw_lv}"
	else
		_otp_pkg="${rw_hong}未安装${rw_lv}"
	fi
	if grep -q "pam_google_authenticator.so" /etc/pam.d/sshd 2>/dev/null; then
		_otp_pam="${rw_lv}已加载${rw_lv}"
	else
		_otp_pam="${rw_hong}未加载${rw_lv}"
	fi
	_otp_users=0
	while IFS=: read -r _u _p _uid _gid _gcos _home _shell; do
		[ "$_uid" -lt 1000 ] && [ "$_u" != "root" ] && continue
		[ -f "${_home}/.google_authenticator" ] && _otp_users=$((_otp_users + 1))
	done </etc/passwd 2>/dev/null

	echo -e " OTP 软件包: ${_otp_pkg}   PAM 模块: ${_otp_pam}   已配 OTP 用户: ${rw_huang}${_otp_users}${rw_lv}"
	echo ""
	echo -e " ${rw_cheng}──── 三证登录（公钥 + 密码 + OTP）────${rw_lv}"
	echo -e " ${rw_huang}1.   ${rw_lv}安装 google-authenticator${rw_lv}"
	echo -e " ${rw_huang}2.   ${rw_lv}为用户配置 OTP 动态码${rw_lv}"
	echo -e " ${rw_huang}3.   ${rw_lv}启用三证登录（公钥 + 密码 + OTP）${rw_lv}"
	echo -e " ${rw_huang}4.   ${rw_lv}禁用三证登录（恢复单一认证）${rw_lv}"
	echo -e " ${rw_huang}5.   ${rw_lv}查看已配置 OTP 的用户${rw_lv}"
	echo -e " ${rw_huang}6.   ${rw_lv}删除用户 OTP 配置（配置错了可重配）${rw_lv}"
	echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
	echo -e " ${rw_huang}0.   ${rw_lv}返回上级菜单${rw_lv}"
	echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
	read -e -p " 请输入你的选择: " thf_choice

	case $thf_choice in
	  1)
		# ── 安装 google-authenticator（与双证共用逻辑）──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 安装 google-authenticator ━━━━━━${rw_lv}"
		echo ""
		if command -v google-authenticator &>/dev/null; then
			green "google-authenticator 已经安装"
			break_end
			continue
		fi
		if command -v apt-get &>/dev/null; then
			echo -e " 检测到 Debian/Ubuntu，使用 apt 安装..."
			read -e -p " 确认安装 libpam-google-authenticator？(y/N): " _confirm < /dev/tty
			if [[ "$_confirm" =~ ^[Yy]$ ]]; then
				apt-get update -y && apt-get install -y libpam-google-authenticator
				[ $? -eq 0 ] && green "安装成功！" || red "安装失败"
			else
				yellow "已取消"
			fi
		elif command -v dnf &>/dev/null; then
			echo -e " 检测到 Fedora/RHEL9+，使用 dnf 安装..."
			read -e -p " 确认安装？(y/N): " _confirm < /dev/tty
			if [[ "$_confirm" =~ ^[Yy]$ ]]; then
				dnf install -y google-authenticator
				[ $? -eq 0 ] && green "安装成功！" || red "安装失败"
			else
				yellow "已取消"
			fi
		elif command -v yum &>/dev/null; then
			echo -e " 检测到 CentOS/RHEL，使用 yum 安装..."
			echo -e " ${rw_hong}提示: EPEL 仓库可能需要先启用${rw_lv}"
			read -e -p " 确认安装？(y/N): " _confirm < /dev/tty
			if [[ "$_confirm" =~ ^[Yy]$ ]]; then
				yum install -y google-authenticator
				[ $? -eq 0 ] && green "安装成功！" || red "安装失败"
			else
				yellow "已取消"
			fi
		elif command -v apk &>/dev/null; then
			echo -e " 检测到 Alpine，使用 apk 安装..."
			read -e -p " 确认安装？(y/N): " _confirm < /dev/tty
			if [[ "$_confirm" =~ ^[Yy]$ ]]; then
				apk add --no-cache google-authenticator
				[ $? -eq 0 ] && green "安装成功！" || red "安装失败"
			else
				yellow "已取消"
			fi
		else
			red "无法识别包管理器，请手动安装"
		fi
		;;
	  2)
		# ── 为用户配置 OTP ──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 为用户配置 OTP ━━━━━━${rw_lv}"
		echo ""
		if ! command -v google-authenticator &>/dev/null; then
			red "google-authenticator 未安装，请先执行选项 1"
			break_end
			continue
		fi
		echo -e " ${rw_cheng}── 可用用户 ──${rw_lv}"
		local _avail_users=()
		while IFS=: read -r _u _p _uid _gid _gcos _home _shell; do
			[ "$_uid" -lt 1000 ] && [ "$_u" != "root" ] && continue
			[ -n "$_shell" ] && _avail_users+=("$_u")
		done </etc/passwd
		_avail_users+=("root")
		local _ui=1
		for _u in "${_avail_users[@]}"; do
			local _h=$(getent passwd "$_u" | cut -d: -f6)
			local _otp_mark=""
			[ -f "${_h}/.google_authenticator" ] && _otp_mark="${rw_lv}[已配OTP]${rw_lv}"
			echo -e " ${rw_huang}${_ui}.${rw_lv} $_u → ${_h} ${_otp_mark}"
			((_ui++))
		done
		echo -e " ${rw_huang}0.   ${rw_lv}取消${rw_lv}"
		echo ""
		read -e -p " 请选择用户编号: " _user_idx < /dev/tty
		[ "$_user_idx" = "0" ] && continue
		[ -z "$_user_idx" ] && { red "无效选择"; break_end; continue; }
		local _target_u=""
		_ui=1
		for _u in "${_avail_users[@]}"; do
			if [ "$_ui" -eq "$_user_idx" ]; then
				_target_u="$_u"
				break
			fi
			((_ui++))
		done
		[ -z "$_target_u" ] && { red "无效选择"; break_end; continue; }

		_ssh_otp_configure_user "$_target_u"
		;;
	  3)
		# ── 启用三证登录（公钥 + 密码 + OTP）──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 启用三证登录（公钥 + 密码 + OTP）━━━━━━${rw_lv}"
		echo ""

		if ! command -v google-authenticator &>/dev/null; then
			red "google-authenticator 未安装，请先执行选项 1"
			break_end
			continue
		fi

		# 多用户审计：三证全局生效，必须确认所有可登录用户都齐备公钥+OTP
		_ssh_audit_auth_users
		echo -e " ${rw_cheng}── 可登录用户审计 ──${rw_lv}"
		echo -e "   可登录用户: ${rw_huang}${_AUDIT_USERS}${rw_lv}    有公钥: ${rw_huang}${_AUDIT_HAS_PUBKEY}${rw_lv}    有OTP: ${rw_huang}${_AUDIT_HAS_OTP}${rw_lv}"
		echo ""
		if [ $_AUDIT_USERS -eq 0 ]; then
			red "未发现可登录用户，无法启用三证"
			break_end
			continue
		fi
		# 三证 = 公钥 + 密码 + OTP，公钥和OTP必须先配齐（密码由用户自行保证非空）
		if [ $_AUDIT_OK -eq 0 ]; then
			echo -e " ${rw_hong}⚠ 以下用户缺少公钥或 OTP，启用后这些用户将无法 SSH 登录：${rw_lv}"
			echo "$_AUDIT_MISSING" | sed 's/^/   /'
			echo ""
			echo -e " ${rw_huang}三证全局生效，建议先为所有用户补齐公钥+OTP${rw_lv}"
			echo -e " ${rw_huang}公钥: 主菜单 → 12.密钥管理 → SSH 配置 → 添加 SSH 公钥${rw_lv}"
			echo -e " ${rw_huang}OTP : 本菜单选项 2「为用户配置 OTP 动态码」${rw_lv}"
			echo -e " ${rw_huang}密码: 确保各用户密码非空（passwd <用户>）${rw_lv}"
			echo ""
			read -e -p " 仍要强制启用三证？(输入 yes 继续): " _force < /dev/tty
			if [ "$_force" != "yes" ]; then
				yellow "已取消"
				break_cancel
				continue
			fi
		else
			green "✓ 所有可登录用户均已配置公钥 + OTP（请自行确认密码非空）"
		fi

		echo -e " ${rw_huang}即将执行的变更:${rw_lv}"
		echo -e "   1) 备份 sshd_config + pam.d/sshd + authorized_keys"
		echo -e "   2) 清理旧的认证模式残留 (AuthenticationMethods / Match 块 / PAM OTP)"
		echo -e "   3) 写入 PAM: ${rw_huang}auth required pam_google_authenticator.so nullok${rw_lv}"
		echo -e "   4) sshd_config:"
		echo -e "      ${rw_huang}PasswordAuthentication yes${rw_lv}        (三证需要密码)"
		echo -e "      ${rw_huang}PubkeyAuthentication yes${rw_lv}"
		echo -e "      ${rw_huang}KbdInteractiveAuthentication yes${rw_lv} (新版 OpenSSH)"
		echo -e "      ${rw_huang}ChallengeResponseAuthentication yes${rw_lv} (旧版兼容)"
		echo -e "      ${rw_huang}AuthenticationMethods publickey,password,keyboard-interactive${rw_lv}"
		echo -e "   5) sshd -t 语法检查 → 失败自动回滚 → 询问重启"
		echo ""
		echo -e " ${rw_hong}⚠ 登录流程: 1) 私钥通过公钥认证  2) 输入账号密码  3) 输入手机 App 6 位 OTP${rw_lv}"
		echo -e " ${rw_hong}⚠ 操作失误可通过腾讯云 VNC 控制台救援${rw_lv}"
		echo ""
		read -e -p " 确认启用三证登录？(y/N): " _confirm < /dev/tty
		if [[ ! "$_confirm" =~ ^[Yy]$ ]]; then
			yellow "已取消"
			break_cancel
			continue
		fi

		_ssh_backup_configs
		_ssh_clear_conflicting_auth

		# 写入 PAM
		if ! grep -q "pam_google_authenticator.so" /etc/pam.d/sshd 2>/dev/null; then
			if grep -q "pam_unix.so" /etc/pam.d/sshd 2>/dev/null; then
				sed -i '/^auth.*pam_unix.so/a auth       required     pam_google_authenticator.so nullok' /etc/pam.d/sshd
			else
				echo "auth       required     pam_google_authenticator.so nullok" >> /etc/pam.d/sshd
			fi
			green "PAM 已加载 google_authenticator"
		else
			yellow "PAM 中已存在 google_authenticator（保留）"
		fi

		# 写入 sshd_config（三证：密码 yes）
		_ssh_cfg_set PasswordAuthentication yes
		_ssh_cfg_set PubkeyAuthentication yes
		_ssh_cfg_set KbdInteractiveAuthentication yes
		_ssh_cfg_set ChallengeResponseAuthentication yes
		_ssh_cfg_set AuthenticationMethods "publickey,password,keyboard-interactive"
		green "sshd_config 已更新"

		_ssh_apply_and_restart
		;;
	  4)
		# ── 禁用三证登录 ──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 禁用三证登录 ━━━━━━${rw_lv}"
		echo ""
		_ssh_current_auth_mode
		if [ "$_SSH_MODE" != "3fa" ]; then
			yellow "当前认证模式为「${_SSH_MODE_DESC}」，并非三证模式"
			echo -e " ${rw_huang}仍可继续清理 OTP 相关配置${rw_lv}"
		fi
		echo ""
		echo -e " ${rw_huang}即将执行:${rw_lv}"
		echo -e "   1) 备份当前配置"
		echo -e "   2) 注释掉 AuthenticationMethods"
		echo -e "   3) 设置 KbdInteractiveAuthentication no / ChallengeResponseAuthentication no"
		echo -e "   4) 从 PAM 移除 google_authenticator 行"
		echo -e "   5) PasswordAuthentication 保持 yes / PubkeyAuthentication yes"
		echo -e "   6) sshd -t 检查 → 询问重启"
		echo ""
		echo -e " ${rw_hong}⚠ 禁用后退回「公钥或密码」模式${rw_lv}"
		read -e -p " 确认禁用三证登录？(y/N): " _confirm < /dev/tty
		if [[ ! "$_confirm" =~ ^[Yy]$ ]]; then
			yellow "已取消"
			break_cancel
			continue
		fi

		_ssh_backup_configs
		_ssh_clear_conflicting_auth
		_ssh_cfg_set KbdInteractiveAuthentication no
		_ssh_cfg_set ChallengeResponseAuthentication no
		_ssh_cfg_set PasswordAuthentication yes
		_ssh_cfg_set PubkeyAuthentication yes
		green "已禁用三证相关配置"

		_ssh_apply_and_restart
		;;
	  5)
		# ── 查看已配置 OTP 的用户 ──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 已配置 OTP 的用户 ━━━━━━${rw_lv}"
		echo ""
		local _found=0
		while IFS=: read -r _u _p _uid _gid _gcos _home _shell; do
			[ "$_uid" -lt 1000 ] && [ "$_u" != "root" ] && continue
			if [ -f "${_home}/.google_authenticator" ]; then
				_found=1
				local _ga_mtime
				_ga_mtime=$(stat -c '%y' "${_home}/.google_authenticator" 2>/dev/null | cut -d' ' -f1 || \
							stat -f '%Sm' -t '%Y-%m-%d' "${_home}/.google_authenticator" 2>/dev/null || echo "未知")
				printf "  ${rw_huang}%-15s${rw_lv}  HOME: %-25s  配置时间: %s\n" "$_u" "${_home}" "$_ga_mtime"
			fi
		done </etc/passwd
		[ $_found -eq 0 ] && yellow "暂无用户配置 OTP"
		echo ""
		;;
	  6)
		# ── 删除用户 OTP 配置 ──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 删除用户 OTP 配置 ━━━━━━${rw_lv}"
		echo ""
		# 列出已配置 OTP 的用户
		local _otp_users=()
		local _ui=1
		while IFS=: read -r _u _p _uid _gid _gcos _home _shell; do
			[ "$_uid" -lt 1000 ] && [ "$_u" != "root" ] && continue
			if [ -f "${_home}/.google_authenticator" ]; then
				_otp_users+=("$_u")
				local _ga_mtime
				_ga_mtime=$(stat -c '%y' "${_home}/.google_authenticator" 2>/dev/null | cut -d' ' -f1 || \
							stat -f '%Sm' -t '%Y-%m-%d' "${_home}/.google_authenticator" 2>/dev/null || echo "未知")
				echo -e " ${rw_huang}${_ui}.${rw_lv} $_u → ${_home}  (配置于: ${_ga_mtime})"
				((_ui++))
			fi
		done </etc/passwd
		if [ ${#_otp_users[@]} -eq 0 ]; then
			yellow "暂无用户配置 OTP，无需删除"
			break_end
			continue
		fi
		echo -e " ${rw_huang}0.${rw_lv} 取消"
		echo ""
		read -e -p " 请选择要删除 OTP 的用户编号: " _del_idx < /dev/tty
		[ "$_del_idx" = "0" ] && continue
		[ -z "$_del_idx" ] && { red "无效选择"; break_end; continue; }
		local _target_u=""
		_ui=1
		for _u in "${_otp_users[@]}"; do
			if [ "$_ui" -eq "$_del_idx" ]; then
				_target_u="$_u"
				break
			fi
			((_ui++))
		done
		[ -z "$_target_u" ] && { red "无效选择"; break_end; continue; }

		echo ""
		echo -e " ${rw_hong}⚠ 即将删除用户 ${rw_huang}${_target_u}${rw_hong} 的 OTP 配置${rw_lv}"
		echo -e " ${rw_hong}删除后该用户的双证/三证登录将失效，需重新配置 OTP${rw_lv}"
		echo -e " ${rw_huang}（配置文件会备份到 /tmp，可恢复）${rw_lv}"
		echo ""
		read -e -p " 确认删除？(y/N): " _confirm < /dev/tty
		if [[ "$_confirm" =~ ^[Yy]$ ]]; then
			_ssh_otp_delete_user "$_target_u"
		else
			yellow "已取消"
		fi
		;;
	  0)
		break
		;;
	  *)
		red "无效的输入!"
		;;
	esac
	break_cancel
done
}

# ================================================================
# SSH FIDO2 硬件密钥认证管理器（硬证登录）
# 原理: OpenSSH ≥ 8.2 原生支持 sk-* 密钥类型，私钥锁在 FIDO2 硬件芯片内
#       登录时 SSH 触发硬件密钥，用户触摸金属触点 + 输入 PIN 完成认证
# 依赖: OpenSSH ≥ 8.2（服务端 + 客户端）、FIDO2 硬件密钥（YubiKey/Titan 等）
# 服务端仅需 PubkeyAuthentication yes，无需安装任何 FIDO2 库
# ================================================================
ssh_fido2_manager() {
while true; do
	clear

	# ── 探测 FIDO2 就绪状态 ──
	local _fido_sshd_ver _fido_sshd_ok=0
	_fido_sshd_ver=$(sshd -V 2>&1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
	local _fido_sshd_major=0 _fido_sshd_minor=0
	if [ -n "$_fido_sshd_ver" ]; then
		_fido_sshd_major=$(echo "$_fido_sshd_ver" | cut -d. -f1)
		_fido_sshd_minor=$(echo "$_fido_sshd_ver" | cut -d. -f2)
		if [ "$_fido_sshd_major" -gt 8 ] || ([ "$_fido_sshd_major" -eq 8 ] && [ "$_fido_sshd_minor" -ge 2 ]); then
			_fido_sshd_ok=1
		fi
	fi
	_fido_sshd_ver="${_fido_sshd_ver:-未知}"

	local _fido_cli_ver _fido_cli_ok=0
	_fido_cli_ver=$(ssh -V 2>&1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
	local _fido_cli_major=0 _fido_cli_minor=0
	if [ -n "$_fido_cli_ver" ]; then
		_fido_cli_major=$(echo "$_fido_cli_ver" | cut -d. -f1)
		_fido_cli_minor=$(echo "$_fido_cli_ver" | cut -d. -f2)
		if [ "$_fido_cli_major" -gt 8 ] || ([ "$_fido_cli_major" -eq 8 ] && [ "$_fido_cli_minor" -ge 2 ]); then
			_fido_cli_ok=1
		fi
	fi
	_fido_cli_ver="${_fido_cli_ver:-未知}"

	local _fido_keys=0 _fido_authorized=0
	if [ -d "$HOME/.ssh" ]; then
		_fido_keys=$(ls "$HOME/.ssh"/id_*_sk 2>/dev/null | wc -l | tr -d ' ')
	fi
	if [ -f "$HOME/.ssh/authorized_keys" ]; then
		_fido_authorized=$(grep -c "^sk-" "$HOME/.ssh/authorized_keys" 2>/dev/null || echo 0)
	fi

	local _sshd_color="${rw_hong}"
	[ $_fido_sshd_ok -eq 1 ] && _sshd_color="${rw_lv}"
	local _cli_color="${rw_hong}"
	[ $_fido_cli_ok -eq 1 ] && _cli_color="${rw_lv}"

	_ssh_status_panel
	echo -e " 服务端 OpenSSH: ${_sshd_color}${_fido_sshd_ver}${rw_lv} (≥8.2: $([ $_fido_sshd_ok -eq 1 ] && echo "✓" || echo "✗"))"
	echo -e " 本地客户端:     ${_cli_color}${_fido_cli_ver}${rw_lv} (≥8.2: $([ $_fido_cli_ok -eq 1 ] && echo "✓" || echo "✗"))"
	echo -e " FIDO2 密钥文件: ${rw_huang}${_fido_keys}${rw_lv} 个   authorized_keys 中: ${rw_huang}${_fido_authorized}${rw_lv} 个"
	echo ""
	echo -e " ${rw_cheng}──── 服务端配置 ────${rw_lv}"
	echo -e " ${rw_huang}1.   ${rw_lv}检查 FIDO2 环境兼容性${rw_lv}"
	echo -e " ${rw_huang}2.   ${rw_lv}启用硬证登录（服务端配置）${rw_lv}"
	echo -e " ${rw_huang}3.   ${rw_lv}禁用硬证登录（清理 FIDO2 配置）${rw_lv}"
	echo ""
	echo -e " ${rw_cheng}──── 客户端密钥生成（在本地电脑执行）────${rw_lv}"
	echo -e " ${rw_huang}4.   ${rw_lv}生成驻留密钥 (ed25519-sk, 推荐)${rw_lv}"
	echo -e " ${rw_huang}5.   ${rw_lv}生成非驻留密钥 (ecdsa-sk)${rw_lv}"
	echo ""
	echo -e " ${rw_cheng}──── 部署与测试 ────${rw_lv}"
	echo -e " ${rw_huang}6.   ${rw_lv}部署公钥到服务器${rw_lv}"
	echo -e " ${rw_huang}7.   ${rw_lv}测试 FIDO2 SSH 连接${rw_lv}"
	echo -e " ${rw_huang}8.   ${rw_lv}多密钥备份（注册备用硬件密钥）${rw_lv}"
	echo -e " ${rw_huang}9.   ${rw_lv}查看已注册的 FIDO2 密钥${rw_lv}"
	echo ""
	echo -e " ${rw_cheng}──── 其他 ────${rw_lv}"
	echo -e " ${rw_huang}10.  ${rw_lv}📖 操作教程（快速上手指南）${rw_lv}"
	echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
	echo -e " ${rw_huang}0.   ${rw_lv}返回上级菜单${rw_lv}"
	echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
	read -e -p " 请输入你的选择: " fido_choice

	case $fido_choice in
	  1)
		# ── 检查 FIDO2 环境兼容性 ──
		echo ""
		echo -e "${rw_cheng}━━━━━━ FIDO2 环境兼容性检查 ━━━━━━${rw_lv}"
		echo ""

		echo -e " ${rw_cheng}── 1) 服务端 OpenSSH 版本 ──${rw_lv}"
		if [ $_fido_sshd_ok -eq 1 ]; then
			green "服务端 OpenSSH ${_fido_sshd_ver} ≥ 8.2 — 满足要求"
		else
			red "服务端 OpenSSH ${_fido_sshd_ver} < 8.2 — 不满足要求"
			echo -e " ${rw_huang}解决方案:${rw_lv}"
			echo -e "   Ubuntu 20.04+/Debian 11+: 系统默认满足"
			echo -e "   CentOS 7/Ubuntu 18.04: 需升级 OpenSSH"
			echo -e "   可使用本工具箱的 ${rw_huang}升级 OpenSSH${rw_lv} 功能"
		fi

		echo -e " ${rw_cheng}── 2) 本地客户端 OpenSSH 版本 ──${rw_lv}"
		if [ $_fido_cli_ok -eq 1 ]; then
			green "本地客户端 OpenSSH ${_fido_cli_ver} ≥ 8.2 — 满足要求"
		else
			red "本地客户端 OpenSSH ${_fido_cli_ver} < 8.2 — 不满足要求"
			echo -e " ${rw_huang}解决方案:${rw_lv}"
			echo -e "   macOS: 系统自带 (Big Sur+)"
			echo -e "   Windows: Win10 2004+ / Win11 自带 OpenSSH"
			echo -e "   Linux: apt install openssh-client / yum install openssh-clients"
		fi

		echo -e " ${rw_cheng}── 3) FIDO2 密钥类型支持 ──${rw_lv}"
		if ssh-keygen --help 2>&1 | grep -q "ed25519-sk" || \
		   ssh-keygen -t ed25519-sk -f /tmp/_fido_test_$$ -N "" 2>&1 | grep -qiv "not supported\|unknown\|invalid" 2>/dev/null; then
			green "ed25519-sk 密钥类型已支持"
		else
			echo -e " ${rw_hong}ed25519-sk 可能不支持 — 请确认 libfido2 库已安装${rw_lv}"
			echo -e " ${rw_huang}安装:${rw_lv} apt-get install libfido2-1 (Debian) / yum install libfido2 (RHEL)"
		fi
		rm -f /tmp/_fido_test_$$* 2>/dev/null

		echo -e " ${rw_cheng}── 4) FIDO2 USB 设备检测 ──${rw_lv}"
		if command -v lsusb &>/dev/null; then
			local _fido_devs
			_fido_devs=$(lsusb 2>/dev/null | grep -iE "yubi|fido|security key|u2f" || true)
			if [ -n "$_fido_devs" ]; then
				green "检测到 FIDO2 设备:"
				echo "$_fido_devs" | while read -r _line; do
					echo -e "   ${rw_lv}$_line${rw_lv}"
				done
			else
				yellow "未检测到 FIDO2 设备，请确认硬件密钥已插入"
				echo -e " ${rw_lv}常见设备: YubiKey 5/5C/Nano, Google Titan, Feitian${rw_lv}"
			fi
		elif command -v system_profiler &>/dev/null; then
			local _usb_info
			_usb_info=$(system_profiler SPUSBDataType 2>/dev/null | grep -iE "yubi|fido|security key" -A 2 || true)
			if [ -n "$_usb_info" ]; then
				green "检测到 FIDO2 设备:"
				echo "$_usb_info"
			else
				yellow "未检测到 FIDO2 设备，请确认硬件密钥已插入"
			fi
		else
			echo -e " ${rw_huang}无法检测 USB 设备，请手动确认硬件密钥已插入${rw_lv}"
		fi

		echo -e " ${rw_cheng}── 5) libfido2 库状态 ──${rw_lv}"
		if ldconfig -p 2>/dev/null | grep -q libfido2; then
			green "libfido2 已安装"
		elif dpkg -l libfido2-1 2>/dev/null | grep -q "^ii"; then
			green "libfido2-1 已安装"
		elif rpm -q libfido2 2>/dev/null | grep -q "libfido2"; then
			green "libfido2 已安装"
		else
			yellow "libfido2 可能未安装，某些 FIDO2 功能可能受限"
			echo -e " ${rw_huang}安装:${rw_lv} apt-get install libfido2-1 (Debian) / yum install libfido2 (RHEL)"
		fi
		echo ""
		;;
	  2)
		# ── 启用硬证登录（服务端配置）──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 启用硬证登录（服务端配置）━━━━━━${rw_lv}"
		echo ""
		if [ $_fido_sshd_ok -ne 1 ]; then
			red "服务端 OpenSSH ${_fido_sshd_ver} < 8.2，不支持 FIDO2"
			echo -e " ${rw_huang}请先升级 OpenSSH${rw_lv}"
			break_end
			continue
		fi

		_ssh_current_auth_mode
		echo -e " 当前认证模式: ${rw_huang}${_SSH_MODE_DESC}${rw_lv}"
		echo ""
		echo -e " ${rw_huang}即将执行的变更:${rw_lv}"
		echo -e "   1) 备份 sshd_config + pam.d/sshd + authorized_keys"
		echo -e "   2) 清理旧认证模式残留 (AuthenticationMethods / Match 块 / PAM OTP)"
		echo -e "   3) sshd_config:"
		echo -e "      ${rw_huang}PubkeyAuthentication yes${rw_lv}"
		echo -e "      ${rw_huang}PasswordAuthentication no${rw_lv}   (硬证不使用密码)"
		echo -e "      ${rw_huang}KbdInteractiveAuthentication no${rw_lv}"
		echo -e "      ${rw_huang}ChallengeResponseAuthentication no${rw_lv}"
		echo -e "      注释掉 AuthenticationMethods（FIDO2 走标准公钥路径）"
		echo -e "   4) sshd -t 语法检查 → 失败自动回滚 → 询问重启"
		echo ""
		echo -e " ${rw_hong}⚠ FIDO2 服务端无需额外库，OpenSSH 8.2+ 原生支持${rw_lv}"
		echo -e " ${rw_hong}⚠ 启用后需客户端有 sk-* 公钥部署到 authorized_keys 才能登录${rw_lv}"
		echo -e " ${rw_hong}⚠ 操作失误可通过腾讯云 VNC 控制台救援${rw_lv}"
		echo ""
		read -e -p " 确认启用硬证登录？(y/N): " _confirm < /dev/tty
		if [[ ! "$_confirm" =~ ^[Yy]$ ]]; then
			yellow "已取消"
			break_cancel
			continue
		fi

		_ssh_backup_configs
		_ssh_clear_conflicting_auth
		_ssh_cfg_set PubkeyAuthentication yes
		_ssh_cfg_set PasswordAuthentication no
		_ssh_cfg_set KbdInteractiveAuthentication no
		_ssh_cfg_set ChallengeResponseAuthentication no
		green "sshd_config 已更新（FIDO2 走标准公钥路径）"

		_ssh_apply_and_restart
		;;
	  3)
		# ── 禁用硬证登录（清理 FIDO2 配置）──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 禁用硬证登录 ━━━━━━${rw_lv}"
		echo ""
		_ssh_current_auth_mode
		echo -e " 当前认证模式: ${rw_huang}${_SSH_MODE_DESC}${rw_lv}"
		echo ""
		echo -e " ${rw_huang}即将执行:${rw_lv}"
		echo -e "   1) 备份 sshd_config"
		echo -e "   2) PasswordAuthentication 恢复 yes（避免锁死）"
		echo -e "   3) PubkeyAuthentication 保持 yes"
		echo -e "   4) sshd -t 检查 → 询问重启"
		echo ""
		echo -e " ${rw_hong}注意: 此操作仅修改服务端 sshd_config，不删除已部署的 sk-* 公钥和本地密钥文件${rw_lv}"
		echo -e " ${rw_huang}如需彻底清理 FIDO2 密钥文件，请使用选项 10 的卸载功能${rw_lv}"
		echo ""
		read -e -p " 确认禁用硬证登录？(y/N): " _confirm < /dev/tty
		if [[ ! "$_confirm" =~ ^[Yy]$ ]]; then
			yellow "已取消"
			break_cancel
			continue
		fi

		_ssh_backup_configs
		_ssh_cfg_set PasswordAuthentication yes
		_ssh_cfg_set PubkeyAuthentication yes
		_ssh_cfg_set KbdInteractiveAuthentication no
		_ssh_cfg_set ChallengeResponseAuthentication no
		green "已禁用硬证配置（恢复密码登录）"

		_ssh_apply_and_restart
		;;
	  4)
		# ── 生成驻留密钥 (ed25519-sk) ──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 生成驻留密钥 (ed25519-sk) ━━━━━━${rw_lv}"
		echo ""
		if [ $_fido_cli_ok -ne 1 ]; then
			red "本地客户端 OpenSSH 版本过低 (< 8.2)，不支持 ed25519-sk"
			break_end
			continue
		fi
		echo -e " ${rw_hong}⚠ 此操作在本地电脑执行，不是服务器！${rw_lv}"
		echo ""
		echo -e " ${rw_lv}密钥类型: ${rw_huang}ed25519-sk -O resident${rw_lv}"
		echo -e " ${rw_lv}说明: 私钥将${rw_hong}永久存储在硬件密钥内${rw_lv}，本地仅保存"句柄"文件"
		echo -e " ${rw_lv}优点: 硬件丢失也不泄露私钥，可多设备漫游${rw_lv}"
		echo ""
		echo -e " ${rw_huang}操作步骤:${rw_lv}"
		echo -e " 1. 确保 FIDO2 硬件密钥已插入 USB 端口"
		echo -e " 2. 按回车后，终端将提示触摸硬件密钥"
		echo -e " 3. 触摸硬件密钥上的金属触点"
		echo -e " 4. 输入 PIN 码 (首次使用需设置)"
		echo ""
		read -e -p " 请输入密钥名称（默认: id_ed25519_sk_cvm）: " _key_name < /dev/tty
		_key_name="${_key_name:-id_ed25519_sk_cvm}"
		local _key_path="$HOME/.ssh/${_key_name}"

		if [ -f "$_key_path" ]; then
			yellow "密钥文件 ${_key_name} 已存在"
			read -e -p " 是否覆盖？(y/N): " _overwrite < /dev/tty
			[[ ! "$_overwrite" =~ ^[Yy]$ ]] && { yellow "已取消"; break_cancel; continue; }
		fi

		echo ""
		echo -e " ${rw_huang}正在生成驻留密钥...${rw_lv}"
		echo -e " ${rw_lv}请准备好触摸你的 FIDO2 硬件密钥...${rw_lv}"
		echo ""

		ssh-keygen -t ed25519-sk -O resident -O application="ssh:cvm-$(hostname)" -f "$_key_path"
		local _gen_rc=$?

		if [ $_gen_rc -eq 0 ] && [ -f "$_key_path" ]; then
			green "驻留密钥生成成功！"
			echo ""
			echo -e " ${rw_huang}私钥句柄:${rw_lv} ${_key_path}"
			echo -e " ${rw_huang}公钥文件:${rw_lv} ${_key_path}.pub"
			echo ""
			echo -e " ${rw_hong}⚠ 重要提示:${rw_lv}"
			echo -e "   - 私钥已永久存储在 FIDO2 硬件内，${_key_path} 仅是一个"句柄""
			echo -e "   - 如果硬件密钥丢失，需要重新生成密钥"
			echo -e "   - ${rw_hong}强烈建议注册至少 2 把硬件密钥 (主用+备用)${rw_lv}"
			echo ""
			echo -e " 公钥内容:"
			cat "${_key_path}.pub"
			echo ""
			echo -e " ${rw_huang}下一步: 使用选项 6 将公钥部署到服务器${rw_lv}"
		else
			red "密钥生成失败"
			echo -e " ${rw_huang}常见原因:${rw_lv}"
			echo -e "  - 硬件密钥未插入或未被系统识别"
			echo -e "  - 客户端 OpenSSH 版本不支持 (需要 ≥ 8.2)"
			echo -e "  - 缺少 libfido2 库"
		fi
		;;
	  5)
		# ── 生成非驻留密钥 (ecdsa-sk) ──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 生成非驻留密钥 (ecdsa-sk) ━━━━━━${rw_lv}"
		echo ""
		if [ $_fido_cli_ok -ne 1 ]; then
			red "本地客户端 OpenSSH 版本过低 (< 8.2)，不支持 ecdsa-sk"
			break_end
			continue
		fi
		echo -e " ${rw_hong}⚠ 此操作在本地电脑执行，不是服务器！${rw_lv}"
		echo ""
		echo -e " ${rw_lv}密钥类型: ${rw_huang}ecdsa-sk${rw_lv}"
		echo -e " ${rw_lv}说明: 私钥存储在本地文件，硬件密钥仅用于签名验证${rw_lv}"
		echo -e " ${rw_lv}适用场景: 需要在多台机器间共享密钥但不想购买多把硬件密钥${rw_lv}"
		echo ""
		echo -e " ${rw_hong}⚠ 注意: 非驻留密钥的私钥文件在本地，安全性低于驻留模式${rw_lv}"
		echo ""

		read -e -p " 请输入密钥名称（默认: id_ecdsa_sk_cvm）: " _key_name < /dev/tty
		_key_name="${_key_name:-id_ecdsa_sk_cvm}"
		local _key_path="$HOME/.ssh/${_key_name}"

		if [ -f "$_key_path" ]; then
			yellow "密钥文件 ${_key_name} 已存在"
			read -e -p " 是否覆盖？(y/N): " _overwrite < /dev/tty
			[[ ! "$_overwrite" =~ ^[Yy]$ ]] && { yellow "已取消"; break_cancel; continue; }
		fi

		echo ""
		echo -e " ${rw_huang}正在生成非驻留密钥...${rw_lv}"
		echo -e " ${rw_lv}请准备好触摸你的 FIDO2 硬件密钥...${rw_lv}"
		echo ""

		ssh-keygen -t ecdsa-sk -f "$_key_path"
		local _gen_rc=$?

		if [ $_gen_rc -eq 0 ] && [ -f "$_key_path" ]; then
			green "非驻留密钥生成成功！"
			echo ""
			echo -e " ${rw_huang}私钥文件:${rw_lv} ${_key_path}"
			echo -e " ${rw_huang}公钥文件:${rw_lv} ${_key_path}.pub"
			echo ""
			echo -e " ${rw_hong}⚠ 请妥善保管私钥文件，不要泄露！${rw_lv}"
			echo ""
			echo -e " 公钥内容:"
			cat "${_key_path}.pub"
			echo ""
		else
			red "密钥生成失败"
		fi
		;;
	  6)
		# ── 部署公钥到服务器 ──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 部署公钥到服务器 ━━━━━━${rw_lv}"
		echo ""

		local _sk_keys=()
		if [ -d "$HOME/.ssh" ]; then
			while IFS= read -r -d '' _f; do
				_sk_keys+=("$_f")
			done < <(find "$HOME/.ssh" -maxdepth 1 -name "*.pub" -exec grep -l "sk-" {} \; 2>/dev/null | tr '\n' '\0')
		fi

		if [ ${#_sk_keys[@]} -eq 0 ]; then
			yellow "未找到任何 FIDO2 公钥 (.pub 文件中含 sk- 前缀)"
			echo -e " ${rw_huang}请先使用选项 4 或 5 生成 FIDO2 密钥${rw_lv}"
			break_end
			continue
		fi

		echo -e " ${rw_cheng}── 可部署的 FIDO2 公钥 ──${rw_lv}"
		local _i=1
		for _k in "${_sk_keys[@]}"; do
			local _ktype
			_ktype=$(awk '{print $1}' "$_k" 2>/dev/null || echo "未知")
			echo -e " ${rw_huang}${_i}.${rw_lv} $(basename "$_k")  (类型: $_ktype)"
			((_i++))
		done
		echo -e " ${rw_huang}0.   ${rw_lv}取消${rw_lv}"
		echo ""

		read -e -p " 请选择要部署的公钥编号: " _pk_idx < /dev/tty
		[ "$_pk_idx" = "0" ] && continue
		if ! [[ "$_pk_idx" =~ ^[0-9]+$ ]] || [ "$_pk_idx" -lt 1 ] || [ "$_pk_idx" -gt ${#_sk_keys[@]} ]; then
			red "无效选择"
			break_end
			continue
		fi
		local _selected_pk="${_sk_keys[$((_pk_idx - 1))]}"
		local _pk_content
		_pk_content=$(cat "$_selected_pk")

		echo ""
		echo -e " 即将部署的公钥:"
		echo -e "  文件: ${rw_huang}$(basename "$_selected_pk")${rw_lv}"
		echo -e "  内容: ${rw_lv}${_pk_content}${rw_lv}"
		echo ""

		echo -e " 部署方式:"
		echo -e " ${rw_huang}1.   ${rw_lv}自动追加到当前用户的 authorized_keys${rw_lv}"
		echo -e " ${rw_huang}2.   ${rw_lv}手动指定目标用户和服务器 (ssh-copy-id)${rw_lv}"
		echo -e " ${rw_huang}0.   ${rw_lv}取消${rw_lv}"
		echo ""
		read -e -p " 请选择: " _deploy_way < /dev/tty
		[ "$_deploy_way" = "0" ] && continue

		case $_deploy_way in
		  1)
			mkdir -p "$HOME/.ssh"
			chmod 700 "$HOME/.ssh"
			if grep -qF "$_pk_content" "$HOME/.ssh/authorized_keys" 2>/dev/null; then
				yellow "该公钥已存在于 authorized_keys 中"
			else
				echo "$_pk_content" >> "$HOME/.ssh/authorized_keys"
				chmod 600 "$HOME/.ssh/authorized_keys"
				green "公钥已部署到 ~/.ssh/authorized_keys"
			fi
			;;
		  2)
			echo ""
			read -e -p " 请输入目标用户名: " _target_user < /dev/tty
			[ -z "$_target_user" ] && { red "用户名不能为空"; break_end; continue; }
			read -e -p " 请输入目标服务器 IP/主机名: " _target_host < /dev/tty
			[ -z "$_target_host" ] && { red "服务器地址不能为空"; break_end; continue; }
			read -e -p " 请输入 SSH 端口（默认 22）: " _target_port < /dev/tty
			_target_port="${_target_port:-22}"

			echo ""
			echo -e " ${rw_huang}正在使用 ssh-copy-id 部署公钥...${rw_lv}"
			echo -e " ${rw_hong}注意: 需要目标服务器的密码登录权限${rw_lv}"
			read -e -p " 确认执行？(y/N): " _confirm < /dev/tty
			if [[ "$_confirm" =~ ^[Yy]$ ]]; then
				ssh-copy-id -i "$_selected_pk" -p "$_target_port" "${_target_user}@${_target_host}" 2>&1
				[ $? -eq 0 ] && green "公钥已部署到 ${_target_user}@${_target_host}" || red "部署失败，请检查连接"
			else
				yellow "已取消"
			fi
			;;
		  *)
			yellow "无效选择"
			;;
		esac

		echo ""
		echo -e " ${rw_huang}部署完成后，测试命令:${rw_lv}"
		echo -e "   ${rw_lv}ssh -i $(basename "$_selected_pk" .pub) user@server_ip${rw_lv}"
		echo -e " ${rw_lv}连接时会提示 \"Touch your authenticator\"，触摸硬件密钥即可登录${rw_lv}"
		;;
	  7)
		# ── 测试 FIDO2 SSH 连接 ──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 测试 FIDO2 SSH 连接 ━━━━━━${rw_lv}"
		echo ""

		local _sk_privs=()
		if [ -d "$HOME/.ssh" ]; then
			for _f in "$HOME/.ssh"/id_*_sk "$HOME/.ssh"/*_sk; do
				[ -f "$_f" ] && [[ "$_f" != *.pub ]] && _sk_privs+=("$_f")
			done
		fi

		if [ ${#_sk_privs[@]} -eq 0 ]; then
			yellow "未找到任何 FIDO2 私钥文件"
			echo -e " ${rw_huang}请先使用选项 4 或 5 生成密钥${rw_lv}"
			break_end
			continue
		fi

		echo -e " ${rw_cheng}── 可用的 FIDO2 密钥 ──${rw_lv}"
		local _i=1
		for _k in "${_sk_privs[@]}"; do
			echo -e " ${rw_huang}${_i}.${rw_lv} $(basename "$_k")"
			((_i++))
		done
		echo -e " ${rw_huang}0.   ${rw_lv}取消${rw_lv}"
		echo ""
		read -e -p " 请选择密钥编号: " _k_idx < /dev/tty
		[ "$_k_idx" = "0" ] && continue
		if ! [[ "$_k_idx" =~ ^[0-9]+$ ]] || [ "$_k_idx" -lt 1 ] || [ "$_k_idx" -gt ${#_sk_privs[@]} ]; then
			red "无效选择"
			break_end
			continue
		fi
		local _selected_key="${_sk_privs[$((_k_idx - 1))]}"

		echo ""
		read -e -p " 请输入目标服务器 (user@host): " _test_target < /dev/tty
		[ -z "$_test_target" ] && { red "目标不能为空"; break_end; continue; }
		read -e -p " 请输入 SSH 端口（默认 22）: " _test_port < /dev/tty
		_test_port="${_test_port:-22}"

		echo ""
		echo -e " ${rw_huang}正在测试 FIDO2 SSH 连接...${rw_lv}"
		echo -e " ${rw_lv}请准备好触摸你的 FIDO2 硬件密钥...${rw_lv}"
		echo -e " ${rw_lv}终端会提示: \"Touch your authenticator\"${rw_lv}"
		echo ""

		ssh -i "$_selected_key" -p "$_test_port" -o PreferredAuthentications=publickey -o IdentitiesOnly=yes "$_test_target" "echo 'FIDO2 SSH 认证成功！'; hostname; whoami"
		local _test_rc=$?

		echo ""
		if [ $_test_rc -eq 0 ]; then
			green "FIDO2 SSH 连接测试成功！"
		else
			red "连接测试失败 (退出码: $_test_rc)"
			echo -e " ${rw_huang}常见原因:${rw_lv}"
			echo -e "  - 公钥未部署到目标服务器 (请使用选项 6 部署)"
			echo -e "  - 服务端 PubkeyAuthentication 未启用"
			echo -e "  - 防火墙/安全组未放行 SSH 端口"
			echo -e "  - 硬件密钥未被客户端识别"
		fi
		;;
	  8)
		# ── 多密钥备份 ──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 多密钥备份 (注册备用硬件密钥) ━━━━━━${rw_lv}"
		echo ""
		echo -e " ${rw_hong}⚠ 强烈建议注册至少两把 FIDO2 硬件密钥${rw_lv}"
		echo -e " ${rw_lv}  - 主用: 日常使用"
		echo -e "  - 备用: 主密钥丢失/损坏时的替代方案"
		echo ""
		echo -e " ${rw_huang}操作步骤:${rw_lv}"
		echo -e " 1. 插入备用 FIDO2 硬件密钥"
		echo -e " 2. 使用选项 4 生成新的驻留密钥 (不同文件名)"
		echo -e "   例如: ${rw_lv}id_ed25519_sk_cvm_backup${rw_lv}"
		echo -e " 3. 使用选项 6 将备用公钥也部署到服务器"
		echo ""
		echo -e " ${rw_lv}这样，任意一把硬件密钥都可独立登录服务器${rw_lv}"
		echo ""
		echo -e " ${rw_cheng}── 当前已部署的 FIDO2 公钥 ──${rw_lv}"
		if [ -f "$HOME/.ssh/authorized_keys" ]; then
			grep "^sk-" "$HOME/.ssh/authorized_keys" 2>/dev/null | while IFS= read -r _line; do
				local _type _comment
				_type=$(echo "$_line" | awk '{print $1}')
				_comment=$(echo "$_line" | awk '{print $NF}')
				echo -e "  ${rw_huang}•${rw_lv} $_type  ${rw_lv}($_comment)${rw_lv}"
			done
		else
			yellow "  authorized_keys 不存在"
		fi
		echo ""

		read -e -p " 是否立即生成备用 FIDO2 密钥？(y/N): " _gen_backup < /dev/tty
		if [[ "$_gen_backup" =~ ^[Yy]$ ]]; then
			if [ $_fido_cli_ok -ne 1 ]; then
				red "客户端 OpenSSH 版本不满足要求"
				break_end
				continue
			fi
			read -e -p " 请输入备用密钥名称（默认: id_ed25519_sk_cvm_backup）: " _bk_name < /dev/tty
			_bk_name="${_bk_name:-id_ed25519_sk_cvm_backup}"
			local _bk_path="$HOME/.ssh/${_bk_name}"

			if [ -f "$_bk_path" ]; then
				yellow "密钥文件已存在"
				read -e -p " 是否覆盖？(y/N): " _overwrite < /dev/tty
				[[ ! "$_overwrite" =~ ^[Yy]$ ]] && { yellow "已取消"; break_cancel; continue; }
			fi

			echo ""
			echo -e " ${rw_huang}正在生成备用驻留密钥...${rw_lv}"
			echo -e " ${rw_lv}请触摸备用 FIDO2 硬件密钥...${rw_lv}"
			echo ""
			ssh-keygen -t ed25519-sk -O resident -O application="ssh:cvm-backup-$(hostname)" -f "$_bk_path"

			if [ $? -eq 0 ]; then
				green "备用密钥生成成功！"
				echo -e " ${rw_huang}备用公钥:${rw_lv} ${_bk_path}.pub"
				echo ""
				echo -e " ${rw_huang}下一步: 使用选项 6 将备用公钥也部署到服务器${rw_lv}"
			else
				red "备用密钥生成失败"
			fi
		else
			yellow "已取消"
		fi
		;;
	  9)
		# ── 查看已注册的 FIDO2 密钥 ──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 已注册的 FIDO2 密钥 ━━━━━━${rw_lv}"
		echo ""

		echo -e " ${rw_cheng}── 本地 FIDO2 密钥文件 ──${rw_lv}"
		if [ -d "$HOME/.ssh" ]; then
			local _found_sk=0
			for _f in "$HOME/.ssh"/id_*_sk "$HOME/.ssh"/*_sk; do
				if [ -f "$_f" ] && [[ "$_f" != *.pub ]]; then
					_found_sk=1
					local _f_pub="${_f}.pub"
					local _f_type="未知"
					local _f_date=""
					if [ -f "$_f_pub" ]; then
						_f_type=$(awk '{print $1}' "$_f_pub")
					fi
					_f_date=$(stat -c '%y' "$_f" 2>/dev/null | cut -d' ' -f1 || \
							  stat -f '%Sm' -t '%Y-%m-%d' "$_f" 2>/dev/null || echo "未知")
					printf "  ${rw_huang}%-35s${rw_lv}  类型: %-15s  创建: %s\n" "$(basename "$_f")" "$_f_type" "$_f_date"
				fi
			done
			[ $_found_sk -eq 0 ] && yellow "  未找到本地 FIDO2 密钥文件"
		else
			yellow "  ~/.ssh 目录不存在"
		fi

		echo ""
		echo -e " ${rw_cheng}── authorized_keys 中的 FIDO2 公钥 ──${rw_lv}"
		if [ -f "$HOME/.ssh/authorized_keys" ]; then
			local _sk_count=0
			while IFS= read -r _line; do
				if echo "$_line" | grep -q "^sk-"; then
					_sk_count=$((_sk_count + 1))
					local _sk_type _sk_comment
					_sk_type=$(echo "$_line" | awk '{print $1}')
					_sk_comment=$(echo "$_line" | awk '{print $NF}')
					echo -e "  ${rw_huang}${_sk_count}.${rw_lv} 类型: $_sk_type  注释: ${_sk_comment:-无}"
				fi
			done < "$HOME/.ssh/authorized_keys"
			[ $_sk_count -eq 0 ] && yellow "  未找到 FIDO2 公钥条目"
			echo -e "  ${rw_huang}共 ${_sk_count} 个 FIDO2 公钥${rw_lv}"
		else
			yellow "  ~/.ssh/authorized_keys 不存在"
		fi
		echo ""
		;;
	  10)
		# ── 卸载与删除 FIDO2 配置 ──
		echo ""
		echo -e "${rw_cheng}━━━━━━ 卸载与删除 FIDO2 配置 ━━━━━━${rw_lv}"
		echo ""
		echo -e " ${rw_hong}⚠ 此功能将帮助你清理 FIDO2 相关配置${rw_lv}"
		echo -e " ${rw_lv}请根据需求选择要清理的内容:${rw_lv}"
		echo ""
		echo -e " ${rw_huang}1.   ${rw_lv}删除本地 FIDO2 密钥文件 (id_*_sk + .pub)${rw_lv}"
		echo -e " ${rw_huang}2.   ${rw_lv}从 authorized_keys 中移除 FIDO2 公钥${rw_lv}"
		echo -e " ${rw_huang}3.   ${rw_lv}一键全部清理 (密钥文件 + authorized_keys)${rw_lv}"
		echo -e " ${rw_huang}4.   ${rw_lv}自检残留 (检查是否还有 FIDO2 配置残留)${rw_lv}"
		echo -e " ${rw_huang}0.   ${rw_lv}取消${rw_lv}"
		echo ""
		read -e -p " 请选择: " _clean_choice < /dev/tty

		case $_clean_choice in
		  1)
			echo ""
			echo -e " ${rw_cheng}── 本地 FIDO2 密钥文件 ──${rw_lv}"
			local _sk_files=()
			if [ -d "$HOME/.ssh" ]; then
				while IFS= read -r -d '' _f; do
					_sk_files+=("$_f")
				done < <(find "$HOME/.ssh" -maxdepth 1 \( -name "*_sk" -o -name "*_sk.pub" \) -print0 2>/dev/null)
			fi
			if [ ${#_sk_files[@]} -eq 0 ]; then
				yellow "  未找到任何 FIDO2 密钥文件"
			else
				echo -e " 将删除以下文件:"
				for _f in "${_sk_files[@]}"; do
					echo -e "   ${rw_hong}•${rw_lv} $(basename "$_f")"
				done
				echo ""
				read -e -p " 确认删除以上 ${#_sk_files[@]} 个文件？(y/N): " _confirm < /dev/tty
				if [[ "$_confirm" =~ ^[Yy]$ ]]; then
					for _f in "${_sk_files[@]}"; do
						rm -f "$_f"
						echo -e "   ${rw_lv}已删除: $(basename "$_f")${rw_lv}"
					done
					green "所有本地 FIDO2 密钥文件已删除"
				else
					yellow "已取消"
				fi
			fi
			;;
		  2)
			echo ""
			echo -e " ${rw_cheng}── authorized_keys 中的 FIDO2 公钥 ──${rw_lv}"
			if [ ! -f "$HOME/.ssh/authorized_keys" ]; then
				yellow "  ~/.ssh/authorized_keys 不存在"
				break_end
				continue
			fi
			local _sk_lines
			_sk_lines=$(grep -n "^sk-" "$HOME/.ssh/authorized_keys" 2>/dev/null || true)
			if [ -z "$_sk_lines" ]; then
				yellow "  未找到 FIDO2 公钥条目"
			else
				echo -e " 将删除以下 FIDO2 公钥:"
				echo "$_sk_lines" | while IFS= read -r _line; do
					local _ln=$(echo "$_line" | cut -d: -f1)
					local _comment=$(echo "$_line" | awk '{print $NF}')
					echo -e "   ${rw_hong}•${rw_lv} 第 $_ln 行  注释: ${_comment:-无}"
				done
				echo ""
				read -e -p " 确认从 authorized_keys 中移除以上条目？(y/N): " _confirm < /dev/tty
				if [[ "$_confirm" =~ ^[Yy]$ ]]; then
					sed -i '/^sk-/d' "$HOME/.ssh/authorized_keys"
					green "FIDO2 公钥已从 authorized_keys 中移除"
				else
					yellow "已取消"
				fi
			fi
			;;
		  3)
			echo ""
			echo -e " ${rw_hong}⚠ 一键全部清理${rw_lv}"
			echo -e " 将执行:"
			echo -e "   1) 删除 ~/.ssh/ 下所有 id_*_sk 及 id_*_sk.pub 文件"
			echo -e "   2) 从 authorized_keys 中移除所有 sk-* 公钥"
			echo ""
			read -e -p " 确认一键清理？(y/N): " _confirm < /dev/tty
			if [[ "$_confirm" =~ ^[Yy]$ ]]; then
				find "$HOME/.ssh" -maxdepth 1 \( -name "*_sk" -o -name "*_sk.pub" \) -print0 2>/dev/null | while IFS= read -r -d '' _f; do
					rm -f "$_f" && echo -e "   ${rw_lv}已删除: $(basename "$_f")${rw_lv}"
				done
				if [ -f "$HOME/.ssh/authorized_keys" ]; then
					local _sk_before _sk_after
					_sk_before=$(grep -c "^sk-" "$HOME/.ssh/authorized_keys" 2>/dev/null || echo 0)
					sed -i '/^sk-/d' "$HOME/.ssh/authorized_keys"
					_sk_after=$(grep -c "^sk-" "$HOME/.ssh/authorized_keys" 2>/dev/null || echo 0)
					echo -e "   ${rw_lv}已从 authorized_keys 移除 $_sk_before 个 FIDO2 公钥${rw_lv}"
				fi
				green "一键清理完成！"
			else
				yellow "已取消"
			fi
			;;
		  4)
			echo ""
			echo -e " ${rw_cheng}── 自检残留 ──${rw_lv}"
			echo ""
			local _found_any=0

			echo -e " ${rw_huang}1) 本地 FIDO2 密钥文件:${rw_lv}"
			local _sk_remains
			_sk_remains=$(find "$HOME/.ssh" -maxdepth 1 \( -name "*_sk" -o -name "*_sk.pub" \) 2>/dev/null || true)
			if [ -n "$_sk_remains" ]; then
				_found_any=1
				echo "$_sk_remains" | while IFS= read -r _f; do
					echo -e "   ${rw_hong}⚠ 残留${rw_lv}  $(basename "$_f")"
				done
			else
				echo -e "   ${rw_lv}✓ 无残留${rw_lv}"
			fi

			echo -e " ${rw_huang}2) authorized_keys 中的 sk-* 公钥:${rw_lv}"
			if [ -f "$HOME/.ssh/authorized_keys" ]; then
				local _sk_count
				_sk_count=$(grep -c "^sk-" "$HOME/.ssh/authorized_keys" 2>/dev/null || echo 0)
				if [ "$_sk_count" -gt 0 ]; then
					_found_any=1
					echo -e "   ${rw_hong}⚠ 残留${rw_lv}  $_sk_count 个 FIDO2 公钥"
				else
					echo -e "   ${rw_lv}✓ 无残留${rw_lv}"
				fi
			else
				echo -e "   ${rw_lv}✓ authorized_keys 不存在${rw_lv}"
			fi

			echo -e " ${rw_huang}3) SSH 客户端配置引用:${rw_lv}"
			if [ -f "$HOME/.ssh/config" ]; then
				if grep -q "_sk" "$HOME/.ssh/config" 2>/dev/null; then
					_found_any=1
					echo -e "   ${rw_hong}⚠ 残留${rw_lv}  ~/.ssh/config 中仍有 _sk 密钥引用"
					grep -n "_sk" "$HOME/.ssh/config" | while IFS= read -r _line; do
						echo -e "     $_line"
					done
				else
					echo -e "   ${rw_lv}✓ 无残留${rw_lv}"
				fi
			else
				echo -e "   ${rw_lv}✓ ~/.ssh/config 不存在${rw_lv}"
			fi

			echo ""
			if [ $_found_any -eq 0 ]; then
				green "✅ 未发现任何 FIDO2 配置残留，清理干净！"
			else
				yellow "⚠ 发现残留项，可使用选项 1-3 继续清理"
			fi
			;;
		  *)
			[ "$_clean_choice" != "0" ] && red "无效选择"
			;;
		esac
		;;
	  11)
		# ── 操作教程 ──
		echo ""
		echo -e "${rw_cheng}━━━━━━━━━━━━  FIDO2 SSH 快速上手指南  ━━━━━━━━━━━━${rw_lv}"
		echo ""
		echo -e "  ${rw_huang}硬件要求: ${rw_lv}OpenSSH ≥ 8.2 + FIDO2 硬件密钥 (YubiKey / Titan 等)"
		echo ""
		echo -e "  ${rw_cheng}━━━━━━ 操作步骤 (按顺序执行对应菜单选项) ━━━━━━${rw_lv}"
		echo ""
		echo -e "  ┌──────────────────────────────────────────────────────────┐"
		echo -e "  │                                                         │"
		echo -e "  │  ${rw_huang}第1步  ▸ 菜单选项 [1] 检查 FIDO2 环境兼容性${rw_lv}                 │"
		echo -e "  │    确认服务端/客户端 OpenSSH ≥ 8.2，硬件密钥已识别       │"
		echo -e "  │                                                         │"
		echo -e "  │  ${rw_huang}第2步  ▸ 菜单选项 [4] 生成驻留密钥 (在本地电脑执行)${rw_lv}          │"
		echo -e "  │    ${rw_hong}★ 推荐!${rw_lv} 私钥永久存入硬件芯片，本地仅存"句柄"            │"
		echo -e "  │    按提示触摸硬件密钥 + 输入 PIN 完成                   │"
		echo -e "  │                                                         │"
		echo -e "  │  ${rw_huang}第3步  ▸ 菜单选项 [6] 部署公钥到服务器${rw_lv}                    │"
		echo -e "  │    自动将 .pub 公钥追加到 ~/.ssh/authorized_keys         │"
		echo -e "  │    或使用 ssh-copy-id 部署到远程服务器                  │"
		echo -e "  │                                                         │"
		echo -e "  │  ${rw_huang}第4步  ▸ 菜单选项 [2] 启用硬证登录 (服务端配置)${rw_lv}            │"
		echo -e "  │    写入 PubkeyAuthentication=yes, PasswordAuthentication=no │"
		echo -e "  │    自动清理旧认证模式残留 + sshd -t 检查 + 重启          │"
		echo -e "  │                                                         │"
		echo -e "  │  ${rw_huang}第5步  ▸ 菜单选项 [7] 测试 FIDO2 SSH 连接${rw_lv}                 │"
		echo -e "  │    终端提示 \"Touch your authenticator\" 时触摸硬件密钥    │"
		echo -e "  │                                                         │"
		echo -e "  └──────────────────────────────────────────────────────────┘"
		echo ""
		echo -e "  ${rw_cheng}━━━━━━ 卸载与删除指南 (不需要时执行) ━━━━━━${rw_lv}"
		echo ""
		echo -e "  ┌──────────────────────────────────────────────────────────┐"
		echo -e "  │                                                         │"
		echo -e "  │  ${rw_huang}▸ 菜单选项 [3] 禁用硬证登录${rw_lv}                              │"
		echo -e "  │    恢复密码登录，不删除密钥文件                          │"
		echo -e "  │                                                         │"
		echo -e "  │  ${rw_huang}▸ 菜单选项 [10] 卸载与删除 FIDO2 配置${rw_lv}                     │"
		echo -e "  │    内含 4 个子选项:                                     │"
		echo -e "  │      [1] 删除本地 FIDO2 密钥文件 (id_*_sk + .pub)      │"
		echo -e "  │      [2] 从 authorized_keys 中移除 FIDO2 公钥           │"
		echo -e "  │      [3] 一键全部清理 (密钥 + authorized_keys)          │"
		echo -e "  │      [4] 自检残留 (检查是否清理干净)                    │"
		echo -e "  │                                                         │"
		echo -e "  │  ${rw_huang}手动清理命令 (可选):${rw_lv}                                 │"
		echo -e "  │    rm -f ~/.ssh/id_*_sk ~/.ssh/id_*_sk.pub             │"
		echo -e "  │    sed -i '/^sk-/d' ~/.ssh/authorized_keys              │"
		echo -e "  │                                                         │"
		echo -e "  └──────────────────────────────────────────────────────────┘"
		echo ""
		echo -e "  ${rw_huang}💡 建议${rw_lv}  配置前通过腾讯云 VNC 保留应急通道，防止硬件丢失被锁"
		echo -e "  ${rw_huang}💡 建议${rw_lv}  ${rw_hong}注册至少 2 把硬件密钥${rw_lv}（主用+备用），菜单选项 [8] 一键完成"
		echo -e "  ${rw_hong}⚠ 注意${rw_lv}  腾讯云控制台"通行密钥" ≠ SSH FIDO2，不能用于 SSH 登录"
		echo ""
		echo -e "  ${rw_cheng}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${rw_lv}"
		;;
	  0)
		break
		;;
	  *)
		red "无效的输入!"
		;;
	esac
	break_cancel
done
}

# ================================================================
# Nginx 管理器
# ================================================================

ngxing_manager() {
while true; do
	clear

	# ── 状态探测 ──
	local _ngx_ver="" _ngx_stat="${rw_hong}未运行${rw_lv}" _site_cnt=0 _br="" _gz="" _zs="" _waf=""
	if docker inspect nginx &>/dev/null; then
		_ngx_ver=$(docker exec nginx nginx -v 2>&1 | sed -n -E 's/.*nginx\/([0-9.]+).*/\1/p')
		docker exec nginx nginx -t &>/dev/null && _ngx_stat="${rw_lv}运行中${rw_lv}" || _ngx_stat="${rw_hong}异常${rw_lv}"
		_site_cnt=$(ls /home/web/conf.d/*.conf 2>/dev/null | grep -vc 'map\|default')
	elif command -v nginx &>/dev/null; then
		_ngx_ver=$(nginx -v 2>&1 | sed -n -E 's/.*nginx\/([0-9.]+).*/\1/p')
		pgrep -x nginx &>/dev/null && _ngx_stat="${rw_lv}运行中${rw_lv}" || _ngx_stat="${rw_hong}未运行${rw_lv}"
	fi
	# 压缩 / WAF 状态
	if [ -f /home/web/nginx.conf ]; then
		grep -qE '^[[:space:]]*gzip[[:space:]]+on;' /home/web/nginx.conf && _gz=" gzip"
		grep -qE '^[[:space:]]*brotli[[:space:]]+on;' /home/web/nginx.conf && _br=" br"
		grep -qE '^[[:space:]]*zstd[[:space:]]+on;' /home/web/nginx.conf && _zs=" zstd"
		grep -qE '^[[:space:]]*modsecurity[[:space:]]+on;' /home/web/nginx.conf && _waf=" WAF"
	fi
	local _comp="${rw_lv}${_gz}${_br}${_zs}${_waf}${rw_lv}"

	echo -e "${rw_cheng}━━━━━━━━━━━━  Nginx 管理  ━━━━━━━━━━━━${rw_lv}"
	echo -e " ${_ngx_stat}  v${_ngx_ver:-?}  站点 ${rw_lv}${_site_cnt}${rw_lv}  ${_comp}"
	echo ""
	echo -e " ${rw_cheng}──── 服务${rw_lv}"
	echo -e " ${rw_huang}1${rw_lv}  启动    ${rw_huang}2${rw_lv}  停止    ${rw_huang}3${rw_lv}  重启    ${rw_huang}4${rw_lv}  重载"
	echo -e " ${rw_huang}5${rw_lv}  测试配置"
	echo ""
	echo -e " ${rw_cheng}──── 站点${rw_lv}"
	echo -e " ${rw_huang}6${rw_lv}  站点列表         ${rw_huang}7${rw_lv}  编辑站点配置"
	echo -e " ${rw_huang}8${rw_lv}  编辑全局配置     ${rw_huang}9${rw_lv}  证书管理"
	echo ""
	echo -e " ${rw_cheng}──── 反代${rw_lv}"
	echo -e " ${rw_huang}10${rw_lv} 添加反向代理    ${rw_huang}11${rw_lv} 添加负载均衡"
	echo -e " ${rw_huang}12${rw_lv} Stream四层代理"
	echo ""
	echo -e " ${rw_cheng}──── 优化${rw_lv}"
	echo -e " ${rw_huang}13${rw_lv} 压缩/性能       ${rw_huang}14${rw_lv} 安全防御"
	echo -e " ${rw_huang}15${rw_lv} 更新Nginx"
	echo ""
	echo -e " ${rw_cheng}──── 日志${rw_lv}"
	echo -e " ${rw_huang}16${rw_lv} 访问日志        ${rw_huang}17${rw_lv} 错误日志    ${rw_huang}18${rw_lv} 监听端口"
	echo ""
	echo -e " ${rw_cheng}────────────────────────────────────────${rw_lv}"
	echo -e " ${rw_huang}0${rw_lv}  返回主菜单"
	echo -e " ${rw_cheng}────────────────────────────────────────${rw_lv}"
	read -e -p " 请选择: " ngx_choice

	case $ngx_choice in
	  1)
		if docker inspect nginx &>/dev/null; then
			cd /home/web && docker compose start nginx && echo -e "${rw_lv}Nginx 已启动${rw_lv}"
		else
			systemctl start nginx 2>/dev/null || service nginx start 2>/dev/null || echo -e "${rw_hong}启动失败${rw_lv}"
		fi
		;;
	  2)
		if docker inspect nginx &>/dev/null; then
			cd /home/web && docker compose stop nginx && echo -e "${rw_lv}Nginx 已停止${rw_lv}"
		else
			systemctl stop nginx 2>/dev/null || service nginx stop 2>/dev/null || echo -e "${rw_hong}停止失败${rw_lv}"
		fi
		;;
	  3)
		if docker inspect nginx &>/dev/null; then
			cd /home/web && docker compose restart nginx && echo -e "${rw_lv}Nginx 已重启${rw_lv}"
		else
			systemctl restart nginx 2>/dev/null || service nginx restart 2>/dev/null || echo -e "${rw_hong}重启失败${rw_lv}"
		fi
		;;
	  4)
		if docker inspect nginx &>/dev/null; then
			docker exec nginx nginx -s reload && echo -e "${rw_lv}配置已重载${rw_lv}" || echo -e "${rw_hong}重载失败${rw_lv}"
		else
			nginx -s reload 2>/dev/null || systemctl reload nginx 2>/dev/null || echo -e "${rw_hong}重载失败${rw_lv}"
		fi
		;;
	  5)
		if docker inspect nginx &>/dev/null; then
			docker exec nginx nginx -t 2>&1
		else
			nginx -t 2>&1
		fi
		;;
	  6)
		ldnmp_web_status
		;;
	  7)
		if [ -d /home/web/conf.d ]; then
			echo -e "当前站点配置:"
			ls -1 /home/web/conf.d/*.conf 2>/dev/null | xargs -I{} basename {} .conf | grep -v '^map$\|^default$'
			echo ""
			read -e -p " 输入站点域名编辑配置: " _site
			[ -z "$_site" ] && continue
			if [ -f "/home/web/conf.d/${_site}.conf" ]; then
				install nano
				nano /home/web/conf.d/${_site}.conf
				read -e -p " 是否重载Nginx? (y/N): " _rl
				[[ "$_rl" =~ ^[Yy]$ ]] && docker exec nginx nginx -s reload
			else
				echo -e "${rw_hong}配置文件不存在${rw_lv}"
			fi
		else
			echo -e "${rw_hong}未找到站点配置目录${rw_lv}"
		fi
		;;
	  8)
		if [ -f /home/web/nginx.conf ]; then
			install nano
			nano /home/web/nginx.conf
			read -e -p " 是否重载Nginx? (y/N): " _rl
			[[ "$_rl" =~ ^[Yy]$ ]] && { docker exec nginx nginx -s reload 2>/dev/null || nginx -s reload 2>/dev/null; }
		else
			echo -e "${rw_huang}Nginx编译参数:${rw_lv}"
			if docker inspect nginx &>/dev/null; then
				docker exec nginx nginx -V 2>&1 | grep "configure arguments"
			else
				nginx -V 2>&1 | grep "configure arguments"
			fi
			echo ""
			echo -e "配置文件: /etc/nginx/nginx.conf  /etc/nginx/conf.d/"
		fi
		;;
	  9)
		if [ -d /home/web/certs ]; then
			echo -e "SSL 证书到期时间:"
			echo -e "${rw_cheng}────────────────────────────────────${rw_lv}"
			for _cert in /home/web/certs/*_cert.pem; do
				[ -f "$_cert" ] || continue
				local _dom=$(basename "$_cert" | sed 's/_cert.pem//')
				local _exp=$(openssl x509 -noout -enddate -in "$_cert" 2>/dev/null | awk -F'=' '{print $2}')
				local _exp_fmt=$(portable_date "$_exp" '+%Y-%m-%d' 2>/dev/null || echo "$_exp")
				printf " %-35s %s\n" "$_dom" "$_exp_fmt"
			done
			echo ""
			read -e -p " 输入域名申请/更新证书 (留空跳过): " _cert_domain
			[ -n "$_cert_domain" ] && { install_certbot; install_ssltls; certs_status; }
		else
			echo -e "${rw_hong}未找到证书目录${rw_lv}"
		fi
		;;
	  10)
		ldnmp_Proxy
		;;
	  11)
		ldnmp_Proxy_backend
		;;
	  12)
		stream_panel
		;;
	  13)
		web_optimization
		;;
	  14)
		web_security
		;;
	  15)
		if docker inspect nginx &>/dev/null; then
			nginx_upgrade
			echo -e "${rw_lv}Nginx 已更新${rw_lv}"
		else
			echo -e "${rw_huang}Nginx未通过Docker安装，请手动升级${rw_lv}"
		fi
		;;
	  16)
		if [ -f /home/web/logs/access.log ]; then
			tail -n 50 /home/web/logs/access.log
		elif [ -f /var/log/nginx/access.log ]; then
			tail -n 50 /var/log/nginx/access.log
		else
			echo -e "${rw_hong}未找到访问日志${rw_lv}"
		fi
		;;
	  17)
		if [ -f /home/web/logs/error.log ]; then
			tail -n 50 /home/web/logs/error.log
		elif [ -f /var/log/nginx/error.log ]; then
			tail -n 50 /var/log/nginx/error.log
		else
			echo -e "${rw_hong}未找到错误日志${rw_lv}"
		fi
		;;
	  18)
		if command -v ss &>/dev/null; then
			ss -tlnp | grep nginx
		elif command -v netstat &>/dev/null; then
			netstat -tlnp | grep nginx
		else
			docker inspect nginx --format='{{range $k,$v := .NetworkSettings.Ports}}{{$k}} -> {{range $v}}{{.HostPort}}{{end}}{{"\n"}}{{end}}' 2>/dev/null
		fi
		;;
	  0) return ;;
	  *) echo -e "${rw_hong}无效选择${rw_lv}" ;;
	esac
	break_end
done
}


# ================================================================
# Git管理函数
# ================================================================
# 功能: 提供GitHub仓库管理功能
# 包含: 克隆仓库、查看分支、暂存文件、提交推送等
# ================================================================

# 翻译git status输出为中文的函数
translate_git_status() {
  git status | awk '{
    if ($0 ~ /^On branch /) {
      print "位于分支 " substr($0, 11);
    } else if ($0 ~ /^Your branch is up to date with /) {
      print "您的分支与远端 " substr($0, 33) " 是最新的。";
    } else if ($0 ~ /^Changes to be committed:$/) {
      print "要提交的更改：";
    } else if ($0 ~ /^Changes not staged for commit:$/) {
      print "未暂存的更改：";
    } else if ($0 ~ /^  \(use "git add <file>..." to update what will be committed\)$/) {
      print "  (使用 \"git add <file>...\" 更新将要提交的内容)";
    } else if ($0 ~ /^  \(use "git restore <file>..." to discard changes in working directory\)$/) {
      print "  (使用 \"git restore <file>...\" 丢弃工作区的更改)";
    } else if ($0 ~ /^  \(use "git restore --staged <file>..." to unstage\)$/) {
      print "  (使用 \"git restore --staged <file>...\" 取消暂存)";
    } else if ($0 ~ /^        modified:   /) {
      print "        修改:   " substr($0, 18);
    } else if ($0 ~ /^        deleted:    /) {
      print "        删除:    " substr($0, 18);
    } else if ($0 ~ /^        new file:   /) {
      print "        新文件:   " substr($0, 18);
    } else if ($0 ~ /^        renamed:    /) {
      print "        重命名:    " substr($0, 18);
    } else if ($0 ~ /^Untracked files:$/) {
      print "未跟踪的文件：";
    } else if ($0 ~ /^  \(use "git add <file>..." to include in what will be committed\)$/) {
      print "  (使用 \"git add <file>...\" 包含在将要提交的内容中)";
    } else if ($0 ~ /^no changes added to commit/) {
      print "没有添加到提交的更改（使用 \"git add\" 和/或 \"git commit -a\"）";
    } else if ($0 ~ /^nothing to commit, working tree clean$/) {
      print "没有可提交的内容，工作区是干净的";
    } else if ($0 ~ /^nothing added to commit but untracked files present/) {
      print "没有添加到提交的内容，但存在未跟踪的文件（使用 \"git add\" 来跟踪）";
    } else if ($0 ~ /^Your branch and /) {
      print "您的分支和 " substr($0, 16);
    } else if ($0 ~ /^ have diverged,$/) {
      print " 已分叉，";
    } else if ($0 ~ /^and have /) {
      print "并且分别有 " substr($0, 9);
    } else if ($0 ~ /^ and /) {
      print " 和 " substr($0, 5);
    } else if ($0 ~ /^ different commits each, respectively\.$/) {
      print " 个不同的提交。";
    } else if ($0 ~ /^  \(use "git pull" to merge the remote branch into yours\)$/) {
      print "  (使用 \"git pull\" 将远程分支合并到您的分支)";
    } else if ($0 ~ /^Your branch is ahead of /) {
      print "您的分支领先于 " substr($0, 22);
    } else if ($0 ~ /^ by /) {
      print " 共 " substr($0, 4);
    } else if ($0 ~ /^ commits?\.$/) {
      print " 个提交。";
    } else if ($0 ~ /^  \(use "git push" to publish your local commits\)$/) {
      print "  (使用 \"git push\" 发布您的本地提交)";
    } else if ($0 ~ /^Your branch is behind /) {
      print "您的分支落后于 " substr($0, 21);
    } else if ($0 ~ /^  \(use "git pull" to update your local branch\)$/) {
      print "  (使用 \"git pull\" 更新您的本地分支)";
    } else {
      print $0;
    }
  }'
}

# ================================================================
# 一键换源 LinuxMirrors（版本控制入口）
# 原始功能「切换 Git 镜像源」已替换为 LinuxMirrors 一键换源
# 调用 linux_mirrors_switch 独立函数（与环境配置-35共用）
# 来源: https://github.com/SuperManito/LinuxMirrors
# ================================================================
switch_git_mirror() {
  linux_mirrors_switch
}

# ================================================================
# 功能: 自动部署常用 Git Hooks 到指定仓库
# 支持: pre-commit, post-merge, pre-push, post-receive 等
# ================================================================
git_hooks_deploy() {
  while true; do
    clear
    echo -e "${rw_huang}╔════════════════════════════════════════╗${rw_huang}"
    echo -e "${rw_huang}║         Git Hooks 自动部署             ║${rw_huang}"
    echo -e "${rw_huang}╚════════════════════════════════════════╝${rw_huang}"
    echo ""

    # 路径选择
    echo -e "${rw_huang}当前路径: ${rw_lv}$(pwd)${rw_lv}"
    echo ""
    echo -e "${rw_lv}操作实例: ${rw_hong}/home/user/my-project ${rw_lv}或 ${rw_hong}/var/www/html${rw_lv}"
    echo ""
    echo -e "${rw_huang}提示: 输入 0 返回上一级${rw_lv}"
    echo ""
    echo -e "请输入 git 仓库路径 (回车默认): \c"
    read -e repo_path
    if [ "$repo_path" = "0" ]; then return; fi
    if [ -z "$repo_path" ]; then
      repo_path="."
    fi

    # 展开路径
    repo_path="$(cd "$repo_path" 2>/dev/null && pwd || echo "$repo_path")"

    # 检查是否是 git 仓库
    if [ ! -d "$repo_path/.git" ]; then
      echo ""
      echo -e "${rw_hong}错误: $repo_path 不是有效的 git 仓库${rw_lv}"
      echo -e "${rw_huang}提示: 请先在该目录执行 git init 或克隆一个仓库${rw_lv}"
      echo ""
      read -e -p "按回车继续..."
      continue
    fi

    local hooks_dir="$repo_path/.git/hooks"

    while true; do
      clear
      echo -e "${rw_huang}╔════════════════════════════════════════╗${rw_huang}"
      echo -e "${rw_huang}║         Git Hooks 自动部署             ║${rw_huang}"
      echo -e "${rw_huang}╚════════════════════════════════════════╝${rw_huang}"
      echo ""
      echo -e "${rw_huang}当前仓库: $repo_path${rw_lv}"
      echo -e "${rw_lv}Hooks 目录: $hooks_dir ${rw_huang}[默认]${rw_lv}"
      echo ""
      echo -e "${rw_huang}${rw_huang}常用 Hooks${rw_lv}"
      echo -e "${rw_huang}1.   ${rw_lv}${rw_lv}pre-commit      ${rw_lv}${rw_huang}- 提交前自动检查${rw_lv}"
      echo -e "${rw_huang}2.   ${rw_lv}${rw_lv}post-merge      ${rw_lv}${rw_huang}- 合并后自动更新依赖${rw_lv}"
      echo -e "${rw_huang}3.   ${rw_lv}${rw_lv}pre-push        ${rw_lv}${rw_huang}- 推送前运行测试${rw_lv}"
      echo -e "${rw_huang}4.   ${rw_lv}${rw_lv}post-receive    ${rw_lv}${rw_huang}- 接收推送后自动部署${rw_lv}"
      echo -e "${rw_huang}5.   ${rw_lv}${rw_lv}commit-msg      ${rw_lv}${rw_huang}- 提交信息格式检查${rw_lv}"
      echo ""
      echo -e "${rw_cheng}------------------------${rw_lv}"
      echo -e "${rw_huang}6.  ${rw_lv}一键安装所有 Hooks${rw_lv}"
      echo -e "${rw_huang}7.   ${rw_lv}${rw_lv}查看已安装的 Hooks${rw_lv}"
      echo -e "${rw_huang}8.   ${rw_lv}${rw_lv}删除指定 Hook${rw_lv}"
      echo ""
      echo -e "${rw_cheng}------------------------${rw_lv}"
      echo -e "${rw_huang}9.   ${rw_lv}${rw_lv}切换仓库路径${rw_lv}"
      echo -e "${rw_huang}0.  返回主菜单"
      echo -e "${rw_cheng}------------------------${rw_lv}"
      read -e -p "请输入你的选择: " hook_choice

      case $hook_choice in
        1)
          echo ""
          echo -e "${rw_lv}正在部署 pre-commit hook...${rw_lv}"
          cat > "$hooks_dir/pre-commit" << 'HOOK_EOF'
#!/bin/bash
# pre-commit hook - 提交前自动检查
# 自动部署生成

echo -e "${rw_cheng}========================================${rw_lv}"
echo "  pre-commit: 提交前检查"
echo -e "${rw_cheng}========================================${rw_lv}"

# 检查是否有尾随空格
echo "[1/3] 检查尾随空格..."
if git diff --cached --check -- '*.py' '*.js' '*.ts' '*.sh' '*.md' '*.txt' 2>/dev/null; then
  echo "  通过"
else
  echo "  发现尾随空格，请修复后再提交"
  exit 1
fi

# 检查文件大小（超过 10MB 警告）
echo "[2/3] 检查大文件..."
large_files=$(git diff --cached --numstat | awk '$1 > 10000 || $2 > 10000 {print $3}')
if [ -n "$large_files" ]; then
  echo "  警告: 以下文件改动较大，请确认是否需要提交:"
  echo "$large_files" | sed 's/^/    /'
fi

# 检查是否有控制台输出遗留（针对 JS/TS 文件）
echo "[3/3] 检查 console.log..."
console_logs=$(git diff --cached --name-only | grep -E '\.(js|ts|jsx|tsx)$' | xargs git diff --cached -U0 -- 2>/dev/null | grep -E '^\+.*console\.(log|debug|warn|error)' || true)
if [ -n "$console_logs" ]; then
  echo "  警告: 发现 console.log 等调试语句:"
  echo "$console_logs" | sed 's/^/    /'
  echo "  建议清理后再提交"
fi

echo -e "${rw_cheng}========================================${rw_lv}"
echo "  pre-commit 检查完成"
echo -e "${rw_cheng}========================================${rw_lv}"
HOOK_EOF
          chmod +x "$hooks_dir/pre-commit"
          echo -e "${rw_lv}pre-commit hook 部署成功${rw_lv}"
          echo -e "${rw_huang}功能: 检查尾随空格、大文件警告、console.log 检查${rw_lv}"
          ;;

        2)
          echo ""
          echo -e "${rw_lv}正在部署 post-merge hook...${rw_lv}"
          cat > "$hooks_dir/post-merge" << 'HOOK_EOF'
#!/bin/bash
# post-merge hook - 合并后自动更新依赖
# 自动部署生成

echo -e "${rw_cheng}========================================${rw_lv}"
echo "  post-merge: 合并后自动更新"
echo -e "${rw_cheng}========================================${rw_lv}"

# 检测包管理器并自动安装依赖
if [ -f "package.json" ] && [ -f "package-lock.json" ]; then
  echo "[npm] 检测到 package-lock.json，正在执行 npm ci..."
  npm ci
elif [ -f "package.json" ] && [ -f "yarn.lock" ]; then
  echo "[yarn] 检测到 yarn.lock，正在执行 yarn install --frozen-lockfile..."
  yarn install --frozen-lockfile
elif [ -f "package.json" ]; then
  echo "[npm] 检测到 package.json，正在执行 npm install..."
  npm install
elif [ -f "requirements.txt" ]; then
  echo "[pip] 检测到 requirements.txt，正在执行 pip install -r requirements.txt..."
  pip install -r requirements.txt
elif [ -f "Pipfile" ]; then
  echo "[pipenv] 检测到 Pipfile，正在执行 pipenv install..."
  pipenv install
elif [ -f "composer.json" ]; then
  echo "[composer] 检测到 composer.json，正在执行 composer install..."
  composer install --no-dev --optimize-autoloader
elif [ -f "go.mod" ]; then
  echo "[go] 检测到 go.mod，正在执行 go mod download..."
  go mod download
elif [ -f "Cargo.toml" ]; then
  echo "[cargo] 检测到 Cargo.toml，正在执行 cargo build..."
  cargo build
else
  echo "未检测到已知依赖文件，跳过自动安装"
fi

echo -e "${rw_cheng}========================================${rw_lv}"
echo "  post-merge 更新完成"
echo -e "${rw_cheng}========================================${rw_lv}"
HOOK_EOF
          chmod +x "$hooks_dir/post-merge"
          echo -e "${rw_lv}post-merge hook 部署成功${rw_lv}"
          echo -e "${rw_huang}功能: 自动检测并安装 npm/yarn/pip/composer/go/cargo 依赖${rw_lv}"
          ;;

        3)
          echo ""
          echo -e "${rw_lv}正在部署 pre-push hook...${rw_lv}"
          cat > "$hooks_dir/pre-push" << 'HOOK_EOF'
#!/bin/bash
# pre-push hook - 推送前运行测试
# 自动部署生成

echo -e "${rw_cheng}========================================${rw_lv}"
echo "  pre-push: 推送前测试"
echo -e "${rw_cheng}========================================${rw_lv}"

# 检测测试框架并自动运行
if [ -f "package.json" ]; then
  if grep -q '"test"' package.json 2>/dev/null; then
    echo "[npm] 正在运行 npm test..."
    npm test
    if [ $? -ne 0 ]; then
      echo "测试失败，推送已取消"
      exit 1
    fi
  fi
elif [ -f "pytest.ini" ] || [ -f "setup.py" ] || [ -f "pyproject.toml" ]; then
  echo "[pytest] 正在运行 pytest..."
  pytest -q
  if [ $? -ne 0 ]; then
    echo "测试失败，推送已取消"
    exit 1
  fi
elif [ -f "go.mod" ]; then
  echo "[go] 正在运行 go test ./..."
  go test ./...
  if [ $? -ne 0 ]; then
    echo "测试失败，推送已取消"
    exit 1
  fi
elif [ -f "Cargo.toml" ]; then
  echo "[cargo] 正在运行 cargo test..."
  cargo test
  if [ $? -ne 0 ]; then
    echo "测试失败，推送已取消"
    exit 1
  fi
else
  echo "未检测到测试配置，跳过测试"
fi

echo -e "${rw_cheng}========================================${rw_lv}"
echo "  pre-push 测试通过"
echo -e "${rw_cheng}========================================${rw_lv}"
HOOK_EOF
          chmod +x "$hooks_dir/pre-push"
          echo -e "${rw_lv}pre-push hook 部署成功${rw_lv}"
          echo -e "${rw_huang}功能: 推送前自动运行 npm/pytest/go/cargo 测试${rw_lv}"
          ;;

        4)
          echo ""
          echo -e "${rw_lv}正在部署 post-receive hook...${rw_lv}"
          cat > "$hooks_dir/post-receive" << 'HOOK_EOF'
#!/bin/bash
# post-receive hook - 接收推送后自动部署
# 自动部署生成
# 此 hook 用于服务器端的裸仓库

read oldrev newrev refname
branch=$(echo "$refname" | sed 's|refs/heads/||')

echo -e "${rw_cheng}========================================${rw_lv}"
echo "  post-receive: 自动部署"
echo -e "${rw_cheng}========================================${rw_lv}"
echo "分支: $branch"
echo "提交: $newrev"
echo -e "${rw_cheng}========================================${rw_lv}"

# 设置部署目录（修改为你的实际部署路径）
DEPLOY_DIR="/var/www/html"
GIT_DIR=$(pwd)

if [ -d "$DEPLOY_DIR" ]; then
  echo "正在部署到 $DEPLOY_DIR ..."
  git --work-tree="$DEPLOY_DIR" --git-dir="$GIT_DIR" checkout -f "$branch"
  if [ $? -eq 0 ]; then
    echo "部署成功"
    # 可以在这里添加额外的部署后操作
    # 例如: 重启服务、清理缓存等
    # systemctl restart nginx
  else
    echo "部署失败"
    exit 1
  fi
else
  echo "部署目录 $DEPLOY_DIR 不存在"
  echo "请修改此 hook 中的 DEPLOY_DIR 变量"
fi

echo -e "${rw_cheng}========================================${rw_lv}"
HOOK_EOF
          chmod +x "$hooks_dir/post-receive"
          echo -e "${rw_lv}post-receive hook 部署成功${rw_lv}"
          echo -e "${rw_huang}功能: 接收推送后自动部署到指定目录${rw_lv}"
          echo -e "${rw_huang}注意: 此 hook 用于服务器端裸仓库，需修改 DEPLOY_DIR${rw_lv}"
          ;;

        5)
          echo ""
          echo -e "${rw_lv}正在部署 commit-msg hook...${rw_lv}"
          cat > "$hooks_dir/commit-msg" << 'HOOK_EOF'
#!/bin/bash
# commit-msg hook - 提交信息格式检查
# 自动部署生成

COMMIT_MSG_FILE=$1
COMMIT_MSG=$(head -n1 "$COMMIT_MSG_FILE")

echo -e "${rw_cheng}========================================${rw_lv}"
echo "  commit-msg: 提交信息检查"
echo -e "${rw_cheng}========================================${rw_lv}"

# 检查提交信息长度
if [ ${#COMMIT_MSG} -lt 5 ]; then
  echo "错误: 提交信息太短（至少5个字符）"
  exit 1
fi

# 检查提交信息是否以特定前缀开头（可选）
# 支持的类型: feat, fix, docs, style, refactor, test, chore
if echo "$COMMIT_MSG" | grep -qE '^(feat|fix|docs|style|refactor|test|chore|ci|build|perf)(\(.+\))?:'; then
  echo "提交信息格式正确"
else
  echo "警告: 提交信息建议遵循约定式提交格式"
  echo "  例如: feat: 添加新功能"
  echo "        fix: 修复某个bug"
  echo "        docs: 更新文档"
  echo "  可选前缀: feat, fix, docs, style, refactor, test, chore, ci, build, perf"
  echo ""
  echo "是否继续提交? (y/n)"
  read -n 1 -r < /dev/tty
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi

echo -e "${rw_cheng}========================================${rw_lv}"
HOOK_EOF
          chmod +x "$hooks_dir/commit-msg"
          echo -e "${rw_lv}commit-msg hook 部署成功${rw_lv}"
          echo -e "${rw_huang}功能: 检查提交信息长度和格式（约定式提交）${rw_lv}"
          ;;

        6)
          echo ""
          echo -e "${rw_lv}正在一键安装所有常用 Hooks...${rw_lv}"
          # 依次安装所有 hooks
          for hook_name in pre-commit post-merge pre-push commit-msg; do
            echo ""
            echo -e "${rw_huang}安装 $hook_name...${rw_lv}"
            case $hook_name in
              pre-commit)
                cat > "$hooks_dir/pre-commit" << 'HOOK_EOF'
#!/bin/bash
# pre-commit hook - 提交前自动检查
# 自动部署生成

echo -e "${rw_cheng}========================================${rw_lv}"
echo "  pre-commit: 提交前检查"
echo -e "${rw_cheng}========================================${rw_lv}"

# 检查是否有尾随空格
echo "[1/3] 检查尾随空格..."
if git diff --cached --check -- '*.py' '*.js' '*.ts' '*.sh' '*.md' '*.txt' 2>/dev/null; then
  echo "  通过"
else
  echo "  发现尾随空格，请修复后再提交"
  exit 1
fi

# 检查文件大小（超过 10MB 警告）
echo "[2/3] 检查大文件..."
large_files=$(git diff --cached --numstat | awk '$1 > 10000 || $2 > 10000 {print $3}')
if [ -n "$large_files" ]; then
  echo "  警告: 以下文件改动较大，请确认是否需要提交:"
  echo "$large_files" | sed 's/^/    /'
fi

# 检查是否有控制台输出遗留（针对 JS/TS 文件）
echo "[3/3] 检查 console.log..."
console_logs=$(git diff --cached --name-only | grep -E '\.(js|ts|jsx|tsx)$' | xargs git diff --cached -U0 -- 2>/dev/null | grep -E '^\+.*console\.(log|debug|warn|error)' || true)
if [ -n "$console_logs" ]; then
  echo "  警告: 发现 console.log 等调试语句:"
  echo "$console_logs" | sed 's/^/    /'
  echo "  建议清理后再提交"
fi

echo -e "${rw_cheng}========================================${rw_lv}"
echo "  pre-commit 检查完成"
echo -e "${rw_cheng}========================================${rw_lv}"
HOOK_EOF
                ;;
              post-merge)
                cat > "$hooks_dir/post-merge" << 'HOOK_EOF'
#!/bin/bash
# post-merge hook - 合并后自动更新依赖
# 自动部署生成

echo -e "${rw_cheng}========================================${rw_lv}"
echo "  post-merge: 合并后自动更新"
echo -e "${rw_cheng}========================================${rw_lv}"

if [ -f "package.json" ] && [ -f "package-lock.json" ]; then
  echo "[npm] 正在执行 npm ci..."
  npm ci
elif [ -f "package.json" ] && [ -f "yarn.lock" ]; then
  echo "[yarn] 正在执行 yarn install --frozen-lockfile..."
  yarn install --frozen-lockfile
elif [ -f "package.json" ]; then
  echo "[npm] 正在执行 npm install..."
  npm install
elif [ -f "requirements.txt" ]; then
  echo "[pip] 正在执行 pip install -r requirements.txt..."
  pip install -r requirements.txt
elif [ -f "Pipfile" ]; then
  echo "[pipenv] 正在执行 pipenv install..."
  pipenv install
elif [ -f "composer.json" ]; then
  echo "[composer] 正在执行 composer install..."
  composer install --no-dev --optimize-autoloader
elif [ -f "go.mod" ]; then
  echo "[go] 正在执行 go mod download..."
  go mod download
elif [ -f "Cargo.toml" ]; then
  echo "[cargo] 正在执行 cargo build..."
  cargo build
fi

echo -e "${rw_cheng}========================================${rw_lv}"
echo "  post-merge 更新完成"
echo -e "${rw_cheng}========================================${rw_lv}"
HOOK_EOF
                ;;
              pre-push)
                cat > "$hooks_dir/pre-push" << 'HOOK_EOF'
#!/bin/bash
# pre-push hook - 推送前运行测试
# 自动部署生成

echo -e "${rw_cheng}========================================${rw_lv}"
echo "  pre-push: 推送前测试"
echo -e "${rw_cheng}========================================${rw_lv}"

if [ -f "package.json" ] && grep -q '"test"' package.json 2>/dev/null; then
  echo "[npm] 正在运行 npm test..."
  npm test
  if [ $? -ne 0 ]; then
    echo "测试失败，推送已取消"
    exit 1
  fi
elif [ -f "pytest.ini" ] || [ -f "setup.py" ] || [ -f "pyproject.toml" ]; then
  echo "[pytest] 正在运行 pytest..."
  pytest -q
  if [ $? -ne 0 ]; then
    echo "测试失败，推送已取消"
    exit 1
  fi
elif [ -f "go.mod" ]; then
  echo "[go] 正在运行 go test ./..."
  go test ./...
  if [ $? -ne 0 ]; then
    echo "测试失败，推送已取消"
    exit 1
  fi
elif [ -f "Cargo.toml" ]; then
  echo "[cargo] 正在运行 cargo test..."
  cargo test
  if [ $? -ne 0 ]; then
    echo "测试失败，推送已取消"
    exit 1
  fi
fi

echo -e "${rw_cheng}========================================${rw_lv}"
echo "  pre-push 测试通过"
echo -e "${rw_cheng}========================================${rw_lv}"
HOOK_EOF
                ;;
              commit-msg)
                cat > "$hooks_dir/commit-msg" << 'HOOK_EOF'
#!/bin/bash
# commit-msg hook - 提交信息格式检查
# 自动部署生成

COMMIT_MSG_FILE=$1
COMMIT_MSG=$(head -n1 "$COMMIT_MSG_FILE")

echo -e "${rw_cheng}========================================${rw_lv}"
echo "  commit-msg: 提交信息检查"
echo -e "${rw_cheng}========================================${rw_lv}"

if [ ${#COMMIT_MSG} -lt 5 ]; then
  echo "错误: 提交信息太短（至少5个字符）"
  exit 1
fi

if echo "$COMMIT_MSG" | grep -qE '^(feat|fix|docs|style|refactor|test|chore|ci|build|perf)(\(.+\))?:'; then
  echo "提交信息格式正确"
else
  echo "警告: 提交信息建议遵循约定式提交格式"
  echo "  例如: feat: 添加新功能"
  echo "        fix: 修复某个bug"
  echo ""
  read -n 1 -r < /dev/tty
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi

echo -e "${rw_cheng}========================================${rw_lv}"
HOOK_EOF
                ;;
            esac
            chmod +x "$hooks_dir/$hook_name"
            echo -e "${rw_lv}$hook_name 安装完成${rw_lv}"
          done
          echo ""
          echo -e "${rw_lv}所有常用 Hooks 一键安装完成！${rw_lv}"
          ;;

        7)
          echo ""
          echo -e "${rw_huang}已安装的 Hooks:${rw_lv}"
          if [ -d "$hooks_dir" ]; then
            local found=0
            for hook in "$hooks_dir"/*; do
              if [ -f "$hook" ] && [ -x "$hook" ]; then
                local name=$(basename "$hook")
                # 跳过 sample 文件
                if [[ "$name" == *.sample ]]; then continue; fi
                found=1
                echo -e "${rw_huang}  ${rw_lv}$name${rw_lv}"
              fi
            done
            if [ $found -eq 0 ]; then
              echo -e "${rw_hong}  尚未安装任何自定义 hooks${rw_lv}"
            fi
          else
            echo -e "${rw_hong}  Hooks 目录不存在${rw_lv}"
          fi
          ;;

        8)
          echo ""
          echo -e "${rw_huang}已安装的 Hooks:${rw_lv}"
          local hooks_list=()
          local idx=1
          for hook in "$hooks_dir"/*; do
            if [ -f "$hook" ] && [ -x "$hook" ]; then
              local name=$(basename "$hook")
              if [[ "$name" == *.sample ]]; then continue; fi
              hooks_list+=("$name")
              echo -e "${rw_huang}$idx. $name"
              ((idx++))
            fi
          done
          if [ ${#hooks_list[@]} -eq 0 ]; then
            echo -e "${rw_hong}  没有可删除的 hooks${rw_lv}"
          else
            echo ""
            read -e -p "请输入要删除的 Hook 编号 (0 取消): " del_idx
            if [ "$del_idx" != "0" ] && [ "$del_idx" -ge 1 ] && [ "$del_idx" -le ${#hooks_list[@]} ] 2>/dev/null; then
              local del_name="${hooks_list[$((del_idx-1))]}"
              rm -f "$hooks_dir/$del_name"
              echo -e "${rw_lv}已删除 $del_name${rw_lv}"
            fi
          fi
          ;;

        9)
          break
          ;;

        0)
          return
          ;;

        *)
          echo -e "${rw_hong}无效的输入!${rw_lv}"
          ;;
      esac

      echo ""
      read -e -p "按回车继续..."
    done
  done
}

github_manager() {
  # ── 首次进入初始化（只执行一次，循环内不重复）──
  if [ -z "${_GITHUB_MANAGER_INIT:-}" ]; then
    export _GITHUB_MANAGER_INIT=1
    send_stats "Git管理"
    # install git 只查一次，已存在就跳过
    command -v git &>/dev/null || install git
  fi
  while true; do
    clear

    # ════════════════════════════════════════════
    # 状态面板 - 一次性获取所有状态（合并 git 命令减少 fork）
    # ════════════════════════════════════════════
    local _is_repo=false _branch="-" _status_color="${rw_lv}" _status_text="干净"
    local _remote_name="无" _remote_url="" _remote_short="无"
    local _ahead=0 _behind=0 _staged=0 _modified=0 _untracked=0 _total_changes=0
    local _current_dir=""

    _current_dir=$(basename "$(pwd)" 2>/dev/null || echo "?")

    if git rev-parse --is-inside-work-tree &>/dev/null; then
        _is_repo=true
        # ── 一次性获取分支 + ahead/behind + 变更统计 ──
        # git status --porcelain=v1 --branch 输出:
        #   ## main...origin/main [ahead 2, behind 1]
        #   M  file1.py
        #   ?? file2.py
        local _status_block
        _status_block=$(git status --porcelain=v1 --branch 2>/dev/null)

        # 解析分支行（第一行以 ## 开头）
        local _branch_line=""
        if [ -n "$_status_block" ]; then
            _branch_line=$(echo "$_status_block" | head -1)
        fi
        # 提取分支名: ## main...origin/main → main
        if [[ "$_branch_line" =~ ^##[[:space:]]+([^.\ ]+) ]]; then
            _branch="${BASH_REMATCH[1]}"
        else
            _branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null || echo "?")
        fi
        # 提取 ahead/behind: [ahead 2, behind 1]
        if [[ "$_branch_line" =~ ahead[[:space:]]+([0-9]+) ]]; then
            _ahead="${BASH_REMATCH[1]}"
        fi
        if [[ "$_branch_line" =~ behind[[:space:]]+([0-9]+) ]]; then
            _behind="${BASH_REMATCH[1]}"
        fi

        # ── 文件变更统计（从 _status_block 直接统计，不再调 git status）──
        # 跳过第一行（## 分支行），统计剩余行
        local _files_block=""
        if [ -n "$_status_block" ]; then
            _files_block=$(echo "$_status_block" | tail -n +2)
        fi
        if [ -n "$_files_block" ]; then
            # 一次性用 awk 统计三种状态，避免 3 次 grep -c
            local _counts
            _counts=$(echo "$_files_block" | awk '
                /^[MADRC]/ { staged++ }
                /^.[MD]/   { modified++ }
                /^\?\?/    { untracked++ }
                END {
                    printf "%d %d %d", staged+0, modified+0, untracked+0
                }
            ')
            _staged=$(echo "$_counts" | awk '{print $1}')
            _modified=$(echo "$_counts" | awk '{print $2}')
            _untracked=$(echo "$_counts" | awk '{print $3}')
            _staged=${_staged:-0}
            _modified=${_modified:-0}
            _untracked=${_untracked:-0}
            _total_changes=$((_staged + _modified + _untracked))
            _status_color="${rw_huang}"
            _status_text="有变更"
        else
            _status_color="${rw_lv}"
            _status_text="干净"
        fi

        # ── 远程仓库信息（仅当未从 branch 行获取到 origin 时才查）──
        if [[ "$_branch_line" =~ \.\.\.([^/]+)/ ]]; then
            # 从 ## main...origin/main 提取远程名
            _remote_name="${BASH_REMATCH[1]}"
            _remote_url=$(git remote get-url "$_remote_name" 2>/dev/null)
        else
            # branch 行没有远程信息，回退到 git remote
            _remote_url=$(git remote get-url origin 2>/dev/null)
            if [ -n "$_remote_url" ]; then
                _remote_name="origin"
            fi
        fi
        if [ -n "$_remote_url" ]; then
            # 提取友好名: github.com/user/repo.git → user/repo
            _remote_short=$(echo "$_remote_url" | sed 's|\.git$||; s|.*[:/]||; s|^.*@.*:||' 2>/dev/null)
            [ -z "$_remote_short" ] && _remote_short="$_remote_url"
            # ahead/behind 如果 status 没给，用 rev-list 补充（仅在远程引用存在时）
            if [ "$_ahead" = "0" ] && [ "$_behind" = "0" ]; then
                if git rev-parse --verify "${_remote_name}/HEAD" &>/dev/null 2>&1; then
                    :
                fi
            fi
        fi
    fi

    # ════════════════════════════════════════════
    # 顶部状态面板
    # ════════════════════════════════════════════
    echo -e "${rw_cheng}━━━━━━━━━━━━  Git 版本控制  ━━━━━━━━━━━━${rw_lv}"

    if [ "$_is_repo" = true ]; then
        # 第一行: 目录 + 分支 + 状态
        echo -e " 目录 ${rw_huang}${_current_dir}${rw_lv}  分支 ${rw_huang}${_branch}${rw_lv}  状态 ${_status_color}${_status_text}${rw_lv}"

        # 第二行: 变更明细
        if [ "$_total_changes" -gt 0 ]; then
            local _change_detail=""
            [ "$_staged" -gt 0 ] && _change_detail+="已暂存 ${rw_lv}${_staged}${rw_lv}  "
            [ "$_modified" -gt 0 ] && _change_detail+="已修改 ${rw_huang}${_modified}${rw_lv}  "
            [ "$_untracked" -gt 0 ] && _change_detail+="未跟踪 ${rw_hong}${_untracked}${rw_lv}  "
            echo -e " 变更: ${_change_detail}共 ${rw_huang}${_total_changes}${rw_lv} 个文件"
        fi

        # 第三行: 远程仓库 + ahead/behind
        if [ "$_remote_name" != "无" ]; then
            local _sync_info=""
            if [ "$_ahead" -gt 0 ] 2>/dev/null; then
                _sync_info+="  ${rw_huang}↑${_ahead}待推送${rw_lv}"
            fi
            if [ "$_behind" -gt 0 ] 2>/dev/null; then
                _sync_info+="  ${rw_huang}↓${_behind}待拉取${rw_lv}"
            fi
            [ -z "$_sync_info" ] && _sync_info="  ${rw_lv}✓已同步${rw_lv}"
            echo -e " 远程 ${rw_huang}${_remote_name}${rw_lv}: ${rw_lv}${_remote_short}${rw_lv}${_sync_info}"
        else
            echo -e " 远程 ${rw_hong}未配置${rw_lv}  提示: 选 7 添加远程仓库"
        fi
    else
        echo -e " ${rw_hong}当前目录不是 git 仓库${rw_lv}"
        echo -e " 提示: 选 8 初始化新仓库  或  选 9 克隆远程仓库"
    fi
    echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"

    # ════════════════════════════════════════════
    # 菜单选项
    # ════════════════════════════════════════════
    echo ""
    echo -e " ${rw_cheng}──── 提交与推送（日常最常用）────${rw_lv}"
    echo -e "  ${rw_huang}1${rw_lv}  快速提交并推送       ${rw_huang}2${rw_lv}  拉取更新"
    echo -e "  ${rw_huang}3${rw_lv}  仅推送               ${rw_huang}4${rw_lv}  查看状态"
    echo -e "  ${rw_huang}5${rw_lv}  提交日志             ${rw_huang}6${rw_lv}  查看文件差异"
    echo ""
    echo -e " ${rw_cheng}──── 版本回退 ────${rw_lv}"
    echo -e "  ${rw_huang}7${rw_lv}  撤销上次提交         ${rw_huang}8${rw_lv}  回退到历史版本"
    echo ""
    echo -e " ${rw_cheng}──── 仓库管理 ────${rw_lv}"
    echo -e "  ${rw_huang}9${rw_lv}  远程仓库管理         ${rw_huang}10${rw_lv} 初始化新仓库"
    echo -e "  ${rw_huang}11${rw_lv} 克隆仓库             ${rw_huang}12${rw_lv} 分支管理"
    echo ""
    echo -e " ${rw_cheng}──── 高级 ────${rw_lv}"
    echo -e "  ${rw_huang}13${rw_lv} 一键换源 ${rw_huang}            14${rw_lv} GitHooks 部署"
    echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
    echo -e "  ${rw_huang}0${rw_lv}  返回主菜单"
    echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
    read -e -p " 请选择: " sub_choice < /dev/tty
    sub_choice=${sub_choice:-0}

    case $sub_choice in
      1)
        # ════════════════════════════════════════════
        # 1. 快速提交并推送 - 最常用功能
        # ════════════════════════════════════════════
        clear
        echo -e "${rw_cheng}━━━━━━━━━━━━  快速提交并推送  ━━━━━━━━━━━━${rw_lv}"
        echo ""

        if ! git rev-parse --is-inside-work-tree &>/dev/null; then
            echo -e " ${rw_hong}✗ 当前目录不是 git 仓库${rw_lv}"
            echo -e " ${rw_huang}提示: 返回菜单选 10 初始化新仓库${rw_lv}"
            break_end; continue
        fi

        # ── 显示变更文件 ──
        local _changes
        _changes=$(git status --short 2>/dev/null)
        if [ -z "$_changes" ]; then
            echo -e " ${rw_lv}✓ 工作区干净，没有可提交的更改${rw_lv}"
            break_end; continue
        fi

        echo -e " ${rw_cheng}── 待提交文件 ──${rw_lv}"
        echo "$_changes" | while IFS= read -r line; do
            local _flag="${line:0:2}"
            local _file="${line:3}"
            local _color="$rw_lv" _mark=""
            case "$_flag" in
                M*)  _color="$rw_huang"; _mark="[修改]" ;;
                A*)  _color="$rw_lv";   _mark="[新增]" ;;
                D*)  _color="$rw_hong"; _mark="[删除]" ;;
                R*)  _color="$rw_lv";   _mark="[重命名]" ;;
                ??*) _color="$rw_hong"; _mark="[未跟踪]" ;;
                *)   _color="$rw_lv";   _mark="[其他]" ;;
            esac
            echo -e "   ${_color}${_mark}${rw_lv}  ${_file}"
        done
        local _total
        _total=$(echo "$_changes" | wc -l)
        echo -e " ${rw_cheng}────────────────────────${rw_lv}"
        echo -e " 共 ${rw_huang}${_total}${rw_lv} 个文件变更"
        echo ""

        # ── 提交信息输入 ──
        echo -e " ${rw_cheng}── 提交信息 ──${rw_lv}"
        echo -e " ${rw_huang}推荐格式:${rw_lv}"
        echo -e "   feat: 新功能    fix: 修复bug    docs: 文档"
        echo -e "   style: 格式     refactor: 重构  chore: 杂项"
        echo -e " ${rw_huang}直接回车 = 自动时间戳${rw_lv}"
        echo ""
        read -e -p " 提交信息（0返回上一级）: " _msg < /dev/tty
        [ "$_msg" = "0" ] && continue
        [ -z "$_msg" ] && _msg="更新 $(date '+%Y-%m-%d %H:%M')"

        # ── 执行提交 ──
        echo ""
        echo -e " ${rw_cheng}── 执行提交 ──${rw_lv}"
        git add -A 2>&1 | head -3
        local _commit_out
        _commit_out=$(GIT_EDITOR=true git commit -m "$_msg" 2>&1)
        local _commit_rc=$?

        if [ $_commit_rc -ne 0 ]; then
            echo -e " ${rw_hong}✗ 提交失败${rw_lv}"
            echo "$_commit_out" | head -5
            # 权限问题自动修复
            if echo "$_commit_out" | grep -qi "permission\|denied\|owner"; then
                echo ""
                echo -e " ${rw_huang}检测到权限问题，尝试修复 .git 属主...${rw_lv}"
                chown -R "$(whoami):$(id -gn)" .git 2>/dev/null
                if [ $? -eq 0 ]; then
                    echo -e " ${rw_lv}✓ 权限已修复，重新提交...${rw_lv}"
                    _commit_out=$(GIT_EDITOR=true git commit -m "$_msg" 2>&1)
                    if [ $? -eq 0 ]; then
                        echo -e " ${rw_lv}✓ 提交成功${rw_lv}"
                        echo "$_commit_out" | head -3
                    else
                        echo -e " ${rw_hong}✗ 仍然失败，请手动: sudo chown -R $(whoami):$(id -gn) .git${rw_lv}"
                        break_end; continue
                    fi
                else
                    echo -e " ${rw_hong}修复失败，请手动: sudo chown -R $(whoami):$(id -gn) .git${rw_lv}"
                    break_end; continue
                fi
            else
                break_end; continue
            fi
        else
            echo -e " ${rw_lv}✓ 提交成功${rw_lv}"
            echo "$_commit_out" | head -3
        fi

        # ── 推送到远程 ──
        echo ""
        local _remote_chk
        _remote_chk=$(git remote 2>/dev/null | head -1)
        if [ -z "$_remote_chk" ]; then
            echo -e " ${rw_huang}⚠ 未配置远程仓库${rw_lv}"
            echo -e " ${rw_huang}提示: 返回菜单选 9 添加远程仓库${rw_lv}"
            echo -e " ${rw_huang}或选 10 初始化并关联 GitHub${rw_lv}"
        else
            local _br
            _br=$(git symbolic-ref --short HEAD 2>/dev/null || echo "main")
            local _ru=$(git remote get-url "$_remote_chk" 2>/dev/null)
            # 记录推送前的远程 SHA，用于事后校验是否真的推送成功
            local _remote_sha_before
            _remote_sha_before=$(git ls-remote "$_remote_chk" "$_br" 2>/dev/null | awk '{print $1}')
            local _local_sha
            _local_sha=$(git rev-parse HEAD 2>/dev/null)
            echo -e " ${rw_cheng}── 推送到远程 ──${rw_lv}"
            echo -e " 远程: ${rw_huang}${_remote_chk}${rw_lv}  分支: ${rw_huang}${_br}${rw_lv}"
            echo -e " 地址: ${rw_lv}${_ru}${rw_lv}"
            echo -e " 本地最新: ${rw_lv}${_local_sha:0:8}${rw_lv}  $(git log -1 --format='%s' 2>/dev/null)"
            # HTTPS 远程提示凭证
            case "$_ru" in
                https://*)
                    echo -e " ${rw_huang}⚠ HTTPS 远程，若推送失败请检查 Token/凭证${rw_lv}"
                    ;;
            esac
            echo ""
            read -e -p " 是否推送到远程？(Y/n): " _push < /dev/tty
            if [[ ! "$_push" =~ ^[Nn]$ ]]; then
                # ── 后台执行 git push + 进度条动画 ──
                local _push_log="/tmp/riwi_push_$$.log"
                (
                    git -c core.askpass= push "$_remote_chk" "$_br" > "$_push_log" 2>&1
                    echo "EXIT_CODE=$?" >> "$_push_log"
                ) &
                local _push_pid=$!

                # 进度条动画（与拉取同样的样式）
                local _bar_width=30
                local _spin_idx=0
                local _spin_chars="|/-\\"
                local _elapsed=0
                local _max_wait=120
                while kill -0 "$_push_pid" 2>/dev/null; do
                    local _progress=$(( _elapsed * _bar_width / _max_wait ))
                    [ "$_progress" -gt "$_bar_width" ] && _progress=$_bar_width
                    local _filled=""
                    local _i=0
                    while [ "$_i" -lt "$_progress" ]; do _filled+="█"; _i=$((_i+1)); done
                    local _empty=""
                    _i=0
                    while [ "$_i" -lt $((_bar_width - _progress)) ]; do _empty+="░"; _i=$((_i+1)); done
                    local _pct=$(( _elapsed * 100 / _max_wait ))
                    [ "$_pct" -gt 99 ] && _pct=99
                    local _spin_char="${_spin_chars:$_spin_idx:1}"
                    _spin_idx=$(( (_spin_idx + 1) % 4 ))
                    printf "\r ${rw_huang}[%s%s]${rw_lv} %3d%% %s 推送中..." "$_filled" "$_empty" "$_pct" "$_spin_char"
                    sleep 0.2
                    _elapsed=$((_elapsed + 1))
                    if [ "$_elapsed" -ge "$_max_wait" ]; then
                        echo ""
                        echo -e " ${rw_hong}✗ 推送超时（${_max_wait}秒）${rw_lv}"
                        kill "$_push_pid" 2>/dev/null
                        wait "$_push_pid" 2>/dev/null
                        rm -f "$_push_log"
                        echo -e " ${rw_huang}可能网络问题 → 选 13 切换镜像源${rw_lv}"
                        break_end; continue
                    fi
                done
                wait "$_push_pid" 2>/dev/null

                # 完成进度条
                _filled=""
                _i=0
                while [ "$_i" -lt "$_bar_width" ]; do _filled+="█"; _i=$((_i+1)); done
                printf "\r ${rw_lv}[%s]${rw_lv} 100%% ✓${rw_lv}\n" "$_filled"

                # 解析推送结果
                local _push_out _push_rc
                _push_rc=$(grep "^EXIT_CODE=" "$_push_log" | cut -d= -f2)
                _push_rc=${_push_rc:-1}
                _push_out=$(grep -v "^EXIT_CODE=" "$_push_log")
                rm -f "$_push_log"

                if [ "$_push_rc" = "0" ]; then
                    # 二次校验：远程 SHA 是否已更新为本地 SHA
                    local _remote_sha_after
                    _remote_sha_after=$(git ls-remote "$_remote_chk" "$_br" 2>/dev/null | awk '{print $1}')
                    if [ "$_remote_sha_after" = "$_local_sha" ]; then
                        echo ""
                        echo -e " ${rw_lv}✓ 推送成功${rw_lv}"
                        echo -e " ${rw_huang}${_remote_chk}/${_br}${rw_lv}"
                        echo -e " 远程已更新: ${rw_lv}${_remote_sha_after:0:8}${rw_lv}"
                    else
                        echo ""
                        echo -e " ${rw_huang}⚠ push 返回成功，但远程未更新${rw_lv}"
                        echo -e "   推送前: ${_remote_sha_before:0:8}"
                        echo -e "   推送后: ${_remote_sha_after:0:8}"
                        echo -e "   期望值: ${_local_sha:0:8} (本地HEAD)"
                        echo -e " ${rw_huang}可能推送到了其他分支或被服务端拒绝${rw_lv}"
                    fi
                else
                    echo ""
                    echo -e " ${rw_hong}✗ 推送失败 (退出码: $_push_rc)${rw_lv}"
                    echo -e " ${rw_cheng}── 完整错误输出 ──${rw_lv}"
                    echo "$_push_out" | head -15
                    echo -e " ${rw_cheng}────────────────${rw_lv}"
                    echo -e " ${rw_huang}可能原因:${rw_lv}"
                    echo -e "   1. 本地落后于远程 → 选 2 拉取更新"
                    echo -e "   2. 权限/凭证问题 → 检查 SSH密钥/Token"
                    echo -e "   3. 网络问题 → 选 13 切换镜像源"
                    echo ""
                    read -e -p " 是否先拉取再推送？(y/N): " _retry < /dev/tty
                    if [[ "$_retry" =~ ^[Yy]$ ]]; then
                        # 拉取（带进度条）
                        local _pull_retry_log="/tmp/riwi_pull_retry_$$.log"
                        (
                            git pull --rebase "$_remote_chk" "$_br" > "$_pull_retry_log" 2>&1
                            echo "EXIT_CODE=$?" >> "$_pull_retry_log"
                        ) &
                        local _pull_retry_pid=$!
                        _elapsed=0
                        local _max_wait2=60
                        while kill -0 "$_pull_retry_pid" 2>/dev/null; do
                            local _progress2=$(( _elapsed * _bar_width / _max_wait2 ))
                            [ "$_progress2" -gt "$_bar_width" ] && _progress2=$_bar_width
                            local _filled2=""
                            _i=0
                            while [ "$_i" -lt "$_progress2" ]; do _filled2+="█"; _i=$((_i+1)); done
                            local _empty2=""
                            _i=0
                            while [ "$_i" -lt $((_bar_width - _progress2)) ]; do _empty2+="░"; _i=$((_i+1)); done
                            local _pct2=$(( _elapsed * 100 / _max_wait2 ))
                            [ "$_pct2" -gt 99 ] && _pct2=99
                            local _spin_char2="${_spin_chars:$_spin_idx:1}"
                            _spin_idx=$(( (_spin_idx + 1) % 4 ))
                            printf "\r ${rw_huang}[%s%s]${rw_lv} %3d%% %s 拉取中..." "$_filled2" "$_empty2" "$_pct2" "$_spin_char2"
                            sleep 0.2
                            _elapsed=$((_elapsed + 1))
                            if [ "$_elapsed" -ge "$_max_wait2" ]; then
                                kill "$_pull_retry_pid" 2>/dev/null
                                break
                            fi
                        done
                        wait "$_pull_retry_pid" 2>/dev/null
                        _filled=""
                        _i=0
                        while [ "$_i" -lt "$_bar_width" ]; do _filled+="█"; _i=$((_i+1)); done
                        printf "\r ${rw_lv}[%s]${rw_lv} 100%% ✓${rw_lv}\n" "$_filled"
                        grep -v "^EXIT_CODE=" "$_pull_retry_log" | head -10 | sed 's/^/ /'
                        rm -f "$_pull_retry_log"

                        # 重新推送（带进度条）
                        local _push_retry_log="/tmp/riwi_push_retry_$$.log"
                        (
                            git push "$_remote_chk" "$_br" > "$_push_retry_log" 2>&1
                            echo "EXIT_CODE=$?" >> "$_push_retry_log"
                        ) &
                        local _push_retry_pid=$!
                        _elapsed=0
                        while kill -0 "$_push_retry_pid" 2>/dev/null; do
                            local _progress3=$(( _elapsed * _bar_width / _max_wait2 ))
                            [ "$_progress3" -gt "$_bar_width" ] && _progress3=$_bar_width
                            local _filled3=""
                            _i=0
                            while [ "$_i" -lt "$_progress3" ]; do _filled3+="█"; _i=$((_i+1)); done
                            local _empty3=""
                            _i=0
                            while [ "$_i" -lt $((_bar_width - _progress3)) ]; do _empty3+="░"; _i=$((_i+1)); done
                            local _pct3=$(( _elapsed * 100 / _max_wait2 ))
                            [ "$_pct3" -gt 99 ] && _pct3=99
                            local _spin_char3="${_spin_chars:$_spin_idx:1}"
                            _spin_idx=$(( (_spin_idx + 1) % 4 ))
                            printf "\r ${rw_huang}[%s%s]${rw_lv} %3d%% %s 重新推送..." "$_filled3" "$_empty3" "$_pct3" "$_spin_char3"
                            sleep 0.2
                            _elapsed=$((_elapsed + 1))
                            if [ "$_elapsed" -ge "$_max_wait2" ]; then
                                kill "$_push_retry_pid" 2>/dev/null
                                break
                            fi
                        done
                        wait "$_push_retry_pid" 2>/dev/null
                        _filled=""
                        _i=0
                        while [ "$_i" -lt "$_bar_width" ]; do _filled+="█"; _i=$((_i+1)); done
                        printf "\r ${rw_lv}[%s]${rw_lv} 100%% ✓${rw_lv}\n" "$_filled"

                        local _push_rc2
                        _push_rc2=$(grep "^EXIT_CODE=" "$_push_retry_log" | cut -d= -f2)
                        _push_rc2=${_push_rc2:-1}
                        local _push_out2
                        _push_out2=$(grep -v "^EXIT_CODE=" "$_push_retry_log")
                        rm -f "$_push_retry_log"
                        if [ "$_push_rc2" = "0" ]; then
                            local _remote_sha_after2
                            _remote_sha_after2=$(git ls-remote "$_remote_chk" "$_br" 2>/dev/null | awk '{print $1}')
                            if [ "$_remote_sha_after2" = "$(git rev-parse HEAD)" ]; then
                                echo -e " ${rw_lv}✓ 拉取并推送成功${rw_lv}"
                            else
                                echo -e " ${rw_huang}⚠ push 返回成功但远程未更新，请手动检查${rw_lv}"
                            fi
                        else
                            echo -e " ${rw_hong}✗ 仍有冲突，请手动处理${rw_lv}"
                            echo "$_push_out2" | head -10
                            echo -e " ${rw_huang}手动步骤: git pull → 解决冲突 → git add → git commit → git push${rw_lv}"
                        fi
                    fi
                fi
            fi
        fi
        echo ""
        break_end
        ;;

      2)
        # ════════════════════════════════════════════
        # 2. 拉取更新
        # ════════════════════════════════════════════
        clear
        echo -e "${rw_cheng}━━━━━━━━━━━━  拉取更新  ━━━━━━━━━━━━${rw_lv}"
        echo ""
        if ! git rev-parse --is-inside-work-tree &>/dev/null; then
            echo -e " ${rw_hong}✗ 当前目录不是 git 仓库${rw_lv}"
            break_end; continue
        fi
        local _br _rem _ru
        _br=$(git symbolic-ref --short HEAD 2>/dev/null || echo "")
        _rem=$(git remote 2>/dev/null | head -1)
        _ru=$(git remote get-url "$_rem" 2>/dev/null)
        if [ -z "$_rem" ]; then
            echo -e " ${rw_hong}✗ 未配置远程仓库${rw_lv}"
            echo -e " ${rw_huang}提示: 返回菜单选 9 添加远程仓库${rw_lv}"
            break_end; continue
        fi
        echo -e " 分支: ${rw_huang}${_br:-未知}${rw_lv}"
        echo -e " 远程: ${rw_huang}${_rem}${rw_lv}  地址: ${rw_lv}${_ru}${rw_lv}"
        echo ""

        # ── 拉取前的状态分析 ──
        local _behind_cnt=0
        _behind_cnt=$(git rev-list --count HEAD..@{upstream} 2>/dev/null || echo 0)
        if [ "${_behind_cnt:-0}" -gt 0 ] 2>/dev/null; then
            echo -e " 待拉取: ${rw_huang}${_behind_cnt}${rw_lv} 个提交"
            echo -e " ${rw_cheng}── 待拉取提交 ──${rw_lv}"
            git log --oneline HEAD..@{upstream} 2>/dev/null | head -10 | sed 's/^/   /'
        else
            # 检查是否已经最新
            if git rev-parse --abbrev-ref --symbolic-full-name @{upstream} &>/dev/null; then
                echo -e " ${rw_lv}✓ 本地已与远程同步${rw_lv}"
                echo -e " ${rw_huang}（如需强制更新，请手动执行 git fetch && git reset --hard）${rw_lv}"
                break_end; continue
            fi
        fi
        echo ""

        # ── 执行拉取（带进度条动画）──
        echo -e " ${rw_cheng}── 正在拉取 ──${rw_lv}"
        local _pull_log="/tmp/riwi_pull_$$.log"
        # 后台执行 git pull，输出重定向到日志
        (
            git pull "$_rem" "${_br:-main}" > "$_pull_log" 2>&1
            echo "EXIT_CODE=$?" >> "$_pull_log"
        ) &
        local _pull_pid=$!

        # 进度条动画
        local _bar_width=30
        local _spin_idx=0
        local _spin_chars="|/-\\"
        local _elapsed=0
        local _max_wait=120  # 最大等待120秒
        while kill -0 "$_pull_pid" 2>/dev/null; do
            # 计算进度（基于已用时间，模拟进度条）
            local _progress=$(( _elapsed * _bar_width / _max_wait ))
            [ "$_progress" -gt "$_bar_width" ] && _progress=$_bar_width
            local _filled=""
            local _i=0
            while [ "$_i" -lt "$_progress" ]; do _filled+="█"; _i=$((_i+1)); done
            local _empty=""
            _i=0
            while [ "$_i" -lt $((_bar_width - _progress)) ]; do _empty+="░"; _i=$((_i+1)); done
            local _pct=$(( _elapsed * 100 / _max_wait ))
            [ "$_pct" -gt 99 ] && _pct=99
            local _spin_char="${_spin_chars:$_spin_idx:1}"
            _spin_idx=$(( (_spin_idx + 1) % 4 ))
            # 显示进度条（\r 回到行首覆盖）
            printf "\r ${rw_huang}[%s%s]${rw_lv} %3d%% %s 拉取中..." "$_filled" "$_empty" "$_pct" "$_spin_char"
            sleep 0.2
            _elapsed=$((_elapsed + 1))
            # 超时保护
            if [ "$_elapsed" -ge "$_max_wait" ]; then
                echo ""
                echo -e " ${rw_hong}✗ 拉取超时（${_max_wait}秒）${rw_lv}"
                kill "$_pull_pid" 2>/dev/null
                wait "$_pull_pid" 2>/dev/null
                rm -f "$_pull_log"
                echo -e " ${rw_huang}可能网络问题 → 选 13 切换镜像源${rw_lv}"
                break_end; continue
            fi
        done
        wait "$_pull_pid" 2>/dev/null

        # 完成进度条
        local _filled=""
        local _i=0
        while [ "$_i" -lt "$_bar_width" ]; do _filled+="█"; _i=$((_i+1)); done
        printf "\r ${rw_lv}[%s]${rw_lv} 100%% ✓${rw_lv}\n" "$_filled"

        # 解析拉取结果
        local _pull_rc
        _pull_rc=$(grep "^EXIT_CODE=" "$_pull_log" | cut -d= -f2)
        _pull_rc=${_pull_rc:-1}
        # 显示拉取输出（去掉末尾的EXIT_CODE行）
        echo ""
        echo -e " ${rw_cheng}── 拉取结果 ──${rw_lv}"
        grep -v "^EXIT_CODE=" "$_pull_log" | head -20 | sed 's/^/ /'
        rm -f "$_pull_log"

        if [ "$_pull_rc" = "0" ]; then
            echo ""
            echo -e " ${rw_lv}✓ 拉取成功${rw_lv}"
            # 显示本次拉取更新了什么
            local _new_logs
            _new_logs=$(git log --oneline -5 2>/dev/null)
            if [ -n "$_new_logs" ]; then
                echo -e " ${rw_cheng}── 最近5个提交 ──${rw_lv}"
                echo "$_new_logs" | sed 's/^/ /'
            fi
        else
            echo ""
            echo -e " ${rw_hong}✗ 拉取失败${rw_lv}"
            echo -e " ${rw_huang}可能原因:${rw_lv}"
            echo -e "   1. 有未提交的本地更改 → 先提交或 stash"
            echo -e "   2. 合并冲突 → 手动解决后提交"
            echo -e "   3. 网络问题 → 选 13 切换镜像源"
            echo ""
            read -e -p " 是否尝试 git pull --rebase？(y/N): " _retry < /dev/tty
            if [[ "$_retry" =~ ^[Yy]$ ]]; then
                echo -e " ${rw_cheng}── 重新拉取（rebase 模式）──${rw_lv}"
                local _pull_log2="/tmp/riwi_pull2_$$.log"
                (
                    git pull --rebase "$_rem" "${_br:-main}" > "$_pull_log2" 2>&1
                    echo "EXIT_CODE=$?" >> "$_pull_log2"
                ) &
                local _pull_pid2=$!
                _elapsed=0
                while kill -0 "$_pull_pid2" 2>/dev/null; do
                    local _progress=$(( _elapsed * _bar_width / 60 ))
                    [ "$_progress" -gt "$_bar_width" ] && _progress=$_bar_width
                    _filled=""
                    _i=0
                    while [ "$_i" -lt "$_progress" ]; do _filled+="█"; _i=$((_i+1)); done
                    _empty=""
                    _i=0
                    while [ "$_i" -lt $((_bar_width - _progress)) ]; do _empty+="░"; _i=$((_i+1)); done
                    local _pct=$(( _elapsed * 100 / 60 ))
                    [ "$_pct" -gt 99 ] && _pct=99
                    local _spin_char="${_spin_chars:$_spin_idx:1}"
                    _spin_idx=$(( (_spin_idx + 1) % 4 ))
                    printf "\r ${rw_huang}[%s%s]${rw_lv} %3d%% %s rebase中..." "$_filled" "$_empty" "$_pct" "$_spin_char"
                    sleep 0.2
                    _elapsed=$((_elapsed + 1))
                    if [ "$_elapsed" -ge 60 ]; then
                        kill "$_pull_pid2" 2>/dev/null
                        break
                    fi
                done
                wait "$_pull_pid2" 2>/dev/null
                _filled=""
                _i=0
                while [ "$_i" -lt "$_bar_width" ]; do _filled+="█"; _i=$((_i+1)); done
                printf "\r ${rw_lv}[%s]${rw_lv} 100%% ✓${rw_lv}\n" "$_filled"
                local _pull_rc2
                _pull_rc2=$(grep "^EXIT_CODE=" "$_pull_log2" | cut -d= -f2)
                _pull_rc2=${_pull_rc2:-1}
                grep -v "^EXIT_CODE=" "$_pull_log2" | head -15 | sed 's/^/ /'
                rm -f "$_pull_log2"
                if [ "$_pull_rc2" = "0" ]; then
                    echo -e " ${rw_lv}✓ rebase 拉取成功${rw_lv}"
                else
                    echo -e " ${rw_hong}✗ 仍失败，请手动处理冲突${rw_lv}"
                    echo -e " ${rw_huang}手动步骤: git status → 解决冲突 → git add → git rebase --continue${rw_lv}"
                fi
            fi
        fi
        echo ""
        break_end
        ;;

      3)
        # ════════════════════════════════════════════
        # 3. 仅推送
        # ════════════════════════════════════════════
        clear
        echo -e "${rw_cheng}━━━━━━━━━━━━  推送提交  ━━━━━━━━━━━━${rw_lv}"
        echo ""
        if ! git rev-parse --is-inside-work-tree &>/dev/null; then
            echo -e " ${rw_hong}✗ 当前目录不是 git 仓库${rw_lv}"
            break_end; continue
        fi
        local _br _rem _ru
        _br=$(git symbolic-ref --short HEAD 2>/dev/null || echo "main")
        _rem=$(git remote 2>/dev/null | head -1)
        _ru=$(git remote get-url "$_rem" 2>/dev/null)
        if [ -z "$_rem" ]; then
            echo -e " ${rw_hong}✗ 未配置远程仓库${rw_lv}"
            echo -e " ${rw_huang}提示: 返回菜单选 9 添加远程仓库${rw_lv}"
            break_end; continue
        fi

        # 显示待推送的提交
        local _ahead_cnt
        _ahead_cnt=$(git rev-list --count @{upstream}..HEAD 2>/dev/null || echo 0)
        echo -e " 分支: ${rw_huang}${_br}${rw_lv}  远程: ${rw_huang}${_rem}${rw_lv}"
        echo -e " 地址: ${rw_lv}${_ru}${rw_lv}"
        if [ "$_ahead_cnt" -gt 0 ] 2>/dev/null; then
            echo -e " 待推送: ${rw_huang}${_ahead_cnt}${rw_lv} 个提交"
            echo ""
            echo -e " ${rw_cheng}── 待推送提交 ──${rw_lv}"
            git log --oneline @{upstream}..HEAD 2>/dev/null | head -10 | sed 's/^/   /'
        else
            echo -e " ${rw_lv}✓ 没有待推送的提交${rw_lv}"
        fi
        echo ""
        echo -e " ${rw_cheng}── 执行推送 ──${rw_lv}"
        # 记录推送前状态用于事后校验
        local _remote_sha_before3
        _remote_sha_before3=$(git ls-remote "$_rem" "$_br" 2>/dev/null | awk '{print $1}')
        local _local_sha3
        _local_sha3=$(git rev-parse HEAD 2>/dev/null)
        local _push_out3 _push_rc3
        _push_out3=$(git push "$_rem" "$_br" 2>&1)
        _push_rc3=$?
        if [ $_push_rc3 -eq 0 ]; then
            # 二次校验远程是否真的更新
            local _remote_sha_after3
            _remote_sha_after3=$(git ls-remote "$_rem" "$_br" 2>/dev/null | awk '{print $1}')
            if [ "$_remote_sha_after3" = "$_local_sha3" ]; then
                echo ""
                echo -e " ${rw_lv}✓ 推送成功${rw_lv}"
                echo -e " 远程已更新: ${rw_lv}${_remote_sha_after3:0:8}${rw_lv}"
            else
                echo ""
                echo -e " ${rw_huang}⚠ push 返回成功，但远程未更新${rw_lv}"
                echo -e "   推送前: ${_remote_sha_before3:0:8}"
                echo -e "   推送后: ${_remote_sha_after3:0:8}"
                echo -e "   期望值: ${_local_sha3:0:8} (本地HEAD)"
                echo -e " ${rw_huang}请检查是否推送到了正确的分支${rw_lv}"
            fi
        else
            echo ""
            echo -e " ${rw_hong}✗ 推送失败 (退出码: $_push_rc3)${rw_lv}"
            echo -e " ${rw_cheng}── 完整错误输出 ──${rw_lv}"
            echo "$_push_out3" | head -15
            echo -e " ${rw_cheng}────────────────${rw_lv}"
            echo -e " ${rw_huang}可能原因:${rw_lv}"
            echo -e "   1. 本地落后于远程 → 选 2 拉取更新"
            echo -e "   2. 权限问题 → 检查 SSH密钥/Token"
            echo -e "   3. 网络问题 → 选 13 切换镜像源"
            echo ""
            read -e -p " 是否先拉取再推送？(y/N): " _retry < /dev/tty
            if [[ "$_retry" =~ ^[Yy]$ ]]; then
                git pull --rebase "$_rem" "$_br" 2>&1 | head -10
                _push_out3=$(git push "$_rem" "$_br" 2>&1)
                _push_rc3=$?
                if [ $_push_rc3 -eq 0 ]; then
                    local _remote_sha_after4
                    _remote_sha_after4=$(git ls-remote "$_rem" "$_br" 2>/dev/null | awk '{print $1}')
                    if [ "$_remote_sha_after4" = "$(git rev-parse HEAD)" ]; then
                        echo -e " ${rw_lv}✓ 拉取并推送成功${rw_lv}"
                    else
                        echo -e " ${rw_huang}⚠ push 返回成功但远程未更新，请手动检查${rw_lv}"
                    fi
                else
                    echo -e " ${rw_hong}✗ 仍有冲突，请手动处理${rw_lv}"
                    echo "$_push_out3" | head -10
                fi
            fi
        fi
        echo ""
        break_end
        ;;

      4)
        # ════════════════════════════════════════════
        # 4. 查看状态
        # ════════════════════════════════════════════
        clear
        echo -e "${rw_cheng}━━━━━━━━━━━━  Git 状态  ━━━━━━━━━━━━${rw_lv}"
        echo ""
        if ! git rev-parse --is-inside-work-tree &>/dev/null; then
            echo -e " ${rw_hong}✗ 当前目录不是 git 仓库${rw_lv}"
            break_end; continue
        fi
        translate_git_status
        echo ""
        break_end
        ;;

      5)
        # ════════════════════════════════════════════
        # 5. 提交日志
        # ════════════════════════════════════════════
        clear
        echo -e "${rw_cheng}━━━━━━━━━━━━  提交日志  ━━━━━━━━━━━━${rw_lv}"
        echo ""
        if ! git rev-parse --is-inside-work-tree &>/dev/null; then
            echo -e " ${rw_hong}✗ 当前目录不是 git 仓库${rw_lv}"
            break_end; continue
        fi
        echo -e " ${rw_cheng}── 最近 20 条提交 ──${rw_lv}"
        echo ""
        git log --oneline --graph --decorate -20 2>/dev/null | sed 's/HEAD/当前位置/g' || echo -e " ${rw_huang}无提交记录${rw_lv}"
        echo ""
        break_end
        ;;

      6)
        # ════════════════════════════════════════════
        # 6. 查看文件差异
        # ════════════════════════════════════════════
        clear
        echo -e "${rw_cheng}━━━━━━━━━━━━  文件差异  ━━━━━━━━━━━━${rw_lv}"
        echo ""
        if ! git rev-parse --is-inside-work-tree &>/dev/null; then
            echo -e " ${rw_hong}✗ 当前目录不是 git 仓库${rw_lv}"
            break_end; continue
        fi
        echo -e " ${rw_huang}1${rw_lv}  查看未暂存的更改"
        echo -e " ${rw_huang}2${rw_lv}  查看已暂存的更改"
        echo -e " ${rw_huang}3${rw_lv}  查看与远程的差异"
        echo -e " ${rw_huang}4${rw_lv}  指定文件查看差异"
        echo -e " ${rw_huang}0${rw_lv}  返回"
        echo ""
        read -e -p " 请选择: " _diff_choice < /dev/tty
        case $_diff_choice in
            1)
                echo ""
                local _diff_out1
                _diff_out1=$(git diff 2>&1)
                if [ -z "$_diff_out1" ]; then
                    echo -e " ${rw_lv}✓ 没有未暂存的更改${rw_lv}"
                else
                    echo "$_diff_out1" | head -100
                    local _lines1=$(echo "$_diff_out1" | wc -l)
                    [ "$_lines1" -gt 100 ] && echo -e " ${rw_huang}...（共 $_lines1 行，仅显示前100行）${rw_lv}"
                fi
                ;;
            2)
                echo ""
                local _diff_out2
                _diff_out2=$(git diff --cached 2>&1)
                if [ -z "$_diff_out2" ]; then
                    echo -e " ${rw_lv}✓ 没有已暂存的更改${rw_lv}"
                else
                    echo "$_diff_out2" | head -100
                    local _lines2=$(echo "$_diff_out2" | wc -l)
                    [ "$_lines2" -gt 100 ] && echo -e " ${rw_huang}...（共 $_lines2 行，仅显示前100行）${rw_lv}"
                fi
                ;;
            3)
                local _rem=$(git remote 2>/dev/null | head -1)
                local _br=$(git symbolic-ref --short HEAD 2>/dev/null || echo "main")
                if [ -z "$_rem" ]; then
                    echo -e " ${rw_hong}✗ 未配置远程仓库${rw_lv}"
                    echo -e " ${rw_huang}提示: 返回菜单选 9 添加远程仓库${rw_lv}"
                else
                    # 检查远程引用是否存在（origin/main 是否有效）
                    if ! git rev-parse --verify "${_rem}/${_br}" &>/dev/null; then
                        echo -e " ${rw_huang}⚠ 远程引用 ${_rem}/${_br} 不存在，正在获取...${rw_lv}"
                        echo ""
                        # 后台 fetch + 进度条
                        local _fetch_log="/tmp/riwi_diff_fetch_$$.log"
                        (
                            git fetch "$_rem" "$_br" > "$_fetch_log" 2>&1
                            echo "EXIT_CODE=$?" >> "$_fetch_log"
                        ) &
                        local _fetch_pid=$!
                        local _bar_width=30 _spin_idx=0 _spin_chars="|/-\\" _elapsed=0 _max_wait=60
                        while kill -0 "$_fetch_pid" 2>/dev/null; do
                            local _progress=$(( _elapsed * _bar_width / _max_wait ))
                            [ "$_progress" -gt "$_bar_width" ] && _progress=$_bar_width
                            local _filled="" _i=0
                            while [ "$_i" -lt "$_progress" ]; do _filled+="█"; _i=$((_i+1)); done
                            local _empty="" ; _i=0
                            while [ "$_i" -lt $((_bar_width - _progress)) ]; do _empty+="░"; _i=$((_i+1)); done
                            local _pct=$(( _elapsed * 100 / _max_wait ))
                            [ "$_pct" -gt 99 ] && _pct=99
                            local _spin_char="${_spin_chars:$_spin_idx:1}"
                            _spin_idx=$(( (_spin_idx + 1) % 4 ))
                            printf "\r ${rw_huang}[%s%s]${rw_lv} %3d%% %s 获取中..." "$_filled" "$_empty" "$_pct" "$_spin_char"
                            sleep 0.2
                            _elapsed=$((_elapsed + 1))
                            if [ "$_elapsed" -ge "$_max_wait" ]; then
                                kill "$_fetch_pid" 2>/dev/null
                                break
                            fi
                        done
                        wait "$_fetch_pid" 2>/dev/null
                        _filled="" ; _i=0
                        while [ "$_i" -lt "$_bar_width" ]; do _filled+="█"; _i=$((_i+1)); done
                        printf "\r ${rw_lv}[%s]${rw_lv} 100%% ✓${rw_lv}\n" "$_filled"
                        local _fetch_rc
                        _fetch_rc=$(grep "^EXIT_CODE=" "$_fetch_log" | cut -d= -f2)
                        rm -f "$_fetch_log"
                        if [ "$_fetch_rc" != "0" ]; then
                            echo -e " ${rw_hong}✗ 获取远程信息失败${rw_lv}"
                            echo -e " ${rw_huang}可能网络问题 → 选 13 切换镜像源${rw_lv}"
                        fi
                    fi
                    # 再次校验引用是否存在
                    if git rev-parse --verify "${_rem}/${_br}" &>/dev/null; then
                        echo ""
                        local _diff_out3
                        _diff_out3=$(git diff "${_rem}/${_br}" HEAD 2>&1)
                        if [ -z "$_diff_out3" ]; then
                            echo -e " ${rw_lv}✓ 本地与远程无差异${rw_lv}"
                        else
                            echo "$_diff_out3" | head -100
                            local _lines3=$(echo "$_diff_out3" | wc -l)
                            [ "$_lines3" -gt 100 ] && echo -e " ${rw_huang}...（共 $_lines3 行，仅显示前100行）${rw_lv}"
                        fi
                    else
                        echo -e " ${rw_hong}✗ 仍无法获取远程引用 ${_rem}/${_br}${rw_lv}"
                        echo -e " ${rw_huang}请手动执行: git fetch ${_rem}${rw_lv}"
                    fi
                fi
                ;;
            4)
                read -e -p " 文件路径（0返回上一级）: " _file < /dev/tty
                [ "$_file" = "0" ] && continue
                if [ -n "$_file" ]; then
                    if [ -e "$_file" ]; then
                        echo ""
                        local _diff_out4
                        _diff_out4=$(git diff "$_file" 2>&1)
                        if [ -z "$_diff_out4" ]; then
                            echo -e " ${rw_lv}✓ 该文件没有未暂存的更改${rw_lv}"
                        else
                            echo "$_diff_out4" | head -100
                        fi
                    else
                        echo -e " ${rw_hong}✗ 文件不存在: $_file${rw_lv}"
                    fi
                fi
                ;;
            0) continue ;;
            *) echo " 无效的输入!" ;;
        esac
        echo ""
        break_end
        ;;

      7)
        # ════════════════════════════════════════════
        # 7. 撤销上次提交（保留更改）
        # ════════════════════════════════════════════
        clear
        echo -e "${rw_cheng}━━━━━━━━━━━━  撤销上次提交  ━━━━━━━━━━━━${rw_lv}"
        echo ""
        if ! git rev-parse --is-inside-work-tree &>/dev/null; then
            echo -e " ${rw_hong}✗ 当前目录不是 git 仓库${rw_lv}"
            break_end; continue
        fi

        # 显示最近一条提交
        echo -e " ${rw_cheng}最近一条提交:${rw_lv}"
        git log -1 --oneline 2>/dev/null | sed 's/^/   /'
        echo ""
        echo -e " ${rw_huang}撤销方式:${rw_lv}"
        echo -e "   ${rw_huang}1${rw_lv} 软撤销（保留更改在暂存区，推荐）"
        echo -e "   ${rw_huang}2${rw_lv} 混合撤销（保留更改在工作区）"
        echo -e "   ${rw_huang}3${rw_lv} 硬撤销（${rw_hong}丢弃所有更改，不可恢复！${rw_lv}）"
        echo -e "   ${rw_huang}0${rw_lv} 取消"
        echo ""
        read -e -p " 请选择: " _reset_choice < /dev/tty
        case $_reset_choice in
            1) git reset --soft HEAD~1 2>&1 && echo -e " ${rw_lv}✓ 已软撤销，更改保留在暂存区${rw_lv}" ;;
            2) git reset --mixed HEAD~1 2>&1 && echo -e " ${rw_lv}✓ 已混合撤销，更改保留在工作区${rw_lv}" ;;
            3)
                read -e -p " $(echo -e "${rw_hong}确认硬撤销？所有更改将丢失！(输入 YES): ${rw_lv}")" _hard_confirm < /dev/tty
                if [ "$_hard_confirm" = "YES" ]; then
                    git reset --hard HEAD~1 2>&1 && echo -e " ${rw_lv}✓ 已硬撤销${rw_lv}"
                else
                    echo -e " ${rw_huang}已取消${rw_lv}"
                fi
                ;;
            0) continue ;;
        esac
        echo ""
        break_end
        ;;

      8)
        # ════════════════════════════════════════════
        # 8. 回退到历史版本
        # ════════════════════════════════════════════
        clear
        echo -e "${rw_cheng}━━━━━━━━━━━━  回退到历史版本  ━━━━━━━━━━━━${rw_lv}"
        echo ""
        if ! git rev-parse --is-inside-work-tree &>/dev/null; then
            echo -e " ${rw_hong}✗ 当前目录不是 git 仓库${rw_lv}"
            break_end; continue
        fi

        # 检查是否有远程仓库
        _has_remote=false
        if git remote | grep -q . 2>/dev/null; then
            _has_remote=true
        fi

        echo -e " ${rw_cheng}最近 20 条提交:${rw_lv}"
        echo ""
        git log --oneline -20 2>/dev/null | nl | sed 's/^/   /'
        echo ""
        echo -e " ${rw_huang}提示：左侧序号仅用于显示，请输入右侧的提交ID（哈希值）。${rw_lv}"
        echo -e " ${rw_huang}      提交ID就是每行空格后那串字母数字组合（如 a1b2c3d）。${rw_lv}"
        echo ""
        read -e -p " 输入要回退的提交ID（前6位即可，0返回上一级）: " _commit_id < /dev/tty
        [ "$_commit_id" = "0" ] && continue
        [ -z "$_commit_id" ] && continue

        # 验证提交ID是否有效
        if ! git rev-parse --verify "${_commit_id}^{commit}" &>/dev/null; then
            echo ""
            echo -e " ${rw_hong}✗ 提交ID「$_commit_id」不存在，请检查后重试${rw_lv}"
            break_end; continue
        fi

        # 显示该提交的详细信息
        _commit_msg=$(git log -1 --format="%s" "$_commit_id" 2>/dev/null)
        _commit_date=$(git log -1 --format="%cd" --date=format:"%Y-%m-%d %H:%M" "$_commit_id" 2>/dev/null)
        _commit_author=$(git log -1 --format="%an" "$_commit_id" 2>/dev/null)
        echo ""
        echo -e " ${rw_lv}┌──────────────────────────────────────────┐${rw_lv}"
        echo -e " ${rw_lv}│ 目标提交信息：${rw_lv}"
        echo -e " ${rw_lv}│   ID:     ${_commit_id}${rw_lv}"
        echo -e " ${rw_lv}│   说明:   ${_commit_msg}${rw_lv}"
        echo -e " ${rw_lv}│   时间:   ${_commit_date}${rw_lv}"
        echo -e " ${rw_lv}│   作者:   ${_commit_author}${rw_lv}"
        echo -e " ${rw_lv}└──────────────────────────────────────────┘${rw_lv}"
        echo ""

        echo -e " ${rw_cheng}回退方式:${rw_lv}"
        echo ""
        echo -e "   ${rw_huang}1${rw_lv} 软回退（soft reset）"
        echo -e "      ${rw_lv}HEAD 移到目标提交，但代码文件不变，差异保留在暂存区${rw_lv}"
        echo -e "      ${rw_huang}适用：想重新整理提交历史，但不想丢失代码改动${rw_lv}"
        echo ""
        echo -e "   ${rw_huang}2${rw_lv} 硬回退（hard reset）${rw_hong} ⚠️ 危险！${rw_lv}"
        echo -e "      ${rw_hong}HEAD 移到目标提交，代码文件也一起回到那个版本${rw_lv}"
        echo -e "      ${rw_hong}目标提交之后的所有改动将被永久丢弃！${rw_lv}"
        echo -e "      ${rw_huang}适用：确定要完全回到历史版本，不要之后的任何改动${rw_lv}"
        echo ""
        echo -e "   ${rw_huang}0${rw_lv} 取消"
        echo ""
        read -e -p " 请选择: " _reset_choice < /dev/tty
        _reset_done=false
        case $_reset_choice in
            1)
                git reset --soft "$_commit_id" 2>&1
                if [ $? -eq 0 ]; then
                    echo -e " ${rw_lv}✓ 已软回退到 ${_commit_id}${rw_lv}"
                    echo -e " ${rw_huang}提示：代码文件未变，差异已保留在暂存区，可重新提交${rw_lv}"
                    _reset_done=true
                else
                    echo -e " ${rw_hong}✗ 软回退失败${rw_lv}"
                fi
                ;;
            2)
                echo ""
                echo -e " ${rw_hong}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${rw_lv}"
                echo -e " ${rw_hong}⚠️  硬回退将永久丢弃以下改动：${rw_lv}"
                git log --oneline "${_commit_id}..HEAD" 2>/dev/null | head -20 | sed 's/^/   /'
                _lost_count=$(git rev-list --count "${_commit_id}..HEAD" 2>/dev/null)
                echo -e " ${rw_hong}   共 ${_lost_count} 个提交将被丢弃！${rw_lv}"
                echo -e " ${rw_hong}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${rw_lv}"
                echo ""
                read -e -p " $(echo -e "${rw_hong}确认硬回退？输入 YES 确认 / 其他取消: ${rw_lv}")" _confirm < /dev/tty
                if [ "$_confirm" = "YES" ]; then
                    git reset --hard "$_commit_id" 2>&1
                    if [ $? -eq 0 ]; then
                        echo -e " ${rw_lv}✓ 已硬回退到 ${_commit_id}${rw_lv}"
                        echo -e " ${rw_huang}代码文件已回到该版本，之后的改动已丢弃${rw_lv}"
                        _reset_done=true
                    else
                        echo -e " ${rw_hong}✗ 硬回退失败${rw_lv}"
                    fi
                else
                    echo -e " ${rw_huang}已取消，未做任何更改${rw_lv}"
                fi
                ;;
            0) continue ;;
        esac

        # 如果回退成功且有远程仓库，提示是否强制推送
        if [ "$_reset_done" = "true" ] && [ "$_has_remote" = "true" ]; then
            echo ""
            echo -e " ${rw_cheng}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${rw_lv}"
            echo -e " ${rw_cheng}当前已回退本地仓库，但远程仓库还是旧的！${rw_lv}"
            echo -e " ${rw_cheng}需要强制推送才能让远程也回退到同一版本。${rw_lv}"
            echo -e " ${rw_cheng}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${rw_lv}"
            echo ""
            echo -e "   ${rw_huang}1${rw_lv} 强制推送到远程（覆盖远程历史）${rw_hong} ⚠️${rw_lv}"
            echo -e "   ${rw_huang}2${rw_lv} 仅本地回退，不推送（稍后手动推送）"
            echo -e "   ${rw_huang}0${rw_lv} 跳过"
            echo ""
            read -e -p " 请选择: " _push_choice < /dev/tty
            case $_push_choice in
                1)
                    # 获取当前分支名；detached HEAD 时 --abbrev-ref 返回 "HEAD"
                    _cur_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
                    if [ "$_cur_branch" = "HEAD" ] || [ -z "$_cur_branch" ]; then
                        # detached HEAD 状态，尝试从远程跟踪分支推断
                        _cur_branch=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null | sed 's|.*/||')
                        if [ -z "$_cur_branch" ]; then
                            # 还是拿不到，列出本地分支让用户选
                            echo -e " ${rw_huang}当前处于 detached HEAD 状态，无法自动判断分支。${rw_lv}"
                            echo -e " ${rw_cheng}本地分支列表:${rw_lv}"
                            git branch 2>/dev/null | sed 's/^/   /'
                            echo ""
                            read -e -p " 请输入要推送的分支名: " _cur_branch < /dev/tty
                            [ -z "$_cur_branch" ] && _cur_branch="main"
                        else
                            echo -e " ${rw_huang}检测到远程跟踪分支: ${_cur_branch}${rw_lv}"
                        fi
                    fi
                    echo -e " ${rw_lv}正在强制推送到远程分支 ${_cur_branch} ...${rw_lv}"
                    git push --force-with-lease origin "$_cur_branch" 2>&1
                    _push_rc=$?
                    if [ $_push_rc -eq 0 ]; then
                        echo -e " ${rw_lv}✓ 强制推送成功，远程已同步回退${rw_lv}"
                    else
                        echo -e " ${rw_hong}✗ 推送失败（exit code: $_push_rc）${rw_lv}"
                        echo -e " ${rw_huang}可能是远程有新提交或分支名不匹配${rw_lv}"
                        echo -e " ${rw_huang}如需强制覆盖，可手动执行:${rw_lv}"
                        echo -e "   ${rw_lv}git push --force origin ${_cur_branch}${rw_lv}"
                    fi
                    ;;
                2)
                    echo -e " ${rw_huang}已跳过推送。本地已回退，远程未变。${rw_lv}"
                    echo -e " ${rw_huang}稍后可用 git push --force 手动推送${rw_lv}"
                    ;;
                0) ;;
            esac
        elif [ "$_reset_done" = "true" ] && [ "$_has_remote" = "false" ]; then
            echo ""
            echo -e " ${rw_huang}提示：当前仓库没有远程，仅本地回退已完成。${rw_lv}"
        fi
        echo ""
        break_end
        ;;

      9)
        # ════════════════════════════════════════════
        # 9. 远程仓库管理
        # ════════════════════════════════════════════
        _git_remote_manager
        ;;

      10)
        # ════════════════════════════════════════════
        # 10. 初始化新仓库
        # ════════════════════════════════════════════
        clear
        echo -e "${rw_cheng}━━━━━━━━━━━━  初始化新仓库  ━━━━━━━━━━━━${rw_lv}"
        echo ""
        read -e -p " 目录路径（回车=当前目录，0返回上一级）: " _dir < /dev/tty
        [ "$_dir" = "0" ] && continue
        _dir="${_dir:-.}"
        cd "$_dir" 2>/dev/null || { echo -e " ${rw_hong}✗ 目录不存在${rw_lv}"; break_end; continue; }

        git init 2>&1

        # 自动创建 .gitignore
        if [ ! -f ".gitignore" ]; then
            cat > .gitignore << 'GIEOF'
.DS_Store
*.log
node_modules/
__pycache__/
*.pyc
.env
.idea/
.vscode/
GIEOF
            echo -e " ${rw_lv}✓ 已创建 .gitignore${rw_lv}"
        fi

        # 询问是否关联远程
        echo ""
        read -e -p " 是否关联远程仓库？(y/N): " _link_remote < /dev/tty
        if [[ "$_link_remote" =~ ^[Yy]$ ]]; then
            echo -e " ${rw_huang}URL 示例:${rw_lv}"
            echo -e "   https://github.com/user/repo.git"
            echo -e "   git@github.com:user/repo.git"
            read -e -p " 远程URL: " _url < /dev/tty
            if [ -n "$_url" ]; then
                git remote add origin "$_url" 2>&1 && \
                    echo -e " ${rw_lv}✓ 已关联远程: $_url${rw_lv}" || \
                    echo -e " ${rw_hong}✗ 关联失败（可能已存在）${rw_lv}"
                # 首次提交并推送
                git add -A 2>/dev/null
                GIT_EDITOR=true git commit -m "Initial commit" 2>/dev/null
                read -e -p " 是否推送初始提交到远程？(y/N): " _push_init < /dev/tty
                if [[ "$_push_init" =~ ^[Yy]$ ]]; then
                    git push -u origin main 2>/dev/null || \
                    git push -u origin master 2>/dev/null || \
                    echo -e " ${rw_hong}✗ 推送失败${rw_lv}"
                fi
            fi
        fi

        echo ""
        echo -e " ${rw_lv}✓ 仓库已初始化: $(pwd)${rw_lv}"
        echo ""
        break_end
        ;;

      11)
        # ════════════════════════════════════════════
        # 11. 克隆仓库
        # ════════════════════════════════════════════
        clear
        echo -e "${rw_cheng}━━━━━━━━━━━━  克隆仓库  ━━━━━━━━━━━━${rw_lv}"
        echo ""
        echo -e " ${rw_huang}URL 示例:${rw_lv}"
        echo -e "   ${rw_lv}https://github.com/riwi002/mybox.git${rw_lv}"
        echo -e "   git@github.com:riwi002/mybox.git"
        echo -e " ${rw_huang}回车=克隆 riwi002/mybox 到当前目录${rw_lv}"
        echo ""
        read -e -p " 仓库URL（0返回上一级）: " _url < /dev/tty
        [ "$_url" = "0" ] && continue
        [ -z "$_url" ] && _url="https://github.com/riwi002/mybox.git"
        read -e -p " 目标目录（回车=仓库名，0返回上一级）: " _dir < /dev/tty
        [ "$_dir" = "0" ] && continue

        echo ""
        if [ -n "$_dir" ]; then
            git clone "$_url" "$_dir" 2>&1
        else
            git clone "$_url" 2>&1
        fi
        if [ $? -eq 0 ]; then
            echo -e " ${rw_lv}✓ 克隆成功${rw_lv}"
        else
            echo -e " ${rw_hong}✗ 克隆失败${rw_lv}"
            echo -e " ${rw_huang}可能原因:${rw_lv}"
            echo -e "   1. URL错误或仓库不存在"
            echo -e "   2. 网络问题 → 选 13 切换镜像源"
            echo -e "   3. 权限不足 → 检查 SSH密钥/Token"
        fi
        echo ""
        break_end
        ;;

      12)
        # ════════════════════════════════════════════
        # 12. 分支管理
        # ════════════════════════════════════════════
        _git_branch_manager
        ;;

      13)
        switch_git_mirror
        ;;

      14)
        git_hooks_deploy
        ;;

      0)
        clear; return
        ;;

      *)
        echo -e " ${rw_hong}无效的输入！${rw_lv}"
        sleep 1
        ;;
    esac
  done
}


# ================================================================
# 远程仓库管理子菜单
# ================================================================
_git_remote_manager() {
  while true; do
    clear
    echo -e "${rw_cheng}━━━━━━━━━━━━  远程仓库管理  ━━━━━━━━━━━━${rw_lv}"
    echo ""

    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        echo -e " ${rw_hong}✗ 当前目录不是 git 仓库${rw_lv}"
        break_end; return
    fi

    # 列出远程仓库
    local _remotes
    _remotes=$(git remote 2>/dev/null)
    if [ -n "$_remotes" ]; then
        echo -e " ${rw_cheng}── 已配置的远程仓库 ──${rw_lv}"
        echo ""
        local _idx=1
        _GIT_REMOTE_NAMES=()
        while IFS= read -r _rname; do
            local _rurl
            _rurl=$(git remote get-url "$_rname" 2>/dev/null)
            # 提取友好名
            local _short
            _short=$(echo "$_rurl" | sed 's|\.git$||; s|.*[:/]||; s|^.*@.*:||' 2>/dev/null)
            echo -e "  ${rw_huang}${_idx}.${rw_lv} ${rw_huang}${_rname}${rw_lv}  ${rw_lv}${_short}${rw_lv}"
            echo -e "     ${rw_huang}${_rurl}${rw_lv}"
            _GIT_REMOTE_NAMES+=("$_rname")
            _idx=$((_idx + 1))
        done <<< "$_remotes"
        echo ""
    else
        echo -e " ${rw_huang}未配置任何远程仓库${rw_lv}"
        echo ""
    fi

    echo -e " ${rw_cheng}────────────────────────${rw_lv}"
    echo -e "  ${rw_huang}1${rw_lv}  添加远程仓库"
    echo -e "  ${rw_huang}2${rw_lv}  移除远程仓库"
    echo -e "  ${rw_huang}3${rw_lv}  修改远程URL"
    echo -e "  ${rw_huang}4${rw_lv}  重命名远程"
    echo -e " ${rw_cheng}────────────────────────${rw_lv}"
    echo -e "  ${rw_huang}0${rw_lv}  返回上级菜单"
    echo -e " ${rw_cheng}────────────────────────${rw_lv}"
    read -e -p " 请选择: " _rm_choice < /dev/tty
    _rm_choice=${_rm_choice:-0}

    case $_rm_choice in
      1)
        echo ""
        read -e -p " 远程名称（默认 origin，0返回上一级）: " _name < /dev/tty
        [ "$_name" = "0" ] && continue
        _name="${_name:-origin}"
        echo -e " ${rw_huang}URL 示例:${rw_lv}"
        echo -e "   https://github.com/user/repo.git"
        echo -e "   git@github.com:user/repo.git"
        read -e -p " 远程URL（0返回上一级）: " _url < /dev/tty
        [ "$_url" = "0" ] && continue
        if [ -z "$_url" ]; then
            echo -e " ${rw_hong}URL不能为空${rw_lv}"
            sleep 1; continue
        fi
        git remote add "$_name" "$_url" 2>&1 && \
            echo -e " ${rw_lv}✓ 已添加远程: $_name${rw_lv}" || \
            echo -e " ${rw_hong}✗ 添加失败（可能已存在）${rw_lv}"
        sleep 1
        ;;
      2)
        if [ -z "$_remotes" ]; then
            echo -e " ${rw_huang}没有可移除的远程仓库${rw_lv}"
            sleep 1; continue
        fi
        echo ""
        read -e -p " 输入要移除的远程编号（0返回上一级）: " _idx < /dev/tty
        [ "$_idx" = "0" ] && continue
        if [[ "$_idx" =~ ^[0-9]+$ ]] && [ "$_idx" -ge 1 ] && [ "$_idx" -le ${#_GIT_REMOTE_NAMES[@]} ]; then
            local _target="${_GIT_REMOTE_NAMES[$((_idx - 1))]}"
            read -e -p " 确认移除 ${_target}？(y/N): " _confirm < /dev/tty
            if [[ "$_confirm" =~ ^[Yy]$ ]]; then
                git remote remove "$_target" 2>&1 && \
                    echo -e " ${rw_lv}✓ 已移除: $_target${rw_lv}"
            fi
        else
            echo -e " ${rw_hong}无效编号${rw_lv}"
        fi
        sleep 1
        ;;
      3)
        if [ -z "$_remotes" ]; then
            echo -e " ${rw_huang}没有可修改的远程仓库${rw_lv}"
            sleep 1; continue
        fi
        echo ""
        read -e -p " 输入要修改的远程编号（0返回上一级）: " _idx < /dev/tty
        [ "$_idx" = "0" ] && continue
        if [[ "$_idx" =~ ^[0-9]+$ ]] && [ "$_idx" -ge 1 ] && [ "$_idx" -le ${#_GIT_REMOTE_NAMES[@]} ]; then
            local _target="${_GIT_REMOTE_NAMES[$((_idx - 1))]}"
            echo -e " 当前URL: ${rw_huang}$(git remote get-url "$_target" 2>/dev/null)${rw_lv}"
            read -e -p " 新URL（0返回上一级）: " _new_url < /dev/tty
            [ "$_new_url" = "0" ] && continue
            if [ -n "$_new_url" ]; then
                git remote set-url "$_target" "$_new_url" 2>&1 && \
                    echo -e " ${rw_lv}✓ 已修改 ${_target} 的URL${rw_lv}"
            fi
        else
            echo -e " ${rw_hong}无效编号${rw_lv}"
        fi
        sleep 1
        ;;
      4)
        if [ -z "$_remotes" ]; then
            echo -e " ${rw_huang}没有可重命名的远程仓库${rw_lv}"
            sleep 1; continue
        fi
        echo ""
        read -e -p " 输入要重命名的远程编号（0返回上一级）: " _idx < /dev/tty
        [ "$_idx" = "0" ] && continue
        if [[ "$_idx" =~ ^[0-9]+$ ]] && [ "$_idx" -ge 1 ] && [ "$_idx" -le ${#_GIT_REMOTE_NAMES[@]} ]; then
            local _old="${_GIT_REMOTE_NAMES[$((_idx - 1))]}"
            read -e -p " 新名称（0返回上一级）: " _new < /dev/tty
            [ "$_new" = "0" ] && continue
            if [ -n "$_new" ]; then
                git remote rename "$_old" "$_new" 2>&1 && \
                    echo -e " ${rw_lv}✓ 已重命名: $_old → $_new${rw_lv}"
            fi
        else
            echo -e " ${rw_hong}无效编号${rw_lv}"
        fi
        sleep 1
        ;;
      0) break ;;
    esac
  done
}


# ================================================================
# 分支管理子菜单
# ================================================================
_git_branch_manager() {
  while true; do
    clear
    echo -e "${rw_cheng}━━━━━━━━━━━━  分支管理  ━━━━━━━━━━━━${rw_lv}"
    echo ""

    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        echo -e " ${rw_hong}✗ 当前目录不是 git 仓库${rw_lv}"
        break_end; return
    fi

    # 当前分支
    local _cur_br
    _cur_br=$(git symbolic-ref --short HEAD 2>/dev/null || echo "?")
    echo -e " 当前分支: ${rw_huang}${_cur_br}${rw_lv}"
    echo ""

    # 列出本地分支
    echo -e " ${rw_cheng}── 本地分支 ──${rw_lv}"
    local _idx=1
    _GIT_BRANCH_NAMES=()
    while IFS= read -r _bline; do
        local _bname="${_bline//\*/}"
        _bname="$(echo "$_bname" | xargs)"
        local _mark=""
        [[ "$_bline" == *\** ]] && _mark="${rw_lv} ← 当前${rw_lv}"
        echo -e "  ${rw_huang}${_idx}.${rw_lv} ${_bname}${_mark}"
        _GIT_BRANCH_NAMES+=("$_bname")
        _idx=$((_idx + 1))
    done < <(git branch 2>/dev/null)

    # 远程分支
    local _remote_brs
    _remote_brs=$(git branch -r 2>/dev/null | head -10)
    if [ -n "$_remote_brs" ]; then
        echo ""
        echo -e " ${rw_cheng}── 远程分支（前10个）──${rw_lv}"
        echo "$_remote_brs" | sed 's/^/   /'
    fi

    echo ""
    echo -e " ${rw_cheng}────────────────────────${rw_lv}"
    echo -e "  ${rw_huang}1${rw_lv}  切换到已有分支      ${rw_huang}2${rw_lv}  创建新分支"
    echo -e "  ${rw_huang}3${rw_lv}  删除分支            ${rw_huang}4${rw_lv}  合并分支"
    echo -e "  ${rw_huang}5${rw_lv}  推送新分支到远程"
    echo -e " ${rw_cheng}────────────────────────${rw_lv}"
    echo -e "  ${rw_huang}0${rw_lv}  返回上级菜单"
    echo -e " ${rw_cheng}────────────────────────${rw_lv}"
    read -e -p " 请选择: " _bm_choice < /dev/tty
    _bm_choice=${_bm_choice:-0}

    case $_bm_choice in
      1)
        echo ""
        read -e -p " 输入分支编号切换（0返回上一级）: " _idx < /dev/tty
        [ "$_idx" = "0" ] && continue
        if [[ "$_idx" =~ ^[0-9]+$ ]] && [ "$_idx" -ge 1 ] && [ "$_idx" -le ${#_GIT_BRANCH_NAMES[@]} ]; then
            local _target="${_GIT_BRANCH_NAMES[$((_idx - 1))]}"
            git checkout "$_target" 2>&1 && \
                echo -e " ${rw_lv}✓ 已切换到: $_target${rw_lv}" || \
                echo -e " ${rw_hong}✗ 切换失败${rw_lv}"
        else
            echo -e " ${rw_hong}无效编号${rw_lv}"
        fi
        sleep 1
        ;;
      2)
        echo ""
        read -e -p " 新分支名称（0返回上一级）: " _new_br < /dev/tty
        [ "$_new_br" = "0" ] && continue
        if [ -z "$_new_br" ]; then
            echo -e " ${rw_hong}名称不能为空${rw_lv}"
            sleep 1; continue
        fi
        git checkout -b "$_new_br" 2>&1 && \
            echo -e " ${rw_lv}✓ 已创建并切换到: $_new_br${rw_lv}" || \
            echo -e " ${rw_hong}✗ 创建失败${rw_lv}"
        sleep 1
        ;;
      3)
        echo ""
        read -e -p " 输入要删除的分支编号（0返回上一级）: " _idx < /dev/tty
        [ "$_idx" = "0" ] && continue
        if [[ "$_idx" =~ ^[0-9]+$ ]] && [ "$_idx" -ge 1 ] && [ "$_idx" -le ${#_GIT_BRANCH_NAMES[@]} ]; then
            local _target="${_GIT_BRANCH_NAMES[$((_idx - 1))]}"
            [ "$_target" = "$_cur_br" ] && { echo -e " ${rw_hong}不能删除当前所在分支${rw_lv}"; sleep 1; continue; }
            read -e -p " 确认删除分支 $_target？(y/N): " _confirm < /dev/tty
            if [[ "$_confirm" =~ ^[Yy]$ ]]; then
                git branch -d "$_target" 2>&1 && \
                    echo -e " ${rw_lv}✓ 已删除: $_target${rw_lv}" || \
                    echo -e " ${rw_hong}✗ 删除失败（可能未合并，用 -D 强制删除）${rw_lv}"
            fi
        else
            echo -e " ${rw_hong}无效编号${rw_lv}"
        fi
        sleep 1
        ;;
      4)
        echo ""
        echo -e " ${rw_cheng}将指定分支合并到当前分支 ${rw_huang}${_cur_br}${rw_lv}"
        read -e -p " 输入要合并的分支编号（0返回上一级）: " _idx < /dev/tty
        [ "$_idx" = "0" ] && continue
        if [[ "$_idx" =~ ^[0-9]+$ ]] && [ "$_idx" -ge 1 ] && [ "$_idx" -le ${#_GIT_BRANCH_NAMES[@]} ]; then
            local _target="${_GIT_BRANCH_NAMES[$((_idx - 1))]}"
            git merge "$_target" 2>&1
            [ $? -eq 0 ] && echo -e " ${rw_lv}✓ 合并成功${rw_lv}" || \
                echo -e " ${rw_hong}✗ 合并冲突，请手动解决${rw_lv}"
        else
            echo -e " ${rw_hong}无效编号${rw_lv}"
        fi
        sleep 1
        ;;
      5)
        echo ""
        local _br _rem
        _br=$(git symbolic-ref --short HEAD 2>/dev/null || echo "")
        _rem=$(git remote 2>/dev/null | head -1)
        if [ -z "$_br" ] || [ -z "$_rem" ]; then
            echo -e " ${rw_hong}无法获取分支或远程信息${rw_lv}"
            sleep 1; continue
        fi
        echo -e " 将推送分支 ${rw_huang}${_br}${rw_lv} 到远程 ${rw_huang}${_rem}${rw_lv}"
        read -e -p " 确认？(y/N): " _confirm < /dev/tty
        if [[ "$_confirm" =~ ^[Yy]$ ]]; then
            git push -u "$_rem" "$_br" 2>&1 && \
                echo -e " ${rw_lv}✓ 推送成功${rw_lv}" || \
                echo -e " ${rw_hong}✗ 推送失败${rw_lv}"
        fi
        sleep 1
        ;;
      0) break ;;
    esac
  done
}



# ================================================================
# Docker 全管理（重构版）
# 设计原则: 主菜单清晰分层 → 子菜单聚焦操作 → 辅助函数复用
# 上手友好: 每个操作前列出可选项，输入编号即可，无需手敲容器名
# ================================================================

# ── 辅助: 检查 Docker 是否可用 ──
_dk_check() {
	if ! command -v docker &>/dev/null; then
		echo -e " ${rw_hong}Docker 未安装，请先执行「安装/升级 Docker」${rw_lv}"
		return 1
	fi
	if ! docker info &>/dev/null; then
		echo -e " ${rw_hong}Docker 未运行，请先启动 Docker 服务${rw_lv}"
		echo -e " ${rw_huang}启动命令: systemctl start docker${rw_lv}"
		return 1
	fi
	return 0
}

# ── 辅助: 列出容器并让用户选择，返回容器名到 $_DK_PICK ──
# 用法: _dk_pick_container <filter>  filter: all/running/stopped
_dk_pick_container() {
	local _filter="$1"
	local _list
	case "$_filter" in
		running) _list=$(docker ps --format "{{.Names}}|{{.Image}}|{{.Status}}" 2>/dev/null) ;;
		stopped) _list=$(docker ps -a --filter "status=exited" --format "{{.Names}}|{{.Image}}|{{.Status}}" 2>/dev/null) ;;
		*)       _list=$(docker ps -a --format "{{.Names}}|{{.Image}}|{{.Status}}" 2>/dev/null) ;;
	esac
	if [ -z "$_list" ]; then
		echo -e " ${rw_huang}没有符合条件的容器${rw_lv}"
		return 1
	fi
	echo -e " ${rw_cheng}── 可选容器 ──${rw_lv}"
	local _i=1
	_DK_CONTAINER_NAMES=()
	while IFS='|' read -r _name _img _stat; do
		echo -e " ${rw_huang}${_i}.${rw_lv} ${_name}  [${_img}]  ${_stat}"
		_DK_CONTAINER_NAMES+=("$_name")
		((_i++))
	done <<< "$_list"
	echo -e " ${rw_huang}0.${rw_lv} 取消"
	echo ""
	read -e -p " 请选择编号: " _idx < /dev/tty
	[ "$_idx" = "0" ] && return 1
	[ -z "$_idx" ] && return 1
	if ! [[ "$_idx" =~ ^[0-9]+$ ]] || [ "$_idx" -lt 1 ] || [ "$_idx" -gt ${#_DK_CONTAINER_NAMES[@]} ]; then
		echo -e " ${rw_hong}无效选择${rw_lv}"
		return 1
	fi
	_DK_PICK="${_DK_CONTAINER_NAMES[$((_idx - 1))]}"
	return 0
}

# ── 辅助: 列出镜像并让用户选择，返回到 $_DK_PICK ──
_dk_pick_image() {
	local _list
	_list=$(docker images --format "{{.Repository}}:{{.Tag}}|{{.ID}}|{{.Size}}" 2>/dev/null)
	if [ -z "$_list" ]; then
		echo -e " ${rw_huang}没有镜像${rw_lv}"
		return 1
	fi
	echo -e " ${rw_cheng}── 可选镜像 ──${rw_lv}"
	local _i=1
	_DK_IMAGE_NAMES=()
	while IFS='|' read -r _name _id _size; do
		echo -e " ${rw_huang}${_i}.${rw_lv} ${_name}  [${_id}]  ${_size}"
		_DK_IMAGE_NAMES+=("$_name")
		((_i++))
	done <<< "$_list"
	echo -e " ${rw_huang}0.${rw_lv} 取消"
	echo ""
	read -e -p " 请选择编号: " _idx < /dev/tty
	[ "$_idx" = "0" ] && return 1
	[ -z "$_idx" ] && return 1
	if ! [[ "$_idx" =~ ^[0-9]+$ ]] || [ "$_idx" -lt 1 ] || [ "$_idx" -gt ${#_DK_IMAGE_NAMES[@]} ]; then
		echo -e " ${rw_hong}无效选择${rw_lv}"
		return 1
	fi
	_DK_PICK="${_DK_IMAGE_NAMES[$((_idx - 1))]}"
	return 0
}

# ── 辅助: 获取 Compose 命令 ──
_dk_compose_cmd() {
	if docker compose version &>/dev/null; then
		echo "docker compose"
	elif command -v docker-compose &>/dev/null; then
		echo "docker-compose"
	else
		echo ""
	fi
}

# ================================================================
# Docker 主菜单
# ================================================================
docker_manager_menu() {
while true; do
	clear
	send_stats "Docker"

	# ── 状态探测 ──
	local _dk_stat="${rw_hong}未安装${rw_lv}" _dr=0 _da=0 _di=0
	if command -v docker &>/dev/null; then
		if docker info &>/dev/null; then
			_dk_stat="${rw_lv}运行中${rw_lv}"
			_dr=$(docker ps -q 2>/dev/null | wc -l | tr -d ' ')
			_da=$(docker ps -a -q 2>/dev/null | wc -l | tr -d ' ')
			_di=$(docker images -q 2>/dev/null | wc -l | tr -d ' ')
		else
			_dk_stat="${rw_huang}已安装未运行${rw_lv}"
		fi
	fi

	# Compose 状态
	local _compose_stat="${rw_hong}未安装${rw_lv}"
	if [ -n "$(_dk_compose_cmd)" ]; then
		_compose_stat="${rw_lv}已安装${rw_lv}"
	fi

	echo -e "${rw_cheng}━━━━━━━━━━━━  Docker 管理  ━━━━━━━━━━━━${rw_lv}"
	echo -e " Docker: ${_dk_stat}   容器: ${rw_lv}${_dr}${rw_lv}运行/${rw_huang}$(( _da - _dr ))${rw_lv}停止   镜像: ${rw_lv}${_di}${rw_lv}"
	echo -e " Compose: ${_compose_stat}"
	echo ""
	echo -e " ${rw_cheng}──── 容器 ────${rw_lv}"
	echo -e " ${rw_huang}1.   ${rw_lv}容器管理（启动/停止/重启/删除/日志）${rw_lv}"
	echo -e " ${rw_huang}2.   ${rw_lv}进入容器 Shell${rw_lv}"
	echo -e " ${rw_huang}3.   ${rw_lv}一键运行新容器（交互式引导）${rw_lv}"
	echo ""
	echo -e " ${rw_cheng}──── 镜像 ────${rw_lv}"
	echo -e " ${rw_huang}4.   ${rw_lv}镜像管理（拉取/搜索/删除/导出导入）${rw_lv}"
	echo ""
	echo -e " ${rw_cheng}──── Compose ────${rw_lv}"
	echo -e " ${rw_huang}5.   ${rw_lv}Compose 项目管理${rw_lv}"
	echo ""
	echo -e " ${rw_cheng}──── 系统维护 ────${rw_lv}"
	echo -e " ${rw_huang}6.   ${rw_lv}安装 / 升级 Docker${rw_lv}"
	echo -e " ${rw_huang}7.   ${rw_lv}磁盘清理（悬空镜像/停止容器/未用网络）${rw_lv}"
	echo -e " ${rw_huang}8.   ${rw_lv}健康诊断${rw_lv}"
	echo -e " ${rw_huang}9.   ${rw_lv}版本信息${rw_lv}"
	echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
	echo -e " ${rw_huang}0.   ${rw_lv}返回主菜单${rw_lv}"
	echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
	read -e -p " 请选择: " dk_choice

	case $dk_choice in
	  1) docker_container_manage ;;
	  2) docker_shell_access ;;
	  3) docker_quick_run ;;
	  4) docker_image_manage ;;
	  5) docker_compose_manage ;;
	  6) docker_install_upgrade ;;
	  7) docker_system_clean ;;
	  8) docker_health_check ;;
	  9) docker_version_show ;;
	  0) return ;;
	  *) echo -e "${rw_hong}无效选项${rw_lv}"; sleep 1 ;;
	esac
done
}

# ================================================================
# 容器管理
# ================================================================
docker_container_manage() {
while true; do
	clear
	_dk_check || { break_end; return; }
	echo -e "${rw_cheng}━━━━━━━━━━━━  容器管理  ━━━━━━━━━━━━${rw_lv}"
	echo ""
	# 容器列表（表格形式）
	docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null | head -30
	echo ""
	echo -e " ${rw_cheng}──── 操作 ────${rw_lv}"
	echo -e " ${rw_huang}1.   ${rw_lv}启动容器${rw_lv}"
	echo -e " ${rw_huang}2.   ${rw_lv}停止容器${rw_lv}"
	echo -e " ${rw_huang}3.   ${rw_lv}重启容器${rw_lv}"
	echo -e " ${rw_huang}4.   ${rw_lv}删除容器${rw_lv}"
	echo -e " ${rw_huang}5.   ${rw_lv}查看日志${rw_lv}"
	echo -e " ${rw_huang}6.   ${rw_lv}查看详情${rw_lv}"
	echo -e " ${rw_huang}7.   ${rw_lv}重命名容器${rw_lv}"
	echo -e " ${rw_huang}8.   ${rw_lv}清理所有已停止容器${rw_lv}"
	echo -e " ${rw_huang}9.   ${rw_lv}批量启动/停止${rw_lv}"
	echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
	echo -e " ${rw_huang}0.   ${rw_lv}返回${rw_lv}"
	echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
	read -e -p " 请选择: " choice

	case $choice in
	  1)
		echo ""
		if _dk_pick_container stopped; then
			docker start "$_DK_PICK" && green "✓ 已启动 $_DK_PICK" || red "启动失败"
		fi
		break_end
		;;
	  2)
		echo ""
		if _dk_pick_container running; then
			docker stop "$_DK_PICK" && green "✓ 已停止 $_DK_PICK" || red "停止失败"
		fi
		break_end
		;;
	  3)
		echo ""
		if _dk_pick_container all; then
			docker restart "$_DK_PICK" && green "✓ 已重启 $_DK_PICK" || red "重启失败"
		fi
		break_end
		;;
	  4)
		echo ""
		if _dk_pick_container all; then
			read -e -p " 确认删除 $_DK_PICK？(y/N): " _confirm < /dev/tty
			if [[ "$_confirm" =~ ^[Yy]$ ]]; then
				docker rm -f "$_DK_PICK" && green "✓ 已删除 $_DK_PICK" || red "删除失败"
				break_end
			else
				yellow "已取消"
			fi
		fi
		;;
	  5)
		echo ""
		if _dk_pick_container all; then
			echo ""
			echo -e " ${rw_huang}1.${rw_lv} 查看最近 N 行  ${rw_huang}2.${rw_lv} 实时跟踪 (Ctrl+C 退出)"
			read -e -p " 选择（默认1）: " _log_mode < /dev/tty
			_log_mode="${_log_mode:-1}"
			if [ "$_log_mode" = "2" ]; then
				docker logs -f "$_DK_PICK"
			else
				read -e -p " 行数（默认100）: " _lines < /dev/tty
				_lines="${_lines:-100}"
				docker logs --tail "$_lines" "$_DK_PICK"
			fi
		fi
		break_end
		;;
	  6)
		echo ""
		if _dk_pick_container all; then
			echo ""
			docker inspect "$_DK_PICK" 2>/dev/null | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)[0]
    name = d['Name'].lstrip('/')
    state = d['State']['Status']
    image = d['Config']['Image']
    created = d['Created'][:19].replace('T',' ')
    ip = d.get('NetworkSettings',{}).get('IPAddress','N/A')
    ports = []
    for k,v in d.get('NetworkSettings',{}).get('Ports',{}).items():
        if v: ports.append(f'{v[0][\"HostPort\"]} -> {k}')
        else: ports.append(str(k))
    mounts = [m['Source']+' -> '+m['Destination'] for m in d.get('Mounts',[])]
    restart = d.get('HostConfig',{}).get('RestartPolicy',{}).get('Name','none')
    print(f'  名称:     {name}')
    print(f'  状态:     {state}')
    print(f'  镜像:     {image}')
    print(f'  创建时间: {created}')
    print(f'  IP:       {ip}')
    print(f'  端口:     {\", \".join(ports) if ports else \"无\"}')
    print(f'  重启策略: {restart}')
    print(f'  挂载:')
    for m in mounts: print(f'    {m}')
    if not mounts: print('    无')
except Exception as e:
    print(f'  解析失败: {e}')
" 2>/dev/null || docker inspect "$_DK_PICK"
		fi
		break_end
		;;
	  7)
		echo ""
		if _dk_pick_container all; then
			read -e -p " 新名称: " _new_name < /dev/tty
			[ -z "$_new_name" ] && { red "名称不能为空"; break_end; continue; }
			docker rename "$_DK_PICK" "$_new_name" && green "✓ 已重命名为 $_new_name" || red "重命名失败"
		fi
		break_end
		;;
	  8)
		echo ""
		local _stopped_cnt
		_stopped_cnt=$(docker ps -a --filter "status=exited" -q 2>/dev/null | wc -l | tr -d ' ')
		[ "$_stopped_cnt" -eq 0 ] && { yellow "没有已停止的容器"; break_end; continue; }
		read -e -p " 确认清理 ${_stopped_cnt} 个已停止容器？(y/N): " _confirm < /dev/tty
		if [[ "$_confirm" =~ ^[Yy]$ ]]; then
			docker container prune -f && green "✓ 已清理 ${_stopped_cnt} 个容器" || red "清理失败"
		else
			yellow "已取消"
		fi
		break_cancel
		;;
	  9)
		echo ""
		echo -e " ${rw_huang}1.${rw_lv} 批量启动所有已停止容器"
		echo -e " ${rw_huang}2.${rw_lv} 批量停止所有运行中容器"
		echo -e " ${rw_huang}0.${rw_lv} 取消"
		read -e -p " 选择: " _batch < /dev/tty
		case $_batch in
			1)
				docker start $(docker ps -a --filter "status=exited" -q) 2>/dev/null
				green "✓ 批量启动完成"
				;;
			2)
				read -e -p " 确认停止所有运行中容器？(y/N): " _confirm < /dev/tty
				if [[ "$_confirm" =~ ^[Yy]$ ]]; then
					docker stop $(docker ps -q) 2>/dev/null
					green "✓ 批量停止完成"
				fi
				;;
			*) yellow "已取消" ;;
		esac
		break_cancel
		;;
	  0) return ;;
	  *) echo -e "${rw_hong}无效选项${rw_lv}"; sleep 1 ;;
	esac
done
}

# ================================================================
# 进入容器 Shell
# ================================================================
docker_shell_access() {
	clear
	_dk_check || { break_end; return; }
	echo -e "${rw_cheng}━━━━━━ 进入容器 Shell ━━━━━━${rw_lv}"
	echo ""
	if _dk_pick_container running; then
		echo ""
		echo -e " ${rw_huang}1.${rw_lv} sh   ${rw_huang}2.${rw_lv} bash   ${rw_huang}3.${rw_lv} 自定义命令"
		read -e -p " 选择（默认2）: " _sh < /dev/tty
		_sh="${_sh:-2}"
		case $_sh in
			1) docker exec -it "$_DK_PICK" sh ;;
			2) docker exec -it "$_DK_PICK" bash 2>/dev/null || docker exec -it "$_DK_PICK" sh ;;
			3)
				read -e -p " 命令: " _cmd < /dev/tty
				[ -n "$_cmd" ] && docker exec -it "$_DK_PICK" $_cmd
				;;
		esac
	fi
	break_end
}

# ================================================================
# 一键运行新容器（交互式引导）
# ================================================================
docker_quick_run() {
	clear
	_dk_check || { break_end; return; }
	echo -e "${rw_cheng}━━━━━━ 一键运行新容器 ━━━━━━${rw_lv}"
	echo ""
	echo -e " ${rw_lv}按提示输入参数，直接生成 docker run 命令并执行${rw_lv}"
	echo ""

	read -e -p " 镜像名（如 nginx:latest）: " _img < /dev/tty
	[ -z "$_img" ] && { red "镜像不能为空"; break_end; return; }

	read -e -p " 容器名（可选，留空自动生成）: " _name < /dev/tty
	read -e -p " 端口映射（如 8080:80，多个用逗号，留空跳过）: " _ports < /dev/tty
	read -e -p " 数据卷挂载（如 /opt/data:/data，多个用逗号，留空跳过）: " _vols < /dev/tty
	read -e -p " 环境变量（如 KEY=val，多个用逗号，留空跳过）: " _envs < /dev/tty
	read -e -p " 重启策略 [always/on-failure/no]（默认 no）: " _restart < /dev/tty
	_restart="${_restart:-no}"
	read -e -p " 后台运行？(Y/n): " _detach < /dev/tty
	local _d_flag="-d"
	[[ "$_detach" =~ ^[Nn]$ ]] && _d_flag=""

	# 拼装命令
	local _cmd="docker run $_d_flag --name ${_name:-auto_$$} --restart $_restart"
	[ -n "$_ports" ] && IFS=',' read -ra _pa <<< "$_ports" && for p in "${_pa[@]}"; do _cmd="$_cmd -p $p"; done
	[ -n "$_vols" ] && IFS=',' read -ra _va <<< "$_vols" && for v in "${_va[@]}"; do _cmd="$_cmd -v $v"; done
	[ -n "$_envs" ] && IFS=',' read -ra _ea <<< "$_envs" && for e in "${_ea[@]}"; do _cmd="$_cmd -e $e"; done
	_cmd="$_cmd $_img"

	echo ""
	echo -e " ${rw_huang}即将执行:${rw_lv}"
	echo -e "   ${rw_lv}$_cmd${rw_lv}"
	echo ""
	read -e -p " 确认执行？(y/N): " _confirm < /dev/tty
	if [[ "$_confirm" =~ ^[Yy]$ ]]; then
		eval "$_cmd" && green "✓ 容器已启动" || red "启动失败"
	else
		yellow "已取消"
	fi
	break_cancel
}

# ================================================================
# 镜像管理
# ================================================================
docker_image_manage() {
while true; do
	clear
	_dk_check || { break_end; return; }
	echo -e "${rw_cheng}━━━━━━━━━━━━  镜像管理  ━━━━━━━━━━━━${rw_lv}"
	echo ""
	docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedSince}}" 2>/dev/null | head -30
	echo ""
	echo -e " ${rw_cheng}──── 操作 ────${rw_lv}"
	echo -e " ${rw_huang}1.   ${rw_lv}拉取镜像${rw_lv}"
	echo -e " ${rw_huang}2.   ${rw_lv}搜索镜像${rw_lv}"
	echo -e " ${rw_huang}3.   ${rw_lv}删除镜像${rw_lv}"
	echo -e " ${rw_huang}4.   ${rw_lv}清理悬空镜像${rw_lv}"
	echo -e " ${rw_huang}5.   ${rw_lv}清理所有未使用镜像${rw_lv}"
	echo -e " ${rw_huang}6.   ${rw_lv}导出镜像为 tar${rw_lv}"
	echo -e " ${rw_huang}7.   ${rw_lv}从 tar 导入镜像${rw_lv}"
	echo -e " ${rw_huang}8.   ${rw_lv}查看镜像层信息${rw_lv}"
	echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
	echo -e " ${rw_huang}0.   ${rw_lv}返回${rw_lv}"
	echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
	read -e -p " 请选择: " choice

	case $choice in
	  1)
		echo ""
		read -e -p " 镜像名（如 nginx:latest）: " _img < /dev/tty
		[ -z "$_img" ] && { red "不能为空"; break_end; continue; }
		docker pull "$_img" && green "✓ 拉取成功" || red "拉取失败"
		break_end
		;;
	  2)
		echo ""
		read -e -p " 关键词: " _kw < /dev/tty
		[ -z "$_kw" ] && { red "不能为空"; break_end; continue; }
		read -e -p " 显示条数（默认10，最大25）: " _limit < /dev/tty
		_limit="${_limit:-10}"
		[ "$_limit" -gt 25 ] 2>/dev/null && _limit=25
		docker search --limit "$_limit" "$_kw" --format "table {{.Name}}\t{{.StarCount}}\t{{.IsOfficial}}" 2>/dev/null \
			|| red "搜索失败，请检查网络"
		break_end
		;;
	  3)
		echo ""
		if _dk_pick_image; then
			read -e -p " 确认删除 $_DK_PICK？(y/N): " _confirm < /dev/tty
			if [[ "$_confirm" =~ ^[Yy]$ ]]; then
				docker rmi -f "$_DK_PICK" && green "✓ 已删除" || red "删除失败"
				break_end
			else
				yellow "已取消"
			fi
		fi
		;;
	  4)
		echo ""
		local _cnt
		_cnt=$(docker images -f "dangling=true" -q 2>/dev/null | wc -l | tr -d ' ')
		[ "$_cnt" -eq 0 ] && { yellow "没有悬空镜像"; break_end; continue; }
		read -e -p " 清理 $_cnt 个悬空镜像？(y/N): " _confirm < /dev/tty
		[[ "$_confirm" =~ ^[Yy]$ ]] && docker image prune -f && green "✓ 已清理" || yellow "已取消"
		break_cancel
		;;
	  5)
		echo ""
		local _cnt
		_cnt=$(docker images -q 2>/dev/null | wc -l | tr -d ' ')
		read -e -p " 清理所有未被使用的镜像（$_cnt 个）？(y/N): " _confirm < /dev/tty
		[[ "$_confirm" =~ ^[Yy]$ ]] && docker image prune -a -f && green "✓ 已清理" || yellow "已取消"
		break_cancel
		;;
	  6)
		echo ""
		if _dk_pick_image; then
			local _safe _out
			_safe=$(echo "$_DK_PICK" | tr '/:' '_')
			_out="${_safe}_$(date +%Y%m%d_%H%M%S).tar"
			docker save -o "$_out" "$_DK_PICK" \
				&& green "✓ 已导出: $(pwd)/$_out  $(du -h "$_out" | cut -f1)" \
				|| red "导出失败"
		fi
		break_end
		;;
	  7)
		echo ""
		ls -lh *.tar 2>/dev/null || echo -e " ${rw_huang}当前目录无 tar 文件${rw_lv}"
		read -e -p " tar 文件路径: " _tar < /dev/tty
		[ -z "$_tar" ] && { red "不能为空"; break_end; continue; }
		[ ! -f "$_tar" ] && { red "文件不存在"; break_end; continue; }
		docker load -i "$_tar" && green "✓ 导入成功" || red "导入失败"
		break_end
		;;
	  8)
		echo ""
		if _dk_pick_image; then
			echo ""
			docker history "$_DK_PICK" --format "table {{.CreatedSince}}\t{{.Size}}\t{{.Comment}}" 2>/dev/null
		fi
		break_end
		;;
	  0) return ;;
	  *) echo -e "${rw_hong}无效选项${rw_lv}"; sleep 1 ;;
	esac
done
}

# ================================================================
# Compose 项目管理
# ================================================================
docker_compose_manage() {
	local COMPOSE_CMD
	COMPOSE_CMD=$(_dk_compose_cmd)

	while true; do
		clear
		echo -e "${rw_cheng}━━━━━━━━━━━━  Compose 管理  ━━━━━━━━━━━━${rw_lv}"
		echo ""
		if [ -z "$COMPOSE_CMD" ]; then
			echo -e " ${rw_hong}Docker Compose 未安装${rw_lv}"
			echo -e " ${rw_huang}请先执行「安装/升级 Docker」（菜单 6）${rw_lv}"
			break_end
			return
		fi
		echo -e " 命令: ${rw_lv}${COMPOSE_CMD}${rw_lv}"
		echo ""
		# 列出 Compose 项目
		echo -e " ${rw_cheng}── 运行中的 Compose 项目 ──${rw_lv}"
		docker ps --filter "label=com.docker.compose.project" \
			--format " {{.Label \"com.docker.compose.project\"}}\t{{.Names}}\t{{.Status}}" 2>/dev/null \
			| column -t | head -15
		[ $? -ne 0 ] && echo -e " ${rw_huang}暂无项目${rw_lv}"
		echo ""
		echo -e " ${rw_cheng}──── 操作 ────${rw_lv}"
		echo -e " ${rw_huang}1.   ${rw_lv}粘贴 yml 创建并运行${rw_lv}"
		echo -e " ${rw_huang}2.   ${rw_lv}管理现有项目（启动/停止/重启/状态）${rw_lv}"
		echo -e " ${rw_huang}3.   ${rw_lv}查看项目日志${rw_lv}"
		echo -e " ${rw_huang}4.   ${rw_lv}删除项目${rw_lv}"
		echo -e " ${rw_huang}5.   ${rw_lv}重新拉取镜像并重建${rw_lv}"
		echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
		echo -e " ${rw_huang}0.   ${rw_lv}返回${rw_lv}"
		echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
		read -e -p " 请选择: " choice

		case $choice in
		  1)
			echo ""
			read -e -p " 项目名称（如 myapp）: " _proj < /dev/tty
			[ -z "$_proj" ] && { red "不能为空"; break_end; continue; }
			local _proj_dir="${HOME}/compose/${_proj}"
			mkdir -p "$_proj_dir"
			local _yml_file="$_proj_dir/docker-compose.yml"
			echo -e " ${rw_huang}请粘贴 docker-compose.yml 内容（结束时输入 EOF 换行）:${rw_lv}"
			cat > "$_yml_file" <<'EOF'
EOF
			# 用 cat 读多行直到 EOF
			cat > "$_yml_file" <<'PEOF'
PEOF
			# 重新用 read 方式
			> "$_yml_file"
			while IFS= read -r _line || [ -n "$_line" ]; do
				[ "$_line" = "EOF" ] && break
				echo "$_line" >> "$_yml_file"
			done
			if [ -s "$_yml_file" ]; then
				cd "$_proj_dir"
				$COMPOSE_CMD up -d && green "✓ 项目已启动: $_proj_dir" || red "启动失败"
				cd - >/dev/null
			else
				red "yml 内容为空"
			fi
			break_end
			;;
		  2)
			echo ""
			# 列出 compose 项目目录
			local _proj_dir="${HOME}/compose"
			if [ -d "$_proj_dir" ]; then
				echo -e " ${rw_cheng}── 已有项目 ──${rw_lv}"
				local _projs=()
				local _i=1
				for _d in "$_proj_dir"/*/; do
					[ -d "$_d" ] || continue
					local _pn=$(basename "$_d")
					echo -e " ${rw_huang}${_i}.${rw_lv} $_pn  → $_d"
					_projs+=("$_d")
					((_i++))
				done
				if [ ${#_projs[@]} -eq 0 ]; then
					yellow "  暂无项目"
					break_end
					continue
				fi
				echo -e " ${rw_huang}0.${rw_lv} 取消"
				read -e -p " 选择: " _idx < /dev/tty
				[ "$_idx" = "0" ] && continue
				[ -z "$_idx" ] && continue
				if ! [[ "$_idx" =~ ^[0-9]+$ ]] || [ "$_idx" -lt 1 ] || [ "$_idx" -gt ${#_projs[@]} ]; then
					red "无效选择"
					break_end
					continue
				fi
				local _target="${_projs[$((_idx - 1))]}"
				echo ""
				echo -e " ${rw_huang}1.${rw_lv} 启动   ${rw_huang}2.${rw_lv} 停止   ${rw_huang}3.${rw_lv} 重启   ${rw_huang}4.${rw_lv} 状态"
				read -e -p " 操作: " _act < /dev/tty
				cd "$_target"
				case $_act in
					1) $COMPOSE_CMD up -d && green "✓ 已启动" ;;
					2) $COMPOSE_CMD down && green "✓ 已停止" ;;
					3) $COMPOSE_CMD restart && green "✓ 已重启" ;;
					4) $COMPOSE_CMD ps ;;
					*) yellow "无效" ;;
				esac
				cd - >/dev/null
			else
				yellow "  暂无项目目录 ($_proj_dir)"
			fi
			break_end
			;;
		  3)
			echo ""
			local _proj_dir="${HOME}/compose"
			[ -d "$_proj_dir" ] || { yellow "无项目"; break_end; continue; }
			local _projs=()
			local _i=1
			for _d in "$_proj_dir"/*/; do
				[ -d "$_d" ] || continue
				echo -e " ${rw_huang}${_i}.${rw_lv} $(basename "$_d")"
				_projs+=("$_d")
				((_i++))
			done
			[ ${#_projs[@]} -eq 0 ] && { yellow "无项目"; break_end; continue; }
			echo -e " ${rw_huang}0.${rw_lv} 取消"
			read -e -p " 选择: " _idx < /dev/tty
			[ "$_idx" = "0" ] && continue
			[ -z "$_idx" ] && continue
			if ! [[ "$_idx" =~ ^[0-9]+$ ]] || [ "$_idx" -lt 1 ] || [ "$_idx" -gt ${#_projs[@]} ]; then
				break_end
				continue
			fi
			local _target="${_projs[$((_idx - 1))]}"
			echo ""
			echo -e " ${rw_huang}1.${rw_lv} 最近 N 行  ${rw_huang}2.${rw_lv} 实时跟踪"
			read -e -p " 选择（默认1）: " _lm < /dev/tty
			_lm="${_lm:-1}"
			cd "$_target"
			if [ "$_lm" = "2" ]; then
				$COMPOSE_CMD logs -f
			else
				read -e -p " 行数（默认100）: " _lines < /dev/tty
				$COMPOSE_CMD logs --tail "${_lines:-100}"
			fi
			cd - >/dev/null
			break_end
			;;
		  4)
			echo ""
			local _proj_dir="${HOME}/compose"
			[ -d "$_proj_dir" ] || { yellow "无项目"; break_end; continue; }
			local _projs=()
			local _i=1
			for _d in "$_proj_dir"/*/; do
				[ -d "$_d" ] || continue
				echo -e " ${rw_huang}${_i}.${rw_lv} $(basename "$_d")"
				_projs+=("$_d")
				((_i++))
			done
			[ ${#_projs[@]} -eq 0 ] && { yellow "无项目"; break_end; continue; }
			echo -e " ${rw_huang}0.${rw_lv} 取消"
			read -e -p " 选择: " _idx < /dev/tty
			[ "$_idx" = "0" ] && continue
			[ -z "$_idx" ] && continue
			if ! [[ "$_idx" =~ ^[0-9]+$ ]] || [ "$_idx" -lt 1 ] || [ "$_idx" -gt ${#_projs[@]} ]; then
				break_end
				continue
			fi
			local _target="${_projs[$((_idx - 1))]}"
			read -e -p " 确认删除 $(basename "$_target")？将停止容器并删除目录 (yes确认): " _confirm < /dev/tty
			if [ "$_confirm" = "yes" ]; then
				cd "$_target"
				$COMPOSE_CMD down -v 2>/dev/null
				cd - >/dev/null
				rm -rf "$_target"
				green "✓ 已删除 $(basename "$_target")"
			else
				yellow "已取消"
			fi
			break_cancel
			;;
		  5)
			echo ""
			local _proj_dir="${HOME}/compose"
			[ -d "$_proj_dir" ] || { yellow "无项目"; break_end; continue; }
			local _projs=()
			local _i=1
			for _d in "$_proj_dir"/*/; do
				[ -d "$_d" ] || continue
				echo -e " ${rw_huang}${_i}.${rw_lv} $(basename "$_d")"
				_projs+=("$_d")
				((_i++))
			done
			[ ${#_projs[@]} -eq 0 ] && { yellow "无项目"; break_end; continue; }
			echo -e " ${rw_huang}0.${rw_lv} 取消"
			read -e -p " 选择: " _idx < /dev/tty
			[ "$_idx" = "0" ] && continue
			[ -z "$_idx" ] && continue
			if ! [[ "$_idx" =~ ^[0-9]+$ ]] || [ "$_idx" -lt 1 ] || [ "$_idx" -gt ${#_projs[@]} ]; then
				break_end
				continue
			fi
			local _target="${_projs[$((_idx - 1))]}"
			cd "$_target"
			$COMPOSE_CMD pull && $COMPOSE_CMD up -d --build && green "✓ 已重建" || red "重建失败"
			cd - >/dev/null
			break_end
			;;
		  0) return ;;
		  *) echo -e "${rw_hong}无效选项${rw_lv}"; sleep 1 ;;
		esac
	done
}

# ================================================================
# 安装 / 升级 Docker
# ================================================================
docker_install_upgrade() {
	clear
	echo -e "${rw_cheng}━━━━━━ 安装 / 升级 Docker ━━━━━━${rw_lv}"
	echo ""
	if command -v docker &>/dev/null; then
		green "Docker 已安装，当前版本:"
		docker version --format '{{.Server.Version}}' 2>/dev/null || docker --version
		echo ""
		echo -e " ${rw_huang}1.${rw_lv} 升级到最新版   ${rw_huang}2.${rw_lv} 卸载 Docker   ${rw_huang}0.${rw_lv} 返回"
		read -e -p " 选择: " _act < /dev/tty
		case $_act in
			1)
				echo ""
				echo -e " ${rw_huang}正在升级...${rw_lv}"
				if command -v apt-get &>/dev/null; then
					apt-get update -y && apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
				elif command -v yum &>/dev/null; then
					yum update -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
				elif command -v dnf &>/dev/null; then
					dnf update -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
				else
					red "无法识别包管理器"
				fi
				green "✓ 升级完成" || red "升级失败"
				;;
			2)
				echo ""
				echo -e " ${rw_hong}⚠ 将卸载 Docker 及相关组件${rw_lv}"
				read -e -p " 确认卸载？(yes确认): " _confirm < /dev/tty
				if [ "$_confirm" = "yes" ]; then
					systemctl stop docker 2>/dev/null
					if command -v apt-get &>/dev/null; then
						apt-get purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras 2>/dev/null
						apt-get autoremove -y
					elif command -v yum &>/dev/null; then
						yum remove -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 2>/dev/null
					elif command -v dnf &>/dev/null; then
						dnf remove -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 2>/dev/null
					fi
					green "✓ 卸载完成"
				else
					yellow "已取消"
				fi
				;;
			*) return ;;
		esac
	else
		echo -e " ${rw_huang}Docker 未安装，即将使用官方脚本安装...${rw_lv}"
		echo -e " ${rw_lv}官方脚本: https://get.docker.com${rw_lv}"
		echo ""
		read -e -p " 确认安装？(y/N): " _confirm < /dev/tty
		if [[ "$_confirm" =~ ^[Yy]$ ]]; then
			echo ""
			echo -e " ${rw_huang}正在下载并执行官方安装脚本...${rw_lv}"
			if command -v curl &>/dev/null; then
				curl -fsSL https://get.docker.com | bash
			elif command -v wget &>/dev/null; then
				wget -qO- https://get.docker.com | bash
			else
				install curl
				curl -fsSL https://get.docker.com | bash
			fi
			if [ $? -eq 0 ] && command -v docker &>/dev/null; then
				systemctl enable docker 2>/dev/null
				systemctl start docker 2>/dev/null
				green "✓ Docker 安装成功并已启动"
				echo -e " ${rw_huang}版本: ${rw_lv}$(docker --version)${rw_lv}"
				break_end
			else
				red "安装失败，请检查网络或手动安装"
				break_end
			fi
		else
			yellow "已取消"
		fi
	fi
}

# ================================================================
# 磁盘清理
# ================================================================
docker_system_clean() {
	clear
	_dk_check || { break_end; return; }
	echo -e "${rw_cheng}━━━━━━ Docker 磁盘清理 ━━━━━━${rw_lv}"
	echo ""
	echo -e " ${rw_huang}当前 Docker 磁盘占用:${rw_lv}"
	docker system df 2>/dev/null
	echo ""
	echo -e " ${rw_cheng}──── 清理选项 ────${rw_lv}"
	echo -e " ${rw_huang}1.   ${rw_lv}清理悬空镜像（dangling）${rw_lv}"
	echo -e " ${rw_huang}2.   ${rw_lv}清理所有未使用镜像${rw_lv}"
	echo -e " ${rw_huang}3.   ${rw_lv}清理已停止容器${rw_lv}"
	echo -e " ${rw_huang}4.   ${rw_lv}清理未使用网络${rw_lv}"
	echo -e " ${rw_huang}5.   ${rw_lv}清理构建缓存${rw_lv}"
	echo -e " ${rw_huang}6.   ${rw_lv}一键清理全部（谨慎）${rw_lv}"
	echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
	echo -e " ${rw_huang}0.   ${rw_lv}返回${rw_lv}"
	echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
	read -e -p " 请选择: " choice

	case $choice in
	  1) docker image prune -f && green "✓ 悬空镜像已清理" ;;
	  2)
		read -e -p " 确认清理所有未使用镜像？(y/N): " _c < /dev/tty
		[[ "$_c" =~ ^[Yy]$ ]] && docker image prune -a -f && green "✓ 已清理" || yellow "已取消"
		;;
	  3) docker container prune -f && green "✓ 已停止容器已清理" ;;
	  4) docker network prune -f && green "✓ 未使用网络已清理" ;;
	  5) docker builder prune -f && green "✓ 构建缓存已清理" ;;
	  6)
		read -e -p " 确认一键清理全部？将删除所有未使用资源 (yes确认): " _c < /dev/tty
		if [ "$_c" = "yes" ]; then
			docker system prune -a -f --volumes && green "✓ 全部清理完成"
		else
			yellow "已取消"
		fi
		;;
	  0) return ;;
	  *) red "无效选项" ;;
	esac
	break_end
}

# ================================================================
# 健康诊断
# ================================================================
docker_health_check() {
	clear
	_dk_check || { break_end; return; }
	echo -e "${rw_cheng}━━━━━━ Docker 健康诊断 ━━━━━━${rw_lv}"
	echo ""
	echo -e " ${rw_cheng}── 1. 服务状态 ──${rw_lv}"
	systemctl is-active docker 2>/dev/null && green "  docker 服务: 运行中" || red "  docker 服务: 未运行"
	echo ""
	echo -e " ${rw_cheng}── 2. 版本信息 ──${rw_lv}"
	docker version --format '  Client: {{.Client.Version}}' 2>/dev/null
	docker version --format '  Server: {{.Server.Version}}' 2>/dev/null
	echo ""
	echo -e " ${rw_cheng}── 3. 系统资源 ──${rw_lv}"
	docker system df 2>/dev/null
	echo ""
	echo -e " ${rw_cheng}── 4. 容器健康 ──${rw_lv}"
	local _unhealthy
	_unhealthy=$(docker ps --filter "health=unhealthy" --format "{{.Names}}" 2>/dev/null)
	if [ -n "$_unhealthy" ]; then
		red "  不健康容器:"
		echo "$_unhealthy" | while read -r _n; do echo "    - $_n"; done
	else
		green "  所有运行中容器状态正常"
	fi
	echo ""
	echo -e " ${rw_cheng}── 5. 磁盘空间 ──${rw_lv}"
	df -h / /var/lib/docker 2>/dev/null | head -5
	echo ""
	green "✓ 诊断完成"
	break_end
}

# ================================================================
# 版本信息
# ================================================================
docker_version_show() {
	clear
	echo -e "${rw_cheng}━━━━━━ Docker 版本信息 ━━━━━━${rw_lv}"
	echo ""
	if command -v docker &>/dev/null; then
		echo -e " ${rw_huang}Docker:${rw_lv}"
		docker --version 2>/dev/null
		echo ""
		echo -e " ${rw_huang}Docker Compose:${rw_lv}"
		if [ -n "$(_dk_compose_cmd)" ]; then
			$(_dk_compose_cmd) version 2>/dev/null
		else
			echo -e "  ${rw_hong}未安装${rw_lv}"
		fi
		echo ""
		echo -e " ${rw_huang}详细信息:${rw_lv}"
		docker version 2>/dev/null
	else
		red "Docker 未安装"
	fi
	break_end
}

k_info() {
send_stats "r命令参考用例"
echo -e "${rw_cheng}-------------------${rw_lv}"
echo "视频介绍: https://www.bilibili.com/video/BV1ib421E7it?t=0.1"
echo "以下是r命令参考用例："
echo "启动脚本            r"
echo "安装软件包          r install nano wget | r add nano wget | r 安装 nano wget"
echo "卸载软件包          r remove nano wget | r del nano wget | r uninstall nano wget | r 卸载 nano wget"
echo "更新系统            r update | r 更新"
echo "清理系统垃圾        r clean | r 清理"
echo "重装系统面板        r dd | r 重装"
echo "bbr3控制面板        r bbr3 | r bbrv3"
echo "内核调优面板        r nhyh | r 内核优化"
echo "设置虚拟内存        r swap 2048"
echo "设置虚拟时区        r time Asia/Shanghai | r 时区 Asia/Shanghai"
echo "系统回收站          r trash | r hsz | r 回收站"
echo "系统备份功能        r backup | r bf | r 备份"
echo "ssh远程连接工具     r ssh | r 远程连接"
echo "rsync远程同步工具   r rsync | r 远程同步"
echo "硬盘管理工具        r disk | r 硬盘管理"
echo "内网穿透（服务端）  r frps"
echo "内网穿透（客户端）  r frpc"
echo "软件启动            r start sshd | r 启动 sshd "
echo "软件停止            r stop sshd | r 停止 sshd "
echo "软件重启            r restart sshd | r 重启 sshd "
echo "软件状态查看        r status sshd | r 状态 sshd "
echo "软件开机启动        r enable docker | r autostart docke | r 开机启动 docker "
echo "域名证书申请        r ssl"
echo "域名证书到期查询    r ssl ps"
echo "docker管理平面      r docker | r docker manager"
echo "docker环境安装      r docker install |r docker 安装"
echo "docker容器管理      r docker ps |r docker 容器"
echo "docker镜像管理      r docker img |r docker 镜像"
echo "LDNMP站点管理       r web"
echo "LDNMP缓存清理       r web cache"
echo "安装WordPress       r wp |r wordpress |r wp xxx.com"
echo "安装反向代理        r fd |r rp |r 反代 |r fd xxx.com"
echo "安装负载均衡        r loadbalance |r 负载均衡"
echo "安装L4负载均衡      r stream |r L4负载均衡"
echo "防火墙面板          r fhq |r 防火墙"
echo "开放端口            r dkdk 8080 |r 打开端口 8080"
echo "关闭端口            r gbdk 7800 |r 关闭端口 7800"
echo "放行IP              r fxip 127.0.0.0/8 |r 放行IP 127.0.0.0/8"
echo "阻止IP              r zzip 177.5.25.36 |r 阻止IP 177.5.25.36"
echo "命令收藏夹          r fav | r 命令收藏夹"
echo "应用市场管理        r app"
echo "应用编号快捷管理    r app 26 | r app 1panel | r app npm"
echo "fail2ban管理        r fail2ban | r f2b"
echo "显示系统信息        r info"
echo "ROOT密钥管理        r sshkey"
echo "SSH公钥导入(URL)    r sshkey <url>"
echo "SSH公钥导入(GitHub) r sshkey github <user> "

}
#!/bin/bash
# 1Panel 面板管理函数
# 插入到 riwi.sh 中 k_info() 函数之后，CLI 入口点之前

one_panel_manager() {
while true; do
	clear

	# ── 使用缓存的状态探测 ──
	if _should_refresh_cache; then
	    refresh_status_cache
	fi

	# ── 状态探测 ──
	local _1p_ver="" _1p_stat="${rw_hong}未安装${rw_lv}" _1p_port="" _1p_user="" _1p_url=""
	local _1p_ip=""

	if command -v 1pctl &>/dev/null; then
		_1p_stat="${rw_lv}已安装${rw_lv}"
		_1p_ver=$(1pctl version 2>/dev/null | sed -n -E 's/.*(v[0-9.]+).*/\1/p' | head -1)
		# 获取端口和访问地址
		local _conf_file=""
		[ -f /opt/1panel/conf/app.yaml ] && _conf_file="/opt/1panel/conf/app.yaml"
		[ -f /opt/1panel/conf/1panel.yaml ] && _conf_file="/opt/1panel/conf/1panel.yaml"
		if [ -n "$_conf_file" ]; then
			_1p_port=$(sed -n -E 's/.*port:[[:space:]]*([0-9]+).*/\1/p' "$_conf_file" 2>/dev/null | head -1)
			_1p_ip=$(sed -n -E 's/.*listen_ip:[[:space:]]*([^[:space:]]+).*/\1/p' "$_conf_file" 2>/dev/null | head -1)
			[ "$_1p_ip" = "0.0.0.0" ] && _1p_ip=$(hostname -I 2>/dev/null | awk '{print $1}')
			_1p_url="http://${_1p_ip:-localhost}:${_1p_port:-$(grep port /opt/1panel/conf/app.yaml 2>/dev/null | awk '{print $2}' | head -1)}"
		fi
		# 服务状态（使用缓存）
		if $_CACHE_1PANEL_ACTIVE; then
			_1p_stat="${rw_lv}运行中${rw_lv}"
		else
			_1p_stat="${rw_hong}未运行${rw_lv}"
		fi
		# 用户信息
		_1p_user=$(1pctl user-info 2>/dev/null | sed -n -E 's/.*用户名:[[:space:]]*([^[:space:]]+).*/\1/p' | head -1)
	fi

	echo -e "${rw_cheng}━━━━━━━━━━━━  1Panel 面板管理  ━━━━━━━━━━━━${rw_lv}"
	echo -e " 状态 ${_1p_stat}  v${_1p_ver:-?}  端口 ${rw_lv}${_1p_port:-?}${rw_lv}  用户 ${rw_lv}${_1p_user:-?}${rw_lv}"
	[ -n "$_1p_url" ] && echo -e " 访问 ${rw_lv}${_1p_url}${rw_lv}"
	echo ""
	echo -e " ${rw_cheng}──── 服务${rw_lv}"
	echo -e " ${rw_huang}1${rw_lv}  启动        ${rw_huang}2${rw_lv}  停止        ${rw_huang}3${rw_lv}  重启        ${rw_huang}4${rw_lv}  状态详情"
	echo ""
	echo -e " ${rw_cheng}──── 失联修复${rw_lv}"
	echo -e " ${rw_huang}5${rw_lv}  重置安全入口        ${rw_huang}6${rw_lv}  重置域名绑定"
	echo -e " ${rw_huang}7${rw_lv}  重置HTTPS登录       ${rw_huang}8${rw_lv}  取消IP限制"
	echo -e " ${rw_huang}9${rw_lv}  关闭两步验证(MFA)   ${rw_huang}10${rw_lv} 一键重置全部"
	echo ""
	echo -e " ${rw_cheng}──── 配置${rw_lv}"
	echo -e " ${rw_huang}11${rw_lv} 修改端口            ${rw_huang}12${rw_lv} 修改密码"
	echo -e " ${rw_huang}13${rw_lv} 修改用户名          ${rw_huang}14${rw_lv} 切换监听IP"
	echo -e " ${rw_huang}15${rw_lv} 查看登录信息"
	echo ""
	echo -e " ${rw_cheng}──── 防火墙${rw_lv}"
	echo -e " ${rw_huang}16${rw_lv} 放行面板端口        ${rw_huang}17${rw_lv} 查看已放行端口"
	echo ""
	echo -e " ${rw_cheng}──── 其他${rw_lv}"
	echo -e " ${rw_huang}18${rw_lv} 查看日志            ${rw_huang}19${rw_lv} 更新1Panel"
	echo -e " ${rw_huang}20${rw_lv} 安装1Panel          ${rw_huang}21${rw_lv} 卸载1Panel"
	echo ""
	echo -e " ${rw_cheng}────────────────────────────────────────${rw_lv}"
	echo -e " ${rw_huang}0${rw_lv}  返回主菜单"
	echo -e " ${rw_cheng}────────────────────────────────────────${rw_lv}"
	read -e -p " 请选择: " _1p_choice

	case $_1p_choice in
	  1)
		send_stats "1Panel启动"
		if command -v 1pctl &>/dev/null; then
			1pctl start all && echo -e "${rw_lv}1Panel 已启动${rw_lv}"
		else
			echo -e "${rw_hong}1Panel 未安装${rw_lv}"
		fi
		;;
	  2)
		send_stats "1Panel停止"
		if command -v 1pctl &>/dev/null; then
			1pctl stop all && echo -e "${rw_lv}1Panel 已停止${rw_lv}"
		else
			echo -e "${rw_hong}1Panel 未安装${rw_lv}"
		fi
		;;
	  3)
		send_stats "1Panel重启"
		if command -v 1pctl &>/dev/null; then
			1pctl restart all && echo -e "${rw_lv}1Panel 已重启${rw_lv}"
		else
			echo -e "${rw_hong}1Panel 未安装${rw_lv}"
		fi
		;;
	  4)
		send_stats "1Panel状态详情"
		if command -v 1pctl &>/dev/null; then
			echo -e "${rw_cheng}────────────────────────────────────${rw_lv}"
			1pctl status
			echo -e "${rw_cheng}────────────────────────────────────${rw_lv}"
			1pctl version
			echo -e "${rw_cheng}────────────────────────────────────${rw_lv}"
			1pctl user-info
		else
			echo -e "${rw_hong}1Panel 未安装${rw_lv}"
		fi
		;;
	  5)
		send_stats "1Panel重置安全入口"
		if command -v 1pctl &>/dev/null; then
			echo -e "${rw_huang}重置安全入口（登录URL后缀）...${rw_lv}"
			1pctl reset entrance
			echo -e "${rw_lv}安全入口已重置，现在可以直接访问面板无需URL后缀${rw_lv}"
			1pctl user-info
		else
			echo -e "${rw_hong}1Panel 未安装${rw_lv}"
		fi
		;;
	  6)
		send_stats "1Panel重置域名绑定"
		if command -v 1pctl &>/dev/null; then
			echo -e "${rw_huang}取消域名绑定限制...${rw_lv}"
			1pctl reset domain
			echo -e "${rw_lv}域名绑定已取消，可用任意域名或IP访问${rw_lv}"
		else
			echo -e "${rw_hong}1Panel 未安装${rw_lv}"
		fi
		;;
	  7)
		send_stats "1Panel重置HTTPS"
		if command -v 1pctl &>/dev/null; then
			echo -e "${rw_huang}取消HTTPS强制登录...${rw_lv}"
			1pctl reset https
			echo -e "${rw_lv}HTTPS限制已取消，可用HTTP访问${rw_lv}"
		else
			echo -e "${rw_hong}1Panel 未安装${rw_lv}"
		fi
		;;
	  8)
		send_stats "1Panel取消IP限制"
		if command -v 1pctl &>/dev/null; then
			echo -e "${rw_huang}取消IP访问限制...${rw_lv}"
			1pctl reset ips
			echo -e "${rw_lv}IP限制已取消，任意IP可访问${rw_lv}"
		else
			echo -e "${rw_hong}1Panel 未安装${rw_lv}"
		fi
		;;
	  9)
		send_stats "1Panel关闭MFA"
		if command -v 1pctl &>/dev/null; then
			echo -e "${rw_huang}关闭两步验证...${rw_lv}"
			1pctl reset mfa
			echo -e "${rw_lv}两步验证已关闭${rw_lv}"
		else
			echo -e "${rw_hong}1Panel 未安装${rw_lv}"
		fi
		;;
	  10)
		send_stats "1Panel一键重置全部"
		if command -v 1pctl &>/dev/null; then
			echo -e "${rw_hong}警告：这将重置所有安全设置！${rw_lv}"
			read -e -p " 确认重置？(y/N): " _confirm
			if [[ "$_confirm" =~ ^[Yy]$ ]]; then
				1pctl reset entrance
				1pctl reset domain
				1pctl reset https
				1pctl reset ips
				1pctl reset mfa
				echo -e "${rw_lv}全部安全设置已重置！${rw_lv}"
				echo -e "${rw_lv}现在可直接访问面板，无需安全入口/域名/HTTPS${rw_lv}"
				1pctl user-info
			else
				echo -e "已取消"
			fi
		else
			echo -e "${rw_hong}1Panel 未安装${rw_lv}"
		fi
		;;
	  11)
		send_stats "1Panel修改端口"
		if command -v 1pctl &>/dev/null; then
			read -e -p " 输入新端口 (当前: ${_1p_port}): " _new_port
			[ -z "$_new_port" ] && { echo "已取消"; continue; }
			if [[ "$_new_port" =~ ^[0-9]+$ ]] && [ "$_new_port" -ge 1 ] && [ "$_new_port" -le 65535 ]; then
				1pctl update port <<< "$_new_port"
				echo -e "${rw_lv}端口已修改为 ${_new_port}，重启后生效${rw_lv}"
				1pctl restart all
			else
				echo -e "${rw_hong}端口无效${rw_lv}"
			fi
		else
			echo -e "${rw_hong}1Panel 未安装${rw_lv}"
		fi
		;;
	  12)
		send_stats "1Panel修改密码"
		if command -v 1pctl &>/dev/null; then
			echo -e "${rw_huang}请输入新密码:${rw_lv}"
			1pctl update password
			echo -e "${rw_lv}密码已修改${rw_lv}"
		else
			echo -e "${rw_hong}1Panel 未安装${rw_lv}"
		fi
		;;
	  13)
		send_stats "1Panel修改用户名"
		if command -v 1pctl &>/dev/null; then
			echo -e "${rw_huang}请输入新用户名:${rw_lv}"
			1pctl update username
			echo -e "${rw_lv}用户名已修改${rw_lv}"
		else
			echo -e "${rw_hong}1Panel 未安装${rw_lv}"
		fi
		;;
	  14)
		send_stats "1Panel切换监听IP"
		if command -v 1pctl &>/dev/null; then
			echo -e " ${rw_huang}1${rw_lv} IPv4   ${rw_huang}2${rw_lv} IPv6"
			read -e -p " 选择: " _ip_choice
			case $_ip_choice in
				1) 1pctl listen-ip ipv4 && echo -e "${rw_lv}已切换为IPv4监听${rw_lv}" ;;
				2) 1pctl listen-ip ipv6 && echo -e "${rw_lv}已切换为IPv6监听${rw_lv}" ;;
				*) echo -e "${rw_hong}无效选择${rw_lv}" ;;
			esac
		else
			echo -e "${rw_hong}1Panel 未安装${rw_lv}"
		fi
		;;
	  15)
		send_stats "1Panel查看登录信息"
		if command -v 1pctl &>/dev/null; then
			echo -e "${rw_cheng}────────────────────────────────────${rw_lv}"
			1pctl user-info
			echo -e "${rw_cheng}────────────────────────────────────${rw_lv}"
			echo -e "${rw_lv}提示：${rw_lv}"
			echo "  安全入口：/opt/1panel/conf/app.yaml 中 entrance 字段"
			echo "  端口：/opt/1panel/conf/app.yaml 中 port 字段"
		else
			echo -e "${rw_hong}1Panel 未安装${rw_lv}"
		fi
		;;
	  16)
		send_stats "1Panel防火墙放行端口"
		if command -v 1pctl &>/dev/null; then
			local _port="${_1p_port:-19081}"
			read -e -p " 输入要放行的端口 (默认 ${_port}): " _fp_port
			_fp_port=${_fp_port:-$_port}
			echo -e "${rw_huang}放行端口 ${_fp_port} ...${rw_lv}"
			# firewalld
			if command -v firewall-cmd &>/dev/null; then
				firewall-cmd --permanent --add-port=${_fp_port}/tcp 2>/dev/null
				firewall-cmd --reload 2>/dev/null
				echo -e "${rw_lv}firewalld: 端口 ${_fp_port} 已放行${rw_lv}"
			fi
			# ufw
			if command -v ufw &>/dev/null; then
				ufw allow ${_fp_port}/tcp 2>/dev/null
				echo -e "${rw_lv}ufw: 端口 ${_fp_port} 已放行${rw_lv}"
			fi
			# iptables
			iptables -I INPUT -p tcp --dport ${_fp_port} -j ACCEPT 2>/dev/null
			echo -e "${rw_lv}端口 ${_fp_port} 放行完成${rw_lv}"
		else
			echo -e "${rw_hong}1Panel 未安装${rw_lv}"
		fi
		;;
	  17)
		send_stats "1Panel查看防火墙规则"
		echo -e "${rw_cheng}────────────────────────────────────${rw_lv}"
		if command -v firewall-cmd &>/dev/null; then
			echo -e "${rw_lv}firewalld 已放行端口:${rw_lv}"
			firewall-cmd --list-ports --permanent 2>/dev/null
		fi
		if command -v ufw &>/dev/null; then
			echo -e "${rw_lv}ufw 状态:${rw_lv}"
			ufw status 2>/dev/null
		fi
		echo -e "${rw_lv}iptables 放行端口:${rw_lv}"
		iptables -L INPUT -n 2>/dev/null | grep ACCEPT
		echo -e "${rw_cheng}────────────────────────────────────${rw_lv}"
		;;
	  18)
		send_stats "1Panel查看日志"
		if command -v 1pctl &>/dev/null; then
			echo -e "${rw_huang}最近50行日志:${rw_lv}"
			echo -e "${rw_cheng}────────────────────────────────────${rw_lv}"
			if [ -f /opt/1panel/log/1panel.log ]; then
				tail -n 50 /opt/1panel/log/1panel.log
			elif [ -f /var/log/1panel.log ]; then
				tail -n 50 /var/log/1panel.log
			else
				journalctl -u 1panel -n 50 --no-pager 2>/dev/null || echo -e "${rw_hong}未找到日志文件${rw_lv}"
			fi
		else
			echo -e "${rw_hong}1Panel 未安装${rw_lv}"
		fi
		;;
	  19)
		send_stats "1Panel更新"
		if command -v 1pctl &>/dev/null; then
			echo -e "${rw_huang}正在更新 1Panel...${rw_lv}"
			1pctl update
			echo -e "${rw_lv}更新完成，请重启服务${rw_lv}"
			1pctl restart all
		else
			echo -e "${rw_hong}1Panel 未安装${rw_lv}"
		fi
		;;
	  20)
		send_stats "1Panel安装"
		echo -e "${rw_huang}安装 1Panel (官方一键脚本)...${rw_lv}"
		echo -e "${rw_lv}提示：安装完成后可用本菜单管理${rw_lv}"
		read -e -p " 确认安装？(y/N): " _confirm
		if [[ "$_confirm" =~ ^[Yy]$ ]]; then
			bash -c "$(curl -sSL https://resource.fit2cloud.com/1panel/package/v2/quick_start.sh)"
		else
			echo "已取消"
		fi
		;;
	  21)
		send_stats "1Panel卸载"
		if command -v 1pctl &>/dev/null; then
			echo -e "${rw_hong}警告：卸载将删除1Panel及所有数据！${rw_lv}"
			read -e -p " 确认卸载？(y/N): " _confirm
			if [[ "$_confirm" =~ ^[Yy]$ ]]; then
				1pctl uninstall
			else
				echo "已取消"
			fi
		else
			echo -e "${rw_hong}1Panel 未安装${rw_lv}"
		fi
		;;
	  0) return ;;
	  *) echo -e "${rw_hong}无效选择${rw_lv}" ;;
	esac
	break_end
done
}

python_manager() {
while true; do
	clear

	# ── 状态探测 ──
	local _py3_stat="${rw_hong}未安装${rw_lv}" _py3_ver="" _pip_stat="${rw_hong}未安装${rw_lv}" _pip_ver=""
	local _py2_stat="${rw_hong}未安装${rw_lv}" _py2_ver="" _venv_stat="${rw_hong}未安装${rw_lv}"

	# Python3 状态
	if command -v python3 &>/dev/null; then
		_py3_ver=$(python3 --version 2>/dev/null | sed 's/Python //')
		_py3_stat="${rw_lv}${_py3_ver}${rw_lv}"
	fi

	# Python2 状态
	if command -v python2 &>/dev/null; then
		_py2_ver=$(python2 --version 2>&1 | sed 's/Python //')
		_py2_stat="${rw_lv}${_py2_ver}${rw_lv}"
	fi

	# pip3 状态
	if command -v pip3 &>/dev/null; then
		_pip_ver=$(pip3 --version 2>/dev/null | sed -E 's/pip ([0-9.]+).*/\1/')
		_pip_stat="${rw_lv}v${_pip_ver}${rw_lv}"
	elif command -v python3 &>/dev/null && python3 -m pip --version &>/dev/null 2>&1; then
		_pip_ver=$(python3 -m pip --version 2>/dev/null | sed -E 's/pip ([0-9.]+).*/\1/')
		_pip_stat="${rw_lv}v${_pip_ver}${rw_lv}"
	fi

	# venv 模块状态
	if command -v python3 &>/dev/null && python3 -c "import venv" 2>/dev/null; then
		_venv_stat="${rw_lv}可用${rw_lv}"
	fi

	echo -e "${rw_cheng}━━━━━━━━━━━━  Python 管理  ━━━━━━━━━━━━${rw_lv}"
	echo -e " Python3 ${_py3_stat}  pip3 ${_pip_stat}  venv ${_venv_stat}"
	[ -n "$_py2_ver" ] && echo -e " Python2 ${_py2_stat}"
	echo ""
	echo -e " ${rw_cheng}──── 安装与卸载${rw_lv}"
	echo -e " ${rw_huang}1${rw_lv}  安装Python3          ${rw_huang}2${rw_lv}  安装pip3"
	echo -e " ${rw_huang}3${rw_lv}  安装Python2           ${rw_huang}4${rw_lv}  卸载Python3"
	echo ""
	echo -e " ${rw_cheng}──── 版本管理${rw_lv}"
	echo -e " ${rw_huang}5${rw_lv}  切换Python默认版本   ${rw_huang}6${rw_lv}  查看已安装版本"
	echo ""
	echo -e " ${rw_cheng}──── 虚拟环境${rw_lv}"
	echo -e " ${rw_huang}7${rw_lv}  创建虚拟环境          ${rw_huang}8${rw_lv}  删除虚拟环境"
	echo -e " ${rw_huang}9${rw_lv}  查看虚拟环境列表"
	echo ""
	echo -e " ${rw_cheng}──── 包管理${rw_lv}"
	echo -e " ${rw_huang}10${rw_lv} 安装Python包          ${rw_huang}11${rw_lv} 卸载Python包"
	echo -e " ${rw_huang}12${rw_lv} 查看已安装包          ${rw_huang}13${rw_lv} 升级pip"
	echo ""
	echo -e " ${rw_cheng}──── 信息${rw_lv}"
	echo -e " ${rw_huang}14${rw_lv} Python环境详情        ${rw_huang}15${rw_lv} pip配置信息"
	echo ""
	echo -e " ${rw_cheng}────────────────────────────────────────${rw_lv}"
	echo -e " ${rw_huang}0${rw_lv}  返回上级菜单"
	echo -e " ${rw_cheng}────────────────────────────────────────${rw_lv}"
	read -e -p " 请选择: " _py_choice

	case $_py_choice in
	  1)
		send_stats "Python安装Python3"
		echo -e "${rw_huang}正在安装 Python3 ...${rw_lv}"
		install python3
		# 尝试安装 pip
		if ! command -v pip3 &>/dev/null; then
			echo -e "${rw_huang}正在安装 pip ...${rw_lv}"
			if command -v apt &>/dev/null; then
				apt install -y python3-pip
			elif command -v yum &>/dev/null; then
				yum install -y python3-pip
			elif command -v dnf &>/dev/null; then
				dnf install -y python3-pip
			elif command -v apk &>/dev/null; then
				apk add py3-pip
			fi
		fi
		# 安装 venv 模块
		if command -v apt &>/dev/null; then
			apt install -y python3-venv 2>/dev/null
		fi
		if command -v python3 &>/dev/null; then
			echo -e "${rw_lv}Python3 安装成功！${rw_lv}"
			echo -e "  版本: $(python3 --version 2>/dev/null)"
			echo -e "  路径: $(which python3 2>/dev/null)"
		else
			echo -e "${rw_hong}Python3 安装失败${rw_lv}"
		fi
		;;
	  2)
		send_stats "Python安装pip3"
		if ! command -v python3 &>/dev/null; then
			echo -e "${rw_hong}请先安装 Python3${rw_lv}"
		else
			echo -e "${rw_huang}正在安装 pip3 ...${rw_lv}"
			if command -v apt &>/dev/null; then
				apt install -y python3-pip
			elif command -v yum &>/dev/null; then
				yum install -y python3-pip
			elif command -v dnf &>/dev/null; then
				dnf install -y python3-pip
			elif command -v apk &>/dev/null; then
				apk add py3-pip
			else
				python3 -m ensurepip --upgrade 2>/dev/null || curl -sS https://bootstrap.pypa.io/get-pip.py | python3
			fi
			if command -v pip3 &>/dev/null || python3 -m pip --version &>/dev/null 2>&1; then
				echo -e "${rw_lv}pip3 安装成功！${rw_lv}"
			else
				echo -e "${rw_hong}pip3 安装失败${rw_lv}"
			fi
		fi
		;;
	  3)
		send_stats "Python安装Python2"
		echo -e "${rw_huang}正在安装 Python2 ...${rw_lv}"
		if command -v apt &>/dev/null; then
			apt install -y python2 2>/dev/null || apt install -y python 2>/dev/null
		elif command -v yum &>/dev/null; then
			yum install -y python2 2>/dev/null || yum install -y python 2>/dev/null
		elif command -v apk &>/dev/null; then
			apk add python2 2>/dev/null || apk add python 2>/dev/null
		else
			echo -e "${rw_hong}当前包管理器不支持直接安装 Python2${rw_lv}"
		fi
		if command -v python2 &>/dev/null; then
			echo -e "${rw_lv}Python2 安装成功！$(python2 --version 2>&1)${rw_lv}"
		else
			echo -e "${rw_hong}Python2 安装失败或已停止维护${rw_lv}"
		fi
		;;
	  4)
		send_stats "Python卸载Python3"
		echo -e "${rw_hong}警告：卸载Python3可能导致系统工具异常！${rw_lv}"
		read -e -p " 确认卸载？输入YES继续: " _py_confirm
		if [ "$_py_confirm" = "YES" ]; then
			if command -v apt &>/dev/null; then
				apt remove -y python3 python3-pip python3-venv
				apt autoremove -y
			elif command -v yum &>/dev/null; then
				yum remove -y python3 python3-pip
			elif command -v dnf &>/dev/null; then
				dnf remove -y python3 python3-pip
			elif command -v apk &>/dev/null; then
				apk del python3 py3-pip
			fi
			echo -e "${rw_lv}Python3 已卸载${rw_lv}"
		else
			echo -e "已取消"
		fi
		;;
	  5)
		send_stats "Python切换默认版本"
		if ! command -v python3 &>/dev/null; then
			echo -e "${rw_hong}未安装 Python3${rw_lv}"
		else
			echo -e " ${rw_huang}1${rw_lv}  python → python3"
			if command -v python2 &>/dev/null; then
				echo -e " ${rw_huang}2${rw_lv}  python → python2"
			fi
			echo -e " ${rw_huang}3${rw_lv}  取消"
			read -e -p " 选择: " _alt_choice
			case $_alt_choice in
			  1)
				update-alternatives --install /usr/bin/python python "$(which python3)" 1 2>/dev/null
				ln -sf "$(which python3)" /usr/bin/python 2>/dev/null
				echo -e "${rw_lv}已将 python 指向 python3${rw_lv}"
				;;
			  2)
				if command -v python2 &>/dev/null; then
					update-alternatives --install /usr/bin/python python "$(which python2)" 2 2>/dev/null
					ln -sf "$(which python2)" /usr/bin/python 2>/dev/null
					echo -e "${rw_lv}已将 python 指向 python2${rw_lv}"
				else
					echo -e "${rw_hong}Python2 未安装${rw_lv}"
				fi
				;;
			  3) ;;
			  *) echo -e "${rw_hong}无效选择${rw_lv}" ;;
			esac
		fi
		;;
	  6)
		send_stats "Python查看已安装版本"
		echo -e "${rw_cheng}────────────────────────────────────${rw_lv}"
		echo -e "${rw_huang}已安装的 Python 版本:${rw_lv}"
		echo ""
		for _py_bin in python python2 python3 python3.8 python3.9 python3.10 python3.11 python3.12 python3.13 python3.14; do
			if command -v "$_py_bin" &>/dev/null; then
				local _v=$("$_py_bin" --version 2>/dev/null || "$_py_bin" -V 2>/dev/null)
				[ -n "$_v" ] && echo -e "  ${rw_lv}${_v}${rw_lv}  → $(which $_py_bin)"
			fi
		done
		echo ""
		if command -v update-alternatives &>/dev/null; then
			echo -e "${rw_huang}update-alternatives 配置:${rw_lv}"
			update-alternatives --display python 2>/dev/null || echo "  未配置"
		fi
		echo -e "${rw_cheng}────────────────────────────────────${rw_lv}"
		;;
	  7)
		send_stats "Python创建虚拟环境"
		if ! command -v python3 &>/dev/null; then
			echo -e "${rw_hong}请先安装 Python3${rw_lv}"
		else
			read -e -p " 输入虚拟环境名称: " _venv_name
			[ -z "$_venv_name" ] && { echo "已取消"; continue; }
			read -e -p " 输入目录路径（默认当前目录）: " _venv_dir
			_venv_dir=${_venv_dir:-.}
			if python3 -m venv "${_venv_dir}/${_venv_name}" 2>/dev/null; then
				echo -e "${rw_lv}虚拟环境已创建！${rw_lv}"
				echo -e "  路径: ${_venv_dir}/${_venv_name}"
				echo -e "  激活: source ${_venv_dir}/${_venv_name}/bin/activate"
				echo -e "  退出: deactivate"
			else
				echo -e "${rw_hong}创建失败，可能缺少 python3-venv 模块${rw_lv}"
				echo -e "${rw_huang}尝试安装 venv 模块...${rw_lv}"
				if command -v apt &>/dev/null; then
					apt install -y python3-venv
					python3 -m venv "${_venv_dir}/${_venv_name}"
					echo -e "${rw_lv}虚拟环境已创建！${rw_lv}"
				else
					echo -e "${rw_hong}请手动安装 venv 模块后重试${rw_lv}"
				fi
			fi
		fi
		;;
	  8)
		send_stats "Python删除虚拟环境"
		read -e -p " 输入虚拟环境路径: " _venv_del
		[ -z "$_venv_del" ] && { echo "已取消"; continue; }
		if [ -d "$_venv_del" ] && [ -f "${_venv_del}/bin/activate" ]; then
			echo -e "${rw_hong}将删除虚拟环境: ${_venv_del}${rw_lv}"
			read -e -p " 确认删除？(y/N): " _vd_confirm
			if [[ "$_vd_confirm" =~ ^[Yy]$ ]]; then
				rm -rf "$_venv_del"
				echo -e "${rw_lv}虚拟环境已删除${rw_lv}"
			else
				echo -e "已取消"
			fi
		else
			echo -e "${rw_hong}未找到有效的虚拟环境: ${_venv_del}${rw_lv}"
		fi
		;;
	  9)
		send_stats "Python查看虚拟环境列表"
		echo -e "${rw_cheng}────────────────────────────────────${rw_lv}"
		echo -e "${rw_huang}搜索虚拟环境（当前目录及子目录）:${rw_lv}"
		local _venv_count=0
		while IFS= read -r _venv_found; do
			_venv_count=$((_venv_count + 1))
			local _pv_ver=""
			if [ -f "${_venv_found}/bin/python3" ]; then
				_pv_ver=$("${_venv_found}/bin/python3" --version 2>/dev/null)
			fi
			echo -e "  ${rw_lv}${_venv_count}${rw_lv}. ${_venv_found}  ${rw_huang}${_pv_ver}${rw_lv}"
		done < <(find . -maxdepth 3 -type f -name "activate" -path "*/bin/activate" -not -path "*/\.*" 2>/dev/null | sed 's|/bin/activate$||' | sort)
		[ $_venv_count -eq 0 ] && echo -e "  ${rw_hong}未找到虚拟环境${rw_lv}"
		# 也检查常见目录
		for _chk_dir in ~/venvs ~/envs ~/.virtualenvs; do
			if [ -d "$_chk_dir" ]; then
				echo -e "\n  ${rw_huang}${_chk_dir}:${rw_lv}"
				for _sub in "$_chk_dir"/*/; do
					[ -f "${_sub}bin/activate" ] && echo -e "    ${rw_lv}${_sub}${rw_lv}"
				done
			fi
		done
		echo -e "${rw_cheng}────────────────────────────────────${rw_lv}"
		;;
	  10)
		send_stats "Python安装包"
		if ! command -v pip3 &>/dev/null && ! python3 -m pip --version &>/dev/null 2>&1; then
			echo -e "${rw_hong}请先安装 pip3${rw_lv}"
		else
			read -e -p " 输入要安装的包名（多个包用空格分隔）: " _pip_pkgs
			[ -z "$_pip_pkgs" ] && { echo "已取消"; continue; }
			echo -e "${rw_huang}正在安装 ${_pip_pkgs} ...${rw_lv}"
			if command -v pip3 &>/dev/null; then
				pip3 install "$_pip_pkgs"
			else
				python3 -m pip install "$_pip_pkgs"
			fi
			echo -e "${rw_lv}安装完成${rw_lv}"
		fi
		;;
	  11)
		send_stats "Python卸载包"
		if ! command -v pip3 &>/dev/null && ! python3 -m pip --version &>/dev/null 2>&1; then
			echo -e "${rw_hong}请先安装 pip3${rw_lv}"
		else
			read -e -p " 输入要卸载的包名: " _pip_rmpkg
			[ -z "$_pip_rmpkg" ] && { echo "已取消"; continue; }
			if command -v pip3 &>/dev/null; then
				pip3 uninstall -y "$_pip_rmpkg"
			else
				python3 -m pip uninstall -y "$_pip_rmpkg"
			fi
			echo -e "${rw_lv}卸载完成${rw_lv}"
		fi
		;;
	  12)
		send_stats "Python查看已安装包"
		echo -e "${rw_cheng}────────────────────────────────────${rw_lv}"
		if command -v pip3 &>/dev/null; then
			pip3 list 2>/dev/null
		elif command -v python3 &>/dev/null && python3 -m pip --version &>/dev/null 2>&1; then
			python3 -m pip list 2>/dev/null
		else
			echo -e "${rw_hong}pip3 未安装${rw_lv}"
		fi
		echo -e "${rw_cheng}────────────────────────────────────${rw_lv}"
		;;
	  13)
		send_stats "Python升级pip"
		if ! command -v python3 &>/dev/null; then
			echo -e "${rw_hong}Python3 未安装${rw_lv}"
		else
			echo -e "${rw_huang}正在升级 pip ...${rw_lv}"
			if command -v pip3 &>/dev/null; then
				pip3 install --upgrade pip
			else
				python3 -m pip install --upgrade pip
			fi
			echo -e "${rw_lv}pip 已升级到最新版本${rw_lv}"
		fi
		;;
	  14)
		send_stats "Python环境详情"
		echo -e "${rw_cheng}────────────────────────────────────${rw_lv}"
		echo -e "${rw_huang}Python 环境详情:${rw_lv}"
		echo ""
		if command -v python3 &>/dev/null; then
			echo -e "  ${rw_lv}Python3:${rw_lv}"
			echo -e "    版本:   $(python3 --version 2>/dev/null)"
			echo -e "    路径:   $(which python3 2>/dev/null)"
			echo -e "    前缀:   $(python3 -c 'import sys; print(sys.prefix)' 2>/dev/null)"
			echo -e "    包路径: $(python3 -c 'import site; print(site.getsitepackages()[0])' 2>/dev/null)"
		else
			echo -e "  ${rw_hong}Python3: 未安装${rw_lv}"
		fi
		echo ""
		if command -v python2 &>/dev/null; then
			echo -e "  ${rw_lv}Python2:${rw_lv} $(python2 --version 2>&1) → $(which python2 2>/dev/null)"
		fi
		echo ""
		if command -v pip3 &>/dev/null; then
			echo -e "  ${rw_lv}pip3:${rw_lv}  $(pip3 --version 2>/dev/null)"
			echo -e "    路径:   $(which pip3 2>/dev/null)"
		elif command -v python3 &>/dev/null && python3 -m pip --version &>/dev/null 2>&1; then
			echo -e "  ${rw_lv}pip:${rw_lv}   $(python3 -m pip --version 2>/dev/null)"
		else
			echo -e "  ${rw_hong}pip3: 未安装${rw_lv}"
		fi
		echo ""
		# 检查默认 python 指向
		if command -v python &>/dev/null; then
			echo -e "  python → $(readlink -f $(which python) 2>/dev/null || which python 2>/dev/null)"
		else
			echo -e "  python: 未配置默认版本"
		fi
		echo -e "${rw_cheng}────────────────────────────────────${rw_lv}"
		;;
	  15)
		send_stats "Python查看pip配置"
		if command -v pip3 &>/dev/null; then
			pip3 config list 2>/dev/null
			echo ""
			echo -e "${rw_huang}pip 配置文件位置:${rw_lv}"
			pip3 config list -v 2>/dev/null | grep -i "global\|user\|site" || echo "  使用默认配置"
		elif command -v python3 &>/dev/null && python3 -m pip --version &>/dev/null 2>&1; then
			python3 -m pip config list 2>/dev/null
		else
			echo -e "${rw_hong}pip3 未安装${rw_lv}"
		fi
		;;
	  0) return ;;
	  *) echo -e "${rw_hong}无效选择${rw_lv}" ;;
	esac
	break_end
done
}

other_panel_manager() {
while true; do
	clear

	# ── 状态探测 ──
	local _1p_stat="${rw_hong}未安装${rw_lv}" _ngx_stat="${rw_hong}未安装${rw_lv}" _py_stat="${rw_hong}未安装${rw_lv}"

	# 1Panel 状态
	if command -v 1pctl &>/dev/null; then
		_1p_stat="${rw_lv}已安装${rw_lv}"
		$_CACHE_1PANEL_ACTIVE && _1p_stat="${rw_lv}运行中${rw_lv}"
	fi

	# Nginx 状态
	if docker inspect nginx &>/dev/null || command -v nginx &>/dev/null; then
		if docker inspect nginx &>/dev/null; then
			docker exec nginx nginx -t &>/dev/null && _ngx_stat="${rw_lv}运行中${rw_lv}" || _ngx_stat="${rw_hong}异常${rw_lv}"
		elif pgrep -x nginx &>/dev/null; then
			_ngx_stat="${rw_lv}运行中${rw_lv}"
		else
			_ngx_stat="${rw_hong}未运行${rw_lv}"
		fi
	fi

	# Python 状态
	if command -v python3 &>/dev/null; then
		_py_stat="${rw_lv}$(python3 --version 2>/dev/null | sed 's/Python //')${rw_lv}"
	fi

	echo -e "${rw_cheng}━━━━━━━━━━━━  其他管理面板  ━━━━━━━━━━━━${rw_lv}"
	echo -e " 1Panel ${_1p_stat}    Nginx ${_ngx_stat}    Python ${_py_stat}"
	echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
	echo -e "${rw_huang}1.  ${rw_lv}${rw_lv}1Panel 面板管理${rw_lv}"
	echo -e "${rw_huang}2.  ${rw_lv}${rw_lv}Nginx 管理器${rw_lv}"
	echo -e "${rw_huang}3.  ${rw_lv}${rw_lv}Python 管理${rw_lv}"
	echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
	echo -e "${rw_huang}0.  ${rw_lv}${rw_lv}返回主菜单${rw_lv}"
	echo -e "${rw_cheng}────────────────────────────────────────${rw_lv}"
	read -e -p " 请选择: " _op_choice

	case $_op_choice in
	  1) one_panel_manager ;;
	  2) ngxing_manager ;;
	  3) python_manager ;;
	  0) return ;;
	  *) echo -e "${rw_hong}无效选择${rw_lv}" ;;
	esac
	break_end
done
}



if [ "$#" -eq 0 ]; then
	# 如果没有参数，运行交互式逻辑
	riwi_sh
else
	# 如果有参数，执行相应函数
	case $1 in
		install|add|安装)
			shift
			send_stats "安装软件"
			install "$@"
			;;
		remove|del|uninstall|卸载)
			shift
			send_stats "卸载软件"
			remove "$@"
			;;
		update|更新)
			linux_update
			;;
		clean|清理)
			linux_clean
			;;
		dd|重装)
			dd_xitong
			;;
		bbr3|bbrv3)
			bbrv3
			;;
		nhyh|内核优化)
			Kernel_optimize
			;;
		trash|hsz|回收站)
			linux_trash
			;;
		backup|bf|备份)
			linux_backup
			;;
		ssh|远程连接)
			ssh_manager
			;;

		rsync|远程同步)
			rsync_manager
			;;

		rsync_run)
			shift
			send_stats "定时rsync同步"
			run_task "$@"
			;;

		disk|硬盘管理)
			disk_manager
			;;

		wp|wordpress)
			shift
			ldnmp_wp "$@"

			;;
		fd|rp|反代)
			shift
			ldnmp_Proxy "$@"
	  		find_container_by_host_port "$port"
	  		if [ -z "$docker_name" ]; then
	  		  close_port "$port"
			  echo "已阻止IP+端口访问该服务"
	  		else
			  ip_address
			  close_port "$port"
	  		  block_container_port "$docker_name" "$ipv4_address"
	  		fi
			;;

		loadbalance|负载均衡)
			ldnmp_Proxy_backend
			;;


		stream|L4负载均衡)
			ldnmp_Proxy_backend_stream
			;;

		swap)
			shift
			send_stats "快速设置虚拟内存"
			add_swap "$@"
			;;

		time|时区)
			shift
			send_stats "快速设置时区"
			set_timedate "$@"
			;;


		iptables_open)
			iptables_open
			;;

		frps)
			frps_panel
			;;

		frpc)
			frpc_panel
			;;


		打开端口|dkdk)
			shift
			open_port "$@"
			;;

		关闭端口|gbdk)
			shift
			close_port "$@"
			;;

		放行IP|fxip)
			shift
			allow_ip "$@"
			;;

		阻止IP|zzip)
			shift
			block_ip "$@"
			;;

		防火墙|fhq)
			iptables_panel
			;;

		命令收藏夹|fav)
			linux_fav
			;;

		status|状态)
			shift
			send_stats "软件状态查看"
			status "$@"
			;;
		start|启动)
			shift
			send_stats "软件启动"
			start "$@"
			;;
		stop|停止)
			shift
			send_stats "软件暂停"
			stop "$@"
			;;
		restart|重启)
			shift
			send_stats "软件重启"
			restart "$@"
			;;

		enable|autostart|开机启动)
			shift
			send_stats "软件开机自启"
			enable "$@"
			;;

		ssl)
			shift
			if [ "$1" = "ps" ]; then
				send_stats "查看证书状态"
				ssl_ps
			elif [ -z "$1" ]; then
				add_ssl
				send_stats "快速申请证书"
			elif [ -n "$1" ]; then
				add_ssl "$1"
				send_stats "快速申请证书"
			else
				k_info
			fi
			;;

		docker)
			shift
			case $1 in
				install|安装)
					send_stats "快捷安装docker"
					install_docker
					;;
				ps|容器)
					send_stats "快捷容器管理"
					docker_ps
					;;
				img|镜像)
					send_stats "快捷镜像管理"
					docker_image
					;;
				manager|管理|"")
					send_stats "Docker"
					docker_manager_menu
					;;
				*)
					echo "Docker 管理相关命令:"
					echo "  r docker              进入 Docker 全管理界面"
					echo "  r docker install       安装 Docker"
					echo "  r docker ps            容器管理"
					echo "  r docker img           镜像管理"
					echo "  r docker manager       进入管理界面"
					;;
			esac
			;;

		web)
		   shift
			if [ "$1" = "cache" ]; then
				web_cache
			elif [ "$1" = "sec" ]; then
				web_security
			elif [ "$1" = "opt" ]; then
				web_optimization
			elif [ -z "$1" ]; then
				ldnmp_web_status
			else
				k_info
			fi
			;;


		app)
			shift
			send_stats "应用$@"
			linux_panel "$@"
			;;

		claw|oc|OpenClaw)
			moltbot_menu
			;;

		info)
			linux_info
			;;

		fail2ban|f2b)
			fail2ban_panel
			;;


		sshkey)

			shift
			case "$1" in
				"" )
					# sshkey → 交互菜单
					send_stats "SSHKey 交互菜单"
					sshkey_panel
					;;
				github )
					shift
					send_stats "从 GitHub 导入 SSH 公钥"
					fetch_github_ssh_keys "$1"
					;;
				http://*|https://* )
					send_stats "从 URL 导入 SSH 公钥"
					fetch_remote_ssh_keys "$1"
					;;
				ssh-rsa*|ssh-ed25519*|ssh-ecdsa* )
					send_stats "公钥直接导入"
					import_sshkey "$1"
					;;
				* )
					echo "错误：未知参数 '$1'"
					echo "用法："
					echo "  r sshkey                  进入交互菜单"
					echo "  r sshkey \"<pubkey>\"     直接导入 SSH 公钥"
					echo "  r sshkey <url>            从 URL 导入 SSH 公钥"
					echo "  r sshkey github <user>    从 GitHub 导入 SSH 公钥"
					;;
			esac

			;;
		*)
			k_info
			;;
	esac
fi
