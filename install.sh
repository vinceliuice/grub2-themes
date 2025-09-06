#! /usr/bin/env bash

# Exit Immediately if a command fails
set -o errexit

readonly ROOT_UID=0
readonly Project_Name="GRUB2::THEMES"
readonly MAX_DELAY=20                               # max delay for user to enter root password
tui_root_login=

THEME_DIR="/usr/share/grub/themes"
REO_DIR="$(cd $(dirname $0) && pwd)"

THEME_VARIANTS=('tela' 'vimix' 'stylish' 'whitesur')
ICON_VARIANTS=('color' 'white' 'whitesur')
SCREEN_VARIANTS=('1080p' '2k' '4k' 'ultrawide' 'ultrawide2k')
custom_resolution=""

#################################
#   :::::: C O L O R S ::::::   #
#################################

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

#######################################
#   :::::: F U N C T I O N S ::::::   #
#######################################

# echo like ... with flag type and display message colors
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

# Check command availability
function has_command() {
  command -v $1 &> /dev/null #with "&>", all output will be redirected.
}

usage() {
cat << EOF

Usage: $0 [OPTION]...

OPTIONS:
  -t, --theme                 theme variant(s)          [tela|vimix|stylish|whitesur]       (default is tela)
  -i, --icon                  icon variant(s)           [color|white|whitesur]              (default is color)
  -s, --screen                screen display variant(s) [1080p|2k|4k|ultrawide|ultrawide2k] (default is 1080p)
  -c, --custom-resolution     set custom resolution     (e.g., 1600x900)                    (disabled in default)
  -r, --remove                remove theme              [tela|vimix|stylish|whitesur]       (must add theme name option, default is tela)

  -b, --boot                  install theme into '/boot/grub' or '/boot/grub2'
  -g, --generate              do not install but generate theme into chosen directory       (must add your directory)

  -h, --help                  show this help

EOF
}

