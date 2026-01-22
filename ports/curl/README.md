# [![curl logo](https://curl.se/logo/curl-logo.svg)](https://curl.se/)

This Page serves as a redirect hub for the curl library ported to QNX. Rather than duplicating documentation and build configurations, we maintain pointers to authoritative sources managed by the QNX open-source community and the official curl project.

curl is a command-line tool for transferring data specified with URL syntax.
Learn how to use curl by reading [the
manpage](https://curl.se/docs/manpage.html) or [everything
curl](https://everything.curl.dev/).

libcurl is the library curl is using to do its job. It is readily available to
be used by your software. Read [the libcurl
manpage](https://curl.se/libcurl/c/libcurl.html) to learn how.

## Key Resources

### Official Maintenance & Build Configuration
**Repository:** [github.com/curl/curl-for-qnx](https://github.com/curl/curl-for-qnx)

This is the official upstream repository maintained by the curl project team and QNX partners. It contains:
- Build scripts and compilation configurations for QNX 7.0, 7.1, and 8.0
- Cross-architecture support (x86_64, aarch64, armle-v7)
- CI/CD workflows via GitHub Actions
- Latest patches and QNX-specific modifications

**Start here for:**
- Building from source
- Understanding the build pipeline
- Contributing fixes or improvements
- Accessing compilation documentation (README.md)

### Released Binaries & Packages
**Location:** [curl.se/qnx/](https://curl.se/qnx/)

Official pre-compiled curl packages for QNX are available at the curl project's official download site. These include:
- Binary releases for QNX 7.0, 7.1, and 8.0
- Pre-built curl tool and libcurl library
- Headers and development files
- Installation instructions and release notes

**Use this for:**
- Downloading pre-compiled, ready-to-deploy packages
- Getting stable, tested releases
- Accessing official curl documentation

## Quick Start

### Option 1: Download Pre-Built Packages (Recommended)
```bash
# Visit curl.se/qnx/ and download the package for your QNX version
# Extract and install
tar xzf curl-X.Y.Z-qnxsdpN.tar.gz
```

### Option 2: Build from Source
1. Clone the upstream repository:
   ```bash
   git clone https://github.com/curl/curl-for-qnx.git
   cd curl-for-qnx
   ```

2. Follow the build instructions in [README.md](https://github.com/curl/curl-for-qnx/blob/master/README.md):
   - Set up QNX SDK environments
   - Configure build paths
   - Run the build scripts (mkpkg-*.sh, mkrelease.sh)

## Documentation

**Curl Documentation:** 
  - [curl.se/docs/](https://curl.se/docs/)
  - [curl Tool Manual](https://curl.se/docs/manpage.html)
  - [libcurl C API Reference](https://curl.se/libcurl/c/)

## Related Resources

- [Official curl Project](https://curl.se/)
- [QNX Operating System](https://www.qnx.com/)
- [QNX Ports Organization](https://github.com/qnx-ports)
- [QNX Everywhere Documentation](https://www.qnx.com/developers/docs/qnxeverywhere/)
