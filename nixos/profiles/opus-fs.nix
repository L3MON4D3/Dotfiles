{ config, lib, pkgs, machine, data, inputs, system, ... }:

let
  target_dir = "/srv/media/lossy_audio";
in {
  # for opus-fs.
  programs.fuse.userAllowOther = true;

  systemd.services.opus-fs = {
    enable = true;
    unitConfig.RequiresMountsFor = [ target_dir ];
    serviceConfig = {
      Type = "exec";
      User = "simon";
      Group = "simon";
    };
    path = [ inputs.dirmap.packages.${system}.default ];
    script = ''
      mkdir -p ${target_dir}
      chown simon:media ${target_dir}
      # run in foreground, need direct_io due to unknown/incorrect st_size.
      opus-fs /srv/media/audio ${target_dir} -f -o direct_io,ro,allow_other
    '';
    preStop = ''
      ${config.security.wrapperDir}/fusermount -u ${target_dir}
    '';
  };
}
