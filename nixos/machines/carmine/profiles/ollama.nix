{ config, lib, pkgs, pkgs-unstable, machine, data, ... }:

{
  services.ollama = {
    enable = true;
    acceleration = "rocm";
    package = pkgs-unstable.ollama-rocm;
    rocmOverrideGfx = "10.3.0";
  };
}
