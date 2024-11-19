Currently these version combos are tested:
+ 1.82.0 on QNX 7.1.0

## Compile Rust toolchain for QNX 7.1 on a Linux host
Currently rust compiler officially supports QNX 7.1 as a target, but since it's on Tier 3, we will need to compile to compiler ourselves.

You'll first need `rustup` installed. Check https://rustup.rs for the latest instruction. When the setup script asks just use the default target for your platform.

Then we do the actual compiling. Compelling!

```bash
# Assuming your build-files repo is at ~/workspace/build-files
cd ~/workspace
# Clone the rust project
git clone https://github.com/rust-lang/rust.git
cd rust/
# Use the latest supported version tag
git checkout 1.82.0
# Setup build environment
./x setup compiler
# Add QNX-specific settings to it
cat ~/workspace/build-files/ports/rust/qnx710-config.toml >> config.toml
# Actually building the compiler. This will take quite a while
./x build --target aarch64-unknown-nto-qnx710
# All good! Now we add the new compiler to rustup, so we can use it
rustup toolchain link qnx710-stage1 build/host/stage1
```

After everything's done, we can compile a rust project by doing this:

```bash
cd rust_project/
# For compiling debug-profile program (so you can use debuggers)
cargo +qnx710-stage1 build --target aarch64-unknown-nto-qnx710
# For compiling release-profile programs
cargo +qnx710-stage1 build --target aarch64-unknown-nto-qnx710 --release
```

Just note that programs compiled under debug profiles can be quite large due to all the debug symbols and lack of optimization.

## Tested crates
We call libraries as crates in Rust.

+ tokio (>=1.4)
+ mio (>=1.0)
+ rusqlite, alongside its C-binding crate (libsqlite3-sys)
  - note that if you're bundling the sqlite binary, you'll need to specify `CC` and `TARGET` envvars before invoking cargo build
