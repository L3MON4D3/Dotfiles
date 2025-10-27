{ config, lib, l3lib, pkgs, machine, data, ... }:

let
  gpgdir = "/run/user/1000/gnupg";
in {
  home.sessionVariables = {
    GNUPGHOME = gpgdir;
  };

  home.activation.myGPG = lib.hm.dag.entryAfter ["writeBoundary"] ''
    run mkdir -p -m 700 ${gpgdir}/
    run mkdir -p -m 700 ${gpgdir}/d.cpwgsr1yrynbs7nu683b3gty
    run echo 'no-autostart' > ${gpgdir}/gpg.conf
    GNUPGHOME=${gpgdir} run ${pkgs.gnupg}/bin/gpg --import ${l3lib.secret "gpg-simon@l3mon4.de.pub"}
    GNUPGHOME=${gpgdir} run ${pkgs.gnupg}/bin/gpg --import ${l3lib.secret "gpg-simljk@outlook.de.pub"}
  '';
}
