{ pkgs }:
let
  webDirs = {
    landing = import (pkgs.fetchgit {
      url = "https://github.com/thought2/landing-purs.git";
      rev = "5e9947ca121c571c11d87dc085177650abb89265";
      sha256 = "1crsk540yv9qap17n95zfbl0b1i2gl9g2lk3bgpcjvpcq38mmr7i";
    }) { inherit pkgs; };

  };
in {

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
    #locations = locationsPublic // locationsPrivate;
    #basicAuthFile = "/etc/.htpasswd";
  };

}
