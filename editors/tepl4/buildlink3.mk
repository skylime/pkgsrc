# $NetBSD: buildlink3.mk,v 1.9 2022/08/11 05:08:17 gutteridge Exp $

BUILDLINK_TREE+=	tepl4

.if !defined(TEPL4_BUILDLINK3_MK)
TEPL4_BUILDLINK3_MK:=

BUILDLINK_API_DEPENDS.tepl4+=	tepl4>=4.4.0
BUILDLINK_ABI_DEPENDS.tepl4?=	tepl4>=4.4.0nb6
BUILDLINK_PKGSRCDIR.tepl4?=	../../editors/tepl4

.include "../../devel/amtk/buildlink3.mk"
.include "../../textproc/uchardet/buildlink3.mk"
.include "../../x11/gtk3/buildlink3.mk"
.include "../../x11/gtksourceview4/buildlink3.mk"
.endif	# TEPL4_BUILDLINK3_MK

BUILDLINK_TREE+=	-tepl4
