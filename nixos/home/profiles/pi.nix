{ config, lib, pkgs, machine, data, self, ... }:

let
  carmine_conf = self.nixosConfigurations.carmine.config;
in {
  home.file.".pi/agent/models.json" = {
    enable = true;
    text = builtins.toJSON {
      providers = {
        llama = {
          baseUrl = "http://${carmine_conf.lib.l3mon.networks.virtual.work.peers.jochspitze.address}:${toString data.ports.llama-cpp}/v1";
          api = "openai-completions";
          apiKey = "none";
          models = [
            {
              id = "Qwen3.5-35B-A3B";
            }
          ];
        };
      };
    };
  };
}
