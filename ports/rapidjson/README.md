**Note:** QNX ports are only officially supported from a **Linux Host**. Please install WSL if using Windows.

# RapidJSON
RapidJSON information: https://rapidjson.org/

RapidJSON is a fast, header-based JSON parsing library for C++. It is recommended that you directly include it in your project via copying the RapidJSON headers into your project's include directory, per their documentation. 

If you wish to build tests or install the headers, pkg-config, and cmake files please follow the instructions below:

## Installation
*Note:* This process will install rapidjson's headers and optionally build test executables. rapidjson does not have an associated archive or library.
1. Clone the source and QNX build-files repos into a new workspace
```bash
mkdir ~/your-wksp && cd ~/your-wksp
git clone https://github.com/Tencent/rapidjson.git
git clone git@github.com:qnx-ports/build-files.git
```
2. **\[Optional\]** Initialize the QNX Building Docker Container
```bash
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh
cd -
```

3. **\[Optional | Needed for Tests\]** Clone googletest
```bash
git clone git@github.com:qnx-ports/googletest.git
```

4. Build the project. *Note:* *replace* *qnx800* *with* *your* *SDP* *installation*.
```bash
source ~/qnx800/qnxsdp-env.sh

# Without tests
make -C build-files/ports/rapidjson/ install

# With tests
BUILD_TESTS=true make -C build-files/ports/rapidjson install
# With tests & specify Googletest Installation
BUILD_TESTS=true GTEST_SRC="your/gtest/install/path" make -C build-files/ports/rapidjson install
```

## Testing
Make sure you have built rapidjson with tests.
1. Copy tests to target
```bash
#replace aarch64le with x86_64 if running on an x86 machine
cd $QNX_TARGET/aarch64le/usr/local/bin/rapidjson_tests
scp -r * <username>@<target-ip>:~/rapidjson
```
2. Run tests on target
```bash
ssh <username>@<target-ip>

#ON TARGET:
cd rapidjson
./unittest
```