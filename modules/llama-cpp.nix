{ pkgs, lib, inputs, ... }:
let
  rev = inputs.llama-cpp-src.shortRev or "git";

  # Build nixpkgs' llama-cpp expression, but with CUDA on and the source
  # swapped for the release tag pinned in flake.nix (inputs.llama-cpp-src).
  # cudaSupport is a callPackage arg (.override); src/version are mkDerivation
  # attrs (.overrideAttrs). Version is taken from the pinned commit's short rev
  # so it always reflects whatever the flake input currently points at.
  #
  # The server's embedded web UI is disabled (LLAMA_BUILD_UI=OFF,
  # LLAMA_USE_PREBUILT_UI=OFF). Upstream's UI build wants to run npm/vite or
  # download prebuilt assets from a HuggingFace bucket at build time — both
  # impossible in Nix's sandbox, and nixpkgs' prefetched-npm-deps approach
  # breaks whenever upstream moves the webui (it has). With the UI off,
  # scripts/ui-assets.cmake falls through to emitting an empty ui.cpp, so the
  # server still links — llama-server's HTTP API works fully, it just doesn't
  # serve the browser chat UI. This keeps every release bump npm-free and
  # one-command. To re-enable the UI you'd vendor the npm deps (FOD hash that
  # changes each bump) — deliberately not done here.
  llama-cpp-cuda =
    (pkgs.llama-cpp.override { cudaSupport = true; }).overrideAttrs (old: {
      version = rev;
      src = inputs.llama-cpp-src;

      # Drop the npm toolchain — unused once the UI is off, and npmConfigHook
      # errors without npmDeps.
      nativeBuildInputs = lib.filter
        (p: let n = p.name or ""; in
          !(lib.hasInfix "npm" n || lib.hasInfix "node" n))
        old.nativeBuildInputs;
      npmDeps = null;

      # Replace nixpkgs' preConfigure: it ran `npm run build` and read a COMMIT
      # file that the upstream fetcher writes from .git — our flake-input source
      # has no .git, so feed the build commit from the pinned short rev instead.
      preConfigure = ''
        prependToVar cmakeFlags "-DLLAMA_BUILD_COMMIT:STRING=${rev}"
      '';

      # nixpkgs feeds the package `version` into LLAMA_BUILD_NUMBER, which the
      # generated build-info.cpp emits as a bare C++ int (`int x = @VALUE@;`).
      # Our version is a git short rev (e.g. 6ed481e), which C++ misreads as a
      # malformed float literal ("exponent has no digits"). Drop that flag and
      # force a numeric build number; the exact build is still identified by
      # LLAMA_BUILD_COMMIT (the rev) set in preConfigure above.
      cmakeFlags =
        (lib.filter (f: !(lib.hasInfix "LLAMA_BUILD_NUMBER" f)) old.cmakeFlags)
        ++ [
          "-DLLAMA_BUILD_NUMBER=0"
          "-DLLAMA_BUILD_UI=OFF"
          "-DLLAMA_USE_PREBUILT_UI=OFF"
        ];
    });

  # Mirror of bump-claude-code: query GitHub for the newest llama.cpp release
  # tag, rewrite the pin in flake.nix, and update the lock. Rebuild to apply.
  bump-llama-cpp = pkgs.writeShellApplication {
    name = "bump-llama-cpp";
    runtimeInputs = [ pkgs.nix pkgs.gh pkgs.gnused ];
    text = ''
      cd "$HOME/nixos-config"
      tag=$(gh release view --repo ggml-org/llama.cpp --json tagName -q .tagName)
      echo "latest llama.cpp release: $tag"
      sed -i -E "s#(github:ggml-org/llama\.cpp/)[^\"]+#\1$tag#" flake.nix
      nix flake update llama-cpp-src
      echo "llama-cpp-src pinned to $tag; rebuild to apply"
    '';
  };
in
{
  # CUDA-accelerated llama.cpp.
  #
  # CUDA builds are unfree/unredistributable, so Hydra never builds them and
  # they aren't in cache.nixos.org — every build is local. The cuda-maintainers
  # Cachix hosts the heavy toolkit deps (CUDA, cudnn) so those at least come
  # prebuilt; llama.cpp itself still compiles here since we pin a fresh release.
  nix.settings = {
    substituters = [ "https://cuda-maintainers.cachix.org" ];
    trusted-public-keys = [
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
    ];
  };

  environment.systemPackages = [
    llama-cpp-cuda
    bump-llama-cpp
  ];
}
