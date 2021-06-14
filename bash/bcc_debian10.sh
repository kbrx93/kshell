#! /usr/bin/env zsh

# use root role
cp /etc/apt/sources.list /etc/apt/sources.list.bak \
&& cat >> /etc/apt/sources.list <<EOF
# add for bcc compiler
deb http://deb.debian.org/debian sid main contrib non-free
deb-src http://deb.debian.org/debian sid main contrib non-free
EOF

# compiler
apt update -y \
&& apt install -y arping bison clang-format cmake dh-python \
  dpkg-dev pkg-kde-tools ethtool flex inetutils-ping iperf \
  libbpf-dev libclang-dev libclang-cpp-dev libedit-dev libelf-dev \
  libfl-dev libzip-dev linux-libc-dev llvm-dev libluajit-5.1-dev \
  luajit python3-netaddr python3-pyroute2 python3-distutils python3 \
&& ln -s /usr/bin/python3 /usr/bin/python \
&& git clone "https://github.com/iovisor/bcc.git" \
&& mkdir bcc/build \
&& cd bcc/build \
&& cmake .. \
&& make \
&& make install

cat >> ~/.zshrc <<EOF
export PATH=/usr/share/bcc/tools:$PATH
EOF

source ～/.zshrc
apt install -y gcc-8 libgcc-8-dev linux-headers-$(uname -r)
