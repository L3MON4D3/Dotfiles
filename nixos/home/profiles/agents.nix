{
  config,
  lib,
  pkgs,
  machine,
  data,
  inputs,
  system,
  self,
  ...
}:

let
  llm-agents = inputs.llm-agents.packages.${system};
  mkAgent =
    configs:
    inputs.agents.lib.${system}.mkAgent {
      imports = configs;
    };
  agentFromConfPaths =
    # takes strings like "agents.defaultConf", ie. paths in the config relative to userLib, as defined below.
    extraConfPaths:
    let
      extraConfItems = builtins.foldl' (acc: val: acc + " userLib.${val}") "" extraConfPaths;
    in
    pkgs.writeShellApplication {
      name = "agent";
      text = ''
        # impure necessary despite flake-reference in store.
        nix run --impure --expr '
          {conf}:
          let
            userLib = (builtins.getFlake "${self}").nixosConfigurations.${machine}.config.home-manager.users.simon.lib.l3mon;
          in {
            res = userLib.agents.mkAgent [ userLib.agents.defaultConf ${extraConfItems} conf ];
          }' res \
          --arg conf "$1" \
      '';
    };
in
{
  lib.l3mon.agents.defaultConf =
    let
      wg_work = inputs.home-dotfiles.nixosConfigurations.indigo.config.lib.l3mon.networks.virtual.work;
      wg_work_peerconf = wg_work.peers.${machine};
    in
    { pkgs, lib, ... }:
    {
      agent.protectGit = true;
      copilot.package = llm-agents.copilot-cli;
      pi = {
        package = llm-agents.pi;
        providers.llama = {
          baseUrl = "http://${wg_work_peerconf.address}:${toString data.ports.llama-cpp}/v1";
          api = "openai-completions";
          apiKey = "none";
          models = [
            {
              id = "Qwen3.5-35B-A3B";
            }
          ];
        };
        settings = {
          defaultProvider = "llama";
          defaultModel = "Qwen3.5-35B-A3B";
        };
      };
    };
  lib.l3mon.agents.mkAgent = mkAgent;
  lib.l3mon.agents.agentFromConfPaths = agentFromConfPaths;

  home.packages = [
    (agentFromConfPaths [ ])
  ];
}
