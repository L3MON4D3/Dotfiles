# Dotfiles

Contains configurations for various programs, split up into subdirectories.
Generally, these are symlinked into place by nixOS home-manager (or are
maintained in home-manager itself).

# TODO
* neovim: all packages needed for nvim-internal stuff (eg. zig for compiling
  ts-grammars) is also accessible in any shell spawneed by it. I don't really
  like that, I should only be able to access compilers etc. when in a devShell
  or when it's pulled in temporarily via `nix-shell -p ...`.
  A possible solution for binaries I invoke manually is to put their paths into
  some file, like 
  ```lua
  return {
    zig = "/nix/store/...zig-x.y.z",
    ...
  }
  ```
  and then don't rely on PATH being correct, but that does not work for plugins
  that need some binary :/
