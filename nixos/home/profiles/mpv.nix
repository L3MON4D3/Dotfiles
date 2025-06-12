{ config, lib, pkgs, machine, data, ... }:

{
  xdg.configFile."mpv/mpv.conf".text = ''
    vo=gpu-next
    gpu-api=vulkan
    hwdec=yes
    video-sync=display-resample
  '';
  
  home.packages = with pkgs; [
    mpv
  ];

  wayland.windowManager.sway.extraConfig = ''
    bindsym XF86AudioPlay exec ${pkgs.mpc}/bin/mpc toggle
  '';
}
