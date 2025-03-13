#!/usr/bin/env bash

dir="$HOME/.themex/themes"
themex="$HOME/.themex"
style="$HOME/.themex/style.css"
waybarConf="$HOME/.config/waybar"
hyprConf="$HOME/.config/hypr"
kittyConf="$HOME/.config/kitty"
rofi="$HOME/.config/rofi"
shaders="$HOME/.config/hypr/shaders"
config="$HOME/.themex/config.json"

BLACK="\e[0;30m"
RED="\e[0;31m"
GREEN="\e[0;32m"
YELLOW="\e[0;33m"
BLUE="\e[0;34m"
PURPLE="\e[0;35m"
CYAN="\e[0;36m"
WHIE="\e[0;37m"
RESET="\e[0m"


useRofi=false


help() {
    echo "Usage: themex [OPTION]"
    echo ""
    echo "Options:"
    echo "  -c [name]       Create new theme with given name"
    echo "  -u              Updates theme with current theme"
    echo "                  Uses name in config.json"
    echo "                  Creates backup theme \"temp\" from old theme version"
    echo "  -s              Switch theme (uses fzf)"
    echo "                  Creates backup theme \"temp\" from current theme"
    echo "  -h              Reloads hyprland config with colors from style.css"
    echo "                  Use $hyprConf/theme for theme config"
    echo "                  Use \"{{color_name}}\" in theme config"
    echo "  -r              Use rofi instead of fzf"
    echo "                  Needs to be used before -s flag"
    echo "  -t [workspace]  Call a transition script"
    echo "  --boot          Starts a boot sequence"
    exit
}

