{ config, lib, pkgs, inputs, data, ... }:

{
  imports = [
    ./modules/bash-alias-completion.nix
    ./modules/bash-dircolors.nix
  ];

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # stable neovim for root user.
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  environment.shellAliases = {
    n = "nvim";
    re = ''sudo ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake "/home/simon/projects/dotfiles/nixos#indigo"'';
    ".." = "cd ..";
    g = "git";
  };

  environment.variables = {
    MANPAGER = "nvim +Man!";
    MANWIDTH = "999";
  };

  security.sudo = {
    enable = true;
    extraRules = [{
      commands = [{
        # insecure, allows arbitrary modification to system by unprivileged user.
        # Does not matter here :D
        command = ''${pkgs.nixos-rebuild}/bin/nixos-rebuild'';
    options = [ "NOPASSWD" ];
      }];
      groups = [ "wheel" ];
    }];
    extraConfig = with pkgs; ''
      Defaults:picloud secure_path="${lib.makeBinPath [
        systemd
      ]}:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
    '';
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.simon = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user and provide user-group.
    packages = with pkgs; [
      tree
    ];
    uid = 1000;
  };

  users.users.simon.openssh.authorizedKeys.keys = [
    data.pubkey
  ];

  # for correct permissions on files from nfs/existing data.
  users.groups.nfs.gid = 1000;

  # programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    # archives
    zip
    xz
    unzip
    p7zip

    # utils
    ripgrep

    # networking tools
    dig
    wget
    curl

    # misc
    file
    which
    tree
    dust

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
