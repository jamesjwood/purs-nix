{
  description = "Test three-stage architecture: CoreFn → Optional Optimizer → Backend";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    get-flake.url = "github:ursi/get-flake";
  };

  outputs = { self, nixpkgs, get-flake }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};

      # Get local purs-nix
      main-project-flake = get-flake ../.;
      purs-nix = main-project-flake { inherit system; };
      u = import ../utils.nix pkgs;

      purescript = purs-nix.purescript;

      # Fetch purerl backend
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

      # Minimal PureScript program (no dependencies, just types)
      src = pkgs.writeTextDir "src/Main.purs" ''
        module Main where

        -- Minimal program with no dependencies to test CoreFn generation
        identity :: forall a. a -> a
        identity x = x

        main :: Int
        main = identity 42
      '';

      # STAGE 1: Compile to CoreFn (per-package, cached)
      corefn = pkgs.stdenv.mkDerivation {
        name = "hello-corefn";
        inherit src;
        buildInputs = [ purescript ];
        buildPhase = ''
          ${u.compile-corefn-only purescript {
            globs = ''"${src}/src/**/*.purs"'';
            output = "output";
          }}
        '';
        installPhase = "cp -r output $out";
      };

      # STAGE 2: Optimizer (skipped in this test)
      # optimized-corefn = if optimizer != null then ... else corefn;

      # STAGE 3: Backend compilation (whole-project)
      backend-output = pkgs.stdenv.mkDerivation {
        name = "hello-erl";
        buildInputs = [ purerl ];
        phases = [ "buildPhase" "installPhase" ];
        buildPhase = ''
          # Copy CoreFn
          cp -r ${corefn} output
          chmod -R u+w output

          # Run backend (whole-project)
          ${u.compile-backend-directory {
            backend = {
              package = purerl;
              cmd = "purerl";
            };
            corefn-dir = "output";
          }}
        '';
        installPhase = "cp -r output $out";
      };

    in
    {
      packages.${system} = {
        default = backend-output;
        corefn = corefn;
      };

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [ purescript purerl pkgs.erlang ];
        shellHook = ''
          echo "Three-stage architecture test environment"
          echo "Stage 1: purs → CoreFn"
          echo "Stage 2: Optimizer (optional)"
          echo "Stage 3: Backend → .erl"
        '';
      };
    };
}
