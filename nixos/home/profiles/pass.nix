{ config, lib, l3lib, pkgs, machine, data, ... }:

{
  home.activation.myPass = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ ! -d "${config.home.homeDirectory}/.password-store" ]; then
      run ${pkgs.systemd}/lib/systemd/systemd-networkd-wait-online
      run ${pkgs.git}/bin/git clone http://git.internal/simon/pass.git ${config.home.homeDirectory}/.password-store
    fi
  '';

  home.packages = with pkgs; [
    gnupg
  ];
}
