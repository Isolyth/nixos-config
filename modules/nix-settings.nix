{ ... }:
{
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      trusted-users = [ "root" "eriskii" ];
      # Cap parallel builds — 30 GB RAM + 32 GB swap gets shredded when two
      # CUDA/LLVM link steps run together (each peaks 8–16 GB RSS). Only
      # affects local builds; binary-cache substitutes still parallelize via
      # `max-substitution-jobs`. Bump back to 2 once the big-bump backlog is
      # built and the only locally-compiled packages are the small custom ones.
      max-jobs = 1;
      cores = 4;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  nixpkgs.config.allowUnfree = true;
}
