let
  nft_conf_path_etc_relative = "nftables.conf";
  nft_conf_path = "/etc/${nft_conf_path_etc_relative}";
in {
  rcservices.disableServices = [ "firewall" ];
  etc = {
    "rc.local".text = ''
      nft -f ${nft_conf_path}
    ''; 
    ${nft_conf_path_etc_relative}.text = builtins.readFile ./nftables.conf;
  };
}
