p:
with builtins;
rec {
  # purerl backend binary (prebuilt tarballs)
  purerl =
    let
      version = "0.0.24";
      src =
        if p.stdenv.hostPlatform.isDarwin then
          p.fetchurl
            {
              url = "https://github.com/purerl/purerl/releases/download/v${version}/macos.tar.gz";
              hash = "sha256-YcUIDA3q/Az6dSKTK3OhhyIQIoYkPI3B/LfRxVsDYsk=";
            }
        else
          p.fetchurl {
            url = "https://github.com/purerl/purerl/releases/download/v${version}/linux.tar.gz";
            hash = "sha256-c/FK5bT5JU3PCuVeKUnry7FYo0JS3kS8h7OM01hmK3A=";
          };
    in
    p.stdenv.mkDerivation {
      pname = "purerl";
      inherit version src;
      sourceRoot = ".";
      installPhase = ''
        mkdir -p $out/bin
        tar -xzf $src
        install -m755 -D purerl/purerl $out/bin/purerl
      '';
      dontFixup = true;
    };

  # purs-backend-es (npm tarball)
  pursBackendEs =
    let
      _pname = "purs-backend-es";
      _version = "1.4.2";
      _src = p.fetchurl {
        url = "https://registry.npmjs.org/${_pname}/-/${_pname}-${_version}.tgz";
        hash = "sha256-oEkAUq7VFz2gB5r124ssu4H/zu2g6ydrArV3Nz584Do=";
      };
    in
    p.stdenv.mkDerivation {
      pname = _pname;
      version = _version;
      src = _src;
      sourceRoot = "package";
      installPhase = ''
                runHook preInstall
                mkdir -p $out/bin $out/lib
                cp -r . $out/lib/${_pname}
                cat > $out/bin/purs-backend-es << 'WRAPPER'
        #!/usr/bin/env bash
        exec NODE_PATH "$@"
        WRAPPER
                sed -i "s|NODE_PATH|${p.nodejs}/bin/node $out/lib/${_pname}/index.js|" \
                  $out/bin/purs-backend-es
                chmod +x $out/bin/purs-backend-es
                runHook postInstall
      '';
    };

  "purs-backend-es" = pursBackendEs;

  # purs-backend-erl (npm tarball)
  pursBackendErl =
    let
      _pname = "purs-backend-erl";
      _version = "0.0.3";
      _src = p.fetchurl {
        url = "https://registry.npmjs.org/${_pname}/-/${_pname}-${_version}.tgz";
        hash = "sha256-+WHVcwbKvliLMu1n3dbWjLbjBCcFDdYIKL0H6QxcoEWfe+eLvZmmCmxsxLqKNhvgHyDmqh4PyYszZrNUUV4NAQ==";
      };
    in
    p.stdenv.mkDerivation {
      pname = _pname;
      version = _version;
      src = _src;
      sourceRoot = "package";
      installPhase = ''
                runHook preInstall
                mkdir -p $out/bin $out/lib
                cp -r . $out/lib/${_pname}
                cat > $out/bin/purs-backend-erl << 'WRAPPER'
        #!/usr/bin/env bash
        exec NODE_PATH "$@"
        WRAPPER
                sed -i "s|NODE_PATH|${p.nodejs}/bin/node $out/lib/${_pname}/index.js|" \
                  $out/bin/purs-backend-erl
                chmod +x $out/bin/purs-backend-erl
                runHook postInstall
      '';
    };

  "purs-backend-erl" = pursBackendErl;
}
