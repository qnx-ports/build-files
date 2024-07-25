**NOTE**: QNX ports are only supported from a Linux host operating system

# Compile the port for QNX in a Docker container

Pre-requisite: Install Docker on Ubuntu https://docs.docker.com/engine/install/ubuntu/
```bash
# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://gitlab.com/qnx/ports/build-files.git

# Build the Docker image and create a container
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# Now you are in the Docker container

# source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh

# Clone ComputeLibrary
cd ~/qnx_workspace
git clone https://gitlab.com/qnx/ports/ComputeLibrary.git

# Build ComputeLibrary
BUILD_EXAMPLES="ON" BUILD_TESTING="ON" QNX_PROJECT_ROOT="$(pwd)/ComputeLibrary" make -C build-files/ports/ComputeLibrary install -j$(nproc)
```

# Compile the port for QNX on Ubuntu host
```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://gitlab.com/qnx/ports/build-files.git
git clone https://gitlab.com/qnx/ports/ComputeLibrary.git

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Build ComputeLibrary
BUILD_EXAMPLES="ON" BUILD_TESTING="ON" QNX_PROJECT_ROOT="$(pwd)/ComputeLibrary" make -C build-files/ports/ComputeLibrary install -j$(nproc)
```

# How to run tests

scp libraries and tests to the target.
```bash
# Move neon test binaries to your QNX target
scp -r ${QNX_TARGET}/aarch64le/usr/local/bin/ComputeLibrary_tests/ qnxuser@<target-ip-address>:/data/home/qnxuser/bin

# Move the ARM Compute Library to your QNX target
scp ${QNX_TARGET}/aarch64le/usr/local/lib/libarm_compute* qnxuser@<target-ip-address>:/data/home/qnxuser/lib
# Move the ARM Compute Library to your QNX target
scp ${QNX_TARGET}/aarch64le/lib/libgomp.so.1 qnxuser@<target-ip-address>:/data/home/qnxuser/lib
```
**NOTE**: You need to make sure the destination folders on the target exist. After you scped them over, you either need to use `su root -c <command>` to move files over to `/system/xbin` and `/system/lib`, or add the destination folders to `PATH` and `LD_LIBRARY_PATH` accordingly. 

Run tests on the target.
```bash
# ssh into the target
ssh root@<target-ip-address>

# Run unit tests
cd /system/xbin/ComputeLibrary_tests
./arm_compute_validation
./graph_alexnet
./graph_deepspeech_v0_4_1
./graph_edsr
./graph_googlenet
./graph_inception_resnet_v1
./graph_inception_resnet_v2
./graph_inception_v3
./graph_inception_v4
./graph_lenet
./graph_mobilenet
./graph_mobilenet_v2
./graph_resnet12
./graph_resnet50
./graph_resnet_v2_50
./graph_resnext50
./graph_shufflenet
./graph_squeezenet
./graph_squeezenet_v1_1
./graph_srcnn955
./graph_ssd_mobilenet
./graph_vgg16
./graph_vgg19
./graph_vgg_vdsr
./graph_yolov3
./neon_cnn
./neon_copy_objects
./neon_gemm_qasymm8
./neon_gemm_s8_f32
./neon_permute
./neon_scale
./neon_sgemm

# WIP Tests which currently fail:
graph_deepspeech_v0_4_1
graph_edsr
```