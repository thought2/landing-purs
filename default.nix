let
  sources = import ./nix/sources.nix;

  nixpkgs = import sources.nixpkgs { };

  easy-purescript-nix = import sources.easy-purescript-nix { pkgs = nixpkgs; };

  yarn2nix' = import sources.yarn2nix { pkgs = nixpkgs; };

in {

pkgs ? nixpkgs,

mkDerivation ? nixpkgs.stdenv.mkDerivation,

nixfmt ? nixpkgs.nixfmt,

spago ? easy-purescript-nix.spago,

writeShellScriptBin ? nixpkgs.writeShellScriptBin,

purs ? easy-purescript-nix.purs-0_13_4,

yarn2nix ? yarn2nix',

yarn ? nixpkgs.yarn,

runCommand ? nixpkgs.runCommand,

spago2nix ? easy-purescript-nix.spago2nix,

fetchgit ? nixpkgs.fetchgit,

make ? nixpkgs.gnumake,

bash ? nixpkgs.bash,

nix-gitignore ? nixpkgs.nix-gitignore,

dhall ? nixpkgs.dhall,

git ? nixpkgs.git,

nodejs ? nixpkgs.nodejs,

purty ? easy-purescript-nix.purty

}:
let
  packageJsonMeta = {
    pname = "landing-purs";
    name = "landing-purs";
    version = "1.0.0";
    packageJSON = ./package.json;
    yarnLock = ./yarn.lock;
  };

  yarnPackage = yarn2nix.mkYarnPackage (packageJsonMeta // {
    src = runCommand "src" { } ''
      mkdir $out
      ln -s ${./package.json} $out/package.json
      ln -s ${./yarn.lock} $out/yarn.lock
    '';
    publishBinsFor = [ "purescript-psa" "parcel" "prettier" ];
  });

  yarnModules = yarn2nix.mkYarnModules packageJsonMeta;

  cleanSrc = runCommand "src" { } ''
    mkdir $out
    cp -r ${nix-gitignore.gitignoreSource [ ] ./.}/* -t $out
    cd $out
    ${git}/bin/git init
    ${git}/bin/git add --all
    ln -s ${yarnModules}/node_modules $out/node_modules
  '';

  buildSrc = mkDerivation {
    name = "src";
    buildInputs = [ yarnPackage purs make' ];
    buildCommand = ''
      TMP=`mktemp -d`
      cd $TMP

      ln -s ${./Makefile} ./Makefile
      ln -s ${./src} ./src
      ln -s ${./public} ./public
      ln -s ${yarnModules}/node_modules node_modules

      bash ${(pkgs.callPackage ./src/spago-packages.nix { }).installSpagoStyle}
      make build-src

      mkdir $out
      cp -r dist/* -t $out
    '';
  };

  buildTest = mkDerivation {
    name = "test";
    buildInputs = [ yarnPackage purs make' nodejs ];
    buildCommand = ''
      TMP=`mktemp -d`
      cd $TMP

      ln -s ${./Makefile} ./Makefile
      ln -s ${./src} ./src
      ln -s ${./test} ./test

      bash ${(pkgs.callPackage ./test/spago-packages.nix { }).installSpagoStyle}

      make build-test
      make check-test

      ln -s output $out   
    '';
  };

  make' = writeShellScriptBin "make" ''
    ${make}/bin/make SHELL="${bash}/bin/bash -O globstar -O extglob" $@
  '';

in mkDerivation {
  name = "landing-purs";
  shellHook = "PATH=$PATH:${yarnPackage}/bin";
  buildInputs = [
    yarnPackage
    nixfmt
    spago
    purs
    yarn
    spago2nix
    make'
    dhall
    git
    nodejs
    purty
  ];
  buildCommand = ''
    cd ${cleanSrc}

    make check-format

    ls ${buildTest}

    ln -s ${buildSrc} $out
  '';
}
