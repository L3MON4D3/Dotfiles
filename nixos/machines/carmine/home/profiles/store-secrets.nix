{ config, lib, pkgs, machine, data, ... }:

{
  home.packages = [
    (pkgs.writeShellApplication {
      name = "store-secrets";
      runtimeInputs = with pkgs; [ gnupg coreutils diffutils gnutar ];
      text =
      # bash
      ''
        TARGET_PATH=$(realpath "$1")
        FNAME=secrets.tar.gz

        UPDATE_SCRATCHDIR=$(mktemp -d)
        VERIFY_SCRATCHDIR=$(mktemp -d)

        function cleanup {
          rm -rf "$UPDATE_SCRATCHDIR"
          rm -rf "$VERIFY_SCRATCHDIR"
        }

        trap cleanup EXIT

        #
        # UPDATE
        #

        rsync -ar --delete --progress /home/simon/.password-store "$UPDATE_SCRATCHDIR"

        mkdir -p "$UPDATE_SCRATCHDIR"/gpgkeys
        gpg --output "$UPDATE_SCRATCHDIR"/gpgkeys/simon-public.pgp --armor --export simon@l3mon4.de
        gpg --output "$UPDATE_SCRATCHDIR"/gpgkeys/simon-private.pgp --armor --export-secret-key simon@l3mon4.de
        gpg --output "$UPDATE_SCRATCHDIR"/gpgkeys/simljk-public.pgp --armor --export simljk@outlook.de
        gpg --output "$UPDATE_SCRATCHDIR"/gpgkeys/simljk-private.pgp --armor --export-secret-key simljk@outlook.de
        gpg --output "$UPDATE_SCRATCHDIR"/gpgkeys/s6sikatz-public.pgp --armor --export s6sikatz@uni-bonn.de
        gpg --output "$UPDATE_SCRATCHDIR"/gpgkeys/s6sikatz-private.pgp --armor --export-secret-key s6sikatz@uni-bonn.de

        cd /var/secrets
        sudo tar -cvf "$UPDATE_SCRATCHDIR"/secrets.tar.gz ./*
        sudo chown simon:simon "$UPDATE_SCRATCHDIR"/secrets.tar.gz
        gpg --encrypt --output "$UPDATE_SCRATCHDIR/secrets.tar.gz.gpg" --recipient simon@l3mon4.de "$UPDATE_SCRATCHDIR"/secrets.tar.gz
        rm "$UPDATE_SCRATCHDIR"/secrets.tar.gz

        cd "$UPDATE_SCRATCHDIR"
        # preserve permissions/symlinks.
        tar -cvf "$TARGET_PATH/$FNAME" ./* ./.*

        #
        # VERIFY
        #
        tar -xvf "$TARGET_PATH/$FNAME" -C "$VERIFY_SCRATCHDIR"

        export GNUPGHOME="$VERIFY_SCRATCHDIR/.gnupg"
        mkdir -p "$GNUPGHOME"
        ln -s ~/.gnupg/gpg-agent.conf "$GNUPGHOME/gpg-agent.conf"

        gpg --import "$VERIFY_SCRATCHDIR/gpgkeys/simon-public.pgp"
        gpg --import "$VERIFY_SCRATCHDIR/gpgkeys/simon-private.pgp"
        gpg --import "$VERIFY_SCRATCHDIR/gpgkeys/simljk-public.pgp"
        gpg --import "$VERIFY_SCRATCHDIR/gpgkeys/simljk-private.pgp"
        gpg --import "$VERIFY_SCRATCHDIR/gpgkeys/s6sikatz-public.pgp"
        gpg --import "$VERIFY_SCRATCHDIR/gpgkeys/s6sikatz-private.pgp"


        if ! diff -qr "$VERIFY_SCRATCHDIR/.password-store" /home/simon/.password-store; then
          printf "preserved and present password-store differ!"
          exit
        fi

        gpg  --output "$VERIFY_SCRATCHDIR/secrets.tar.gz" --recipient simon@l3mon4.de --decrypt "$VERIFY_SCRATCHDIR/secrets.tar.gz.gpg"
        mkdir "$VERIFY_SCRATCHDIR/secrets"
        tar -xvf "$VERIFY_SCRATCHDIR/secrets.tar.gz" -C "$VERIFY_SCRATCHDIR/secrets"

        if ! sudo diff -qr "$VERIFY_SCRATCHDIR/secrets" /var/secrets; then
          printf "preserved and present secrets differ!"
          exit
        fi

        # created via `pass edit testkey` -> enter "testkeyvalue" -> `cat ~/.password-store/testkey.gpg | base64`
        # should be a good test for whether we can decrypt passwords using the stored keys.
        # (prevent accidentally reading from real store because testkey.gpg does not
        # exist in there, and uses the same keys because the file was generated using
        # the normal workflow.)
        # Have to update this if I ever change keys!
        base64 -d > "$VERIFY_SCRATCHDIR/.password-store/testkey.gpg" <<EOF
        hQGMAy2Y3BPlzvtIAQv/VqHtr0D7UMpK9whDlsWlmOEJe4P/o2PgLLYkadv0cFTmvA38MSYG0J2A
        u9hRgBzFWSjgJU0DEl4bjJdNKK95Q6MO/xV9GIPQ0kI9BydBelZXnxKTmIEsolWkAzIvKQgQNBia
        stUMDILQHPaZz+pC6ziJYXjysrLZtDAIZT9Gk03sUba2sP/eMwZ21lVSnmIiWhdxpHryFKkabPyS
        eJb0tb/VPOdS6scu7POL2l3MVI29yWvca85Fcrgqz2ftwpB8u4879/sYIXUB95u2oP9BTwMjXDlE
        v5rTi+DzBu3MfsinVNy7JOUjO3sdfBWEENThu9yj0NOanY9SVINnUebiIvr90lcFGwdoQxbWrvr+
        h0KBjNpRtGtp5u/XuxnokqrcQLg72RNIrYSEhhkQJ1PFdnL061btA/bRFRIUTQyK969qBSaEAwYg
        dDCS5C+SOz+xc1g6gaD9VJ8Mn1m/O2KBau4mGCpl/yw6j0RkOrK+Qc6SBIZOG3CwZs9pVA56eLPX
        0lUB6fGdWsqdE6TuoIQ7+7umDsReVmSzxu0eGhrcys3mneH5bzrtZUDxBdWtOXyUSNPo3NCQOiWM
        UsUa2EBmASkjOCSyJV+BC7oWTph85jg+GeDW/yts
        EOF

        if [ "$(PASSWORD_STORE_DIR="$VERIFY_SCRATCHDIR/.password-store" pass show testkey)" != "testkeyvalue" ]; then
          printf "cannot restore stored passwords!!"
          exit
        fi
      '';
    })
  ];
}
