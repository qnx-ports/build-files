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

# Clone metis
cd ~/qnx_workspace
git clone https://github.com/qnx-ports/METIS.git

# Clone OpenBLAS
git clone https://github.com/qnx-ports/OpenBLAS.git

# Clone clapack
git clone https://github.com/qnx-ports/clapack.git

# clone mpfr
wget https://www.mpfr.org/mpfr-4.2.2/mpfr-4.2.2.tar.xz
tar -xvf mpfr-4.2.2.tar.xz 
mv mpfr-4.2.2 mpfr

# Clone gmp
wget https://gmplib.org/download/gmp/gmp-6.2.0.tar.xz
tar -xvf gmp-6.2.0.tar.xz 
mv gmp-6.2.0 gmp

#Clone SuiteSparse
git clone https://github.com/qnx-ports/SuiteSparse.git
cd SuiteSparse
git checkout v7.11.0
cd ..

# Build metis
cd ~/qnx_workspace
git clone https://github.com/KarypisLab/GKlib.git && cd GKlib
# Checkout latest tested commit
git checkout 8bd6bad750b2b0d90800c632cf18e8ee93ad72d7
git apply ~/qnx_workspace/build-files/ports/METIS/patches/GKlib.patch

cd ~/qnx_workspace
GKLIB_SRC="$(pwd)/GKlib" QNX_PROJECT_ROOT="$(pwd)/METIS" make -C build-files/ports/METIS install -j4

QNX_PROJECT_ROOT="$(pwd)/OpenBLAS" make -C build-files/ports/OpenBLAS/ install -j4
make -C build-files/ports/clapack install
QNX_PROJECT_ROOT="$(pwd)/gmp" make -C build-files/ports/gmp install JLEVEL=4
QNX_PROJECT_ROOT="$(pwd)/mpfr" make -C build-files/ports/mpfr install JLEVEL=4
QNX_PROJECT_ROOT="$(pwd)/SuiteSparse" make -C build-files/ports/SuiteSparse install JLEVEL=4
```

# Compile the port for QNX on Ubuntu host

```bash
# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/build-files.git

# source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh
# (Use ~/qnx710/qnxsdp-env.sh for SDP 7.1)

# Clone metis
cd ~/qnx_workspace
git clone https://github.com/qnx-ports/METIS.git

# Clone OpenBLAS
git clone https://github.com/qnx-ports/OpenBLAS.git

# Clone clapack
git clone https://github.com/qnx-ports/clapack.git

# clone mpfr
wget https://www.mpfr.org/mpfr-4.2.2/mpfr-4.2.2.tar.xz
tar -xf mpfr-4.2.2.tar.xz 
mv mpfr-4.2.2 mpfr

# Clone gmp
wget https://gmplib.org/download/gmp/gmp-6.2.0.tar.xz
tar -xvf gmp-6.2.0.tar.xz 
mv gmp-6.2.0 gmp

#Clone SuiteSparse
git clone https://github.com/qnx-ports/SuiteSparse.git
cd SuiteSparse
git checkout v7.11.0
cd ..

# Build metis
cd ~/qnx_workspace
git clone https://github.com/KarypisLab/GKlib.git && cd GKlib
# Checkout latest tested commit
git checkout 8bd6bad750b2b0d90800c632cf18e8ee93ad72d7
git apply ~/qnx_workspace/build-files/ports/METIS/patches/GKlib.patch

cd ~/qnx_workspace
GKLIB_SRC="$(pwd)/GKlib" QNX_PROJECT_ROOT="$(pwd)/METIS" make -C build-files/ports/METIS install -j4

QNX_PROJECT_ROOT="$(pwd)/OpenBLAS" make -C build-files/ports/OpenBLAS/ install -j4
make -C build-files/ports/clapack install
QNX_PROJECT_ROOT="$(pwd)/gmp" make -C build-files/ports/gmp install JLEVEL=4
QNX_PROJECT_ROOT="$(pwd)/mpfr" make -C build-files/ports/mpfr install JLEVEL=4
QNX_PROJECT_ROOT="$(pwd)/SuiteSparse" make -C build-files/ports/SuiteSparse install JLEVEL=4
```


