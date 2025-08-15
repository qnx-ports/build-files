# fake-08
An implementation of PICO-8 using libretro.

**Repository:** https://github.com/jtothebell/fake-08/ \
**PICO-8 Website:** https://www.lexaloffle.com/pico-8.php \
**Supports:** RetroArch for QNX

You must build [RetroArch for QNX](../../RetroArch/README.md) to use this core. \
You should first run `make install` for RetroArch and any cores you wish to use, then follow the installation instructions in [RetroArch for QNX README.md](../../RetroArch/README.md). \
Make sure to grab some [PICO-8 Carts](https://www.lexaloffle.com/bbs/?cat=7&carts_tab=1#mode=carts&sub=2), which can be copied over to your target and installed via the install content option in retroarch. (alternatively, copy them directly to `retroarch/rarch-shared/content/`)

**IMPORTANT:** \
-> Default libretro controls work by translating your keyboard into a gamepad. \
-> Standard keyboard controls are *not* what you may be expecting. \
-> PICO-8 Games that you download with keyboard control labels can be incorrect

**The controls are as follows:** \
D-Pad Up: E \
D-Pad Down: S \
D-Pad Left: W \
D-Pad Right: D \
A-Button: K \
B-Button: L

## Build
```bash
# 1. Clone repos into a workspace
cd workspace      #Or make a new one and navigate into it
git clone https://github.com/jtothebell/fake-08/.git
git clone https://github.com/qnx-ports/build-files.git

# 2. Source QNX SDP 8
source ~/qnx800/qnxsdp-env.sh

# 3. Navigate here and run make/make install
cd workspace/build-files/ports/libretro-cores/fake-08
make
make install
```
