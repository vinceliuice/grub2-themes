```
  ____ ____  _   _ ____ ____    _____ _   _ _____ __  __ _____ ____
 / ___|  _ \| | | | __ )___ \  |_   _| | | | ____|  \/  | ____/ ___|
| |  _| |_) | | | |  _ \ __) |   | | | |_| |  _| | |\/| |  _| \___ \
| |_| |  _ <| |_| | |_) / __/    | | |  _  | |___| |  | | |___ ___) |
 \____|_| \_\\___/|____/_____|   |_| |_| |_|_____|_|  |_|_____|____/

```

## Flat Design themes for Grub2.

## Install

Usage:  `sudo ./install.sh`  **[OPTIONS...]**

*if no option used the terminal user interface will be show up*

|  OPTIONS:      | |
|:---------------|:-------------|
| -v, --vimix    | Vimix grub theme |
| -s, --stylish  | Stylish grub theme |
| -t, --tela     | Tela grub theme |
| -l, --slaze    | Slaze grub theme |
| -2, --2k       | Install 2k(2560x1440) background image |
| -4, --4k       | Install 4k(3840x2160) background image |
| -r, --remove   | Remove theme (must add theme name option) |
| -h, --help     | Show this help |

For example:
1. `Install Tela theme on 2k display device`

    sudo ./install.sh -t -2

2. `Remove Tela theme`

    sudo ./install.sh -r -t

## Set the right resolution of your display
On the grub screen, `press c` to get the commandline,
and enter `vbeinfo` to check what resolutions you can use,
then edit `/etc/default/grub` , add your resolution `GRUB_GFXMODE=****x****x32` into it,
last you can run `grub-mkconfig -o /boot/grub/grub.cfg` to update your grub.cfg.

## Screenshots

### Vimix grub theme

![01](https://github.com/vinceliuice/grub2-themes/blob/master/screenshots/grub-theme-vimix.jpg?raw=true)

### Stylish grub theme

![02](https://github.com/vinceliuice/grub2-themes/blob/master/screenshots/grub-theme-stylish.jpg?raw=true)

### Tela grub theme

![03](https://github.com/vinceliuice/grub2-themes/blob/master/screenshots/grub-theme-tela.jpg?raw=true)

### Slaze grub theme

![04](https://github.com/vinceliuice/grub2-themes/blob/master/screenshots/grub-theme-slaze.jpg?raw=true)
