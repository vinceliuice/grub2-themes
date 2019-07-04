#!/bin/bash

# Grub2 Dark Theme

ROOT_UID=0
THEME_DIR="/boot/grub/themes"
THEME_DIR_2="/boot/grub2/themes"
G_SNAP="themes_ori.tar.gz"                          # name of archive file  used to restore default grub theme 

REO_DIR=$(cd $(dirname $0) && pwd)

MAX_DELAY=20                                        # max delay for user to enter root password

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
  printf "  %-25s%s\n" "-l, --slaze" "slaze grub theme"
  printf "  %-25s%s\n" "-s, --stylish" "stylish grub theme"
  printf "  %-25s%s\n" "-t, --tela" "tela grub theme"
  printf "  %-25s%s\n" "-v, --vimix" "vimix grub theme"
  printf "  %-25s%s\n" "-h, --help" "Show this help"
  printf "  %-25s%s\n" "-r, --restore" "Restore default themes"
  
}

#  [spnap shot] :=> boot to prepare for uninstall 
freezing_snapshot() {  
    declare -ar grub=(
        "grub"          # ---> reference to THEME_DIR 
        "grub2"         # ---> reference to THEME_DIR_2 
    ) 
    local format 
    local current_grub  

{ #[ auto_detect_grub_type ] 
    for grub_type in $(ls -d /boot/*/)  ; do 
        if  [[ -d ${grub_type} ]] ; then
            format=${grub_type%*/} 
            current_grub="${format##*/}"
            for grub_target in ${grub[@]} ; do
                [[ ${current_grub} == ${grub_target} ]]  && break   
            done 
        fi 
    done  
}   

    local use_related_dir 
    case "${current_grub}" in 
        "${grub}") use_related_dir=${THEME_DIR};; 
        "${grub[1]}")use_related_dir=${THEME_DIR_2};; 
   esac 

   if [[ -n $1 ]] ; then 
       case ${1} in 
           "--no-snap") echo "${use_related_dir}";;       #  /boot/[grub|grup2]/themes
       esac
   else
       local themes_folder=${use_related_dir##*/}         # extract themes folder
       if [[ ! -f ${use_related_dir/themes/}$G_SNAP ]] ; then 
           prompt -i "* freezing default themes..."  
           cd ${use_related_dir/$themes_folder/}
           [[  $? -eq 0 ]] || prompt -e "cannot change directory"  
           sudo tar -zcf ${G_SNAP}  "${themes_folder}/"
           [[ $? -eq 0 ]] && {
                prompt -i "snap shot forzen "  
           }||{
                prompt -e "[x] cannot freeze default themes"
           }
       else 
           prompt -i "[escaping] snapshot ..."
    fi
fi

}

