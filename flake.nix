{
  inputs = {
    docs-search = {
      # to prevent lock file explosion
      flake = false;
      url = "github:jamesjwood/purescript-docs-search";
    };
    get-flake = {
      url = "github:ursi/get-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lint-utils = {
      url = "github:homotopic/lint-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    make-shell = {
      url = "github:ursi/nix-make-shell/1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    parsec = {
      url = "github:nprindle/nix-parsec";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ps-tools = {
      url = "github:jamesjwood/purescript-tools/arm64-support";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    utils = {
      url = "github:ursi/flake-utils/8";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { get-flake, parsec, utils, ... }@inputs:
    with builtins;
    {
      __functor = _:
        { defaults ? { }
        , overlays ? [ ]
        , pkgs ? inputs.nixpkgs.legacyPackages.${system}
        , system
        }:
        import ./purs-nix.nix {
          inherit (inputs) docs-search;
          inherit defaults overlays pkgs;
          inherit (parsec.lib) parsec;
          ps-tools = inputs.ps-tools.legacyPackages.${system};
        };

      templates = {
        default = {
          description = "A basic purs-nix project";
          path = "${./templates/default}";
        };

        flake = {
          description = "The flake.nix only - for converting existing projects";

          path =
            toString
              (filterSource
                (path: _: baseNameOf path == "flake.nix")
                ./templates/default);
        };

        package = {
          description = "A basic purs-nix package setup";
          path = "${./templates/package}";
        };
      };

      herculesCI.ciSystems = [ "x86_64-linux" ];
    }
    // utils.apply-systems
      {
        inherit inputs;
        systems = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ];
      }
      ({ make-shell
       , lint-utils
       , pkgs
       , system
       , ...
       }:
        let
          p = pkgs;
          u = import ./utils.nix p;

          inherit
            (import ./build-pkgs.nix {
              inherit pkgs;
              utils = u;
            })
            ps-pkgs;
        in
        {
          legacyPackages = {
            package-info =
              mapAttrs
                (_: v: p.writeShellScriptBin v.purs-nix-info.name (u.package-info v))
                ps-pkgs;
          };

          apps =
            let
              lock-script = ./scripts/lock-package-set.sh;
              lock-package-set-wrapped = p.writeShellScriptBin "lock-package-set" ''
                PATH=${p.lib.makeBinPath [ p.bash p.curl p.jq p.git ]}:$PATH
                exec ${p.bash}/bin/bash ${lock-script} "$@"
              '';
            in
            {
              lock-package-set = {
                type = "app";
                program = "${lock-package-set-wrapped}/bin/lock-package-set";
                meta = {
                  description = "Lock a PureScript package set by resolving git tags to commit hashes";
                };
              };

              refresh-package-set = {
                type = "app";
                program = "${p.writeShellScript "refresh-package-set" ''
                  PATH=${p.lib.makeBinPath [ p.bash p.curl p.jq p.git ]}:$PATH
                  exec ${p.bash}/bin/bash ${lock-script} --refresh "$@"
                ''}";
                meta = {
                  description = "Refresh a locked package set with latest commit hashes";
                };
              };

              prefetch-url = {
                type = "app";
                program = "${p.writeShellScript "prefetch-url" ''
                  set -euo pipefail
                  if [ $# -lt 1 ]; then
                    echo "usage: prefetch-url <URL>" >&2
                    exit 1
                  fi
                  URL="$1"
                  HASH=$(${p.nix}/bin/nix store prefetch-file --json "$URL" | ${p.jq}/bin/jq -r .hash)
                  echo "hash = \"$HASH\";"
                ''}";
                meta = { description = "Prefetch a URL and print a Nix hash attribute"; };
              };
            };

          checks =
            let
              lu = inputs.lint-utils.linters.${system};

              # Create purs-nix instance for backend tests
              purs-nix-for-system = import ./purs-nix.nix {
                inherit (inputs) docs-search;
                defaults = { };
                overlays = [ ];
                inherit pkgs;
                inherit (inputs.parsec.lib) parsec;
                ps-tools = inputs.ps-tools.legacyPackages.${system};
              };

              # Backend tests run on all systems (aarch64-darwin, x86_64-linux, aarch64-linux)
              # Defined in tests.nix to keep this flake clean
              backend-tests = import ./tests.nix {
                inherit pkgs;
                purs-nix-instance = purs-nix-for-system;
              };

              # Original tests only on x86_64-linux
              original-tests =
                if system == "x86_64-linux" then
                  (get-flake ./test).checks.${system}
                  // {
                    "hello world example" =
                      (get-flake ./examples/hello-world).packages.${system}.default;

                    "foreign deps example" =
                      (get-flake ./examples/foreign-dependencies).packages.${system}.default;
                  }
                else
                  { };
            in
            {
              deadnix = lu.deadnix { src = ./.; };
              formatting = lu.nixpkgs-fmt { src = ./.; };
              statix = lu.statix { src = ./.; };
            }
            // backend-tests
            // original-tests;

          devShells.default = make-shell {
            packages = with p; [
              deadnix
              lint-utils.nixpkgs-fmt
              statix
            ];

            aliases.lint = "deadnix **/*.nix; statix check";
            env.GIT_LFS_SKIP_SMUDGE = 1;
          };

          formatter = lint-utils.nixpkgs-fmt;
        });
}
