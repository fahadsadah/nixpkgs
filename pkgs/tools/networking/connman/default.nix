{ stdenv, fetchurl, fetchpatch, pkgconfig, openconnect, file, gawk,
  openvpn, vpnc, glib, dbus, iptables, gnutls, polkit,
  wpa_supplicant, readline6, pptp, ppp }:

stdenv.mkDerivation rec {
  name = "connman-${version}";
  version = "1.35";
  src = fetchurl {
    url = "mirror://kernel/linux/network/connman/${name}.tar.xz";
    sha256 = "1apj5j25kj7v1bsfv3nh54aiq873nfrsjfbj85p5qm3ihfwxxmv6";
  };

  buildInputs = [ openconnect polkit
                  openvpn vpnc glib dbus iptables gnutls
                  wpa_supplicant readline6 pptp ppp ];

  nativeBuildInputs = [ pkgconfig file gawk ];

  patches = [
    (fetchpatch {
      name = "header-include.patch";
      url = "https://git.kernel.org/pub/scm/network/connman/connman.git/patch/?id=bdfb3526466f8fb8f13d9259037d8f42c782ce24";
      sha256 = "0q6ysy2xvvcmkcbw1y29x90g7g7kih7v95k1xbxdcxkras5yl8nf";
    })
  ];

  preConfigure = ''
    export WPASUPPLICANT=${wpa_supplicant}/sbin/wpa_supplicant
    export PPPD=${ppp}/sbin/pppd
    export AWK=${gawk}/bin/gawk
    sed -i "s/\/usr\/bin\/file/file/g" ./configure
  '';

  configureFlags = [
    "--sysconfdir=\${out}/etc"
    "--localstatedir=/var"
    "--with-dbusconfdir=\${out}/etc"
    "--with-dbusdatadir=\${out}/usr/share"
    "--disable-maintainer-mode"
    "--enable-openconnect=builtin"
    "--with-openconnect=${openconnect}/sbin/openconnect"
    "--enable-openvpn=builtin"
    "--with-openvpn=${openvpn}/sbin/openvpn"
    "--enable-vpnc=builtin"
    "--with-vpnc=${vpnc}/sbin/vpnc"
    "--enable-session-policy-local=builtin"
    "--enable-client"
    "--enable-bluetooth"
    "--enable-wifi"
    "--enable-polkit"
    "--enable-tools"
    "--enable-datafiles"
    "--enable-pptp"
    "--with-pptp=${pptp}/sbin/pptp"
    "--enable-iwd"
  ];

  postInstall = ''
    cp ./client/connmanctl $out/sbin/connmanctl
  '';

  meta = with stdenv.lib; {
    description = "A daemon for managing internet connections";
    homepage = https://connman.net/;
    maintainers = [ maintainers.matejc ];
    platforms = platforms.linux;
    license = licenses.gpl2;
  };
}
