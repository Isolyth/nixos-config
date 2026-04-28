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
    starship
    fzf ripgrep fd bat eza zoxide
    btop fastfetch
    tmux

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
    mako
    swww
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

    # System utils
    htop iotop lsof
    pciutils usbutils
    nvtopPackages.nvidia
    smartmontools
    cryptsetup
    btrfs-progs
  ];
}
