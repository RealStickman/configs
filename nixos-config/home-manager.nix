{ config, pkgs, ... }:

let
  user = "exu";
  hostname = "nixos";
in {
  imports = [ <home-manager/nixos> ];

  # root home
  home-manager.users.root = { pkgs, ... }: {
    home.username = "root";
    home.homeDirectory = "/root";
    home.stateVersion = "22.11";
    home.packages = with pkgs;
      [
        kitty # terminfo support
      ];

    imports = [ ./home-manager/hyprland.nix ./home-manager/fish.nix ];

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
      #xfce.xfce4-settings # xfce settings manager
      xfce.xfconf # xfce config storage
      transmission-remote-gtk # torrent remote controll gui
    ];

    imports = [ ./home-manager/hyprland.nix ./home-manager/fish.nix ];

    systemd.user = {
      # user services
      services = {
        # ssh-agent user service
        ssh-agent = {
          Unit = { Description = "SSH key agent"; };
          Service = {
            Type = "simple";
            Environment = "SSH_AUTH_SOCK=%t/ssh-agent.socket";
            ExecStart = "${pkgs.openssh}/bin/ssh-agent -D -a $SSH_AUTH_SOCK";
          };
          Install = { WantedBy = [ "default.target" ]; };
        };
      };
      # user environment variables
      sessionVariables = {
        # see https://discourse.nixos.org/t/how-to-use-xdg-runtime-dir-in-pam-sessionvariables/10120/3 about the builtin variable
        SSH_AUTH_SOCK = "${builtins.getEnv "XDG_RUNTIME_DIR"}/ssh-agent.socket";
      };
    };

    # git configuration
    programs.git = {
      enable = true;
      extraConfig = {
        init = { defaultBranch = "main"; };
        user = {
          name = "RealStickman";
          email = "mrc@frm01.net";
        };
        gitlab = { user = "RealStickman"; };
        github = { user = "RealStickman"; };
      };
    };

    programs = {
      waybar = {
        enable = true;
        settings = {
          mainBar = (builtins.fromJSON
            (builtins.readFile ./home-manager/config/waybar/config.json));
        };
        style = (builtins.readFile ./home-manager/config/waybar/style.css);
      };
      kitty = {
        enable = true;
        extraConfig =
          (builtins.readFile ./home-manager/config/kitty/kitty.conf);
      };
      ssh = {
        enable = true;
        extraOptionOverrides = {
          AddKeysToAgent = "yes";
          test = "${builtins.getEnv "HOME"}";
          test2 = "${builtins.getEnv "XDG_RUNTIME_DIR"}";
        };
        matchBlocks = [
          {
            host = "gitlab.com";
            identityFile = [ "${builtins.getEnv "HOME"}/.ssh/id_ed25519_git" ];
          }
          {
            host = "github.com";
            identityFile = [ "${builtins.getEnv "HOME"}/.ssh/id_ed25519_git" ];
          }
          {
            host = "gitea.exu.li";
            identityFile = [ "${builtins.getEnv "HOME"}/.ssh/id_ed25519_git" ];
          }
          {
            host = "aur.archlinux.org";
            identityFile = [ "${builtins.getEnv "HOME"}/.ssh/id_ed25519_git" ];
          }
        ];
      };
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
        #recursive = true;
      };
      # templates
      ".config/Vorlagen" = {
        source = ./home-manager/config/Vorlagen;
        #recursive = true;
      };
      # xfce4 settings
      ".config/xfce4".source = ./home-manager/config/xfce4;
      # xdg user dirs
      ".config/user-dirs.dirs".source = ./home-manager/config/user-dirs.dirs;
      # xdg user locales
      ".config/user-dirs.locale".source =
        ./home-manager/config/user-dirs.locale;
      # libreoffice settings
      ".config/libreoffice".source = ./home-manager/config/libreoffice;
      # transmission remote settings
      ".config/transmission-remote-gtk".source =
        ./home-manager/config/transmission-remote-gtk;
      # TODO firefox configuration
      # TODO calibre configuration
    };

    services.mako.enable = true;
  };
}
