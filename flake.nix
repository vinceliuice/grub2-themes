{
  description = "Flake to manage grub2 themes from vinceliuice";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };
    in
    with nixpkgs.lib;
    rec {
      nixosModules.default = { config, ... }:
        let
          cfg = config.boot.loader.grub2-theme;
          splashImage = if cfg.splashImage == null then "" else cfg.splashImage;
          hasBootMenuConfig = cfg.bootMenuConfig != null;
          hasTerminalConfig = cfg.terminalConfig != null;
          resolutions = {
            "1080p" = "1920x1080";
            "ultrawide" = "2560x1080";
            "2k" = "2560x1440";
            "4k" = "3840x2160";
            "ultrawide2k" = "3440x1440";
          };
          grub2-theme = pkgs.stdenv.mkDerivation {
            name = "grub2-theme";
            src = "${self}";
            buildInputs = [ pkgs.imagemagick ];
            installPhase = ''
              mkdir -p $out/grub/themes

              # Create placeholder terminal box PNGs that install.sh expects
              mkdir -p common
              for box in c e n ne nw s se sw w; do
                touch common/terminal_box_$box.png
              done

              # Run the install script
              bash ./install.sh \
                --generate $out/grub/themes \
                --screen ${cfg.screen} \
                --theme ${cfg.theme} \
                --icon ${cfg.icon} \
                ${if cfg.customResolution != null then "--custom-resolution ${cfg.customResolution}" else ""}

              if [ -n "${splashImage}" ]; then
                rm $out/grub/themes/${cfg.theme}/background.jpg;
                ${pkgs.imagemagick}/bin/magick ${splashImage} $out/grub/themes/${cfg.theme}/background.jpg;
              fi;

              if [ ${pkgs.lib.trivial.boolToString cfg.footer} == "false" ]; then
                sed -i ':again;$!N;$!b again; s/\+ image {[^}]*}//g' $out/grub/themes/${cfg.theme}/theme.txt;
              fi;

              if [ ${pkgs.lib.trivial.boolToString hasBootMenuConfig} == "true" ]; then
                sed -i ':again;$!N;$!b again; s/\+ boot_menu {[^}]*}//g' $out/grub/themes/${cfg.theme}/theme.txt;
                cat << EOF >> $out/grub/themes/${cfg.theme}/theme.txt
              + boot_menu {
                  ${if cfg.bootMenuConfig == null then "" else cfg.bootMenuConfig}
              }
              EOF
              fi;

              if [ ${pkgs.lib.trivial.boolToString hasTerminalConfig} == "true" ]; then
                sed -i 's/^terminal-.*$//g' $out/grub/themes/${cfg.theme}/theme.txt
                cat << EOF >> $out/grub/themes/${cfg.theme}/theme.txt
              ${if cfg.terminalConfig == null then "" else cfg.terminalConfig}
              EOF
              fi;
            '';
          };
          resolution = if cfg.customResolution != null
            then cfg.customResolution
            else resolutions."${cfg.screen}";
        in
        rec {
          options = {
            boot.loader.grub2-theme = {
              enable = mkOption {
                default = true;
                example = true;
                type = types.bool;
                description = ''
                  Enable grub2 theming
                '';
              };
              theme = mkOption {
                default = "tela";
                example = "tela";
                type = types.enum [ "tela" "vimix" "stylish" "whitesur" ];
                description = ''
                  The theme to use for grub2.
                '';
              };
              icon = mkOption {
                default = "white";
                example = "white";
                type = types.enum [ "color" "white" "whitesur" ];
                description = ''
                  The icon to use for grub2.
                '';
              };
              screen = mkOption {
                default = "1080p";
                example = "1080p";
                type = types.enum [ "1080p" "2k" "4k" "ultrawide" "ultrawide2k" ];
                description = ''
                  The screen resolution to use for grub2.
                '';
              };
              customResolution = mkOption {
                default = null;
                example = "1600x900";
                type = types.nullOr (types.strMatching "[0-9]+x[0-9]+");
                description = ''
                  Custom resolution for grub2 theme. Should be in the format "WIDTHxHEIGHT".
                  If set, this will override the 'screen' option.
                '';
              };
              splashImage = mkOption {
                default = null;
                example = "/my/path/background.jpg";
                type = types.nullOr types.path;
                description = ''
                  The path of the image to use for background (must be jpg or png).
                '';
              };
              bootMenuConfig = mkOption {
                default = null;
                example = "left = 30%";
                type = types.nullOr types.str;
                description = ''
                  Grub theme definition for boot_menu.
                  Refer to config/theme-*.txt for reference.
                '';
              };
              terminalConfig = mkOption {
                default = null;
                example = "terminal-font: \"Terminus Regular 18\"";
                type = types.nullOr types.str;
                description = ''
                  Replaces grub theme definition for terminial-*.
                  Refer to config/theme-*.txt for reference.
                '';
              };
              footer = mkOption {
                default = true;
                example = true;
                type = types.bool;
                description = ''
                  Whether to include the image footer.
                '';
              };
            };
          };
          config = mkIf cfg.enable (mkMerge [{
            environment.systemPackages = [
              grub2-theme
            ];
            boot.loader.grub = {
              theme = "${grub2-theme}/grub/themes/${cfg.theme}";
              splashImage = "${grub2-theme}/grub/themes/${cfg.theme}/background.jpg";
              gfxmodeEfi = "${resolution},auto";
              gfxmodeBios = "${resolution},auto";
              extraConfig = ''
                insmod gfxterm
                insmod png
                set icondir=($root)/theme/icons
              '';
            };
          }]);
        };
    };
}
