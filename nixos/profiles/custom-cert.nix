{ config, lib, pkgs, machine, data, ... }:

let
  envs = {
    # for python.
    REQUESTS_CA_BUNDLE = config.security.pki.caBundle;
  };
in {
  security.pki.certificateFiles = [ config.l3mon.secgen.secrets.caddy_ca_root.cert ];

  environment.variables = envs;
  systemd.globalEnvironment = envs;
}
