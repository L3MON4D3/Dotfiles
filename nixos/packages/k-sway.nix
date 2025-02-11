{ buildLuarocksPackage, fetchFromGitHub, fetchurl, l3mon, luaAtLeast, luaOlder, luaposix, lua-cjson }:

buildLuarocksPackage {
  pname = "k-sway";
  version = "0.1-2";
  knownRockspec = (fetchurl {
    url    = "mirror://luarocks/k-sway-0.1-2.rockspec";
    sha256 = "123lw97s45zl6mfldk9d32j4x5nmv0d2rs6n7scjas7b3r015jm1";
  }).outPath;
  src = fetchFromGitHub {
    owner = "norcalli";
    repo = "lua-sway";
    rev = "k-sway-v0.1-2";
    hash = "sha256-7uhFNUzp1MDUULJXWK6coW/H3bEqxp4AooIMcALab8o=";
  };

  postConfigure = ''
    substituteInPlace ''${rockspecFilename} --replace-warn "luaposix ~> 34.0" "luaposix >= 34.0"
    substituteInPlace ''${rockspecFilename} --replace-warn '-- "struct ~> 1.4"; -- Optional' '"struct ~> 1.4"'
    echo $(cat rockspecs/k-sway-0.1-2.rockspec)
  '';

  disabled = luaOlder "5.1" || luaAtLeast "5.4";
  propagatedBuildInputs = [ l3mon.k-stream l3mon.struct lua-cjson luaposix ];

  meta = {
    homepage = "https://github.com/norcalli/lua-sway";
    description = "No summary";
    license.fullName = "MIT";
  };
}
