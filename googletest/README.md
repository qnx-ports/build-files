# Compile the port for QNX

**NOTE**: QNX ports are only supported from a Linux host operating system

Don't forget the source qnxsdp-env.sh in your QNX SDP.

```bash
# Create a workspace
mkdir -p ~/googletest_workspace && cd ~/googletest_workspace

# Clone the qnx-ports and googletest repos
git clone https://gitlab.com/qnx/libs/qnx-ports.git
git clone https://gitlab.com/qnx/libs/googletest.git

# Build
JLEVEL=4 BUILD_TESTING="ON" QNX_PROJECT_ROOT="~/googletest_workspace/googletest" make -C qnx-ports/googletest install
```
