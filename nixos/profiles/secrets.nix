{ config, lib, pkgs, machine, data, inputs, system, ... }:

{
  l3mon.secgen.secrets = {
    local_root_password = rec {
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
    atproto = rec {
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
    caddy_ca_root = rec {
      cert_repo = "/data/generated/caddy_root_cert";
      cert_impure = "${config.l3mon.paths.nixos_config_dir}${cert_repo}";
      cert = ./.. + "${cert_repo}";
      key = "${config.l3mon.secgen.secret_dir}/caddy_root_key";

      backup_files = [ key ];
      gen = pkgs.writeShellApplication {
        name = "gen";
        runtimeInputs = [ pkgs.openssl ];
        text =
        if config.l3mon.paths.nixos_config_dir == null then ''
          echo "Cannot update cert without updating it in config."
          exit
        '' else
        ''
          # https://stackoverflow.com/a/41366949
          # sha256 because firefox thinks sha-1 is outdated, throws SEC_ERROR_CERT_SIGNATURE_ALGORITHM_DISABLED
          # also rsa:4096 because ed25519 is "not prohibited but not supported".
          # see https://www.mozilla.org/en-US/about/governance/policies/security-group/certs/policy/
          openssl req -x509 -sha256 -newkey rsa:4096 -days 3650 -noenc -keyout ${key} -out ${cert_impure} -subj "/CN=l3mon4.de" -addext "subjectAltName=DNS:*.internal" -addext "keyUsage=critical,digitalSignature,keyCertSign"
          chown caddy:caddy ${key}
          chmod 400 ${key}
          chmod 444 ${cert_impure}
          echo "Make sure there is not remaining, old intermediate certs on caddy (remove /var/lib/caddy/.local/) and rebuild to update the local key."
        '';
      };
    };
    remarkable_cert = rec {
      cert_repo = "/data/generated/rmfakecloud_cert";
      cert_impure = "${config.l3mon.paths.nixos_config_dir}${cert_repo}";
      cert = ./.. + "${cert_repo}";
      key = "${config.l3mon.secgen.secret_dir}/rmfakecloud_cert_key";

      backup_files = [ key ];
      gen = pkgs.writeShellApplication {
        name = "gen";
        runtimeInputs = [ pkgs.openssl ];
        text =
        if config.l3mon.paths.nixos_config_dir == null then ''
          echo "Cannot update cert without updating it in config."
          exit
        '' else
        ''
          echo "
            1. enable rmfakecloudctl, set upstream to raw port, allow in firewall
            2. establish connection in xochitl
            3. rem: systemctl disable --now rmfakecloud-proxy and change entries in /etc/hosts
            4. indigo: scp root@10.0.0.5:/opt/var/rmfakecloud-proxy/rmfakecloud-proxy.crt ./
            5. indigo: scp root@10.0.0.5:/opt/var/rmfakecloud-proxy/rmfakecloud-proxy.key ./
            6. cp ./rmfakecloud-proxy.crt ${cert_impure}
            7. sudo cp ./rmfakecloud-proxy.crt ${key}
            7. sudo chown caddy:caddy ${key}
          "
        '';
      };
    };
    wifi_pw_alabaster = config.lib.l3mon.secgen.wpa2psk "wifi_alabaster";
    pw_alabaster = config.lib.l3mon.secgen.openwrt_pw "rootpw_alabaster";
    pw_ivory = config.lib.l3mon.secgen.openwrt_pw "rootpw_ivory";
    dsl_user = config.lib.l3mon.secgen.direct_secret "easybell_user";
    dsl_pw = config.lib.l3mon.secgen.direct_secret "easybell_password";
  };
}
