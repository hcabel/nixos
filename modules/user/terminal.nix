{ pkgs, ... }:

{
  programs.kitty = {
    enable = true;
    font = {
      name = "SpaceMono Nerd Font";
      size = 12;
    };
    settings = {
      background_opacity = "0.58";
      dynamic_background_opacity = true;

      scrollback_lines = 10000;
      enable_audio_bell = false;
      window_padding_width = 8;
      confirm_os_window_close = 0;
    };
  };

  # cd but better
  programs.zoxide = {
    enable = true;
    options = [ "--cmd cd" ];
  };
  programs.fzf.enable = true; # fuzzy finder
  home.packages = with pkgs; [
    bat # cat but better
    eza # ls but better
    fd # find but better
    dust # du but better
    ripgrep # grep but better

    jq # JSON processor
    tealdeer # tldr of help pages
  ];

  programs.fish = {
    enable = true;

    shellAliases = {
      ls = "eza -lh --group-directories-first --icons=auto";
      ll = "eza -lah --group-directories-first --icons=auto";
      ff = "fzf --preview 'bat --style=numbers --color=always {}'";
      cat = "bat -pp";
    };

    shellAbbrs = {
      g = "git";
      lg = "lazygit";
      os = "nh os";
      ns = "nix-shell -p";
      nr = "nix run nixpkgs#";
      mk = "mkdir -p";
    };

    functions = {
      lt = ''
        set -l level 2
        test (count $argv) -gt 0; and set level $argv[1]
        eza --tree --level=$level --long --icons --git
      '';
      mkcd = "test -n \"$argv[1]\"; and mkdir -p $argv[1]; and cd $argv[1]";
      fcd = ''
        set -l dir (fd --type d --hidden --exclude .git | fzf --preview "eza --tree --level=1 --icons {}")
        test -n "$dir"; and cd $dir
      '';
    };

    plugins = with pkgs.fishPlugins; [
      {
        name = "done";
        src = done.src;
      }
      {
        name = "sponge";
        src = sponge.src;
      }
      {
        name = "autopair";
        src = autopair.src;
      }
    ];

    interactiveShellInit = ''
      set -g fish_greeting ""
      set -g fish_prompt_pwd_dir_length 0

      # ── plugin settings ──
      set -g __done_min_cmd_duration 15000
      set -g __done_notify_sound 0
      set -g __done_exclude '^(nvim|lazygit)'

      # ── git prompt config: set once, not on every render ──
      function _git_segment
          set -l branch (git symbolic-ref --short HEAD 2>/dev/null)
          or set branch (git rev-parse --short HEAD 2>/dev/null)
          test -z "$branch"; and return

          set -l dirty ""
          set -l changes (git status --porcelain --ignore-submodules=dirty 2>/dev/null)
          test (count $changes) -gt 0; and set dirty "•"

          printf ' [%s%s]' $branch $dirty
      end

      set -g rainbow_colors \
          "#55FF55" "#33FFBB" "#00DDFF" "#3399FF" "#5D5DFF" "#AA55FF" "#FF55FF" \
          "#FF77AA" "#FF9999" "#FF5555" "#FF884D" "#FFBB33" "#FFFF55" "#B6FF5D"
      set -g rainbow_color_count (count $rainbow_colors)
      set -g rainbow_color_index 1

      function fish_prompt
          set -l last_status $status

          set -g rainbow_color_index (math "$rainbow_color_index % $rainbow_color_count + 1")
          set -l accent $rainbow_colors[$rainbow_color_index]

          set_color $fish_color_autosuggestion
          printf '%s ' (date "+%H:%M:%S")

          set_color $accent
          printf '%s ' $USER

          set_color --bold $fish_color_cwd
          printf '%s' (prompt_pwd)
          set_color normal

          set_color "#FF5555"
          printf '%s' (_git_segment)

          if test $last_status -ne 0
              set_color red
              printf ' [%d]' $last_status
          end

          set_color normal

          if test $last_status -ne 0
              set_color red
          else
              set_color $accent
          end
          printf ' ❯ '
          set_color normal
      end
    '';
  };
}
