{
  description = "Minimal JavaScript test - no dependencies, single file";

  inputs = {
    purs-nix.url = "git+file:../../../..";
    nixpkgs.follows = "purs-nix/nixpkgs";
  };

  outputs = { purs-nix, nixpkgs, ... }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
      ps = purs-nix { inherit system; };

      inherit (ps) purescript;

      # Minimal program - no dependencies
      src = pkgs.writeTextDir "src/Main.purs" ''
        module Main where

        identity :: forall a. a -> a
        identity x = x

        main :: Int
        main = identity 42
      '';

      js-output = pkgs.stdenv.mkDerivation {
        name = "minimal-js";
        inherit src;
        buildInputs = [ purescript ];
        phases = [ "buildPhase" "installPhase" ];
        buildPhase = ''
          ${purescript}/bin/purs compile \
            --output output \
            "${src}/src/**/*.purs"
        '';
        installPhase = "cp -r output $out";
      };

    in
    {
      packages.${system}.default = js-output;

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [ purescript pkgs.nodejs ];
      };
    };
}
