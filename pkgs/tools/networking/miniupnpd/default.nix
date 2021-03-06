{ stdenv, lib, fetchurl, iptables, libuuid, pkgconfig
, which, iproute, gnused, coreutils, gawk, makeWrapper
}:

let
  scriptBinEnv = lib.makeBinPath [ which iproute iptables gnused coreutils gawk ];
in
stdenv.mkDerivation rec {
  name = "miniupnpd-2.1";

  src = fetchurl {
    url = "http://miniupnp.free.fr/files/download.php?file=${name}.tar.gz";
    sha256 = "1hg0zzvvzfgpnmngmd3ffnsk9x18lwlxlpw5jgh7y6b1jrvr824m";
    name = "${name}.tar.gz";
  };

  buildInputs = [ iptables libuuid ];
  nativeBuildInputs= [ pkgconfig makeWrapper ];

  makefile = "Makefile.linux";

  buildFlags = [ "miniupnpd" "genuuid" ];

  installFlags = [ "PREFIX=$(out)" "INSTALLPREFIX=$(out)" ];

  postFixup = ''
    for script in $out/etc/miniupnpd/ip{,6}tables_{init,removeall}.sh
    do
      wrapProgram $script --set PATH '${scriptBinEnv}:$PATH'
    done
  '';

  meta = with stdenv.lib; {
    homepage = http://miniupnp.free.fr/;
    description = "A daemon that implements the UPnP Internet Gateway Device (IGD) specification";
    platforms = platforms.linux;
    license = licenses.bsd3;
  };
}
