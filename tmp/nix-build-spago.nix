{ pkgs ? import <nixpkgs> { }, ... }:
with builtins;
let

  replace = f: regex: string:
    foldl' (x: y: x + y) ""
    (map (x: if isString x then x else f x) (split regex string));

  resolveDhall = dhallCode:
    let
      regex = "(http[^ ]+) sha256:([^ ]+)";
      matcher = matches:
        readFile (fetchurl {
          url = elemAt matches 0;
          hash = elemAt matches 1;
        });
    in replace matcher regex dhallCode;

  #(builtins.readFile ./packages.dhall)

in { inherit spago2nix; }
