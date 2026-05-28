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
        # Terminal scheme handler — what xdg-terminal-exec / file managers use to spawn a terminal
        "x-scheme-handler/terminal" = "kitty.desktop";

        # Catch-all for files with no detected MIME (empty files) or generic binary
        "application/octet-stream" = "code.desktop";
        "inode/x-empty" = "code.desktop";

        # Firefox: web + html + pdf
        "text/html" = "firefox.desktop";
        "application/pdf" = "firefox.desktop";
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

        # VSCode: plain text + structured / source files
        "text/plain" = "code.desktop";
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
        "text/x-markdown" = "code.desktop";
        "application/x-shellscript" = "code.desktop";

        # Misc text formats commonly detected as their own MIME
        "text/xml" = "code.desktop";
        "application/xml" = "code.desktop";
        "text/csv" = "code.desktop";
        "text/tab-separated-values" = "code.desktop";
        "application/x-desktop" = "code.desktop";
        "text/x-log" = "code.desktop";
        "text/x-sql" = "code.desktop";
        "text/x-tex" = "code.desktop";
        "application/x-ipynb+json" = "code.desktop";
        "text/x-lua" = "code.desktop";
        "text/x-ruby" = "code.desktop";
        "text/x-java" = "code.desktop";
        "text/x-kotlin" = "code.desktop";
        "text/x-nix" = "code.desktop";

        # Gwenview: images
        "image/jpeg" = "org.kde.gwenview.desktop";
        "image/png" = "org.kde.gwenview.desktop";
        "image/gif" = "org.kde.gwenview.desktop";
        "image/webp" = "org.kde.gwenview.desktop";
        "image/bmp" = "org.kde.gwenview.desktop";
        "image/tiff" = "org.kde.gwenview.desktop";
        "image/svg+xml" = "org.kde.gwenview.desktop";
        "image/x-icon" = "org.kde.gwenview.desktop";
        "image/vnd.microsoft.icon" = "org.kde.gwenview.desktop";
        "image/heif" = "org.kde.gwenview.desktop";
        "image/heic" = "org.kde.gwenview.desktop";
        "image/avif" = "org.kde.gwenview.desktop";
        "image/jxl" = "org.kde.gwenview.desktop";
        "image/x-portable-pixmap" = "org.kde.gwenview.desktop";
        "image/x-portable-bitmap" = "org.kde.gwenview.desktop";
        "image/x-portable-graymap" = "org.kde.gwenview.desktop";

        # VLC: video
        "video/mp4" = "vlc.desktop";
        "video/x-matroska" = "vlc.desktop";
        "video/webm" = "vlc.desktop";
        "video/quicktime" = "vlc.desktop";
        "video/x-msvideo" = "vlc.desktop";
        "video/mpeg" = "vlc.desktop";
        "video/x-flv" = "vlc.desktop";
        "video/3gpp" = "vlc.desktop";
        "video/3gpp2" = "vlc.desktop";
        "video/ogg" = "vlc.desktop";
        "video/x-ms-wmv" = "vlc.desktop";
        "video/x-ms-asf" = "vlc.desktop";
        "video/mp2t" = "vlc.desktop";
        "application/x-matroska" = "vlc.desktop";
      };
    };
  };
}
