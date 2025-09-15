{ buildLuarocksPackage, fetchFromGitHub, fetchurl, luaAtLeast, luaOlder }:
buildLuarocksPackage {
  pname = "k-stream";
  version = "0.1-2";
  knownRockspec = (fetchurl {
    url    = "https://luarocks.org/k-stream-0.1-2.rockspec";
    sha256 = "1b060m01438ybgdm2r1csxpxjmmrsp9blby94rlfg90shjlqi3qq";
  }).outPath;
  src = fetchFromGitHub {
    owner = "norcalli";
    repo = "lua-stream";
    rev = "k-stream-v0.1-2";
    hash = "sha256-xC8cfxEy3wfJNKLRiLqsOmYn8ReeBSX7/Ju1oR/mjgs=";
  };

  disabled = luaOlder "5.1" || luaAtLeast "5.4";

  meta = {
    homepage = "https://github.com/norcalli/lua-stream.git";
    description = "No summary";
    license.fullName = "MIT";
  };
}
