{pkgs}: rec {
  assertSecret = sname: ''
    if [ ! -f /var/secrets/${sname} ]; then
      echo ASSERT FAILED: Secret ${sname} is missing!
      exit 1
    fi
  '';
  secret = (sname: "/var/secrets/${sname}");

  #
  # lua-write from nixpkgs does not respect `libraries`.
  #
  makeLuaWriter =
    lua: luaPackages: buildLuaPackages: name:
    {
      libraries ? [ ],
      ...
    }@args:
    pkgs.writers.makeScriptWriter (
      (builtins.removeAttrs args [ "libraries" ])
      // {
        interpreter = (if libraries == [] then lua.interpreter else (lua.withPackages (ps: libraries)).interpreter);
        check = (
          pkgs.writers.writeDash "luacheck.sh" ''
            exec ${buildLuaPackages.luacheck}/bin/luacheck "$1"
          ''
        );
      }
    ) name;

  writeLuajit = makeLuaWriter pkgs.luajit pkgs.luajitPackages pkgs.buildPackages.luajitPackages;
}
