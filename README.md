# DOTFILES

## Install required dependencies
``` paru -Sy awesome-git alacritty rofi todo-bin acpi acpid acpi_call upower \
jq inotify-tools polkit-gnome xdotool xclip gpick ffmpeg blueman \
pipewire pipewire-alsa pipewire-pulse pamixer brightnessctl scrot redshift \
feh mpv mpd mpc mpdris2 ncmpcpp playerctl --needed 
```

## Install custom apps
``` paru -Sy brave visual-studio-code-bin spotify-bin foliate remnote ```

## Enable services

```systemctl --user enable mpd.service
systemctl --user start mpd.service
```

## Clone repository and copy config

```git clone --recurse-submodules https://github.com/rxyhn/dotfiles.git
cd dotfiles && git submodule update --remote --merge
```

## Copy fonts
```cp -r config/* ~/.config/
cp -r misc/fonts/* ~/.fonts/
cp -r misc/fonts/* /usr/share/fonts/
```

``` fc-cache -v ```
