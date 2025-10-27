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
# Activatge qnx toolchain
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

## crates that builds without error
We call libraries as crates in Rust.

+ tokio (>=1.4)
+ mio (>=1.0)
+ rusqlite, alongside its C-binding crate (libsqlite3-sys)
  - note that if you're bundling the sqlite binary, you'll need to specify `CC` and `TARGET` envvars before invoking cargo build
