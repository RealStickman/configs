{ config, pkgs, ... }:

let
  user = "exu";
  hostname = "nixos";
in
{
  imports = [
    <home-manager/nixos>
  ];

  # root home
  home-manager.users.root = { pkgs, ... }: {
    home.username = "root";
    home.homeDirectory = "/root";
    home.stateVersion = "22.11";
    home.packages = with pkgs; [
      kitty # terminfo support
    ];

    imports = [
      ./home-manager/hyprland.nix
      ./home-manager/fish.nix
    ];

  };

  # keep everything using home manager within this block
  home-manager.users.${user} = { pkgs, ... }: {
    home.username = "${user}";
    home.homeDirectory = "/home/${user}";
    home.stateVersion = "22.11";
    home.packages = with pkgs; [
      firefox # browser
      kitty # terminal
      pciutils # lspci command
      git # git
      emacs # emacs editor
      emacsPackages.doom # doom emacs configuration
      acpilight # controlling laptop monitor backlight
      networkmanagerapplet # network configuration
      wofi # app launcher (wayland replacement for rofi)
      fish # fish shell
      libnotify # notifications
      mako # notification daemon
      xdg-desktop-portal-hyprland # desktop portal (hyprland fork)
      #neovim # text editor
      yt-dlp # video downloader
      #sweet # gtk theme
      waybar # status bar
      playerctl # mpris
      xfce.thunar # file manager
      xfce.thunar-archive-plugin # manage archives in thunar
    ];

    imports = [
      ./home-manager/hyprland.nix
      ./home-manager/fish.nix
    ];

    systemd.user = {
      # user services
      services = {
        # ssh-agent user service
        ssh-agent = {
          Unit = {
            Description = "SSH key agent";
          };
          Service = {
            Type = "simple";
            Environment = "SSH_AUTH_SOCK=%t/ssh-agent.socket";
            ExecStart = "/run/current-system/sw/bin/ssh-agent -D -a $SSH_AUTH_SOCK";
          };
          Install = {
            WantedBy = [ "default.target" ];
          };
        };
      };
      # user environment variables
      sessionVariables = {
        SSH_AUTH_SOCK = "/run/user/1000/ssh-agent.socket";
      };
    };

    # git configuration
    programs.git = {
      enable = true;
      extraConfig = {
        init = {
          defaultBranch = "main";
        };
        user = {
          name = "RealStickman";
          email = "mrc@frm01.net";
        };
        gitlab = {
          user = "RealStickman";
        };
        github = {
          user = "RealStickman";
        };
      };
    };

    programs.waybar = {
      enable = true;
      settings = {
        mainBar = (builtins.fromJSON (builtins.readFile ./home-manager/config/waybar/config.json));
      };
      style = (builtins.readFile ./home-manager/config/waybar/style.css);
    };

    home.file = {
      # Scripts
      ".scripts/waybar/player-mpris-tail.py" = {
        source = ./home-manager/scripts/waybar/player-mpris-tail.py;
        executable = true;
      };
      # Thunar configuration
      ".config/Thunar" = {
        source = ./home-manager/config/Thunar;
        recursive = true;
      };
      # templates
      ".config/Vorlagen" = {
        source = ./home-manager/config/Vorlagen;
        recursive = true;
      };
    };

  services.mako.enable = true;
  };
}
