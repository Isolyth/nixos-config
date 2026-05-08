{ config, lib, pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Lock in the legacy default (dotfiles in $HOME) — silences the 26.05
    # deprecation warning without moving things.
    dotDir = config.home.homeDirectory;

    history = {
      path = "${config.home.homeDirectory}/.histfile";
      size = 10000;
      save = 10000;
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
    };

    initContent = ''
      # emacs keybindings (carried over from your old .zshrc)
      bindkey -e

      # case-insensitive + partial-substring completion
      zstyle ':completion:*' matcher-list \
        ''' \
        'm:{a-zA-Z}={A-Za-z}' \
        'r:|=*' \
        'l:|=* r:|=*'

      # ~/.local/bin on PATH (carried from old setup)
      export PATH="$HOME/.local/bin:$PATH"

      # oh-my-posh prompt — theme shipped via the flake at home/zsh/theme.toml
      eval "$(${pkgs.oh-my-posh}/bin/oh-my-posh init zsh --config ${../zsh/theme.toml})"
    '';

    shellAliases = {
      # eza replaces ls
      ls = "eza";
      ll = "eza -l --git --icons";
      la = "eza -la --git --icons";
      lt = "eza --tree --level=2 --git-ignore --icons";

      # bat replaces cat (no pager — feels like cat with colors)
      cat = "bat --paging=never";

      # quality-of-life
      g = "git";
      gs = "git status";
      gd = "git diff";

      # nixos
      rebuild = "sudo nixos-rebuild switch --flake ~/nixos-config#theseus";
      rebuild-test = "sudo nixos-rebuild test --flake ~/nixos-config#theseus";
      gc-nix = "sudo nix-collect-garbage -d";
    };
  };

  # ── fuzzy finder ──
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  # oh-my-posh binary (theme is in home/zsh/posh.omp.json, sourced from initContent)
  home.packages = [ pkgs.oh-my-posh ];
}
