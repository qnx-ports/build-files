# iftop 

Supports QNX7.1 and QNX8.0


# evn setup
sudo apt install autoconf
source ~/qnx800/qnxsdp-env.sh or source ~/qnx/qnx710/qnxsdp-env.sh

# Clione iftop and build 
git clone git@gitlab.com:qnx/ports/build-files.git
git clone https://github.com/soarpenguin/iftop.git)
# checkout to the latest stable
cd build-files/ports/iftop
make


# Deploy binaries via SSH
```bash
#Set your target's IP here
TARGET_IP_ADDRESS=<target-ip-address-or-hostname>
TARGET_USER=<target-username>

scp ./nto-aarch64-le/build/iftop root@ip:/usr/lib/
```


# Tests
Tests are avaliable; currently all tests are passed.
# export TERM=xterm
# iftop

               12.5kb          25.0kb          37.5kb          50.0kb    62.5kb

└───────────────┴───────────────┴───────────────┴───────────────┴───────────────





































────────────────────────────────────────────────────────────────────────────────

TX:             cum:   1.92kB   peak:      0b   rates:      0b      0b      0b

RX:                    3.66kB              0b               0b      0b      0b

TOTAL:                 5.58kB              0b               0b      0b      0b



