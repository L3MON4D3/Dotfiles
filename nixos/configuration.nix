{ config, lib, l3lib, pkgs, pkgs-unstable, inputs, data, self, system, ... }:

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
    cleartext_rel = "local_root_pw";
    cleartext = "${config.l3mon.secgen.secret_dir}/${cleartext_rel}";

    hashed_rel = "local_root_pw_hashed";
    hashed = "${config.l3mon.secgen.secret_dir}/${hashed_rel}";

    backup_relfiles = [ cleartext_rel hashed_rel ];
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

  l3mon.secgen.secrets.atproto = rec {
    key_rel = "atproto_key";
    key_abs = "${config.l3mon.secgen.secret_dir}/${key_rel}";
    pubkey_rel = "atproto_pubkey";
    pubkey_abs = "${config.l3mon.secgen.secret_dir}/${pubkey_rel}";

    backup_relfiles = [ key_rel pubkey_rel ];
    gen = pkgs.writeShellApplication {
      name = "gen";
      runtimeInputs = [ inputs.didweb.packages.${system}.default ];
      text = ''
        KEY=$(bsky-did-web genkey)
        PUBKEY=$(echo -n "$KEY" | bsky-did-web pubkey)

        echo -n "$KEY" > ${key_abs}
        chown root:root ${key_abs}
        chmod 400 ${key_abs}

        echo -n "$PUBKEY" > ${pubkey_abs}
        chown root:root ${pubkey_abs}
        chmod 400 ${pubkey_abs}
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
      file_rel = "mailbox_msmtp";
      file_abs = "${config.l3mon.secgen.secret_dir}/${file_rel}";

      microvm_file_rel = "mailbox_msmtp_microvm";
      microvm_file_abs = "${config.l3mon.secgen.secret_dir}/${microvm_file_rel}";

      backup_relfiles = [ file_rel ];
      gen = pkgs.writeShellApplication {
        name = "gen";
        text = ''
          echo 'Open mailbox.org and create a new email-app password with SMTP access.'
          echo 'Enter it here:'
          read -r PASSWORD
          echo "Read password $PASSWORD from stdin"

          # passwordfile has to be \n-terminated!
          echo "$PASSWORD" > ${file_abs}
          chown root:root ${file_abs}
          chmod 400 ${file_abs}

          echo "$PASSWORD" > ${microvm_file_abs}
          chown microvm:kvm ${microvm_file_abs}
          chmod 440 ${microvm_file_abs}
        '';
      };
    };
    id_rsa = rec {
      key_rel = "id_rsa";
      key_abs = "${config.l3mon.secgen.secret_dir}/${key_rel}";

      pubkey_rel = "id_rsa.pub";
      pubkey_abs = "${config.l3mon.secgen.secret_dir}/${pubkey_rel}";

      microvm_file_rel = "mailbox_msmtp_microvm";
      microvm_file_abs = "${config.l3mon.secgen.secret_dir}/${microvm_file_rel}";

      backup_relfiles = [ key_rel pubkey_rel ];
      gen = pkgs.writeShellApplication {
        name = "gen";
        runtimeInputs = with pkgs; [ openssh ];
        text = ''
          ssh-keygen -N "" -f ${key_abs} -C ""

          chown root:root ${key_abs}
          chmod 400 ${key_abs}
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
