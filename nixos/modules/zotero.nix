# from https://www.reddit.com/r/NixOS/comments/1dtgavp/combining_global_and_homemanager_options_in_a/
{ config, lib, pkgs, machine, data, ... }:

with lib;
let
  client_zotero_data_dir = "/mnt/zotero";
  export_name = "zotero";
in
{
  options.l3mon.zotero = {
    enable_server = mkEnableOption (lib.mdDoc "Enable hosting of zotero-data.");
    enable_client = mkEnableOption (lib.mdDoc "Enable usage of zotero-data.");
  };

  config = mkMerge [
    (mkIf config.l3mon.zotero.enable_server {
      fileSystems."/srv/nfs/${export_name}" = {
        device = "/srv/zotero";
        options = [ "bind" ];
      };
      services.nfs.server.exports = ''
        /srv/nfs/${export_name} 192.168.178.0/24(rw)
      '';

      l3mon.restic.specs.zotero = {
        backupDaily = {
          text = ''
            cd /srv/zotero
            restic backup --tag=zotero --skip-if-unchanged=true -- *
          '';
        };
        forget = {
          text = ''
            # consider group-by=tag,path to keep all files?
            restic forget --tag=zotero --group-by=tag --keep-daily=7 --keep-monthly=12
          '';
        };
      };
    })
    (mkIf config.l3mon.zotero.enable_client {
      fileSystems.${client_zotero_data_dir} = {
        device = "zotero.internal:/${export_name}";
        fsType = "nfs";
        options = [ "nfsvers=4.2" "rw" "fsc" ];
      };
      
      home-manager.sharedModules = [
        ({ config, lib, pkgs, machine, data, ... }: {
          options.l3mon.zotero.enable = mkEnableOption "Enable zotero-config for this user.";
          config = mkIf config.l3mon.zotero.enable {
            xdg.stateFile."zotero/user.js".text = ''
              user_pref("extensions.zotero.useDataDir", true);
              # TOOD: change this file.
              user_pref("extensions.zotero.dataDir", "${client_zotero_data_dir}");

              user_pref("extensions.zotero.findPDFs.resolvers", "[     {         \"name\":\"Sci-Hub\",         \"method\":\"GET\",         \"url\":\"https://sci-hub.se/{doi}\",         \"mode\":\"html\",         \"selector\":\"#pdf\",         \"attribute\":\"src\",         \"automatic\":true     },     {         \"name\":\"annas-archive\",         \"method\":\"GET\",         \"url\":\"https://annas-archive.org/scidb/{doi}\",         \"mode\":\"html\",         \"selector\":\"li>a\",         \"index\":3,         \"attribute\":\"href\",         \"automatic\":true     } ]");
              user_pref("extensions.zotero.openURL.resolver", "https://annas-archive.org/scidb/?");

              user_pref("extensions.zotero.firstRun.skipFirefoxProfileAccessCheck", true);
            '';

            home.packages = with pkgs; [
              zotero
            ];

            wayland.windowManager.sway.extraConfig = ''
              mode "apps" {
                bindsym z exec $term ${pkgs.zotero}/bin/zotero --profile ${client_zotero_data_dir}
              }
            '';
          };
        })
      ];
    })
  ];
}
