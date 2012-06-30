# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/logwatch/logwatch-7.4.0.ebuild,v 1.9 2012/03/17 17:57:48 armin76 Exp $

inherit eutils

DESCRIPTION="Analyzes and Reports on system logs"
HOMEPAGE="http://www.logwatch.org/"
SRC_URI="mirror://sourceforge/${PN}/${P}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ppc ppc64 sparc x86"
IUSE=""

DEPEND=""
RDEPEND="virtual/cron
	virtual/mta
	virtual/mailx
	dev-lang/perl
	dev-perl/Date-Calc
	dev-perl/DateManip
	dev-perl/Tie-IxHash
	dev-perl/Sys-CPU
	dev-perl/Sys-MemInfo"

src_unpack() {
	unpack ${A}
	cd ${S}

	epatch "${FILESDIR}"/http-ignore-eval-7.4.0.patch
}

src_install() {
	dodir /usr/share/logwatch/lib
	dodir /usr/share/logwatch/scripts/services
	dodir /usr/share/logwatch/scripts/shared
	dodir /usr/share/logwatch/default.conf/logfiles
	dodir /usr/share/logwatch/default.conf/services
	dodir /usr/share/logwatch/default.conf/html
	keepdir /etc/logwatch
	keepdir /var/cache/logwatch

	newsbin scripts/logwatch.pl logwatch.pl || die "dosbin logwatch failed"

	for i in scripts/logfiles/* ; do
		exeinto /usr/share/logwatch/$i
		doexe $i/* || die "doexe $i failed"
	done

	exeinto /usr/share/logwatch/lib
	doexe lib/*.pm

	exeinto /usr/share/logwatch/scripts/services
	doexe scripts/services/*

	exeinto /usr/share/logwatch/scripts/shared
	doexe scripts/shared/*

	insinto /usr/share/logwatch/default.conf
	doins conf/logwatch.conf

	insinto /usr/share/logwatch/default.conf/logfiles
	doins conf/logfiles/*

	insinto /usr/share/logwatch/default.conf/services
	doins conf/services/*

	insinto /usr/share/logwatch/default.conf/html
	doins conf/html/*

	# Make sure logwatch is run before anything else #100243
	exeinto /etc/cron.daily
	newexe "${FILESDIR}"/logwatch 00-logwatch

	doman logwatch.8
	dodoc README HOWTO-Customize-LogWatch
}

pkg_postinst() {
	if [[ -e ${ROOT}/etc/cron.daily/logwatch ]] ; then
		local md5=$(md5sum "${ROOT}"/etc/cron.daily/logwatch)
		[[ ${md5} == "edb003cbc0686ed4cf37db16025635f3" ]] \
			&& rm -f "${ROOT}"/etc/cron.daily/logwatch \
			|| ewarn "You have two logwatch files in /etc/cron.daily/"
	fi
}