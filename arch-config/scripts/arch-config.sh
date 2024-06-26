#!/usr/bin/env bash

set -euo pipefail

# function to keep sudo from timing out
function func_dont_timeout {
    while true; do
        sudo -v
        sleep 60
    done
}

# check if user is root
if [ "$EUID" -ne 0 ]; then
    sudo -v
fi

# keep sudo active in background
func_dont_timeout &

cat <<EOF
############################################################
###################### INSTALL CONFIG ######################
############################################################
EOF

# function to select theme
function func_seltheme {
    cmd=(dialog --separate-output --checklist "Select theme (Only select one)" 22 76 16)
    options=(1 "Nyarch" off # any option can be set to default to "on"
        2 "Spaceengine Pink" off)
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    clear
    for choice in $choices; do
        case $choice in
            1)
                echo "nyarch" >"$HOME/.seltheme"
                ;;
            2)
                echo "space-pink" >"$HOME/.seltheme"
                ;;
        esac
    done
}

echo
cat <<EOF
########################################
################ Setup  ################
########################################
EOF

# get script directory
scriptloc="$BASH_SOURCE"
#scriptpath="$(dirname "$scriptloc")"

# change to home
#cd "$HOME"

# remove old installs
#rm -rf ~/configs

# Use temporary directory for download
# FIXME probably lots of issues at first
tempdir="$(mktemp -d)"
#cd "$tempdir"

echo "Checking config file"

#clone this repo
git clone -b main https://gitea.exu.li/realstickman/configs.git "$tempdir" &>/dev/null

# check if the install scripts are the same
# NOTE Arguments get passed automatically now
if ! cmp --silent "$scriptloc" "$HOME/scripts/arch-config.sh"; then
    echo Removed old config file and launched new one.
    cp "$tempdir/arch-config/scripts/arch-config.sh" "$HOME/scripts/" && bash ~/scripts/arch-config.sh "$@"
fi

# if no seltheme file exists, ask to select a theme
if [[ ! -f "$HOME/.seltheme" ]]; then
    func_seltheme
fi

####################
#### Arguments  ####
####################

copy_firefox=0

# handle arguments
if [[ "$#" -eq 1 ]]; then
    # -t/--theme to change theme
    if [[ "$1" == "-t" || "$1" == "--theme" ]]; then
        func_seltheme
    elif [[ "$1" == "-f" || "$1" == "--firefox" ]]; then
        copy_firefox=1
    elif [[ "$1" == "-h" || "$1" == "--help" ]]; then
        echo "-h, --help     Show help menu"
        echo "-t, --theme    Show theme selection screen"
        echo "-f, --firefox  Update firefox config"
        exit 0
    fi
elif [[ "$#" -gt 1 ]]; then
    echo "Too many arguments"
    exit 1
fi

echo
cat <<EOF
########################################
################ Backup ################
########################################
EOF

# Collect all PIDs of background processes that shoulb be waited for
pids=""

####################
##### Cleaning #####
####################

#delete previous backups
echo Removing old backup
if [[ -d ~/old_dat ]]; then
    rm -rf ~/old_dat
fi

####################
##### Creating #####
####################

# make new backup
echo Creating backup
mkdir -p ~/old_dat/.config
mkdir -p ~/old_dat/.doom.d
#mkdir -p ~/old_dat/.easystroke
mkdir -p ~/old_dat/.mozilla
mkdir -p ~/old_dat/scripts
mkdir -p ~/old_dat/.elvish
mkdir -p ~/old_dat/.ssh

# make subdirectories
mkdir -p ~/old_dat/.local/share

#config folders
if [[ -d ~/.config/MangoHud ]]; then
    rsync -ah ~/.config/MangoHud ~/old_dat/.config/
fi
if [[ -d ~/.config/fish ]]; then
    rsync -ah ~/.config/fish ~/old_dat/.config/
fi
if [[ -d ~/.config/gtk-3.0 ]]; then
    rsync -ah ~/.config/gtk-3.0 ~/old_dat/.config/
fi
if [[ -d ~/.config/sway ]]; then
    rsync -ah ~/.config/sway ~/old_dat/.config/
fi
if [[ -d ~/.config/polybar ]]; then
    rsync -ah ~/.config/polybar ~/old_dat/.config/
fi

# doom.d folder
if [[ -d ~/.doom.d ]]; then
    rsync -ah ~/.doom.d ~/old_dat/
fi

# .ssh folder
if [[ -d ~/.ssh ]]; then
    rsync -ah ~/.ssh ~/old_dat/
