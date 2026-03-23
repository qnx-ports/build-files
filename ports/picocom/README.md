# picocom
Currently only QNX8 has been tested.

## Compile picocom for QNX 8.0 on a Linux host
```bash
# Clone the repository and checkout the tested tag
git clone https://github.com/npat-efault/picocom
git checkout 3.1
# Apply patch
patch -p1 < 0001-qnx-compat.patch
# Build project with qcc
CC=qcc make
# And picocom binary is available under the root of the project
file picocom
# binary should be linked to ldqnx
```
