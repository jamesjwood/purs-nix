{
  description = "Minimal backend-erl test - no dependencies, single file";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    get-flake.url = "github:ursi/get-flake";
  };

  outputs =
    { nixpkgs, get-flake, ... }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};

      main-project-flake = get-flake ../../../..;
      purs-nix = main-project-flake { inherit system; };
      u = import ../../../../utils.nix pkgs;

      inherit (purs-nix) purescript tools;
      inherit (tools) pursBackendErl;

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
        phases = [
          "buildPhase"
          "installPhase"
        ];
        buildPhase = ''
          ${
            u.compile-corefn-only purescript {
              globs = ''"${src}/src/**/*.purs"'';
              output = "output";
            }
          }
        '';
        installPhase = "cp -r output $out";
      };

      # Stage 3: Backend compilation with purs-backend-erl
      backend-output = pkgs.stdenv.mkDerivation {
        name = "minimal-backend-erl";
        buildInputs = [
          pursBackendErl
          pkgs.nodejs
        ];
        phases = [
          "buildPhase"
          "installPhase"
        ];
        buildPhase = ''
          cp -r ${corefn} output
          chmod -R u+w output

          # purs-backend-erl reads from output/ and writes to output-erl/
          ${pursBackendErl}/bin/purs-backend-erl

          # Move output-erl contents back to output for consistency with purerl
          if [ -d output-erl ]; then
            cp -r output-erl/* output/ 2>/dev/null || true
            rmdir output-erl 2>/dev/null || true
          fi
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
        buildInputs = [
          purescript
          pursBackendErl
          pkgs.erlang
        ];
      };
    };
}
