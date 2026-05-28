{ pkgs, ... }:
let
  bump-claude-code = pkgs.writeShellApplication {
    name = "bump-claude-code";
    runtimeInputs = [ pkgs.curl pkgs.jq ];
    text = ''
      cd "$HOME/nixos-config"
      base="https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases"
      # Optional explicit version arg; otherwise track the bucket's `latest`.
      version="''${1:-$(curl -fsSL "$base/latest")}"
      checksum="$(curl -fsSL "$base/$version/manifest.json" | jq -er '.platforms["linux-x64"].checksum')"
      jq -n --arg version "$version" --arg checksum "$checksum" \
        '{version: $version, checksum: $checksum}' > claude-code-pin.json
      echo "claude-code pinned to $version"
    '';
  };
in
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
    go
    nodejs_22 bun
    codex
    python3 python3Packages.pip pipx uv
    jdk21 maven
    cudaPackages.cudatoolkit
    docker-compose

    # Shell / TUI
    zsh-completions
    fzf ripgrep fd bat eza jq
    btop-cuda fastfetch
    tmux
    kitty
    
    claude-code
    bump-claude-code
    opencode

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
    matugen                     # material-you palette generator (DMS, vesktop theme)
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
    vlc
    (obs-studio.override { cudaSupport = true; })  # cudaSupport pulls in autoAddDriverRunpath so obs-nvenc-test gets /run/opengl-driver/lib in RUNPATH (NVENC test process otherwise fails: nvenc_lib)
    ffmpegthumbnailer            # video thumbs in Thunar etc

    # Misc utilities
    ncdu
    hyprpicker                   # color picker
    font-manager
    libreoffice
    # Prism's nixpkgs wrapper bakes a fixed PRISMLAUNCHER_JAVA_PATHS list of
    # stock OpenJDKs — Graal is excluded by default. Override `jdks` so the
    # in-app Java auto-detect picks it up alongside the stock builds.
    (prismlauncher.override {
      jdks = with pkgs; [ jdk8 jdk17 jdk21 jdk25 graalvmPackages.graalvm-ce graalvm-ce-21 ];
    })
    graalvmPackages.graalvm-ce   # Graal CE 25 (Java 25) — best perf for Minecraft 1.20.5+
    graalvm-ce-21                # Graal CE 21 (Java 21 LTS) — from nixpkgs-graal21 pin; current unstable has no community Java 21 build

    # GUI apps — communication
    vesktop                       # Discord (electron-free wrapper)

    # GUI apps — notes / docs
    obsidian
    kdePackages.okular            # PDF viewer

    # GUI apps — making
    bambu-studio                  # Bambu Lab printer slicer
    (blender.override { cudaSupport = true; })  # 3D modeling / animation — cudaSupport enables Cycles GPU rendering on NVIDIA

    # GUI apps — image / photo
    darktable                     # RAW photo workflow
    krita                         # painting / pixel art
    inkscape                      # vector drawing
    kdePackages.gwenview          # quick image viewer

    # GUI apps — archive / shortcuts
    kdePackages.ark               # archive manager
    kdePackages.spectacle         # screenshot tool

    # System utils
    sshpass
    htop iotop lsof
    e2fsprogs                    # chattr, lsattr, etc — needed for btrfs swapfile NoCoW
    pciutils usbutils
    nvtopPackages.nvidia
    smartmontools
    cryptsetup
    btrfs-progs
  ];
}
