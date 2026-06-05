{
  lib,
  appimageTools,
  fetchurl,
}:

let
  pname = "opencode-desktop";
  version = "1.16.0";

  src = fetchurl {
    url = "https://github.com/anomalyco/opencode/releases/download/v${version}/${pname}-linux-x86_64.AppImage";
    hash = "sha256-4AHxoORpuMpmIfYUL54v5NdzAgiHbVy66srZW7chjEs=";
  };

  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm644 "${appimageContents}/@opencode-aidesktop.desktop" \
      $out/share/applications/${pname}.desktop
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace-fail 'Exec=AppRun' "Exec=$out/bin/${pname}" \
      --replace-fail 'Icon=@opencode-aidesktop' 'Icon=opencode-desktop' \
      --replace-fail 'StartupWMClass=OpenCode' 'StartupWMClass=opencode-desktop'

    for size_dir in "${appimageContents}"/usr/share/icons/hicolor/*/apps; do
      size=$(basename "$(dirname "$size_dir")")
      src_icon="$size_dir/@opencode-aidesktop.png"
      [ -f "$src_icon" ] && install -Dm644 "$src_icon" \
        "$out/share/icons/hicolor/$size/apps/opencode-desktop.png"
    done

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
  '';

  meta = {
    description = "OpenCode AI coding agent — Desktop App (Electron)";
    homepage = "https://github.com/anomalyco/opencode";
    license = lib.licenses.asl20;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "opencode-desktop";
  };
}
