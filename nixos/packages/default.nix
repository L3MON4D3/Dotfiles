final: prev: {
  # special scope for my own packages.
  l3mon = {
    netns-exec = prev.callPackage ./netns-exec.nix { };
  };
}
