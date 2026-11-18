# libevent [![Build](https://github.com/qnx-ports/build-files/actions/workflows/libevent.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/libevent.yml)

**NOTE**: QNX ports are only supported from a Linux host operating system

Use `$(nproc)` instead of `4` after `JLEVEL=` if you want to use the maximum number of cores to build this project.

# Git tags:
- qnx-2.1.12_p0
- qnx-2.1.13_p0


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

# Clone libevent
# replace <Git tag>, with one of the supported tags
cd ~/qnx_workspace
git clone [-b <Git tag>] https://github.com/qnx-ports/libevent.git

# Build libevent
make -C build-files/ports/libevent install JLEVEL=4
```

# Compile the port for QNX on Ubuntu host
```bash
# Create a workspace
mkdir -p ~/qnx_workspace && cd qnx_workspace
# Clone the repos
git clone https://github.com/qnx-ports/build-files.git
# replace <Git tag>, with one of the supported tags
git clone [-b <Git tag>] https://github.com/qnx-ports/libevent.git

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Build libevent
make -C build-files/ports/libevent install JLEVEL=4
```

# Signals and interrupted system calls on QNX

QNX does not support `SA_RESTART`. A blocking system call interrupted by a signal handler therefore fails with `errno == EINTR` and is never restarted automatically.  
libevent handles this inside its own event loop, buffer and listener code.  
Applications using libevent should follow these points:

1. Do the I/O on libevent's descriptors through `bufferevent` and `evbuffer`, not with raw `read`/`write` calls. They already treat `EINTR` as "try again".
2. Retry your own blocking calls on `EINTR` (`read`, `write`, `accept`, `connect`, `sem_wait`, and so on), for example `do { n = read(fd, buf, len); } while (n < 0 && errno == EINTR);`.
3. For signals that should drive the event loop, use `evsignal_new()` / `event_new()` with the signal number instead of your own handlers. The callback then runs from the event loop and not in signal-handler context.
4. Do not rely on `SA_RESTART` in your own `sigaction()` code. If shared code sets it, guard it with `#ifdef SA_RESTART`, and still retry on `EINTR`.
5. Test the interrupted paths of your application, that is, a signal arriving while it is blocked in a system call or in the event loop.
