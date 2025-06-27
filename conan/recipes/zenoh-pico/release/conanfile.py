from conan import ConanFile
from conan.tools.cmake import CMakeToolchain, CMake, cmake_layout, CMakeDeps
from conan.tools.files import apply_conandata_patches, export_conandata_patches, get, copy
import os

class upCoreApiRecipe(ConanFile):
    name = "zenoh-pico"

    # Optional metadata
    license = "Apache-2.0"
    author = "ZettaScale Zenoh Team, <zenoh@zettascale.tech>"
    url = "https://github.com/eclipse-zenoh/zenoh-pico"
    description = "Zero Overhead Pub/sub, Store/Query and Compute. Native C library for constrained devices."
    topics = ("automotive", "iot", "zenoh", "messaging")

    # Binary configuration
    settings = "os", "compiler", "build_type", "arch"
    options = {
        "shared": [True, False],
        "fPIC": [True, False],
    }

    default_options = {
        "shared": False,
        "fPIC": True,
    }

    def source(self):
        get(self, **self.conan_data[self.version]["sources"], strip_root=True)

    def export_sources(self):
        export_conandata_patches(self)

    def config_options(self):
        if self.settings.os == "Windows":
            del self.options.fPIC

    def layout(self):
        cmake_layout(self)

    def generate(self):
        deps = CMakeDeps(self)
        deps.generate()
        tc = CMakeToolchain(self)
        tc.cache_variables["BUILD_EXAMPLES"] = False
        tc.cache_variables["BUILD_TESTING"] = False
        tc.generate()

    def build(self):
        apply_conandata_patches(self)
        cmake = CMake(self)
        cmake.configure()
        cmake.build()

    def package(self):
        copy(self, "LICENSE", self.source_folder, os.path.join(self.package_folder, "licenses"))
        cmake = CMake(self)
        cmake.install()

    def package_info(self):
        self.cpp_info.libs = ["zenohpico"]
        self.cpp_info.builddirs.append(os.path.join("lib", "cmake"))

        if self.settings.os == "Neutrino":
            self.cpp_info.system_libs.append("socket")
