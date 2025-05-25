{ config, lib, pkgs, machine, data, ... }:

with lib;
let
  netns_cfg = config.l3mon.network_namespaces;
in {
    home-manager.sharedModules = (map
      (wg_network: let
        netns_name = "${wg_network.name}";
      in (
        { config, lib, pkgs, machine, data, ... }: {
          options.l3mon.sway-netns.${netns_name} = {
            enable = mkEnableOption "Enable sway-keybindings for ${netns_name}.";
            openPrivateWindow = mkOption {
              type = types.bool;
              description = "Whether to open firefox in incognito mode.";
              default = false;
            };
            netnsKey = mkOption {
              type = types.str;
              description = "bindsym for this network namespace.";
            };
            landingPage = mkOption {
              type = types.str;
              description = "Page to open on startup.";
              default = "http://google.com";
            };
            firefoxProfileSettings = mkOption {
              type = types.attrs;
              description = "Attrs for the netns-specific firefox profile.";
              default = {};
            };
          };
          config = let
            cfg = config.l3mon.sway-netns.${netns_name};
            ff_profile_name = "netns-${netns_name}";
          in (mkIf cfg.enable {
            programs.firefox.profiles = {
              ${ff_profile_name} = {
                name = ff_profile_name;
                isDefault = false;
              } // cfg.firefoxProfileSettings;
            };


            wayland.windowManager.sway.extraConfig = let
              # ns_exec = "${config.security.wrapperDir}/netns-exec ${netns_name}";
              ns_exec = "netns-exec";
            in ''
              mode "netns" {
                bindsym ${cfg.netnsKey} mode "${netns_name}"
              }

              mode "${netns_name}" {
                bindsym Return exec $term ${ns_exec} bash; mode "default"
                ${lib.optionalString config.programs.firefox.enable "bindsym f exec ${ns_exec} ${netns_name} ${config.programs.firefox.finalPackage}/bin/firefox -no-remote -P ${ff_profile_name} ${lib.optionalString cfg.openPrivateWindow "--private-window"} ${cfg.landingPage}; mode default"}

                bindsym Escape mode "default"
              }
            '';
          });
        }
      ))
      config.l3mon.network_namespaces.network_configs) ++
      [
        ({ config, lib, pkgs, machine, data, ... }: {
          config = mkIf (any (wg_network: config.l3mon.sway-netns.${wg_network.name}.enable) netns_cfg.network_configs) {
            wayland.windowManager.sway.extraConfig = ''
              mode "netns" {
                bindsym Escape mode "default"
              }
              bindsym $mod+n mode "netns"
            '';
          };
        })
      ];
}
