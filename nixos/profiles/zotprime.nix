{ config, lib, pkgs, pkgs-unstable, machine, data, ... }:

let
  map_imagespec = name: spec: pkgs.dockerTools.pullImage {
    inherit (spec) imageDigest hash;
    imageName = "uniuu/${name}";
    finalImageName = name;
    finalImageTag = "system";
  };
  # all version v3.2.0.
  # generate hashes via nix-prefetch-docker.
  imagespecs = {
    # zotprime-init uses this one too.
    zotprime-dataserver = {
      imageDigest = "sha256:acc6f448e104f5507097d2bcea7c7822893868acbc3f7b481e62069102389f80";
      hash = "sha256-90byTkDA4YTSp8YLngWTC/APUL1EqKmx3LwV6mOSL4c=";
    };
    zotprime-db = {
      imageDigest = "sha256:bf6119e52422de4d2f6f3b4547f09bc71479629b9ddfc16ac7fb1c17d0c6c1f5";
      hash = "sha256-ftGLmgrwTwKoL3LvAOsYd7xWBQHEggpJ4RWVwKhwbU8=";
    };
    zotprime-elasticsearch = {
      imageDigest = "sha256:99c41801f379c6aea2981646d25328da45629cd8fa10ab58bf35336a7017305d";
      hash = "sha256-Zs4/i5dFnuiyDgUYxnSDOjTkPRZEXTBcifl8fgfGEmA=";
    };
    zotprime-localstack = {
      imageDigest = "sha256:37a339bd143f54aedba5e3c28575cf866a813129c788db96486d8a79e910a8fc";
      hash = "sha256-rE1lQgwYKam/FRGI4FVeTiZKLwae5EDAx1XXki05N0A=";
    };
    zotprime-memcached = {
      imageDigest = "sha256:9ac5aedfdcdf4c60c8afc75ba656781015269b654031b0e528e032c150d38c7a";
      hash = "sha256-1QzFcQTnCdm47kDn4+33Qb1ac/DrOSBGqzSjlqRLpfI=";
    };
    zotprime-minio = {
      imageDigest = "sha256:e1dc778618da57d698c5b96fe082231c904834f93765ae256e35858fc14ce6e2";
      hash = "sha256-YYuTdHLzw8t+dHQQ0bAgxrnWGJ7FCmUhgmpIflXPgA4=";
    };
    zotprime-phpmyadmin = {
      imageDigest = "sha256:f679505ff36d389cdc4d23371b166b5df999fe77e6e5befe428ee76b24b7b350";
      hash = "sha256-/0SFxmI/VRm2YtRnwQzjFO0EVi0Zb70eCXudsp6HuoY=";
    };
    zotprime-redis = {
      imageDigest = "sha256:a4bd7e6fd336e1b3d0408aff8f32c7c926f0f9cc88c13ec3d4e50ae16d1b8688";
      hash = "sha256-Zyes3bM9/+Vv1DQ5A4CNVGMx109Ey4CgMm0n7k1514c=";
    };
    zotprime-streamserver = {
      imageDigest = "sha256:b5afe57326726666df0aeefbff2d3dbc52da92e6a0196d2f2bc11c370809388e";
      hash = "sha256-Jv6SeAff3hm6cgXYG2g57/IjPcOmjNUS6Ji2pPB197o=";
    };
    zotprime-tinymceclean = {
      imageDigest = "sha256:77aa9abf445a002fed4d5c1610534bf0b84517c5885ed4f92795828cde386319";
      hash = "sha256-h6EBuiYX8lTf2Dnnew+/y6QtGdPsDymuCWwWz626uIk=";
    };
    zotprime-portal = {
      imageDigest = "sha256:4e2dcb3255d3d8120e9680adbe6bc59edfdd159e267a33a01fb49b10e00c2a27";
      hash = "sha256-knTBO1chc7pjq9KCzzAvG/pAGpA5fkR5wdJrwwhJ4sQ=";
    };
    zotprime-admin = {
      imageDigest = "sha256:ecbb15263695e50f6659bf865e7b95bf9ad76507911515c8729b5564db693450";
      hash = "sha256-YpzdMMalkfPUWVrtf0+mVuuWtGNdSRyW3QnUA21yzHI=";
    };
  };
  images = lib.attrsets.mapAttrs map_imagespec imagespecs;
  
  zotprime_src = pkgs-unstable.fetchFromGitHub {
    owner = "uniuuu";
    repo = "zotprime";
    rev = "c9456e1213a55babdd23389a72622a89b7388afc";
    sha256 = "sha256-Tax1POYbHvPCIwmgt49ImBH5uUTW44GnO886YHOAhco=";
  };
  compose = pkgs-unstable.runCommand "zotprime-compose2nix" {
    nativeBuildInputs = with pkgs-unstable; [ compose2nix ];
  } ''
    cp ${zotprime_src}/docker-compose.yml .

    # compose2nix ignores services defined with a profile.
    substituteInPlace ./docker-compose.yml --replace-fail 'profiles: ["admin"]' ""
    substituteInPlace ./docker-compose.yml --replace-fail 'profiles: ["portal"]' ""

    # make repo-relative files absolute.
    substituteInPlace ./docker-compose.yml --replace-fail './' '${zotprime_src}/'

    # Not sure where this one should be coming from.
    sed -i 's/- SECURE_COOKIES=.*//' ./docker-compose.yml

    compose2nix -project=zotprime

    # modify ports
    substituteInPlace ./docker-compose.nix --replace-fail '"8080' '"''${toString data.ports.zotprime-zotero-api}'
    substituteInPlace ./docker-compose.nix --replace-fail '"9000' '"''${toString data.ports.zotprime-s3}'
    substituteInPlace ./docker-compose.nix --replace-fail '"8082' '"''${toString data.ports.zotprime-admin}'
    substituteInPlace ./docker-compose.nix --replace-fail '"8083' '"''${toString data.ports.zotprime-phpmyadmin}'
    substituteInPlace ./docker-compose.nix --replace-fail '"9001' '"''${toString data.ports.zotprime-s3-webui}'
    substituteInPlace ./docker-compose.nix --replace-fail '"8081' '"''${toString data.ports.zotprime-streamserver}'
    substituteInPlace ./docker-compose.nix --replace-fail '"3045' '"''${toString data.ports.zotprime-portal}'

    # fix path to podman for systemd service
    substituteInPlace ./docker-compose.nix --replace-fail '"podman network rm' '"''${pkgs.podman}/bin/podman network rm'

    # get `data` into module.
    substituteInPlace ./docker-compose.nix --replace-fail '{ pkgs, lib, config, ... }:' '{ pkgs, lib, config, data, ... }:'

    # remove env-vars related to secrets.
    # They are added via environmentFiles (mapping to --env-file).
    # Unfortunately, the env-variables declared directly in the compose-file
    # map to --env, and that supersedes env-variables loaded from a file.
    # So, remove all secret env-vars in `environment`-sections.
    sed -i 's/"MARIADB_ROOT_PASSWORD" =.*//' ./docker-compose.nix
    sed -i 's/"MARIADB_DATABASE" =.*//' ./docker-compose.nix
    sed -i 's/"MARIADB_USER" =.*//' ./docker-compose.nix
    sed -i 's/"MARIADB_PASSWORD" =.*//' ./docker-compose.nix

    sed -i 's/"MINIO_ROOT_USER" =.*//' ./docker-compose.nix
    sed -i 's/"MINIO_ROOT_PASSWORD" =.*//' ./docker-compose.nix

    sed -i 's/"SERVER_IP" =.*//' ./docker-compose.nix
    sed -i 's/"AUTH_SALT" =.*//' ./docker-compose.nix
    sed -i 's/"API_SUPER_TOKEN" =.*//' ./docker-compose.nix
    sed -i 's/"API_SUPER_TOKEN_HASH" =.*//' ./docker-compose.nix
    sed -i 's/"AWS_ACCESS_KEY_ID" =.*//' ./docker-compose.nix
    sed -i 's/"AWS_SECRET_ACCESS_KEY" =.*//' ./docker-compose.nix
    sed -i 's/"WEBADMIN_PASSWORD" =.*//' ./docker-compose.nix
    sed -i 's/"WEBADMIN_USERNAME" =.*//' ./docker-compose.nix
    sed -i 's/"APP_KEY" =.*//' ./docker-compose.nix
    sed -i 's/"ADMIN_EMAIL" =.*//' ./docker-compose.nix
    sed -i 's/"ADMIN_PASSWORD" =.*//' ./docker-compose.nix
    sed -i 's/"ADMIN_USERNAME" =.*//' ./docker-compose.nix
    sed -i 's/"PORTAL_SESSION_SECRET" =.*//' ./docker-compose.nix

    # fix healthcheck command for zotprime-db.
    # In the original dockerfile this uses a predefined env-variable, but we
    # only load the env-vars into the systemd unit files, not here where the docker-compose.nix is created.
    substituteInPlace ./docker-compose.nix --replace-fail \
      '"--health-cmd=[\"mariadb-admin\", \"ping\", \"-h\", \"localhost\", \"-p\"]"' \
      '"--health-cmd=mariadb-admin ping -h 10.5.5.2 -p$MARIADB_ROOT_PASSWORD --ssl=FALSE --user root"'

    # set all health-intervals to 30 seconds.
    sed -i 's/"--health-interval=.*/"--health-interval=30s"/' ./docker-compose.nix

    cp ./docker-compose.nix $out
  '';
