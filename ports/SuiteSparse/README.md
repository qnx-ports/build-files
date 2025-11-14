**NOTE**: QNX ports are only supported from a Linux host operating system

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.

# Compile the port for QNX in a Docker container

Pre-requisite: Install Docker on Ubuntu https://docs.docker.com/engine/install/ubuntu/

```bash
# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/build-files.git

# Build the Docker image and create a container
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh
# (Use ~/qnx710/qnxsdp-env.sh for SDP 7.1)

# Clone and Build METIS
cd ~/qnx_workspace
git clone https://github.com/qnx-ports/METIS.git
git clone https://github.com/KarypisLab/GKlib.git && cd GKlib
# Checkout latest tested commit
git checkout 8bd6bad750b2b0d90800c632cf18e8ee93ad72d7
git apply ~/qnx_workspace/build-files/ports/METIS/patches/GKlib.patch

# Clone and Build OpenBLAS
git clone https://github.com/qnx-ports/OpenBLAS.git
QNX_PROJECT_ROOT="$(pwd)/OpenBLAS" make -C build-files/ports/OpenBLAS/ install -j4

# Clone and Build clapack
git clone https://github.com/qnx-ports/clapack.git
make -C build-files/ports/clapack install

# Clone and Build gmp
wget https://gmplib.org/download/gmp/gmp-6.2.0.tar.xz
tar -xvf gmp-6.2.0.tar.xz 
mv gmp-6.2.0 gmp
QNX_PROJECT_ROOT="$(pwd)/gmp" make -C build-files/ports/gmp clean
QNX_PROJECT_ROOT="$(pwd)/gmp" make -C build-files/ports/gmp install JLEVEL=4

# Clone and Build mpfr
wget https://www.mpfr.org/mpfr-4.2.2/mpfr-4.2.2.tar.xz
tar -xvf mpfr-4.2.2.tar.xz 
mv mpfr-4.2.2 mpfr
QNX_PROJECT_ROOT="$(pwd)/mpfr" make -C build-files/ports/mpfr install clean
QNX_PROJECT_ROOT="$(pwd)/mpfr" make -C build-files/ports/mpfr install JLEVEL=4

# Clone SuiteSparse
git clone https://github.com/qnx-ports/SuiteSparse.git
make -C build-files/ports/SuiteSparse install JLEVEL=4
```

# Compile the port for QNX on Ubuntu host

```bash
# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/build-files.git

# source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh
# (Use ~/qnx710/qnxsdp-env.sh for SDP 7.1)

# Clone and Build METIS
cd ~/qnx_workspace
git clone https://github.com/qnx-ports/METIS.git
git clone https://github.com/KarypisLab/GKlib.git && cd GKlib
# Checkout latest tested commit
git checkout 8bd6bad750b2b0d90800c632cf18e8ee93ad72d7
git apply ~/qnx_workspace/build-files/ports/METIS/patches/GKlib.patch

# Clone and Build OpenBLAS
git clone https://github.com/qnx-ports/OpenBLAS.git
QNX_PROJECT_ROOT="$(pwd)/OpenBLAS" make -C build-files/ports/OpenBLAS/ install -j4

# Clone and Build clapack
git clone https://github.com/qnx-ports/clapack.git
make -C build-files/ports/clapack install

# Clone and Build gmp
wget https://gmplib.org/download/gmp/gmp-6.2.0.tar.xz
tar -xvf gmp-6.2.0.tar.xz 
mv gmp-6.2.0 gmp
QNX_PROJECT_ROOT="$(pwd)/gmp" make -C build-files/ports/gmp clean
QNX_PROJECT_ROOT="$(pwd)/gmp" make -C build-files/ports/gmp install JLEVEL=4

# Clone and Build mpfr
wget https://www.mpfr.org/mpfr-4.2.2/mpfr-4.2.2.tar.xz
tar -xvf mpfr-4.2.2.tar.xz 
mv mpfr-4.2.2 mpfr
QNX_PROJECT_ROOT="$(pwd)/mpfr" make -C build-files/ports/mpfr install clean
QNX_PROJECT_ROOT="$(pwd)/mpfr" make -C build-files/ports/mpfr install JLEVEL=4

# Clone SuiteSparse
git clone https://github.com/qnx-ports/SuiteSparse.git
make -C build-files/ports/SuiteSparse install JLEVEL=4
```
# Running tests

```bash
export TARGET_HOST=<target-ip-address-or-hostname>

# Copy the dependency libraries for testing
scp $QNX_TARGET/aarch64le/usr/local/lib/lib*.so*   qnxuser@$TARGET_HOST:~/lib
scp $(pwd)/SuiteSparse/Mongoose/Matrix qnxuser@$TARGET_HOST:~/Matrix/Mongoose
scp $(pwd)/SuiteSparse/LAGraph/data qnxuser@$TARGET_HOST:~/Matrix/LAGraph
scp $(pwd)/SuiteSparse/CHOLMOD/Demo/Matrix qnxuser@$TARGET_HOST:~/Matrix/CHOLMOD

# Copy test binaries to target
scp $(pwd)/build-files/ports/SuiteSparse/nto-aarch64-le/build/CHOLMOD/tests qnxuser@$TARGET_HOST:~/tests
scp $(pwd)/build-files/ports/SuiteSparse/nto-aarch64-le/build/LAGraph/tests qnxuser@$TARGET_HOST:~/tests
scp $(pwd)/build-files/ports/SuiteSparse/nto-aarch64-le/build/Mongoose/tests qnxuser@$TARGET_HOST:~/tests
```

### On target run

```bash
cd ~/tests
export LD_LIBRARY_PATH=$HOME/lib:$LD_LIBRARY_PATH
./cholmod_di_demo ~/Matrix/CHOLMOD/matrixname.mtx
```





