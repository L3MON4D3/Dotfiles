{ config, lib, pkgs, machine, data, ... }:

{
  services.caddy = {
    enable = true;
    enableReload = true;
    globalConfig = let
      caddy_ca_root = config.l3mon.secgen.secrets.caddy_ca_root;
    in ''
      skip_install_trust
      pki {
        ca local {
          root {
            format pem_file
            cert ${caddy_ca_root.cert}
            key ${caddy_ca_root.key}
          }
        }
      }
    '';
  };
}
