{ lib
, pkgs
, stdenv
, buildPythonPackage
, fetchPypi
, python310Packages
, python3Packages
, setuptools
, paramiko-ng
, zodburi
}:



buildPythonPackage rec {
  pname = "pwncat-cs";
  version = "0.5.4";

  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-ZxT+n+aT8/6OjWi6xDRFlnoWAE4pn5RtfGT5PR2dZ9w=";
  };

  buildInputs = [ stdenv.cc.cc.lib pkgs.poetry ];


  nativeBuildInputs = [
    setuptools
    pkgs.autoPatchelfHook
  ];

  packaging = python310Packages.packaging.overrideAttrs (oldAttrs: rec {
    version = "20.9";
    src = fetchPypi {
      pname = "packaging";
      inherit version;
      sha256 = "sha256-WzJ6wTINyGPcpy9FFOzAhvMRhnRLhKIwN0zB/Xdv6uU=";
    };
  });

  jinja2 = python310Packages.jinja2.overrideAttrs (oldAttrs: rec {
    version = "3.0.1";
    src = pkgs.fetchurl {
      url = "https://files.pythonhosted.org/packages/39/11/8076571afd97303dfeb6e466f27187ca4970918d4b36d5326725514d3ed3/Jinja2-3.0.1.tar.gz";
      sha256 = "sha256-cD9IS0emr1AudDyRIllcyBKwJx9mFyJAMRT3GnnQ9aQ=";
    };
  });

  #colorama = python310Packages.colorama.overrideAttrs (oldAttrs: rec {
  #  version = "0.4.0";
  #  src = fetchPypi {
  #    pname = "colorama";
  #    inherit version;
  #    sha256 = "sha256-boo+LGHmz2GTv8/7uJhloJc693edPq2RP9u7wz9FfCw=";
  #  };
  #});

#  rich = python310Packages.rich.overrideAttrs (oldAttrs: rec {
#    version = "10.4.0";
#    src = fetchPypi {
#      pname = "rich";
#      inherit version;
#      sha256 = "sha256-boo+LGHmz2GTv8/7uJhloJc693edPq2RP9u7wz9FfCw=";
#    };
#    propagatedBuildInputs = [ python3Packages.colorama python3Packages.pygments python3Packages.CommonMark ];
#  });

  propagatedBuildInputs = [ setuptools packaging paramiko-ng python310Packages.python-rapidjson python310Packages.requests zodburi jinja2 python310Packages.rich ];


  meta = with lib; {
    description = "Fancy reverse and bind shell handler";
    homepage = "https://github.com/calebstewart/pwncat";
    license = licenses.mit;
    maintainers = with maintainers; [ leo ];
  };
}
