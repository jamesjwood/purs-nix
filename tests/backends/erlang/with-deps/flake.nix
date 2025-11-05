{
  description = "Erlang test with real dependencies - prelude, effect, console, arrays";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    get-flake.url = "github:ursi/get-flake";
  };

  outputs = { nixpkgs, get-flake, ... }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};

      main-project-flake = get-flake ../../../..;
      purs-nix = main-project-flake { inherit system; };

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

      ps = purs-nix.purs {
        dependencies = [
          "prelude"
          "effect"
          "console"
          "arrays"
        ];

        backend = {
          cmd = "purerl";
          package = purerl;
        };

        # Use locked package set for pure evaluation
        package-set = import ./purerl-packages-locked.nix;

        dir = ./.;
      };

    in
    {
      packages.${system}.default = ps.output { };

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [ purerl pkgs.erlang purs-nix.purescript ];
        shellHook = ''
          echo "PureScript Erlang with dependencies test"
          echo "Dependencies: prelude, effect, console, arrays"
        '';
      };
    };
}