generate() {
  if [[ "${install_boot}" == 'true' ]]; then
    if [[ -d "/boot/grub" ]]; then
      THEME_DIR='/boot/grub/themes'
    fi
    if [[ -d "/boot/grub2" ]]; then
      THEME_DIR='/boot/grub2/themes'
    fi
  fi

  # Make a themes directory if it doesn't exist
  prompt -i "\n Checking for the existence of themes directory..."

  [[ -d "${THEME_DIR}/${theme}" ]] && rm -rf "${THEME_DIR}/${theme}"
  mkdir -p "${THEME_DIR}/${theme}"

  # Copy theme
  prompt -i "\n Installing ${theme} ${icon} ${screen} theme..."

  # Don't preserve ownership because the owner will be root, and that causes the script to crash if it is ran from terminal by sudo
  cp -a --no-preserve=ownership "${REO_DIR}/common/"*.pf2 "${THEME_DIR}/${theme}"
  cp -a --no-preserve=ownership "${REO_DIR}/config/theme-${screen}.txt" "${THEME_DIR}/${theme}/theme.txt"
  cp -a --no-preserve=ownership "${REO_DIR}/backgrounds/${screen}/background-${theme}.jpg" "${THEME_DIR}/${theme}/background.jpg"

  # Function to determine which assets to use based on resolution
  get_asset_type() {
    local width=$(echo $1 | cut -d'x' -f1)
    local height=$(echo $1 | cut -d'x' -f2)
    if [ $width -le 1920 ] && [ $height -le 1080 ]; then
      echo "1080p"
    elif [ $width -le 2560 ] && [ $height -le 1440 ]; then
      echo "2k"
    else
      echo "4k"
    fi
  }

  # Determine which configuration file and assets to use
  if [[ -n "$custom_resolution" ]]; then
    if has_command apt || has_command pacman || has_command eopkg; then
      install_depends imagemagick
    else
      install_depends ImageMagick
    fi
    asset_type=$(get_asset_type "$custom_resolution")
    cp -a --no-preserve=ownership "${REO_DIR}/config/theme-${asset_type}.txt" "${THEME_DIR}/${theme}/theme.txt"
    # Replace resolution in theme.txt
    sed -i "s/[0-9]\+x[0-9]\+/${custom_resolution}/" "${THEME_DIR}/${theme}/theme.txt"
    # Use appropriate background as base and resize it
    cp -a --no-preserve=ownership "${REO_DIR}/backgrounds/${asset_type}/background-${theme}.jpg" "${THEME_DIR}/${theme}/background.jpg"
    magick "${THEME_DIR}/${theme}/background.jpg" -resize ${custom_resolution}^ -gravity center -extent ${custom_resolution} "${THEME_DIR}/${theme}/background.jpg"
  else
    cp -a --no-preserve=ownership "${REO_DIR}/config/theme-${screen}.txt" "${THEME_DIR}/${theme}/theme.txt"
    cp -a --no-preserve=ownership "${REO_DIR}/backgrounds/${screen}/background-${theme}.jpg" "${THEME_DIR}/${theme}/background.jpg"
  fi

  # Use custom background.jpg as grub background image
  if [[ -f "${REO_DIR}/background.jpg" ]]; then
    if has_command apt || has_command pacman || has_command eopkg; then
      install_depends imagemagick
    else
      install_depends ImageMagick
    fi
    prompt -w "\n Using custom background.jpg as grub background image..."
    cp -a --no-preserve=ownership "${REO_DIR}/background.jpg" "${THEME_DIR}/${theme}/background.jpg"
    magick "${THEME_DIR}/${theme}/background.jpg" -auto-orient "${THEME_DIR}/${theme}/background.jpg"
  fi

  # Determine which assets to use based on custom resolution or screen
  if [[ -n "$custom_resolution" ]]; then
    asset_type=$(get_asset_type "$custom_resolution")
    cp -a --no-preserve=ownership "${REO_DIR}/assets/assets-${icon}/icons-${asset_type}" "${THEME_DIR}/${theme}/icons"
    cp -a --no-preserve=ownership "${REO_DIR}/assets/assets-select/select-${asset_type}/"*.png "${THEME_DIR}/${theme}"
    cp -a --no-preserve=ownership "${REO_DIR}/assets/info-${asset_type}.png" "${THEME_DIR}/${theme}/info.png"
  elif [[ ${screen} == 'ultrawide' ]]; then
    cp -a --no-preserve=ownership "${REO_DIR}/assets/assets-${icon}/icons-1080p" "${THEME_DIR}/${theme}/icons"
    cp -a --no-preserve=ownership "${REO_DIR}/assets/assets-select/select-1080p/"*.png "${THEME_DIR}/${theme}"
    cp -a --no-preserve=ownership "${REO_DIR}/assets/info-1080p.png" "${THEME_DIR}/${theme}/info.png"
  elif [[ ${screen} == 'ultrawide2k' ]]; then
    cp -a --no-preserve=ownership "${REO_DIR}/assets/assets-${icon}/icons-2k" "${THEME_DIR}/${theme}/icons"
    cp -a --no-preserve=ownership "${REO_DIR}/assets/assets-select/select-2k/"*.png "${THEME_DIR}/${theme}"
    cp -a --no-preserve=ownership "${REO_DIR}/assets/info-2k.png" "${THEME_DIR}/${theme}/info.png"
  else
    cp -a --no-preserve=ownership "${REO_DIR}/assets/assets-${icon}/icons-${screen}" "${THEME_DIR}/${theme}/icons"
    cp -a --no-preserve=ownership "${REO_DIR}/assets/assets-select/select-${screen}/"*.png "${THEME_DIR}/${theme}"
    cp -a --no-preserve=ownership "${REO_DIR}/assets/info-${screen}.png" "${THEME_DIR}/${theme}/info.png"
  fi
}

