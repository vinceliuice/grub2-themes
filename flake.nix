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
      nixosModule = { config, ... }:
        let
          cfg = config.boot.loader.grub2-theme;
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
            installPhase = ''
              mkdir -p $out/grub/themes;
              bash ./install.sh \
                --generate $out/grub/themes \
                --screen ${cfg.screen} \
                --theme ${cfg.theme} \
                --icon ${cfg.icon};
            '';
          };
          resolution = resolutions."${cfg.screen}";
        in
        rec {
          options = {
            boot.loader.grub2-theme = {
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
              splashImage = mkOption {
                default = "";
                example = "/my/path/background.jpg";
                type = types.string;
                description = ''
                  The path of the image to use for background (must be jpg).
                '';
              };
            };
          };
          config = mkMerge [{
            environment.systemPackages = [
              grub2-theme
            ];
            boot.loader.grub = {
              theme = "${grub2-theme}/grub/themes/${cfg.theme}";
              splashImage = "${grub2-theme}/grub/themes/${cfg.theme}/background.jpg";
              gfxmodeEfi = "${resolution},auto";
              gfxmodeBios = "${resolution},auto";
            };
          }];
        };
    };
}
