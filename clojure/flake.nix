{
  description = "Clojure development environment";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  outputs =
    { self, nixpkgs, ... }:

    let
      # Change this value to update the whole stack:
      javaVersion = 25;
      # The headless version of the JDK excludes GUI components - if you don't
      # need them, that makes for a lighter install:
      headless = true;
      suffix = if headless then "_headless" else "";
      jdk_name = "jdk${toString javaVersion}${suffix}";

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
          jdk = prev."${jdk_name}";
        in
        {
          clojure = prev.clojure.override { inherit jdk; };
        };

      devShells = forEachSupportedSystem (
        { pkgs }:
        {
          default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              clojure.jdk
              clojure
            ];
            JAVA_HOME = pkgs.clojure.jdk;
          };
        }
      );
    };
}
