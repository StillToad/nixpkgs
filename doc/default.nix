{ pkgs ? (import ./.. { }), nixpkgs ? { }}:
let
  inherit (pkgs) lib callPackage;
  fs = lib.fileset;

  common = import ./common.nix;

  lib-docs = callPackage ./doc-support/lib-function-docs.nix {
    inherit nixpkgs;
  };

  epub = callPackage ./doc-support/epub.nix { };

  # NB: This file describes the Nixpkgs manual, which happens to use module docs infra originally developed for NixOS.
  optionsDoc = callPackage ./doc-support/options-doc.nix { };

  pythonInterpreterTable = pkgs.callPackage ./doc-support/python-interpreter-table.nix {};

in pkgs.stdenv.mkDerivation {
  name = "nixpkgs-manual";

  nativeBuildInputs = with pkgs; [
    nixos-render-docs
  ];

  src = fs.toSource {
    root = ./.;
    fileset = fs.unions [
      (fs.fileFilter (file:
        file.hasExt "md"
        || file.hasExt "md.in"
      ) ./.)
      ./style.css
      ./anchor-use.js
      ./anchor.min.js
      ./manpage-urls.json
    ];
  };

  postPatch = ''
    ln -s ${optionsDoc.optionsJSON}/share/doc/nixos/options.json ./config-options.json
  '';

  buildPhase = ''
    substituteInPlace ./languages-frameworks/python.section.md \
      --subst-var-by python-interpreter-table "$(<"${pythonInterpreterTable}")"

    cat \
      ./functions/library.md.in \
      ${lib-docs}/index.md \
      > ./functions/library.md
    substitute ./manual.md.in ./manual.md \
      --replace-fail '@MANUAL_VERSION@' '${pkgs.lib.version}'

    mkdir -p out/media

    mkdir -p out/highlightjs
    cp -t out/highlightjs \
      ${pkgs.documentation-highlighter}/highlight.pack.js \
      ${pkgs.documentation-highlighter}/LICENSE \
      ${pkgs.documentation-highlighter}/mono-blue.css \
      ${pkgs.documentation-highlighter}/loader.js

    cp -t out ./style.css ./anchor.min.js ./anchor-use.js

    nixos-render-docs manual html \
      --manpage-urls ./manpage-urls.json \
      --revision ${pkgs.lib.trivial.revisionWithDefault (pkgs.rev or "master")} \
      --stylesheet style.css \
      --stylesheet highlightjs/mono-blue.css \
      --script ./highlightjs/highlight.pack.js \
      --script ./highlightjs/loader.js \
      --script ./anchor.min.js \
      --script ./anchor-use.js \
      --toc-depth 1 \
      --section-toc-depth 1 \
      manual.md \
      out/index.html
  '';

  installPhase = ''
    dest="$out/${common.outputPath}"
    mkdir -p "$(dirname "$dest")"
    mv out "$dest"
    mv "$dest/index.html" "$dest/${common.indexPath}"

    cp ${epub} "$dest/nixpkgs-manual.epub"

    mkdir -p $out/nix-support/
    echo "doc manual $dest ${common.indexPath}" >> $out/nix-support/hydra-build-products
    echo "doc manual $dest nixpkgs-manual.epub" >> $out/nix-support/hydra-build-products
  '';

  passthru = {
    inherit pythonInterpreterTable;
    tests.manpage-urls = callPackage ./tests/manpage-urls.nix { };
  };
}
