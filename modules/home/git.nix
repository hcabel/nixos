{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "hcabel";
        email = "coding@hugocabel.com";
      };

      alias = {
        co = "checkout";
        br = "branch";
        ci = "commit";
        st = "status";
      };

      init.defaultBranch = "master";
      pull.rebase = true; # rebase instead of merge on pull
      push.autoSetupRemote = true; # set upstream automatically on push

      diff = {
        algorithm = "histogram"; # clearer diffs on moved/edited lines
        colorMoved = "plain";
        mnemonicPrefix = true;
      };

      commit.verbose = true; # include the diff in the commit template
      column.ui = "auto";
      branch.sort = "-committerdate";
      tag.sort = "-version:refname";

      commit.gpgsign = true;
      tag.gpgsign = true;
      user.signingkey = "C18C77C607AF017AAABE8E3025B7B118CCB7EA3C";

      rerere = {
        enabled = true; # record and reuse conflict resolutions
        autoupdate = true;
      };
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      line-numbers = true;
      side-by-side = false;
    };
  };

  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-gtk2;
  };

  programs.lazygit = {
    enable = true;
    settings = {
      os.edit = "nvim {{filename}}";
      git = {
        overrideGpg = true;
        pagers = [
          {
            name = "delta";
            colorArg = "always";
            pager = "delta --dark --paging=never";
          }
          {
            name = "delta (side-by-side)";
            colorArg = "always";
            pager = "delta --dark --paging=never --side-by-side";
          }
        ];
      };
      gui.showRandomTip = false;
    };
  };

  home.shellAliases.lazygit = "lazygit -ucf ${config.xdg.configHome}/lazygit/config.yml";

  home.packages = with pkgs; [
    gh
    difftastic
  ];
}
