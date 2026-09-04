{
  description = "Isolyth's NixOS config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Dedicated nixpkgs pin so codex can move ahead of (or independent of) the
    # main nixpkgs pin without dragging the rest of the system along. Its
    # overlay provides pkgs.codex. Bump just codex with `bump-codex` (see
    # modules/packages.nix), which runs `nix flake update nixpkgs-codex`.
    nixpkgs-codex.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Dedicated pin for pi-coding-agent, same idea as nixpkgs-codex. Tracks
    # master because pi's baked-in model catalog goes stale fast (nixos-unstable
    # sat on 0.79.1 while master had 0.82.1 with the GPT-5.6 catalog). pi is a
    # cheap node package, so building from master is fine. Bump with `bump-pi`
    # (see modules/packages.nix).
    nixpkgs-pi.url = "github:NixOS/nixpkgs/master";

    # Pin for GraalVM CE 21.0.1 (JDK 21 LTS). Current unstable only ships
    # graalvm-ce 25 and graalvm-oracle_{17,24,25} — no community Java 21 build.
    # Graal aligned its versioning to the underlying JDK; in nixos-24.11 the
    # graalvm-ce is on JDK 23, so we go back further.
    nixpkgs-graal21.url = "github:NixOS/nixpkgs/nixos-23.11";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/v0.7.0";

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    linux-magic-force = {
      url = "github:Isolyth/LinuxMagicForce";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # claude-code straight from Anthropic's distribution bucket, ahead of
    # nixpkgs. Its overlay provides pkgs.claude-code. Bump the pinned version
    # with `bump-claude-code` (see modules/packages.nix).
    claude-code-nix = {
      url = "github:Isolyth/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # llama.cpp source pinned to an upstream release tag. CUDA builds can't be
    # cached (unfree), so we build locally anyway — might as well track the
    # latest release rather than nixpkgs' frozen version. Bump the pinned tag
    # with `bump-llama-cpp` (see modules/llama-cpp.nix). flake = false: this is
    # just a source tree, the build expression comes from nixpkgs.
    llama-cpp-src = {
      url = "github:ggml-org/llama.cpp/b9413";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nixpkgs-codex, nixpkgs-pi, nixpkgs-graal21, disko, home-manager, dms, nix-flatpak, niri, linux-magic-force, claude-code-nix, ... }@inputs:
    let
      system = "x86_64-linux";
      graal21Pkgs = import nixpkgs-graal21 {
        inherit system;
        config.allowUnfree = true;
      };
      # Expose Graal CE 21 (== graalvm-ce 21.0.1 from nixos-23.11) under a
      # distinct attribute so it can sit alongside graalvmPackages.graalvm-ce (25).
      graal21Overlay = final: prev: {
        graalvm-ce-21 = graal21Pkgs.graalvm-ce;
      };
      codexPkgs = import nixpkgs-codex {
        inherit system;
        config.allowUnfree = true;
      };
      # Draw codex from its dedicated pin so it tracks a newer nixpkgs rev than
      # the main input. Bump with `bump-codex` (see modules/packages.nix).
      codexOverlay = final: prev: {
        codex = codexPkgs.codex;
      };
      piPkgs = import nixpkgs-pi {
        inherit system;
        config.allowUnfree = true;
      };
      # Draw pi from its dedicated pin so its model catalog stays current.
      # Bump with `bump-pi` (see modules/packages.nix).
      piOverlay = final: prev: {
        pi-coding-agent = piPkgs.pi-coding-agent;
      };
      # Codex desktop app — OpenAI's official Linux .deb (shipped as the
      # combined ChatGPT app), repackaged in ./pkgs/codex-app. Pinned by
      # pkgs/codex-app/pin.json; bump with `bump-codex-app` (see
      # modules/packages.nix). Separate from the codex CLI above.
      codexAppOverlay = final: prev: {
        codex-app = final.callPackage ./pkgs/codex-app { };
      };
    in {
      nixosConfigurations.theseus = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          { nixpkgs.overlays = [ claude-code-nix.overlays.default graal21Overlay codexOverlay codexAppOverlay piOverlay ]; }
          disko.nixosModules.disko
          ./disko-config.nix
          home-manager.nixosModules.home-manager
          nix-flatpak.nixosModules.nix-flatpak
          niri.nixosModules.niri
          linux-magic-force.nixosModules.default
          ./hosts/theseus
        ];
      };
    };
}
