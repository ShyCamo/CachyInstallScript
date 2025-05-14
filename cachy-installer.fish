#!/bin/fish
echo "Starting post-install script..."
echo "🎮 Verifying NVIDIA Driver..."
if not nvidia-smi
    echo "Installing NVIDIA drivers..."
    sudo pacman -S --noconfirm nvidia nvidia-utils nvidia-settings
end
echo "NVIDIA drivers verified."

sleep 2
echo "🛠 Enabling KMS for Wayland..."
sleep 1
echo "options nvidia_drm modeset=1" | sudo tee /etc/modprobe.d/nvidia.conf
sudo mkinitcpio -P
echo "KMS for Wayland enabled."

sleep 2
echo "📂 Editing GRUB config..."
sleep 1
sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="[^"]*/& nvidia_drm.modeset=1/' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg
echo "✅ NVIDIA setup done. Please reboot for changes to take effect."

sleep 2
echo "📦 Installing essential software..."
sudo pacman -S --noconfirm dolphin dolphin-emu steam wine wine-gecko wine-mono obs-studio citra gimp flatpak discover cmake make dkms linux-cachyos-headers git vscode audacity

echo "🔗 Enabling Flathub..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo "🔑 Adding Firefox Nightly key..."
gpg --keyserver hkps://keys.openpgp.org --recv-keys 14F26682D0916CDD81E37B6D61B7B526D98F0353

echo "⬇️ Installing AUR apps..."
paru -S --noconfirm firefox-nightly minecraft-launcher jre17-openjdk lutris ryujinx-bin discord spotify streamdeck-ui oversteer winegui

echo "🔄 Setting up Syncthing..."
sudo pacman -S --noconfirm syncthing
systemctl --user enable syncthing
systemctl --user start syncthing
echo "Please open http://localhost:8384 to link your Steam Deck device."

echo "🛞 Installing Thrustmaster T128 driver..."
git clone https://github.com/Thrustmaster/hid-tmff2.git
cd hid-tmff2
make
sudo make install

echo "🔧 Enabling DKMS support for Thrustmaster T128..."
sudo dkms add .
sudo dkms build hid-tmff2/1.0
sudo dkms install hid-tmff2/1.0
dkms status
cd ..
echo "Main software and drivers installed."
cd ~

sleep 2
echo "🐚 Adding fish aliases..."
echo "alias cleanup='set orphans (pacman -Qdtq); and sudo pacman -Rns \$orphans; or echo "No unused dependencies to remove."'" >> ~/.config/fish/config.fish
echo "alias update='sudo pacman -Syu && paru -Syu'" >> ~/.config/fish/config.fish
echo "Aliases added to Fish shell."
sleep 2
clear
echo "✅ Automated post-install script completed."
sleep 1
cd ~/Desktop/ && touch checklist.txt
echo "
1. Download the files for the camera software from your personal MEGA account. Build instructions should be available from the GitHub link in your private Discord server. Failing that, run it through VSCode like on your MacBook.

2. Download the files for RVC WebUI from the DMs of Gangsta and ask him how to build it.

3. Run sudo nano /usr/share/cachyos-fish-config/cachyos-config.fish (open this in a new terminal window) and look for any lines mentioning fastfetch then remove them to prevent fastfetch running every time you open the terminal.

4. Watch this video (https:www.youtube.com/watch?v=Oqla04P_2QA) to see the process for getting a HP Reverb working since 24H2 doesn't work with WMR anymore.

5. Open http://localhost:8384 for Syncthing to link your Steam Deck folders to your PC for emulation save files.
" > checklist.txt
cd ~
sleep 1
echo "Manual steps have been placed into a checklist text file on your desktop for you to look back over and 
complete yourself as the script cannot."
sleep 2
function prompt_reboot
    read -l -P "🎯 Do you want to reboot now? (Y/N): " answer
    switch $answer
        case y Y
            echo "♻️ Rebooting in 10 seconds. Press CTRL+C if you wish to cancel and reboot later."
            sleep 10
			reboot
        case '*'
            echo "🚫 Reboot cancelled. Please reboot manually later."
    end
end

prompt_reboot