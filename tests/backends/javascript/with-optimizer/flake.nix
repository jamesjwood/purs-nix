{
  description = "JavaScript WITH optimizer (purs-backend-es) - no dependencies";

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

      # Program that benefits from optimization
      src = pkgs.writeTextDir "src/Main.purs" ''
        module Main where

        identity :: forall a. a -> a
        identity x = x

        compose :: forall a b c. (b -> c) -> (a -> b) -> a -> c
        compose f g x = f (g x)

        main :: Int
        main = compose identity identity 42
      '';

      # STAGE 1: Compile to CoreFn
      corefn = pkgs.stdenv.mkDerivation {
        name = "optimizer-test-corefn";
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

      # STAGES 2 & 3: Optimize + Generate JS
      optimized-js = pkgs.stdenv.mkDerivation {
        name = "optimizer-test-js";
        buildInputs = [ purs-backend-es pkgs.nodejs ];
        phases = [ "buildPhase" "installPhase" ];
        buildPhase = ''
          # Copy CoreFn
          cp -r ${corefn} output
          chmod -R u+w output

          # Run optimizer+backend
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
        inherit corefn;
      };

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [ purescript purs-backend-es pkgs.nodejs ];
        shellHook = ''
          echo "JavaScript optimizer test (no dependencies)"
          echo "purs-backend-es performs dead code elimination"
        '';
      };
    };
}
