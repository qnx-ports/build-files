# RetroArch
A frontend for running games using libretro.

**Repository:** https://github.com/qnx-ports/RetroArch \
**Upstream:** https://github.com/libretro/RetroArch \
**Website:** https://www.retroarch.com/ \
**Supports:** QNX 8.0, aarch64 processors.



## Build
```bash
# 1. Clone repos into a workspace
cd workspace      #Or make a new one and navigate into it
git clone https://github.com/qnx-ports/retroarch.git
git clone https://github.com/qnx-ports/build-files.git

# 2. Source QNX SDP 8
source ~/qnx800/qnxsdp-env.sh

# 3. Navigate here and run make/make install
cd workspace/build-files/ports/RetroPie/RetroArch
make
make install
```
## Install and Run
Replace \<user\> and \<target\> appropriately.
```bash
# 1. Navigate to staging and scp to target
cd workspace/build-files/ports/RetroPie/staging/aarch64le
ssh <user>@<target> "mkdir -p /data/home/<user>/retroarch/"
scp -r * <user>@<target>:/data/home/<user>/retroarch/

# 2. Run startup.sh on target
ssh <user>@<target>
cd retroarch
./startup.sh
```
