#!/bin/bash

# 创建一个临时文件来模拟用户输入
cat > /tmp/test_input.txt << 'EOF'
4
0
0
EOF

# 运行原脚本，用临时文件作为输入
cd /Users/owen/Desktop/github/6月1日/sh/cn
bash cn/riwi.sh < /tmp/test_input.txt

# 清理临时文件
rm /tmp/test_input.txt
