# Compile the port for QNX

**NOTE**: QNX ports are only supported from a Linux host operating system

Don't forget the source qnxsdp-env.sh in your QNX SDP.

```bash
# Create a workspace
mkdir -p ~/tinyxml2_workspace && cd ~/tinyxml2_workspace

# Clone the qnx-ports and tinyxml2 repos
git clone https://gitlab.com/qnx/libs/qnx-ports.git
git clone https://gitlab.com/qnx/libs/tinyxml2.git

# Build
JLEVEL=4 BUILD_TESTING="ON" QNX_PROJECT_ROOT="~/tinyxml2_workspace/tinyxml2" make -C qnx-ports/tinyxml2 install
```
