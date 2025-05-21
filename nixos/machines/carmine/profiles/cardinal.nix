{ config, lib, pkgs, pkgs-unstable, machine, data, ... }:

let
  cardinal = pkgs-unstable.cardinal;
in {
  environment.systemPackages = let 
    jack = pkgs.pipewire.jack;
  in [
    ((pkgs-unstable.cardinal.override { libjack2 = jack; }).overrideAttrs (old: {
      # manually merge postInstall, seems to fickle to do otherwise.
      postInstall = if old.postInstall == ''
        wrapProgram $out/bin/Cardinal \
        --suffix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ jack ]}

        wrapProgram $out/bin/CardinalMini \
        --suffix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ jack ]}

        # this doesn't work and is mainly just a test tool for the developers anyway.
        rm -f $out/bin/CardinalNative
      '' then ''
        wrapProgram $out/bin/Cardinal \
        --prefix PATH : ${lib.makeBinPath [pkgs.xdg-utils]} \
        --suffix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ jack ]}

        wrapProgram $out/bin/CardinalMini \
        --prefix PATH : ${lib.makeBinPath [pkgs.xdg-utils]} \
        --suffix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ jack ]}

        # this doesn't work and is mainly just a test tool for the developers anyway.
        rm -f $out/bin/CardinalNative
      ''
      else
        builtins.throw "Update manually merged postInstall!! Currently is ${old.postInstall}.";
    }))
  ];
}
