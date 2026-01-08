{
  lib,
  appimageTools,
  fetchurl,
}:
let
  pname = "opencode-desktop";
  version = "1.1.6";

  src = fetchurl {
    url = "https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-desktop-linux-amd64.AppImage";
    hash = "sha256-vKPCspYSU6UvWs+JXMWPIoJYoMtgk2LDJEVi0GkFkgU=";
  };

  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    # Install desktop file
    install -Dm644 ${appimageContents}/OpenCode.desktop $out/share/applications/opencode-desktop.desktop
    substituteInPlace $out/share/applications/opencode-desktop.desktop \
      --replace-fail "Exec=OpenCode" "Exec=${pname}" \
      --replace-fail "Icon=OpenCode" "Icon=opencode-desktop"

    # Install icon
    install -Dm644 ${appimageContents}/OpenCode.png $out/share/icons/hicolor/256x256/apps/opencode-desktop.png
  '';

  meta = {
    description = "The open source AI coding agent - Desktop App";
    homepage = "https://github.com/anomalyco/opencode";
    license = lib.licenses.asl20;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "opencode-desktop";
  };
}
