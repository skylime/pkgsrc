# $NetBSD: options.mk,v 1.6 2022/10/31 14:54:38 triaxx Exp $

PKG_OPTIONS_VAR=	PKG_OPTIONS.libLLVM

LLVM_TARGETS=	AArch64 AMDGPU ARM AVR BPF Hexagon Lanai Mips MSP430 NVPTX PowerPC RISCV Sparc SystemZ WebAssembly X86 XCore

.for tgt in ${LLVM_TARGETS}
PLIST_VARS+=			${tgt}
PKG_SUPPORTED_OPTIONS+=		llvm-target-${tgt:tl}
.endfor
.if ${OPSYS} != "FreeBSD"
PKG_SUPPORTED_OPTIONS+=		terminfo
.endif

# Terminfo is used for colour output, only enable it by default if terminfo
# is builtin to avoid unnecessary dependencies which could cause bootstrap
# issues.
CHECK_BUILTIN.terminfo:=	yes
.include "../../mk/terminfo.builtin.mk"
CHECK_BUILTIN.terminfo:=	no
.if !empty(USE_BUILTIN.terminfo:M[yY][eE][sS]) && ${OPSYS} != "FreeBSD"
PKG_SUGGESTED_OPTIONS+=		terminfo
.endif

# Probably safe to assume that only x86 users are interested in
# cross-compilation for now. This saves some build time for everyone else.
.if !empty(MACHINE_ARCH:Msparc*)
PKG_SUGGESTED_OPTIONS+=	llvm-target-sparc
.elif !empty(MACHINE_ARCH:Mpowerpc*)
PKG_SUGGESTED_OPTIONS+=	llvm-target-powerpc
.elif !empty(MACHINE_ARCH:Maarch64)
PKG_SUGGESTED_OPTIONS+=	llvm-target-aarch64
.elif !empty(MACHINE_ARCH:Mearm*)
PKG_SUGGESTED_OPTIONS+=	llvm-target-arm
.elif !empty(MACHINE_ARCH:M*mips*)
PKG_SUGGESTED_OPTIONS+=	llvm-target-mips
.else
# X86 and everyone else get all targets by default.
.  for tgt in ${LLVM_TARGETS}
PKG_SUGGESTED_OPTIONS+=	llvm-target-${tgt:tl}
.  endfor
.endif
PKG_SUGGESTED_OPTIONS+=	llvm-target-amdgpu	# for mesa/radeon

.include "../../mk/bsd.options.mk"

.for tgt in ${LLVM_TARGETS}
.  if !empty(PKG_OPTIONS:Mllvm-target-${tgt:tl})
PLIST.${tgt}=		yes
LLVM_TARGETS_TO_BUILD+=	${tgt}
.  endif
.endfor

.if !empty(PKG_OPTIONS:Mterminfo)
.include "../../mk/terminfo.buildlink3.mk"
.else
CMAKE_ARGS+=	-DLLVM_ENABLE_TERMINFO=OFF
.endif

CMAKE_ARGS+=	-DLLVM_TARGETS_TO_BUILD="${LLVM_TARGETS_TO_BUILD:ts;}"
