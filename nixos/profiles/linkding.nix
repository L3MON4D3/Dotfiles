{ config, lib, pkgs, machine, data, ... }:

let
  linkding_img = pkgs.dockerTools.pullImage {
    imageName = "ghcr.io/sissbruecker/linkding";
    imageDigest = "sha256:12ffd6f3b48c5d46543d2f38030de1f476d8dcff5f486eb75c9c7cb5941e7127";
    hash = "sha256-zoHFMAMAb/OojndFsRqGBFP+Df4BUm6HlIEByRzoIdw=";
    finalImageName = "linkding";
    finalImageTag = "system";
  };
  linkding_dir = "/var/lib/linkding";
in {
  users.users.linkding  = {
    isSystemUser = true;
    uid = data.ids.linkding;
    group = "linkding";
    subUidRanges = [{count = 100; startUid = 200000;}];
    subGidRanges = [{count = 100; startGid = 200000;}];
  };
  users.groups.linkding.gid = data.ids.linkding;

  systemd.tmpfiles.settings.linkding = {
    ${linkding_dir}.d = lib.mkForce {
      mode = "770";
      user = "linkding";
      group = "linkding";
    };
    "${linkding_dir}/data".d = lib.mkForce {
      mode = "770";
      user = "linkding";
      group = "linkding";
    };
    "${linkding_dir}/podman".d = lib.mkForce {
      mode = "770";
      user = "linkding";
      group = "linkding";
    };
  };

  virtualisation.oci-containers.backend = "podman";
  virtualisation.oci-containers.containers.linkding = {
    serviceName = "linkding";
    pull = "never";
    privileged = false;
    ports = [ "${toString data.ports.linkding}:9090" ];
    # podman.user = "linkding";
    imageFile = linkding_img;
    image = "linkding:system";
    extraOptions = [ "--userns" "keep-id:uid=${toString data.ids.linkding},gid=${toString data.ids.linkding}" ];
    volumes = ["${linkding_dir}/data:/etc/linkding/data"];
    environment = {
      LD_SUPERUSER_NAME = "l3mon";
      LD_SUPERUSER_PASSWORD = "l3mon";
      LD_DISABLE_BACKGROUND_TASKS = "True";
    };
  };
  systemd.services.linkding.serviceConfig.Environment=["HOME=${linkding_dir}/podman"];

  services.caddy.extraConfig = ''
    http://linkding, http://linkding.internal, http://linkding.${machine} {
      reverse_proxy http://localhost:${toString data.ports.linkding}
    }
  '';

  l3mon.restic.extraGroups = [ "linkding" ];
  l3mon.restic.specs.linkding = {
    backupStopResumeServices = ["linkding.service"];
    backupDaily = {
      text = ''
        cd /var/lib/linkding/data
        restic backup --tag=linkding --skip-if-unchanged=true -- ./*
      '';
    };
    forget = {
      text = ''
        restic forget --tag=linkding --group-by=tag --keep-daily=7 --keep-monthly=12
      '';
    };
  };
}
