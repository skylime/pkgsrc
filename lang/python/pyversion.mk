# $NetBSD: pyversion.mk,v 1.143 2022/10/31 09:53:31 adam Exp $

# This file determines which Python version is used as a dependency for
# a package.
#
# === User-settable variables ===
#
# PYTHON_VERSION_DEFAULT
#	The preferred Python version to use.
#
#	Possible values: 27 37 38 39 310 311
#	Default: 310
#
# === Infrastructure variables ===
#
# PYTHON_VERSION_REQD
#	Python version to use. This variable should not be set in
#	packages.  Normally it is used by bulk build tools.
#
#	Possible: ${PYTHON_VERSIONS_ACCEPTED}
#	Default:  ${PYTHON_VERSION_DEFAULT}
#
# === Package-settable variables ===
#
# PYTHON_VERSIONS_ACCEPTED
#	The Python versions that are acceptable for the package. The
#	order of the entries matters, since earlier entries are
#	preferred over later ones.
#
#	Possible values: 311 310 39 38 37 27
#	Default: 311 310 39 38 37 27
#
# PYTHON_VERSIONS_INCOMPATIBLE
#	The Python versions that are NOT acceptable for the package.
#
#	Possible values: 27 37 38 39 310 311
#	Default: (empty)
#
# PYTHON_FOR_BUILD_ONLY
#	Whether Python is needed only at build time or at run time.
#
#	Possible values: yes no test tool
#	Default: no
#
# PYTHON_SELF_CONFLICT
#	If set to "yes", additional CONFLICTS entries are added for
#	registering a conflict between pyNN-<modulename> packages.
#
#	Possible values: yes no
#	Default: no
#
# === Defined variables ===
#
# PYPKGPREFIX
#	The prefix to use in PKGNAME for extensions which are meant
#	to be installed for multiple Python versions.
#
#	Example: py27
#
# PYVERSSUFFIX
#	The suffix to executables and in the library path, equal to
#	sys.version[0:3].
#
#	Example: 2.7
#
# Keywords: python
#

.if !defined(PYTHON_PYVERSION_MK)
PYTHON_PYVERSION_MK=	defined

# derive a python version from the package name if possible
# optionally handled quoted package names
.if defined(PKGNAME_REQD) && !empty(PKGNAME_REQD:Mpy[0-9][0-9]-*) || \
    defined(PKGNAME_REQD) && !empty(PKGNAME_REQD:M*-py[0-9][0-9]-*)
PYTHON_VERSION_REQD?=	${PKGNAME_REQD:C/(^.*-|^)py([0-9][0-9])-.*/\2/}
.elif defined(PKGNAME_OLD) && !empty(PKGNAME_OLD:Mpy[0-9][0-9]-*) || \
      defined(PKGNAME_OLD) && !empty(PKGNAME_OLD:M*-py[0-9][0-9]-*)
PYTHON_VERSION_REQD?=	${PKGNAME_OLD:C/(^.*-|^)py([0-9][0-9])-.*/\2/}
.endif

.include "../../mk/bsd.prefs.mk"

BUILD_DEFS+=		PYTHON_VERSION_DEFAULT
BUILD_DEFS_EFFECTS+=	PYPACKAGE

PYTHON_VERSION_DEFAULT?=		310
PYTHON_VERSIONS_ACCEPTED?=		311 310 39 38 37 27
PYTHON_VERSIONS_INCOMPATIBLE?=		# empty by default

# transform the list into individual variables
.for pv in ${PYTHON_VERSIONS_ACCEPTED}
.  if empty(PYTHON_VERSIONS_INCOMPATIBLE:M${pv})
_PYTHON_VERSION_${pv}_OK=	yes
_PYTHON_VERSIONS_ACCEPTED+=	${pv}
.  endif
.endfor

