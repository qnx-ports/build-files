Some shared resources that are applicable for multiple projects.

+ `meson/qnx*.ini`
  - meson cross-compile file, allow meson to correctly set compile environment with QNX SDP
+ `pkgconfig/*.pc`
  - library helper files that are omitted in official QNX SDP releases. allow build systems like meson and cmake to automatically find and configure libraries