in {
  imports = [
    "${compose}"
  ];
  virtualisation.oci-containers.containers = lib.mkMerge [
    {
      # set correct images!
      # could almost generate this cleanly, unfortunately zotprime-init needs zotprime-dataserver :(
      zotprime-zotprime-dataserver.image      = lib.mkForce "docker-archive:${images.zotprime-dataserver}";
      zotprime-zotprime-db.image              = lib.mkForce "docker-archive:${images.zotprime-db}";
      zotprime-zotprime-elasticsearch.image   = lib.mkForce "docker-archive:${images.zotprime-elasticsearch}";
      zotprime-zotprime-init.image            = lib.mkForce "docker-archive:${images.zotprime-dataserver}";
      zotprime-zotprime-localstack.image      = lib.mkForce "docker-archive:${images.zotprime-localstack}";
      zotprime-zotprime-memcached.image       = lib.mkForce "docker-archive:${images.zotprime-memcached}";
      zotprime-zotprime-minio.image           = lib.mkForce "docker-archive:${images.zotprime-minio}";
      zotprime-zotprime-phpmyadmin.image      = lib.mkForce "docker-archive:${images.zotprime-phpmyadmin}";
      zotprime-zotprime-redis.image           = lib.mkForce "docker-archive:${images.zotprime-redis}";
      zotprime-zotprime-streamserver.image    = lib.mkForce "docker-archive:${images.zotprime-streamserver}";
      zotprime-zotprime-tinymceclean.image    = lib.mkForce "docker-archive:${images.zotprime-tinymceclean}";
      zotprime-zotprime-portal.image          = lib.mkForce "docker-archive:${images.zotprime-portal}";
      zotprime-zotprime-admin.image           = lib.mkForce "docker-archive:${images.zotprime-admin}";
    }
    {
      # add secret-environmentfiles to all docker units.
      # TODO: make this more finegrained?
      zotprime-zotprime-dataserver.environmentFiles     = [ config.l3mon.secgen.secrets.zotprime.envfile ];
      zotprime-zotprime-db.environmentFiles             = [ config.l3mon.secgen.secrets.zotprime.envfile ];
      zotprime-zotprime-elasticsearch.environmentFiles  = [ config.l3mon.secgen.secrets.zotprime.envfile ];
      zotprime-zotprime-init.environmentFiles           = [ config.l3mon.secgen.secrets.zotprime.envfile ];
      zotprime-zotprime-localstack.environmentFiles     = [ config.l3mon.secgen.secrets.zotprime.envfile ];
      zotprime-zotprime-memcached.environmentFiles      = [ config.l3mon.secgen.secrets.zotprime.envfile ];
      zotprime-zotprime-minio.environmentFiles          = [ config.l3mon.secgen.secrets.zotprime.envfile ];
      zotprime-zotprime-phpmyadmin.environmentFiles     = [ config.l3mon.secgen.secrets.zotprime.envfile ];
      zotprime-zotprime-redis.environmentFiles          = [ config.l3mon.secgen.secrets.zotprime.envfile ];
      zotprime-zotprime-streamserver.environmentFiles   = [ config.l3mon.secgen.secrets.zotprime.envfile ];
      zotprime-zotprime-tinymceclean.environmentFiles   = [ config.l3mon.secgen.secrets.zotprime.envfile ];
      zotprime-zotprime-portal.environmentFiles         = [ config.l3mon.secgen.secrets.zotprime.envfile ];
      zotprime-zotprime-admin.environmentFiles          = [ config.l3mon.secgen.secrets.zotprime.envfile ];
    }
    {
      # compose2nix does not handle the `links`-directive, so add this manually here.
      zotprime-zotprime-db.extraOptions             = [ "--network-alias=mariadb" ];
      zotprime-zotprime-elasticsearch.extraOptions  = [ "--network-alias=elasticsearch" ];
      zotprime-zotprime-localstack.extraOptions     = [ "--network-alias=localstack" ];
      zotprime-zotprime-memcached.extraOptions      = [ "--network-alias=memcached" ];
      zotprime-zotprime-minio.extraOptions          = [ "--network-alias=minio" ];
      zotprime-zotprime-redis.extraOptions          = [ "--network-alias=redis" ];
      zotprime-zotprime-streamserver.extraOptions   = [ "--network-alias=streamserver" ];
      zotprime-zotprime-tinymceclean.extraOptions   = [ "--network-alias=tinymceclean"  ];
      zotprime-zotprime-dataserver.extraOptions   = [ "--network-alias=dataserver"  ];
    }
    {
      # update these environment-variables manually!
      zotprime-zotprime-admin.environment.APP_URL = lib.mkForce "https://zotprime.internal";
      zotprime-zotprime-dataserver.environment.S3_PUBLIC_ENDPOINT = lib.mkForce "http://127.0.0.1:9000";
    }
  ];
  l3mon.services.defs = {
    zotprime = {
      cfg = data.ports.zotprime-zotero-api;
    };
    zotprime-s3-webui = {
      cfg = data.ports.zotprime-s3-webui;
    };
    zotprime-phpmyadmin = {
      cfg = data.ports.zotprime-phpmyadmin;
    };
    zotprime-admin = {
      cfg = data.ports.zotprime-admin;
    };
    zotprime-streamserver = {
      cfg = data.ports.zotprime-streamserver;
    };
    zotprime-portal = {
      cfg = data.ports.zotprime-portal;
    };
  };

  l3mon.secgen.secrets.zotprime = rec {
    envfile = "${config.l3mon.secgen.secret_dir}/zotprime";
    backup_files = [ envfile ];
    gen = pkgs.writeShellApplication {
      name = "gen";
      runtimeInputs = with pkgs; [ openssl php ];
      text =
      # adapted from ${zotprime_src}/bin/install.sh
      ''
        API_SUPER_TOKEN=$(openssl rand -hex 32)
        WEBADMIN_PASSWORD_PLAIN=$(openssl rand -hex 12)
        MINIOROOTUSER=zotprimeminio
        MINIOROOTPASSWORD=$(openssl rand -hex 16)

        echo "
        SERVER_IP=127.0.0.1
        MARIADB_DATABASE=zotprimeprod
        VER=v3.2.0
        
        MARIADB_ROOT_PASSWORD=$(openssl rand -hex 16)
        MARIADB_USER=zotprimeprod
        MARIADB_PASSWORD=$(openssl rand -hex 16)
        MINIO_ROOT_USER=$MINIOROOTUSER
        MINIO_ROOT_PASSWORD=$MINIOROOTPASSWORD
        AWS_ACCESS_KEY_ID=$MINIOROOTUSER
        AWS_SECRET_ACCESS_KEY=$MINIOROOTPASSWORD
        API_SUPER_TOKEN=$API_SUPER_TOKEN
        API_SUPER_TOKEN_HASH=$(php -r "echo password_hash('$API_SUPER_TOKEN', PASSWORD_BCRYPT);")
        AUTH_SALT=$(openssl rand -hex 16)
        ADMIN_USERNAME=admin
        ADMIN_PASSWORD=$(openssl rand -hex 12)
        ADMIN_EMAIL=admin@example.tld
        WEBADMIN_USERNAME=webadmin
        WEBADMIN_PASSWORD_PLAIN=$WEBADMIN_PASSWORD_PLAIN
        WEBADMIN_PASSWORD=$(php -r "echo password_hash('$WEBADMIN_PASSWORD_PLAIN', PASSWORD_BCRYPT, ['cost' => 12]);")
        # this deviates from the instructions in zotprime, those (openssl rand
        # -hex 32) give an error in laravel about
        # 'unsupported cipher or incorrect key length'
        APP_KEY=$(echo -n "base64:"; openssl rand -base64 32)
        PORTAL_SESSION_SECRET=$(openssl rand -hex 32)
        " > ${envfile}
        chown root:root ${envfile}
        chmod 400 ${envfile}
      '';
    };
  };
  lib.l3mon.zotprime-client = pkgs-unstable.zotero.overrideAttrs (old: {
    postPatch = old.postPatch + (let
      sdefs = config.l3mon.services.defs;
    in ''
      sed -i "s#https://api.zotero.org/#https://zotprime.internal/#g" ./resource/config.mjs; \
      sed -i "s#wss://stream.zotero.org/#wss://zotprime-streamserver.internal/#g" ./resource/config.mjs; \
      ${pkgs.perl}/bin/perl -i -pe 's#https://www\.zotero\.org/(?!start)#https://zotprime.internal/#g' ./resource/config.mjs; \
      sed -i "s#https://zoteroproxycheck.s3.amazonaws.com/test##g" ./resource/config.mjs
    '');
  });
}
