final: prev: {
  # special scope for my own packages.
  l3mon = {
    iosevka = prev.callPackage ./iosevka.nix { };
    k-sway = prev.luajitPackages.callPackage ./k-sway.nix { };
    k-stream = prev.luajitPackages.callPackage ./k-stream.nix { };
    struct = prev.luajitPackages.callPackage ./struct.nix { };
  };
}
