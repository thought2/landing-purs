let
  sources = import ./nix/sources.nix;

  nixpkgs = import sources.nixpkgs { };

in import ./network-impl.nix { runCommand = nixpkgs.runCommand; }
