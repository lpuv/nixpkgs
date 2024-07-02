{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) types;
  cfg = config.services.ocis;
  defaultUser = "ocis";
  defaultGroup = defaultUser;
in
{
  options = {
    services.ocis = {
      enable = lib.mkEnableOption "ownCloud Infinite Scale";

      package = lib.mkPackageOption pkgs "ocis-bin" { };

      configDir = lib.mkOption {
        type = types.nullOr types.path;
        default = null;
        example = "/var/lib/ocis/config";
        description = ''
          Path to directory containing oCIS config file.

          Example config can be generated by `ocis init --config-path fileName --admin-password "adminPass"`.
          Add `--insecure true` if SSL certificates are generated and managed externally (e.g. using oCIS behind reverse proxy).

          Note: This directory must contain at least a `ocis.yaml`. Ensure
          [user](#opt-services.ocis.user) has read/write access to it. In some
          circumstances you may need to add additional oCIS configuration files (e.g.,
          `proxy.yaml`) to this directory.
        '';
      };

      environmentFile = lib.mkOption {
        type = types.nullOr types.path;
        default = null;
        example = "/run/keys/ocis.env";
        description = ''
          An environment file as defined in {manpage}`systemd.exec(5)`.

          Configuration provided in this file will override those from [configDir](#opt-services.ocis.configDir)/ocis.yaml.
        '';
      };

      user = lib.mkOption {
        type = types.str;
        default = defaultUser;
        example = "yourUser";
        description = ''
          The user to run oCIS as.
          By default, a user named `${defaultUser}` will be created whose home
          directory is [stateDir](#opt-services.ocis.stateDir).
        '';
      };

      group = lib.mkOption {
        type = types.str;
        default = defaultGroup;
        example = "yourGroup";
        description = ''
          The group to run oCIS under.
          By default, a group named `${defaultGroup}` will be created.
        '';
      };

      address = lib.mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = "Web interface address.";
      };

      port = lib.mkOption {
        type = types.port;
        default = 9200;
        description = "Web interface port.";
      };

      url = lib.mkOption {
        type = types.str;
        default = "https://localhost:9200";
        example = "https://some-hostname-or-ip:9200";
        description = "Web interface address.";
      };

      stateDir = lib.mkOption {
        default = "/var/lib/ocis";
        type = types.str;
        description = "ownCloud data directory.";
      };

      environment = lib.mkOption {
        type = types.attrsOf types.str;
        default = { };
        description = ''
          Extra config options.

          See [the documentation](https://doc.owncloud.com/ocis/next/deployment/services/services.html) for available options.
          See [notes for environment variables](https://doc.owncloud.com/ocis/next/deployment/services/env-var-note.html) for more information.

          Note that all the attributes here will be copied to /nix/store/ and will be world readable. Options like *_PASSWORD or *_SECRET should be part of     [environmentFile](#opt-services.ocis.environmentFile) instead, and are only provided here for illustrative purpose.

          Configuration here will override those from [environmentFile](#opt-services.ocis.environmentFile) and will have highest precedence, at the cost of security. Do NOT put security sensitive stuff here.
        '';
        example = {
          OCIS_INSECURE = "false";
          OCIS_LOG_LEVEL = "error";
          OCIS_JWT_SECRET = "super_secret";
          OCIS_TRANSFER_SECRET = "foo";
          OCIS_MACHINE_AUTH_API_KEY = "foo";
          OCIS_SYSTEM_USER_ID = "123";
          OCIS_MOUNT_ID = "123";
          OCIS_STORAGE_USERS_MOUNT_ID = "123";
          GATEWAY_STORAGE_USERS_MOUNT_ID = "123";
          CS3_ALLOW_INSECURE = "true";
          OCIS_INSECURE_BACKENDS = "true";
          TLS_INSECURE = "true";
          TLS_SKIP_VERIFY_CLIENT_CERT = "true";
          WEBDAV_ALLOW_INSECURE = "true";
          IDP_TLS = "false";
          GRAPH_APPLICATION_ID = "1234";
          IDM_IDPSVC_PASSWORD = "password";
          IDM_REVASVC_PASSWORD = "password";
          IDM_SVC_PASSWORD = "password";
          IDP_ISS = "https://localhost:9200";
          OCIS_LDAP_BIND_PASSWORD = "password";
          OCIS_SERVICE_ACCOUNT_ID = "foo";
          OCIS_SERVICE_ACCOUNT_SECRET = "foo";
          OCIS_SYSTEM_USER_API_KEY = "foo";
          STORAGE_USERS_MOUNT_ID = "123";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${defaultUser} = lib.mkIf (cfg.user == defaultUser) {
      group = cfg.group;
      home = cfg.stateDir;
      isSystemUser = true;
      createHome = true;
      description = "ownCloud Infinite Scale daemon user";
    };

    users.groups = lib.mkIf (cfg.group == defaultGroup) { ${defaultGroup} = { }; };

    systemd = {
      services.ocis = {
        description = "ownCloud Infinite Scale Stack";
        wantedBy = [ "multi-user.target" ];
        environment = {
          PROXY_HTTP_ADDR = "${cfg.address}:${toString cfg.port}";
          OCIS_URL = cfg.url;
          OCIS_CONFIG_DIR = if (cfg.configDir == null) then "${cfg.stateDir}/config" else cfg.configDir;
          OCIS_BASE_DATA_PATH = cfg.stateDir;
        } // cfg.environment;
        serviceConfig = {
          Type = "simple";
          ExecStart = "${lib.getExe cfg.package} server";
          WorkingDirectory = cfg.stateDir;
          User = cfg.user;
          Group = cfg.group;
          Restart = "always";
          EnvironmentFile = lib.optional (cfg.environmentFile != null) cfg.environmentFile;
          ReadWritePaths = [ cfg.stateDir ];
          ReadOnlyPaths = [ cfg.configDir ];
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
          PrivateTmp = true;
          PrivateDevices = true;
          ProtectSystem = "strict";
          ProtectHome = true;
          ProtectControlGroups = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectKernelLogs = true;
          RestrictAddressFamilies = [
            "AF_UNIX"
            "AF_INET"
            "AF_INET6"
            "AF_NETLINK"
          ];
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          LockPersonality = true;
          SystemCallArchitectures = "native";
        };
      };
    };
  };

  meta.maintainers = with lib.maintainers; [
    bhankas
    danth
    ramblurr
  ];
}
