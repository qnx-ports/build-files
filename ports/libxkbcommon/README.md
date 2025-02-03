**NOTE**: QNX ports are only supported from a Linux host operating system

# Compile the port for QNX in a Docker container

**Pre-requisite**: Install Docker on Ubuntu https://docs.docker.com/engine/install/ubuntu/
```bash
# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/build-files.git

# Build the Docker image and create a container
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# Now you are in the Docker container

# Clone libxkbcommon
cd ~/qnx_workspace
git clone https://github.com/xkbcommon/libxkbcommon.git

# Checkout xkbcommon-1.7.0
cd libxkbcommon
git checkout xkbcommon-1.7.0


# Meson setup for your desired architecture
# Adjust the cross file paths to your machines path
export QNX_ARCH=aarch64le

meson setup build \
    --prefix=/$(QNX_ARCH)/usr \
    --includedir=/usr/include \
    --cross-file ~/qnx-ports/build-files/resources/meson/$(QNX_ARCH)/qnx800.ini \
    -Dc_args=-D_QNX_SOURCE \
    -Ddefault-layout=us \
    -Denable-tools=false \
    -Denable-x11=false \
    -Denable-xkbregistry=false \
    -Denable-docs=false \
    -Ddefault-rules=hidut \
    -Dxkb-config-root=/usr/share/xkb \
    -Dx-locale-root=/usr/share/locale

# Meson compile
meson compile -C build/

# Meson install
meson install -C build --destdir=$QNX_TARGET/

```

# Compile the port for QNX on Ubuntu host
```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace

# Clone libxkbcommon
cd ~/qnx_workspace
git clone https://github.com/libxkbcommon/libxkbcommon.git

# Checkout xkbcommon-1.7.0
cd libxkbcommon
git checkout xkbcommon-1.7.0

# Meson setup for your desired architecture
# Adjust the cross file paths to your machines path
export QNX_ARCH=aarch64le

meson setup build \
    --prefix=/$(QNX_ARCH)/usr \
    --includedir=/usr/include \
    --cross-file ~/qnx-ports/build-files/resources/meson/$(QNX_ARCH)/qnx800.ini \
    -Dc_args=-D_QNX_SOURCE \
    -Ddefault-layout=us \
    -Denable-tools=false \
    -Denable-x11=false \
    -Denable-xkbregistry=false \
    -Denable-docs=false \
    -Ddefault-rules=hidut \
    -Dxkb-config-root=/usr/share/xkb \
    -Dx-locale-root=/usr/share/locale

# Meson compile
meson compile -C build/

# Meson install
meson install -C build/ --destdir=$QNX_TARGET/
```
