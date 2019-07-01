{ pkgs ? import <nixpkgs> {}}:

let
  easy-purescript = import ./easy-purescript.nix;
  spagoPkgs = import ./spago-packages.nix { inherit pkgs; };
in
pkgs.stdenv.mkDerivation rec {
  name = "landing";
  src = ./.;

  buildInputs = [ easy-purescript.purs ];

  buildCommand =
  ''
    BUILD_DIR=$(mktemp -d);

    cp -r $src/* $BUILD_DIR

    cd $BUILD_DIR

    ${pkgs.bash}/bin/bash ${spagoPkgs.installSpagoStyle}

    shopt -s globstar
    ${pkgs.bash}/bin/bash ${spagoPkgs.buildSpagoStyle} src/**/*.purs

    mkdir $out
    cp -r $src/public/* -t $out

    ${easy-purescript.spago}/bin/spago bundle-app -n -s --to $out/index.js
  '';
}
