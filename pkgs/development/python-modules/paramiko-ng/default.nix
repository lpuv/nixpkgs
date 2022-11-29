{ lib
, bcrypt
, buildPythonPackage
, cryptography
, fetchpatch
, fetchPypi
, gssapi
, invoke
, mock
, pyasn1
, pynacl
, pytest-relaxed
, pytestCheckHook
, six
}:

buildPythonPackage rec {
  pname = "paramiko-ng";
  version = "2.8.10";
  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-xg8epiGX+gDu6Fa3xL+znOuKyP3Yap1Os3cR0Uqr7KE=";
  };


  propagatedBuildInputs = [
    bcrypt
    cryptography
    pyasn1
    six
  ] ++ passthru.optional-dependencies.ed25519; # remove on 3.0 update

  passthru.optional-dependencies = {
    gssapi = [ pyasn1 gssapi ];
    ed25519 = [ pynacl bcrypt ];
    invoke = [ invoke ];
  };

  checkInputs = [
    mock
    pytestCheckHook
  ] ++ lib.flatten (builtins.attrValues passthru.optional-dependencies);

  disabledTestPaths = [
    # disable tests that require pytest-relaxed, which is broken
    "tests/test_client.py"
    "tests/test_ssh_gss.py"
  ];

  pythonImportsCheck = [
    "paramiko"
  ];

  __darwinAllowLocalNetworking = true;

  meta = with lib; {
    homepage = "https://github.com/ploxiln/paramiko-ng/";
    description = "A fork of paramiko - Native Python SSHv2 protocol library";
    license = licenses.lgpl21Plus;
    longDescription = ''
      Library for making SSH2 connections (client or server). Emphasis is
      on using SSH2 as an alternative to SSL for making secure connections
      between python scripts. All major ciphers and hash methods are
      supported. SFTP client and server mode are both supported too.
    '';
    maintainers = with maintainers; [ leo ];
  };
}
