{
  description = "OpenCode Desktop - The open source AI coding agent";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      packages.${system} = {
        default = pkgs.callPackage ./package.nix {};
        opencode-desktop = self.packages.${system}.default;
      };

      overlays.default = final: prev: {
        opencode-desktop = final.callPackage ./package.nix {};
      };
    };
}
