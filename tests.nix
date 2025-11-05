# Backend tests for purs-nix three-stage architecture
# Tests both JavaScript and Erlang backends with various scenarios
#
# Note: Tests requiring dependency resolution (with-deps, with-erl-packages) are
# kept as standalone flakes in tests/backends/ for manual testing. These tests
# require proper project directory structures which are complex to inline here.
# The tests below cover the core three-stage pipeline functionality.

{ pkgs
, purs-nix-instance
}:

let
  inherit (purs-nix-instance) purescript;
  u = import ./utils.nix pkgs;

  # Fetch purerl binary for Erlang tests
  purerl =
    if pkgs.stdenv.isDarwin then
      pkgs.stdenv.mkDerivation
        rec {
          pname = "purerl";
          version = "0.0.24";
          src = pkgs.fetchurl {
            url = "https://github.com/purerl/purerl/releases/download/v${version}/macos.tar.gz";
            sha256 = "sha256-YcUIDA3q/Az6dSKTK3OhhyIQIoYkPI3B/LfRxVsDYsk=";
          };
          sourceRoot = ".";
          installPhase = ''
            mkdir -p $out/bin
            tar -xzf $src
            install -m755 -D purerl/purerl $out/bin/purerl
          '';
          dontFixup = true;
        }
    else
      pkgs.stdenv.mkDerivation rec {
        pname = "purerl";
        version = "0.0.24";
        src = pkgs.fetchurl {
          url = "https://github.com/purerl/purerl/releases/download/v${version}/linux.tar.gz";
          sha256 = "sha256-c/FK5bT5JU3PCuVeKUnry7FYo0JS3kS8h7OM01hmK3A=";
        };
        sourceRoot = ".";
        installPhase = ''
          mkdir -p $out/bin
          tar -xzf $src
          install -m755 -D purerl/purerl $out/bin/purerl
        '';
        dontFixup = true;
      };

  # Fetch purs-backend-es for optimizer tests
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
            cat > $out/bin/purs-backend-es << 'WRAPPER'
      #!/usr/bin/env bash
      exec NODE_PATH "$@"
      WRAPPER
            sed -i "s|NODE_PATH|${pkgs.nodejs}/bin/node $out/lib/${pname}/index.js|" \
              $out/bin/purs-backend-es
            chmod +x $out/bin/purs-backend-es
            runHook postInstall
    '';
  };

in
{
  # JavaScript Tests

  backend-js-minimal = pkgs.stdenv.mkDerivation {
    name = "backend-js-minimal";
    src = pkgs.writeTextDir "src/Main.purs" ''
      module Main where
      identity :: forall a. a -> a
      identity x = x
      main :: Int
      main = identity 42
    '';
    buildInputs = [ purescript ];
    phases = [ "buildPhase" "installPhase" ];
    buildPhase = ''
      ${purescript}/bin/purs compile \
        --output output \
        "$src/src/**/*.purs"
    '';
    installPhase = "cp -r output $out";
  };

  # backend-js-with-deps test is in tests/backends/javascript/with-deps/flake.nix
  # (requires proper project structure for dependency resolution)

  backend-js-with-optimizer =
    let
      src = pkgs.writeTextDir "src/Main.purs" ''
        module Main where
        identity :: forall a. a -> a
        identity x = x
        compose :: forall a b c. (b -> c) -> (a -> b) -> a -> c
        compose f g x = f (g x)
        main :: Int
        main = compose identity identity 42
      '';

      corefn = pkgs.stdenv.mkDerivation {
        name = "backend-js-optimizer-corefn";
        inherit src;
        buildInputs = [ purescript ];
        phases = [ "buildPhase" "installPhase" ];
        buildPhase = ''
          ${u.compile-corefn-only purescript {
            globs = ''"$src/src/**/*.purs"'';
            output = "output";
          }}
        '';
        installPhase = "cp -r output $out";
      };
    in
    pkgs.stdenv.mkDerivation {
      name = "backend-js-with-optimizer";
      buildInputs = [ purs-backend-es pkgs.nodejs ];
      phases = [ "buildPhase" "installPhase" ];
      buildPhase = ''
        cp -r ${corefn} output
        chmod -R u+w output
        ${u.optimize-corefn-directory {
          optimizer = {
            package = purs-backend-es;
            cmd = "purs-backend-es";
            args = [ "build" ];
          };
          corefn-dir = "output";
        }}
      '';
      installPhase = "cp -r output $out";
    };

  # Erlang Tests

  backend-erl-minimal =
    let
      src = pkgs.writeTextDir "src/Main.purs" ''
        module Main where
        identity :: forall a. a -> a
        identity x = x
        main :: Int
        main = identity 42
      '';

      corefn = pkgs.stdenv.mkDerivation {
        name = "backend-erl-minimal-corefn";
        inherit src;
        buildInputs = [ purescript ];
        phases = [ "buildPhase" "installPhase" ];
        buildPhase = ''
          ${u.compile-corefn-only purescript {
            globs = ''"$src/src/**/*.purs"'';
            output = "output";
          }}
        '';
        installPhase = "cp -r output $out";
      };
    in
    pkgs.stdenv.mkDerivation {
      name = "backend-erl-minimal";
      buildInputs = [ purerl ];
      phases = [ "buildPhase" "installPhase" ];
      buildPhase = ''
        cp -r ${corefn} output
        chmod -R u+w output
        ${u.compile-backend-directory {
          backend = {
            package = purerl;
            cmd = "purerl";
          };
          corefn-dir = "output";
        }}
      '';
      installPhase = "cp -r output $out";
    };

  # backend-erl-with-deps test is in tests/backends/erlang/with-deps/flake.nix
  # (requires proper project structure for dependency resolution)

  # backend-erl-with-erl-packages test is in tests/backends/erlang/with-erl-packages/flake.nix
  # (requires proper project structure for dependency resolution with custom package set)
}