#
# choose a python version where to add,
# try to be intelligent
#
# if a version is explicitly required, take it
.if defined(PYTHON_VERSION_REQD)
# but check if it is acceptable first, error out otherwise
.  if defined(_PYTHON_VERSION_${PYTHON_VERSION_REQD}_OK)
_PYTHON_VERSION=	${PYTHON_VERSION_REQD}
.  endif
.else
# if the default is accepted, it is first choice
.  if !defined(_PYTHON_VERSION)
.    if defined(_PYTHON_VERSION_${PYTHON_VERSION_DEFAULT}_OK)
_PYTHON_VERSION=	${PYTHON_VERSION_DEFAULT}
.    endif
.  endif
# prefer an already installed version, in order of "accepted"
.  if !defined(_PYTHON_VERSION)
.    for pv in ${PYTHON_VERSIONS_ACCEPTED}
.      if defined(_PYTHON_VERSION_${pv}_OK)
_PYTHON_VERSION?=	${pv}
.      endif
.    endfor
.  endif
.endif

#
# Variable assignment for multi-python packages
MULTI+=	PYTHON_VERSION_REQD=${_PYTHON_VERSION}

# No supported version found, annotate to simplify statements below.
.if !defined(_PYTHON_VERSION)
_PYTHON_VERSION=	none
PKG_FAIL_REASON+=	"No valid Python version"
PYPKGPREFIX=		none
PYVERSSUFFIX=		none
.endif

# Additional CONFLICTS
.if ${PYTHON_SELF_CONFLICT:U:tl} == "yes"
.  for i in ${PYTHON_VERSIONS_ACCEPTED:N${_PYTHON_VERSION}}
.    if empty(PYTHON_VERSIONS_INCOMPATIBLE:M${i})
CONFLICTS+=	${PKGNAME:S/py${_PYTHON_VERSION}/py${i}/:C/-[0-9].*$/-[0-9]*/}
.    endif
.  endfor
.endif # PYCONFLICTS

#
PLIST_VARS+=	py2x py3x

.if empty(_PYTHON_VERSION:Mnone)
PYPACKAGE=				python${_PYTHON_VERSION}
PYVERSSUFFIX=				${_PYTHON_VERSION:C/^([0-9])/\1./1}
BUILDLINK_API_DEPENDS.${PYPACKAGE}?=	${PYPACKAGE}>=${PYVERSSUFFIX}
PYPKGSRCDIR=				../../lang/${PYPACKAGE}
PYDEPENDENCY=				${BUILDLINK_API_DEPENDS.${PYPACKAGE}}:${PYPKGSRCDIR}
PYPKGPREFIX=				py${_PYTHON_VERSION}
.endif
.if !empty(_PYTHON_VERSION:M3*)
PLIST.py3x=				yes
.endif
.if !empty(_PYTHON_VERSION:M2*)
PLIST.py2x=				yes
.endif

PTHREAD_OPTS+=	require
.include "../../mk/pthread.buildlink3.mk"

PYTHON_FOR_BUILD_ONLY?=		no
.if defined(PYPKGSRCDIR)
.  if !empty(PYTHON_FOR_BUILD_ONLY:M[tT][oO][oO][lL])
TOOL_DEPENDS+=			${PYDEPENDENCY}
.  elif !empty(PYTHON_FOR_BUILD_ONLY:M[tT][eE][sS][tT])
TEST_DEPENDS+=			${PYDEPENDENCY}
.  else
.    if !empty(PYTHON_FOR_BUILD_ONLY:M[yY][eE][sS])
BUILDLINK_DEPMETHOD.python?=	build
.    endif
.    include "${PYPKGSRCDIR}/buildlink3.mk"
.  endif
.endif

PYTHONBIN=	${LOCALBASE}/bin/python${PYVERSSUFFIX}
.if exists(${PYTHONBIN}m)
PYTHONCONFIG=	${LOCALBASE}/bin/python${PYVERSSUFFIX}m-config
.else
PYTHONCONFIG=	${LOCALBASE}/bin/python${PYVERSSUFFIX}-config
.endif
PY_COMPILE_ALL= \
	${PYTHONBIN} ${PREFIX}/lib/python${PYVERSSUFFIX}/compileall.py -q
PY_COMPILE_O_ALL= \
	${PYTHONBIN} -O ${PREFIX}/lib/python${PYVERSSUFFIX}/compileall.py -q

PYINC=		include/python${PYVERSSUFFIX}
PYLIB=		lib/python${PYVERSSUFFIX}
PYSITELIB=	${PYLIB}/site-packages

