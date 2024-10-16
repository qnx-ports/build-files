# pkg-config files for QNX SDP
This folder contains pkg-config files that is missing in the official SDP releases. By adding them back, build systems like `meson` should be able to pick up these dependencies automatically, rather than needing to edit the build script each time.

**NOTE**: Since most OSS build systems doesn't use the multiarch filesystem layout employed by the SDP, use separate `target` folder for each architectures, or you might mix up build artifacts in places like `usr/lib`.

## Usage
To use, simply copy all the `.pc` files in the corresponding SDP and arch folder into `$QNX_TARGET/usr/lib/pkgconfig`.

Then, you'll need to make sure `PKG_CONFIG_SYSROOT_DIR` and `PKG_CONFIG_LIBDIR` are set correctly and are both absolute paths. This is usually done by the build system:

### Meson build system
Meson has a cross-compile config file. To specify pkg-config settings, add these under `properties`:

```meson
#...some config, like host_machine

[properties]
#...some other config under properties
sys_root = $QNX_TARGET
pkg_config_libdir = $QNX_TARGET/usr/lib/pkgconfig
```
