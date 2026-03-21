{ config, lib, pkgs, machine, data, ... }:

{
  # show effective configuration by checking, in `su show wireplumber.service`,
  # for drop-in paths, which set XDG_DATA_DIRS.
  services.pipewire.wireplumber = {
    extraConfig = {
      "disable-monitor-out" = {
        "monitor.alsa.rules" = [
          {
            matches = [
              {
                "node.name" = "alsa_input.usb-046d_C270_HD_WEBCAM_200901010001-02.mono-fallback";
              }
              {
                "node.name" = "alsa_output.pci-0000_28_00.1.hdmi-stereo";
              }
            ];
            actions = {
              update-props = {
                "node.disabled" = true;
              };
            };
          }
        ];
      };
    };
  };
}
