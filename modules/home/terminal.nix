{ config, pkgs, ... }:

{
  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;

    settings = {
      # background-blur not set because Hyprland already does it for us
      background-opacity = 0.58;

      window-padding-x = 14;
      window-padding-y = 14;
      window-decoration = "none";
      confirm-close-surface = false;
      resize-overlay = "never";

      cursor-style = "block";
      cursor-style-blink = false;

      shell-integration = "fish";
      shell-integration-features = "cursor,sudo,title";

      # Ghostty renders on the iGPU under PRIME offload; this keeps it there
      # rather than spinning up the dGPU for a terminal.
      gtk-single-instance = true;

      auto-update = "off"; # Nix owns updates
    };
  };

  programs.fish = {
    enable = true;
    plugins = [
      { name = "grc"; src = pkgs.fishPlugins.grc.src; }
    ];

    shellAbbrs = {
      ".." = "cd ..";
      "..." = "cd ../..";
      ".2" = "cd ../..";
      "...." = "cd ../../..";
      ".3" = "cd ../../..";
      ".4" = "cd ../../../..";
      ".5" = "cd ../../../../..";
      lg = "lazygit";
      g = "git";
      c = "cargo";
    };

    shellAliases = {
      ls = "${pkgs.eza}/bin/eza -lh --group-directories-first --icons=auto";
      lt = "${pkgs.eza}/bin/eza --tree --level=2 --long --icons --git";
      ff = "${pkgs.fzf}/bin/fzf --preview 'bat --style=numbers --color=always {}'";
      cd = "z"; # Dont know how to link that with the zoxide package
    };

    functions = {
      clear = ''
        command clear
        fastfetch
        commandline -f repaint
      '';
      fish_greeting = "${pkgs.fastfetch}/bin/fastfetch";
    };
  };

  # ── Prompt ────────────────────────────────────────────────────────────────
  xdg.configFile."fish/conf.d/prompt.fish".text = ''
    set -g rainbow_color_index 1
    set -g rainbow_colors \
        '#55FF55' '#33FFBB' '#00DDFF' '#3399FF' '#5D5DFF' '#AA55FF' '#FF55FF' \
        '#FF77AA' '#FF9999' '#FF5555' '#FF884D' '#FFBB33' '#FFFF55' '#B6FF5D'

    set -g rainbow_color_count (count $rainbow_colors)

    function fish_prompt
        set -g fish_prompt_pwd_dir_length 0

        set -g __fish_git_prompt_showupstream informative
        set -g __fish_git_prompt_show_informative_status 1
        set -g __fish_git_prompt_hide_untrackedfiles 1
        set -g __fish_git_prompt_char_upstream_ahead ""
        set -g __fish_git_prompt_char_upstream_behind ""
        set -g __fish_git_prompt_char_upstream_prefix ""
        set -g __fish_git_prompt_char_stateseparator '|'
        set -g __fish_git_prompt_char_stagedstate "●"
        set -g __fish_git_prompt_char_dirtystate " "
        set -g __fish_git_prompt_char_untrackedfiles "…"
        set -g __fish_git_prompt_char_conflictedstate "✖"
        set -g __fish_git_prompt_char_cleanstate "✔"

        printf '%s' (set_color $fish_color_autosuggestion) (date '+%H:%M:%S')
        set_color reset

        set -g rainbow_color_index (math "$rainbow_color_index % $rainbow_color_count + 1")
        set -l rainbow_color $rainbow_colors[$rainbow_color_index]
        printf '%s ' (set_color $rainbow_color) $USER
        set_color reset

        printf '%s' (set_color --bold $fish_color_normal) (prompt_pwd)
        set_color reset

        printf '%s ' (fish_git_prompt)

        set_color reset
        printf '%s%s ' (set_color $fish_color_cwd) (set_color reset)
    end
  '';

  # ── supporting CLI tools ──────────────────────────────────────────────────
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };
  programs.eza.enable = true;
  programs.fzf.enable = true;

  programs.bat = {
    enable = true;
    config = {
      style = "numbers,changes";
      italic-text = "always";
      theme = "ansi";
    };
  };

  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        type = "small";
        padding.top = 1;
      };
      display.separator = "  ";
      modules = [
        "break"
        {
          type = "custom";
          format = "┌────────────────────── Hardware ──────────────────────┐";
          outputColor = "red";
        }
        { type = "title"; key = " PC"; keyColor = "green"; }
        { type = "cpu"; key = "│ ├󰍛CPU"; showPeCoreCount = true; format = "{1}"; keyColor = "green"; }
        { type = "gpu"; key = "│ ├󰍛 GPU"; keyColor = "green"; } { type = "memory"; key = "└ └󰍛 Memory"; keyColor = "green"; }
        {
          type = "custom";
          format = "└──────────────────────────────────────────────────────┘";
          outputColor = "red";
        }
        "break"
        { type = "custom";
          format = "┌────────────────────── Software ──────────────────────┐";
          outputColor = "red";
        }
        { type = "os"; key = " OS"; keyColor = "yellow"; }
        { type = "kernel"; key = "│ ├ Kernel"; keyColor = "yellow"; }
        { type = "packages"; key = "│ ├󰏖 Packages"; keyColor = "yellow"; }
        { type = "shell"; key = "│ ├ Shell"; keyColor = "yellow"; }
        {
          type = "command";
          key = "│ ├ OS Age";
          keyColor = "yellow";
          text = "birth_install=$(stat -c %W /); current=$(date +%s); time_progression=$((current - birth_install)); days_difference=$((time_progression / 86400)); echo $days_difference days";
        }
        { type = "uptime"; key = "└ └ Uptime"; keyColor = "yellow"; }
        "break"
        { type = "de"; key = " DE"; keyColor = "blue"; }
        { type = "lm"; key = "│ ├ LM"; keyColor = "blue"; }
        { type = "wm"; key = "│ ├ WM"; keyColor = "blue"; }
        { type = "gpu"; key = "│ ├󰍛 GPU Driver"; format = "{3}"; keyColor = "blue"; }
        { type = "wmtheme"; key = "└ └󰉼 Theme"; keyColor = "blue"; }
        {
          type = "custom";
          format = "└────────────────────────────────────────────────────┘";
          outputColor = "red";
        }
        "colors"
        "break"
      ];
    };
  };

  home.packages = with pkgs; [
    ripgrep
    fd
    jq
    curl
    wget
    unzip
    tree
    htop
    fishPlugins.grc
  ];
}
