{
  webserver = {
    # deployment.targetHost = "stage.thought2.de";
    deployment.targetEnv = "virtualbox";
    deployment.virtualbox.memorySize = 1024; # megabytes
    deployment.virtualbox.vcpu = 2; # number of cpus

    imports = [ ./hardware-configuration.nix ];
    boot.loader.grub.device = "/dev/sda";
  };
}
