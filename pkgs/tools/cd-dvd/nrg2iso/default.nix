{lib, stdenv, fetchurl}:

stdenv.mkDerivation rec {
  pname = "nrg2iso";
  version = "0.4.1";

  src = fetchurl {
    url = "http://gregory.kokanosky.free.fr/v4/linux/${pname}-${version}.tar.gz";
    sha256 = "sha256-O+NqQWdY/BkQRztJqNrfKiqj1R8ZdhlzNrwXS8HjBuU=";
  };

  patches = [ ./c-compiler.patch ];

  installPhase = ''
    mkdir -pv $out/bin/
    cp -v nrg2iso $out/bin/nrg2iso
  '';

  meta = with lib; {
    description = "Linux utils for converting CD (or DVD) image generated by Nero Burning Rom to ISO format";
    homepage = "http://gregory.kokanosky.free.fr/v4/linux/nrg2iso.en.html";
    license = licenses.gpl2Plus;
    platforms = platforms.all;
    mainProgram = "nrg2iso";
  };
}
