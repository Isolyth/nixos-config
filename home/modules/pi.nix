# pi (badlogic/pi-mono) user-level config: the snapcompact extension.
#
# snapcompact is oh-my-pi's bitmap-frame context compression, ported to run
# on plain pi's extension API (session_before_compact + context hooks).
# Source lives in home/pi/snapcompact/ — a vendored, Node-patched copy of
# @oh-my-pi/snapcompact (the upstream package is Bun-only: text import
# attributes + Bun.stripANSI) plus glue in index.ts. See that directory.
#
# The native rasterizer comes from the prebuilt napi addon published as
# @oh-my-pi/pi-natives-linux-x64; the derivation below drops both CPU
# variants (AVX2 "modern" + "baseline") next to vendor/natives.ts, which
# picks one at load time via /proc/cpuinfo.
#
# The whole assembled directory is linked to ~/.pi/agent/extensions/snapcompact,
# where pi auto-discovers index.ts. Bump `nativesVersion` (and the hash) to
# track upstream pi-natives releases; re-vendor snapcompact.ts separately.
{ pkgs, ... }:
let
  nativesVersion = "17.2.1";

  nativesTarball = pkgs.fetchurl {
    url = "https://registry.npmjs.org/@oh-my-pi/pi-natives-linux-x64/-/pi-natives-linux-x64-${nativesVersion}.tgz";
    hash = "sha256-ev0ztH7tU+ZtBiG0lOwtJwIb+xP72gLuwcVodHrB6XY=";
  };

  snapcompactExtension = pkgs.runCommand "pi-snapcompact-extension" { } ''
    mkdir -p $out
    cp -r ${../pi/snapcompact}/. $out/
    chmod -R u+w $out
    tar -xzf ${nativesTarball} -C "$TMPDIR"
    cp "$TMPDIR"/package/pi_natives.linux-x64-modern.node   $out/vendor/
    cp "$TMPDIR"/package/pi_natives.linux-x64-baseline.node $out/vendor/
  '';
in
{
  home.file.".pi/agent/extensions/snapcompact".source = snapcompactExtension;
}
