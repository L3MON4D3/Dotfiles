{ config, lib, pkgs, machine, data, ... }:

let 
  kimmify = pkgs.writeShellApplication {
    name = "kimmify";
    runtimeInputs = with pkgs; [ ffmpeg util-linux ripgrep coreutils ];
    text = ''
      TARGET_DIR=/srv/media/video/kim

      for FILE_PATH in "$@"
      do
        FNAME=$(basename -- "$FILE_PATH")

        # map video, audio, and subtitle-streams.
        # copy subtitles, transcode video to h264 1080p, transcode audio to aac.
        # use crf23 for a bitrate appropriate to that TV.
        # use veryslow so the files are as small as possible (transcoding happens overnight anyway, so that should be fine :D)
        # profile high and level 4.1 are recommended [here](https://developers.google.com/cast/docs/media)
        #
        # Apply tonemapping (reinhard) and keep 4:2:0 chroma planes.
        # The resulting video is not profile high but profile constrained baseline, but that seems fine :)
        #
        # 0:V to exclude cover art.

        IS_HDR=$(ffmpeg -i "''${FILE_PATH}" 2>&1 | rg -o bt2020) || true
        EXTRA_vf=""
        if [[ -n "''${IS_HDR}" ]]; then
          EXTRA_vf="zscale=t=linear:npl=100,format=gbrpf32le,zscale=p=bt709,tonemap=tonemap=reinhard:desat=0,zscale=t=bt709:m=bt709:r=tv,"
        fi

        # confine ffmpeg to all but the first core.
        # for nvenc: -hwaccel -vcodec h264_nvenc -preset p7 (for example).
        taskset -c 1-"$(lscpu | rg ^CPU.s.: | rg -o -e '\d')" ffmpeg -i "''${FILE_PATH}" \
          -map 0:V \
            -vf "scale=1920:-1,pad=width=ceil(iw/2)*2:height=ceil(ih/2)*2,''${EXTRA_vf}format=yuv420p," \
            -profile:v high \
            -level:v 4.1 \
            -vcodec libx264 \
            -crf 22 \
            -preset veryslow \
          -map 0:a \
            -acodec aac \
          -map 0:s? \
            -c:s copy \
          "$TARGET_DIR/$FNAME"
      done
    '';
  };
in {
  environment.systemPackages = [
    kimmify
  ];
  systemd.tmpfiles.rules = [
    "d /srv/media/video/kim 750 simon simon"
  ];
}
