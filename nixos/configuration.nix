{ config, lib, pkgs, inputs, data, ... }:

{
  disabledModules = ["services/databases/mysql.nix"];

  imports = [
    ./modules/mysql.nix

    ./profiles/bash-alias-completion.nix
    ./profiles/bash-dircolors.nix
    ./profiles/simon.nix
  ];

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # stable neovim for root user.
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  # override builtin aliases like ls.
  environment.shellAliases = {
    n = "nvim";
    re = ''sudo ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake "/home/simon/projects/dotfiles/nixos#indigo"'';
    ".." = "cd ..";
    g = "git";
    ss = "sudo systemctl";
    su = "systemctl --user";
    js = "sudo journalctl";
    ju = "journalctl --user";
    l = "ls";
    la = "ls -a";
    ll = "ls -la";
  };
  programs.bash.interactiveShellInit = ''
    where() {
      realpath $(which $1)
    }
    export -f where
  '';

  environment.variables = {
    MANPAGER = "nvim +Man!";
    # if 999 (recommended default), the doc is much to wide for my taste.
    # this gives it a better appearance
    MANWIDTH = "100";
  };

  security.sudo = {
    enable = true;
    extraRules = [{
      commands = [{
        # insecure, allows arbitrary modification to system by unprivileged user.
        # Does not matter here :D
        command = ''${pkgs.nixos-rebuild}/bin/nixos-rebuild'';
        options = [ "NOPASSWD" ];
      }
      ];
      groups = [ "wheel" ];
    }];
    extraConfig = with pkgs; ''
      Defaults:picloud secure_path="${lib.makeBinPath [
        systemd
      ]}:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
    '';
  };

  # programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    # archives
    zip
    xz
    unzip
    p7zip

    # utils
    ripgrep
    shellcheck

    # networking tools
    dig
    wget
    curl
    socat

    # misc
    file
    which
    tree
    dust
    wireguard-tools
    restic

    # nix related
    nix-output-monitor

    # monitoring
    btop  # replacement of htop/nmon
    iotop # io monitoring
    iftop # network monitoring

    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files

    # system tools
    sysstat
    lm_sensors # for `sensors` command
    pciutils # lspci
    usbutils # lsusb

    l3mon.netns-exec
  ];

  nixpkgs.overlays = [
    (import ./packages/default.nix)
  ];

  fileSystems."/mnt/misc" = {
    device = "cinnabar:/misc";
    fsType = "nfs";
    options = [ "nfsvers=4.2" ];
  };
  fileSystems."/mnt/media" = {
    device = "cinnabar:/media";
    fsType = "nfs";
    options = [ "nfsvers=4.2" ];
  };
  # for correct permissions on files from nfs/existing data.
  users.groups.nfs.gid = 1000;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings = {
    # login only via public key.
    PasswordAuthentication = false;
  };

  # system.copySystemConfiguration = true;

  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11";
}
