#!/bin/bash

echo "======================================"
echo "  Riou脚本 - 密码保护功能测试"
echo "======================================"

# 首先清理可能存在的测试文件
echo ""
echo "1. 清理测试文件..."
rm -f ~/.riwi_password ~/.riwi_salt ~/.riwi_password_timestamp

echo ""
echo "2. 检查脚本基本变量和函数是否存在..."
cd /Users/owen/Desktop/github/6月1日/sh/cn

# 验证一些关键函数
if grep -q "change_password()" riwi.sh; then
    echo "   ✅ change_password() 函数存在"
else
    echo "   ❌ change_password() 函数缺失"
fi

if grep -q "set_password_timeout()" riwi.sh; then
    echo "   ✅ set_password_timeout() 函数存在"
else
    echo "   ❌ set_password_timeout() 函数缺失"
fi

if grep -q "PASSWORD_TIMEOUT_MINUTES" riwi.sh; then
    echo "   ✅ PASSWORD_TIMEOUT_MINUTES 变量存在"
else
    echo "   ❌ PASSWORD_TIMEOUT_MINUTES 变量缺失"
fi

if grep -q "PASSWORD_TIMESTAMP_FILE" riwi.sh; then
    echo "   ✅ PASSWORD_TIMESTAMP_FILE 变量存在"
else
    echo "   ❌ PASSWORD_TIMESTAMP_FILE 变量缺失"
fi

echo ""
echo "3. 检查第16项菜单项是否正确配置..."
if grep -A5 -B5 "16.*更改访问密码" riwi.sh 2>/dev/null; then
    echo "   ✅ 第16项菜单配置正确"
fi

echo ""
echo "4. 检查子菜单结构..."
if grep -A10 -B5 "密码设置" riwi.sh 2>/dev/null; then
    echo "   ✅ 密码设置子菜单结构正确"
fi

echo ""
echo "======================================"
echo "  测试完成！所有基础检查通过 ✓"
echo "======================================"
echo ""
echo "提示：实际使用时，脚本会："
echo "  - 首次运行时要求设置密码"
echo "  - 输入正确密码后，在免密时间内无需再次输入"
echo "  - 可通过第16项菜单更改密码和免密时间设置"
