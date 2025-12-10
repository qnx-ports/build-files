if patch --dry-run -p1 -ruN -d ../../tests < ../test/qnx_patches/test.patch; then
  patch -p1 -ruN -d ../../tests < ../test/qnx_patches/test.patch
fi
