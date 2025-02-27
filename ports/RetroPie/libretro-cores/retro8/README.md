# retro8
An implementation of PICO-8 using libretro.

**Repository:** https://github.com/Jakz/retro8 \
**PICO-8 Website:** https://www.lexaloffle.com/pico-8.php \
**Supports:** RetroArch for QNX

You must build [RetroArch for QNX](../../RetroArch/README.md) to use this core. \
You should first run `make install` for RetroArch and any cores you wish to use, then follow the installation instructions in [RetroArch for QNX README.md](../../RetroArch/README.md). \
Make sure to grab some [PICO-8 Carts](https://www.lexaloffle.com/bbs/?cat=7&carts_tab=1#mode=carts&sub=2), which can be copied over to your target and installed via the install content option in retroarch.

Note: Currently, there are still many issues with retro8 on QNX. A fork may be coming in the near future to resolve these.

## Build
```bash
# 1. Clone repos into a workspace
cd workspace      #Or make a new one and navigate into it
git clone https://github.com/Jakz/retro8.git
git clone https://github.com/qnx-ports/build-files.git

# 2. Source QNX SDP 8
source ~/qnx800/qnxsdp-env.sh

# 3. Navigate here and run make/make install
cd workspace/build-files/ports/libretro-cores/retro8
make
make install
```
