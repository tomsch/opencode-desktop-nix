{
  lib,
  stdenvNoCC,
  fetchurl,
  dpkg,
  makeWrapper,
  autoPatchelfHook,
  wrapGAppsHook3,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  gdk-pixbuf,
  glib,
  gtk3,
  libdrm,
  libGL,
  libnotify,
  libsecret,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxkbcommon,
  libxrandr,
  libxshmfence,
  mesa,
  musl,
  nspr,
  nss,
  pango,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "opencode-desktop";
  version = "1.17.7";

  # Prefer the Debian archive over the AppImage: upstream AppImage desktop/icon
  # names changed, while the .deb keeps the Electron install layout stable.
  src = fetchurl {
    url = "https://github.com/anomalyco/opencode/releases/download/v${finalAttrs.version}/opencode-desktop-linux-amd64.deb";
    hash = "sha256-Waiy//mh2CfD668HTzK6+M53aUXsO9jUx4ArLkdLTfY=";
  };

  nativeBuildInputs = [
    dpkg
    makeWrapper
    autoPatchelfHook
    wrapGAppsHook3
  ];

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
    libGL
    libnotify
    libsecret
    libx11
    libxcb
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxkbcommon
    libxrandr
    libxshmfence
    mesa
    musl
    nspr
    nss
    pango
  ];

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/opencode-desktop $out/bin $out/share
    cp -r opt/OpenCode/* $out/lib/opencode-desktop/

    install -Dm644 usr/share/applications/ai.opencode.desktop.desktop \
      $out/share/applications/${finalAttrs.pname}.desktop
    substituteInPlace $out/share/applications/${finalAttrs.pname}.desktop \
      --replace-fail 'Exec=/opt/OpenCode/ai.opencode.desktop %U' "Exec=$out/bin/${finalAttrs.pname} %U" \
      --replace-fail 'Icon=ai.opencode.desktop' 'Icon=opencode-desktop' \
      --replace-fail 'StartupWMClass=ai.opencode.desktop' 'StartupWMClass=opencode-desktop'

    for size_dir in usr/share/icons/hicolor/*/apps; do
      size=$(basename "$(dirname "$size_dir")")
      src_icon="$size_dir/ai.opencode.desktop.png"
      [ -f "$src_icon" ] && install -Dm644 "$src_icon" \
        "$out/share/icons/hicolor/$size/apps/opencode-desktop.png"
    done

    makeWrapper $out/lib/opencode-desktop/ai.opencode.desktop $out/bin/${finalAttrs.pname} \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath finalAttrs.buildInputs}" \
      --set-default OC_ALLOW_WAYLAND 1

    cat > $out/bin/opencode-cli << 'EOF'
#!/usr/bin/env bash
# Wrapper for opencode CLI - searches PATH and ~/.opencode/bin
if command -v opencode &>/dev/null; then
  exec opencode "$@"
elif [ -x "$HOME/.opencode/bin/opencode" ]; then
  exec "$HOME/.opencode/bin/opencode" "$@"
else
  echo "Error: opencode CLI not found. Install via: curl -fsSL https://opencode.ai/install | bash" >&2
  exit 1
fi
EOF
    chmod +x $out/bin/opencode-cli

    runHook postInstall
  '';

  meta = {
    description = "OpenCode AI coding agent — Desktop App (Electron)";
    homepage = "https://github.com/anomalyco/opencode";
    license = lib.licenses.asl20;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "opencode-desktop";
  };
})
