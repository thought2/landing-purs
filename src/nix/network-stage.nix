{
  webserver = { lib, ... }: {
    deployment.targetHost = "stage.thought2.de";
    imports = [ <nixpkgs/nixos/modules/profiles/qemu-guest.nix> ];
    boot.loader.grub.device = "/dev/sda";

    boot.initrd.availableKernelModules =
      [ "ata_piix" "uhci_hcd" "virtio_pci" "sd_mod" "sr_mod" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ ];
    boot.extraModulePackages = [ ];

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/9ccad8d5-8b0e-42a3-84da-34c812861309";
      fsType = "ext4";
    };

    fileSystems."/nix/store" = {
      device = "/nix/store";
      fsType = "none";
      options = [ "bind" ];
    };

    swapDevices = [ ];

    nix.maxJobs = lib.mkDefault 1;
  };
}
