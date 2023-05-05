# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, pkgs, ... }:

let
  user = "exu";
  hostname = "nixos";
in
{
  imports = [
      ./hardware-configuration.nix
      ./system-packages.nix
      ./home-manager.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };
    efi = {
      canTouchEfiVariables = true;
    };
  };

  # Enable completions by nix
  programs.fish.enable = true;

  # set neovim as default
  programs.neovim.enable = true;
  programs.neovim.defaultEditor = true;

  environment = {
    shells = [ pkgs.fish ];
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      SUDO_EDITOR = "nvim";
      TERMINAL = "kitty";
    };
    # remove nano from default packages
    defaultPackages = [ pkgs.perl pkgs.rsync pkgs.strace ];
    etc = {
      # gtk theme configuration
      # src: https://unix.stackexchange.com/questions/632879/how-to-set-a-system-wide-gtk-theme-in-nixos
      "gtk-2.0/gtkrc".source =  ./config/gtk-2.0/gtkrc;
      "gtk-3.0/settings.ini".source =  ./config/gtk-3.0/settings.ini;
      "gtk-4.0/settings.ini".source =  ./config/gtk-4.0/settings.ini;
    };
  };

  networking.hostName = "${hostname}"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # disable global firewall for the time being
  networking.firewall.enable = false;

  # Set your time zone.
  time.timeZone = "Europe/Zurich";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "de_CH.UTF-8";
  console = {
    keyMap = "de_CH-latin1";
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    displayManager.defaultSession = "hyprland";
    #displayManager.lightdm = {
    #  enable = true;
    #  greeters.gtk.enable = true;
    #};
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
    desktopManager.lxqt.enable = true;
  };

  # enable gvfs service
  services.gvfs.enable = true;

  # Hyprland
  security.polkit.enable = true;
  programs.hyprland = {
    enable = true;
  };

  # sudoers file
  security.sudo.configFile = (builtins.readFile ./config/sudoers);

  # Configure keymap in X11
  services.xserver.layout = "ch";

  # keyring
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.${user}.enableGnomeKeyring = true;
  programs.seahorse.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable Pipewire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  # root config
  users.users.root = {
    shell = pkgs.fish;
  };

  # User config
  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" "networkmanager" "lp" "scanner" ];
    initialPassword = "pass";
    shell = pkgs.fish;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable thumbnailer service
  services.tumbler.enable = true;

  virtualisation = {
    podman = {
      enable = true;
      # clean up regularly
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # BTRFS options
  fileSystems = {
    "/".options = [ "compress=zstd" ];
    "/home".options = [ "compress=zstd" ];
    "/nix".options = [ "compress=zstd" "noatime" ];
    "/swap".options = [ "noatime" ];
  };

  # Swapfile
  swapDevices = [ { device = "/swap/swapfile"; } ];

  # Enable automatic package upgrades
  #system.autoUpgrade = {
  #  enable = true;
  #  channel = "https://nixos.org/channels/nixos-unstable";
  #};

  # Enable automatic garbage collection
  nix = {
    settings.auto-optimise-store = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
