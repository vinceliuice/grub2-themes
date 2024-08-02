![banner](banner.png?raw=true)

## Installation:

Usage:  `sudo ./install.sh [OPTIONS...]`

```
  -t, --theme     theme variant(s)          [tela|vimix|stylish|whitesur]       (default is tela)
  -i, --icon      icon variant(s)           [color|white|whitesur]              (default is color)
  -s, --screen    screen display variant(s) [1080p|2k|4k|ultrawide|ultrawide2k] (default is 1080p)
  -r, --remove    Remove theme              [tela|vimix|stylish|whitesur]       (must add theme name option, default is tela)

  -b, --boot      install theme into '/boot/grub' or '/boot/grub2'
  -g, --generate  do not install but generate theme into chosen directory       (must add your directory)

  -h, --help      Show this help
```

_If no options are used, a user interface `dialog` will show up instead_

### Examples:
 - Install Tela theme on 2k display device:

```sh
sudo ./install.sh -t tela -s 2k
```

 - Install Tela theme into /boot/grub/themes:

```sh
sudo ./install.sh -b -t tela
```

 - Uninstall Tela theme:

```sh
sudo ./install.sh -r -t tela
```

## Installation with NixOS:
To use this theme with NixOS you will have to enable [flakes](https://wiki.nixos.org/wiki/flakes). Before you do this, please inform yourself if you really want to, because flakes are still an unstable feature.

First you will have to add grub2 to your `flake.nix` file as a new input.
```nix
# flake.nix
{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # Add grub2 themes to your inputs ...
    grub2-themes = {
      url = "github:vinceliuice/grub2-themes";
    };
  };

  outputs = inputs@{ nixpkgs,  grub2-themes, ... }: {
    nixosConfigurations = {
      my_host = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };

        # ... and then to your modules
        modules = [
          ./configuration.nix
          grub2-themes.nixosModules.default
        ];
      };
    };
  };
}
```

After that, you can configure the theme as shown below. In this example it is inside the `configuration.nix` file but it can be any file you choose.
```nix
# configuration.nix
{ inputs, config, pkgs, lib, ... }:
{
  boot.loader.grub = { ... };
  boot.loader.grub2-theme = {
    enable = true;
    theme = "stylish";
    footer = true;
  };
}
```

## Issues / tweaks:

### Correcting display resolution:

 - On the grub screen, press `c` to enter the command line
 - Enter `vbeinfo` or `videoinfo` to check available resolutions
 - Open `/etc/default/grub`, and edit `GRUB_GFXMODE=[height]x[width]x32` to match your resolution
 - Finally, run `grub-mkconfig -o /boot/grub/grub.cfg` to update your grub config

### Setting a custom background:

 - Make sure you have `imagemagick` installed, or at least something that provides `convert`
 - Find the resolution of your display, and make sure your background matches the resolution
   - 1920x1080 >> 1080p
   - 2560x1080 >> ultrawide
   - 2560x1440 >> 2k
   - 3440x1440 >> ultrawide2k
   - 3840x2160 >> 4k
 - Place your custom background inside the root of the project, and name it `background.jpg`
 - Run the installer like normal, but with -s `[YOUR_RESOLUTION]` and -t `[THEME]` and -i `[ICON]`
   - Make sure to replace `[YOUR_RESOLUTION]` with your resolution and `[THEME]` with the theme

## Contributing:
 - If you made changes to icons, or added a new one:
   - Delete the existing icon, if there is one
   - Run `cd assets; ./render-all.sh`
 - Create a pull request from your branch or fork
 - If any issues occur, report then to the [issue](https://github.com/vinceliuice/grub2-themes/issues) page

## Preview:
![preview](preview.png?raw=true)

## Documents

[Grub2 theme reference](https://wiki.rosalab.ru/en/index.php/Grub2_theme_/_reference)

[Grub2 theme tutorial](https://wiki.rosalab.ru/en/index.php/Grub2_theme_tutorial)
