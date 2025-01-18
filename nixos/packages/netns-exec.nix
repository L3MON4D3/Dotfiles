{
  iproute2,
  # mount
  util-linux,
  bashInteractive,
  writeShellApplication,
  writeTextFile,
  symlinkJoin,
  installShellFiles
}:
let
  netns-exec-completion = writeTextFile {
    name = "netns-exec-completion";
    destination = "/share/bash-completion/completions/netns-exec";
    text = ''
      _comp_cmd_ip__netns()
      {
          local unquoted
          _comp_split -l unquoted "$(
              {
                  ''${1-ip} -c=never netns list 2>/dev/null || ''${1-ip} netns list
              } | command sed -e 's/ (.*//'
          )"
          # namespace names can have spaces, so we quote all of them if needed
          local ns quoted=()
          for ns in "''${unquoted[@]}"; do
              local namespace
              printf -v namespace '%q' "$ns"
              quoted+=("$namespace")
          done
          ((''${#quoted[@]})) && _comp_compgen -- -W '"''${quoted[@]}"'
      }

      _netns-exec()
      {
          local cur
          cur="''${COMP_WORDS[$COMP_CWORD]}"
          if [[ $COMP_CWORD == 1 ]] ; then
              _comp_cmd_ip__netns ip
              return 0
          fi
          if [[ $COMP_CWORD -ge 2 ]] ; then
              _comp_command_offset 2
              return 0
          fi
      }

      complete -F _netns-exec netns-exec
    '';
  };
  netns-exec-script = writeShellApplication {
    name = "netns-exec";
    runtimeInputs = [iproute2 util-linux bashInteractive];
    text = ''
      if [ $# -lt 1 ]; then
        echo "Provide a network-namespace as the first argument!"
        exit 1
      fi

      NETNS=$1
      shift
      COMMAND="$*"

      if [ -z "$COMMAND" ]; then
        COMMAND=bash
      fi

      sudo ip netns exec "''${NETNS}" bash -c "mount --bind /var/empty /var/run/nscd; $COMMAND"
    '';
  };
in
symlinkJoin {
  name = "netns-exec";
  paths = [ netns-exec-script netns-exec-completion ];
}
