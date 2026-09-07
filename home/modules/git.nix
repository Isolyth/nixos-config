{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    package = pkgs.gitFull;        # gitFull pulls in HTTP libs, gitk, etc.
    lfs.enable = true;

    settings = {
      user = {
        name = "Eriskii";
        email = "13102203+Eriskii@users.noreply.github.com";
      };

      # Use gh CLI as the credential helper for github.com / gist.github.com.
      credential = {
        "https://github.com" = {
          helper = [ "" "!${pkgs.gh}/bin/gh auth git-credential" ];
        };
        "https://gist.github.com" = {
          helper = [ "" "!${pkgs.gh}/bin/gh auth git-credential" ];
        };
      };

      init.defaultBranch = "main";
      pull.rebase = false;
      push.autoSetupRemote = true;
    };
  };
}
