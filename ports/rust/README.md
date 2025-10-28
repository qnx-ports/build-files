# Rust

Currently these version combos are tested:
+ 1.82.0 on QNX 7.1.0
+ 1.90.0 on QNX 8.0.3 and 7.1.0

## Compile Rust toolchain for QNX 7.1/8.0 on a Linux host
New rust compiler officially supports QNX 7.1/8.0 as a target, but since it's on Tier 3, we will need to compile the compiler ourselves.

You'll first need `rustup` installed. Check https://rustup.rs for the latest instruction. When the setup script asks just use the default target for your platform.

```bash
# interactive installation of rustup
curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh
# or install it with all default settings
curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh -s -- -y
# source cargo ENV
source ~/.cargo/env
# source QNX SDP
source ~/qnx800/qnxsdp-env.sh
```

Then we do the actual compiling. Compelling!

```bash
# Setup working area
mkdir -p ~/workspace && cd ~/workspace
# Clone qnx-post build files
git clone https://github.com/qnx-ports/build-files.git
# Clone the rust 1.90.0 for QNX8.0/7.1 - with some fixes from qnx-ports/rust
git clone --branch=qnx-1.90.0 https://github.com/qnx-ports/rust.git
# Or rust 1.82.0 for QNX7.1 -- IMPORTANT: QNX.8.0 is not supported
git clone --branch=1.82.0 https://github.com/rust-lang/rust.git
cd rust
# Add QNX-specific settings to it
# For QNX 8.0
cat ~/workspace/build-files/ports/rust/qnx800-config.toml > config.toml
# For QNX 7.1
cat ~/workspace/build-files/ports/rust/qnx710-config.toml > config.toml
# Build and instal into ${PWD}/stage
./x.py install
# All good! Now we add the new compiler to rustup, so we can use it
rustup toolchain link qnx-rust stage/host/linux/x86_64/usr/
```

After everything's done, we can compile a rust project by doing this:

```bash
cd rust_project/
# Activate qnx toolchain
rustup override set qnx-rust
#
# <qnx-targets>: x86_64-pc-nto-qnx710, aarch64-unknown-nto-qnx710, x86_64-pc-nto-qnx800, aarch64-unknown-nto-qnx800
#
# For compiling debug-profile program (so you can use debuggers)
cargo build --target <qnx-targets>
# For compiling release-profile programs
cargo build --target <qnx-targets> --release
```

Just note that programs compiled under debug profiles can be quite large due to all the debug symbols and lack of optimization.

## Testing the Rust compiler

The main test harness for testing the compiler itself is a tool called compiletest.

It is recomended to use **UI tests** colletion

### Build and setup rust test runner

```bash
# Activate freshly built toolchain with qnx targets
rustup override set qnx-rust
# Build remote test server
./x build remote-test-server --target x86_64-pc-nto-qnx800
export QNX_TARGET_HOST=<target-ip-address-or-hostname>
# copy only remote test server to the target
scp ./build/host/stage1-tools/x86_64-pc-nto-qnx800/release/remote-test-server qnxuser@$QNX_TARGET_HOST:/data/home/qnxuser/
# NOTE: some tests cases need root permition
ssh root@$TARGET_HOST
# Start remote test server on the target
./remote-test-server -v --bind 0.0.0.0:12345
```

### Build and run UI tests from the Host

QNX8.0 x86_64
```bash
export TEST_DEVICE_ADDR=$QNX_TARGET_HOST":12345"
./x test tests/ui --target x86_64-pc-nto-qnx800
...
Testing stage1 compiletest suite=ui mode=ui (x86_64-unknown-linux-gnu -> x86_64-pc-nto-qnx800)
...
running 19535 tests
test result: ok. 19247 passed; 0 failed; 288 ignored; 0 measured; 0 filtered out; finished in 287.34s
```

QNX8.0 aarch64
```bash
export TEST_DEVICE_ADDR=$QNX_TARGET_HOST":12345"
./x test tests/ui --target aarch64-unknown-nto-qnx800
...
Testing stage1 compiletest suite=ui mode=ui (x86_64-unknown-linux-gnu -> aarch64-unknown-nto-qnx800)
...
running 19535 tests
test result: ok. 19158 passed; 0 failed; 377 ignored; 0 measured; 0 filtered out; finished in 332.21s
```

QNX7.1 x86_64
```bash
export TEST_DEVICE_ADDR=$QNX_TARGET_HOST":12345"
./x test tests/ui --target x86_64-pc-nto-qnx710
...
Testing stage1 compiletest suite=ui mode=ui (x86_64-unknown-linux-gnu -> x86_64-pc-nto-qnx710)
...
running 19535 tests
test result: ok. 19247 passed; 0 failed; 288 ignored; 0 measured; 0 filtered out; finished in 290.45s
```

QNX7.1 aarch64
```bash
export TEST_DEVICE_ADDR=$QNX_TARGET_HOST":12345"
./x test tests/ui --target aarch64-unknown-nto-qnx710
...
Testing stage1 compiletest suite=ui mode=ui (x86_64-unknown-linux-gnu -> aarch64-unknown-nto-qnx710)
...
running 19535 tests
test result: FAILED. 19157 passed; 1 failed; 377 ignored; 0 measured; 0 filtered out; finished in 301.42s
```
