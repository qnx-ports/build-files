# Lua
A lightweight, versatile, and powerful scripting language suppoting procedural, object-oriented, functional, and data-driven programming. Used extensively in game programming and embedded systems.

**Repository:** https://github.com/qnx-ports/lua \
**Upstream:** https://github.com/lua/lua \
**Website:** https://www.lua.org/ \
**Supports:** TODO.



## Build
```bash
# 1. Clone repos into a workspace
cd workspace      #Or make a new one and navigate into it
git clone https://github.com/qnx-ports/lua.git
git clone https://github.com/qnx-ports/build-files.git

# 2. Source QNX SDP 8
source ~/qnx800/qnxsdp-env.sh

# 3. Navigate here and run make/make install
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
