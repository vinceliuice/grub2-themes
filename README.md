```
  ____ ____  _   _ ____ ____    _____ _   _ _____ __  __ _____ ____
 / ___|  _ \| | | | __ )___ \  |_   _| | | | ____|  \/  | ____/ ___|
| |  _| |_) | | | |  _ \ __) |   | | | |_| |  _| | |\/| |  _| \___ \
| |_| |  _ <| |_| | |_) / __/    | | |  _  | |___| |  | | |___ ___) |
 \____|_| \_\\___/|____/_____|   |_| |_| |_|_____|_|  |_|_____|____/

```

## Flat Design themes for Grub

## Installation:

Usage:  `sudo ./install.sh [OPTIONS...]`

|  Options:              | Description: |
|:-----------------------|:-------------|
| -b, --boot             | Install grub theme into `/boot/grub/themes` |
| -v, --vimix            | Install Vimix grub theme |
| -s, --stylish          | Install Stylish grub theme |
| -t, --tela             | Install Tela grub theme |
| -l, --slaze            | Install Slaze grub theme |
| -w, --white            | Install using black and white icons |
| -u, --ultrawide        | Install 21:9 (2560x1080) background image - not available for slaze theme|
| -C, --custom-background| Use either background.jpg or custom-background.jpg as theme background instead
| -2, --2k               | Install 2k (2560x1440) background image |
| -4, --4k               | Install 4k (3840x2160) background image |
| -r, --remove [THEME]   | Uninstall selected theme |
| -h, --help             | Show this help |

_If no options are used, a user interface will show up instead_

### Examples:
 - Install Tela theme on 2k display device:
   - `sudo ./install.sh --tela --2k`

 - Install Tela theme into /boot/grub/themes:
   - `sudo ./install.sh -b -t`

 - Uninstall Tela theme:
   - `sudo ./install.sh -r -t`

## Issues / tweaks:

### Correcting display resolution:

 - On the grub screen, press `c` to enter the command line
 - Enter `vbeinfo` or `videoinfo` to check available resolutions
 - Open `/etc/default/grub`, and edit `GRUB_GFXMODE=[height]x[width]x32` to match your resolution
 - Finally, run `grub-mkconfig -o /boot/grub/grub.cfg` to update your grub config

### Setting a custom background:

 - Make sure you have `imagemagick` installed, or at least something that provides `convert`
 - Find the resolution of your display, and make sure your background matches the resolution
   - (1920x1080 -> --1080p, 2560x1080 -> --ultrawide, 2560x1440 -> --2k, 3840x2160 -> --4k)
 - Place your custom background inside the root of the project, and name it either background.jpg or custom-background.jpg
 - Run the installer like normal, but with `--custom-background`, `--[YOUR_RESOLUTION]` and `--[THEME]`
   - Make sure to replace `[YOUR_RESOLUTION]` with your resolution and `[THEME]` with the theme

## Contributing:
 - If you made changes to icons, or added a new one:
   - Delete the existing icon, if there is one
   - Run `cd assets; ./render-all.sh`
 - Create a pull request from your branch or fork
 - If any issues occur, report then to the [issue](https://github.com/vinceliuice/grub2-themes/issues) page

## Screenshots:

### Vimix grub theme:

![Vimix](screenshots/grub-theme-vimix.jpg?raw=true)

### Stylish grub theme:

![Stylish](screenshots/grub-theme-stylish.jpg?raw=true)

### Tela grub theme:

![Tela](screenshots/grub-theme-tela.jpg?raw=true)

### Slaze grub theme:

![Slaze](screenshots/grub-theme-slaze.jpg?raw=true)