install() {
  local theme=${1}
  local icon=${2}
  local screen=${3}

  # Check for root access and proceed if it is present
  if [[ "$UID" -eq "$ROOT_UID" ]]; then
    # Generate the theme in "/usr/share/grub/themes"
    generate "${theme}" "${icon}" "${screen}"

    # Set theme
    prompt -i "\n Setting ${theme} as default..."

    # Backup grub config
    if [[ -f /etc/default/grub.bak ]]; then
      prompt -w "\n File '/etc/default/grub.bak' already exists!"
#      read choice
#      if [[ "$choice" = 'y' ]]; then
#        cp -a /etc/default/grub /etc/default/grub.bak
#      else
#        prompt -s "Skipping to save a backup configuration in '/etc/default/grub.bak'"
#      fi
    else
      cp -an /etc/default/grub /etc/default/grub.bak
    fi

    # Fedora workaround to fix the missing unicode.pf2 file (tested on fedora 34): https://bugzilla.redhat.com/show_bug.cgi?id=1739762
    # This occurs when we add a theme on grub2 with Fedora.
    if has_command dnf; then
      if [[ -f "/boot/grub2/fonts/unicode.pf2" ]]; then
        if grep "GRUB_FONT=" /etc/default/grub 2>&1 >/dev/null; then
          #Replace GRUB_FONT
          sed -i "s|.*GRUB_FONT=.*|GRUB_FONT=/boot/grub2/fonts/unicode.pf2|" /etc/default/grub
        else
          #Append GRUB_FONT
          echo "GRUB_FONT=/boot/grub2/fonts/unicode.pf2" >> /etc/default/grub
        fi
      elif [[ -f "/boot/efi/EFI/fedora/fonts/unicode.pf2" ]]; then
        if grep "GRUB_FONT=" /etc/default/grub 2>&1 >/dev/null; then
          #Replace GRUB_FONT
          sed -i "s|.*GRUB_FONT=.*|GRUB_FONT=/boot/efi/EFI/fedora/fonts/unicode.pf2|" /etc/default/grub
        else
          #Append GRUB_FONT
          echo "GRUB_FONT=/boot/efi/EFI/fedora/fonts/unicode.pf2" >> /etc/default/grub
        fi
      fi
    fi

    if grep "GRUB_THEME=" /etc/default/grub 2>&1 >/dev/null; then
      #Replace GRUB_THEME
      sed -i "s|.*GRUB_THEME=.*|GRUB_THEME=\"${THEME_DIR}/${theme}/theme.txt\"|" /etc/default/grub
    else
      #Append GRUB_THEME
      echo "GRUB_THEME=\"${THEME_DIR}/${theme}/theme.txt\"" >> /etc/default/grub
    fi

    if grep "GRUB_BACKGROUND=" /etc/default/grub 2>&1 >/dev/null; then
      # remove GRUB_BACKGROUND
      sed -i "s|.*GRUB_BACKGROUND=.*||" /etc/default/grub
    fi

    # Make sure the right resolution for grub is set
    if [[ -n "$custom_resolution" ]]; then
      gfxmode="GRUB_GFXMODE=${custom_resolution},auto"
    elif [[ ${screen} == '1080p' ]]; then
      gfxmode="GRUB_GFXMODE=1920x1080,auto"
    elif [[ ${screen} == 'ultrawide' ]]; then
      gfxmode="GRUB_GFXMODE=2560x1080,auto"
    elif [[ ${screen} == '4k' ]]; then
      gfxmode="GRUB_GFXMODE=3840x2160,auto"
    elif [[ ${screen} == '2k' ]]; then
      gfxmode="GRUB_GFXMODE=2560x1440,auto"
    elif [[ ${screen} == 'ultrawide2k' ]]; then
      gfxmode="GRUB_GFXMODE=3440x1440,auto"
    fi

    if grep "GRUB_GFXMODE=" /etc/default/grub 2>&1 >/dev/null; then
      #Replace GRUB_GFXMODE
      sed -i "s|.*GRUB_GFXMODE=.*|${gfxmode}|" /etc/default/grub
    else
      #Append GRUB_GFXMODE
      echo "${gfxmode}" >> /etc/default/grub
    fi

    if grep "GRUB_TERMINAL=console" /etc/default/grub 2>&1 >/dev/null || grep "GRUB_TERMINAL=\"console\"" /etc/default/grub 2>&1 >/dev/null; then
      #Replace GRUB_TERMINAL
      sed -i "s|.*GRUB_TERMINAL=.*|#GRUB_TERMINAL=console|" /etc/default/grub
    fi

    if grep "GRUB_TERMINAL_OUTPUT=console" /etc/default/grub 2>&1 >/dev/null || grep "GRUB_TERMINAL_OUTPUT=\"console\"" /etc/default/grub 2>&1 >/dev/null; then
      #Replace GRUB_TERMINAL_OUTPUT
      sed -i "s|.*GRUB_TERMINAL_OUTPUT=.*|#GRUB_TERMINAL_OUTPUT=console|" /etc/default/grub
    fi

    # For Kali linux
    if [[ -f "/etc/default/grub.d/kali-themes.cfg" && ! -f "/etc/default/grub.d/kali-themes.cfg.bak" ]]; then
      cp -an /etc/default/grub.d/kali-themes.cfg /etc/default/grub.d/kali-themes.cfg.bak
      sed -i "s|.*GRUB_GFXMODE=.*|${gfxmode}|" /etc/default/grub.d/kali-themes.cfg
      sed -i "s|.*GRUB_THEME=.*|GRUB_THEME=\"${THEME_DIR}/${theme}/theme.txt\"|" /etc/default/grub.d/kali-themes.cfg
    fi

    # Update grub config
    prompt -i "\n Updating grub config... \n"
    updating_grub
    prompt -w "\n * At the next restart of your computer you will see your new Grub theme: '$theme' \n"

  #Check if password is cached (if cache timestamp has not expired yet)
  elif sudo -n true 2> /dev/null && echo; then
    if [[ -n "$custom_resolution" ]]; then
      if [[ "${install_boot}" == 'true' ]]; then
        sudo "$0" -t ${theme} -i ${icon} -c ${custom_resolution} -b
      else
        sudo "$0" -t ${theme} -i ${icon} -c ${custom_resolution}
      fi
    else
      if [[ "${install_boot}" == 'true' ]]; then
        sudo "$0" -t ${theme} -i ${icon} -s ${screen} -b
      else
        sudo "$0" -t ${theme} -i ${icon} -s ${screen}
      fi
    fi
  else
    #Ask for password
    if [[ -n ${tui_root_login} ]] ; then
      if [[ -n "${theme}" && -n "${screen}" ]]; then
        if [[ "${install_boot}" == 'true' ]]; then
          sudo -S $0 -t ${theme} -i ${icon} -s ${screen} -b <<< ${tui_root_login}
        else
          sudo -S $0 -t ${theme} -i ${icon} -s ${screen} <<< ${tui_root_login}
        fi
      elif [[ -n "$custom_resolution" ]]; then
        if [[ "${install_boot}" == 'true' ]]; then
          sudo -S $0 -t ${theme} -i ${icon} -c ${custom_resolution} -b <<< ${tui_root_login}
        else
          sudo -S $0 -t ${theme} -i ${icon} -c ${custom_resolution} <<< ${tui_root_login}
        fi
      fi
    else
      prompt -e "\n [ Error! ] -> Run me as root! "
      read -r -p " [ Trusted ] Specify the root password : " -t ${MAX_DELAY} -s
      if sudo -S echo <<< $REPLY 2> /dev/null && echo; then
        #Correct password, use with sudo's stdin
        if [[ -n "$custom_resolution" ]]; then
          if [[ "${install_boot}" == 'true' ]]; then
            sudo "$0" -t ${theme} -i ${icon} -c ${custom_resolution} -b <<< ${REPLY}
          else
            sudo "$0" -t ${theme} -i ${icon} -c ${custom_resolution} <<< ${REPLY}
          fi
        else
          if [[ "${install_boot}" == 'true' ]]; then
            sudo "$0" -t ${theme} -i ${icon} -s ${screen} -b <<< ${REPLY}
          else
            sudo "$0" -t ${theme} -i ${icon} -s ${screen} <<< ${REPLY}
          fi
        fi
      else
        #block for 3 seconds before allowing another attempt
        sleep 3
        prompt -e "\n [ Error! ] -> Incorrect password!\n"
        exit 1
      fi
    fi
  fi
}

