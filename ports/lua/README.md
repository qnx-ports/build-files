# Lua
A lightweight, versatile, and powerful scripting language suppoting procedural, object-oriented, functional, and data-driven programming. Used extensively in game programming and embedded systems. \

**Repository:** https://github.com/qnx-ports/lua \
**Upstream:** https://github.com/lua/lua \
**Website:** https://www.lua.org/ \
**Manual**: https://www.lua.org/manual/

Please note that the version of lua that is currently ported at qnx-ports/lua, v5.5, is an in-development version for purposes of upstreaming.

## Build
```bash
# 1. Clone repos into a workspace
cd workspace      #Or make a new one and navigate into it
git clone https://github.com/qnx-ports/lua.git
git clone https://github.com/qnx-ports/build-files.git

# 2. Build muslflt or rename LuaMakefileNoMuslflt.qnx to LuaMakefile.qnx
#    libmuslflt corrects floating point accuracy.
git clone https://github.com/qnx-ports/muslflt.git
source ~/qnx800/qnxsdp-env.sh
cd workspace/build-files/ports/muslflt
make install
#--OR (without muslflt)--
cd workspace/build-files/ports/lua
rm LuaMakefile.qnx
mv LuaMakefileNoMuslflt.qnx LuaMakefile.qnx

# 3. Source QNX SDP 8
source ~/qnx800/qnxsdp-env.sh

# 4. Navigate here and run make/make install
cd workspace/build-files/ports/lua
make
#OR
make lua_tests
```
## Install and Run
Replace workspace, \<architecture\>, \<user\> and \<target\> appropriately.
```bash
# 1. Navigate to staging and scp to target
cd workspace/build-files/ports/lua/<architecture>/
scp -r test_staging <user>@<target>:~/lua

# 2. Run Lua on target
ssh <user>@<target>
cd lua
./lua
#OR FOR .lua FILES:
./lua <path-to-file>
```
Note that for many .lua scipts, you will need to run the from the script's directory. e.g.
```bash
cd <script-directory>
./<script-to-programs>/lua script.lua
```
If you install lua as a commandline utility (see below), you can avoid typing in any paths and simply run it via
```bash
lua script.lua
```

## Installing as a Utility
You may wish to install lua such that you can run it anywhere via `lua <options>` instead of pasting the full filepath each time. \
The following process shows how to do this for the QNXE 8.0 Distribution. You will need root privileges.
```bash
# 0. Switch to a user with root privileges
su root
# 1. Copy Lua to the /system/xbin/ folder
cp path/to/install/lua /system/xbin/
# 2. Copy libmuslflt to /system/lib/
cp path/to/install/lib/*muslflt* /system/lib/
# 3. Test your installation
cd path/to/install/test
lua sort.lua # Or a test of your choice
```