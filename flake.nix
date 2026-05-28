{
  description = "Isolyth's NixOS config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

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
  };

  outputs = { self, nixpkgs, nixpkgs-graal21, disko, home-manager, dms, nix-flatpak, niri, linux-magic-force, ... }@inputs:
    let
      system = "x86_64-linux";
      # claude-code ships prebuilt binaries to a public bucket faster than
      # nixpkgs repackages them. Rather than pin a separate nixpkgs for it, keep
      # the derivation (wrapper + sandbox setup) from our main nixpkgs and just
      # override version + src against the bucket. Bump with `bump-claude-code`,
      # which rewrites claude-code-pin.json. See modules/packages.nix.
      claudeBaseUrl = "https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases";
      claudePin = builtins.fromJSON (builtins.readFile ./claude-code-pin.json);
      claudeOverlay = final: prev: {
        claude-code = prev.claude-code.overrideAttrs (old: {
          version = claudePin.version;
          src = prev.fetchurl {
            url = "${claudeBaseUrl}/${claudePin.version}/linux-x64/claude";
            sha256 = claudePin.checksum;
          };
        });
      };
      graal21Pkgs = import nixpkgs-graal21 {
        inherit system;
        config.allowUnfree = true;
      };
      # Expose Graal CE 21 (== graalvm-ce 21.0.1 from nixos-23.11) under a
      # distinct attribute so it can sit alongside graalvmPackages.graalvm-ce (25).
      graal21Overlay = final: prev: {
        graalvm-ce-21 = graal21Pkgs.graalvm-ce;
      };
    in {
      nixosConfigurations.theseus = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          { nixpkgs.overlays = [ claudeOverlay graal21Overlay ]; }
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
