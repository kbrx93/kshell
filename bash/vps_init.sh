#!/usr/bin/env bash
export PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin"

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

change_password()
{
  local new_password="kbrx93.com"
  local confirm_password="kbrx93.com"
  read -p "please input your new password: (default -> kbrx93.com) " new_password
  read -p "confirm your password again: " confirm_password
  if [[ "${new_password}" != "${confirm_password}" ]]; then
    echo_red "password is different, exit"
    exit 1
  fi
  echo "$USER:${new_password}" | chpasswd
  if [[ "$?" = "0" ]]; then
    echo_green "----- change $USER password success ! -----"
  else
    echo_red "----- change $USER password failed :( -----"
    exit 1
  fi
}

common_update()
{
  if command -v apt-get &>/dev/null; then
    apt update -y && apt upgrade -y
  else
    echo_red "Can not find apt-get !"
    exit 1
  fi
}

install_bbr()
{
  # 暂时不检测内核版本
  echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf && echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf && sysctl -p
}

custom_setting()
{
  echo > /etc/motd
  apt install sudo wget curl net-tools git zsh -y
}

install_zsh()
{
   sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
}

update_ssh_port()
{
  bash <(wget -N --no-check-certificate -qO- https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/ssh_port.sh)
}

install_pip(){
  if ! command -v curl &> /dev/null; then
    echo_red "curl not install"
    exit 1
  fi
  curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
  sudo apt-get install build-essential checkinstall aptitude sqlite3  libreadline-gplv2-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev libxslt1-dev libxml2-dev libffi-dev python-dev xz-utils -y
  sudo aptitude -y install gcc make zlib1g-dev
  if ! command -v python2 &> /dev/null; then
    echo_red "python2 not installed"
    exit 1
  fi
  if python2 get-pip.py; then
    rm -rf get-pip.py
  fi
}

install_pyenv()
{
  curl -L https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer | bash
  cat >> ~/.bashrc << EOF
# Pyenv
export PATH="/root/.pyenv/bin:\$PATH"
eval "\$(pyenv init -)"
eval "\$(pyenv virtualenv-init -)"
EOF
  export PATH="/root/.pyenv/bin:${PATH}"
  pyenv init -
  pyenv virtualenv-init -
  pyenv install 3.6.8
  pyenv global 3.6.8
}

install_serverstatus()
{
  local serverNo="s01"
  read -p "input server no : " serverNo
  mkdir /root/.serverstatus && cd $_ && wget --no-check-certificate -qO client-linux.py 'https://raw.githubusercontent.com/cppla/ServerStatus/master/clients/client-linux.py' 

cat > /etc/systemd/system/clientServer.service << EOF
[Unit]
Description=clientServer
After=network.target
Wants=network.target

[Service]
Type=simple
PIDFile=/var/run/clientServer.pid
WorkingDirectory=/root/.serverstatus
ExecStart=/usr/bin/python2 client-linux.py SERVER=serverstatus.kbrx93.com USER="${serverNo}" PASSWORD=939393
Restart=always
User=root

[Install]
WantedBy=multi-user.target

EOF

systemctl restart clientServer.service
systemctl enable clientServer.service
}

check_root()
{
  if [[ $(id -u) != "0" ]]; then
    echo_red "Error: You must run this script as root !"
    exit 1
  fi
}

color_text()
{
  echo -e "\e[0;$2m$1\e[0m"
}

echo_red()
{
  echo $(color_text "$1" "31")
}

echo_green()
{
  echo $(color_text "$1" "32")
}

main()
{
  # do
  local yesOrNo=n
  read -p 'check root ?' yesOrNo
  if [[ "${yesOrNo}" =~ ^[Yy]$ ]]; then
    check_root
  fi
  read -p 'change_password ?' yesOrNo
  if [[ "${yesOrNo}" =~ ^[Yy]$ ]]; then
    change_password
  fi
  read -p 'common_update ?' yesOrNo
  if [[ "${yesOrNo}" =~ ^[Yy]$ ]]; then
    common_update
  fi
  read -p 'install_bbr ?' yesOrNo
  if [[ "${yesOrNo}" =~ ^[Yy]$ ]]; then
    install_bbr
  fi
  read -p 'custom_setting[like install wget curl...] ?' yesOrNo
  if [[ "${yesOrNo}" =~ ^[Yy]$ ]]; then
    custom_setting
  fi
  read -p 'update_ssh_port ?' yesOrNo
  if [[ "${yesOrNo}" =~ ^[Yy]$ ]]; then
    update_ssh_port
  fi
  read -p 'install_pip ?' yesOrNo
  if [[ "${yesOrNo}" =~ ^[Yy]$ ]]; then
    install_pip
  fi
  read -p 'install_pyenv ?' yesOrNo
  if [[ "${yesOrNo}" =~ ^[Yy]$ ]]; then
    install_pyenv
  fi
  read -p 'install_serverstatus ?' yesOrNo
  if [[ "${yesOrNo}" =~ ^[Yy]$ ]]; then
    install_serverstatus
  fi
  read -p 'install_zsh ?' yesOrNo
  if [[ "${yesOrNo}" =~ ^[Yy]$ ]]; then
    install_zsh
  fi
}

main "$@"
