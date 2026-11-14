import os

from conan import ConanFile
from conan.tools.cmake import CMakeToolchain, CMake, cmake_layout, CMakeDeps
from conan.tools.files import apply_conandata_patches, export_conandata_patches, get, copy
from conan.errors import ConanInvalidConfiguration

required_conan_version = ">=2"

class ZenohCConan(ConanFile):
    name = "zenoh-c"

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
        version_data = self.conan_data[self.version]
        if "build_requirements" in version_data:
            for requirement, version in version_data["build_requirements"].items():
                if "rust-toolchain" == requirement:
                    self.tool_requires(f"rust-toolchain/{version}", options={"target":self._target_option})
                else:
                    self.tool_requires(f"{requirement}/{version}")
        else:
            raise ConanInvalidConfiguration("No build requirements specified in conandata.yml. Please check your configuration.")

    def export_sources(self):
        export_conandata_patches(self)

    def source(self):
        get(self, **self.conan_data[self.version]["sources"], strip_root=True)
        apply_conandata_patches(self)

    def layout(self):
        cmake_layout(self)

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
        self.run("cargo update --recursive ring pnet_sys pnet_datalink zenoh-util")
        cmake = CMake(self)
        cmake.configure()
        cmake.build()

    def package(self):
        copy(self, "LICENSE", self.source_folder, os.path.join(self.package_folder, "licenses"))
        cmake = CMake(self)
        cmake.install()

    def package_info(self):
        self.cpp_info.libs = ["zenohc"]
        self.cpp_info.builddirs.append(os.path.join("lib", "cmake"))

        if self.settings.os == "Neutrino":
            self.cpp_info.system_libs.append("socket")
