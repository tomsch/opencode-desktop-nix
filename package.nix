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
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "opencode-desktop";
  version = "1.1.6";

  src = fetchurl {
    url = "https://github.com/anomalyco/opencode/releases/download/v${finalAttrs.version}/opencode-desktop-linux-amd64.deb";
    hash = "sha256-Lw5Cl2SoWViTK3ZjpC1pKO+VZnY7asDm5mESSVtj8kI=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    wrapGAppsHook3
  ];

  buildInputs = [
    glib
    gtk3
    gdk-pixbuf
    cairo
    webkitgtk_4_1
    libsoup_3
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

    # Install CLI if available
    if [ -f usr/bin/opencode-cli ]; then
      install -Dm755 usr/bin/opencode-cli $out/bin/opencode-cli
    fi

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
