{ config, lib, pkgs, machine, data, ... }:

{
  xdg.configFile."mpv/mpv.conf".text = ''
    vo=gpu-next
    gpu-api=vulkan
    hwdec=yes
  '';
  
  home.packages = with pkgs; [
    mpv
  ];
}
