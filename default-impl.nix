{ runCommand, mkDerivation, nixfmt, spago, writeShellScriptBin, purs, yarn2nix
, yarn, spago2nix, fetchgit, make, bash, nix-gitignore, dhall, git, nodejs }:

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
    publishBinsFor = [ "purescript-psa" "parcel" ];
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
