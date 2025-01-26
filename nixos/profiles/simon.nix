{ config, lib, pkgs, machine, data, ... }:

{
  users.users.simon = {
    isNormalUser = true;
    group = "simon";
    extraGroups = [
      "wheel"
      "media"
    ]; # Enable ‘sudo’ for the user and provide user-group.
    packages = with pkgs; [
      tree
    ];
    uid = 1000;
  };
  users.groups.simon.gid = 1000;

  users.users.simon.openssh.authorizedKeys.keys = [
    data.pubkey
  ];

  systemd.tmpfiles.rules = [
    "d /home/simon 0750 simon simon"
    "d /home/simon/.config 0750 simon simon"
  ];

  users.users.restic.extraGroups = ["simon"];
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
          -e "/home/simon/.config/chromium"
          -e "/home/simon/.config/spotify"
          -e "/home/simon/.config/Epic"
          -e "/home/simon/.config/VSCodium"
          -e "/home/simon/.config/Code - OSS" )

        restic backup --tag=userdata-auto --exclude-caches "''${PROJECT_EXCLUDE_PATTERNS[@]}" "''${CONFIG_EXCLUDE_PATTERNS[@]}" .config/ projects/
      '';
    };
    forget = {
      # keep last four days of automatically created snapshots.
      # May be excessive, consider removing empty snapshots to cut down on repo-size.
      # group-by is necessary afaict!
      text = ''
        l3mon-restic forget --tag=userdata-auto --group-by=tag --keep-hourly=168 --keep-daily=120 --keep-monthly=36 --keep-yearly=unlimited
      '';
    };
  };
}
