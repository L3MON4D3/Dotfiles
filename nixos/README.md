This directory contains my NixOS configuration.

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

## Wireguard
* netns-name matches name of wg_network.
* service-name is netns-`netns-name`.

## Custom packages
* provide via overlay as pkgs.l3mon.*. I think this makes a lot of sense since
  packages are included in pkgs-fixpoint-computation and can be overridden (not
  possible when maintaining in a separate attrset) and I don't have to worry
  about name-conflicts with packages in pkgs.

## Secrets
Provide secrets at runtime by referring to files in /var/secret.
Or, and this seems very flexible: use envsubst in an activationScript to
populate secrets via env-var into some template-file!
See `profiles/radarr.nix` for an example.

All secrets except the following are set up automatically:
* gpg: Set these up via
  ```
  gpg --import /var/secrets/gpg-simljk@outlook.de.priv
  gpg --import /var/secrets/gpg-simljk@outlook.de.priv-subkey
  gpg --import /var/secrets/gpg-simljk@outlook.de.pub
  gpg --edit-key <simljk-key>
  trust 5
  ```

## Steam
Log into steam once with steamcmd and HOME=/var/lib/steam/cmd and enter
steamguard-code, then it should run again for a while.
## GOG
Log into gog via HOME=/var/lib/gog lgogdownloader --login, then update-games can
do its job for gog.

# TODO
* Use DHCP (Kea, dhcpcd is deprecated) for configuring ips.
  Be careful doing this in fritzbox-net, have to disable its dhcp-server.
* Look into using tailscale (or the self-hosted variant), it may be faster
  than raw wireguard due to hole-punching (directly connect peers vs route all
  traffic over server).
* Use ACL to allow granular access to files and directories for restic. Probably
  use systemd.tmpfiles for granular access, and run it after NixOS rebuild via
  systemd-tmpfiles-resetup.service in activationScript (After?) to make sure
  permissions are correct even when nixOS has different ACL for some directory.


# Resources
* [noogle](https://noogle.dev/) for searching stdlib functions and pulling the
  implementation.
* [nixpkgs](https://github.com/NixOS/nixpkgs) Actually has all implementations
  :D
