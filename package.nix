{
  lib,
  stdenvNoCC,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  wrapGAppsHook3,
  glib,
  gtk3,
  gdk-pixbuf,
  cairo,
  webkitgtk_4_1,
  libsoup_3,
  gst_all_1,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "opencode-desktop";
  version = "1.2.10";

  src = fetchurl {
    url = "https://github.com/anomalyco/opencode/releases/download/v${finalAttrs.version}/opencode-desktop-linux-amd64.deb";
    hash = "sha256-3b5ilUVVSPZlaXw7HGK4R7HR5CFq7GM84TKPaizYCzo=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    wrapGAppsHook3
  ];

  # Let wrapGAppsHook find GStreamer plugins
  preFixup = ''
    gappsWrapperArgs+=(
      --set OC_ALLOW_WAYLAND 1
    )
  '';

  buildInputs = [
    glib
    gtk3
    gdk-pixbuf
    cairo
    webkitgtk_4_1
    libsoup_3
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
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

    mkdir -p $out/bin $out/share

    # Install binary
    install -Dm755 usr/bin/OpenCode $out/bin/opencode-desktop

    # Create opencode-cli wrapper that finds opencode in PATH or ~/.opencode/bin
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

    # Install desktop file
    install -Dm644 usr/share/applications/OpenCode.desktop $out/share/applications/opencode-desktop.desktop
    substituteInPlace $out/share/applications/opencode-desktop.desktop \
      --replace-fail "Exec=OpenCode" "Exec=$out/bin/opencode-desktop" \
      --replace-fail "Icon=OpenCode" "Icon=opencode-desktop"

    # Install icons
    for size in 32 128 256; do
      if [ -f "usr/share/icons/hicolor/''${size}x''${size}/apps/OpenCode.png" ]; then
        install -Dm644 "usr/share/icons/hicolor/''${size}x''${size}/apps/OpenCode.png" \
          "$out/share/icons/hicolor/''${size}x''${size}/apps/opencode-desktop.png"
      fi
    done

    runHook postInstall
  '';

  meta = {
    description = "The open source AI coding agent - Desktop App";
    homepage = "https://github.com/anomalyco/opencode";
    license = lib.licenses.asl20;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "opencode-desktop";
  };
})
