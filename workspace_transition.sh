#!/usr/bin/env bash

themex="$HOME/.themex/"
shaders="$HOME/.config/hypr/shaders"
config="$themex/config.json"

if [ "$(jq -r '.transition_shader.enabled' $config)" = "true" ]; then
    ps aux |
        grep -E 'workspace_transition.sh' |
        grep -E 'bash' |
        sed -E "s/kishi\s+([0-9]+).*/\1/" |
        while IFS= read -r p; do
            if [ "$p" -ne "$$" ]; then
                echo "killing: $p"
                kill $p
            fi
        done

    hyprctl keyword debug:damage_tracking 0
    hyprshade on "$shaders/$(jq -r '.transition_shader.name' $config)"
    hyprctl dispatch workspace $1
    sleep $(jq -r '.transition_shader.length' $config)
    hyprctl keyword debug:damage_tracking 1
    hyprshade off
    hyprctl dispatch workspace $1
else
    hyprctl dispatch workspace $1
fi