run_dialog() {
  if [[ -x /usr/bin/dialog ]]; then
    if [[ "$UID" -ne "$ROOT_UID"  ]]; then
      #Check if password is cached (if cache timestamp not expired yet)
      if sudo -n true 2> /dev/null && echo; then
        #No need to ask for password
        sudo $0
      else
        #Ask for password
        tui_root_login=$(dialog --backtitle ${Project_Name} \
        --title  "ROOT LOGIN" \
        --insecure \
        --passwordbox  "require root permission" 8 50 \
        --output-fd 1 )

        if sudo -S echo <<< $tui_root_login 2> /dev/null && echo; then
          #Correct password, use with sudo's stdin
          sudo -S "$0" <<< $tui_root_login
        else
          #block for 3 seconds before allowing another attempt
          sleep 3
          prompt -e "\n [ Error! ] -> Incorrect password!\n"
          exit 1
        fi
      fi
    fi

    tui=$(dialog --backtitle ${Project_Name} \
    --radiolist "Choose your Grub theme background picture : " 15 40 5 \
      1 "Vimix Theme" off  \
      2 "Tela Theme" on \
      3 "Stylish Theme" off  \
      4 "WhiteSur Theme" off --output-fd 1 )
      case "$tui" in
        1) theme="vimix"      ;;
        2) theme="tela"       ;;
        3) theme="stylish"    ;;
        4) theme="whitesur"   ;;
        *) operation_canceled ;;
     esac

    tui=$(dialog --backtitle ${Project_Name} \
    --radiolist "Choose icon style : " 15 40 5 \
      1 "white" off \
      2 "color" on \
      3 "whitesur" off --output-fd 1 )
      case "$tui" in
        1) icon="white"       ;;
        2) icon="color"       ;;
        3) icon="whitesur"    ;;
        *) operation_canceled ;;
     esac

    tui=$(dialog --backtitle ${Project_Name} \
    --radiolist "Choose your Display Resolution : " 15 40 5 \
      1 "1080p (1920x1080)" on  \
      2 "1080p ultrawide (2560x1080)" off  \
      3 "2k (2560x1440)" off \
      4 "4k (3840x2160)" off \
      5 "1440p ultrawide (3440x1440)" off --output-fd 1 )
      case "$tui" in
        1) screen="1080p"       ;;
        2) screen="ultrawide"   ;;
        3) screen="2k"          ;;
        4) screen="4k"          ;;
        5) screen="ultrawide2k" ;;
        *) operation_canceled   ;;
     esac

     # clear
     echo -e '\0033\0143'
  fi
}

