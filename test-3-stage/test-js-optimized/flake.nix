{
  description = "Test JavaScript WITH optimizer (purs-backend-es)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    get-flake.url = "github:ursi/get-flake";
  };

  outputs = { self, nixpkgs, get-flake }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};

      # Get local purs-nix
      main-project-flake = get-flake ../../.;
      purs-nix = main-project-flake { inherit system; };
      u = import ../../utils.nix pkgs;

      purescript = purs-nix.purescript;

      # Install purs-backend-es from npm registry
      purs-backend-es = pkgs.stdenv.mkDerivation rec {
        pname = "purs-backend-es";
        version = "1.4.2";

        src = pkgs.fetchurl {
          url = "https://registry.npmjs.org/${pname}/-/${pname}-${version}.tgz";
          hash = "sha256-oEkAUq7VFz2gB5r124ssu4H/zu2g6ydrArV3Nz584Do=";
        };

        sourceRoot = "package";

        installPhase = ''
          runHook preInstall

          mkdir -p $out/bin $out/lib
          cp -r . $out/lib/${pname}

          # Create CLI wrapper
          cat > $out/bin/purs-backend-es << 'WRAPPER'
#!/usr/bin/env bash
exec NODE_PATH "$@"
WRAPPER

          # Replace placeholders
          sed -i "s|NODE_PATH|${pkgs.nodejs}/bin/node $out/lib/${pname}/index.js|" \
            $out/bin/purs-backend-es

          chmod +x $out/bin/purs-backend-es

          runHook postInstall
        '';

        meta = with pkgs.lib; {
          description = "Optimizing backend toolkit for PureScript";
          homepage = "https://github.com/aristanetworks/purescript-backend-optimizer";
          license = licenses.asl20;
        };
      };

      # Minimal PureScript program (no dependencies)
      src = pkgs.writeTextDir "src/Main.purs" ''
        module Main where

        -- Program that benefits from optimization
        identity :: forall a. a -> a
        identity x = x

        compose :: forall a b c. (b -> c) -> (a -> b) -> a -> c
        compose f g x = f (g x)

        main :: Int
        main = compose identity identity 42
      '';

      # STAGE 1: Compile to CoreFn (per-package, cached)
      corefn = pkgs.stdenv.mkDerivation {
        name = "hello-corefn";
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

      # STAGES 2 & 3: Optimize + Generate JS (whole-project)
      # purs-backend-es does BOTH optimization and JavaScript generation
      optimized-js = pkgs.stdenv.mkDerivation {
        name = "hello-optimized-js";
        buildInputs = [ purs-backend-es pkgs.nodejs ];
        phases = [ "buildPhase" "installPhase" ];
        buildPhase = ''
          # Copy CoreFn
          cp -r ${corefn} output
          chmod -R u+w output

          # Run optimizer+backend (combined Stage 2+3)
          ${u.optimize-corefn-directory {
            optimizer = {
              package = purs-backend-es;
              cmd = "purs-backend-es";
              args = ["build"];
            };
            corefn-dir = "output";
          }}
        '';
        installPhase = "cp -r output $out";
      };

    in
    {
      packages.${system} = {
        default = optimized-js;
        corefn = corefn;
        optimized = optimized-js;
        optimizer-tool = purs-backend-es;
      };

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [ purescript purs-backend-es pkgs.nodejs ];
        shellHook = ''
          echo "JavaScript WITH Optimizer test environment"
          echo "Stage 1: purs → CoreFn"
          echo "Stage 2+3: purs-backend-es → Optimized JS"
        '';
      };
    };
}
