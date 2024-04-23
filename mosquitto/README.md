# Compile the port for QNX

**NOTE**: QNX ports are only supported from a Linux host operating system

```bash
# Clone the qnx-ports and tinyxml2 repos
git clone https://gitlab.com/qnx/libs/qnx-ports.git
git clone https://gitlab.com/qnx/libs/mosquitto.git

# Build
JLEVEL=4 QNX_PROJECT_ROOT="$(pwd)/mosquitto" make -C qnx-ports/mosquitto install
```
