{ stdenv
, lib
, fetchFromGitHub
, rustPlatform
, git
, nix-update-script
, pkg-config
, openssl
, dbus
, Security
}:

let
  pname = "ockam";
  version = "0.120.0";
in
rustPlatform.buildRustPackage {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "build-trust";
    repo = pname;
    rev = "ockam_v${version}";
    hash = "sha256-Z3yRk0AZefTYITYT9dADrqqpX9PtNeHTgtLFCsICEQ4=";
  };

  cargoHash = "sha256-7jKD1WGTHEW2hzJAuZ7Z5D28hT9nucf0aW17AKKMH7w=";
  nativeBuildInputs = [ git pkg-config ];
  buildInputs = [ openssl dbus ]
    ++ lib.optionals stdenv.isDarwin [ Security ];

  passthru.updateScript = nix-update-script { };

  # too many tests fail for now
  doCheck = false;
  # checkFlags = [
  #   # tries to make a network access
  #   "--skip=tests::curl_http_ockam"
  #   "--skip=medium_file_transfer"
  #   "--skip=medium_file_transfer_large_chunks"
  #   "--skip=medium_file_transfer_small_chunks"
  #   "--skip=tiny_file_transfer"
  #   "--skip=tiny_file_transfer_small_chunks"
  #   # tries to do IO
  #   "--skip=cli_state::tests::integration"
  #   "--skip=cli_state::tests::test_create_default_identity_state"
  #   "--skip=cli_state::tests::test_create_named_identity_state"
  #   "--skip=kafka::integration_test::test::producer__flow_with_mock_kafka__content_encryption_and_decryption"
  #   "--skip=kafka::portal_worker::test::kafka_portal_worker__metadata_exchange__response_changed"
  #   "--skip=full_flow"
  #   "--skip=run::parser::tests::detect_circular_dependency"
  #   "--skip=run::parser::tests::test_parse_config_with_depends_on"
  #   "--skip=util::tests::test_process_multi_addr"
  # ];

  meta = with lib; {
    description = "Orchestrate end-to-end encryption, cryptographic identities, mutual authentication, and authorization policies between distributed applications – at massive scale";
    homepage = "https://github.com/build-trust/ockam";
    license = licenses.mpl20;
    maintainers = with maintainers; [ happysalada ];
    platforms = platforms.linux;
  };
}
