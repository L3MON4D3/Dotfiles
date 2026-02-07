{config, lib, ... }: 

with lib;
let
  cfg = config.rcservices;
in {
  options.rcservices.disableServices = lib.mkOption {
    type = with types; listOf str;
    description = "List of rc-services to disable.";
    default = [];
  };

  config = {
    deploySteps.rcservices = {
      # same as other /etc modifications.
      priority = 20;
      apply = foldl' (acc: name: acc + "rm -f /etc/rc.d/*'${name}'\n") "" cfg.disableServices;
    };
  };
}
