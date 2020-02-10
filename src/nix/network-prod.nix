{
  webserver = { ... }: {
    deployment.targetHost = "thought2.de";

    boot.loader.grub.device = "/dev/sda";

    imports = [ <nixpkgs/nixos/modules/profiles/qemu-guest.nix> ];

    boot.initrd.availableKernelModules =
      [ "ata_piix" "uhci_hcd" "virtio_pci" "sd_mod" "sr_mod" ];
    boot.kernelModules = [ ];
    boot.extraModulePackages = [ ];

    fileSystems = {
      "/" = {
        device = "/dev/disk/by-label/nixos";
        fsType = "ext4";
      };
      "/boot" = { device = "/dev/disk/by-label/boot"; };
    };

    swapDevices = [ ];

    #nix.maxJobs = lib.mkDefault 2;

  };
}
