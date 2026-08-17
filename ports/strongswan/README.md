# Strongswan [![Build](https://github.com/qnx-ports/build-files/actions/workflows/strongswan.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/strongswan.yml)

# Compile the port for QNX

**Note**: QNX ports are only supported from a **Linux host** operating system

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.

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

# Now you are in the Docker container

# Source SDP environment
# for 7.1
source ~/qnx710/qnxsdp-env.sh
# for 8.0
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

# clone strongswan
git clone https://github.com/qnx-ports/strongswan.git

# Build strongswan
QNX_PROJECT_ROOT="$(pwd)/strongswan" make -C build-files/ports/strongswan clean 
QNX_PROJECT_ROOT="$(pwd)/strongswan" make -C build-files/ports/strongswan install JLEVEL=4

```

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

# clone strongswan
git clone https://github.com/qnx-ports/strongswan.git

# Build strongswan
QNX_PROJECT_ROOT="$(pwd)/strongswan" make -C build-files/ports/strongswan clean 
QNX_PROJECT_ROOT="$(pwd)/strongswan" make -C build-files/ports/strongswan install JLEVEL=4
```
# Test on Target

```bash

1.Create the file strongswan.conf in /etc/. For example:
swanctl {
}
charon {
}
2.Create the directory /etc/swanctl/ and add to it swanctl.conf. For example:
connections {
    host-host {
        local_addrs = 192.0.2.10
        remote_addrs = 192.0.2.20
        local {
            auth = psk
            id = 192.0.2.10
         }
         remote {
             auth = psk
             id = 192.0.2.20
         }
         children {
             host-host {
                 esp_proposals = aes256-esn-noesn
                 replay_window=512
             }
        }
        version = 2
        proposals = aes128-sha256-modp1024
    }
}
secrets {
    ike-moon {
        id = 192.0.2.10
        secret = 0sFpZAZqEN6Ti9sqt4ZP5EWcqx
    }
}
3.Make sure that the strongSwan binaries are in the proper directories.
4.Make sure that io-sock is running and an appropriate driver is loaded.
5.Use charon to start the strongSwan daemon. For example:
charon --use-syslog &
6.Run swanctl with the following subcommand to load connection configurations:
swanctl --load-conns
7.Run swanctl with the following subcommand to load credentials.
swanctl --load-creds

Repeat the previous steps for Sun, but use the following swanctl.conf:

connections {
    host-host {
        local_addrs = 192.0.2.20
        remote_addrs = 192.0.2.10
        local {
            auth = psk
            id = 192.0.2.20
         }
         remote {
             auth = psk
             id = 192.0.2.10
         }
         children {
             host-host {
                 esp_proposals = aes256-esn-noesn
                 replay_window=512
             }
        }
        version = 2
        proposals = aes128-sha256-modp1024
    }
}
secrets {
    ike-moon {
        id = 192.0.2.10
        secret = 0sFpZAZqEN6Ti9sqt4ZP5EWcqx
    }
}
To establish the connection between Moon and Sun, on Moon, run swanctl with the following subcommand and option:

swanctl --initiate --child host-host
To verify the connection, on either Sun or Moon, run swanctl with the following subcommand:

swanctl --list-sas
Example output from the verification:

host-host: #3, ESTABLISHED, IKEv2, 8f852fd4921c156f_i 68c5ff2775c43666_r*
    local  '192.0.2.10' @ 192.0.2.10[4500]
    remote '192.0.2.20' @ 192.0.2.20[4500]
    AES_CBC-128/HMAC_SHA2_256_128/PRF_HMAC_SHA2_256/MODP_1024
    established 1975s ago, rekeying in 11587s
    host-host: #4, reqid 3, INSTALLED, TUNNEL, ESP:AES_CBC-256/ESN
        installed 429s ago, rekeying in 2955s, expires in 3531s
        in  c161043d,      0 bytes,     0 packets
        out c3db9127,      0 bytes,     0 packets
        local  192.0.2.10/32
        remote 192.0.2.20/32
```