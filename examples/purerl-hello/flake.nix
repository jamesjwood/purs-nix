{
  description = "Hello World example with PureScript Erlang backend";

  inputs = {
    get-flake.url = "github:ursi/get-flake";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { get-flake, nixpkgs, ... }:
    let
      system = "aarch64-darwin"; # Change to your system
      pkgs = nixpkgs.legacyPackages.${system};

      # Use local purs-nix for testing
      main-project-flake = get-flake ../../.;
      purs-nix-instance = main-project-flake { inherit system; };

      inherit (purs-nix-instance) tools;
      inherit (tools) purerl;

      ps = purs-nix-instance.purs {
        dependencies = [
          "console"
          "effect"
          "prelude"
        ];

        backend = {
          cmd = "purerl";
          package = purerl;
        };

        # Use locked package set for pure evaluation (no --impure needed!)
        package-set = import ./purerl-packages-locked.nix;

        dir = ./.;
      };
    in
    {
      packages.${system}.default = ps.output { };

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [ purerl pkgs.erlang ];
        shellHook = ''
          echo "PureScript Erlang development environment"
          echo "To regenerate locked package set:"
          echo "  nix run github:purs-nix/purs-nix#lock-package-set -- \\"
          echo "    https://raw.githubusercontent.com/purerl/package-sets/erl-0.15.3-20220629/packages.json \\"
          echo "    purerl-packages-locked.nix"
        '';
      };
    };
}