operation_canceled() {
  prompt -i "\n Operation canceled by user, Bye!"
  exit 1
}

updating_grub() {
  if has_command update-grub; then
    update-grub
  elif has_command grub-mkconfig; then
    grub-mkconfig -o /boot/grub/grub.cfg
  # Check for OpenSuse (regular or microOS)
  elif has_command zypper || has_command transactional-update; then
    grub2-mkconfig -o /boot/grub2/grub.cfg
  # Check for Fedora (regular or Atomic)
  elif has_command dnf || has_command rpm-ostree; then
    # Check for BIOS
    if [[ -f /boot/grub2/grub.cfg ]]; then
      prompt -s "Find config file on /boot/grub2/grub.cfg ...\n"
      grub2-mkconfig -o /boot/grub2/grub.cfg
    # Check for UEFI
    elif [[ -f /boot/efi/EFI/fedora/grub.cfg ]]; then
      prompt -s "Find config file on /boot/efi/EFI/fedora/grub.cfg ...\n"
      grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
    fi

    if [[ -f /boot/grub2/grub.cfg && -f /boot/efi/EFI/fedora/grub.cfg ]]; then
      prompt -w "\n Under EFI, GRUB2 looks for its configuration in /boot/efi/EFI/fedora/grub.cfg,\n however the postinstall script of grub2-common installs a small shim which chains to the standard configuration at /boot/grub2/grub.cfg which is generated above.\n To reset this shim to defaults, delete the existing /boot/efi/EFI/fedora/grub.cfg and then reinstall grub2-common."

      prompt -i "\n  sudo rm -f /boot/efi/EFI/fedora/grub.cfg"
      prompt -i "sudo dnf reinstall grub2-common"
    fi
  fi

  # Success message
  prompt -s "\n * All done!"
}

function install_program () {
  if has_command zypper; then
    zypper in -y "$@"
  elif has_command swupd; then
    swupd bundle-add "$@"
  elif has_command apt-get; then
    apt-get install "$@"
  elif has_command dnf; then
    dnf install -y "$@"
  elif has_command yum; then
    yum install -y "$@"
  elif has_command pacman; then
    pacman -Syyu --noconfirm --needed "$@"
  elif has_command xbps-install; then
    xbps-install -Sy "$@"
  elif has_command eopkg; then
    eopkg -y install "$@"
  fi
}