fi

# easystroke
if [[ -d ~/.easystroke ]]; then
    rsync -ah ~/.easystroke ~/old_dat/
fi

# local folder
if [[ -d ~/.local/share/applications ]]; then
    rsync -ah ~/.local/share/applications/ ~/old_dat/.local/share/
fi

# mozilla
if [[ -d ~/.mozilla ]]; then
    rsync -ah ~/.mozilla ~/old_dat/
fi

# scripts
if [[ -d ~/scripts ]]; then
    rsync -ah ~/scripts ~/old_dat/
fi

# remove old templates
if [[ -d ~/.config/Vorlagen ]]; then
    rm -r ~/.config/Vorlagen
fi

# remove old scripts in path
if [[ -d ~/scripts/in_path ]]; then
    rm -r ~/scripts/in_path
fi

# remove old script pieces
if [[ -d ~/scripts/pieces ]]; then
    rm -r ~/scripts/pieces
fi

# remove old polybar scripts
if [[ -d ~/scripts/polybar ]]; then
    rm -r ~/scripts/polybar
fi

# remove archived scripts
if [[ -d ~/scripts/archive ]]; then
    rm -r ~/scripts/archive
fi

echo
cat <<EOF
########################################
########### Copy New Config  ###########
########################################
EOF

#copy folders
cp -r "$tempdir/arch-config/.config/" ~/
cp -r "$tempdir/arch-config/.local/" ~/
cp -r "$tempdir/arch-config/.ssh" ~/

