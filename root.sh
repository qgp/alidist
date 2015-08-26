package: ROOT
version: v6-04-02
source: https://github.com/alisw/root
requires: 
  - CMake
  - AliEn-Runtime
  - GSL
env:
  ROOTSYS: "$INSTALLROOT"
---
#!/bin/bash -e

COMPILER_CC=cc
COMPILER_CXX=c++
COMPILER_LD=c++

case $ARCHITECTURE in 
  osx*)
    ENABLE_COCOA=true
    DISABLE_FINK=true
    WITH_CLANG=true
    COMPILER_CC=clang
    COMPILER_CXX=clang++
    COMPILER_LD=clang
  ;;
esac

export ROOTSYS=$BUILDDIR
"$SOURCEDIR/configure" \
  --with-pythia6-uscore=SINGLE \
  --with-alien-incdir=$ALIEN_RUNTIME_ROOT/api/include \
  --with-alien-libdir=$ALIEN_RUNTIME_ROOT/api/lib \
  --with-monalisa-incdir=$ALIEN_RUNTIME_ROOT/api/include \
  --with-monalisa-libdir=$ALIEN_RUNTIME_ROOT/api/lib \
  --with-xrootd=$ALIEN_RUNTIME_ROOT/api \
  --enable-minuit2 \
  --enable-roofit \
  --enable-soversion \
  --enable-builtin-freetype \
  --enable-builtin-pcre \
  --enable-mathmore \
  ${ENABLE_COCOA+--enable-cocoa} \
  --disable-bonjour \
  ${DISABLE_FINK+--disable-fink} \
  --with-f77=gfortran \
  --with-cc=$COMPILER_CC \
  --with-cxx=$COMPILER_CXX \
  --with-ld=$COMPILER_LD \
  ${WITH_CLANG+--with-clang} \
  --disable-shadowpw \
  --disable-astiff \
  --with-xml-incdir=$ALIEN_RUNTIME_ROOT/include/libxml2 \
  --with-xml-libdir=$ALIEN_RUNTIME_ROOT/lib \
  --disable-globus \
  --with-ssl-libdir=$ALIEN_RUNTIME_ROOT/lib \
  --with-ssl-incdir=$ALIEN_RUNTIME_ROOT/include \
  --with-ssl-shared=yes \
  --enable-mysql

./bin/root-config --features | grep -q alien
./bin/root-config --features | grep -q opengl

make ${JOBS+-j $JOBS}
export ROOTSYS=$INSTALLROOT
make install

# Modulefile
MODULEDIR="$INSTALLROOT/etc/Modules/modulefiles/$PKGNAME"
MODULEFILE="$MODULEDIR/$PKGVERSION-$PKGREVISION"
mkdir -p "$MODULEDIR"
cat > "$MODULEFILE" <<EoF
#%Module1.0
proc ModulesHelp { } {
  global version
  puts stderr "ALICE Modulefile for $PKGNAME $PKGVERSION-$PKGREVISION"
}
set version $PKGVERSION-$PKGREVISION
module-whatis "ALICE Modulefile for $PKGNAME $PKGVERSION-$PKGREVISION"
# Dependencies
module load BASE/1.0 AliEn-Runtime/$ALIEN_RUNTIME_VERSION-$ALIEN_RUNTIME_REVISION
# Our environment
setenv ROOT_RELEASE \$version
setenv ROOT_BASEDIR \$::env(BASEDIR)/$PKGNAME
setenv ROOTSYS \$::env(ROOT_BASEDIR)/\$::env(ROOT_RELEASE)
prepend-path PATH \$::env(ROOTSYS)/bin
prepend-path LD_LIBRARY_PATH \$::env(ROOTSYS)/lib
EoF
