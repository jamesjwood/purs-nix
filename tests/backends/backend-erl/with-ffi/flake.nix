{
  description = "Backend-erl test with FFI - foreign function interface";

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

      inherit (purs-nix) tools;
      inherit (tools) pursBackendErl;

      ps = purs-nix.purs {
        dependencies = [
          "prelude"
          "effect"
          "console"
        ];

        backend = {
          cmd = "purs-backend-erl";
          package = pursBackendErl;
        };

        # Use locked package set for pure evaluation
        package-set = import ../with-deps/purerl-packages-locked.nix;

        dir = ./.;
      };

    in
    {
      packages.${system}.default = ps.output { };

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          pursBackendErl
          pkgs.erlang
          purs-nix.purescript
        ];
        shellHook = ''
          echo "PureScript backend-erl with FFI test"
          echo "Testing foreign Erlang functions"
        '';
      };
    };
}
