{ self, lib, pkgs, ... }: {
  config.lib.secrets = let
    map_secret = name: path: {
      ${name} = { id = name; path = path;};
    };
    secrets = self.nixosConfigurations.carmine.config.l3mon.secgen.secrets;
    secmap = {
      ivory_pw_hashed = secrets.pw_ivory.hashed;
      alabaster_pw_hashed = secrets.pw_alabaster.hashed;
      alabaster_wifi_pw = secrets.wifi_pw_alabaster.key;
    };
  in rec {
    # map internal name to internal name and secret-path.
    secretmap =
      secmap |> lib.foldlAttrs (acc: key: val: acc // map_secret key val) {};
    secret_command = let
      keylines = secretmap |> lib.foldlAttrs (acc: _: val: acc ++ [''\"${val.id}\": $(cat ${val.path} | jq -Rsa .)'']) [] |> lib.join ",\n";
    in pkgs.writeShellApplication {
      name = "get";
      runtimeInputs = with pkgs; [jq];
      text = ''
        echo -n "{"
        echo -n "
        ${keylines}
        "
        echo -n "}"
      '';
    };
  };
}
