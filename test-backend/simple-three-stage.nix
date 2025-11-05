# Simple three-stage architecture test
# Demonstrates: Source → CoreFn → Backend
{ pkgs ? import <nixpkgs> {} }:

let
  u = import ../utils.nix pkgs;
  purescript = pkgs.purescript;

  # Fetch purerl
  purerl = pkgs.stdenv.mkDerivation rec {
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
  };

  # Stage 1: Compile single module to CoreFn
  corefn = pkgs.stdenv.mkDerivation {
    name = "minimal-corefn";
    src = ./minimal-locked;
    buildInputs = [ purescript ];
    buildPhase = ''
      ${u.compile-corefn-only purescript {
        globs = ''"${./minimal-locked}/src/**/*.purs"'';
        output = "output";
      }}
    '';
    installPhase = "cp -r output $out";
  };

  # Stage 3: Run backend on CoreFn (no optimizer for this test)
  backend-output = pkgs.stdenv.mkDerivation {
    name = "minimal-backend";
    buildPhase = ''
      # Copy CoreFn
      cp -r ${corefn} output
      chmod -R u+w output

      # Run backend
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

in
  backend-output
