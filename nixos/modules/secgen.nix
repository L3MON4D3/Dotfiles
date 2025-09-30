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
        secbackup = relpath:
        # bash 
        ''
          if [[ -f "/var/secrets/${relpath}" ]]; then
            mkdir -p "$(dirname /var/secrets/.old/${relpath})"
            BACKUP_PATH="/var/secrets/.old/${relpath}-$(date +%s)"
            install -D -o root -g root -m 400 "/var/secrets/${relpath}" "$BACKUP_PATH"
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
              ${builtins.concatStringsSep "\n" (builtins.map (relpath: secbackup relpath) v.backup_relfiles)}
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
  };
}
