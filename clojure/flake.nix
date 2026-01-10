{
  description = "Clojure development environment";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  outputs =
    { self, nixpkgs, ... }:

    let
      # Change this value to update the whole stack:
      javaVersion = 25;

      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forEachSupportedSystem =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            pkgs = import nixpkgs {
              inherit system;
              overlays = [ self.overlays.default ];
            };
          }
        );
    in
    {
      overlays.default =
        final: prev:
        let
          jdk = prev."jdk${toString javaVersion}";
        in
        {
          clojure = prev.clojure.override { inherit jdk; };
        };

      devShells = forEachSupportedSystem (
        { pkgs }:
        {
          default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              clojure
            ];
          };
        }
      );
    };
}
