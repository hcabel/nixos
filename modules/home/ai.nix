{ pkgs, lib, ... }:

let
  claudeSettings = pkgs.writeText "claude-settings.json" (builtins.toJSON {
    permissions = {
      defaultMode = "plan";

      allow = [
        "Read(//**)"
      ];

      ask = [
        "Bash(git add:*)"
        "Bash(git commit:*)"
        "Bash(git push:*)"
        "Bash(git rebase:*)"
        "Bash(git reset:*)"
        "Bash(git merge:*)"
        "Bash(git checkout:*)"
        "Bash(git clean:*)"
        "Bash(git tag:*)"
        "Bash(git branch:*)"
        "Bash(git stash:*)"
        "Bash(git cherry-pick:*)"
        "Bash(git restore:*)"
      ];

      deny = [
        "Read(~/.ssh/**)"
        "Read(~/.gnupg/**)"
        "Read(//var/lib/sops-nix/key.txt)"
        "Read(~/.mozilla/firefox/**)"
      ];
    };

    env = {
      DISABLE_TELEMETRY = "1";
      DISABLE_ERROR_REPORTING = "1";
    };
  });
in
{
  home.packages = [ pkgs.claude-code ];

  # Claude Code writes to this file at runtime (e.g. `/model` persists the
  # chosen default), which replaces Home Manager's symlink with a plain
  # file. Managing it via `home.file` then fights that on every switch and
  # fails once a stale `.hm-bak` exists. Seed it once instead, and leave it
  # alone afterwards.
  home.activation.claudeSettingsSeed = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    settingsFile="$HOME/.claude/settings.json"
    if [ ! -e "$settingsFile" ]; then
      $DRY_RUN_CMD install $VERBOSE_ARG -Dm644 ${claudeSettings} "$settingsFile"
    fi
  '';
}
