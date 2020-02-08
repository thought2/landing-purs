let
  sources = import ./nix/sources.nix;

  nixpkgs = import sources.nixpkgs { };

  easy-purescript-nix = import sources.easy-purescript-nix { pkgs = nixpkgs; };

  yarn2nix' = import sources.yarn2nix { pkgs = nixpkgs; };

in { mkDerivation ? nixpkgs.stdenv.mkDerivation, nixfmt ? nixpkgs.nixfmt
, spago ? easy-purescript-nix.spago
, writeShellScriptBin ? nixpkgs.writeShellScriptBin
, purs ? easy-purescript-nix.purs-0_13_4, yarn2nix ? yarn2nix'
, yarn ? nixpkgs.yarn, runCommand ? nixpkgs.runCommand
, spago2nix ? easy-purescript-nix.spago2nix, fetchgit ? nixpkgs.fetchgit
, make ? nixpkgs.gnumake, bash ? nixpkgs.bash
, nix-gitignore ? nixpkgs.nix-gitignore, dhall ? nixpkgs.dhall
, git ? nixpkgs.git, nodejs ? nixpkgs.nodejs, }:
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

  spagoPkgs = let
    importSpagoPackages = path:
      import "${path}/spago-packages.nix" {
        pkgs = {
          stdenv = { inherit mkDerivation; };
          inherit fetchgit;
          inherit runCommand;
        };
      };
  in {
    src = importSpagoPackages ./src;
    test = importSpagoPackages ./test;
  };

  cleanSrc = runCommand "src" { } ''
    mkdir $out
    cp -r ${nix-gitignore.gitignoreSource [ ] ./.}/* -t $out
    ln -s ${yarnModules}/node_modules $out/node_modules
  '';

  make' = writeShellScriptBin "make" ''
    ${make}/bin/make SHELL="${bash}/bin/bash -O globstar -O extglob" $@
  '';

in mkDerivation {
  name = "landing-purs";
  shellHook = "PATH=$PATH:${yarnPackage}/bin";
  buildInputs = [ nixfmt spago purs yarn spago2nix make' dhall git nodejs ];
  buildCommand = ''
    TMP=`mktemp -d`

    cd $TMP

    git init

    PATH=$PATH:${yarnPackage}/bin

    cp -r ${cleanSrc}/* .

    make check-format

    rm -rf .spago dist output
    bash ${spagoPkgs.test.installSpagoStyle}
    make build-test
    make check-test

    rm -rf .spago dist output
    bash ${spagoPkgs.src.installSpagoStyle}
    make build-src

    mkdir $out
    cp -r dist/* -t $out
  '';
}