create_theme() {
    doPrint=true
    if [ $# -eq 2 ] && [ $2 = false ]; then
        doPrint=false
    fi

    new_dir="$dir/$1"
    if [ -d "$new_dir" ]; then
        echo -e $RED"Could not create theme: $1"$RESET
        echo "Theme already exists"
        return
    fi

    if [ ! -f "$themex/config.json" ]; then
        echo -e $RED"Could not create theme: $1"$RESET
        echo "Config file not found"
        return
    fi

    if [ $doPrint = true ]; then
        echo "Creating theme: $1"
    fi
    mkdir "$new_dir"

    mkdir "$new_dir/waybar"
    mkdir "$new_dir/hypr"
    mkdir "$new_dir/hypr/shaders"
    mkdir "$new_dir/kitty"
    mkdir "$new_dir/rofi"

    cp -r "$waybarConf/config.jsonc" "$new_dir/waybar/"
    cp -r "$waybarConf/style.css" "$new_dir/waybar/"
    cp "$hyprConf/theme" "$new_dir/hypr/"
    cp -r "$shaders" "$new_dir/hypr/"
    cp "$kittyConf/kitty.conf" "$new_dir/kitty/"

    jq ".name = \"$1\"" "$themex/config.json" > tmp.json && mv tmp.json "$themex/config.json"
    cp "$themex/config.json" "$new_dir/"
    cp "$themex/wallpaper" "$new_dir/"
    cp "$themex/style.css" "$new_dir/"

    if [ -d "$rofi" ]; then
        cp "$rofi/theme" "$new_dir/rofi/"
    fi

    if [ $doPrint = true ]; then
        echo -e $GREEN"Theme $1 created"$RESET
    fi
}

update_theme() {
    if [ ! -f "$themex/config.json" ]; then
        printf "Config file not found\n"
        return 1
    fi

    name="$(jq -r '.name' "$themex/config.json")"

    if [ ! -d "$dir/$name" ]; then
        echo "Theme $name not found"
        echo "Creating new theme $name"
        create_theme $name
        return 1
    fi

    echo "Updating theme: $name"

    if [ -d "$dir/temp" ]; then
        rm -r "$dir/temp"
    fi
    mkdir "$dir/temp"

    echo -e $YELLOW"Creating backup theme \"theme\""$RESET
    cp -r "$dir/$name/." "$dir/temp/"
    echo -e $YELLOW"Removing old theme $name"$RESET
    rm -r "$dir/$name"
    create_theme "$name"
}

get_theme_col() {
    echo "$(grep -E "$1" "$style" | grep -Eo "#[0-9A-Z]+" | sed "s/\#//")"
}

switch_theme() {
    theme=""

    if [ $useRofi = false ]; then
        theme=$(ls "$dir" | fzf \
            --layout=reverse \
            --border \
            --color=bg+:"#$(get_theme_col secondary)",border:"#$(get_theme_col primary)" \
        )
    else
        theme=$(ls "$dir" | rofi -dmenu -p "Select theme")
    fi

    if [ "$theme" = "" ]; then
        echo "Could not switch theme"
        return
    fi

    if [ -d "$dir/temp" ]; then
        rm -r "$dir/temp"
    fi
    create_theme "temp" false

    rm -rf "$shaders"

    cp -r "$dir/$theme/waybar/config.jsonc" "$waybarConf/"
    cp -r "$dir/$theme/waybar/style.css" "$waybarConf/"
    cp "$dir/$theme/hypr/theme" "$hyprConf/"
    cp -r "$dir/$theme/hypr/shaders" "$hyprConf/"
    cp "$dir/$theme/kitty/kitty.conf" "$kittyConf/"

    if [ -d "$rofi" ]; then
        cp "$dir/$theme/rofi/theme" "$rofi/"
    fi

    cp "$dir/$theme/config.json" "$themex/"
    cp "$dir/$theme/wallpaper" "$themex/"
    cp "$dir/$theme/style.css" "$themex/"


    #Transition shader
    hyprctl keyword debug:damage_tracking 0
    hyprshade on "$shaders/$(jq -r '.switch_shader.disabled.name' $config)"
    sleep $(jq -r '.switch_shader.disabled.length' $config)

    wlsunset -g 0 &
    reload_config_colors

    hyprctl reload
    pkill -USR2 waybar
    sleep $(jq -r '.switch_shader.enabled.length' $config)

    # Transition shader
    hyprctl keyword debug:damage_tracking 0
    hyprshade on "$shaders/$(jq -r '.switch_shader.enabled.name' $config)"
    killall wlsunset
    sleep $(jq -r '.switch_shader.enabled.length' $config)
    hyprshade off
    hyprctl keyword debug:damage_tracking 1
}

reload_config_colors() {
    if [ ! -f "$hyprConf/theme" ]; then
        echo $RED"Could not reload hyprland config"$RESET
        echo "File $hyprConf/theme missing"
        return
    fi

    colors=$(sed -E "s/@define-color //" "$style" | sed -E "s/\s\#[0-9A-Z]+;//")
    temp=$(mktemp)
    name="$(jq -r '.name' "$themex/config.json")"

    cp "$hyprConf/theme" "$hyprConf/theme.conf"

    if [ -d "$rofi" ]; then
        cp "$rofi/theme" "$rofi/theme.rasi"
    fi

    while IFS=', ' read -r -a color; do
        val=$(grep -E "$color" "$style" | grep -Eo "#[0-9A-Z]+" | sed "s/\#//")
        sed "s/{{$color}}/$val/g" "$hyprConf/theme.conf" > "$temp" && mv "$temp" "$hyprConf/theme.conf"

        sed "s/{{$color}}/\#$val/g" "$rofi/theme.rasi" > "$temp" && mv "$temp" "$rofi/theme.rasi"
    done <<< "$colors"

    if [ "$(jq -r '.live' "$themex/config.json")" = "true" ]; then
        killall mpvpaper
    else
        killall swaybg
    fi
}

boot() {
    wlsunset -g 0 &
    sleep 3
    hyprctl keyword debug:damage_tracking 0
    hyprshade on "$shaders/themeswitch2.glsl"
    killall wlsunset
    sleep 0.6
    hyprshade off
    hyprctl keyword debug:damage_tracking 1
}

for arg in "$@"; do
    case $arg in
        --help)
            help
            exit 0
            ;;
        -c) 
            create_theme $OPTARG
            exit 0
            ;;
        -u)
            update_theme
            exit 0
            ;;
        -s)
            switch_theme
            exit 0
            ;;
        -h)
            reload_config_colors
            exit 0
            ;;
        -r)
            useRofi=true
            ;;
        -t)
            themex_workspace_transition $1
            exit 0
            ;;
        --boot)
            boot
            exit 0
            ;;
        *)
            echo "Invalide argument: $OPT"
            exit 0
    esac
done
