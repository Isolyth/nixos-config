{ pkgs, ... }:
{
  # Gaming — `programs.steam.enable` is special (sets up fonts, runtime,
  # firewall ports, dedicated server perms). Has to be a `programs.*` option,
  # but conceptually it's "I want Steam installed" so it lives here.
  programs.steam.enable = true;
  programs.gamemode.enable = true;

  environment.systemPackages = with pkgs; [
    # Editors / dev
    vim neovim git gh
    gcc gnumake cmake pkg-config
    rustup
    nodejs_22 bun
    python3 uv
    docker-compose

    # Shell / TUI
    zsh-completions
    fzf ripgrep fd bat eza zoxide jq
    btop fastfetch
    tmux
    kitty
    
    claude-code

    # Hyprland ecosystem
    waybar
    fuzzel
    hyprpaper
    hypridle
    hyprlock
    hyprshot
    grim slurp
    wl-clipboard
    cliphist
    awww                        # formerly swww — wallpaper daemon
    brightnessctl
    pavucontrol
    networkmanagerapplet

    # File / archive
    file unzip zip p7zip
    rsync
    zstd

    # Browsers / media
    firefox
    chromium
    mpv
    obs-studio

    # GUI apps — communication
    vesktop                       # Discord (electron-free wrapper)

    # GUI apps — notes / docs
    obsidian
    kdePackages.okular            # PDF viewer

    # GUI apps — making
    bambu-studio                  # Bambu Lab printer slicer

    # GUI apps — image / photo
    darktable                     # RAW photo workflow
    krita                         # painting / pixel art
    inkscape                      # vector drawing
    kdePackages.gwenview          # quick image viewer

    # GUI apps — archive / shortcuts
    kdePackages.ark               # archive manager
    kdePackages.spectacle         # screenshot tool

    # System utils
    htop iotop lsof
    pciutils usbutils
    nvtopPackages.nvidia
    smartmontools
    cryptsetup
    btrfs-progs
  ];
}
