{ config, lib, pkgs, machine, data, ... }:

{
  services.cachefilesd = {
    enable = true;
    # begin culling at 2% free space, stop at 6%. I've tried 3%, but that does not work for some reason.
    # Stop adding to the cache when only 1% is free.
    # We don't need the f* limits because this is on btrfs.
    extraConfig = ''
      tag nvme
      brun 6%
      bcull 2%
      bstop 1%
    '';
  };

  fileSystems.${config.services.cachefilesd.cacheDir} = {
    label = "CACHE";
  };
}
