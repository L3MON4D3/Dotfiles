{ config, lib, pkgs, machine, l3lib, inputs, data, system, microvm, ... }:

let
  vmname = "merigold";
  vm_runtimedir = "/var/lib/microvms/${vmname}";
  lan = data.network.lan;
  mgconf = {
    hostname = "${vmname}";
    address = "${lan.peers.${vmname}.address}/24";
    mac = "${lan.peers.${vmname}.mac_address}";
    host_if = "${lan.peers.${machine}.phys_interface}";
    host_macvtapname = "macvtap-mg";
    gateway_ip = "${lan.gateway_peer.address}";
    gateway_mac = "${lan.gateway_peer.mac}";
    localnet_allowlist = [
      lan.peers.carmine
      lan.peers.indigo
    ];
    pubkey = data.pubkey; # allowed ssh-pubkey
    guest_keyfile = l3lib.secret "merigold-key";
    guest_pubkeyfile = l3lib.secret "merigold-pubkey";
    share_store = false;
    password = null; # set to null on production server!!
    systemPackages = with pkgs; []; # remove for production.
    img_path = "${vm_runtimedir}/var.img";
    control_socket = "${vm_runtimedir}/control.socket";
  };
  nftable = inputs.merigold.lib.${system}.mkRuleset mgconf;
in {
  microvm = {
    vms = {
      merigold = {
        # use same packages as flake.
        pkgs = import inputs.merigold.inputs.nixpkgs {inherit system;};
        config = inputs.merigold.nixosModules.${system}.merigold;
        specialArgs.mgconf = mgconf;
      };
    };
  };

  systemd.services."microvm-macvtap-interfaces@merigold" = {
    overrideStrategy = "asDropin";
    postStart = ''
      ${pkgs.nftables}/bin/nft -f ${nftable}
    '';
  };
}
