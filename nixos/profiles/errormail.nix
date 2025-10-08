{ config, lib, l3lib, pkgs, machine, data, ... }:

let
  target_email = "simon@l3mon4.de";
  notify-generic = pkgs.writeShellApplication {
    name = "notify-generic";
    runtimeInputs = with pkgs; [ msmtp ];
    text = ''
      sendmail -t <<ERRMAIL
      To: ${target_email}
      From: ${machine}
      Subject: $1
      Content-Transfer-Encoding: 8bit
      Content-Type: text/plain; charset=UTF-8

      $2
      ERRMAIL
    '';
  };
  notify-systemd = pkgs.writeShellApplication {
    name = "notify-systemd";
    runtimeInputs = with pkgs; [ msmtp ];
    text = ''
      sendmail -t --passwordeval="cat $2" <<ERRMAIL
      To: ${target_email}
      From: systemd@${machine}
      Subject: Status of $1
      Content-Transfer-Encoding: 8bit
      Content-Type: text/plain; charset=UTF-8

      Current unit status: "$1"
      $(systemctl status --full "$1")

      Journal of unit starting at T-60s:

      $(journalctl -u "$1" --since=-60)
      ERRMAIL
    '';
  };
  notify-stdin = pkgs.writeShellApplication {
    name = "notify-stdin";
    runtimeInputs = with pkgs; [ msmtp coreutils ];
    text = ''
      stdin=$(cat)

      sendmail -t <<ERRMAIL
      To: ${target_email}
      From: ${machine}
      Subject: $1
      Content-Transfer-Encoding: 8bit
      Content-Type: text/plain; charset=UTF-8

      $stdin
      ERRMAIL
    '';
  };
in {
  programs.msmtp = {
    enable = true;
    accounts.default = {
      auth = true;
      tls = true;
      host = "smtp.mailbox.org";
      from = "simon@l3mon4.de";
      user = "simon@l3mon4.de";
      passwordeval = "${pkgs.coreutils}/bin/cat ${config.l3mon.secgen.secrets.mailbox_msmtp.file}";
    };
  };

  environment.systemPackages = [
    notify-stdin
    notify-generic
  ];

  # See https://github.com/systemd/systemd/issues/22737
  assertions = [ {
    assertion = config.services.dbus.implementation == "broker";
    message = "Enable dbus-broker to make sure that dynamicUser is allowed access to dbus.";
  } ];

  systemd.services."statusmail@" = {
    description = "Send email with status of service %i to ${target_email}.";
    serviceConfig = {
      LoadCredential = "smtp_password:${config.l3mon.secgen.secrets.mailbox_msmtp.file}";
      DynamicUser = true;
      # file in passwordeval is only accessible to root, pass it through for
      # this service.
      ExecStart = "${notify-systemd}/bin/notify-systemd %i %d/smtp_password";
      # allow reading journal-entries for various services.
      Group = "systemd-journal";
    };
  };

  systemd.packages = [
    (pkgs.writeTextDir "etc/systemd/system/service.d/errormail.conf" (lib.generators.toINI {}
      {
        Unit.OnFailure = "statusmail@%n.service";
      }
    ))
  ];
}
