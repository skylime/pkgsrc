# $NetBSD: buildlink3.mk,v 1.5 2022/09/07 06:50:47 pho Exp $

BUILDLINK_TREE+=	hs-hls-module-name-plugin

.if !defined(HS_HLS_MODULE_NAME_PLUGIN_BUILDLINK3_MK)
HS_HLS_MODULE_NAME_PLUGIN_BUILDLINK3_MK:=

BUILDLINK_API_DEPENDS.hs-hls-module-name-plugin+=	hs-hls-module-name-plugin>=1.0.1
BUILDLINK_ABI_DEPENDS.hs-hls-module-name-plugin+=	hs-hls-module-name-plugin>=1.0.1.0nb4
BUILDLINK_PKGSRCDIR.hs-hls-module-name-plugin?=		../../devel/hs-hls-module-name-plugin

.include "../../converters/hs-aeson/buildlink3.mk"
.include "../../devel/hs-ghcide/buildlink3.mk"
.include "../../devel/hs-hls-plugin-api/buildlink3.mk"
.include "../../devel/hs-lsp/buildlink3.mk"
.include "../../devel/hs-unordered-containers/buildlink3.mk"
.endif	# HS_HLS_MODULE_NAME_PLUGIN_BUILDLINK3_MK

BUILDLINK_TREE+=	-hs-hls-module-name-plugin
