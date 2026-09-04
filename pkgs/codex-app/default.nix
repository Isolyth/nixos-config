# Codex desktop app (OpenAI). Upstream ships this as the combined "ChatGPT"
# desktop app for Linux — the former standalone Codex app was merged into it,
# and the CDN paths still say codex-app-prod. Repackaged from OpenAI's official
# apt repository (versioned, sha256-indexed pool debs):
#   https://persistent.oaistatic.com/codex-app-prod/linux/deb/dists/stable/main/binary-amd64/Packages
# Pinned via pin.json; bump with `bump-codex-app` (see modules/packages.nix).
#
# This is independent of the codex CLI (pkgs.codex from the nixpkgs-codex pin)
# — the app bundles its own codex runtime under resources/, both coexist.
{ lib
, stdenv
, fetchurl
, dpkg
, autoPatchelfHook
, makeWrapper
, alsa-lib
, at-spi2-atk
, at-spi2-core
, atk
, cairo
, cups
, dbus
, expat
, gdk-pixbuf
, glib
, gtk3
, libdrm
, libgbm
, libGL
, libnotify
, libsecret
, libusb1
, libuuid
, libxkbcommon
, nspr
, nss
, pango
, pipewire
, systemd
, vulkan-loader
, wayland
, xz
, libX11
, libxcb
, libXcomposite
, libXdamage
, libXext
, libXfixes
, libxrandr
, libxshmfence
}:

let
  pin = lib.importJSON ./pin.json;
in
stdenv.mkDerivation {
  pname = "codex-app";
  version = pin.version;

  src = fetchurl {
    url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/pool/main/c/chatgpt/chatgpt_${pin.version}_amd64.deb";
    sha256 = pin.sha256;
  };

  nativeBuildInputs = [ dpkg autoPatchelfHook makeWrapper ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    gdk-pixbuf
    glib
    gtk3
    libdrm
    libgbm
    libGL
    libnotify
    libsecret
    libusb1
    libuuid
    libxkbcommon
    nspr
    nss
    pango
    stdenv.cc.cc.lib
    libX11
    libxcb
    libXcomposite
    libXdamage
    libXext
    libXfixes
    libxrandr
    libxshmfence
  ];

  # dlopen'd at runtime rather than linked — autoPatchelf can't see these, so
  # put them on RUNPATH explicitly.
  runtimeDependencies = [
    (lib.getLib systemd)
    libnotify
    libsecret
    pipewire
    vulkan-loader
    wayland
  ];

  # The deb bundles its own libEGL/libGLESv2/libvulkan/swiftshader; anything
  # they reference that only exists on the GPU-driver side resolves at runtime
  # via /run/opengl-driver — don't fail the build over it.
  autoPatchelfIgnoreMissingDeps = true;

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib $out/share
    cp -r usr/lib/chatgpt $out/lib/chatgpt
    cp -r usr/share/applications usr/share/pixmaps $out/share/

    # Upstream: usr/bin/chatgpt -> ../lib/chatgpt/codex-launcher (which just
    # execs ChatGPT "$@").
    # xz on PATH: the deb Depends on xz-utils (runtime component extraction).
    makeWrapper $out/lib/chatgpt/codex-launcher $out/bin/chatgpt \
      --prefix PATH : ${lib.makeBinPath [ xz ]}
    ln -s $out/bin/chatgpt $out/bin/codex-app

    # Force native Wayland via the desktop entry (the app ignores
    # ELECTRON_OZONE_PLATFORM_HINT and defaults to X11 otherwise).
    substituteInPlace $out/share/applications/chatgpt.desktop \
      --replace-fail "Exec=chatgpt %U" \
        "Exec=$out/bin/chatgpt --enable-features=UseOzonePlatform --ozone-platform=wayland %U"

    runHook postInstall
  '';

  meta = {
    description = "Codex / ChatGPT desktop app by OpenAI (official Linux build)";
    homepage = "https://developers.openai.com/codex/app";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "chatgpt";
  };
}