# copy firefox only if "-f" or "--firefox" is given as argument
if [[ copy_firefox -eq 1 ]]; then
    if [[ -d ~/.mozilla/firefox ]]; then
        # NOTE check if firefox default-release directory exists. 1 is good, 0 is bad
        firefoxdir=$(find ~/.mozilla/firefox/ -name \*.default-release | wc -l)
        if [[ $firefoxdir -eq 1 ]]; then
            cp -r "$tempdir/arch-config/.mozilla/firefox/default-release/"* ~/.mozilla/firefox/*.default-release/
        else
            echo "Please launch firefox and then update the config again"
        fi
    else
        echo "Please launch firefox and then update the config again"
    fi
fi

#copy single files
cp -r "$tempdir/arch-config/.face" ~/
cp -r "$tempdir/arch-config/.gtkrc-2.0" ~/
cp -r "$tempdir/arch-config/.gitconfig" ~/
cp -r "$tempdir/arch-config/.xinitrc" ~/
cp -r "$tempdir/arch-config/.kopiaignore" ~/
echo Copied files

# make .xinitrc executable
chmod +x ~/.xinitrc

#copy scripts
cp -r "$tempdir/arch-config/scripts/" ~/

#copy stuff to /etc
sudo cp -r "$tempdir/arch-config/etc" /

echo Copied folders

#copy usr stuff
sudo cp -r "$tempdir/arch-config/usr" /

# copy xresources for sway
cp "$tempdir/arch-config/.Xdefaults" ~/

# Set xdg-user-dirs as environment variables
ln -sf "$HOME/.config/user-dirs.dirs" "$HOME/.config/environment.d/user-dirs.dirs.conf"

echo
cat <<EOF
##############################
##### Per Device Settings ####
##############################
EOF

# lupusregina
# TODO analyse parts necessary for Wayland with Alita
if [ "$(hostname)" == "lupusregina" ]; then
    echo "Applying overrides for $(hostname)"
    # polybar dpi
    polybardpi="$(cat ~/configs/arch-config/per-device/lupusregina/polybar-dpi-override.ini)"
    awk -v polybardpi="$polybardpi" '/;per-device dpi insert/{print;print polybardpi;next}1' ~/.config/polybar/i3config.ini >/tmp/i3config.ini
    cp /tmp/i3config.ini ~/.config/polybar/i3config.ini
    # xresources dpi
    xftdpi="$(cat ~/configs/arch-config/per-device/lupusregina/xresources-dpi-override)"
    awk -v xftdpi="$xftdpi" '/!per-device dpi insert/{print;print xftdpi;next}1' ~/.Xdefaults >/tmp/.Xdefaults
    cp /tmp/.Xdefaults ~/.Xdefaults
    sudo cp ~/configs/arch-config/per-device/lupusregina/10-monitor.conf /etc/X11/xorg.conf.d/
    sudo cp ~/configs/arch-config/per-device/lupusregina/20-amdgpu.conf /etc/X11/xorg.conf.d/
fi

echo
cat <<EOF
####################
###### Theme  ######
####################
EOF

# install theme selected in themes file
seltheme="$(cat "$HOME/.seltheme")"
if [[ "$seltheme" == "nyarch" ]]; then
    #cp -r "./themes/nyarch/i3" "$HOME/.config/"
    cp "$tempdir/arch-themes/nyarch/sway/color" "$HOME/.config/sway/config.d/"
    #cp -r "$HOME/configs/arch-themes/nyarch/polybar" "$HOME/.config/"
    #cp -r "./themes/nyarch/neofetch/lowpoly_flamegirl_blue.txt" "$HOME/.config/neofetch/lowpoly_flamegirl.txt"
    #cp "./themes/.fehbg-nyarch" "$HOME/.fehbg"
    #sed -i 's/^NAME=".*"/NAME="Rawrch Linyux"/' /etc/os-release
elif [[ "$seltheme" == "space-pink" ]]; then
    #cp -r "./themes/space-pink/i3" "$HOME/.config/"
    cp "$tempdir/arch-themes/space-pink/sway/color" "$HOME/.config/sway/config.d/"
    #cp -r "$HOME/configs/arch-themes/space-pink/polybar" "$HOME/.config/"
    #cp -r "./themes/space-pink/neofetch/lowpoly_flamegirl_orange.txt" "$HOME/.config/neofetch/lowpoly_flamegirl.txt"
    #cp "./themes/.fehbg-space-pink" "$HOME/.fehbg"
fi

# make fehbg executable
#if [[ -f "$HOME/.fehbg" ]]; then
#    chmod +x ~/.fehbg

# copy chosen image for lockscreen and desktop
backgroundimage="/home/exu/Bilder/Art/artstation/dk-lan/artstation_14224733_55806391_月半与鬼哭.jpg"

mkdir -p "$HOME/.cache/backgrounds"
if [ -f "$backgroundimage" ]; then
    cp "$backgroundimage" "$HOME/.cache/backgrounds/desktop"
    cp "$backgroundimage" "$HOME/.cache/backgrounds/lockscreen"
else
    printf "\033[38;2;200;20;20mCouldn't find background image\n\033[0m"
fi

chmod +x "$HOME/scripts/gsettings.sh"
bash "$HOME/scripts/gsettings.sh"
echo "Set theme using gsettings"

echo
cat <<EOF
####################
##### Bash Cat #####
####################
EOF

# download cat as cat
echo "Installing bash cat"
mkdir "$tempdir/bash-cat-with-cat"
git clone https://github.com/RealStickman/bash-cat-with-cat.git "$tempdir/bash-cat-with-cat" &>/dev/null
cp "$tempdir/bash-cat-with-cat/cat.sh" "$HOME/scripts/pieces/cat.sh"
#rm -rf ./bash-cat-with-cat

echo
cat <<EOF
########################################
############### Autostart ##############
########################################
EOF

# create autostart directory
mkdir -p ~/.config/autostart/

# copy corectrl desktop file
if [[ $(pacman -Q | grep corectrl) ]]; then
    cp /usr/share/applications/org.corectrl.CoreCtrl.desktop ~/.config/autostart/org.corectrl.CoreCtrl.desktop
fi

echo
cat <<EOF
########################################
############### Services ###############
########################################
EOF

# generate betterlockscreen cache image in background
#imagepath="/home/exu/Bilder/Backgrounds/artstation/dk-lan/artstation_14224733_55806391_月半与鬼哭.jpg"
#if [ -f "$imagepath" ]; then
#    betterlockscreen -u "$imagepath" &
#    pids="$pids $!"
#fi

# reload systemd user scripts
systemctl --user daemon-reload

# set systemd services for vmware (only if installed)
if [[ $(pacman -Q | grep vmware-workstation) ]]; then
    sudo systemctl enable --now vmware-networks.service || echo "Service failed, continuing"
    sudo systemctl enable --now vmware-usbarbitrator.service || echo "Service failed, continuing"
fi

# FIXME temporary
#if [ -f "/etc/pipewire/pipewire.conf" ]; then
#    sudo rm "/etc/pipewire/pipewire.conf"
#fi

# FIXME temporary migrate container store
if [ -f "$HOME/.config/containers/storage.conf" ]; then
    rm "$HOME/.config/containers/storage.conf"
    podman system reset -f
fi

# enable fstrim timer
sudo systemctl enable fstrim.timer

# enable btrfs maintenance timers
if [[ $(pacman -Q | grep btrfsmaintenance) ]]; then
    sudo systemctl restart btrfsmaintenance-refresh.service
    sudo systemctl enable btrfs-balance.timer
    sudo systemctl enable btrfs-scrub.timer
fi

# enable systemd-timesyncd (ntp service)
sudo timedatectl set-ntp true

# enable ssh-agent
systemctl --user enable --now ssh-agent

# enable reflector timer
sudo systemctl enable reflector.timer

# enable vnstat
sudo systemctl enable vnstat

echo
cat <<EOF
########################################
################ Groups ################
########################################
EOF

# set systemd and group for vmware (only if installed)
if [[ $(pacman -Q | grep vmware-workstation) ]]; then
    echo "Setting up group for vmware"
    sudo groupadd -f vmware
    sudo gpasswd -a "$USER" vmware 1>/dev/null
fi

# set group for libvirt
if [[ $(pacman -Q | grep libvirt) ]]; then
    echo "Setting group for libvirt"
    sudo gpasswd -a "$USER" libvirt 1>/dev/null
fi

# set group for wireshark (only if installed)
if [[ $(pacman -Q | grep wireshark-qt) ]]; then
    echo "Setting up group for wireshark"
    sudo groupadd -f wireshark
    sudo gpasswd -a "$USER" wireshark 1>/dev/null
fi

# add group for corectrl
if [[ $(pacman -Q | grep corectrl) ]]; then
    echo "Setting up group for corectrl"
    sudo groupadd -f corectrl
    sudo gpasswd -a "$USER" corectrl 1>/dev/null
fi

# group for controlling backlight
echo "Setting group for backlight"
sudo groupadd -f video
sudo gpasswd -a "$USER" video 1>/dev/null

# render group
echo "Setting group for GPU passing"
sudo groupadd -f render
sudo gpasswd -a "$USER" render 1>/dev/null

# group for monitoring wireguard
echo "Setting group for wireguard"
sudo groupadd -f wireguard
sudo gpasswd -a "$USER" wireguard 1>/dev/null

echo
cat <<EOF
########################################
############# Misc Config  #############
########################################
EOF

# set permissions for sudoers.d to root only
sudo chown root:root -R /etc/sudoers.d/
sudo chmod 600 -R /etc/sudoers.d/

# xfce settings
# disable screensaver & locker
/usr/bin/xfconf-query -c xfce4-session -n -t bool -p /startup/screensaver/enabled -s false

#make bash scripts executable
chmod +x -R ~/.config/polybar/
chmod +x -R ~/.config/sway/scripts
chmod +x -R ~/scripts

# make applications executable
chmod +x -R ~/.local/share/applications

#remove downloaded folder
rm -rf ~/config

echo
cat <<EOF
########################################
############## Reloading  ##############
########################################
EOF

# reload applications
update-desktop-database ~/.local/share/applications/

# sync doom-emacs only if it is installed
if [[ -f  ~/.config/emacs/bin/doom ]]; then
    ~/.config/emacs/bin/doom sync &
    pids="$pids $!"
fi

# disable freedesktop notification daemon
if [[ -f "/usr/share/dbus-1/services/org.freedesktop.Notifications.service" ]]; then
    sudo mv /usr/share/dbus-1/services/org.freedesktop.Notifications.service /usr/share/dbus-1/services/org.freedesktop.Notifications.service.disabled
fi

# dunst
pkill dunst && nohup dunst &

# reload .Xresources
# TODO fails without display
#if [[ -f "$HOME/.Xresources" ]]; then
#    xrdb ~/.Xresources
#fi

# execute feh
#if [[ -f "$HOME/.fehbg" ]]; then
#    "$HOME/.fehbg"
#fi

#if ps aux | grep -E "\si3(\s|$)" &>/dev/null; then
#    i3-msg restart 1>/dev/null
#fi

if [ $XDG_SESSION_DESKTOP == "sway" ]; then
    swaymsg reload
    echo "Reloaded sway"
fi

# wait for all background jobs to finish
wait $pids && echo "Finished background jobs"

echo
cat <<EOF
########################################
############### Finished ###############
########################################
EOF

#output
echo -e "\033[38;2;20;200;20mFinished updating everything!\033[0m"
echo Launching new shell!

# reminder for enable additional gpu features for corectrl with amd gpus
if [[ $(pacman -Q corectrl) ]]; then
    echo -e "\033[38;2;200;20;20mRemember to set \"amdgpu.ppfeaturemask=0xffffffff\" in the kernel!!\033[0m"
fi

# reload user default shell
exec "$(getent passwd $LOGNAME | cut -d: -f7)"

# exit successfully
exit 0
