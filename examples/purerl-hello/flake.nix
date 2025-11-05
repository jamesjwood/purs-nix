{
  description = "Hello World example with PureScript Erlang backend";

  inputs = {
    get-flake.url = "github:ursi/get-flake";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, get-flake, nixpkgs }:
    let
      system = "aarch64-darwin";  # Change to your system
      pkgs = nixpkgs.legacyPackages.${system};

      # Use local purs-nix for testing
      main-project-flake = get-flake ../../.;
      purs-nix-instance = main-project-flake { inherit system; };

      # Fetch purerl compiler
      purerl = pkgs.stdenv.mkDerivation rec {
        pname = "purerl";
        version = "0.0.24";
        src = pkgs.fetchurl {
          url = "https://github.com/purerl/purerl/releases/download/v${version}/macos.tar.gz";
          sha256 = "sha256-YcUIDA3q/Az6dSKTK3OhhyIQIoYkPI3B/LfRxVsDYsk=";
        };
        sourceRoot = ".";
        installPhase = ''
          mkdir -p $out/bin
          tar -xzf $src
          install -m755 -D purerl/purerl $out/bin/purerl
        '';
        dontFixup = true;
      };

      ps = purs-nix-instance.purs {
        dependencies = [
          "console"
          "effect"
          "prelude"
        ];

        backend = {
          cmd = "purerl";
          package = purerl;
        };

        # Use locked package set for pure evaluation (no --impure needed!)
        package-set = import ./purerl-packages-locked.nix;

        dir = ./.;
      };
    in
    {
      packages.${system}.default = ps.output {};

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [ purerl pkgs.erlang ];
        shellHook = ''
          echo "PureScript Erlang development environment"
          echo "To regenerate locked package set:"
          echo "  nix run github:purs-nix/purs-nix#lock-package-set -- \\"
          echo "    https://raw.githubusercontent.com/purerl/package-sets/erl-0.15.3-20220629/packages.json \\"
          echo "    purerl-packages-locked.nix"
        '';
      };
    };
}
