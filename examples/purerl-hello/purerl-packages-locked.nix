# Generated from: https://raw.githubusercontent.com/purerl/package-sets/erl-0.15.3-20220629/packages.json
# Generated at: 2025-11-04T14:42:47Z
# To refresh: nix run github:purs-nix/purs-nix#refresh-package-set -- <this-file>
#
# This file contains locked package versions with commit hashes
# for reproducible, pure evaluation builds.

self: {
  "arrays" = {
    src.git = {
      repo = "https://github.com/purerl/purescript-arrays.git";
      rev = "24ac35d3598af6bfb5e479d313f9493ab4d62984";  # Resolved from tag v6.0.0-erl1
    };
    info = {
      version = "v6.0.0-erl1";
      dependencies = [ "bifunctors" "control" "foldable-traversable" "maybe" "nonempty" "partial" "prelude" "tailrec" "tuples" "unfoldable" "unsafe-coerce" ];
    };
  };

  "assert" = {
    src.git = {
      repo = "https://github.com/purerl/purescript-assert.git";
      rev = "b3f25ea1b27e64881c99032a5ec8d461b4491e25";  # Resolved from tag v5.0.0-erl1
    };
    info = {
      version = "v5.0.0-erl1";
      dependencies = [ "console" "effect" "prelude" ];
    };
  };

  "bifunctors" = {
    src.git = {
      repo = "https://github.com/purescript/purescript-bifunctors.git";
      rev = "a31d0fc4bbebf19d5e9b21b65493c28b8d3fba62";  # Resolved from tag v5.0.0
    };
    info = {
      version = "v5.0.0";
      dependencies = [ "const" "either" "newtype" "prelude" "tuples" ];
    };
  };

  "catenable-lists" = {
    src.git = {
      repo = "https://github.com/purescript/purescript-catenable-lists.git";
      rev = "b18278a7cd034b983187580c58a183456b5a25ee";  # Resolved from tag v6.0.1
    };
    info = {
      version = "v6.0.1";
      dependencies = [ "control" "foldable-traversable" "lists" "maybe" "prelude" "tuples" "unfoldable" ];
    };
  };

  "console" = {
    src.git = {
      repo = "https://github.com/purerl/purescript-console.git";
      rev = "56cfd5294acb79758cf30b357751f624650f18e3";  # Resolved from tag v5.0.0-erl1
    };
    info = {
      version = "v5.0.0-erl1";
      dependencies = [ "effect" "prelude" ];
    };
  };

  "const" = {
    src.git = {
      repo = "https://github.com/purescript/purescript-const.git";
      rev = "3a3a4bdc44f71311cf27de9bd22039b110277540";  # Resolved from tag v5.0.0
    };
    info = {
      version = "v5.0.0";
      dependencies = [ "invariant" "newtype" "prelude" ];
    };
  };

  "contravariant" = {
    src.git = {
      repo = "https://github.com/purescript/purescript-contravariant.git";
      rev = "ae1a765f7ddbfd96ae1f12e399e46d554d8e3b38";  # Resolved from tag v5.0.0
    };
    info = {
      version = "v5.0.0";
      dependencies = [ "const" "either" "newtype" "prelude" "tuples" ];
    };
  };

  "control" = {
    src.git = {
      repo = "https://github.com/purerl/purescript-control.git";
      rev = "e3add624f8dacb4d6bec6d9ed682df692e197b5b";  # Resolved from tag v5.0.0-erl1
    };
    info = {
      version = "v5.0.0-erl1";
      dependencies = [ "newtype" "prelude" ];
    };
  };

  "convertable-options" = {
    src.git = {
      repo = "https://github.com/natefaubion/purescript-convertable-options";
      rev = "58728f24d9a5f28e359b4e7940b347c80cb56c6a";  # Resolved from tag v1.0.0
    };
    info = {
      version = "v1.0.0";
      dependencies = [ "effect" "maybe" "record" ];
    };
  };

  "datetime" = {
    src.git = {
      repo = "https://github.com/purerl/purescript-datetime.git";
      rev = "0212f4cb693ca6e4361a09462180a5bc3a9e0552";  # Resolved from tag v5.0.2-erl1
    };
    info = {
      version = "v5.0.2-erl1";
      dependencies = [ "bifunctors" "control" "either" "enums" "foldable-traversable" "functions" "gen" "integers" "lists" "math" "maybe" "newtype" "ordered-collections" "partial" "prelude" "tuples" ];
    };
  };

  "debug" = {
    src.git = {
      repo = "https://github.com/purerl/purescript-debug.git";
      rev = "3f6d18679e224249685bc690dfd5f0884a580374";  # Resolved from tag v5.0.0-erl1
    };
    info = {
      version = "v5.0.0-erl1";
      dependencies = [ "prelude" ];
    };
  };

  "distributive" = {
    src.git = {
      repo = "https://github.com/purescript/purescript-distributive.git";
      rev = "11f3f87ca5720899e1739cedb58dd6227cae6ad5";  # Resolved from tag v5.0.0
    };
    info = {
      version = "v5.0.0";
      dependencies = [ "identity" "newtype" "prelude" "tuples" "type-equality" ];
    };
  };

  "effect" = {
    src.git = {
      repo = "https://github.com/purerl/purescript-effect.git";
      rev = "69ba78cd96a27a0af6a723d255dc05a32c6eaa43";  # Resolved from tag v3.0.0-erl1
    };
    info = {
      version = "v3.0.0-erl1";
      dependencies = [ "prelude" ];
    };
  };

  "either" = {
    src.git = {
      repo = "https://github.com/purescript/purescript-either.git";
      rev = "c1a1af35684f10eecaf6ac7d38dbf6bd48af2ced";  # Resolved from tag v5.0.0
    };
    info = {
      version = "v5.0.0";
      dependencies = [ "control" "invariant" "maybe" "prelude" ];
    };
  };

  "enums" = {
    src.git = {
      repo = "https://github.com/purerl/purescript-enums.git";
      rev = "9c3ec61d03c04642af91e2ac72500cdd6009bd98";  # Resolved from tag v5.0.0-erl1
    };
    info = {
      version = "v5.0.0-erl1";
      dependencies = [ "control" "either" "gen" "maybe" "newtype" "nonempty" "partial" "prelude" "tuples" "unfoldable" ];
    };
  };

  "erl-atom" = {
    src.git = {
      repo = "https://github.com/purerl/purescript-erl-atom.git";
      rev = "4c080679047d6cb166d8a08c2fdcd6d13e480532";  # Resolved from tag v1.2.0
    };
    info = {
      version = "v1.2.0";
      dependencies = [ "prelude" "unsafe-coerce" ];
    };
  };

  "erl-binary" = {
    src.git = {
      repo = "https://github.com/purerl/purescript-erl-binary.git";
      rev = "0d91ea7615eb482bc4c31eb87722dd2f032d56b6";  # Resolved from tag v0.6.0
    };
    info = {
      version = "v0.6.0";
      dependencies = [ "prelude" "maybe" "erl-lists" ];
    };
  };

  "erl-cowboy" = {
    src.git = {
      repo = "https://github.com/purerl/purescript-erl-cowboy";
      rev = "f1e3c71405f6b6d2f38086eb7ece8e197f5f8bd2";  # Resolved from tag v0.11.0
    };
    info = {
      version = "v0.11.0";
      dependencies = [ "effect" "either" "erl-atom" "erl-binary" "erl-kernel" "erl-lists" "erl-maps" "erl-modules" "erl-ranch" "erl-ssl" "erl-tuples" "foreign" "functions" "maybe" "prelude" "record" "transformers" "tuples" "unsafe-coerce" ];
    };
  };

  "erl-file" = {
    src.git = {
      repo = "https://github.com/purerl/purescript-erl-file.git";
      rev = "da82acc9937a753f8f2247b5e58130f778a7ad7b";  # Resolved from tag v0.0.3
    };
    info = {
      version = "v0.0.3";
      dependencies = [ "erl-atom" "erl-binary" "prelude" ];
    };
  };

  "erl-gun" = {
    src.git = {
      repo = "https://github.com/id3as/purescript-erl-gun.git";
      rev = "d3ae7707e1e5916875cc2396acf0d1a684dfdbeb";  # Resolved from tag v0.0.2
    };
    info = {
      version = "v0.0.2";
      dependencies = [ "convertable-options" "datetime" "effect" "either" "erl-atom" "erl-binary" "erl-kernel" "erl-lists" "erl-maps" "erl-process" "erl-ssl" "erl-tuples" "erl-untagged-union" "foreign" "functions" "maybe" "prelude" "record" "simple-json" "typelevel-prelude" ];
    };
  };

  "erl-jsone" = {
    src.git = {
      repo = "https://github.com/purerl/purescript-erl-jsone";
      rev = "70fe914401cf5e58d867ba15b4a7c1f3b011d6cb";  # Resolved from tag v0.4.0
    };
    info = {
      version = "v0.4.0";
      dependencies = [ "arrays" "integers" "assert" "either" "erl-lists" "erl-tuples" ];
    };
  };

  "erl-kernel" = {
    src.git = {
      repo = "https://github.com/id3as/purescript-erl-kernel.git";
      rev = "fb4794817149b43e89106073d910d4f8c65e5cbd";  # Resolved from tag v0.0.3
    };
    info = {
      version = "v0.0.3";
      dependencies = [ "convertable-options" "datetime" "effect" "either" "erl-atom" "erl-binary" "erl-lists" "erl-maps" "erl-process" "erl-tuples" "erl-untagged-union" "foldable-traversable" "foreign" "functions" "integers" "maybe" "newtype" "partial" "prelude" "record" "typelevel-prelude" "unsafe-coerce" ];
    };
  };

  "erl-lager" = {
    src.git = {
      repo = "https://github.com/purerl/purescript-erl-lager.git";
      rev = "3a00b33e86afd23ec641a9fafb7e9ec7485c9219";  # Resolved from tag v0.0.1
    };
    info = {
      version = "v0.0.1";
      dependencies = [ "erl-lists" ];
    };
  };

  "erl-lists" = {
    src.git = {
      repo = "https://github.com/purerl/purescript-erl-lists.git";
      rev = "dbff22cb1f3e4eb243baf6d2882fc5738047b26a";  # Resolved from tag v4.0.1
    };
    info = {
      version = "v4.0.1";
      dependencies = [ "prelude" "foldable-traversable" "unfoldable" "filterable" "tuples" ];
    };
  };

  "erl-logger" = {
    src.git = {
      repo = "https://github.com/id3as/purescript-erl-logger.git";
      rev = "0f71204441e17db5dd9a2a6efb0f5be9840e8360";  # Resolved from tag v0.0.3
    };
    info = {
      version = "v0.0.3";
      dependencies = [ "prelude" "erl-atom" "erl-lists" "record" ];
    };
  };

  "erl-maps" = {
    src.git = {
      repo = "https://github.com/purerl/purescript-erl-maps.git";
      rev = "7157f6b568b9c317c02ee17ed771bd979af0d3fe";  # Resolved from tag v0.5.0
    };
    info = {
      version = "v0.5.0";
      dependencies = [ "erl-lists" "functions" "prelude" "tuples" "unfoldable" ];
    };
  };

  "erl-modules" = {
    src.git = {
      repo = "https://github.com/purerl/purescript-erl-modules.git";
      rev = "79ee9a4c35f798cc00f1bf35dba83e7aeaba4f2a";  # Resolved from tag v0.1.6
    };
    info = {
      version = "v0.1.6";
      dependencies = [ "erl-atom" "prelude" "strings" ];
    };
  };

  "erl-nativerefs" = {
    src.git = {
      repo = "https://github.com/id3as/purescript-erl-nativerefs.git";
      rev = "7dfde2195622b509a2e028cdecec3fd41226efff";  # Resolved from tag v0.1.0
    };
    info = {
      version = "v0.1.0";
      dependencies = [ "prelude" "effect" "erl-tuples" ];
    };
  };

  "erl-opentelemetry" = {
    src.git = {
      repo = "https://github.com/id3as/purescript-erl-opentelemetry.git";
      rev = "5ea4394222d92d9419e5e2489a45b3eb340b5325";  # Resolved from tag v0.0.1
    };
    info = {
      version = "v0.0.1";
      dependencies = [ "effect" "erl-atom" "erl-lists" "erl-maps" "erl-tuples" "erl-untagged-union" "maybe" "prelude" "tuples" "unsafe-reference" ];
    };
  };

  "erl-otp-types" = {
    src.git = {
      repo = "https://github.com/id3as/purescript-erl-otp-types.git";
      rev = "31a3d7c1581247679b3bc11012bb3a59fad9f9b9";  # Resolved from tag v0.0.2
    };
    info = {
      version = "v0.0.2";
      dependencies = [ "erl-atom" "erl-binary" "erl-kernel" "foreign" "prelude" "unsafe-reference" ];
    };
  };

  "erl-pinto" = {
    src.git = {
      repo = "https://github.com/id3as/purescript-erl-pinto.git";
      rev = "3851bfe52f49f713ce0818c47597bfb888c56544";  # Resolved from tag v0.2.0
    };
    info = {
      version = "v0.2.0";
      dependencies = [ "erl-process" "erl-lists" "erl-atom" "erl-kernel" "datetime" "erl-tuples" "erl-modules" "foreign" ];
    };
  };

  "erl-process" = {
    src.git = {
      repo = "https://github.com/purerl/purescript-erl-process.git";
      rev = "5eacc3a23626aed8c6036560139642122e9b8c9b";  # Resolved from tag v3.3.0
    };
    info = {
      version = "v3.3.0";
      dependencies = [ "datetime" "effect" "either" "foreign" "integers" "prelude" ];
    };
  };

  "erl-queue" = {
    src.git = {
      repo = "https://github.com/id3as/purescript-erl-queue.git";
      rev = "88625b148b51975f77f214f9555cfb2f7fd5cb15";  # Resolved from tag v0.0.2
    };
    info = {
      version = "v0.0.2";
      dependencies = [ "control" "either" "erl-lists" "filterable" "foldable-traversable" "lists" "maybe" "newtype" "nonempty" "prelude" "tuples" "unfoldable" ];
    };
  };

  "erl-ranch" = {
    src.git = {
      repo = "https://github.com/id3as/purescript-erl-ranch.git";
      rev = "1eda110f273339e19fc7e8d5dc6f738b0cbf547a";  # Resolved from tag v0.0.2
    };
    info = {
      version = "v0.0.2";
      dependencies = [ "convertable-options" "effect" "either" "erl-atom" "erl-kernel" "erl-lists" "erl-maps" "erl-otp-types" "erl-process" "erl-ssl" "erl-tuples" "exceptions" "foreign" "maybe" "prelude" "record" "typelevel-prelude" "unsafe-coerce" ];
    };
  };

  "erl-simplebus" = {
    src.git = {
      repo = "https://github.com/id3as/purescript-erl-simplebus.git";
      rev = "b5fcf28b4e193ba3eae5e47a0ac6c55320ed7885";  # Resolved from tag v0.0.3
    };
    info = {
      version = "v0.0.3";
      dependencies = [ "effect" "erl-process" "maybe" "newtype" "prelude" ];
    };
  };

  "erl-ssl" = {
    src.git = {
      repo = "https://github.com/id3as/purescript-erl-ssl.git";
      rev = "72a352ca24f7eab5a17db545940c0a070e250c73";  # Resolved from tag v0.0.2
    };
    info = {
      version = "v0.0.2";
      dependencies = [ "convertable-options" "datetime" "effect" "either" "maybe" "erl-atom" "erl-binary" "erl-lists" "erl-kernel" "erl-tuples" "erl-logger" "erl-otp-types" "foreign" "maybe" "partial" "prelude" "record" "unsafe-reference" ];
    };
  };

  "erl-stetson" = {
    src.git = {
      repo = "https://github.com/id3as/purescript-erl-stetson.git";
      rev = "4aa57d93747d15a550ccdefc8146f8c1979e1e1c";  # Resolved from tag v0.13.0
    };
    info = {
      version = "v0.13.0";
      dependencies = [ "erl-atom" "erl-binary" "erl-lists" "erl-maps" "erl-tuples" "erl-modules" "erl-cowboy" "foreign" "maybe" "prelude" "transformers" "routing-duplex" ];
    };
  };

  "erl-test-eunit" = {
    src.git = {
      repo = "https://github.com/id3as/purescript-erl-test-eunit.git";
      rev = "1704c063e20f0d1a9bd723ffdf18c00700203569";  # Resolved from tag v0.0.4
    };
    info = {
      version = "v0.0.4";
      dependencies = [ "assert" "console" "debug" "erl-lists" "erl-tuples" "erl-atom" "foreign" "free" "prelude" "psci-support" ];
    };
  };

  "erl-tuples" = {
    src.git = {
      repo = "https://github.com/purerl/purescript-erl-tuples.git";
      rev = "4a54940fd9f2fc3f8f32cf24fa82e5523ad00922";  # Resolved from tag v3.3.1
    };
    info = {
      version = "v3.3.1";
      dependencies = [ "unfoldable" "tuples" ];
    };
  };

  "erl-untagged-union" = {
    src.git = {
      repo = "https://github.com/id3as/purescript-erl-untagged-union.git";
      rev = "781b2894f9ffcc91b7aea482e435bb9284596f62";  # Resolved from tag v0.0.2
    };
    info = {
      version = "v0.0.2";
      dependencies = [ "erl-atom" "erl-binary" "erl-lists" "erl-tuples" "foreign" "typelevel-prelude" "maybe" "partial" "prelude" "unsafe-coerce" "erl-process" ];
    };
  };

  "exceptions" = {
    src.git = {
      repo = "https://github.com/purerl/purescript-exceptions.git";
      rev = "e57e9598bc327f4e8301136e0af53335fbb1973f";  # Resolved from tag v5.0.0-erl1
    };
    info = {
      version = "v5.0.0-erl1";
      dependencies = [ "maybe" "either" "effect" ];
    };
  };

  "exists" = {
    src.git = {
      repo = "https://github.com/purescript/purescript-exists.git";
      rev = "c34820f8b2d15be29abdd5097c3d636f5df8f28c";  # Resolved from tag v5.1.0
    };
    info = {
      version = "v5.1.0";
      dependencies = [ "unsafe-coerce" ];
    };
  };

  "expect-inferred" = {
    src.git = {
      repo = "https://github.com/justinwoo/purescript-expect-inferred";
      rev = "e43dafbc2f8d25113d5d74121fe4f6cd8a328407";  # Resolved from tag v2.0.0
    };
    info = {
      version = "v2.0.0";
      dependencies = [ "prelude" "typelevel-prelude" ];
    };
  };

  "filterable" = {
    src.git = {
      repo = "https://github.com/purescript/purescript-filterable.git";
      rev = "0b9b0994704f29e75072e6b3e6b8658b93b35ab8";  # Resolved from tag v3.0.1
    };
    info = {
      version = "v3.0.1";
      dependencies = [ "arrays" "either" "foldable-traversable" "identity" "lists" "ordered-collections" ];
    };
  };

  "foldable-traversable" = {
    src.git = {
      repo = "https://github.com/purerl/purescript-foldable-traversable.git";
      rev = "444a611d64800a82259b9c22999330b6a7b48a3d";  # Resolved from tag v5.0.1-erl1
    };
    info = {
      version = "v5.0.1-erl1";
      dependencies = [ "bifunctors" "const" "control" "either" "functors" "identity" "maybe" "newtype" "orders" "prelude" "tuples" ];
    };
  };

  "foreign" = {
    src.git = {
      repo = "https://github.com/purerl/purescript-foreign.git";
      rev = "91f2e6c9950db6bcab673b45f6ebd89305e97728";  # Resolved from tag v6.0.1-erl1
    };
    info = {
      version = "v6.0.1-erl1";
      dependencies = [ "either" "functions" "identity" "integers" "lists" "maybe" "prelude" "strings" "transformers" ];
    };
  };

  "formatters" = {
    src.git = {
      repo = "https://github.com/id3as/purescript-formatters";
      rev = "56644171592f41022957cfdf011ea854daad2722";  # Resolved from tag v5.0.1-erl1
    };
    info = {
      version = "v5.0.1-erl1";
      dependencies = [ "arrays" "bifunctors" "control" "datetime" "either" "enums" "foldable-traversable" "integers" "lists" "math" "maybe" "newtype" "numbers" "ordered-collections" "parsing" "partial" "prelude" "psci-support" "strings" "transformers" "tuples" ];
    };
  };

  "free" = {
    src.git = {
      repo = "https://github.com/purescript/purescript-free.git";
      rev = "3c90f01172329052d9af6ef3114c951f752221e3";  # Resolved from tag v6.0.1
    };
    info = {
      version = "v6.0.1";
      dependencies = [ "catenable-lists" "control" "distributive" "either" "exists" "foldable-traversable" "invariant" "lazy" "maybe" "prelude" "tailrec" "transformers" "tuples" "unsafe-coerce" ];
    };
  };

  "functions" = {
    src.git = {
      repo = "https://github.com/purerl/purescript-functions.git";
      rev = "6f0854f056b5295835db2cc3d06bf8763c181536";  # Resolved from tag v5.0.0-erl1
    };
    info = {
      version = "v5.0.0-erl1";
      dependencies = [ "prelude" ];
    };
  };

  "functors" = {
    src.git = {
      repo = "https://github.com/purescript/purescript-functors.git";
      rev = "56e9889b6939264c4707ad48356419a147493c3e";  # Resolved from tag v4.1.1
    };
    info = {
      version = "v4.1.1";
      dependencies = [ "bifunctors" "const" "contravariant" "control" "distributive" "either" "invariant" "maybe" "newtype" "prelude" "profunctor" "tuples" "unsafe-coerce" ];
    };
  };

  "gen" = {
    src.git = {
      repo = "https://github.com/purescript/purescript-gen.git";
      rev = "85c369f56545a3de834b7e7475a56bc9193bb4b4";  # Resolved from tag v3.0.0
    };
    info = {
      version = "v3.0.0";
      dependencies = [ "either" "foldable-traversable" "identity" "maybe" "newtype" "nonempty" "prelude" "tailrec" "tuples" "unfoldable" ];
    };
  };

  "graphs" = {
    src.git = {
      repo = "https://github.com/purescript/purescript-graphs.git";
      rev = "5d03edc58444595d7ac0ea6df3dc689ec6021b01";  # Resolved from tag v5.0.0
    };
    info = {
      version = "v5.0.0";
      dependencies = [ "catenable-lists" "ordered-collections" ];
    };
  };

  "heterogeneous" = {
    src.git = {
      repo = "https://github.com/natefaubion/purescript-heterogeneous.git";
      rev = "550445cf7932e158395423fc087cdc05bab41c40";  # Resolved from tag v0.5.1
    };
    info = {
      version = "v0.5.1";
      dependencies = [ "prelude" "record" "tuples" "functors" "variant" "either" ];
    };
  };

  "identity" = {
    src.git = {
      repo = "https://github.com/purescript/purescript-identity.git";
      rev = "5c150ac5ee4fa6f145932f6322a1020463dae8e9";  # Resolved from tag v5.0.0
    };
    info = {
      version = "v5.0.0";
      dependencies = [ "control" "invariant" "newtype" "prelude" ];
    };
  };

  "integers" = {
    src.git = {
      repo = "https://github.com/purerl/purescript-integers.git";
      rev = "5549373344321575727cc1b3526ee946cff77a43";  # Resolved from tag v5.0.0-erl1
    };
    info = {
      version = "v5.0.0-erl1";
      dependencies = [ "math" "maybe" "numbers" "prelude" ];
    };
  };

  "invariant" = {
    src.git = {
      repo = "https://github.com/purescript/purescript-invariant.git";
      rev = "c421b49dec7a1511073bb408a08bdd8c9d17d7b1";  # Resolved from tag v5.0.0
    };
    info = {
      version = "v5.0.0";
      dependencies = [ "control" "prelude" ];
    };
  };

  "js-uri" = {
    src.git = {
      repo = "https://github.com/purerl/purescript-js-uri.git";
      rev = "943ae2cd2cf81e62a658e89ab27cca7754a0fadd";  # Resolved from tag v2.0.0-erl1
    };
    info = {
      version = "v2.0.0-erl1";
      dependencies = [ "functions" "maybe" ];
    };
  };

  "lazy" = {
    src.git = {
      repo = "https://github.com/purerl/purescript-lazy.git";
      rev = "11a8a4fa99ef88daf36458b163010179c633168e";  # Resolved from tag v5.0.0-erl1
    };
    info = {
      version = "v5.0.0-erl1";
      dependencies = [ "control" "foldable-traversable" "invariant" "prelude" ];
    };
  };

  "lcg" = {
    src.git = {
      repo = "https://github.com/purescript/purescript-lcg.git";
      rev = "8fb2eb16bbba2cee1d115a6729659ac649da811b";  # Resolved from tag v3.0.0
    };
    info = {
      version = "v3.0.0";
      dependencies = [ "effect" "integers" "math" "maybe" "partial" "prelude" "random" ];
    };
  };

  "lists" = {
    src.git = {
      repo = "https://github.com/purescript/purescript-lists.git";
      rev = "f07a986d14df3dcea57067b7f10fbbca4783be00";  # Resolved from tag v6.0.1
    };
    info = {
      version = "v6.0.1";
      dependencies = [ "bifunctors" "control" "foldable-traversable" "lazy" "maybe" "newtype" "nonempty" "partial" "prelude" "tailrec" "tuples" "unfoldable" ];
    };
  };

  "math" = {
    src.git = {
      repo = "https://github.com/purerl/purescript-math.git";
      rev = "c4760c2620980dbd7168b17ed21dfab12b8c5b39";  # Resolved from tag v3.0.0-erl1
    };
    info = {
      version = "v3.0.0-erl1";
      dependencies = [  ];
    };
  };

  "maybe" = {
    src.git = {
      repo = "https://github.com/purescript/purescript-maybe.git";
      rev = "8e96ca0187208e78e8df6a464c281850e5c9400c";  # Resolved from tag v5.0.0
    };
    info = {
      version = "v5.0.0";
      dependencies = [ "control" "invariant" "newtype" "prelude" ];
    };
  };

  "media-types" = {
    src.git = {
      repo = "https://github.com/purescript-contrib/purescript-media-types.git";
      rev = "b6efa4c1e6808b31f399d8030b5938acec87cb48";  # Resolved from tag v5.0.0
    };
    info = {
      version = "v5.0.0";
      dependencies = [ "prelude" "newtype" ];
    };
  };

  "metadata" = {
    src.git = {
      repo = "https://github.com/spacchetti/purescript-metadata.git";
      rev = "6529ece5167934712454d9b5d9814b3e663a2c85";  # Resolved from tag v0.15.0
    };
    info = {
      version = "v0.15.0";
      dependencies = [  ];
    };
  };

  "newtype" = {
    src.git = {
      repo = "https://github.com/purescript/purescript-newtype.git";
      rev = "7b292fcd2ac7c4a25d7a7a8d3387d0ee7de89b13";  # Resolved from tag v4.0.0
    };
    info = {
      version = "v4.0.0";
      dependencies = [ "prelude" "safe-coerce" ];
    };
  };

  "nonempty" = {
    src.git = {
      repo = "https://github.com/purescript/purescript-nonempty.git";
      rev = "d3e91e3d6e06e5bdcc5b2c21c8e5d0f9b946bb9e";  # Resolved from tag v6.0.0
    };
    info = {
      version = "v6.0.0";
      dependencies = [ "control" "foldable-traversable" "maybe" "prelude" "tuples" "unfoldable" ];
    };
  };

  "nullable" = {
    src.git = {
      repo = "https://github.com/purerl/purescript-nullable.git";
      rev = "22736994306a9b4568cbc610640c61e5976d01ea";  # Resolved from tag v5.0.0-erl1
    };
    info = {
      version = "v5.0.0-erl1";
      dependencies = [ "maybe" "functions" ];
    };
  };

  "numbers" = {
    src.git = {
      repo = "https://github.com/purerl/purescript-numbers.git";
      rev = "5446bc018f2970d91a8573c3424bba0b59305a21";  # Resolved from tag v8.0.0-erl1
    };
    info = {
      version = "v8.0.0-erl1";
      dependencies = [ "functions" "math" "maybe" ];
    };
  };

  "ordered-collections" = {
    src.git = {
      repo = "https://github.com/purerl/purescript-ordered-collections.git";
      rev = "8f9fdc347282cc952241c2f38bd98552caf4a25a";  # Resolved from tag v2.0.2-erl1
    };
    info = {
      version = "v2.0.2-erl1";
      dependencies = [ "arrays" "foldable-traversable" "gen" "lists" "maybe" "partial" "prelude" "tailrec" "tuples" "unfoldable" "unsafe-coerce" ];
    };
  };

  "orders" = {
    src.git = {
      repo = "https://github.com/purescript/purescript-orders.git";
      rev = "c25b7075426cf82bcb960495f28d2541c9a75510";  # Resolved from tag v5.0.0
    };
    info = {
      version = "v5.0.0";
      dependencies = [ "newtype" "prelude" ];
    };
  };

  "parallel" = {
    src.git = {
      repo = "https://github.com/purescript/purescript-parallel.git";
      rev = "16b38a2e148639b04ae67e0ce63cc220da8857f7";  # Resolved from tag v5.0.0
    };
    info = {
      version = "v5.0.0";
      dependencies = [ "control" "effect" "either" "foldable-traversable" "functors" "maybe" "newtype" "prelude" "profunctor" "refs" "transformers" ];
    };
  };

  "parsing" = {
    src.git = {
      repo = "https://github.com/id3as/purescript-parsing";
      rev = "ace4a4e478667014014035372e2e4ec7786e96a6";  # Resolved from tag v6.0.2-erl1
    };
    info = {
      version = "v6.0.2-erl1";
      dependencies = [ "arrays" "assert" "console" "control" "effect" "either" "foldable-traversable" "identity" "integers" "lists" "math" "maybe" "newtype" "prelude" "psci-support" "strings" "tailrec" "transformers" "tuples" "unicode" ];
    };
  };

  "partial" = {
    src.git = {
      repo = "https://github.com/purerl/purescript-partial.git";
      rev = "6fe347eb3a36c70cacd4aeb581b5748a9d5035aa";  # Resolved from tag v3.0.0-erl2
    };
    info = {
      version = "v3.0.0-erl2";
      dependencies = [  ];
    };
  };

  "pathy" = {
    src.git = {
      repo = "https://github.com/id3as/purescript-pathy";
      rev = "3d9b2f24b05c2b5ac166d682dc4b61d42a75011e";  # Resolved from tag v8.1.0-erl1
    };
    info = {
      version = "v8.1.0-erl1";
      dependencies = [ "arrays" "either" "exceptions" "foldable-traversable" "gen" "identity" "lists" "maybe" "newtype" "nonempty" "partial" "prelude" "psci-support" "strings" "tailrec" "tuples" "typelevel-prelude" "unsafe-coerce" ];
    };
  };

  "prelude" = {
    src.git = {
      repo = "https://github.com/purerl/purescript-prelude.git";
      rev = "75a86f361270985ae983b59d4a69c0513b7f1cb1";  # Resolved from tag v5.0.1-erl1
    };
    info = {
      version = "v5.0.1-erl1";
      dependencies = [  ];
    };
  };

  "profunctor" = {
    src.git = {
      repo = "https://github.com/purescript/purescript-profunctor.git";
      rev = "4551b8e437a00268cc9b687cbe691d75e812e82b";  # Resolved from tag v5.0.0
    };
    info = {
      version = "v5.0.0";
      dependencies = [ "control" "distributive" "either" "exists" "invariant" "newtype" "prelude" "tuples" ];
    };
  };

  "profunctor-lenses" = {
    src.git = {
      repo = "https://github.com/purerl/purescript-profunctor-lenses.git";
      rev = "8e858fa26d937b0e792782a209d214d52d7be914";  # Resolved from tag v8.0.0-erl1
    };
    info = {
      version = "v8.0.0-erl1";
      dependencies = [ "arrays" "bifunctors" "const" "control" "distributive" "either" "foldable-traversable" "functors" "identity" "lists" "maybe" "newtype" "ordered-collections" "partial" "prelude" "profunctor" "record" "transformers" "tuples" "erl-maps" ];
    };
  };

  "psci-support" = {
    src.git = {
      repo = "https://github.com/purescript/purescript-psci-support.git";
      rev = "f26fe8266a63494080476333e22f971404ea8846";  # Resolved from tag v5.0.0
    };
    info = {
      version = "v5.0.0";
      dependencies = [ "console" "effect" "prelude" ];
    };
  };

  "quickcheck" = {
    src.git = {
      repo = "https://github.com/purerl/purescript-quickcheck.git";
      rev = "e633f97704bdccc92ad1db60d0e2897a6f98ef56";  # Resolved from tag v7.1.0-erl1
    };
    info = {
      version = "v7.1.0-erl1";
      dependencies = [ "arrays" "console" "control" "effect" "either" "enums" "exceptions" "foldable-traversable" "gen" "identity" "integers" "lazy" "lcg" "lists" "math" "maybe" "newtype" "nonempty" "partial" "prelude" "record" "strings" "tailrec" "transformers" "tuples" "unfoldable" ];
    };
  };

  "quickcheck-laws" = {
    src.git = {
      repo = "https://github.com/purescript-contrib/purescript-quickcheck-laws";
      rev = "464597522e5e001adc2619676584871f423b9ea0";  # Resolved from tag v6.0.1
    };
    info = {
      version = "v6.0.1";
      dependencies = [ "arrays" "console" "control" "effect" "either" "enums" "foldable-traversable" "identity" "lists" "maybe" "newtype" "prelude" "quickcheck" "tuples" ];
    };
  };

  "random" = {
    src.git = {
      repo = "https://github.com/purerl/purescript-random.git";
      rev = "2aca9dd987ba6cec9a01809833130970d024b4de";  # Resolved from tag v5.0.0-erl1
    };
    info = {
      version = "v5.0.0-erl1";
      dependencies = [ "effect" "integers" "math" ];
    };
  };

  "record" = {
    src.git = {
      repo = "https://github.com/purerl/purescript-record.git";
      rev = "539eb726cd7bdfcd95bf8bca20b3aed993006919";  # Resolved from tag v3.0.0-erl1
    };
    info = {
      version = "v3.0.0-erl1";
      dependencies = [ "functions" "typelevel-prelude" "unsafe-coerce" ];
    };
  };

  "record-prefix" = {
    src.git = {
      repo = "https://github.com/dariooddenino/purescript-record-prefix.git";
      rev = "0215cd35d8479f3ce329a9b60737ff2add814531";  # Resolved from tag v1.0.0
    };
    info = {
      version = "v1.0.0";
      dependencies = [ "prelude" "heterogeneous" "console" "typelevel-prelude" ];
    };
  };

  "refs" = {
    src.git = {
      repo = "https://github.com/purerl/purescript-refs.git";
      rev = "1a921991d2c0900c4582d69586bfbd5ce3d53952";  # Resolved from tag v5.0.0-erl2
    };
    info = {
      version = "v5.0.0-erl2";
      dependencies = [ "effect" "prelude" ];
    };
  };

  "routing-duplex" = {
    src.git = {
      repo = "https://github.com/natefaubion/purescript-routing-duplex.git";
      rev = "34963d57ec67004a0683aaf3002929affdc3962d";  # Resolved from tag v0.5.0
    };
    info = {
      version = "v0.5.0";
      dependencies = [ "arrays" "control" "either" "js-uri" "lazy" "numbers" "prelude" "profunctor" "record" "strings" "typelevel-prelude" ];
    };
  };

  "safe-coerce" = {
    src.git = {
      repo = "https://github.com/purescript/purescript-safe-coerce.git";
      rev = "e719defd227d932da067a1f0d62a60b3d3ff3637";  # Resolved from tag v1.0.0
    };
    info = {
      version = "v1.0.0";
      dependencies = [ "unsafe-coerce" ];
    };
  };

  "semirings" = {
    src.git = {
      repo = "https://github.com/purescript/purescript-semirings.git";
      rev = "c162896dc40ba8d1268c663a352ee5e108979a2c";  # Resolved from tag v6.0.0
    };
    info = {
      version = "v6.0.0";
      dependencies = [ "foldable-traversable" "lists" "newtype" "prelude" ];
    };
  };

  "sequences" = {
    src.git = {
      repo = "https://github.com/hdgarrood/purescript-sequences.git";
      rev = "5b6b210887aeac4ca60e5bd639b6b811e0487159";  # Resolved from tag v3.0.2
    };
    info = {
      version = "v3.0.2";
      dependencies = [ "prelude" "unsafe-coerce" "partial" "unfoldable" "lazy" "arrays" "profunctor" "maybe" "tuples" "newtype" ];
    };
  };

  "simple-json-generics" = {
    src.git = {
      repo = "https://github.com/justinwoo/purescript-simple-json-generics";
      rev = "a09475cd830b140fad4eb3e79c70662d54abe382";  # Resolved from tag v0.1.0
    };
    info = {
      version = "v0.1.0";
      dependencies = [ "prelude" "simple-json" ];
    };
  };

  "strings" = {
    src.git = {
      repo = "https://github.com/purerl/purescript-strings.git";
      rev = "82ee15ccdc9d37238e4a57edbb74b135bbe2315a";  # Resolved from tag v5.0.0-erl2
    };
    info = {
      version = "v5.0.0-erl2";
      dependencies = [ "arrays" "control" "either" "enums" "foldable-traversable" "gen" "integers" "maybe" "newtype" "nonempty" "partial" "prelude" "tailrec" "tuples" "unfoldable" "unsafe-coerce" ];
    };
  };

  "tailrec" = {
    src.git = {
      repo = "https://github.com/purerl/purescript-tailrec.git";
      rev = "a865d0787fef54e7350d8c1e8d2e9ed94fae47b7";  # Resolved from tag v5.0.1-erl1
    };
    info = {
      version = "v5.0.1-erl1";
      dependencies = [ "bifunctors" "effect" "either" "identity" "maybe" "partial" "prelude" "refs" ];
    };
  };

  "these" = {
    src.git = {
      repo = "https://github.com/purescript-contrib/purescript-these.git";
      rev = "38dcf86a9bd772091e1153f2f1c13223703599b7";  # Resolved from tag v5.0.0
    };
    info = {
      version = "v5.0.0";
      dependencies = [ "arrays" "gen" "lists" "quickcheck" "quickcheck-laws" "tuples" ];
    };
  };

  "transformers" = {
    src.git = {
      repo = "https://github.com/purescript/purescript-transformers.git";
      rev = "1e5d4193b38c613c97ea1ebdb721c6b94cd8c50a";  # Resolved from tag v5.2.0
    };
    info = {
      version = "v5.2.0";
      dependencies = [ "control" "distributive" "effect" "either" "exceptions" "foldable-traversable" "identity" "lazy" "maybe" "newtype" "prelude" "tailrec" "tuples" "unfoldable" ];
    };
  };

  "tuples" = {
    src.git = {
      repo = "https://github.com/purescript/purescript-tuples.git";
      rev = "04630b287d453158b2b95c4be695dfe9fdd83a12";  # Resolved from tag v6.0.1
    };
    info = {
      version = "v6.0.1";
      dependencies = [ "control" "invariant" "prelude" ];
    };
  };

  "type-equality" = {
    src.git = {
      repo = "https://github.com/purescript/purescript-type-equality.git";
      rev = "f7644468f22ed267a15d398173d234fa6f45e2e0";  # Resolved from tag v4.0.0
    };
    info = {
      version = "v4.0.0";
      dependencies = [  ];
    };
  };

  "typelevel-prelude" = {
    src.git = {
      repo = "https://github.com/purescript/purescript-typelevel-prelude.git";
      rev = "83ddcdb23d06c8d5ea6196596a70438f42cd4afd";  # Resolved from tag v6.0.0
    };
    info = {
      version = "v6.0.0";
      dependencies = [ "prelude" "type-equality" ];
    };
  };

  "undefinable" = {
    src.git = {
      repo = "https://github.com/purerl/purescript-undefinable.git";
      rev = "e0a8cc54473d69536cdbb48db5ec926b39fc5dbb";  # Resolved from tag v4.0.0-erl1
    };
    info = {
      version = "v4.0.0-erl1";
      dependencies = [ "maybe" "functions" ];
    };
  };

  "unfoldable" = {
    src.git = {
      repo = "https://github.com/purerl/purescript-unfoldable.git";
      rev = "5d3b6ac48757c9aa93f6410f86266034fd510599";  # Resolved from tag v5.0.0-erl1
    };
    info = {
      version = "v5.0.0-erl1";
      dependencies = [ "foldable-traversable" "maybe" "partial" "prelude" "tuples" ];
    };
  };

  "unicode" = {
    src.git = {
      repo = "https://github.com/id3as/purescript-unicode";
      rev = "b52d07074bffd3f7253c98a72c92c4cd3d125f5a";  # Resolved from tag v5.0.0-erl1
    };
    info = {
      version = "v5.0.0-erl1";
      dependencies = [ "foldable-traversable" "maybe" "psci-support" "strings" ];
    };
  };

  "unsafe-coerce" = {
    src.git = {
      repo = "https://github.com/purerl/purescript-unsafe-coerce.git";
      rev = "7150d261d40cd92112e8c2064124c5682627f137";  # Resolved from tag v5.0.0-erl1
    };
    info = {
      version = "v5.0.0-erl1";
      dependencies = [  ];
    };
  };

  "unsafe-reference" = {
    src.git = {
      repo = "https://github.com/purerl/purescript-unsafe-reference.git";
      rev = "464ee74d0c3ef50e7b661c13399697431f4b6251";  # Resolved from tag v4.0.0-erl1
    };
    info = {
      version = "v4.0.0-erl1";
      dependencies = [ "prelude" ];
    };
  };

  "uri" = {
    src.git = {
      repo = "https://github.com/purescript-contrib/purescript-uri";
      rev = "d56b9c24933e40b523a0d64e272f3b9f603a1f7c";  # Resolved from tag v8.0.1
    };
    info = {
      version = "v8.0.1";
      dependencies = [ "arrays" "integers" "js-uri" "numbers" "parsing" "prelude" "profunctor-lenses" "these" "transformers" "unfoldable" ];
    };
  };

  "validation" = {
    src.git = {
      repo = "https://github.com/purescript/purescript-validation.git";
      rev = "2d50284b192e71c9ca6aff87747b0d980c1ca657";  # Resolved from tag v5.0.0
    };
    info = {
      version = "v5.0.0";
      dependencies = [ "bifunctors" "control" "either" "foldable-traversable" "newtype" "prelude" ];
    };
  };

  "variant" = {
    src.git = {
      repo = "https://github.com/natefaubion/purescript-variant.git";
      rev = "3f12411ede5edd342d25340c1babce9ae81d6793";  # Resolved from tag v7.0.3
    };
    info = {
      version = "v7.0.3";
      dependencies = [ "enums" "lists" "maybe" "partial" "prelude" "record" "tuples" "unsafe-coerce" ];
    };
  };

}
