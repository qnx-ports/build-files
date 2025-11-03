# Compile the port for QNX on Ubuntu host

```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git

# Source SDP environment
# for 7.1
source ~/qnx710/qnxsdp-env.sh
# for 8.0
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

# clone mpfr
wget https://www.mpfr.org/mpfr-4.2.2/mpfr-4.2.2.tar.xz
tar -xf mpfr-4.2.2.tar.xz 
mv mpfr-4.2.2 mpfr

# Build mpfr
QNX_PROJECT_ROOT="$(pwd)/mpfr" make -C build-files/ports/mpfr clean
QNX_PROJECT_ROOT="$(pwd)/mpfr" make -C build-files/ports/mpfr install JLEVEL=4
