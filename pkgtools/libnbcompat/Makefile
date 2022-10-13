# $NetBSD: Makefile,v 1.87 2020/05/24 21:51:54 nia Exp $
#
# NOTE: If you update this package, it is *mandatory* that you update
# 	pkgsrc/pkgtools/libnbcompat/files/README to reflect the actual
#	list of tested and supported platforms.
#

PKGNAME=		libnbcompat-20221013
CATEGORIES=		pkgtools devel

MAINTAINER=		joerg@NetBSD.org
HOMEPAGE=		https://www.NetBSD.org/
COMMENT=		Portable NetBSD compatibility library

GNU_CONFIGURE=		yes
MAKE_ENV+=		LIBMODE=${LIBMODE}

# Enable by default for standalone builds
CONFIGURE_ARGS+=	--enable-bsd-getopt --enable-db

CHECK_PERMS_SKIP=	*	# avoid dependency cycles with sysutils/checkperms
CHECK_PORTABILITY_SKIP=	*	# avoid dependency cycles with pkgtools/check-portability
PKGSRC_LOCKTYPE=	none	# avoid dependency cycles with pkgtool/shlock

do-extract:
	@${CP} -R ${FILESDIR} ${WRKSRC}

.include "../../mk/bsd.pkg.mk"
