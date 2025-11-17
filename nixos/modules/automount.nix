{ config, lib, pkgs, machine, data, ... }:

with lib; let
  cfg = config.l3mon.automount;
in {
  options.l3mon.automount = {
    enable = mkEnableOption (lib.mdDoc "Enable automounting.");
    spec = mkOption {
      type = types.attrsOf types.attrs;
      description = lib.mdDoc "Maps partition-labels to options for mounting it.";
    };
  };
  config = mkIf cfg.enable (let
    umount_command = partlabel: "${config.security.wrapperDir}/umount /dev/disk/by-label/${partlabel}";
  in {
    services.udev.extraRules = lib.attrsets.foldlAttrs (acc: partlabel: spec: acc + ''
      ACTION=="add", SUBSYSTEMS=="usb", SUBSYSTEM=="block", ENV{ID_FS_USAGE}=="filesystem" ENV{ID_FS_LABEL}=="${partlabel}", RUN{program}+="${pkgs.systemd}/bin/systemd-mount --no-block --automount=yes --collect $devnode ${spec.at} -o x-systemd.idle-timeout=600${if spec ? options then ",${spec.options}" else ""}"
    '') "" cfg.spec;

    systemd.tmpfiles.rules = lib.attrsets.foldlAttrs (acc: _: spec: acc ++ [
      "d ${spec.at} 0770 simon simon"
    ]) [] cfg.spec;

    security.sudo = {
      extraRules = [{
        commands = [{
          command = builtins.concatStringsSep "," (lib.attrsets.foldlAttrs (acc: partlabel: spec: acc ++ ["${umount_command partlabel}"]) [] cfg.spec);
          options = [ "NOPASSWD" ];
        }];
        groups = [ "simon" ];
      }];
    };
    environment.systemPackages = with pkgs; [
      (writeShellApplication (let
      in {
        name = "um";
        text = ''
          case "$1" in
        '' + (attrsets.foldlAttrs (acc: partlabel: _: acc + ''
            ${partlabel})
              ${config.security.wrapperDir}/sudo ${umount_command partlabel}
              ;;
          '')  "" cfg.spec) +
          ''
            *)
              echo "$1 is not a registered partition-lable!"
            esac
          '';
      }))
      (pkgs.runCommand "automount_completion" {} (let
        format = pkgs.formats.yaml {};
        completely_spec = format.generate "completion.yaml" {
          um = attrsets.foldlAttrs (acc: label: _: acc ++ [label]) [] cfg.spec;
        };
      in ''
        mkdir -p "$out/share/bash-completion/completions"
        ${pkgs.completely}/bin/completely generate ${completely_spec} "$out/share/bash-completion/completions/um"
      ''))
    ];
  });
}
