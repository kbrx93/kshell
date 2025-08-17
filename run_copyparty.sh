#!/bin/bash

# 获取当前目录
CURRENT_DIR="$(pwd)"

# 检查 copyparty 是否已在运行，如果是则终止它
pids=$(pgrep -f "copyparty.*-p 8080")
if [ -n "$pids" ]; then
    echo "正在终止已存在的 copyparty 实例，PID: $pids"
    kill $pids
    sleep 2
fi

# 创建临时目录
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

# 下载 copyparty 到临时目录
curl -L https://github.com/9001/copyparty/releases/latest/download/copyparty-sfx.py -o "$TMP_DIR/copyparty-sfx.py"

# 添加执行权限
chmod +x "$TMP_DIR/copyparty-sfx.py"

# 获取内部 IP 地址
INTERNAL_IPS=$(ifconfig | grep -E "inet ([0-9]{1,3}\.){3}[0-9]{1,3}" | grep -v "127.0.0.1" | awk '{print $2}' | tr '
' ' ')

# 获取外部 IP 地址 (使用公共服务)
EXTERNAL_IP=$(curl -s https://api.ipify.org)

# 在启动 copyparty 前显示访问链接
echo "copyparty 可通过以下地址访问:"
echo "内部 IP: $INTERNAL_IPS"
echo "外部 IP: $EXTERNAL_IP"
echo "端口: 8080"
echo ""
echo "访问示例:"
for ip in $INTERNAL_IPS; do
    echo "  http://$ip:8080"
done
echo "  http://$EXTERNAL_IP:8080"
echo ""

# 运行 copyparty，将当前目录作为唯一共享文件夹
# 添加 --no-db 避免数据库冲突
python3 "$TMP_DIR/copyparty-sfx.py" -p 8080 --no-db -v ".:$(basename "$CURRENT_DIR"):rw"
