package: cgal
version: "v4.4"
requires:
  - boost
  - CMake
---
#!/bin/bash -e
PKGID=33524
Url="https://gforge.inria.fr/frs/download.php/${PKGID}/Cgal-${PKGVERSION:1}.tar.bz2"

curl -Lo cgal.tar.bz2 "$Url"
tar xjf cgal.tar.bz2
cd CGAL-${PKGVERSION:1}

export LDFLAGS="-L$BOOST_ROOT/lib"
export LD_LIBRARY_PATH="$BOOST_ROOT/lib:$LD_LIBRARY_PATH"
export DYLD_LIBRARY_PATH="$BOOST_ROOT/lib:$DYLD_LIBRARY_PATH"

cmake . \
      -DCMAKE_INSTALL_PREFIX:PATH="${INSTALLROOT}" \
      -DCMAKE_SKIP_RPATH:BOOL=YES \
      -DWITH_BLAS:BOOL=OFF \
      -DWITH_CGAL_Core:BOOL=ON \
      -DWITH_CGAL_ImageIO:BOOL=ON \
      -DWITH_CGAL_Qt3:BOOL=OFF \
      -DWITH_CGAL_Qt4:BOOL=OFF \
      -DWITH_Coin3D:BOOL=OFF \
      -DWITH_ESBTL:BOOL=OFF \
      -DWITH_Eigen3:BOOL=OFF \
      -DWITH_GMP:BOOL=ON \
      -DWITH_GMPXX:BOOL=OFF \
      -DWITH_IPE:BOOL=OFF \
      -DWITH_LAPACK:BOOL=OFF \
      -DWITH_LEDA:BOOL=OFF \
      -DWITH_MPFI:BOOL=OFF \
      -DWITH_MPFR:BOOL=ON \
      -DWITH_NTL:BOOL=OFF \
      -DWITH_OpenGL:BOOL=OFF \
      -DWITH_OpenNL:BOOL=OFF \
      -DWITH_QGLViewer:BOOL=OFF \
      -DWITH_RS:BOOL=OFF \
      -DWITH_RS3:BOOL=OFF \
      -DWITH_TAUCS:BOOL=OFF \
      -DWITH_ZLIB:BOOL=ON \
      -DWITH_demos:BOOL=OFF \
      -DWITH_examples:BOOL=OFF \
      -DCGAL_ENABLE_PRECONFIG:BOOL=NO \
      -DCGAL_IGNORE_PRECONFIGURED_GMP:BOOL=YES \
      -DCGAL_IGNORE_PRECONFIGURED_MPFR:BOOL=YES \
      -DBoost_NO_SYSTEM_PATHS:BOOL=TRUE \
      -DBOOST_ROOT:PATH="${BOOST_ROOT}"

make VERBOSE=1 ${JOBS:+-j$JOBS}
make install VERBOSE=1

# Modulefile
MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
cat > "$MODULEFILE" <<EoF
#%Module1.0
proc ModulesHelp { } {
  global version
  puts stderr "ALICE Modulefile for $PKGNAME $PKGVERSION-@@PKGREVISION@$PKGHASH@@"
}
set version $PKGVERSION-@@PKGREVISION@$PKGHASH@@
module-whatis "ALICE Modulefile for $PKGNAME $PKGVERSION-@@PKGREVISION@$PKGHASH@@"
# Dependencies
module load BASE/1.0 boost/$BOOST_VERSION-$BOOST_REVISION CMake/$CMAKE_VERSION-$CMAKE_REVISION
# Our environment
setenv CGAL_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path PATH \$::env(CGAL_ROOT)/bin
prepend-path LD_LIBRARY_PATH \$::env(CGAL_ROOT)/lib
EoF
