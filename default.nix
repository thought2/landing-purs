{ sources ? import ./nix/sources.nix }:
let
  overlay = _: pkgs: {
      inherit (import sources.easy-purescript-nix {inherit pkgs;})
        spago purs purty;
    };

  pkgs = import sources.nixpkgs { overlays = [ overlay ] ; config = {}; };

  spagoPkgs = import ./spago-packages.nix { inherit pkgs; };
in
pkgs.stdenv.mkDerivation rec {
  name = "landing";
  src = ./.;

  buildInputs = with pkgs; [bash spago purs purty];

  buildCommand = ''
    BUILD_DIR=$(mktemp -d);

    cp -r $src/* $BUILD_DIR

    cd $BUILD_DIR

    bash ${spagoPkgs.installSpagoStyle}

    shopt -s globstar
    bash ${spagoPkgs.buildSpagoStyle} $src/**/*.purs

    mkdir $out
    cp -r $src/public/* -t $out

    spago bundle-app -n -s --to $out/index.js
  '';
}
