#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Update the package manager
echo "Updating package manager..."
sudo dnf install -y dnf-plugins-core

# Update the system packages
echo "Updating system packages..."
sudo dnf update -y

# Add Brave repository
echo "Adding Brave repository..."
sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo

# Import the Brave GPG key
echo "Importing Brave GPG key..."
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc

# Install Brave browser
echo "Installing Brave browser..."
sudo dnf install -y brave-browser
echo "Brave browser installation completed."

# Add the Mullvad repository server to dnf
echo "Adding Mullvad repository..."
sudo dnf config-manager --add-repo https://repository.mullvad.net/rpm/stable/mullvad.repo

# Install the Mullvad VPN package
echo "Installing Mullvad VPN..."
sudo dnf install -y mullvad-vpn
echo "Mullvad VPN installation completed successfully."

# Install the Mullvad browser
echo "Installing Mullvad browser..."
sudo dnf install -y mullvad-browser
echo "Mullvad browser installation completed successfully."

# Install NextDNS
echo "Installing NextDNS..."
curl -sL https://nextdns.io/install | sh
echo "NextDNS installation completed successfully."

# Install Flatpaks
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# List of Flatpak applications to install
flatpak_apps=(
    app.drey.Warp
    com.calibre_ebook.calibre
    com.github.johnfactotum.Foliate
    com.github.maoschanz.drawing
    com.github.neithern.g4music
    com.github.tchx84.Flatseal
    com.github.tenderowl.frog
    com.vscodium.codium
    de.schmidhuberj.tubefeeder
    garden.jamie.Morphosis
    io.github.amit9838.mousam
    io.github.flattool.Warehouse
    gitlab.news_flash.NewsFlash
    me.dusansimic.DynamicWallpaper
    net.sapples.LiveCaptions
    org.gimp.GIMP
    org.inkscape.Inkscape
    org.keepassxc.KeePassXC
    org.nickvision.tagger
    org.onlyoffice.desktopeditors
    org.qbittorrent.qBittorrent
)

# Install each Flatpak application
for app in "${flatpak_apps[@]}"; do
    echo "Installing Flatpak application: $app..."
    flatpak install -y flathub "$app"
done

# Clean up package manager cache
echo "Cleaning up package manager cache..."
sudo dnf clean all

echo "All operations completed successfully."

