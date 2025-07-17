{ config, lib, l3lib, pkgs, machine, data, ... }:

{
  users.users.simon = {
    isNormalUser = true;
    group = "simon";
    extraGroups = [
      "wheel"
      "media"
      "qbittorrent"
      "private"
    ]; # Enable ‘sudo’ for the user and provide user-group.
    uid = data.ids.simon;
    hashedPasswordFile = l3lib.secret "simon_password_hashed";
    linger = true;
  };
  users.groups.simon.gid = data.ids.simon;

  users.users.simon.openssh.authorizedKeys.keys = [
    data.pubkey
  ];

  system.activationScripts = {
    qbittorrent = {
      text = 
      (l3lib.assertSecret "id_rsa") + 
      (l3lib.assertSecret "id_rsa.pub") + 
      ''
        install -d -o simon -g simon /home/simon/.ssh
        install -D -o simon -g simon -m 600 ${l3lib.secret "id_rsa"} /home/simon/.ssh/id_rsa
        install -D -o simon -g simon -m 640 ${l3lib.secret "id_rsa.pub"} /home/simon/.ssh/id_rsa.pub
      '';
    };
  };
  

  systemd.tmpfiles.rules = [
    "d /home/simon 0750 simon simon"

    "Z /home/simon/.config 0750 simon simon"

    "d /home/simon/.thunderbird/ 0750 simon simon"
    "z /home/simon/.thunderbird/*.default 0750 simon simon"
    "A /home/simon/.thunderbird/*.default/ImapMail - - - - g:simon:rX"

    "A /home/simon/projects/dotfiles/nvim/info - - - - g:simon:r"
  ];

  l3mon.restic.extraGroups = [ "simon" ];
  l3mon.restic.specs.simon = {
    backup15min = {
      text = ''
        cd /home/simon
        PROJECT_EXCLUDE_PATTERNS=(
          -e "/home/simon/projects/**/build/"
          -e "/home/simon/projects/**/Unreal Projects/"
          -e "/home/simon/projects/**/build_d/"
          -e "/home/simon/projects/**/lib/"
          -e "/home/simon/projects/**/*.axf"
          -e "/home/simon/projects/**/.git/lost-found"
          -e "/home/simon/projects/**/.git/modules/"
          -e "/home/simon/projects/**/target/"
          -e "/home/simon/projects/**/.gradle/"
          -e "/home/simon/projects/**/zig-cache/"
          -e "/home/simon/projects/**/luasnip/deps/" )

        CONFIG_EXCLUDE_PATTERNS=(
          -e "/home/simon/.config/discord/"
          -e "/home/simon/.config/ArmCord"
          -e "/home/simon/.config/legcord"
          -e "/home/simon/.config/unity3d"
          -e "/home/simon/.config/chromium"
          -e "/home/simon/.config/spotify"
          -e "/home/simon/.config/Epic"
          -e "/home/simon/.config/VSCodium"
          -e "/home/simon/.config/Code - OSS" )

        restic backup --tag=userdata-auto-${machine} --exclude-caches "''${PROJECT_EXCLUDE_PATTERNS[@]}" "''${CONFIG_EXCLUDE_PATTERNS[@]}" .config/ projects/ .thunderbird/*.default/ImapMail
      '';
    };
    forget = {
      # keep last four days of automatically created snapshots.
      # May be excessive, consider removing empty snapshots to cut down on repo-size.
      # group-by is necessary afaict!
      text = ''
        restic forget --tag=userdata-auto-${machine} --group-by=tag --keep-hourly=168 --keep-daily=120 --keep-monthly=36 --keep-yearly=unlimited
      '';
    };
  };
}
