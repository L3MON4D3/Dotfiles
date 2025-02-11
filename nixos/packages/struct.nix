{ buildLuarocksPackage, fetchurl, luaAtLeast, luaOlder }:
buildLuarocksPackage {
  pname = "struct";
  version = "1.4-1";
  knownRockspec = (fetchurl {
    url    = "mirror://luarocks/struct-1.4-1.rockspec";
    sha256 = "142zbyzqcqmhq10xwnv6h4h5f46gbkbvdfsg9avi8gc3l70y235h";
  }).outPath;
  src = fetchurl {
    url    = "http://www.inf.puc-rio.br/~roberto/struct/struct-0.2.tar.gz";
    sha256 = "19d72xlflyxs4dpk3d6wafphs82iaql62ngpfflp9b3lkygiy7f7";
  };
  # nix complains if unpacking does not produce a directory => just unpack into
  # some directory and adjust all paths.
  unpackPhase = ''
    echo $out
    mkdir struct
    tar -xvf $src -C struct
  '';
  postConfigure = ''
    substituteInPlace ''${rockspecFilename} --replace-warn '"struct.c"' '"struct/struct.c"'
  '';

  disabled = luaOlder "5.1" || luaAtLeast "5.3";

  meta = {
    homepage = "http://www.inf.puc-rio.br/~roberto/struct/";
    description = "A library to convert Lua values to and from C structs";
    license.fullName = "MIT/X";
  };
}
