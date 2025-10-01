{ config, lib, pkgs, machine, l3lib, inputs, data, system, microvm, ... }:

let
  vmname = "merigold";
  vm_runtimedir = "/var/lib/microvms/${vmname}";
  lan = data.network.lan;
  mgconf = {
    hostname = "${vmname}";
    address = "${lan.peers.${vmname}.address}/24";
    mac = "${lan.peers.${vmname}.mac_address}";
    host_if = "${lan.peers.${machine}.phys_interface}";
    host_macvtapname = "macvtap-mg";
    gateway_ip = "${lan.gateway_peer.address}";
    gateway_mac = "${lan.gateway_peer.mac}";
    localnet_allowlist = [
      lan.peers.carmine
      lan.peers.indigo
    ];
    pubkey = data.pubkey; # allowed ssh-pubkey

    guest_keyfile = l3lib.secret "merigold-key";
    guest_pubkeyfile = l3lib.secret "merigold-pubkey";
    pds_env = config.l3mon.secgen.secrets.pds_env.file_abs;
    smtp_passwordfile = config.l3mon.secgen.secrets.mailbox_msmtp.microvm_file_abs;

    share_store = false;
    password = null; # set to null on production server!!
    systemPackages = with pkgs; [ neovim sqlite tree fd btop rsync dust ]; # just a few tools for admin.
    img_path = "${vm_runtimedir}/var.img";
    control_socket = "${vm_runtimedir}/control.socket";

    ports = data.ports;
    ids = data.ids;
  };
  nftable = inputs.merigold.lib.${system}.mkRuleset mgconf;

  remote_sync_dir = "/var/lib/remote-services/merigold";
  rsa_key_file = "${config.l3mon.secgen.secrets.id_rsa.key_abs}";
  sync_pds_merigold = pkgs.writeShellApplication {
    name = "sync-pds-merigold";
    runtimeInputs = with pkgs; [ openssh rsync coreutils ];
    text = ''
      mkdir -p ${remote_sync_dir}/pds
      ssh root@merigold -i ${rsa_key_file} systemctl stop pds
      rsync -av -e 'ssh -i ${rsa_key_file}' root@merigold:/var/lib/pds/ ${remote_sync_dir}/pds
      chown -R restic:restic ${remote_sync_dir}/pds
      ssh root@merigold -i ${rsa_key_file} systemctl start pds
    '';
  };
in {
  microvm = {
    vms = {
      merigold = {
        # use same packages as flake.
        pkgs = import inputs.merigold.inputs.nixpkgs {inherit system;};
        config = inputs.merigold.nixosModules.${system}.merigold;
        specialArgs.mgconf = mgconf;
      };
    };
  };

  l3mon.secgen.secrets.pds_env = rec {
    file_rel = "pds_env";
    file_abs = "${config.l3mon.secgen.secret_dir}/${file_rel}";

    backup_relfiles = [ file_rel ];
    gen = pkgs.writeShellApplication {
      name = "gen";
      runtimeInputs = with pkgs; [ openssl tinyxxd ];
      text = ''
        {
          # Generate JWT secret
          JWT_SECRET=$(openssl rand --hex 16)
          echo "PDS_JWT_SECRET=$JWT_SECRET"

          # Generate admin password
          ADMIN_PASSWORD=$(openssl rand --hex 16)
          echo "PDS_ADMIN_PASSWORD=$ADMIN_PASSWORD"

          # Generate PLC rotation key
          PLC_KEY=$(openssl ecparam --name secp256k1 --genkey --noout --outform DER | tail --bytes=+8 | head --bytes=32 | xxd --plain --cols 32)
          echo "PDS_PLC_ROTATION_KEY_K256_PRIVATE_KEY_HEX=$PLC_KEY"
        } > ${file_abs}
        # passwordfile has to be \n-terminated!
        chown microvm:kvm ${file_abs}
        chmod 440 ${file_abs}
      '';
    };
  };

  systemd.services."microvm-macvtap-interfaces@merigold" = {
    overrideStrategy = "asDropin";
    postStart = ''
      ${pkgs.nftables}/bin/nft -f ${nftable}
    '';
  };

  security.sudo = {
    extraRules = [{
      commands = [{
        command = "${sync_pds_merigold}/bin/sync-pds-merigold";
        options = [ "NOPASSWD" ];
      }];
      groups = [ "restic" ];
    }];
  };

  l3mon.restic.specs.merigold-pds = {
    backupDaily = {
      text =
      # bash
      ''
        ${config.security.wrapperDir}/sudo ${sync_pds_merigold}/bin/sync-pds-merigold

        cd ${remote_sync_dir}/pds
        restic backup --tag=merigold-pds --skip-if-unchanged=true -- ./*
      '';
    };
    forget = {
      text = ''
        restic forget --tag=merigold-pds --group-by=tag --keep-daily=7 --keep-monthly=12
      '';
    };
  };
}
