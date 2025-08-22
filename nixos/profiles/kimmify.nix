{ config, lib, pkgs, machine, data, ... }:

let 
  kimmify = pkgs.writeShellApplication {
    name = "kimmify";
    runtimeInputs = with pkgs; [ (ffmpeg.override {withPlacebo=true;}) util-linux ripgrep coreutils ];
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

        # confine ffmpeg to all but the first core.
        # for nvenc: -hwaccel -vcodec h264_nvenc -preset p7 (for example).
        taskset -c 1-"$(lscpu | rg ^CPU.s.: | rg -o -e '\d+')" ffmpeg -y -init_hw_device vulkan=vk -filter_hw_device vk -hwaccel vulkan -i "''${FILE_PATH}" \
          -map 0:V \
            -vf "libplacebo=w=1920:h=1080:force_original_aspect_ratio=decrease:normalize_sar=true:upscaler=ewa_lanczos:downscaler=ewa_lanczos:colorspace=bt709:color_primaries=bt709:color_trc=bt709:range=tv:format=yuv420p" \
            -profile:v high \
            -level:v 4.1 \
            -vcodec libx264 \
            -crf 19 \
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
