#!/bin/fish
echo "Starting script..."
echo "You will be asked for your password again when Paru begins installing apps so pay some attention."
cd ~
sleep 3

clear
echo "🎮 Installing NVIDIA drivers..."
sudo pacman -S nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-settings linux-cachyos-headers
sleep 1
nvidia-smi
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

clear
echo "📦 Installing essential software..."
sudo pacman -S --noconfirm steam wine wine-gecko wine-mono obs-studio gimp flatpak discover cmake make dkms git vscode audacity vlc syncthing python3

echo "🔗 Enabling Flathub..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo "🔑 Adding Firefox Nightly key..."
gpg --keyserver hkps://keys.openpgp.org --recv-keys 14F26682D0916CDD81E37B6D61B7B526D98F0353

echo "⬇️ Installing AUR apps..."
paru -S --noconfirm firefox-nightly-bin minecraft-launcher jre17-openjdk lutris discord spotify streamdeck-ui oversteer winegui hid-tmff2-dkms-git ncdu emudeck-bin
cd ~/Downloads && git clone https://github.com/b1k/b3DS
cd ~

echo "🔄 Setting up Syncthing..."
systemctl --user enable syncthing
systemctl --user start syncthing
echo "Please open http://localhost:8384 to link your Steam Deck."
sleep 2

clear
echo "📦 Installing VTube Studio with Proton-GE..."

# 1. Create directories
cd ~
mkdir -p ~/.proton-ge
mkdir -p ~/.vtubestudio-proton
mkdir -p ~/Games/VTubeStudio

# 2. Download and extract latest Proton-GE (edit version as needed)
echo "📥 Downloading Proton-GE..."
curl -L -o /tmp/Proton-GE.tar.gz https://github.com/GloriousEggroll/proton-ge-custom/releases/download/GE-Proton8-27/GE-Proton8-27.tar.gz
tar -xf /tmp/Proton-GE.tar.gz -C ~/.proton-ge
rm /tmp/Proton-GE.tar.gz

# 3. Prompt user to copy their VTube Studio files
echo "📁 Please copy your VTube Studio Windows files to: ~/Games/VTubeStudio"
echo "Waiting for confirmation to continue..."
read -p "Press enter once VTubeStudio.exe is inside ~/Games/VTubeStudio..."

# 4. Create launcher script
set LAUNCHER_DIR "$HOME/.local/share/applications"
set FILE "$LAUNCHER_DIR/vtubestudio.desktop"

echo '[Desktop Entry]
Name=VTube Studio
Exec=$HOME/Games/run-vtubestudio.sh
Path=$HOME/Games/VTubeStudio
Terminal=false
Type=Application
Icon=$HOME/Icons/vtubestudio.png
Categories=AudioVideo;' > $FILE

chmod +x ~/Games/run-vtubestudio.sh

# 5. Create .desktop entry
set LAUNCHER_DIR "$HOME/.local/share/applications"
mkdir -p $LAUNCHER_DIR

set FILE "$LAUNCHER_DIR/vtubestudio.desktop"

echo '[Desktop Entry]
Name=VTube Studio
Exec='$HOME'/Games/run-vtubestudio.sh
Type=Application
Comment=Run VTube Studio standalone with Proton-GE
Icon=face-smile
Categories=Graphics;
Terminal=false' > $FILE

echo "✅ VTube Studio setup complete. It will appear in your application launcher."
sleep 2

clear
echo "🔧 Starting setup for Deep-Live-Cam, RVC WebUI, and RVC-GUI..."

set INSTALL_DIR "$HOME/Downloads/CachyInstallScript"
set RVC_WEBUI_ARCHIVE "$INSTALL_DIR/RVC-WebUI.tar.gz"
set RVC_GUI_ARCHIVE "$INSTALL_DIR/RVC-GUI.tar.gz"

# Create target directories
mkdir -p "$HOME/Applications/RVC-WebUI"
mkdir -p "$HOME/Applications/RVC-GUI"


# 1. Setup RVC WebUI
echo "📦 Setting up RVC WebUI..."
tar -xzf "$RVC_WEBUI_ARCHIVE" -C "$HOME/Applications/RVC-WebUI" --strip-components=1
cd "$HOME/Applications/RVC-WebUI" || exit

# Install Python dependencies
python3 -m venv venv
source venv/bin/activate
python3 -m ensurepip --upgrade
python3 -m pip install --upgrade pip
python3 -m pip install -r requirements.txt
deactivate

# 2. Setup RVC-GUI
echo "📦 Setting up RVC-GUI..."
tar -xzf "$RVC_GUI_ARCHIVE" -C "$HOME/Applications/RVC-GUI" --strip-components=1
cd "$HOME/Applications/RVC-GUI" || exit

# Install Python dependencies
python3 -m venv venv
source venv/bin/activate
python3 -m pip install --upgrade pip
python3 -m pip install -r requirements.txt
deactivate

sleep 2

clear
echo "🐚 Adding fish aliases..."
echo "alias cleanup='set orphans (pacman -Qdtq); and sudo pacman -Rns \$orphans && paru -Scc && flatpak uninstall --unused; or echo "No unused dependencies/cached build files to remove."'" >> ~/.config/fish/config.fish
echo "alias update='sudo pacman -Syu && paru -Syu'" >> ~/.config/fish/config.fish
echo "alias debloat='ncdu / --exclude /media --exclude /run/timeshift'" >> ~/.config/fish/config.fish
echo "Aliases 'cleanup', 'update' and 'debloat' added to Fish shell."
sleep 2

clear
cd ~
echo "Removing unwanted packages..."
sudo pacman -R alacritty micro cachyos-micro-settings haruna meld btop
cleanup
sleep 2

clear
echo "✅ Automated post-install script completed."
sleep 1
cd ~/Desktop/ && touch checklist.txt
echo "
1. Run sudo nano /usr/share/cachyos-fish-config/cachyos-config.fish (open this in a new terminal window) and look for any lines mentioning fastfetch then remove them to prevent fastfetch running every time you open the terminal.

2. Watch this video (https://www.youtube.com/watch?v=Oqla04P_2QA) to see the process for getting dad's HP Reverb working since 24H2 doesn't work with WMR anymore.

3. Open http://localhost:8384 for Syncthing to link your Steam Deck folders to your PC for emulation save files.

4. Download this file (https://cdn.discordapp.com/attachments/1267198348415471698/1309301528124719124/RVC-SVC-Best-Dataset-Maker-main.zip?ex=682f0c51&is=682dbad1&hm=4bfdc3a2cf83acd83566624262c98997b3470faf5b8c124981841a71ef4c0fd7&) and run pyinstaller to convert it to the right executable for your system.

5. Get in a call with Gangsta and ask him to walk you through building the RVC tools.

6. Rice the shit out of your system until you're happy with how it works (mainly clear out unwanted entries from the application launcher and change names of things from EmuDeck) and find a really nice background.

7 . Enjoy your new system.
" > checklist.txt
cd ~
sleep 1
echo ""
echo "Manual steps have been placed into a checklist text file on your desktop for you to look back over and
complete yourself as the script cannot do these."
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
