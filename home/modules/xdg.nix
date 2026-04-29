{ ... }:
{
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
      # Set XDG_* env vars in shell sessions (matches legacy default; silences
      # the home.stateVersion < 26.05 warning).
      setSessionVariables = true;
    };

    mimeApps = {
      enable = true;
      defaultApplications = {
        # Firefox: web + html
        "text/html" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "x-scheme-handler/about" = "firefox.desktop";
        "x-scheme-handler/unknown" = "firefox.desktop";
        "application/xhtml+xml" = "firefox.desktop";
        "application/x-extension-htm" = "firefox.desktop";
        "application/x-extension-html" = "firefox.desktop";
        "application/x-extension-shtml" = "firefox.desktop";
        "application/x-extension-xhtml" = "firefox.desktop";
        "application/x-extension-xht" = "firefox.desktop";

        # VSCode: structured / source files
        "application/json" = "code.desktop";
        "application/x-yaml" = "code.desktop";
        "text/yaml" = "code.desktop";
        "application/toml" = "code.desktop";
        "text/toml" = "code.desktop";
        "text/x-python" = "code.desktop";
        "text/x-shellscript" = "code.desktop";
        "text/x-csrc" = "code.desktop";
        "text/x-c++src" = "code.desktop";
        "text/x-rust" = "code.desktop";
        "text/x-go" = "code.desktop";
        "text/x-typescript" = "code.desktop";
        "application/javascript" = "code.desktop";
        "text/javascript" = "code.desktop";
        "text/css" = "code.desktop";
        "text/markdown" = "code.desktop";
        "application/x-shellscript" = "code.desktop";
      };
    };
  };
}
