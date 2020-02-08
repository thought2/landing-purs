TARGET=$1

nix-env -i nixops
nixops delete --all --force
nixops create src/nix/network.nix src/nix/network-$TARGET.nix -d $TARGET
nixops deploy -d $TARGET