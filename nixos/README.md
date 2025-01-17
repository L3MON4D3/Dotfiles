This directory contains nixOS configurations for machines I own.

The general structure is as follows:

* `flake.nix` is the root-flake and manages all inputs.
* `data/` contains an attribute set for miscellanious data that applies to all
  machines managed by the config.
* `machines/` contains hardware-related settings for all machines, eg. setup of
  mountpoints and cleaning of such.
* `modules/` contains reusable modules that manage services etc.

# Workflows
## Wireguard
`/etc/secrets` contains all public and private keys, generate
wg-netns-consumable files from them via

# Try: mount-unit with NetworkNamespacePath in Unit???

# Conventions
* netns-name matches name of wg_network.
* service-name is 