install_depends() {
  local depend=${1}

  if [ ! "$(which '${depend}' 2> /dev/null)" ]; then
    prompt -w "\n '${depend}' need to be installed for this shell"
    install_program "${depend}"
  fi
}

remove() {
  local theme=${1}

  # Check for root access and proceed if it is present
  if [ "$UID" -eq "$ROOT_UID" ]; then
    prompt -i "Checking for the existence of themes directory..."
    if [[ -d "${THEME_DIR}/${theme}" ]]; then
      prompt -i "\n Find installed theme: '${THEME_DIR}/${theme}'..."
      rm -rf "${THEME_DIR}/${theme}"
      prompt -w "\n Removed: '${THEME_DIR}/${theme}'..."
    elif [[ -d "/boot/grub/themes/${theme}" ]]; then
      prompt -i "\n Find installed theme: '/boot/grub/themes/${theme}'..."
      rm -rf "/boot/grub/themes/${theme}"
      prompt -w "\n Removed: '/boot/grub/themes/${theme}'..."
    elif [[ -d "/boot/grub2/themes/${theme}" ]]; then
      prompt -i "\n Find installed theme: '/boot/grub2/themes/${theme}'..."
      rm -rf "/boot/grub2/themes/${theme}"
      prompt -w "\n Removed: '/boot/grub2/themes/${theme}'..."
    else
      prompt -e "\n Specified ${theme} theme does not exist!"
      exit 0
    fi

    local grub_config_location=""

    if [[ -f "/etc/default/grub" ]]; then
      grub_config_location="/etc/default/grub"
    elif [[ -f "/etc/default/grub.d/kali-themes.cfg" ]]; then
      grub_config_location="/etc/default/grub.d/kali-themes.cfg"
    else
      prompt -e "\n Cannot find grub config file in default locations!"
      prompt -w "\n Please inform the developers by opening an issue on github."
      prompt -i "\n Exiting..."
      exit 1
    fi

    local current_theme="" # Declaration and assignment should be done seperately ==> https://github.com/koalaman/shellcheck/wiki/SC2155

    current_theme="$(grep 'GRUB_THEME=' $grub_config_location | grep -v \#)"

    if [[ -n "$current_theme" ]]; then
      # Backup with --in-place option to grub.bak within the same directory; then remove the current theme.
      sed --in-place='.bak' "s|$current_theme|#GRUB_THEME=|" "$grub_config_location"

      if [[ -f "$grub_config_location".back ]]; then
        rm -rf "$grub_config_location".back
      fi

      # Update grub config
      prompt -i "\n Resetting grub theme...\n"
      updating_grub
    else
      prompt -e "\n No active theme found."
      prompt -i "\n Exiting..."
      exit 1
    fi
  else
    #Check if password is cached (if cache timestamp not expired yet)
    if sudo -n true 2> /dev/null && echo; then
      #No need to ask for password
      sudo "$0" -t ${theme} "${PROG_ARGS[@]}"
    else
      #Ask for password
      prompt -e "\n [ Error! ] -> Run me as root! "
      read -r -p " [ Trusted ] Specify the root password : " -t ${MAX_DELAY} -s #when using "read" command, "-r" option must be supplied ==> https://github.com/koalaman/shellcheck/wiki/SC2162

      if sudo -S echo <<< $REPLY 2> /dev/null && echo; then
        #Correct password, use with sudo's stdin
        sudo -S "$0" -t ${theme} "${PROG_ARGS[@]}" <<< $REPLY
      else
        #block for 3 seconds before allowing another attempt
        sleep 3
        prompt -e "\n [ Error! ] -> Incorrect password!\n"
        exit 1
      fi
    fi
  fi
}

dialog_installer() {
  if [[ ! -x /usr/bin/dialog ]];  then
    if [[ $UID -ne $ROOT_UID ]];  then
      #Check if password is cached (if cache timestamp not expired yet)

      if sudo -n true 2> /dev/null && echo; then
        #No need to ask for password
        exec sudo $0
      else
        #Ask for password
        prompt -e "\n [ Error! ] -> Run me as root! "
        read -r -p " [ Trusted ] Specify the root password : " -t ${MAX_DELAY} -s

        if sudo -S echo <<< $REPLY 2> /dev/null && echo; then
          #Correct password, use with sudo's stdin
          sudo $0 <<< $REPLY
        else
          #block for 3 seconds before allowing another attempt
          sleep 3
          prompt -e "\n [ Error! ] -> Incorrect password!\n"
          exit 1
        fi
      fi
    fi
    install_depends dialog
  fi
  run_dialog
  install "${theme}" "${icon}" "${screen}"
  exit 1
}

