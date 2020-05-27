#!/bin/bash

# Grub2 Themes
set  -o errexit

[  GLOBAL::CONF  ]
{
readonly ROOT_UID=0
readonly Project_Name="GRUB2::THEMES"
readonly MAX_DELAY=20                               # max delay for user to enter root password
tui_root_login=

THEME_DIR="/usr/share/grub/themes"
REO_DIR="$(cd $(dirname $0) && pwd)"
}

#COLORS
CDEF=" \033[0m"                                     # default color
CCIN=" \033[0;36m"                                  # info color
CGSC=" \033[0;32m"                                  # success color
CRER=" \033[0;31m"                                  # error color
CWAR=" \033[0;33m"                                  # waring color
b_CDEF=" \033[1;37m"                                # bold default color
b_CCIN=" \033[1;36m"                                # bold info color
b_CGSC=" \033[1;32m"                                # bold success color
b_CRER=" \033[1;31m"                                # bold error color
b_CWAR=" \033[1;33m"                                # bold warning color

# echo like ...  with  flag type  and display message  colors
prompt () {
  case ${1} in
    "-s"|"--success")
      echo -e "${b_CGSC}${@/-s/}${CDEF}";;    # print success message
    "-e"|"--error")
      echo -e "${b_CRER}${@/-e/}${CDEF}";;    # print error message
    "-w"|"--warning")
      echo -e "${b_CWAR}${@/-w/}${CDEF}";;    # print warning message
    "-i"|"--info")
      echo -e "${b_CCIN}${@/-i/}${CDEF}";;    # print info message
    *)
    echo -e "$@"
    ;;
  esac
}

# Check command avalibility
function has_command() {
  command -v $1 > /dev/null
}

usage() {
  printf "%s\n" "Usage: ${0##*/} [OPTIONS...]"
  printf "\n%s\n" "OPTIONS:"
  printf "  %-25s%s\n" "-b, --boot" "install grub theme into /boot/grub/themes"
  printf "  %-25s%s\n" "-l, --slaze" "slaze grub theme"
  printf "  %-25s%s\n" "-s, --stylish" "stylish grub theme"
  printf "  %-25s%s\n" "-t, --tela" "tela grub theme"
  printf "  %-25s%s\n" "-v, --vimix" "vimix grub theme"
  printf "  %-25s%s\n" "-w, --white" "Install white icon version"
  printf "  %-25s%s\n" "-u, --ultrawide" "Install 2560x1080 background image - not available for slaze grub theme"
  printf "  %-25s%s\n" "-2, --2k" "Install 2k(2560x1440) background image"
  printf "  %-25s%s\n" "-4, --4k" "Install 4k(3840x2160) background image"
  printf "  %-25s%s\n" "-r, --remove" "Remove theme (must add theme name option)"
  printf "  %-25s%s\n" "-h, --help" "Show this help"
}

