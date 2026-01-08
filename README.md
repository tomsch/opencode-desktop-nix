# OpenCode Desktop for NixOS

Unofficial Nix package for [OpenCode Desktop](https://github.com/anomalyco/opencode) - the open source AI coding agent.

## Installation

### Flake Input (NixOS/Home Manager)

```nix
{
  inputs.opencode-desktop.url = "github:tomsch/opencode-desktop-nix";

  outputs = { self, nixpkgs, opencode-desktop, ... }: {
    # NixOS
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      modules = [{
        environment.systemPackages = [
          opencode-desktop.packages.x86_64-linux.default
        ];
      }];
    };
  };
}
```

### Direct Run (no install)

```bash
nix run github:tomsch/opencode-desktop-nix
```

### Imperative Install

```bash
nix profile install github:tomsch/opencode-desktop-nix
```

## Features

- **Open source** AI coding agent
- **Multiple AI providers** - OpenAI, Anthropic, and more
- **Terminal & Desktop** - CLI and GUI available
- **Tauri-based** desktop app for Linux

## Update Package

Maintainers can update to the latest version:

```bash
./update.sh
```

## License

The Nix packaging is MIT. OpenCode itself is Apache 2.0 licensed.

## Links

- [OpenCode GitHub](https://github.com/anomalyco/opencode)
- [OpenCode Releases](https://github.com/anomalyco/opencode/releases)
