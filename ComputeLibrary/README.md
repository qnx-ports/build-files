# Compile the port for QNX

**NOTE**: QNX ports are only supported from a Linux host operating system

Don't forget the source qnxsdp-env.sh in your QNX SDP.

```bash
# Clone the repos
git clone https://gitlab.com/qnx/libs/qnx-ports.git
git clone https://gitlab.com/qnx/libs/ComputeLibrary.git

# Build
BUILD_EXAMPLES="ON" BUILD_TESTING="ON" QNX_PROJECT_ROOT="$(pwd)/ComputeLibrary" make -C qnx-ports/ComputeLibrary install -j$(nproc)
```

# How to run tests

scp libraries and tests to the target.
```bash
# Move neon test binaries to your QNX target
scp ${QNX_TARGET}/aarch64le/usr/local/bin/ComputeLibrary_tests/ root@<target-ip-address>:/usr/bin

# Move the ARM Compute Library to your QNX target
scp ${QNX_TARGET}/aarch64le/usr/local/lib/libarm_compute* root@<target-ip-address>:/usr/lib
# Move the ARM Compute Library to your QNX target
scp ${QNX_TARGET}/aarch64le/lib/libgomp.so.1 root@<target-ip-address>:/usr/lib
```

Run tests on the target.
```bash
# ssh into the target
ssh root@<target-ip-address>

# Run unit tests
cd /usr/bin/ComputeLibrary_tests
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
...
```
