import os

from conan import ConanFile
from conan.tools.cmake import CMakeToolchain, CMake, cmake_layout, CMakeDeps
from conan.errors import ConanInvalidConfiguration

required_conan_version = ">=2"

class TestPackageConan(ConanFile):
    name = "zenoh-c_unittest"

    # Optional metadata
    license = "Apache-2.0"
    author = "ZettaScale Zenoh Team, <zenoh@zettascale.tech>"
    url = "https://github.com/eclipse-zenoh/zenoh-c"
    description = "The C bindings for Zenoh"
    topics = ("automotive", "iot", "zenoh", "messaging")

    # Binary configuration
    settings = "os", "compiler", "build_type", "arch"

    options = {
        "shared": [True, False],
    }

    default_options = {
        "shared": False,
    }

    @property
    def _qnx_target_arch_part(self):
        if "armv8" == self.settings.arch:
            return "aarch64-unknown-nto-qnx"
        elif "x86_64" == self.settings.arch:
            return "x86_64-pc-nto-qnx"
        else:
            raise ConanInvalidConfiguration(f"Unsupported QNX arch:{self.settings.arch}")

    @property
    def _target_option(self):
        target = "x86_64-unknown-linux-gnu"
        if "Neutrino" == self.settings.os:
            qnx_target = self._qnx_target_arch_part
            if "7.1" == self.settings.os.version:
                target = qnx_target + "710"
            elif "8.0" == self.settings.os.version:
                target = qnx_target + "800"
            else:
                raise ConanInvalidConfiguration(f"Unsupported QNX version:{self.settings.os.version}")
        return target

    def build_requirements(self):
        self.tool_requires("rust-toolchain/1.90.0", options={"target":self._target_option})
        self.tool_requires("rustup/1.28.2")

    def layout(self):
        project_root = os.environ["QNX_PROJECT_ROOT"]
        cmake_layout(self, src_folder=os.path.join(project_root,"."), build_folder=os.path.join(project_root,"build_tests"))

    def generate(self):
        toolchain_name = self.conf.get("user.rust.toolchain:name")
        deps = CMakeDeps(self)
        deps.generate()
        tc = CMakeToolchain(self)
        tc.cache_variables["ZENOHC_CARGO_CHANNEL"] = f"+{toolchain_name}"
        tc.cache_variables["ZENOHC_CUSTOM_TARGET"] = self._target_option
        tc.generate()

    def build(self):
        #self.run("cargo update --recursive ring pnet")
        ##self.run("cargo update --recursive ring pnet_sys pnet_datalink zenoh-util quinn-udp nix@0.29.0 socket2 zenoh-link zenoh-link-udp")
        #self.run("cargo update --recursive")
        #self.run("cargo update ring pnet_sys pnet_datalink zenoh-util quinn-udp nix@0.29.0 socket2")
        ###self.run("cargo update ring pnet_sys pnet_datalink quinn-udp nix@0.29.0 zenoh zenoh-ext zenoh-runtime zenoh-util")
        #self.run("cargo tree -i socket2")
        cmake = CMake(self)
        cmake.configure()
        cmake.build(target="tests")