PRINT_PLIST_AWK+=	/^${PYINC:S|/|\\/|g}/ \
			{ gsub(/${PYINC:S|/|\\/|g}/, "$${PYINC}") }
PRINT_PLIST_AWK+=	/^${PYSITELIB:S|/|\\/|g}/ \
			{ gsub(/${PYSITELIB:S|/|\\/|g}/, "$${PYSITELIB}") }
PRINT_PLIST_AWK+=	/^${PYLIB:S|/|\\/|g}/ \
			{ gsub(/${PYLIB:S|/|\\/|g}/, "$${PYLIB}") }

ALL_ENV+=		PYTHON=${PYTHONBIN}
.if defined(USE_CMAKE)
# used by FindPython
CMAKE_ARGS+=		-DPython_EXECUTABLE:FILEPATH=${PYTHONBIN}
CMAKE_ARGS+=		-DPython_INCLUDE_DIR:PATH=${BUILDLINK_DIR}/${PYINC}
# used by FindPython2
.  if !empty(_PYTHON_VERSION:M2*)
CMAKE_ARGS+=		-DPython2_EXECUTABLE:FILEPATH=${PYTHONBIN}
CMAKE_ARGS+=		-DPython2_INCLUDE_DIR:PATH=${BUILDLINK_DIR}/${PYINC}
.  endif
# used by FindPython3
.  if !empty(_PYTHON_VERSION:M3*)
CMAKE_ARGS+=		-DPython3_EXECUTABLE:FILEPATH=${PYTHONBIN}
CMAKE_ARGS+=		-DPython3_INCLUDE_DIR:PATH=${BUILDLINK_DIR}/${PYINC}
.  endif
# used by FindPythonInterp.cmake and FindPythonLibs.cmake
CMAKE_ARGS+=		-DPYVERSSUFFIX:STRING=${PYVERSSUFFIX}
# set this explicitly, as by default it will prefer the built in framework
# on Darwin
CMAKE_ARGS+=		-DPYTHON_INCLUDE_DIR:PATH=${BUILDLINK_DIR}/${PYINC}
CMAKE_ARGS+=		-DPYTHON_INCLUDE_PATH:PATH=${BUILDLINK_DIR}/${PYINC}
CMAKE_ARGS+=		-DPYTHON_EXECUTABLE:FILEPATH=${PYTHONBIN}
.endif

_VARGROUPS+=		pyversion
_USER_VARS.pyversion=	PYTHON_VERSION_DEFAULT
_PKG_VARS.pyversion=	\
	PYTHON_VERSIONS_ACCEPTED PYTHON_VERSIONS_INCOMPATIBLE		\
	PYTHON_SELF_CONFLICT PYTHON_FOR_BUILD_ONLY USE_CMAKE
_SYS_VARS.pyversion=	\
	PYTHON_VERSION_REQD PYPACKAGE PYVERSSUFFIX PYPKGSRCDIR		\
	PYPKGPREFIX PYTHONBIN PYTHONCONFIG PY_COMPILE_ALL		\
	PY_COMPILE_O_ALL PYINC PYLIB PYSITELIB CMAKE_ARGS
_USE_VARS.pyversion=	\
	PKGNAME_REQD PKGNAME_OLD LOCALBASE PREFIX BUILDLINK_DIR PKGNAME
_DEF_VARS.pyversion=	\
	CONFLICTS MULTI PLIST_VARS BUILDLINK_API_DEPENDS.${PYPACKAGE}	\
	PYDEPENDENCY PLIST.py2x PLIST.py3x PTHREAD_OPTS TOOL_DEPENDS	\
	TEST_DEPENDS BUILDLINK_DEPMETHOD.python PRINT_PLIST_AWK ALL_ENV	\
	_PYTHON_VERSIONS_ACCEPTED _PYTHON_VERSION
_IGN_VARS.pyversion=	_PYTHON_*
_LISTED_VARS.pyversion=	*_ARGS
_SORTED_VARS.pyversion=	*_DEPENDS *_ENV

.endif	# PYTHON_PYVERSION_MK
