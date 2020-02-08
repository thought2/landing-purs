let
  sources = import ../../nix/sources.nix;

  nixpkgs = import sources.nixpkgs { };

  pkgs = nixpkgs;

in {
  network.description = "Web server";

  webserver = { config, pkgs, ... }: import ./webserver.nix { inherit pkgs; };
}
