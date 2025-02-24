{ config, lib, pkgs, machine, data, ... }:

{
  services.cachefilesd = {
    enable = true;
    extraConfig = ''
      tag nvme
      brun 15%
      bcull 5%
      bstop 2%
      frun 10%
      fcull 5%
      fstop 2%
    '';
  };

  fileSystems.${config.services.cachefilesd.cacheDir} = {
    label = "CACHE";
  };
}
