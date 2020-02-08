{
  webserver = {
    deployment.targetHost = "stage.thought2.de";
    imports = [ ./hardware-configuration.nix ];
    boot.loader.grub.device = "/dev/sda";
  };
}
