# 2048 libretro
An implementation of 2048 using libretro.

**Repository:** https://github.com/libretro/libretro-2048 \
**Website:** https://docs.libretro.com/library/2048/ \
**Supports:** RetroArch for QNX

You must build [RetroArch for QNX](../../RetroArch/README.md) to use this core. \
You should first run `make install` for RetroArch and any cores you wish to use, then follow the installation instructions in [RetroArch for QNX README.md](../../RetroArch/README.md).

## Build
```bash
# 1. Clone repos into a workspace
cd workspace      #Or make a new one and navigate into it
git clone https://github.com/libretro/libretro-2048.git
git clone https://github.com/qnx-ports/build-files.git

# 2. Source QNX SDP 8
source ~/qnx800/qnxsdp-env.sh

# 3. Navigate here and run make/make install
cd workspace/build-files/ports/libretro-cores/2048
make
make install
```
