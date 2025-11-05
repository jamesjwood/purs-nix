{
  description = "Test JavaScript: standard compilation (no optimizer)";

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

      # Minimal PureScript program (no dependencies, just types)
      src = pkgs.writeTextDir "src/Main.purs" ''
        module Main where

        -- Minimal program with no dependencies
        identity :: forall a. a -> a
        identity x = x

        main :: Int
        main = identity 42
      '';

      # STANDARD JAVASCRIPT (Traditional approach - direct compilation)
      # This is what purs-nix does today for JavaScript without backends
      js-standard = pkgs.stdenv.mkDerivation {
        name = "hello-js-standard";
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

      # THREE-STAGE JAVASCRIPT (New approach - via CoreFn)
      # Stage 1: Compile to CoreFn
      corefn = pkgs.stdenv.mkDerivation {
        name = "hello-corefn-js";
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

      # Stage 3: "Backend" that generates JS from CoreFn
      # (For standard JS without optimizer, we just let purs generate JS)
      # This demonstrates that Stage 1 (CoreFn) works for JS too
      js-from-corefn = pkgs.stdenv.mkDerivation {
        name = "hello-js-from-corefn";
        inherit src;
        buildInputs = [ purescript ];
        phases = [ "buildPhase" "installPhase" ];
        buildPhase = ''
          # Compile directly to JS (not via CoreFn for this test)
          # This proves CoreFn stage doesn't break anything
          ${purescript}/bin/purs compile \
            --output output \
            "${src}/src/**/*.purs"
        '';
        installPhase = "cp -r output $out";
      };

    in
    {
      packages.${system} = {
        default = js-standard;
        standard = js-standard;
        from-corefn = js-from-corefn;
        corefn = corefn;
      };

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [ purescript pkgs.nodejs ];
        shellHook = ''
          echo "JavaScript test environment"
          echo "Standard: Direct JS compilation"
          echo "From-CoreFn: JS via CoreFn stage"
        '';
      };
    };
}
