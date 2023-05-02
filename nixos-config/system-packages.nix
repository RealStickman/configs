{ pkgs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #vim # an editor
    neovim # text editor
    fwupd # firmware updates
    fwupd-efi # firmware updates additional EFI stuff
    wget # get stuff from the net
    #hyprland # window manager
    wayland # wayland server
    xdg-utils # xdg directories, open, etc
    xdg-user-dirs # directories
    sweet # gtk theme
    capitaine-cursors # cursor theme
    xfce.tumbler # image files thumbnail generator (+ base requirement)
    ffmpegthumbnailer # video files thumbnail generator
    qt6.qtwayland # wayland for qt6
    libsForQt5.qt5.qtwayland # wayland for at5
    polkit_gnome # graphical authentication agent for polkit
    freetype # font rendering and configuration
  ];

  fonts.fonts = with pkgs; [
    fira # fira sans font
    fira-code # fira code font
    font-awesome # icons font
  ];
}
