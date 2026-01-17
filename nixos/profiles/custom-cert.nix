{ config, lib, pkgs, machine, data, ... }:

let
  vars = {
    # for python.
    REQUESTS_CA_BUNDLE = config.security.pki.caBundle;
  };
in {
  security.pki.certificateFiles = [ config.l3mon.secgen.secrets.caddy_ca_root.cert ];

  environment.variables = vars;
  systemd.globalEnvironment = vars;

  home-manager.sharedModules = [
    ({
      systemd.user.sessionVariables = vars;
      xdg.configFile."systemd/user/service.d/cert_env.conf".text = ''
        [Service]
        Environment=REQUESTS_CA_BUNDLE=${config.security.pki.caBundle}
      '';
    })
  ];
}
