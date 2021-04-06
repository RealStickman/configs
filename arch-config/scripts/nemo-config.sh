#!/usr/bin/env bash
set -euo pipefail

# set terminal emulator
gsettings set org.cinnamon.desktop.default-applications.terminal exec kitty

# list view
gsettings set org.nemo.preferences default-folder-viewer list-view

# show hidden files
gsettings set org.nemo.preferences show-hidden-files true

# show terminal button
gsettings set org.nemo.preferences show-open-in-terminal-toolbar true

# TODO
gsettings set org.nemo.preferences show-edit-icon-toolbar false

# enable open in terminal
gsettings set org.nemo.preferences.menu-config background-menu-open-in-terminal true

# disable favourites
gsettings set org.nemo.preferences.menu-config selection-menu-favorite false

# disable pin
gsettings set org.nemo.preferences.menu-config selection-menu-pin false

# enable changing keyboard shortcuts
gsettings set org.cinnamon.desktop.interface can-change-accels true
