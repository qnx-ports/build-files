# Compile Glib for QNX
To build, first enable your SDP, and then edit `qnx_target` `qnx710.ini` or `qnx800.ini` to reflect the real SDP location.

Then, run:

``` bash
# For QNX 8.0.0
meson setup --cross-file qnx800.ini build-qnx800 -Dprefix=$TARGET_DIR -Dxattr=false
cd build-qnx800 && ninja && ninja install
# For QNX 7.1.0
meson setup --cross-file qnx710.ini build-qnx710 -Dprefix=$TARGET_DIR -Dxattr=false
cd build-qnx710 && ninja && ninja install
```

And build products will be available in `$TARGET_DIR`
