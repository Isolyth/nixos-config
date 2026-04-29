{ pkgs, lib, config, ... }:
let
  statuslineSrc = pkgs.fetchFromGitHub {
    owner = "Isolyth";
    repo = "claude-code-statusline";
    rev = "1dc3b96acc0925d74dd518360c398be6afe41021";
    hash = "sha256-S3JlWBiKjAbdTZRK4TJDQxpuKqabkpkzCtmsmM1gqIw=";
  };

  # Keys we want to enforce in ~/.claude/settings.json. Anything else (permission
  # grants, session state, plugin tweaks made via UI) is left alone by jq merge.
  managed = {
    statusLine = {
      type = "command";
      command = "bash ${config.home.homeDirectory}/.claude/statusline.sh";
    };
  };

  managedJson = pkgs.writeText "claude-managed.json" (builtins.toJSON managed);
in {
  # 1. Pin the statusline script declaratively.
  home.file.".claude/statusline.sh" = {
    source = "${statuslineSrc}/statusline.sh";
    executable = true;
  };

  # 2. On each home-manager activation, deep-merge `managed` into existing
  # ~/.claude/settings.json. Lets Claude Code keep ownership of the file (UI
  # permission grants still stick) while guaranteeing our keys are correct.
  home.activation.claudeSettingsMerge = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    settings="$HOME/.claude/settings.json"
    mkdir -p "$HOME/.claude"
    if [ ! -f "$settings" ]; then
      echo '{}' > "$settings"
    fi
    tmp=$(mktemp)
    ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "$settings" ${managedJson} > "$tmp"
    mv "$tmp" "$settings"
  '';
}
