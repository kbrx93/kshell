#!/usr/bin/env bash
# Author: kbrx93
# Github: https://github.com/kbrx93
#
# Note: Init Shell for Debian 9+
#
# Quick Use: 
export PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin"
clear
printf "
#######################################################################
#                      Init Shell for Debian 9+                       #
#          For information please visit https://blog.kbrx93.com       #
#######################################################################
"

#######  Base Method #######
Color_Text()
{
  echo -e " \e[0;$2m$1\e[0m"
}

Echo_Red()
{
  echo $(Color_Text "$1" "31")
}

Echo_Green()
{
  echo $(Color_Text "$1" "32")
}

Echo_Yellow()
{
  echo $(Color_Text "$1" "33")
}

Get_Dist_Version()
{
    if command -v lsb_release >/dev/null 2>&1; then
        DISTRO_Version=$(lsb_release -sr)
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        DISTRO_Version="$DISTRIB_RELEASE"
    elif [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO_Version="$VERSION_ID"
    fi
    if [[ "${DISTRO}" = "" || "${DISTRO_Version}" = "" ]]; then
        if command -v python2 >/dev/null 2>&1; then
            DISTRO_Version=$(python2 -c 'import platform; print platform.linux_distribution()[1]')
        elif command -v python3 >/dev/null 2>&1; then
            DISTRO_Version=$(python3 -c 'import platform; print(platform.linux_distribution()[1])')
        else
            Install_LSB
            DISTRO_Version=`lsb_release -rs`
        fi
    fi
    printf -v "${DISTRO}_Version" '%s' "${DISTRO_Version}"
}

Get_Dist_Name()
{
    if grep -Eqi "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
        DISTRO='CentOS'
        PM='yum'
    elif grep -Eqi "Aliyun" /etc/issue || grep -Eq "Aliyun Linux" /etc/*-release; then
        DISTRO='Aliyun'
        PM='yum'
    elif grep -Eqi "Amazon Linux" /etc/issue || grep -Eq "Amazon Linux" /etc/*-release; then
        DISTRO='Amazon'
        PM='yum'
    elif grep -Eqi "Fedora" /etc/issue || grep -Eq "Fedora" /etc/*-release; then
        DISTRO='Fedora'
        PM='yum'
    elif grep -Eqi "Oracle Linux" /etc/issue || grep -Eq "Oracle Linux" /etc/*-release; then
        DISTRO='Oracle'
        PM='yum'
    elif grep -Eqi "Red Hat Enterprise Linux" /etc/issue || grep -Eq "Red Hat Enterprise Linux" /etc/*-release; then
        DISTRO='RHEL'
        PM='yum'
    elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
        DISTRO='Debian'
        PM='apt'
    elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
        DISTRO='Ubuntu'
        PM='apt'
    elif grep -Eqi "Raspbian" /etc/issue || grep -Eq "Raspbian" /etc/*-release; then
        DISTRO='Raspbian'
        PM='apt'
    elif grep -Eqi "Deepin" /etc/issue || grep -Eq "Deepin" /etc/*-release; then
        DISTRO='Deepin'
        PM='apt'
    elif grep -Eqi "Mint" /etc/issue || grep -Eq "Mint" /etc/*-release; then
        DISTRO='Mint'
        PM='apt'
    elif grep -Eqi "Kali" /etc/issue || grep -Eq "Kali" /etc/*-release; then
        DISTRO='Kali'
        PM='apt'
    else
        DISTRO='unknow'
    fi
    Get_OS_Bit
}

Get_OS_Bit()
{
    if [[ `getconf WORD_BIT` = '32' && `getconf LONG_BIT` = '64' ]] ; then
        Is_64bit='y'
    else
        Is_64bit='n'
    fi
}



# check if user is root
if [ $(id -u) != "0" ]; then
  echo "Error: you must be root to run this script, please use root"
  exit 1
fi

# check System Version
Get_Dist_Name

if [ "${DISTRO}" != "Debian" ]; then
  Echo_Red "Only Support Debian 9+"
  exit 1
elif [ "${DISTRO}" == "unknow" ]; then
  Echo_Red "Unable to get Linux distribution name, or do NOT support the current distribution."
  exit 1
fi

# choice change password
while :; do echo
  read -e -p "Do you want to change password? [y/n]: " chg_pwd_opt
  if [[ ! ${chg_pwd_opt} =~ ^[y,n]$ ]]; then
    Echo_Red "Input Error! Please only input 'y' or 'n'"
  else
    if [ "${chg_pwd_opt}" == 'y' ]; then
      while :; do echo
        Echo_Yellow "Enter new password for $(id -u -n) (Passowrd will not shown): "
        read -s NEW_ROOT_PASSWORD_1
        Echo_Yellow "Retype new password: "
        read -s NEW_ROOT_PASSWORD_2
        if [ "${NEW_ROOT_PASSWORD_1}" == "${NEW_ROOT_PASSWORD_2}" ]; then
          Echo_Green "OK, Password Input finish."
          break
        else
          Echo_Red "Sorry, password do not match"
        fi
      done
      NEW_ROOT_PASSWORD=${NEW_ROOT_PASSWORD_1}
      break
    else :
      break
    fi
    break  
  fi
done

# choice package update
while :; do echo
  read -e -p "Do you want to execute package update [y/n]? [default: y] " package_update_opt
  package_update_opt=${package_update_opt:-'y'}
  if [[ ! ${package_update_opt} =~ ^[y,n]$ ]]; then
    Echo_Red "Input Error! Please only input 'y' or 'n'"
  else :
    break
  fi
done

# choice BBR installation
while :; do echo
  read -e -p "Do you want to install BBR [y/n]? [default: y] " bbr_install_opt
  bbr_install_opt=${bbr_install_opt:-'y'}
  if [[ ! ${bbr_install_opt} =~ ^[y,n]$ ]]; then
    Echo_Red "Input Error! Please only input 'y' or 'n'"
  else :
    break
  fi
done

# choice custom setting
while :; do echo
  read -e -p "Do you want to take some custom setting [y/n]? [default: y] " custom_setting_opt
  custom_setting_opt=${custom_setting_opt:-'y'}
  if [[ ! ${custom_setting_opt} =~ ^[y,n]$ ]]; then
    Echo_Red "Input Error! Please only input 'y' or 'n'"
  else :
    break
  fi
done

# choice ssh port update
while :; do echo
  read -e -p "Do you want to update ssh port [y/n]? [default: y]" ssh_port_opt
  ssh_port_opt=${ssh_port_opt:-'y'}
  if [[ ! ${ssh_port_opt} =~ ^[y,n]$ ]]; then
    Echo_Red "Input Error! Please only input 'y' or 'n'"
  else :
    if [ "${ssh_port_opt}" == 'y' ]; then
      read -e -p  "Enter new SSH Port: " new_ssh_port
      read -e -p  "Enter new Github username, which hold the public key: [default: kbrx93]" github_key_user
      github_key_user=${github_key_user:-'kbrx93'}
      break
    else :
      break
    fi
    break
  fi
done

# choice Pip installation
while :; do echo
  read -e -p "Do you want to install Pip [y/n]? [default: n]" pip_install_opt
  pip_install_opt=${pip_install_opt:-'n'}
  if [[ ! ${pip_install_opt} =~ ^[y,n]$ ]]; then
    Echo_Red "Input Error! Please only input 'y' or 'n'"
  else :
    break
  fi
done

# choice Pyenv installation
while :; do echo
  read -e -p "Do you want to install Pyenv [y/n]? [default: n]" pyenv_install_opt
  pyenv_install_opt=${pyenv_install_opt:-'n'}
  if [[ ! ${pyenv_install_opt} =~ ^[y,n]$ ]]; then
    Echo_Red "Input Error! Please only input 'y' or 'n'"
  else :
    break
  fi
done

# choice ServerStatus installation
while :; do echo
  read -e -p "Do you want to install serverstatus [y/n]? [default: n]" serverstatus_install_opt
  serverstatus_install_opt=${serverstatus_install_opt:-'n'}
  if [[ ! ${serverstatus_install_opt} =~ ^[y,n]$ ]]; then
    Echo_Red "Input Error! Please only input 'y' or 'n'"
  else :
    break
  fi
done

# choice Oh_My_Zsh installation
while :; do echo
  read -e -p "Do you want to install oh my zsh [y/n]? [default: y]" ohmyzsh_install_opt
  ohmyzsh_install_opt=${ohmyzsh_install_opt:-'y'}
  if [[ ! ${ohmyzsh_install_opt} =~ ^[y,n]$ ]]; then
    Echo_Red "Input Error! Please only input 'y' or 'n'"
  else :
    break
  fi
done

Press_Start()
{
  echo ""
  Echo_Green "Press any key to install...or Press Ctrl+c to cancel"
  OLDCONFIG=`stty -g`
  stty -icanon -echo min 1 time 0
  dd count=1 2>/dev/null
  stty ${OLDCONFIG}
}

change_password()
{
  if [ $1 == 'y' ]; then
    echo "$(id -u -n):$2" | chpasswd
    if [[ "$?" = "0" ]]; then
      Echo_Green "----- change password success ! -----"
    else
      Echo_Red "----- change password failed :( -----"
      exit 1
    fi
  fi
}

package_update()
{
  if [ $1 == 'y' ]; then
    if command -v ${PM} &>/dev/null; then
      ${PM} update -y && apt upgrade -y
    else
      Echo_Red "Can not find apt-get !"
      exit 1
    fi
  fi
}

install_bbr()
{
  # 暂时不检测内核版本
  if [ $1 == 'y' ]; then
    echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf && echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf && sysctl -p
  fi
}

custom_setting()
{
  if [ $1 == 'y' ]; then
    echo > /etc/motd
    # set timezone
    timedatectl set-timezone Asia/Shanghai
    
    # turn off swap
    sed -ri 's/.*swap.*/#&/' /etc/fstab
    sudo swapoff -a
    
    ${PM} install sudo wget curl net-tools git zsh -y
    
    # change default shell to zsh
    chsh -s $(which zsh)
  fi
}



update_ssh_port()
{
  if [ $1 == 'y' ]; then
    # bash <(wget -N --no-check-certificate -qO- https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/ssh_port.sh)
    apt update -y && apt install -y curl && bash <(curl -fsSL https://file.kbrx93.com/directlink/1/public/share/key.sh) -og $2 -p $3 -d
  fi
}

install_pip(){
  if [ $1 == 'y' ]; then
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
  fi
}

install_pyenv()
{
  if [ $1 == 'y' ]; then
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
  fi
}

install_serverstatus()
{
  if [ $1 == 'y' ]; then
  # need
  apt install -y python3 python3-pip
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
ExecStart=/usr/bin/python3 client-linux.py SERVER=serverstatus.kbrx93.com USER="${serverNo}" PASSWORD=939393
Restart=always
User=root

[Install]
WantedBy=multi-user.target

EOF

systemctl enable clientServer.service --now
cd $HOME
  fi
}

install_ohmyzsh()
{
  if [ $1 == 'y' ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh) --skip-chsh"
  fi
}

Press_Start

change_password ${chg_pwd_opt} ${NEW_ROOT_PASSWORD}
package_update ${package_update_opt}
install_bbr ${bbr_install_opt}
custom_setting ${custom_setting_opt}
update_ssh_port ${ssh_port_opt} ${github_key_user} ${new_ssh_port}
install_pip ${pip_install_opt}
install_pyenv ${pyenv_install_opt}
install_serverstatus ${serverstatus_install_opt}
install_ohmyzsh ${ohmyzsh_install_opt}

