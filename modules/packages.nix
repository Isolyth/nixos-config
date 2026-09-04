{ pkgs, ... }:
let
  # claude-code comes from the claude-code-nix flake input (overlay in
  # flake.nix). Pull whatever version that flake currently pins by updating the
  # input. To jump to a brand-new release, bump the pin in the claude-code-nix
  # repo first (`nix run github:Isolyth/claude-code-nix#bump -- <version>`),
  # then run this.
  bump-claude-code = pkgs.writeShellApplication {
    name = "bump-claude-code";
    runtimeInputs = [ pkgs.nix ];
    text = ''
      cd "$HOME/nixos-config"
      nix flake update claude-code-nix
      echo "claude-code-nix input updated; rebuild to apply"
    '';
  };
  # codex comes from its own nixpkgs pin (nixpkgs-codex, overlaid in flake.nix)
  # so it can move independently of the main nixpkgs input. This bumps that pin
  # to the latest nixos-unstable and nothing else.
  bump-codex = pkgs.writeShellApplication {
    name = "bump-codex";
    runtimeInputs = [ pkgs.nix ];
    text = ''
      cd "$HOME/nixos-config"
      nix flake update nixpkgs-codex
      echo "nixpkgs-codex input updated; rebuild to apply"
    '';
  };
  # codex-app (the Codex/ChatGPT desktop app) is repackaged from OpenAI's
  # official apt repo in pkgs/codex-app, pinned by pkgs/codex-app/pin.json.
  # This refreshes that pin from the repo's Packages index (version + sha256)
  # and nothing else.
  bump-codex-app = pkgs.writeShellApplication {
    name = "bump-codex-app";
    runtimeInputs = [ pkgs.curl pkgs.jq ];
    text = ''
      cd "$HOME/nixos-config"
      index=$(curl -fsSL https://persistent.oaistatic.com/codex-app-prod/linux/deb/dists/stable/main/binary-amd64/Packages)
      version=$(printf '%s\n' "$index" | awk '/^Version:/ {print $2; exit}')
      sha256=$(printf '%s\n' "$index" | awk '/^SHA256:/ {print $2; exit}')
      jq -n --arg version "$version" --arg sha256 "$sha256" \
        '{version: $version, sha256: $sha256}' > pkgs/codex-app/pin.json
      echo "codex-app pinned to $version; rebuild to apply"
    '';
  };
  # pi comes from its own nixpkgs pin (nixpkgs-pi, tracks master, overlaid in
  # flake.nix) because its baked-in model catalog goes stale fast on
  # nixos-unstable. This bumps that pin to the latest master and nothing else.
  bump-pi = pkgs.writeShellApplication {
    name = "bump-pi";
    runtimeInputs = [ pkgs.nix ];
    text = ''
      cd "$HOME/nixos-config"
      nix flake update nixpkgs-pi
      echo "nixpkgs-pi input updated; rebuild to apply"
    '';
  };
in
{
  # Gaming — `programs.steam.enable` is special (sets up fonts, runtime,
  # firewall ports, dedicated server perms). Has to be a `programs.*` option,
  # but conceptually it's "I want Steam installed" so it lives here.
  programs.steam.enable = true;
  programs.gamemode.enable = true;
  # gamescope — like steam/gamemode this is a `programs.*` option rather than a
  # bare package: the module ships a setcap-wrapped binary granting CAP_SYS_NICE
  # so gamescope can request realtime scheduling for its compositor thread.
  programs.gamescope.enable = true;

  environment.systemPackages = with pkgs; [
    # Editors / dev
    vim neovim git gh cloc
    gcc gnumake cmake pkg-config
    rustup
    go
    nodejs_22 bun
    codex
    python3 python3Packages.pip pipx uv
    jdk21 maven
    cudaPackages.cudatoolkit
    android-cli

    # Shell / TUI
    zsh-completions
    fzf ripgrep fd bat eza jq
    btop-cuda fastfetch
    tmux
    kitty
    
    claude-code
    bump-claude-code
    bump-codex
    codex-app                    # Codex/ChatGPT desktop app (see pkgs/codex-app)
    bump-codex-app
    opencode
    pi-coding-agent
    bump-pi

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
    geekbench                    # CPU/GPU benchmark (unfree; free runs upload results to browse.geekbench.com)
    stress-ng                    # stress test / load all CPU cores (e.g. `stress-ng --cpu 0 --timeout 60s --metrics`)
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
    # BambuStudio's wxWidgets GL canvas (wxGLCanvasEGL on wl_egl_window) renders
    # a silent blank prepare/viewport when EGL is forced through NVIDIA on a
    # Wayland surface composited by the AMD iGPU. Our hyprland.nix sets
    # GBM_BACKEND=nvidia-drm / __GLX_VENDOR_LIBRARY_NAME=nvidia session-wide,
    # which is correct for everything else but cross-vendors here. Wrap just
    # this binary to render via Mesa EGL on the AMD iGPU. See: imported file
    # never shows up in the prepare area, no error — classic cross-vendor EGL
    # FBO-never-presents.
    (pkgs.symlinkJoin {
      name = "bambu-studio-mesa";
      paths = [ pkgs.bambu-studio ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/bambu-studio \
          --unset GBM_BACKEND \
          --unset __GLX_VENDOR_LIBRARY_NAME \
          --set __EGL_VENDOR_LIBRARY_FILENAMES /run/opengl-driver/share/glvnd/egl_vendor.d/50_mesa.json \
          --set __NV_PRIME_RENDER_OFFLOAD 0
      '';
      inherit (pkgs.bambu-studio) meta;
    })
    (blender.override { cudaSupport = true; })  # 3D modeling / animation — cudaSupport enables Cycles GPU rendering on NVIDIA
    davinci-resolve              # video editor / color grading — uses CUDA on NVIDIA out of the box

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
