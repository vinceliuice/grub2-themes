#!/bin/bash

# Grub2 Dark Theme

ROOT_UID=0
THEME_DIR="/boot/grub/themes"
THEME_DIR_2="/boot/grub2/themes"

REO_DIR=$(cd $(dirname $0) && pwd)

# Check command avalibility
function has_command() {
  command -v $1 > /dev/null
}

usage() {
  printf "%s\n" "Usage: $0 [OPTIONS...]"
  printf "\n%s\n" "OPTIONS:"
  printf "  %-25s%s\n" "-l|--slaze" "slaze grub theme"
  printf "  %-25s%s\n" "-s|--stylish" "stylish grub theme"
  printf "  %-25s%s\n" "-t|--tela" "tela grub theme"
  printf "  %-25s%s\n" "-v|--vimix" "vimix grub theme"
  printf "  %-25s%s\n" "-h, --help" "Show this help"
}

install() {
 [[ ${theme} == 'slaze' ]] && local name="Slaze"
 [[ ${theme} == 'stylish' ]] && local name="Stylish"
 [[ ${theme} == 'tela' ]] && local name="Tela"
 [[ ${theme} == 'vimix' ]] && local name="Vimix"

# Checking for root access and proceed if it is present
if [ "$UID" -eq "$ROOT_UID" ]; then

  # Create themes directory if not exists
  echo -e "Checking for the existence of themes directory..."
  [[ -d ${THEME_DIR}/${name} ]] && rm -rf ${THEME_DIR}/${name}
  [[ -d ${THEME_DIR_2}/${name} ]] && rm -rf ${THEME_DIR_2}/${name}
  [[ -d /boot/grub ]] && mkdir -p ${THEME_DIR}/${name}
  [[ -d /boot/grub2 ]] && mkdir -p ${THEME_DIR_2}/${name}

  # Copy theme
  echo -e "Installing ${name} theme..."

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
  echo -e "Setting ${name} as default..."
  grep "GRUB_THEME=" /etc/default/grub 2>&1 >/dev/null && sed -i '/GRUB_THEME=/d' /etc/default/grub

  [[ -d /boot/grub ]] && echo "GRUB_THEME=\"${THEME_DIR}/${name}/theme.txt\"" >> /etc/default/grub
  [[ -d /boot/grub2 ]] && echo "GRUB_THEME=\"${THEME_DIR_2}/${name}/theme.txt\"" >> /etc/default/grub

  # Update grub config
  echo -e "Updating grub config..."
  if has_command update-grub; then
    update-grub
  elif has_command grub-mkconfig; then
    grub-mkconfig -o /boot/grub/grub.cfg
  elif has_command grub2-mkconfig; then
    grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
  fi

  # Success message
  echo -e "\n All done! "

else
    # Error message
    echo -e "\n Error! -> Run me as root "
fi

}

while [[ $# -gt 0 ]]; do
  case "${1}" in
    -l|--slaze)
      theme='slaze'
      shift 1
      ;;
    -s|--stylish)
      theme='stylish'
      shift 1
      ;;
    -t|--tela)
      theme='tela'
      shift 1
      ;;
    -v|--vimix)
      theme='vimix'
      shift 1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: Unrecognized installation option '$1'."
      echo "Try '$0 --help' for more information."
      exit 1
      ;;
  esac
done

install

