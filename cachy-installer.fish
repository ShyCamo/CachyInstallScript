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
sudo pacman -S --noconfirm steam wine wine-gecko wine-mono obs-studio gimp flatpak discover cmake make dkms git vscode audacity vlc syncthing python3 cuda

echo "🔗 Enabling Flathub..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo "🔑 Adding Firefox Nightly key..."
gpg --keyserver hkps://keys.openpgp.org --recv-keys 14F26682D0916CDD81E37B6D61B7B526D98F0353

echo "⬇️ Installing AUR apps..."
paru -S --noconfirm firefox-nightly-bin minecraft-launcher jre17-openjdk lutris ryujinx discord spotify streamdeck-ui oversteer winegui azahar-appimage hid-tmff2-dkms-git ncdu

echo "🔄 Setting up Syncthing..."
systemctl --user enable syncthing
systemctl --user start syncthing
echo "Please open http://localhost:8384 to link your Steam Deck device."
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
cat << 'EOF' > ~/Games/run-vtubestudio.sh
#!/bin/fish
export STEAM_COMPAT_DATA_PATH="$HOME/.vtubestudio-proton"
"$HOME/.proton-ge/GE-Proton8-27/proton" run "$HOME/Games/VTubeStudio/VTubeStudio.exe"
EOF

chmod +x ~/Games/run-vtubestudio.sh

# 5. Create .desktop entry
mkdir -p ~/.local/share/applications
cat << EOF > ~/.local/share/applications/vtubestudio.desktop
[Desktop Entry]
Name=VTube Studio
Exec=$HOME/Games/run-vtubestudio.sh
Type=Application
Comment=Run VTube Studio standalone with Proton-GE
Icon=face-smile
Categories=Graphics;
Terminal=false
EOF

echo "✅ VTube Studio setup complete. It will appear in your application launcher."
sleep 2

clear
echo "🔧 Starting setup for Deep-Live-Cam, RVC WebUI, and RVC-GUI..."

INSTALL_DIR="$HOME/Downloads/CachyInstallScript"
RVC_WEBUI_ARCHIVE="$INSTALL_DIR/RVC-WebUI.tar.gz"
RVC_GUI_ARCHIVE="$INSTALL_DIR/RVC-GUI.tar.gz"

# Ensure the installation directory exists
if [ ! -d "$INSTALL_DIR" ]; then
    echo "❌ Installation directory not found: $INSTALL_DIR"
    exit 1
fi

# Create target directories
mkdir -p "$HOME/Applications/RVC-WebUI"
mkdir -p "$HOME/Applications/RVC-GUI"


# 1. Setup RVC WebUI
echo "📦 Setting up RVC WebUI..."
if [ -f "$RVC_WEBUI_ARCHIVE" ]; then
    tar -xzf "$RVC_WEBUI_ARCHIVE" -C "$HOME/Applications/RVC-WebUI" --strip-components=1
    cd "$HOME/Applications/RVC-WebUI" || exit

    # Install Python dependencies
    python3 -m venv venv
    source venv/bin/activate
    pip install --upgrade pip
    pip install -r requirements.txt

    # Optional: Create a launcher script
    echo -e "#!/bin/fish\nsource $HOME/Applications/RVC-WebUI/venv/bin/activate\npython infer-web.py" > "$HOME/Applications/RVC-WebUI/start.sh"
    chmod +x "$HOME/Applications/RVC-WebUI/start.sh"

    deactivate
else
    echo "❌ RVC WebUI archive not found: $RVC_WEBUI_ARCHIVE"
fi

# 2. Setup RVC-GUI
echo "📦 Setting up RVC-GUI..."
if [ -f "$RVC_GUI_ARCHIVE" ]; then
    tar -xzf "$RVC_GUI_ARCHIVE" -C "$HOME/Applications/RVC-GUI" --strip-components=1
    cd "$HOME/Applications/RVC-GUI" || exit

    # Install Python dependencies
    python3 -m venv venv
    source venv/bin/activate
    pip install --upgrade pip
    pip install -r requirements.txt

    # Optional: Create a launcher script
    echo -e "#!/bin/fish\nsource $HOME/Applications/RVC-GUI/venv/bin/activate\npython rvcgui.py" > "$HOME/Applications/RVC-GUI/start.sh"
    chmod +x "$HOME/Applications/RVC-GUI/start.sh"

    deactivate
else
    echo "❌ RVC-GUI archive not found: $RVC_GUI_ARCHIVE"
fi

echo "🧷 Creating application launcher entries and installing icons..."

LAUNCHER_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons"

mkdir -p "$LAUNCHER_DIR" "$ICON_DIR"

# RVC WebUI
cp "$INSTALL_DIR/icons/rvc-webui.png" "$ICON_DIR/" 2>/dev/null || echo "⚠️ No icon found for RVC WebUI."
cat <<EOF > "$LAUNCHER_DIR/rvc-webui.desktop"
[Desktop Entry]
Name=RVC WebUI
Exec=$HOME/Applications/RVC-WebUI/start.sh
Path=$HOME/Applications/RVC-WebUI
Terminal=false
Type=Application
Icon=$ICON_DIR/rvc-webui.png
Categories=AudioVideo;
EOF

# RVC-GUI
cp "$INSTALL_DIR/icons/rvc-gui.png" "$ICON_DIR/" 2>/dev/null || echo "⚠️ No icon found for RVC-GUI."
cat <<EOF > "$LAUNCHER_DIR/rvc-gui.desktop"
[Desktop Entry]
Name=RVC-GUI
Exec=$HOME/Applications/RVC-GUI/start.sh
Path=$HOME/Applications/RVC-GUI
Terminal=false
Type=Application
Icon=$ICON_DIR/rvc-gui.png
Categories=AudioVideo;
EOF

# Refresh desktop entries
update-desktop-database "$LAUNCHER_DIR"

echo "✅ Menu entries created. Look for them in the Application Launcher."
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
sudo pacman -R alacritty micro cachyos-micro-settings haruna meld
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