install() {
  if [[ ${theme} == 'slaze' ]]; then
    local name="Slaze"
  elif [[ ${theme} == 'stylish' ]]; then
    local name="Stylish"
  elif [[ ${theme} == 'tela' ]]; then
    local name="Tela"
  elif [[ ${theme} == 'vimix' ]]; then
    local name="Vimix"
  else
    prompt -i "\n Run ./install.sh -h for help or install dialog"
    install_dialog
    prompt -i "\n Run ./install.sh again!"
    exit 0
  fi

  if [[ ${screen} == '2k' ]]; then
    local screen="2k"
  elif [[ ${screen} == '4k' ]]; then
    local screen="4k"
  elif [[ ${screen} == '1080p_21:9' ]]; then
    local screen="1080p_21:9"
  else
    local screen="1080p"
  fi

  if [[ ${screen} == '1080p_21:9' && ${name} == 'Slaze' ]]; then
    prompt -e "ultrawide 1080p does not support Slaze theme"
    exit 1
  fi

  if [[ ${icon} == 'white' ]]; then
    local icon="white"
  else
    local icon="color"
  fi  
  
  # Checking for root access and proceed if it is present
  if [ "$UID" -eq "$ROOT_UID" ]; then
    clear

    # Create themes directory if not exists
    echo -e "\n Checking for the existence of themes directory..."

    [[ -d "${THEME_DIR}/${name}" ]] && rm -rf "${THEME_DIR}/${name}"
    mkdir -p "${THEME_DIR}/${name}"

    # Copy theme
    prompt -i "\n Installing ${name} ${icon} ${screen} theme..."

    cp -a "${REO_DIR}/common/"* "${THEME_DIR}/${name}"
    cp -a "${REO_DIR}/config/theme-${screen}.txt" "${THEME_DIR}/${name}/theme.txt"
    if [[ ${screen} == '1080p_21:9' ]]; then
      cp -a "${REO_DIR}/backgrounds/${screen}/background-${theme}.png" "${THEME_DIR}/${name}/background.png"
    else
      cp -a "${REO_DIR}/backgrounds/${screen}/background-${theme}.jpg" "${THEME_DIR}/${name}/background.jpg"
    fi
    cp -a "${REO_DIR}/assets/assets-${icon}/icons-${screen}" "${THEME_DIR}/${name}/icons"
    cp -a "${REO_DIR}/assets/assets-${icon}/select-${screen}/"*.png "${THEME_DIR}/${name}"

    # Set theme
    prompt -i "\n Setting ${name} as default..."

    # Backup grub config
    cp -an /etc/default/grub /etc/default/grub.bak

    grep "GRUB_THEME=" /etc/default/grub 2>&1 >/dev/null && sed -i '/GRUB_THEME=/d' /etc/default/grub
    grep "GRUB_GFXMODE=" /etc/default/grub 2>&1 >/dev/null && sed -i '/GRUB_GFXMODE=/d' /etc/default/grub

    # Edit grub config
    echo "GRUB_THEME=\"${THEME_DIR}/${name}/theme.txt\"" >> /etc/default/grub

    # Make sure set the right resolution for grub
    if [[ ${screen} == '1080p' ]]; then
      echo "GRUB_GFXMODE=1920x1080,auto" >> /etc/default/grub
    elif [[ ${screen} == '1080p_21:9' ]]; then
      echo "GRUB_GFXMODE=2560x1080,auto" >> /etc/default/grub
    elif [[ ${screen} == '4k' ]]; then
      echo "GRUB_GFXMODE=3840x2160,auto" >> /etc/default/grub
    elif [[ ${screen} == '2k' ]]; then
      echo "GRUB_GFXMODE=2560x1440,auto" >> /etc/default/grub
    fi

    # Update grub config
    prompt -i "\n Updating grub config...\n"

    updating_grub
  else
    # Error message
    prompt -e "\n [ Error! ] -> Run me as root! "

    # persisted execution of the script as root
    if [[ -n ${tui_root_login} ]] ; then
        if [[ -n "${theme}" && -n "${screen}" ]]; then
            sudo -S <<< ${tui_root_login} $0 ${ORIGINAL_ARGUMENTS}
        fi
    else
        read -p "[ Trusted ] Specify the root password : " -t${MAX_DELAY} -s
        [[ -n "$REPLY" ]] && {
        if [[ -n "${theme}" && -n "${screen}" ]]; then
            sudo -S <<< $REPLY $0 ${ORIGINAL_ARGUMENTS}
        fi
        } || {
             operation_canceled
        }
    fi

 fi
}

run_dialog() {
  if [[ -x /usr/bin/dialog ]]; then
    tui_root_login=$(dialog --backtitle ${Project_Name} \
          --title  "ROOT LOGIN" \
          --insecure \
          --passwordbox  "require  root  permission" 8 50 \
          --output-fd 1 )
    [[  -z ${tui_root_login} ]]  &&   exit  ${UID} 
    sudo -S  <<<  $tui_root_login   $0 
    test $? -eq 0  || { 
        prompt -e "\n [ Error! ] -> wrong passwords"
        exit  1 
    }
    tui=$(dialog --backtitle ${Project_Name} \
    --radiolist "Choose your Grub theme : " 15 40 5 \
      1 "Vimix Theme" off  \
      2 "Tela Theme" on \
      3 "Stylish Theme" off  \
      4 "Slaze Theme" off --output-fd 1 )
      case "$tui" in
        1) theme="vimix"     ;;
        2) theme="tela"      ;;
        3) theme="stylish"   ;;
        4) theme="slaze"     ;;
        *) operation_canceled ;;
     esac

    tui=$(dialog --backtitle ${Project_Name} \
    --radiolist "Choose icon style : " 15 40 5 \
      1 "white" off \
      2 "color" on --output-fd 1 )
      case "$tui" in
        1) icon="white"      ;;
        2) icon="color"      ;;
        *) operation_canceled ;;
     esac

    tui=$(dialog --backtitle ${Project_Name} \
    --radiolist "Choose your Display Resolution : " 15 40 5 \
      1 "1080p" on  \
      2 "1080p ultrawide" off  \
      3 "2k" off \
      4 "4k" off --output-fd 1 )
      case "$tui" in
        1) screen="1080p"    ;;
        2) screen="1080p_21:9"  ;;
        3) screen="2k"       ;;
        4) screen="4k"       ;;
        *) operation_canceled ;;
     esac
  fi
}

