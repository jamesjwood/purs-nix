{
  description = "JavaScript test with FFI - foreign function interface";

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

      ps = purs-nix.purs {
        dependencies = [
          "prelude"
          "effect"
          "console"
        ];

        dir = ./.;
      };

    in
    {
      packages.${system} = {
        default = ps.output { };
        bundle = ps.bundle { };
      };

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          nodejs
          (ps.command { })
          purs-nix.purescript
        ];
      };
    };
}
