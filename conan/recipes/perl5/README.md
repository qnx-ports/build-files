**NOTE**: QNX ports are only supported from a Linux host operating system


# Pre-requisite

* Install QNX license and SDP installation (~/.qnx and ~/qnx800 by default)
  - https://www.qnx.com/products/everywhere/ (**Non-Commercial Use**)
* Install Docker on Ubuntu - OPTIONAL
  - https://docs.docker.com/engine/install/ubuntu/
* Install venv - recomended by conan documentation - OPTIONAL
  - https://docs.python.org/3/library/venv.html
* Install Conan2
  - https://docs.conan.io/2/installation.html

# Create a workspace

```bash
# Clone conan recipes
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
```

# Setup a Docker container
```bash
# Build the Docker image and create a container
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# Now you are in the Docker container
```

# Or setup Ubuntu host
```bash
# Source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh
```

# Update conan setting for QNX8.0
```bash
# Setup conan root folder
export QNX_CONAN_ROOT=$(realpath ~/qnx_workspace/build-files/conan)

# Detect build profile
conan profile detect

# Update conan settings for QNX8.0 support
conan config install $QNX_CONAN_ROOT/tools/qnx-8.0-extension/settings_user.yml
```

# Build and install release perl5 for QNX into conan cache
```bash
cd ~/qnx_workspace

#
# <profile-name>: nto-7.1-aarch64-gcc, nto-7.1-x86_64-gcc, nto-8.0-aarch64-gcc, nto-8.0-x86_64-gcc
# <version-number>: 5.32.0, 5.36.0, 5.42.0
#
conan create -pr:h=$QNX_CONAN_ROOT/tools/profiles/<profile-name> --version=<version-number> $QNX_CONAN_ROOT/recipes/perl5/all
```

# Deploy perl5 into QNX SDP
```bash
cd ~/qnx_workspace

mkdir stage_perl5

PATH_2_STAGE=$(realpath ~/qnx_workspace/stage_perl5)

# deploy perl to the stage folder
conan install -pr:h=$QNX_CONAN_ROOT/tools/profiles/nto-8.0-x86_64-gcc \
    --requires=perl5/5.42.0 \
    --deployer=direct_deploy \
    --deployer-folder=$PATH_2_STAGE

# copy perl into SDP
cp -r $PATH_2_STAGE/direct_deploy/perl5/usr/* $QNX_TARGET/x86_64/usr/

# run qemu instance with new perl
mkqnximage --type=qemu --arch=x86_64 --clean --run --force --perl=yes
```

# Build QNX tests for perl5
```bash
cd ~/qnx_workspace

# Clone perl5 from QNX fork
git clone https://github.com/qnx-ports/perl5.git

# Or clone perl5 sources from original repo
git clone https://github.com/Perl/perl5.git

# Clone perl-crross
git clone https://github.com/arsv/perl-cross.git

# copy perl-crross into perl5 build tree
rsync -a --force --exclude='.git*' ./perl-cross/ ./perl5/

cd perl5

# Setup project root folder
export QNX_PROJECT_ROOT=$(pwd)

# Setup env for local build
conan install -pr:h=$QNX_CONAN_ROOT/tools/profiles/nto-8.0-x86_64-gcc $QNX_CONAN_ROOT/recipes/perl5/tests

# Build perl5 with tests
conan build -pr:h=$QNX_CONAN_ROOT/tools/profiles/nto-8.0-x86_64-gcc $QNX_CONAN_ROOT/recipes/perl5/tests
```

# Run tests on the target.

**IMPORTANT** perl build tree needs **space** > 500Mb on data partition and **inodes** > 20k
### For example: mkqnximage --type=qemu --arch=x86_64 --clean --run --force --data-size=500 --data-inodes=20000
```bash
# define target IP address
TARGET_HOST=<target-ip-address-or-hostname>

# remove old test dir on target
ssh qnxuser@$TARGET_HOST "rm -rf perl5_tests"

# create new test dir on target
ssh qnxuser@$TARGET_HOST "mkdir perl5_tests"

# copy perl build tree to your QNX target
scp -r build_tests/Release/* qnxuser@$TARGET_HOST:/data/home/qnxuser/perl5_tests/

# ssh into the target
ssh qnxuser@$TARGET_HOST

# setup perl env
cd /data/home/qnxuser/perl5_tests/t && ln -sf ../perl . && LD_LIBRARY_PATH=$(pwd):$LD_LIBRARY_PATH

# run perl tests
./TEST
```

### QNX8.0 x86_64 v5.42.0:
```bash
Failed 54 tests out of 2548, 97.88% okay.
...
Elapsed: 712 sec
u=4.60  s=0.00  cu=404.61  cs=0.00  scripts=2548  tests=637905
```

### QNX7.1 x86_64 v5.42.0:
```bash
Failed 50 tests out of 2549, 98.04% okay.
...
Elapsed: 826 sec
u=7.00  s=0.00  cu=444.50  cs=3.06  scripts=2549  tests=637769
```

### Linux x86_64 v5.42.0:
```bash
Failed 8 tests out of 2646, 99.70% okay.
...
Elapsed: 812 sec
u=4.00  s=2.40  cu=418.31  cs=34.38  scripts=2646  tests=1319079
```

### QNX8.0 x86_64 v5.36.0:
```bash
Failed 22 tests out of 2446, 99.10% okay.
...
Elapsed: 816 sec
u=6.59  s=0.00  cu=481.03  cs=0.00  scripts=2446  tests=982511
```

### QNX7.1 x86_64 v5.36.0:
```bash
Failed 18 tests out of 2447, 99.26% okay.
...
Elapsed: 916 sec
u=9.65  s=0.03  cu=523.22  cs=3.23  scripts=2447  tests=982414
```

### Linux x86_64 v5.36.0:
```bash
Failed 7 tests out of 2520, 99.72% okay
...
Elapsed: 843 sec
u=4.60  s=2.24  cu=436.31  cs=32.60  scripts=2520  tests=1189438
```

### QNX8.0 x86_64 v5.32.0:
```bash
Failed 69 tests out of 2380, 97.10% okay.
...
Elapsed: 766 sec
u=6.02  s=0.00  cu=437.49  cs=0.00  scripts=2380  tests=947094
```

### QNX7.1 x86_64 v5.32.0:
```bash
Failed 65 tests out of 2381, 97.27% okay.
...
Elapsed: 859 sec
u=9.00  s=0.03  cu=464.15  cs=2.98  scripts=2381  tests=947285
```
