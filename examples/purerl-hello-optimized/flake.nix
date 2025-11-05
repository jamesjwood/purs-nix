{
  description = "Hello World with PureScript Erlang backend and optimizer";

  inputs = {
    purs-nix.url = "github:purs-nix/purs-nix";
    nixpkgs.follows = "purs-nix/nixpkgs";
  };

  outputs = { purs-nix, nixpkgs, ... }:
    let
      system = "aarch64-darwin"; # Change to your system
      pkgs = nixpkgs.legacyPackages.${system};
      purs-nix-instance = purs-nix { inherit system; };
      inherit (purs-nix-instance) tools;
      inherit (tools) purerl pursBackendEs;

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
          package = pursBackendEs;
          args = [ ]; # Just optimize, don't build (purerl will build)
        };

        # Use locked package set for pure evaluation
        package-set = import ../purerl-hello/purerl-packages-locked.nix;

        dir = ./.;
      };
    in
    {
      packages.${system}.default = ps.output { };

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [ purerl pkgs.erlang pursBackendEs ];
        shellHook = ''
          echo "PureScript Erlang development environment with optimizer"
          echo "Optimizer: ${pursBackendEs.version}"
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