operation_canceled() {
  clear
  prompt  -i "\n Operation canceled by user, Bye!"
  exit 1
}

updating_grub() {
  if has_command update-grub; then
    update-grub
  elif has_command grub-mkconfig; then
    grub-mkconfig -o /boot/grub/grub.cfg
  elif has_command zypper; then
    grub2-mkconfig -o /boot/grub2/grub.cfg
  elif has_command dnf; then
    grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
  fi

  # Success message
  prompt -s "\n * All done!"
  prompt -w "\n * At the next restart of your computer you will see your new Grub theme: '$theme' "
}

install_dialog() {
  if [ ! "$(which dialog 2> /dev/null)" ]; then
    prompt -i "\n 'dialog' needs to be installed for this shell"
    if has_command zypper; then
      sudo zypper in dialog
    elif has_command apt-get; then
      sudo apt-get install dialog
    elif has_command dnf; then
      sudo dnf install -y dialog
    elif has_command yum; then
      sudo yum install dialog
    elif has_command pacman; then
      sudo pacman -S --noconfirm dialog
    fi
  fi
}

remove() {
  if [[ ${theme} == 'slaze' ]]; then
    local name="Slaze"
  elif [[ ${theme} == 'stylish' ]]; then
    local name="Stylish"
  elif [[ ${theme} == 'tela' ]]; then
    local name="Tela"
  elif [[ ${theme} == 'vimix' ]]; then
    local name="Vimix"
  else
    prompt -i "\n Run ./install.sh -h for help!"
    exit 0
  fi

  # Checking for root access and proceed if it is present
  if [ "$UID" -eq "$ROOT_UID" ]; then
    echo -e "\n Checking for the existence of themes directory..."
    if [[ -d "${THEME_DIR}/${name}" ]]; then
      rm -rf "${THEME_DIR}/${name}"
    else
      prompt -i "\n ${name} grub theme not exist!"
      exit 0
    fi

    # Backup grub config
    if [[ -f /etc/default/grub.bak ]]; then
      rm -rf /etc/default/grub && mv /etc/default/grub.bak /etc/default/grub
    else
      prompt -i "\n grub.bak not exist!"
      exit 0
    fi

    # Update grub config
    prompt -i "\n Resetting grub theme...\n"
    updating_grub

  else
    # Error message
    prompt -e "\n [ Error! ] -> Run me as root "

    # persisted execution of the script as root
    read -p "[ trusted ] specify the root password : " -t${MAX_DELAY} -s
    [[ -n "$REPLY" ]] && {
      if [[ -n "${theme}" ]]; then
        sudo -S <<< $REPLY $0 --remove --${theme}
      fi
    } || {
      operation_canceled
    }
  fi
}

# show terminal user interface for better use
if [[ $# -lt 1 ]] && [[ $UID -ne $ROOT_UID ]] && [[ -x /usr/bin/dialog ]] ; then
  run_dialog
fi

if [[ $# -lt 1 ]] && [[ $UID -ne $ROOT_UID ]] && [[ ! -x /usr/bin/dialog ]] ;  then
  # Error message
  prompt -e "\n [ Error! ] -> Run me as root! "

  # persisted execution of the script as root
  read -p "[ Trusted ] Specify the root password : " -t${MAX_DELAY} -s
  [[ -n "$REPLY" ]]&& {
   exec sudo -S <<< $REPLY $0
  }|| {
    operation_canceled
  }
fi

while [[ $# -ge 1 ]]; do
  ORIGINAL_ARGUMENTS="$ORIGINAL_ARGUMENTS $1"
  case "${1}" in
    -b|--boot)
      THEME_DIR="/boot/grub/themes"
      ;;
    -l|--slaze)
      theme='slaze'
      ;;
    -s|--stylish)
      theme='stylish'
      ;;
    -t|--tela)
      theme='tela'
      ;;
    -v|--vimix)
      theme='vimix'
      ;;
    -w|--white)
      icon='white'
      ;;
    -c|--color)
      icon='color'
      ;;
    -1|--1080p)
      screen='1080p'
      ;;
    -2|--2k)
      screen='2k'
      ;;
    -4|--4k)
      screen='4k'
      ;;
    -u|--ultrawide|--1080p_21:9)
      screen='1080p_21:9'
      ;;
    -r|--remove)
      remove='true'
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      prompt  -e "\n ERROR: Unrecognized installation option '$1'."
      prompt  -i "Try '$0 --help' for more information."
      exit 1
      ;;
  esac
  shift
done

if [[ "${remove:-}" != 'true' ]]; then
  install
elif [[ "${remove:-}" == 'true' ]]; then
  remove
fi

exit 0
