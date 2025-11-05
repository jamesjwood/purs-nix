with import <nixpkgs> {};
stdenv.mkDerivation rec {
  pname = "purs-backend-es";
  version = "1.4.2";
  src = fetchurl {
    url = "https://registry.npmjs.org/${pname}/-/${pname}-${version}.tgz";
    hash = "sha256-oEkAUq7VFz2gB5r124ssu4H/zu2g6ydrArV3Nz584Do=";
  };
  sourceRoot = "package";
  installPhase = ''
    mkdir -p $out/bin $out/lib
    cp -r . $out/lib/${pname}
    cat > $out/bin/purs-backend-es <<EOF
#!/usr/bin/env bash
exec ${nodejs}/bin/node $out/lib/${pname}/index.js "\$@"
EOF
    chmod +x $out/bin/purs-backend-es
  '';
}
