# MrBoom libretro
A port of Bomberman using libretro.

**Repository:** https://github.com/Javanaise/mrboom-libretro \
**Website:** https://docs.libretro.com/library/mr_boom/ \
**Supports:** RetroArch for QNX

You must build [RetroArch for QNX](../../RetroArch/README.md) to use this core. \
You should first run `make install` for RetroArch and any cores you wish to use, then follow the installation instructions in [RetroArch for QNX README.md](../../RetroArch/README.md).

## Build
```bash
# 1. Clone repos into a workspace
cd workspace      #Or make a new one and navigate into it
git clone https://github.com/Javanaise/mrboom-libretro
git clone https://github.com/qnx-ports/build-files

# 2. Source QNX SDP 8
source ~/qnx800/qnxsdp-env.sh

# 3. Navigate here and run make/make install
cd workspace/build-files/ports/libretro-cores/mrboom
make
make install
```
