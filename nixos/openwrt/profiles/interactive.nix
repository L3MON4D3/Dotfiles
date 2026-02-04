{
  packages = ["vim-full" "more" ]
  # replace shinit with a version that does not attempt aliases for more/vim.
  etc.shinit.text =
  # bash
  ''
    alias ll='ls -alF --color=auto'

    # more stuff from the default openwrt image.
    [ -z "$KSH_VERSION" -o \! -s /etc/mkshrc ] || . /etc/mkshrc

    [ -x /usr/bin/arp -o -x /sbin/arp ] || arp() { cat /proc/net/arp; }
    [ -x /usr/bin/ldd ] || ldd() { LD_TRACE_LOADED_OBJECTS=1 $*; }

    [ -n "$KSH_VERSION" -o \! -s "$HOME/.shinit" ] || . "$HOME/.shinit"
    [ -z "$KSH_VERSION" -o \! -s "$HOME/.mkshrc" ] || . "$HOME/.mkshrc"
  '';
}
