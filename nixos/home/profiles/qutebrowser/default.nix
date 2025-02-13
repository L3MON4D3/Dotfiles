{ config, lib, pkgs, machine, data, ... }:

let
  colors = pkgs.writeText "colors" ''
    colors:
      statusbar:
          caret:
              bg: "#b16286"
              fg: "#fbf1c7"
          command:
              bg: "#1d2021"
              fg: "#fbf1c7"
              private:
                  bg: "#1d2021"
          insert:
              bg: "#b8bb26"
              fg: "#fbf1c7"
          normal:
              bg: "#1d2021"
              fg: "#fbf1c7"
          private:
              bg: "#1d2021"
              fg: "#fbf1c7"
          progress:
              bg: "#fbf1c7"
          url:
              fg: "#fbf1c7"
              error:
                  fg: "#cc241d"
              hover:
                  fg: "#458588"
              success:
                  http:
                      fg: "#fbf1c7"
                  https:
                      fg: "#fbf1c7"
              warn:
                  fg: "#d79921"
      tabs:
          bar:
              bg: "#1d2021"
          even:
              fg: "#928374"
              bg: "#1d2021"
          odd:
              fg: "#928374"
              bg: "#1d2021"
          selected:
              even:
                  fg: "#fbf1c7"
                  bg: "#1d2021"
              odd:
                  fg: "#fbf1c7"
                  bg: "#1d2021"
      completion:
          category:
              bg: "#fbf1c7"
              fg: "#1d2021"
              border:
                  bottom: "#fbf1c7"
                  top: "#fbf1c7"
          even:
              bg: "#1d2021"
          odd:
              bg: "#1d2021"
          item:
              selected:
                  bg: "#458588"
                  fg: "#fbf1c7"
                  border:
                      bottom: "#458588"
                      top: "#458588"
          fg:
              "#fbf1c7"
          match:
              fg: "#b8bb26"
          scrollbar:
              bg: "#fbf1c7"
              fg: "#1d2021"
      downloads:
          bar:
              bg: "#1d2021"
          error:
              fg: "#fbf1c7"
              bg: "#cc241d"
          start:
              fg: "#fbf1c7"
              bg: "#b16286"
          stop:
              fg: "#fbf1c7"
              bg: "#b8bb26"
      hints:
          fg: "#fbf1c7"
          bg: "#1d2021"
          match:
              fg: "#d79921"
      keyhint:
          fg: "#fbf1c7"
          bg: "#1d2021"
          suffix:
              fg: "#d79921"
      messages:
          error:
              fg: "#fbf1c7"
              bg: "#cc241d"
              border: "#cc241d"
          info:
              fg: "#fbf1c7"
              bg: "#b8bb26"
              border: "#b8bb26"
          warning:
              fg: "#fbf1c7"
              bg: "#d79921"
              border: "#d79921"
      prompts:
          fg: "#fbf1c7"
          bg: "#1d2021"
          border: "#1d2021"
          selected:
              bg: "#d79921"
  '';
in {
  programs.qutebrowser = {
    enable = true;
    extraConfig = (builtins.readFile ./config.py) + ''
      import yaml

      with open("${colors}") as f:
          yaml_data = yaml.safe_load(f)

      def dict_attrs(obj, path=""):
          if isinstance(obj, dict):
              for k, v in obj.items():
                  yield from dict_attrs(v, '{}.{}'.format(path, k) if path else k)
          else:
              yield path, obj

      for k, v in dict_attrs(yaml_data):
          config.set(k, v)
    '';
  };
}
