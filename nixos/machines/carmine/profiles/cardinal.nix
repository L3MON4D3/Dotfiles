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

  services.pipewire.wireplumber = {
    extraConfig = {
      "91-cardinal" = {
        "wireplumber.components" = [
          {
            name = "cardinal.lua";
            type = "script/lua";
            provides = "custom.cardinal";
          }
        ];

        "wireplumber.profiles" = {
          main = {
            "custom.cardinal" = "required";
          };
        };
      };
    };
    extraScripts = {
      "cardinal.lua" = ''
        -- derived from https://github.com/bennetthardwick/dotfiles/blob/master/.config/wireplumber/scripts/auto-connect-ports.lua
        function link_ports(output_port, input_port)
          if not input_port or not output_port then
            return nil
          end

          local link_args = {
            ["link.input.node"] = input_port.properties["node.id"],
            ["link.input.port"] = input_port.properties["object.id"],

            ["link.output.node"] = output_port.properties["node.id"],
            ["link.output.port"] = output_port.properties["object.id"],

            -- The node never got created if it didn't have this field set to something
            ["object.id"] = nil,

            -- I was running into issues when I didn't have this set
            ["object.linger"] = true,

            ["node.description"] = "Link created by auto_connect_ports"
          }

          local link = Link("link-factory", link_args)
          link:activate(1)

          return link
        end

        function auto_connect_ports(args)
          local output_om = ObjectManager {
            Interest {
              type = "port",
              args["output"],
              Constraint { "port.direction", "equals", "out" }
            }
          }

          local links = {}

          local input_om = ObjectManager {
            Interest {
              type = "port",
              args["input"],
              Constraint { "port.direction", "equals", "in" }
            }
          }

          function _connect()
            for output_name, input_name in pairs(args.connect) do
              for output in output_om:iterate { Constraint { "port.name", "equals", output_name } } do
                for input in input_om:iterate { Constraint { "port.name", "equals", input_name } } do
                  local link = link_ports(output, input)

                  if link then
                    table.insert(links, link)
                  end
                end
              end
            end
          end

          output_om:connect("object-added", _connect)
          input_om:connect("object-added", _connect)

          output_om:activate()
          input_om:activate()
        end

        -- Auto connect the stereo null sink to the first two channels of the EVO16
        auto_connect_ports {
          output = Constraint { "port.alias", "matches", "Cardinal:*" },
          input = Constraint { "port.alias", "matches", "UMC202HD 192k:*" },
          connect = {
            ["audio_out_1"] = "playback_FL",
            ["audio_out_2"] = "playback_FR",
          }
        }
      '';
    };
  };
}
