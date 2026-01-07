{ config, lib, pkgs, machine, data, ... }:

{
  services.cachefilesd = {
    enable = true;
    # begin culling at 2% free space, stop at 3%.
    # Stop adding to the cache when only 1% is free.
    # when culling, stop when 3% are reached.
    # We don't need the f* limits because this is on btrfs.
    extraConfig = ''
      tag nvme
      brun  3%
      bcull 2%
      bstop 1%
    '';
  };

  fileSystems.${config.services.cachefilesd.cacheDir} = {
    label = "CACHE";
  };
}
