p:
with builtins;
let l = p.lib; in
rec {
  bundle =
    { entry-point
    , esbuild ? { }
    , main ? true
    }:
    let
      esbuild' = {
        log-level = "warning";
        outfile = "main.js";
      }
      // (if esbuild ? platform then { } else { format = "esm"; })
      // esbuild
      // { bundle = true; };

      flags = toString
        (l.mapAttrsToList
          (n: v:
            let
              process = val:
                let str = toString val; in
                if any (a: l.hasPrefix a str) [ ''"'' "$" "'" ]
                then str
                else l.escapeShellArg str;
            in
            if isBool v then
              if v then "--${n}" else ""
            else if isList v then
              map (a: "--${n}:${process a}") v
            else
              "--${n}=${process v}")
          esbuild'
        );

      build = "${p.esbuild}/bin/esbuild ${flags}";
    in
    if main then
      ''echo 'import { main } from "${entry-point}"; main()' | ${build}''
    else
      "${build} ${entry-point}";

  # Optimize CoreFn with purescript-backend-optimizer
  optimize-corefn =
    { optimizer
    , corefn-dir
    }:
    let
      opt-cmd = optimizer.cmd or "purs-backend-es";
      opt-args = toString (optimizer.args or [ ]);
      opt-path = if optimizer ? package then "${optimizer.package}/bin/" else "";
      directives =
        if optimizer ? directives
        then "--directives ${optimizer.directives}"
        else "";
    in
    "${opt-path}${opt-cmd} ${opt-args} ${directives} ${corefn-dir}";

  # Run backend compiler on a CoreFn directory (for per-package compilation)
  compile-backend =
    { backend
    , corefn-dir
    , optimizer ? null
    }:
    let
      backend-cmd = backend.cmd or "purerl";
      backend-args = toString (backend.args or [ ]);
      backend-path = if backend ? package then "${backend.package}/bin/" else "";

      # Run optimizer before backend if specified
      optimize-step =
        if optimizer != null then
          "${optimize-corefn { inherit optimizer corefn-dir; }} && "
        else
          "";

      # Allow custom command template, or use default
      backend-command =
        if backend ? command then
          backend.command
        else
          "${backend-path}${backend-cmd} ${backend-args} -o ${corefn-dir}";
    in
    "${optimize-step}${backend-command}";

  compile =
    purescript:
    { globs
    , output ? null
    , backend ? null
    , optimizer ? null
    , verbose-errors ? false
    , comments ? false
    , codegen ? null
    , no-prefix ? false
    , json-errors ? false
    , # New parameter: skip backend compilation (for incremental builds)
      skip-backend ? false
    }:
    let
      # Force corefn codegen when backend or optimizer is specified
      effective-codegen = if backend != null || optimizer != null then "corefn" else codegen;

      flags = toString [
        (make-flag "--output " output)
        (make-flag "--verbose-errors" verbose-errors)
        (make-flag "--comments" comments)
        (make-flag "--codegen " effective-codegen)
        (make-flag "--no-prefix" no-prefix)
        (make-flag "--json-errors" json-errors)
      ];

      purs-compile = "${purescript}/bin/purs compile ${flags} ${globs}";
      output-dir = if output != null then output else "output";

      # Optimizer step (runs on CoreFn)
      optimizer-step =
        if optimizer != null && !skip-backend then
          " && ${optimize-corefn { inherit optimizer; corefn-dir = output-dir; }}"
        else
          "";

      # Backend step (after optimizer if present)
      backend-compile =
        if backend != null && !skip-backend then
          let
            backend-cmd = backend.cmd or "purerl";
            backend-args = toString (backend.args or [ ]);
            # Ensure backend command is available in PATH
            backend-path = if backend ? package then "${backend.package}/bin/" else "";

            # Allow custom command, or use default with -o flag
            backend-command =
              if backend ? command then
                backend.command
              else
                "${backend-path}${backend-cmd} ${backend-args} -o ${output-dir}";
          in
          " && ${backend-command}"
        else
          "";
    in
    purs-compile + optimizer-step + backend-compile;

  repl = purescript:
    { globs
    , node-path ? null
    , node-opts ? null
    }:
    let
      flags = toString [
        (make-flag "--node-path " node-path)
        (make-flag "--node-opts " node-opts)
      ];
    in
    "${purescript}/bin/purs repl ${flags} ${globs}";

  make-flag = flag: arg:
    if arg == null || arg == false then
      ""
    else if arg == true then
      flag
    else
      flag + arg;

  make-name = unsanitized: version:
    let name = l.strings.sanitizeDerivationName unsanitized; in
    if version == null then
      { inherit name; }
    else
      {
        pname = name;
        inherit version;
      };

  node-command =
    { argv-1
    , import
    , nodejs
    , starting-arg ? 2
    }:
    ''
      ${nodejs}/bin/node \
        --input-type=module \
        -e 'import { main } from "${import}"; main()' \
        -- "${argv-1}" "''${@:${toString starting-arg}}"
    '';

  has-version = pkg:
    let info = pkg.purs-nix-info; in
    if info ? version then
      if info.version == null then
        l.warn "the package '${info.name}' is built with an old version of purs-nix, please update it if possible" false
      else
        true
    else
      false;

  package-info = pkg:
    let
      info = pkg.purs-nix-info;
      source-info =
        if info ? flake then
          ''
            echo "flake:   ${info.flake.url}"
            echo "package: ${info.flake.package or "default"}"''
        else if info ? repo then
          let
            more-info =
              if info ? rev
              then ''echo "commit:  ${info.rev}"''
              else ''echo "path:    ${pkg.src}"'';
          in
          ''
            echo "repo:    ${info.repo}"
            ${more-info}''
        else
          ''echo "path:    ${pkg.src}"'';
    in
    ''
      echo "name:    ${info.name}"
      echo "version: ${if has-version pkg then info.version else "none"}"
      ${source-info}
      echo "source:  ${pkg}"
    '';

  # subtract-string "abcdef" "abc" => "def"
  subtract-string = s1: s2:
    assert l.hasPrefix s2 s1;
    let
      l1 = stringLength s1;
      l2 = stringLength s2;
    in
    substring l2 (l1 - l2) s1;

  dep-name = dep: if typeOf dep == "string" then dep else dep.purs-nix-info.name;

  dep-info = ps-pkgs: dep:
    (if typeOf dep == "string"
    then ps-pkgs.${dep}
    else dep).purs-nix-info;

  # Convert a JSON package set (like purerl format) to purs-nix format
  # Supports both locked format (with rev) and unlocked format (with version tag)
  convert-json-package-set = json-packages: _:
    mapAttrs
      (_: pkg: {
        src.git = {
          inherit (pkg) repo;
        } // (
          # If package has rev (locked format), use it for pure evaluation
          # Otherwise use ref with tag (unlocked format, requires --impure)
          if pkg ? rev then
            { inherit (pkg) rev; }
          else
            { ref = "refs/tags/${pkg.version}"; }
        );
        info = {
          inherit (pkg) version dependencies;
        };
      })
      json-packages;

  # NEW THREE-STAGE ARCHITECTURE
  # =============================

  # Stage 1: Compile source to CoreFn (per-package, highly cacheable)
  compile-corefn-only = purescript:
    { globs
    , output ? null
    , verbose-errors ? false
    , comments ? false
    , no-prefix ? false
    , json-errors ? false
    }:
    let
      flags = toString [
        (make-flag "--output " output)
        (make-flag "--verbose-errors" verbose-errors)
        (make-flag "--comments" comments)
        (make-flag "--codegen " "corefn") # Always CoreFn only
        (make-flag "--no-prefix" no-prefix)
        (make-flag "--json-errors" json-errors)
      ];
    in
    "${purescript}/bin/purs compile ${flags} ${globs}";

  # Stage 2: Optimize CoreFn (whole-project, optional)
  optimize-corefn-directory =
    { optimizer
    , corefn-dir
    }:
    let
      opt-cmd = optimizer.cmd or "purs-backend-es";
      opt-args = toString (optimizer.args or [ "build" ]); # Default to "build" subcommand
      opt-path = if optimizer ? package then "${optimizer.package}/bin/" else "";

      # purs-backend-es CLI: purs-backend-es build --corefn-dir X --output-dir Y
      command =
        if optimizer ? command then
          optimizer.command
        else
          "${opt-path}${opt-cmd} ${opt-args} --corefn-dir ${corefn-dir} --output-dir ${corefn-dir}";
    in
    command;

  # Stage 3: Generate backend output (whole-project)
  compile-backend-directory =
    { backend
    , corefn-dir
    }:
    let
      backend-cmd = backend.cmd or "purerl";
      backend-args = toString (backend.args or [ ]);
      backend-path = if backend ? package then "${backend.package}/bin/" else "";

      # Allow custom command template, or use default
      backend-command =
        if backend ? command then
          backend.command
        else
          "${backend-path}${backend-cmd} ${backend-args} -o ${corefn-dir}";
    in
    backend-command;
}
