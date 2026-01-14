{ config, lib, l3lib, pkgs, pkgs-unstable, inputs, data, self, system, ... }:

{
  disabledModules = ["services/databases/mysql.nix"];

  imports = [
    # supersede nixpkgs' mysql module.
    ./modules/mysql.nix
    ./modules/restic.nix
    ./modules/automount.nix
    ./modules/zotero.nix
    ./modules/wireguard/netns.nix
    ./modules/wireguard/host.nix
    ./modules/blocky.nix
    ./modules/peercache.nix
    ./modules/sway-netns.nix

    ./modules/network.nix
    ./modules/paths.nix
    ./profiles/bash-alias-completion.nix
    ./profiles/bash-dircolors.nix
    ./profiles/networks.nix

    ./profiles/history.nix
    ./profiles/wakeonlan.nix
    ./modules/secgen.nix
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
    cat = "bat";
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
    BAT_STYLE = "header-filename,header-filesize,numbers";
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
    xxd
    bat
    jq

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
  services.openssh = {
    enable = true;
    settings = {
      # login only via public key.
      PasswordAuthentication = false;
      AllowAgentForwarding = true;
      StreamLocalBindUnlink = true;
    };
  };

  nixpkgs.config.allowUnfree = true;

  security.pam.services.su.nodelay = true;
  security.pam.services.sudo.nodelay = true;

  users.mutableUsers = false;
  users.users.root.hashedPasswordFile = config.l3mon.secgen.secrets.local_root_password.hashed;

  l3mon.secgen.secrets.local_root_password = rec {
    cleartext = "${config.l3mon.secgen.secret_dir}/local_root_pw";
    hashed = "${config.l3mon.secgen.secret_dir}/local_root_pw_hashed";

    backup_files = [ cleartext hashed ];
    gen = pkgs.writeShellApplication {
      name = "gen";
      text =
      ''
        echo 'Enter new password:'
        read -r PASSWORD
        echo "Read password $PASSWORD from stdin"
        HASHED=$(echo "$PASSWORD" | mkpasswd -s)

        echo -n "$PASSWORD" > ${cleartext}
        chown root:root ${cleartext}
        chmod 400 ${cleartext}

        echo -n "$HASHED" > ${hashed}
        chown root:root ${hashed}
        chmod 400 ${hashed}
      '';
    };
  };

  # common users
  users.users.media = {
    isSystemUser = true;
    uid = data.ids.media;
    group = "media";
  };
  users.groups.media.gid = data.ids.media;

  users.users.zotero = {
    isSystemUser = true;
    uid = data.ids.zotero;
    group = "zotero";
  };
  users.groups.zotero.gid = data.ids.zotero;

  programs.dconf.enable = true;

  nix = {
    package = pkgs-unstable.nix;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ]; 
      flake-registry = "";
      keep-derivations = true;
      substituters = [
        "http://nix-community.cachix.org"
        "http://cache.nixos.org"
      ];
      trusted-public-keys = [
        data.pubkeys.cachix-community
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

  l3mon.secgen.secrets.atproto = rec {
    key = "${config.l3mon.secgen.secret_dir}/atproto_key";
    pubkey = "${config.l3mon.secgen.secret_dir}/atproto_pubkey";

    backup_files = [ key pubkey ];
    gen = pkgs.writeShellApplication {
      name = "gen";
      runtimeInputs = [ inputs.didweb.packages.${system}.default ];
      text = ''
        KEY=$(bsky-did-web genkey)
        PUBKEY=$(echo -n "$KEY" | bsky-did-web pubkey)

        echo -n "$KEY" > ${key}
        chown root:root ${key}
        chmod 400 ${key}

        echo -n "$PUBKEY" > ${pubkey}
        chown root:root ${pubkey}
        chmod 400 ${pubkey}
      '';
    };
  };

  # networking.extraHosts = ''
    # 0.0.0.0 pkg.machengine.org
    # 0.0.0.0 zigmirror.hryx.net
    # 0.0.0.0 zig.linus.dev
    # 0.0.0.0 zig.squirl.dev
    # 0.0.0.0 zig.florent.dev
    # 0.0.0.0 zig.mirror.mschae23.de
    # 0.0.0.0 zigmirror.meox.dev
  # '';

  l3mon.secgen.secrets = {
    mailbox_msmtp = rec {
      file = "${config.l3mon.secgen.secret_dir}/mailbox_msmtp";
      microvm_file = "${config.l3mon.secgen.secret_dir}/mailbox_msmtp_microvm";

      backup_files = [ file ];
      gen = pkgs.writeShellApplication {
        name = "gen";
        text = ''
          echo 'Open mailbox.org and create a new email-app password with SMTP access.'
          echo 'Enter it here:'
          read -r PASSWORD
          echo "Read password $PASSWORD from stdin"

          # passwordfile has to be \n-terminated!
          echo "$PASSWORD" > ${file}
          chown root:root ${file}
          chmod 400 ${file}

          echo "$PASSWORD" > ${microvm_file}
          chown microvm:kvm ${microvm_file}
          chmod 440 ${microvm_file}
        '';
      };
    };
    id_rsa = rec {
      key = "${config.l3mon.secgen.secret_dir}/id_rsa";
      pubkey = "${config.l3mon.secgen.secret_dir}/id_rsa.pub";

      backup_files = [ key pubkey ];
      gen = pkgs.writeShellApplication {
        name = "gen";
        runtimeInputs = with pkgs; [ openssh ];
        text = ''
          ssh-keygen -N "" -f ${key} -C ""

          chown root:root ${key}
          chmod 400 ${key}
        '';
      };
    };
  };

  # system.copySystemConfiguration = true;

  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11";
}
