{pkgs}: let
  lib = pkgs.lib;
in rec {
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

  deepMerge =
  lhs: rhs:
  lhs
  // rhs
  // (builtins.mapAttrs (
    rName: rValue:
    let
      lValue = lhs.${rName} or null;
    in
    if builtins.isAttrs lValue && builtins.isAttrs rValue then
      deepMerge lValue rValue
    else if builtins.isList lValue && builtins.isList rValue then
      lValue ++ rValue
    else
      rValue
  ) rhs);

  # return path of some attrset, searches up to some specific depth.
  # search = with builtins; let
    # search_attrlist = x: attrlist: depth:
    # if length attrlist == 0 then
      # null
    # else
      # let
        # firstval = (head attrlist).value;
        # firstkey = (head attrlist).name;
        # can_recurse = isAttrs firstval && depth > 0;
        # recurse_res = search x firstval (depth - 1);
        # tail_res = search_attrlist x (tail attrlist) depth;
      # in
        # if firstval == x then
          # [firstkey]
        # else
          # if can_recurse && recurse_res != null then
            # [firstkey] ++ recurse_res
          # else
            # tail_res;
  # in x: attrs: depth: search_attrlist x (pkgs.lib.attrsToList attrs) depth;

  mergeAttrlist = with builtins; attrslist: if length attrslist == 0 then {} else (head attrslist) // mergeAttrlist (tail attrslist);

  mod = x: n: x - (n * (x / n));
  pow = n : i :
          if i == 1 then n
          else if i == 0 then 1
          else n * pow n (i - 1);
  sum = builtins.foldl' builtins.add 0;

  # turns string like /24 into 255.255.255.0
  newmask_to_oldmask = newmask: let
    masklen = newmask: lib.toIntBase10 (lib.substring 1 (-1) newmask);
    len_to_mask_decbits = masklen: builtins.genList (x: if x < masklen then pow 2 (mod x 8) else 0) 32;
    get_byte = idx: decbits: lib.sublist (idx*8) 8 decbits;
    mask_decbits = len_to_mask_decbits (masklen newmask);
  in
    toString (sum (get_byte 0 mask_decbits)) + "." +
    toString (sum (get_byte 1 mask_decbits)) + "." +
    toString (sum (get_byte 2 mask_decbits)) + "." +
    toString (sum (get_byte 3 mask_decbits));
}
