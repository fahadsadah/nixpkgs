{ stdenv, fetchFromGitHub, autoconf, automake, boost, bison, flex, openjdk, doxygen, perl, graphviz, libtool, lsb-release, ncurses, zlib, sqlite }:

stdenv.mkDerivation rec {
  version = "1.2.0";
  name    = "souffle-${version}";

  src = fetchFromGitHub {
    owner  = "souffle-lang";
    repo   = "souffle";
    rev    = version;
    sha256 = "1g8yvm40h102mab8lacpl1cwgqsw1js0s1yn4l84l9fjdvlh2ygd";
  };

  buildInputs = [
    autoconf automake boost bison flex openjdk
    # Used for 1.2.0
    libtool lsb-release ncurses zlib sqlite
    # Used for docs
    doxygen perl graphviz
  ];

  patchPhase = ''
    substituteInPlace configure.ac \
      --replace "m4_esyscmd([git describe --tags --abbrev=0 --always | tr -d '\n'])" "${version}"
  '';

  # Without this, we get an obscure error about not being able to find a library version
  # without saying what library it's looking for. Turns out it's searching global paths
  # for boost and failing there, so we tell it what's what here.
  configureFlags = [ "--with-boost-libdir=${boost}/lib" ];

  preConfigure = "./bootstrap";

  meta = with stdenv.lib; {
    description = "A translator of declarative Datalog programs into the C++ language";
    homepage    = "http://souffle-lang.github.io/";
    platforms   = platforms.unix;
    maintainers = with maintainers; [ copumpkin wchresta ];
    license     = licenses.upl;
  };
}
