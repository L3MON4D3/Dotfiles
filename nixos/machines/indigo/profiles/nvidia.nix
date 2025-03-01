{ config, lib, pkgs, machine, data, ... }:

{
  # https://nixos.wiki/wiki/Nvidia
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    # load even if no graphical session.
    nvidiaPersistenced = true;
    # newer open driver only supports <= turing(20xx)
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  # for mesa, which provides hardware acceleration for video encoding (I think).
  hardware.graphics.enable = true;
  # also necessary for transcoding.
  services.xserver.videoDrivers = [ "nvidia" ];

  environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia
  ];
}
