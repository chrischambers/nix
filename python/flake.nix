{
  description = ''
    Python development environment combining nix and uv.

    - System/external dependencies are managed by nix:
      flake.nix and flake.lock are the source of truth
      for these deps.

    - Python package dependencies are managed by uv:
      pyproject.toml and uv.lock are the source of truth
      for these deps.
  '';
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
  outputs =
    { nixpkgs, ... }:

    let
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
            pkgs = import nixpkgs { inherit system; };
          }
        );
    in
    {
      devShells = forEachSupportedSystem (
        { pkgs }:
        {
          default = pkgs.mkShellNoCC {
            # NOTE: This should be for system/external dependencies only.

            # You need to let uv manage the python dependencies through its
            # mechanisms, so don't add any pkgs.python3XXPackages entries here:
            packages = with pkgs; [
              python3
              uv
            ];

            # NOTE: These entries are shamelessly cargo-culted from
            # https://github.com/pyproject-nix/pyproject.nix:

            env = pkgs.lib.optionalAttrs pkgs.stdenv.isLinux {
              # Python libraries often load native shared objects using dlopen(3).
              # Setting LD_LIBRARY_PATH makes the dynamic library loader aware of libraries without using RPATH for lookup.
              LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath pkgs.pythonManylinuxPackages.manylinux1;
            };
            shellHook = ''
              unset PYTHONPATH
              uv sync
              . .venv/bin/activate
            '';
          };
        }
      );
    };
}
