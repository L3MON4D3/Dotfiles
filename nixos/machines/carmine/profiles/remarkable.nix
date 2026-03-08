{ config, lib, pkgs, pkgs-unstable, machine, data, self, ... }:

{
  environment.systemPackages = with pkgs; [
    pkgs-unstable.rmapi
  ];
  environment.variables = {
    RMAPI_HOST = "https://${self.nixosConfigurations.indigo.config.l3mon.services.defs.rmfakecloud.network_domain}";
  };

  # home-manager.sharedModules = [
    # (
      # { config, lib, pkgs, machine, data, ... }: {
        # home.packages = with pkgs; [
          # (pkgs-unstable.rmapi.overrideAttrs (old: {
            # src = fetchFromGitHub {
              # owner = "ddvk";
              # repo = "rmapi";
              # rev = "4988805";
              # sha256 = "sha256-xB/xQcXU5Nja6YAG5a2NrYFflt1dQVT40doVQDCcFOs=";
            # };
          # }))
        # ];
      # }
    # )
  # ];
}