uninstall() {

    local related_path=$(freezing_snapshot --no-snap) 
    local archive_path="${related_path/themes/}/${G_SNAP}" 
    [[ ! -f ${archive_path} ]] && { 
    prompt -w "not allowed to proceed uninstallation X( !!"
    sleep 2 
    exit 12
    }|| {
     prompt -w "-- uninstalling  Grub2-Themes"   
     prompt -i "removing installed directories ..." 
     if [[ -n $(sudo ls -r "${related_path}/") ]] ; then
         sudo rm -r ${related_path}/* 
         [[ $? -eq 0 ]] && {
            prompt -s "removed" 
            prompt -i "restor default themes" 
            sleep 2 
            sudo tar -zxf ${related_path/themes/}${G_SNAP} --directory "${related_path/themes/}" 
            [[ $? -eq 0 ]] &&  {
                prompt -s "default themes successfully restored" 
                prompt -w "deleting archive file ..." 
                sleep 2 
                [[ $(sudo rm  "$archive_path") -eq 0 ]] &&{ 
                    prompt -s "[ done ]"   
                    exit 0 
                }||{    
                   prompt -e "no deletable archive file" 
                   exit 3
                } 
            } 
        }|| {
            prompt -e "[ deletion error] connot remove  directories" 
            exit 2 
        }
    else 
        prompt -e "[ Fatal Error ] Empty themes ..."
    fi 
     
    } 
}



install() { 
  freezing_snapshot
  if [[ ${theme} == 'slaze' ]]; then
    local name="Slaze"
  elif [[ ${theme} == 'stylish' ]]; then
    local name="Stylish"
  elif [[ ${theme} == 'tela' ]]; then
    local name="Tela"
  elif [[ ${theme} == 'vimix' ]]; then
    local name="Vimix"
  else
    prompt -i "\n Run sudo ./install.sh again! or run ./install.sh -h for help"
    exit 0
  fi

  # Checking for root access and proceed if it is present
  if [ "$UID" -eq "$ROOT_UID" ]; then

    # Create themes directory if not exists
    echo -e "\n Checking for the existence of themes directory..."

    [[ -d ${THEME_DIR}/${name} ]] && rm -rf ${THEME_DIR}/${name}
    [[ -d ${THEME_DIR_2}/${name} ]] && rm -rf ${THEME_DIR_2}/${name}
    [[ -d /boot/grub ]] && mkdir -p ${THEME_DIR}/${name}
    [[ -d /boot/grub2 ]] && mkdir -p ${THEME_DIR_2}/${name}

    # Copy theme
    prompt -i "\n Installing ${name} theme..."

    if [ -d /boot/grub ]; then
      cp -a ${REO_DIR}/common/* ${THEME_DIR}/${name}
      cp -a ${REO_DIR}/backgrounds/background-${theme}.jpg ${THEME_DIR}/${name}/background.jpg

      if [ ${theme} == 'tela' ]; then
        cp -a ${REO_DIR}/assets/assets-tela/icons ${THEME_DIR}/${name}
        cp -a ${REO_DIR}/assets/assets-tela/select/*.png ${THEME_DIR}/${name}
      else
        cp -a ${REO_DIR}/assets/assets-white/icons ${THEME_DIR}/${name}
        cp -a ${REO_DIR}/assets/assets-white/select/*.png ${THEME_DIR}/${name}
      fi
    fi

    if [ -d /boot/grub2 ]; then
      cp -a ${REO_DIR}/common/* ${THEME_DIR_2}/${name}
      cp -a ${REO_DIR}/backgrounds/background-${theme}.jpg ${THEME_DIR_2}/${name}/background.jpg

      if [ ${theme} == 'tela' ]; then
        cp -a ${REO_DIR}/assets/assets-tela/icons ${THEME_DIR_2}/${name}
        cp -a ${REO_DIR}/assets/assets-tela/select/*.png ${THEME_DIR_2}/${name}
      else
        cp -a ${REO_DIR}/assets/assets-white/icons ${THEME_DIR_2}/${name}
        cp -a ${REO_DIR}/assets/assets-white/select/*.png ${THEME_DIR_2}/${name}
      fi
    fi

    # Set theme
    prompt -i "\n Setting ${name} as default..."
    grep "GRUB_THEME=" /etc/default/grub 2>&1 >/dev/null && sed -i '/GRUB_THEME=/d' /etc/default/grub

    [[ -d /boot/grub ]] && echo "GRUB_THEME=\"${THEME_DIR}/${name}/theme.txt\"" >> /etc/default/grub
    [[ -d /boot/grub2 ]] && echo "GRUB_THEME=\"${THEME_DIR_2}/${name}/theme.txt\"" >> /etc/default/grub

    # Update grub config
    prompt -i "\n Updating grub config..."
    if has_command update-grub; then
      update-grub
    elif has_command grub-mkconfig; then
      grub-mkconfig -o /boot/grub/grub.cfg
    elif has_command grub2-mkconfig; then
      grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
    fi

    # Success message
    prompt -s "\n * All done!"
    prompt -w "\n * At the next restart of your computer you will see your new Grub theme: '$theme' "

  else
    # Error message
    prompt -e "\n [ Error!] -> Run me as root "

    # persisted execution of the script as root
    read -p "[ trusted ] specify the root password : " -t${MAX_DELAY} -s
    [[ -n "$REPLY" ]]&& {
      if  [[  -n  "${theme}" ]]  ; then
        sudo -S <<< $REPLY $0 --${theme}
      fi
    }|| {
      prompt  "\n Operation canceled  Bye"
      exit 1
    }
  fi
}

run_dialog() {
  if [[ -x /usr/bin/dialog ]]; then
    tui=$(dialog --backtitle "GRUB2 THEMES" \
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
        *) prompt "Canceled" ;;
     esac
  fi
}

install_dialog() {
  if [ ! "$(which dialog 2> /dev/null)" ]; then
    prompt -i "\n 'dialog' needs to be installed for this shell"
    if has_command zypper; then

      sudo zypper in dialog
        elif has_command apt-get; then

      sudo apt-get install dialog
        elif has_command dnf; then

      sudo dnf install dialog
        elif has_command yum; then

      sudo yum install dialog
        elif has_command pacman; then

      sudo pacman -S --noconfirm dialog
    fi
  fi
}

# show terminal user interface for better use
if [[ $# -lt 1 ]] && [[ $UID -eq $ROOT_UID ]]; then
  run_dialog
fi

if [[ $# -lt 1 ]] && [[ $UID -ne $ROOT_UID ]]; then
  # Error message
  prompt -e "\n [ Error!] -> Run me as root "

  # persisted execution of the script as root
  read -p "[ trusted ] specify the root password : " -t${MAX_DELAY} -s
  [[ -n "$REPLY" ]]&& {
   exec sudo -S <<< $REPLY $0
  }|| {
    prompt  "\n Operation canceled  Bye"
    exit 1
  }
fi

while [[ $# -ge 1 ]]; do
  case "${1}" in
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
    -h|--help)
      usage
      exit 0
      ;; 
  -r|--restore) 
      uninstall 
      ;;
    *)
      prompt  -e "\n ERROR: Unrecognized installation option '$1'."
      prompt  -i "\n Try '$0 --help' for more information."
      exit 1
      ;;
  esac
  shift
done

install_dialog && install

exit 0
