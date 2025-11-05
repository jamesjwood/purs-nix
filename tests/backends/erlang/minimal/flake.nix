{
  description = "Minimal Erlang test - no dependencies, single file";

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
      u = import ../../../../utils.nix pkgs;

      inherit (purs-nix) purescript;

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

      # Minimal program - no dependencies
      src = pkgs.writeTextDir "src/Main.purs" ''
        module Main where

        identity :: forall a. a -> a
        identity x = x

        main :: Int
        main = identity 42
      '';

      # Stage 1: Compile to CoreFn
      corefn = pkgs.stdenv.mkDerivation {
        name = "minimal-corefn";
        inherit src;
        buildInputs = [ purescript ];
        phases = [ "buildPhase" "installPhase" ];
        buildPhase = ''
          ${u.compile-corefn-only purescript {
            globs = ''"${src}/src/**/*.purs"'';
            output = "output";
          }}
        '';
        installPhase = "cp -r output $out";
      };

      # Stage 3: Backend compilation
      backend-output = pkgs.stdenv.mkDerivation {
        name = "minimal-erl";
        buildInputs = [ purerl ];
        phases = [ "buildPhase" "installPhase" ];
        buildPhase = ''
          cp -r ${corefn} output
          chmod -R u+w output

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
        inherit corefn;
      };

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [ purescript purerl pkgs.erlang ];
      };
    };
}
