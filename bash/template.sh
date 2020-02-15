#!/usr/bin/env bash
export PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin"

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

# check if user is root
if [[ $(id -u) != "0" ]]; then
  echo "Error: You must be root to run this script, please use root and run again."
  exit 1
fi

__kscript_version="0.1"
# source some file here

# Set magic variables for current file or dir
__dir="$(cd "$(dirname "$0")" && pwd)"
__file="${__dir}/$(basename "$0")"
__base="$(basename ${__file} .sh)"
__root=$(cd "$(dirname "${__dir}")" && pwd)

Color_Text()
{
  echo -e "\e[0;$2m$1\e[0m"
}

Echo_Red()
{
  echo $(Color_Text "$1" "31")
}

Echo_Green()
{
  echo $(Color_Text "$1" "32")
}

func1(){
  #do something
  # Echo_Red "${__kscript_version}"
  Echo_Red "${@:-2}"
}

func2(){
  #do something
  Echo_Green "${__kscript_version}"
}

main()
{
  func1 "$@"
  func2 "$@"
}

main "$@"