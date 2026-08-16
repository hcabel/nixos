{ config, lib, pkgs, ... }:

# Clone my already existing Neovim config

let
  themeDir = config.hcabel.theme.currentDir;
  nvimConfigDir = "${config.xdg.configHome}/nvim";
  nvimConfigRepo = "git@github.com:hcabel/neovim-config.git";
in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    sideloadInitLua = true; # Do not let HM own init.lua (my config already has one)

    # TODO [hcabel 2026-08-16]: Replace LSPs by mason
    extraPackages = with pkgs; [
      # nix
      nixd
      nixfmt
      # rust
      rust-analyzer
      # lua
      lua-language-server
      stylua
      # go
      gopls
      gotools
      # web
      typescript-language-server
      vscode-langservers-extracted
      # c/c++
      clang-tools
      gcc # nvim-treesitter needs a real C compiler to build parsers
      # other commands
      tree-sitter
      ripgrep
      fd
    ];
  };

  home.sessionVariables.EDITOR = "nvim";

  home.packages = with pkgs; [
    rustc
    cargo
    go
    nodejs
  ];

  # Clone config on a machine if it doesn't exist yet
  home.activation.cloneNvimConfig = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
    if [ ! -e "${nvimConfigDir}" ] && [ ! -L "${nvimConfigDir}" ]; then
      run ${pkgs.git}/bin/git clone ${nvimConfigRepo} "${nvimConfigDir}"
    fi
  '';
}
