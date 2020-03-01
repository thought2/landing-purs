let
  sources = import ../../nix/sources.nix;

  nixpkgs = import sources.nixpkgs { };

  tuesday-coding = sources.tuesday-coding;

  great-heights = sources.great-heights;

  blog = import sources.blog;

  pkgs = nixpkgs;

in { pkgs ? nixpkgs }:
let
  webDirs = {
    landing = import ../../default.nix { };
    loremPicsum = pkgs.stdenv.mkDerivation {
      name = "lorem-picsum";
      buildCommand = ''
        mkdir $out
        cp -r ${tuesday-coding}/2019-04-29/lorem-picsum/* -t $out
      '';
    };
    blog = blog;
    great-heights = great-heights;
  };

  mkLocation = { name, dir }: {
    "= /${name}" = { alias = dir; };
    "^~ /${name}/" = { alias = dir + "/"; };
  };

  locationsPublic = builtins.foldl' (x: y: x // y) { } (map mkLocation [
    {
      name = "lorem-picsum";
      dir = webDirs.loremPicsum;
    }
    {
      name = "blog";
      dir = webDirs.blog;
    }
    {
      name = "great-heights";
      dir = webDirs.great-heights;
    }
  ]);

in {

  nix.binaryCaches = [ "thought2.cachix.org" ];

  services.openssh = {
    enable = true;
    permitRootLogin = "yes";
    passwordAuthentication = false;
    challengeResponseAuthentication = false;
  };

  services.fail2ban.enable = true;

  users.extraUsers.root = {
    initialPassword = "root";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCqLuEaHpnBRDzqsiYC9Cv7+N62hyYQ6udABmGNz/wiHrtd4X5/QYAx0IoohGZ74nXH5atufqKDe/bWAdIxVibDImPdSCKS6b70pi3Zp0ZMqhEuLLlL+6mVFnkCA1lgHEa+s6jlD2qpuarvWQUNM0AIOEXLVdQ9FqWDUkOWBe1oH//VplkCgkCDnUNv/wxOA84BumjQBn9yF6EUb5+nmbciU9rl1C7qHbm7JuhH/FgWhBmnQFPyaea2ML0jxKXCdteSi5RzCu9XXHQO72VebQ2JvgkkU5oft9z0/fQ+wvBn1HIA2uiy3yGLc0piM1icd1PpsrnhDfW+HK2fq4SZM2Kx"
    ];
  };

  networking.firewall.allowedTCPPorts = [ 80 9418 ];

  services.nginx.enable = true;

  services.nginx.appendHttpConfig = ''
    server_names_hash_bucket_size 64;
  '';

  services.nginx.virtualHosts."stage.thought2.de" = {
    addSSL = true;
    enableACME = true;
    root = webDirs.landing;
    locations = locationsPublic;
    #basicAuthFile = "/etc/.htpasswd";
  };

  services.nginx.virtualHosts."thought2.de" = {
    addSSL = true;
    enableACME = true;
    root = webDirs.landing;
    locations = locationsPublic;
  };

}
