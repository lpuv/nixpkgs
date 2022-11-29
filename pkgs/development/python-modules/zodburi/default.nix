{ lib
, bcrypt
, buildPythonPackage
, cryptography
, fetchpatch
, fetchPypi
, gssapi
, invoke
, mock
, ZEO
, zodb
, pyasn1
, pynacl
, pytest-relaxed
, pytestCheckHook
, six
, msgpack
}:

buildPythonPackage rec {
  pname = "zodburi";
  version = "2.5.0";
  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Wn18aPg68n487HXWmoE27xPoSlacRRiF/8vdY3HGMlQ=";
  };


  buildInputs = [ zodb mock ZEO ];

  meta = with lib; {
    homepage = "https://github.com/Pylons/zodburi";
    description = " Construct ZODB storage instances from URIs. ";
    license = licenses.free;
    longDescription = ''
      A library which parses URIs and converts them to ZODB storage objects and database arguments.
    '';
    maintainers = with maintainers; [ leo ];
  };
}
