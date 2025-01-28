{ config, lib, pkgs, machine, data, ... }:

{
  security.polkit.enable = true;
  security.rtkit.enable = true;
  
  services.pipewire = {
    enable = true; # if not already enabled
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  services.gnome.gnome-keyring.enable = true;
  hardware.opengl.enable = true;
}
