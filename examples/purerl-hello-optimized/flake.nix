{
  description = "Hello World with PureScript Erlang backend and optimizer";

  inputs = {
    purs-nix.url = "github:purs-nix/purs-nix";
    nixpkgs.follows = "purs-nix/nixpkgs";
  };

  outputs = { self, purs-nix, nixpkgs }:
    let
      system = "aarch64-darwin";  # Change to your system
      pkgs = nixpkgs.legacyPackages.${system};
      purs-nix-instance = purs-nix { inherit system; };

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

      # Fetch purs-backend-es optimizer
      backend-optimizer = pkgs.stdenv.mkDerivation {
        pname = "purs-backend-es";
        version = "6.4.3";
        src = pkgs.fetchurl {
          url = if pkgs.stdenv.isDarwin then
            "https://github.com/aristanetworks/purescript-backend-optimizer/releases/download/v6.4.3/Darwin.tar.gz"
          else
            "https://github.com/aristanetworks/purescript-backend-optimizer/releases/download/v6.4.3/Linux.tar.gz";
          sha256 = if pkgs.stdenv.isDarwin then
            "sha256-NotYetKnown"  # Will update after first fetch
          else
            "sha256-NotYetKnown";
        };
        sourceRoot = ".";
        installPhase = ''
          mkdir -p $out/bin
          tar -xzf $src
          install -m755 -D purs-backend-es $out/bin/purs-backend-es
        '';
        dontFixup = true;
      };

      ps = purs-nix-instance.purs {
        dependencies = [
          "console"
          "effect"
          "prelude"
        ];

        # Backend: purerl generates Erlang code
        backend = {
          cmd = "purerl";
          package = purerl;
        };

        # Optimizer: runs BEFORE purerl, optimizes CoreFn
        optimizer = {
          cmd = "purs-backend-es";
          package = backend-optimizer;
          args = [];  # Just optimize, don't build (purerl will build)
        };

        # Use locked package set for pure evaluation
        package-set = import ../purerl-hello/purerl-packages-locked.nix;

        dir = ./.;
      };
    in
    {
      packages.${system}.default = ps.output {};

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [ purerl pkgs.erlang backend-optimizer ];
        shellHook = ''
          echo "PureScript Erlang development environment with optimizer"
          echo "Optimizer: ${backend-optimizer.version}"
          echo "Purerl: ${purerl.version}"
          echo ""
          echo "Build flow:"
          echo "  1. purs compile --codegen corefn"
          echo "  2. purs-backend-es optimize (optimizes CoreFn)"
          echo "  3. purerl (generates .erl from optimized CoreFn)"
        '';
      };
    };
}
