# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit systemd
# Don't inherit gentoo python stuff that no longer supports python2

MY_P="${PN}_${PV}"

DESCRIPTION="Proxy cache for Gentoo packages"
HOMEPAGE="https://sourceforge.net/projects/http-replicator"
SRC_URI="mirror://sourceforge/http-replicator/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 hppa ppc ~sparc x86"

RDEPEND="dev-lang/python:2.7"
#DEPEND="${RDEPEND}"

S="${WORKDIR}/${MY_P}"

PATCHES=(
	"${FILESDIR}/http-replicator-3.0-sighup.patch"
	"${FILESDIR}/http-replicator-3-unique-cache-name.patch"
	"${FILESDIR}/http-replicator-3-missing-directory.patch"
)

src_prepare() {
	sed -i '1s/python$/python2/' http-replicator

	default
}

src_install() {
	# Daemon and repcacheman into /usr/bin
	exeinto /usr/bin
	doexe http-replicator

	## future: fix repcacheman and repcacheman.py
        ## (perhaps borrow from separate 2020 work on a python3-based
        ## version 4.0 fork?)
	#python_newscript "${FILESDIR}/http-replicator-3.0-repcacheman-0.44-r2" repcacheman.py

	#exeinto /usr/bin
	#newexe "${FILESDIR}/http-replicator-3.0-callrepcacheman-0.1" repcacheman

	# init.d scripts
	newinitd "${FILESDIR}/http-replicator-3.0.init" http-replicator
	newconfd "${FILESDIR}/http-replicator-3.0.conf" http-replicator

	systemd_dounit "${FILESDIR}"/http-replicator.service
	systemd_install_serviced "${FILESDIR}"/http-replicator.service.conf

	# Docs
	dodoc README debian/changelog "${FILESDIR}/README.gentoo"

        # Needed on all clients (and also the server).
        # future: Package seprately?  Build into sys-apps/portage?
	dodoc "${FILESDIR}/fetcher"

	# Man Page - Not Gentooified yet
	doman http-replicator.1

	insinto /etc/logrotate.d
	newins debian/logrotate http-replicator
}

pkg_postinst() {
	ewarn "Before starting http-replicator, please see the README.gentoo"
        ewarn "file for how to setup both the server and the clients."
}
