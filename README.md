contour clustering

To see the demo:
cd matlab;
test_image;

About the 3rdParty compiling
1. Ncut
On my experiment with OS X (Maverick) and Matlab2013b, the original Ncut code reported an error to the function arpackc(). The way to fix this is: in file ncut.m, replace eigs_new() with eigs().
2. structure contour detection
1) It may give error in compiling if you are using Xcode 5 and Matlab2013b together. You need to modify $matlabroot$/bin/mexopts.sh: replace all 10.7 with 10.8
2) If you get error related to CHAR16_T, replace
CFLAGS="-fno-common -arch $ARCHS -isysroot $MW_SDKROOT -mmacosx-version-min=$MACOSX_DEPLOYMENT_TARGET"
with
CFLAGS="-fno-common -arch $ARCHS -isysroot $MW_SDKROOT -mmacosx-version-min=$MACOSX_DEPLOYMENT_TARGET -Dchar16_t=uint16_T"
3) If the compiling complains about cannot find "omp.h", ignore it. That means openMP cannot be used and the code is working in one thread. That's fine.