#######################################################
#   :::::: A R G U M E N T   H A N D L I N G ::::::   #
#######################################################

install=install

while [[ $# -gt 0 ]]; do
  PROG_ARGS+=("${1}")
  dialog='false'
  case "${1}" in
    -r|--remove)
      remove='true'
      shift
      for theme in "${@}"; do
        case "${theme}" in
          tela)
            themes+=("${THEME_VARIANTS[0]}")
            shift
            ;;
          vimix)
            themes+=("${THEME_VARIANTS[1]}")
            shift
            ;;
          stylish)
            themes+=("${THEME_VARIANTS[2]}")
            shift
            ;;
          whitesur)
            themes+=("${THEME_VARIANTS[3]}")
            shift
            ;;
          -*)
            break
            ;;
          *)
            prompt -e "ERROR: Unrecognized theme variant '$1'."
            prompt -i "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -g|--generate)
      shift 1
      THEME_DIR="${1}"
      install=generate
      shift 1
      ;;
    -b|--boot)
      install_boot='true'
      shift 1
      ;;
    -t|--theme)
      shift
      for theme in "${@}"; do
        case "${theme}" in
          tela)
            themes+=("${THEME_VARIANTS[0]}")
            shift
            ;;
          vimix)
            themes+=("${THEME_VARIANTS[1]}")
            shift
            ;;
          stylish)
            themes+=("${THEME_VARIANTS[2]}")
            shift
            ;;
          whitesur)
            themes+=("${THEME_VARIANTS[3]}")
            shift
            ;;
          -*)
            break
            ;;
          *)
            prompt -e "ERROR: Unrecognized theme variant '$1'."
            prompt -i "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -i|--icon)
      shift
      for icon in "${@}"; do
        case "${icon}" in
          color)
            icons+=("${ICON_VARIANTS[0]}")
            shift
            ;;
          white)
            icons+=("${ICON_VARIANTS[1]}")
            shift
            ;;
          whitesur)
            icons+=("${ICON_VARIANTS[2]}")
            shift
            ;;
          -*)
            break
            ;;
          *)
            prompt -e "ERROR: Unrecognized icon variant '$1'."
            prompt -i "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -s|--screen)
      shift
      for screen in "${@}"; do
        case "${screen}" in
          1080p)
            screens+=("${SCREEN_VARIANTS[0]}")
            shift
            ;;
          2k)
            screens+=("${SCREEN_VARIANTS[1]}")
            shift
            ;;
          4k)
            screens+=("${SCREEN_VARIANTS[2]}")
            shift
            ;;
          ultrawide)
            screens+=("${SCREEN_VARIANTS[3]}")
            shift
            ;;
          ultrawide2k)
            screens+=("${SCREEN_VARIANTS[4]}")
            shift
            ;;
          -*)
            break
            ;;
          *)
            prompt -e "ERROR: Unrecognized screen variant '$1'."
            prompt -i "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -c|--custom-resolution)
      shift
      custom_resolution="$1"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      prompt -e "ERROR: Unrecognized installation option '$1'."
      prompt -i "Try '$0 --help' for more information."
      exit 1
      ;;
  esac
done

#############################
#   :::::: M A I N ::::::   #
#############################

# Show terminal user interface for better use
if [[ "${dialog:-}" == 'false' ]]; then
  if [[ "${remove:-}" != 'true' ]]; then
    for theme in "${themes[@]-${THEME_VARIANTS[0]}}"; do
      for icon in "${icons[@]-${ICON_VARIANTS[0]}}"; do
        for screen in "${screens[@]-${SCREEN_VARIANTS[0]}}"; do
          $install "${theme}" "${icon}" "${screen}"
        done
      done
    done
  elif [[ "${remove:-}" == 'true' ]]; then
    for theme in "${themes[@]-${THEME_VARIANTS[0]}}"; do
      remove "${theme}"
    done
  fi
  else
  dialog_installer
fi

exit 0
