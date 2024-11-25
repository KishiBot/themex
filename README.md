# Themex

### Description
Themex is really dumb linux theme manager. It is very specifically setup to work tightly with my personal setup which probably makes it unusable for anyone else. It basically works only with hyprland and its default directory structure.

### Usage
To use this you need very specific structure. Use `$HOME/.config/hypr/theme` file as config file for hyprland. This should contain all specifics for the current theme. You can hardcode colors here but prefered way is to use templates like `{{color1}}`. These templates will get replaced by colors specified in `style.css` file. Your main hyprland.conf file should then import theme.conf which will be generated from aforementioned `theme` file.<br>
For waybar use `$HOME/.config/waybar/config.jsonc` and `$HOME/.config/waybar/style.css` files. Both of these will be part of current theme and will be swapped with themes. Note that waybar's style.css is different from the main style.css file and to use the same colors as used within hyprland config (which are specified in the main style.css) you should include the main style.css in waybar's style.css and use its colors.<br>
Kitty has its `$HOME/.config/kitty/kitty.conf` file backped up with current theme and swapped as well.<br>
For rofi you can setup colors and specific themes in the same way as hyprland. Use `$HOME/.config/rofi/theme` file for your style. From this a `theme.rasi` file will be generated in rofi's config directory and you should import this in the `config.rasi` file. If rofi's config directory is not present, it will be ignored by themex.<br>
Wallpaper can be either static image or a video. For static image `swaybg` is used and for video `mpvpaper` is used. In `$HOME/.themex/config.json` a parameter of whether a video or static image is in use should be specified. `$HOME/.themex/wallpaper` file will be used for wallpaper. In `$HOME/.config/hypr/theme` you have to startup wallpaper with aforementoned wallpaper file.<br>
`$HOME/.themex/style.css` is main style.css file. In here all colors used throughout the theme should be specified.<br>
