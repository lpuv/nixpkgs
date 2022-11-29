{ lib
, bcrypt
, buildPythonPackage
, cryptography
, fetchpatch
, fetchPypi
, gssapi
, invoke
, mock
, python310Packages
, random2
, transaction
, persistent
, zc_lockfile
, zconfig
, zdaemon
, zope_interface
, zodb
, pyasn1
, pynacl
, pytest-relaxed
, pytestCheckHook
, six
, manuel
}:

buildPythonPackage rec {
  pname = "ZEO";
  version = "5.3.0";
  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-/8VDNPg4TW+vFpPc6CPApfzUKfoBXEfS1J0b1omZcVc=";
  };

  msgpack = python310Packages.msgpack.overrideAttrs (oldAttrs: rec {
    version = "0.6.2";
    src = fetchPypi {
      pname = "msgpack";
      inherit version;
      sha256 = "sha256-6jwvhZNG/NVfxG6WiFMB2cL3o21FP12PKWeEDvoeGDA=";
    };
  });

  propagatedBuildInputs = [ random2 zodb six transaction persistent zc_lockfile zconfig zdaemon zope_interface msgpack manuel ];

  meta = with lib; {
    homepage = "https://github.com/zopefoundation/ZEO";
    description = "ZEO - Single-server client-server database server for ZODB";
    license = licenses.zpl21;
    longDescription = ''
	ZEO is a client-server storage for ZODB for sharing a single storage among many clients. 
        When you use ZEO, a lower-level storage, typically a file storage, is opened in the ZEO server process. 
        Client programs connect to this process using a ZEO ClientStorage. 
        ZEO provides a consistent view of the database to all clients. 
        The ZEO client and server communicate using a custom protocol layered on top of TCP.
    '';
    maintainers = with maintainers; [ leo ];
  };
}
