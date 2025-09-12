{ config, lib, l3lib, pkgs, pkgs-unstable, inputs, data, self, ... }:

{
  disabledModules = ["services/databases/mysql.nix"];

  imports = [
    # supersede nixpkgs' mysql module.
    ./modules/mysql.nix
    ./modules/restic.nix
    ./modules/zotero.nix
    ./modules/wireguard/netns.nix
    ./modules/wireguard/host.nix
    ./modules/blocky.nix
    ./modules/peercache.nix
    ./modules/sway-netns.nix

    ./profiles/bash-alias-completion.nix
    ./profiles/bash-dircolors.nix

    ./profiles/history.nix
    ./profiles/wakeonlan.nix
  ];

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  boot.supportedFilesystems = ["ntfs"];

  # stable neovim for root user.
  programs.neovim = {
    enable = true;
  };
  environment.variables = {
    EDITOR = "nvim";
    SYSTEMD_EDITOR = "nvim";
  };

  # override builtin aliases like ls.
  environment.shellAliases = {
    n = "nvim";
    ".." = "cd ..";
    g = "git";
    # keep environment, like EDITOR.
    ss = "sudo -E systemctl";
    js = "sudo -E journalctl";
    su = "systemctl --user";
    ju = "journalctl --user";
    l = "ls";
    la = "ls -a";
    ll = "ls -la";
    rs = "rsync -ah --progress --info=progress2";
  };
  programs.bash.interactiveShellInit = ''
    where() {
      realpath $(which $1)
    }
    export -f where
    stty -ixon
  '';

  environment.etc."inputrc".text = ''
    set editing-mode vi
    set history-size 500000
  '';

  environment.variables = {
    MANPAGER = "nvim +Man!";
    # if 999 (recommended default), the doc is much to wide for my taste.
    # this gives it a better appearance
    MANWIDTH = "100";
  };

  # programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    # archives
    zip
    xz
    unzip
    p7zip
    rar

    # utils
    ripgrep
    shellcheck
    fd
    rename

    # networking tools
    dig
    wget
    curl
    socat

    # misc
    gnumake
    file
    which
    tree
    dust
    wireguard-tools
    (ffmpeg.override { withFdkAac = true; withUnfree = true; })
    just

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
    rsync

    # system tools
    sysstat
    lm_sensors # for `sensors` command
    pciutils # lspci
    usbutils # lsusb
  ];

  nixpkgs.overlays = [
    (import ./packages/default.nix)
  ];
  # does what config.nixpkgs.flake.setNixPath does, ad adds nixpkgs-overlay
  nix.nixPath = lib.mkForce [ "nixpkgs=flake:nixpkgs:nixpkgs-overlays=${self}/overlays" ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings = {
    # login only via public key.
    PasswordAuthentication = false;
  };

  nixpkgs.config.allowUnfree = true;

  security.pam.services.su.nodelay = true;
  security.pam.services.sudo.nodelay = true;

  users.mutableUsers = false;
  users.users.root.hashedPasswordFile = l3lib.secret "root_password_hashed";

  # common users
  users.users.media = {
    isSystemUser = true;
    uid = data.ids.media;
    group = "media";
  };
  users.groups.media.gid = data.ids.media;

  programs.dconf.enable = true;

  nix = {
    package = pkgs-unstable.nix;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ]; 
      flake-registry = "";
      substituters = [
        "http://nix-community.cachix.org"
        "http://cache.nixos.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    registry = {
     vorlagen = {
        from = {
          type = "indirect";
          id = "vorlagen";
        };
        to = {
          type = "git";
          url = "http://git.internal/simon/nix-templates";
        };
      };
      unstable = {
        from = {
          type = "indirect";
          id = "unstable";
        };
        flake = self.inputs.nixpkgs-unstable;
      };
    };
  };

  environment.etc."nixos-data" = {
    enable = true;
    text = builtins.toJSON data;
    mode = "0444";
  };

  # networking.extraHosts = ''
  #   0.0.0.0 ziglang.org
  #   0.0.0.0 pkg.machengine.org
  #   0.0.0.0 zigmirror.hryx.net
  #   0.0.0.0 zig.linus.dev
  #   0.0.0.0 fs.liujiacai.net
  #   0.0.0.0 zig.nekos.space
  # '';

  # system.copySystemConfiguration = true;

  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11";
}
