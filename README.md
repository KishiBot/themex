# Themex

## Description
Themex is a really dumb linux theme manager. It is very specifically setup to work tightly with my personal setup which probably makes it unusable for anyone else. It works only with hyprland.

## Requirements
Hyprland
Hyprshade
wlsunset
rofi or fzf
mpvpaper
swaybg

## Usage
To create a theme you can use an existing one as template, edit it and then create new theme with `themex -c [name]`.

### config.json
All configuration is inside `config.json` file located in `.themex` folder. config.json is unique for each theme.<br>
`live` sets whether current theme uses still picture or a video for background.`<br>
name` sets the name of the config.`<br>
transition_shader` sets parameters of the shader that is used when transitioning between workspaces (for information on how to set it up refer to Shaders section). `name` is the filename of the transition shader used to locate the file. `enabled` sets whether transition_shader is enabled or not.<br>
`switch_shader` sets parameters of the shader used when switching between themes. (for more information refer to Shaders section).<br>

### Colors
Themex allows for theme wide colors. These are defined in `style.css` file inside `$HOME/.themex` folder. Color can be defined as such: `@define-color background #1C0D26;`. To use these colors inside waybar, simply include this file in your waybar's style.css.<br>
Hyprland doesn't support css styling, but you can still use these. For that you need `theme` file to be present in hyprland directory. In this file you can write hyprland config as if it was .conf file, but instead of hardcoded colors you can use {{background}}. For example: `col.inactive_border = rgb({{background}})`.<br>
When switching to a theme or by using `themex -h` this file will be copied into `theme.conf` file that you can include in your main hyprland.conf like this: `source = $HOME/.config/hypr/theme.conf`. All color templates will be replaced with colors from your style.css.

### Shaders
You can set up custom glsl shaders for certain transitions like `transition_shader` for workspace transitions and `switch_shader` for theme switch transitions. Shaders are located inside `$HOME/.config/hypr/shaders/` folder. For `transition_shader` to work you need to put `bind = $mainMod, [key], exec, themex_workspace_transition [workspace]` for each desired workspace in hyprland config file. themex_workspace_transition will be installed by running `install` script together with `themex`.<br>
In config.json you can specify duration of each shader in `length` parameter, which takes in time in seconds.
`name` parameter takes in name of the shader such as `transition.glsl` and expects this shader to be located in the proper folder.<br>
`switch_shader` can have two different shaders depending on whether the theme is being switched out of or switched into.<br>
