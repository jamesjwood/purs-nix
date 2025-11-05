{
  description = "Backend support tests for purs-nix";

  inputs = {
    get-flake.url = "github:ursi/get-flake";
  };

  outputs = { get-flake, ... }@inputs:
    with builtins;
    let purs-nix-flake = get-flake ../.; in
    purs-nix-flake.inputs.utils.apply-systems
      {
        inputs = inputs // {
          purs-nix = purs-nix-flake;
          inherit (purs-nix-flake.inputs) nixpkgs;
        };
        systems = [ "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
      }
      ({ pkgs, system, ... }:
        let
          purs-nix-instance = purs-nix-flake { inherit system; };

          # Fetch purerl binary for the system
          purerl =
            if pkgs.stdenv.isDarwin then
              pkgs.stdenv.mkDerivation rec {
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
                  sha256 = "sha256-Ue9eCm+x7jABb1mtShc4HrOp1J99FXhZS+rXaJV4rMw=";
                };
                sourceRoot = ".";
                installPhase = ''
                  mkdir -p $out/bin
                  tar -xzf $src
                  install -m755 -D purerl/purerl $out/bin/purerl
                '';
                dontFixup = true;
              };

          # Locked package set for testing
          locked-package-set = import ./minimal-locked-packages.nix;

        in
        {
          checks = {
            # Test 1: Minimal project with locked package set (PURE mode)
            minimal-locked-pure =
              let
                ps = purs-nix-instance.purs {
                  dependencies = [ "console" "effect" "prelude" ];
                  backend = {
                    cmd = "purerl";
                    package = purerl;
                  };
                  package-set = locked-package-set;
                  dir = ./minimal-locked;
                };
              in
              ps.output {};

            # Test 2: Same project but test that .erl files are generated
            minimal-locked-erl-files =
              let
                ps = purs-nix-instance.purs {
                  dependencies = [ "console" "effect" "prelude" ];
                  backend = {
                    cmd = "purerl";
                    package = purerl;
                  };
                  package-set = locked-package-set;
                  dir = ./minimal-locked;
                };
                output = ps.output {};
              in
              pkgs.runCommand "check-erl-files" {} ''
                # Check that .erl files exist
                if [ ! -f ${output}/Main/main@ps.erl ]; then
                  echo "ERROR: main@ps.erl not found!"
                  exit 1
                fi

                # Check that prelude was compiled
                if [ ! -d ${output}/Prelude ]; then
                  echo "ERROR: Prelude directory not found!"
                  exit 1
                fi

                echo "✓ .erl files generated successfully"
                touch $out
              '';

            # Test 3: Medium project with Erlang-specific packages
            medium-locked-pure =
              let
                ps = purs-nix-instance.purs {
                  dependencies = [
                    "console"
                    "effect"
                    "prelude"
                    "erl-atom"
                    "erl-lists"
                    "erl-maps"
                    "erl-process"
                  ];
                  backend = {
                    cmd = "purerl";
                    package = purerl;
                  };
                  package-set = locked-package-set;
                  dir = ./medium-locked;
                };
              in
              ps.output {};

            # Test 4: Package set locking script works
            lock-script-works = pkgs.runCommand "test-lock-script" {
              buildInputs = [ pkgs.bash pkgs.curl pkgs.jq pkgs.git ];
            } ''
              # Test that script shows help
              bash ${../scripts/lock-package-set.sh} > help.txt 2>&1 || true

              if ! grep -q "Usage:" help.txt; then
                echo "ERROR: Script doesn't show usage!"
                cat help.txt
                exit 1
              fi

              echo "✓ Lock script shows help correctly"
              touch $out
            '';

            # Test 5: Verify locked package format
            locked-format-valid = pkgs.runCommand "check-locked-format" {
              lockFile = ./minimal-locked-packages.nix;
            } ''
              # Import the locked file
              pkgs_func=$(cat $lockFile)

              # Basic syntax check
              if ! echo "$pkgs_func" | grep -q "self:"; then
                echo "ERROR: Locked file doesn't have 'self:' parameter"
                exit 1
              fi

              if ! echo "$pkgs_func" | grep -q "src.git"; then
                echo "ERROR: Locked file doesn't have src.git entries"
                exit 1
              fi

              if ! echo "$pkgs_func" | grep -q "rev ="; then
                echo "ERROR: Locked file doesn't have rev (commit hash) entries"
                exit 1
              fi

              echo "✓ Locked package set format is valid"
              touch $out
            '';
          };

          # Example packages that can be built standalone
          packages = {
            minimal-example =
              let
                ps = purs-nix-instance.purs {
                  dependencies = [ "console" "effect" "prelude" ];
                  backend = {
                    cmd = "purerl";
                    package = purerl;
                  };
                  package-set = locked-package-set;
                  dir = ./minimal-locked;
                };
              in
              ps.output {};
          };
        });
}
