{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;

    # Keep extensions installable via the UI in addition to declared ones.
    mutableExtensionsDir = true;

    profiles.default = {
      # Carried over from old settings.json — Arch-specific qt-core path dropped.
      userSettings = {
        "workbench.colorTheme" = "Catppuccin Mocha";
        "workbench.secondarySideBar.defaultVisibility" = "hidden";
        "workbench.editor.empty.hint" = "hidden";

        "git.suggestSmartCommit" = false;
        "git.enableSmartCommit" = true;
        "git.confirmSync" = false;

        "terminal.integrated.stickyScroll.enabled" = false;
        "terminal.integrated.suggest.cdPath" = "off";
        "terminal.integrated.suggest.enabled" = false;

        "svelte.enable-ts-plugin" = true;
        "python.languageServer" = "Pylance";

        "roo-cline.allowedCommands" = [ "git log" "git diff" "git show" ];
        "roo-cline.deniedCommands" = [ ];
      };

      extensions = with pkgs.vscode-extensions; [
        catppuccin.catppuccin-vsc
        catppuccin.catppuccin-vsc-icons
        ms-python.python
        ms-python.vscode-pylance
        rust-lang.rust-analyzer
        svelte.svelte-vscode
        bbenoist.nix
        jnoortheen.nix-ide
      ];
    };
  };
}
