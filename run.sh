#!/bin/sh

usage() {
  local exit_code=${1:-0}
  echo "Usage in ${0##*/} [-opt]
Options (field in '<>' are required):
    -h This help
    -u \"<username;password>\"    Add a user
               required arg: \"<username>;<password>\"
               <username> for user
               <password> for user
" >&2
  exit $exit_code
}

adduser() {
  local name=$(sed -E 's|;.*$||' <<< $1) password=$(sed -E 's|^[^;]*;||' <<< $1)
  useradd -G wheel "${name}"
  if [ $? -ne 0 ]; then
    return 0
  fi
  echo -e "${password}\n${password}" | passwd "${name}"
}

created_file="/docker_container_created"

if [ ! -f ${created_file} ]; then
  while getopts "hu:" opt; do
    case "$opt" in
      h) usage ;;
      u) adduser "$OPTARG" ;;
    esac
  done
  shift $(( OPTIND - 1 ))
  touch ${created_file}
fi

exec /usr/sbin/sshd -D
