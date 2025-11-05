{
  description = "Hello World with PureScript Backend Optimizer";

  inputs = {
    get-flake.url = "github:ursi/get-flake";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { get-flake
    , nixpkgs
    , utils
    , ...
    }:
    utils.lib.eachDefaultSystem
      (system:
      let
        main-project-flake = get-flake ../../.;
        purs-nix = main-project-flake { inherit system; };
        ps-tools = main-project-flake.inputs.ps-tools.legacyPackages.${system};
        p = nixpkgs.legacyPackages.${system};

        # Install purs-backend-es from npm registry (prebuilt binaries)
        backend-optimizer = p.stdenv.mkDerivation rec {
          pname = "purs-backend-es";
          version = "1.4.2";

          src = p.fetchurl {
            url = "https://registry.npmjs.org/${pname}/-/${pname}-${version}.tgz";
            hash = "sha256-oEkAUq7VFz2gB5r124ssu4H/zu2g6ydrArV3Nz584Do=";
          };

          # npm tarball contains a 'package' directory
          sourceRoot = "package";

          installPhase = ''
                        runHook preInstall

                        mkdir -p $out/bin $out/lib
                        # Copy all package contents
                        cp -r . $out/lib/${pname}

                        # Create wrapper script that translates -o flag to purs-backend-es args
                        cat > $out/bin/purs-backend-es <<EOF
            #!/usr/bin/env bash
            # Wrapper to translate standard -o flag to purs-backend-es arguments
            dir=""
            while [[ \$# -gt 0 ]]; do
              case \$1 in
                -o)
                  dir="\$2"
                  shift 2
                  ;;
                *)
                  shift
                  ;;
              esac
            done

            if [[ -z "\$dir" ]]; then
              echo "Error: -o <directory> required" >&2
              exit 1
            fi

            exec ${p.nodejs}/bin/node $out/lib/${pname}/index.js build --corefn-dir "\$dir" --output-dir "\$dir"
            EOF
                        chmod +x $out/bin/purs-backend-es

                        runHook postInstall
          '';

          meta = with p.lib; {
            description = "Optimizing backend toolkit for PureScript";
            homepage = "https://github.com/aristanetworks/purescript-backend-optimizer";
            license = licenses.asl20;
          };
        };

        ps = purs-nix.purs {
          dependencies = [
            "console"
            "effect"
            "prelude"
          ];

          # For JavaScript with optimizer, use purs-backend-es as the backend
          # It will both optimize AND generate modern ECMAScript
          backend = {
            cmd = "purs-backend-es";
            package = backend-optimizer;
          };

          dir = ./.;
        };
      in
      rec {
        apps.default = {
          type = "app";
          program = "${packages.default}/bin/hello";
        };

        packages = with ps; {
          default = app { name = "hello"; };
          bundle = bundle { };
          output = output { };
        };

        devShells.default = p.mkShell {
          buildInputs = with p; [
            nodejs
            (ps.command { })
            purs-nix.esbuild
            purs-nix.purescript
            ps-tools.for-0_15.purescript-language-server
            backend-optimizer
          ];
          shellHook = ''
            echo "PureScript development environment with backend optimizer"
            echo "purs-backend-es version: ${backend-optimizer.version}"
          '';
        };
      });
}
