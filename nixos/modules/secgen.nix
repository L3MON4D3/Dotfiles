{ config, lib, pkgs, machine, data, ... }:

with lib; {
  options.l3mon.secgen = {
    secrets = mkOption {
      type = types.attrsOf types.attrs;
      description = mdDoc ''
        Map secret-names to an attrset which has to have a key `gen`, which is a
        derivation that can generate a new secret, and a key `backup_relfiles`,
        which is a list of relative filepaths, and these will be backed up
        before a new secreet is generated.  
        The attrset may have other keys which can help accessing the secret.
      '';
      default = {};
    };
    secret_dir = mkOption {
      type = types.str;
      description = mdDoc ''
        Location of secrets.
      '';
      default = "/var/secrets";
    };
  };
  config = let
    format = pkgs.formats.yaml {};
    completely_spec = format.generate "completion.yaml" {
      secgen = attrsets.foldlAttrs (acc: k: v: acc ++ [k]) [] config.l3mon.secgen.secrets;
    };
    secgen_completion = pkgs.runCommand "secgen_completion" {} ''
      mkdir -p "$out/share/bash-completion/completions"
      ${pkgs.completely}/bin/completely generate ${completely_spec} "$out/share/bash-completion/completions/secgen"
    '';
  in {
    environment.systemPackages = with pkgs; [
      (writeShellApplication (let
        secbackup = secpath:
        # bash 
        ''
          if [[ -f "${secpath}" ]]; then
            mkdir -p "$(dirname /var/secrets/.old/${secpath})"
            BACKUP_PATH="/var/secrets/.old/${secpath}-$(date +%s)"
            install -D -o root -g root -m 400 "${secpath}" "$BACKUP_PATH"
          fi
        '';
      in {
        name = "secgen";
        text = ''
          if [[ $EUID -ne 0 ]]; then
            printf "secgen needs root to manipulate permissions on secrets."
            exit 1
          fi

          case "$1" in
        '' + (attrsets.foldlAttrs (acc: k: v: acc + ''
            ${k})
              ${builtins.concatStringsSep "\n" (builtins.map (secpath: secbackup secpath) v.backup_files)}
              ${v.gen}/bin/gen
              ;;
          '')  "" config.l3mon.secgen.secrets) +
          ''
            *)
              echo "$1 is not a valid secret-identifier!"
            esac
          '';
      }))
      secgen_completion
    ];
    lib.l3mon.secgen = let
      to_abspath = repo_abs_path: if config.l3mon.paths.nixos_config_dir != null then
          "${config.l3mon.paths.nixos_config_dir}${repo_abs_path}"
        else
          null;
      wireguardSpecKey = prefix: id: "wg-${prefix}-${id}";
      wireguardSpecKeySingle = prefix: "wg-${prefix}";
      to_entry = prefix: id: rec {
        keydir = "${config.l3mon.secgen.secret_dir}/${prefix}";
        key = "${keydir}/${id}.priv";
        nix_pubkey_repo = "/data/generated/wg_pub-${prefix}-${id}.nix";
        nix_pubkey_abs = to_abspath nix_pubkey_repo;

        backup_files = [ key ];
        gen = pkgs.writeShellApplication {
          name = "gen";
          runtimeInputs = [ pkgs.wireguard-tools ];
          text = ''
            KEY=$(wg genkey)
            PUBKEY=$(echo -n "$KEY" | wg pubkey)

            mkdir -p '${keydir}'
            echo -n "$KEY" > ${key}
            chown root:root ${key}
            chmod 400 ${key}

            ${if config.l3mon.paths.nixos_config_dir != null then ''
              echo -n "\"$PUBKEY\"" > ${nix_pubkey_abs}
              echo "Added pubkey to nixos config."
            '' else ''
              echo "Pubkey is $PUBKEY, add it to the config?"
            ''}
          '';
        };
      };
      to_remote_entry = prefix: rec {
        key = "${config.l3mon.secgen.secret_dir}/wg-${prefix}.priv";
        nix_data_repo = "/data/generated/wg-${prefix}.nix";
        nix_data_abs = to_abspath nix_data_repo;

        backup_files = [ key ];
        gen = pkgs.writeShellApplication {
          name = "gen";
          runtimeInputs = [ pkgs.wireguard-tools ];
          text = ''
            echo 'Enter Interface.PrivateKey:'
            read -r KEY
            echo "Read $KEY from stdin"

            echo 'Enter Interface.Address (v4,aaa.bbb.ccc.ddd):'
            read -r ADDRESS
            echo "Read $ADDRESS from stdin"

            echo 'Enter Interface.DNS:'
            read -r DNS
            echo "Read $DNS from stdin"

            echo 'Enter Peer.PublicKey:'
            read -r REMOTE_PUBKEY
            echo "Read $REMOTE_PUBKEY from stdin"

            echo 'Enter Peer.Endpoint:'
            read -r ENDPOINT
            echo "Read $ENDPOINT from stdin"

            PUBKEY=$(echo -n "$KEY" | wg pubkey)

            echo -n "$KEY" > ${key}
            chown root:root ${key}
            chmod 400 ${key}

            ${if nix_data_abs != null then ''
              echo -n "
              {
                pubkey = \"$PUBKEY\";
                address = \"$ADDRESS\";
                dns = \"$DNS\";
                remote_pubkey =  \"$REMOTE_PUBKEY\";
                remote_endpoint =  \"$ENDPOINT\";
              }" > ${nix_data_abs}
            '' else ''
              echo "Please add the data to the config manually!"
            ''}
          '';
        };
      };
    in {
      inherit wireguardSpecKey wireguardSpecKeySingle;
      mkWireguardSpecs = prefix: list: foldr (id: acc: acc // { "${wireguardSpecKey prefix id}" = (to_entry prefix id); }) {} list;
      mkRemoteWireguardSpecs = name: { "${wireguardSpecKeySingle name}" = (to_remote_entry name); };
      wpa2psk = id: rec {
        key = "${config.l3mon.secgen.secret_dir}/${id}";

        backup_files = [ key ];
        gen = pkgs.writeShellApplication {
          name = "gen";
          text = ''
            PASSWORD=""

            while : ; do
              echo 'Enter new password:'
              read -r PASSWORD

              if [ ''${#PASSWORD} -ge 8 ]; then
                break
              else
                echo "WPA-PSK2 key needs at least 8 characters!"
              fi
            done
            echo "Read password $PASSWORD from stdin"

            echo -n "$PASSWORD" > ${key}
            chown simon:simon ${key}
            chmod 400 ${key}
          '';
        };
      };
      openwrt_pw = id: rec {
        cleartext = "${config.l3mon.secgen.secret_dir}/${id}";
        hashed = "${config.l3mon.secgen.secret_dir}/${id}_hashed";

        backup_files = [ cleartext ];
        gen = pkgs.writeShellApplication {
          name = "gen";
          runtimeInputs = with pkgs; [ openssl ];
          text = ''
            PASSWORD=""

            while : ; do
              echo 'Enter new password:'
              read -r PASSWORD

              if [ ''${#PASSWORD} -ge 8 ]; then
                break
              else
                echo "WPA2-PSK key needs at least 8 characters!"
              fi
            done

            echo "Read password $PASSWORD from stdin"
            HASHED=$(echo "$PASSWORD" | openssl passwd -6 -stdin)

            echo -n "$PASSWORD" > ${cleartext}
            chown simon:simon ${cleartext}
            chmod 400 ${cleartext}

            echo -n "$HASHED" > ${hashed}
            chown simon:simon ${hashed}
            chmod 400 ${hashed}
          '';
        };
      };
      direct_secret = spec: rec {
        secret = "${config.l3mon.secgen.secret_dir}/${spec.id}";

        backup_files = [ secret ];
        gen = pkgs.writeShellApplication {
          name = "gen";
          runtimeInputs = with pkgs; [ openssl ];
          text = ''
            SECRET=""

            echo 'Enter new value for ${spec.id}:'
            read -r SECRET

            echo "Read secret $SECRET from stdin"

            echo -n "$SECRET" > ${secret}
            chown ${spec.owner}:${spec.owner} ${secret}
            chmod 400 ${secret}
          '';
        };
      };
    };
  };
}
