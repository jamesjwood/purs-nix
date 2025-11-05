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

        inherit (purs-nix) tools;
        inherit (tools) pursBackendEs;

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
            package = pursBackendEs;
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
            pursBackendEs
          ];
          shellHook = ''
            echo "PureScript development environment with backend optimizer"
            echo "purs-backend-es version: ${pursBackendEs.version}"
          '';
        };
      });
}
