from conan import ConanFile
from conan.tools.cmake import CMakeToolchain, CMake, cmake_layout, CMakeDeps
from conan.tools.files import apply_conandata_patches, export_conandata_patches, get, copy
from conan.errors import ConanInvalidConfiguration
import os

class ZenohCppRecipe(ConanFile):
    name = "zenoh-cpp"

    # Optional metadata
    license = "Apache-2.0"
    author = "ZettaScale Zenoh Team, <zenoh@zettascale.tech>"
    url = "https://github.com/eclipse-zenoh/zenoh-cpp"
    description = "The Zenoh C++ API are headers only C++ bindings for [zenoh-c] and [zenoh-pico] libraries."
    topics = ("automotive", "iot", "zenoh", "messaging")

    # Binary configuration
    settings = "os", "compiler", "build_type", "arch"
    backend = ["zenoh-c", "zenoh-pico"]
    options = {
        "shared": [True, False],
        "backend": backend,
    }

    default_options = {
        "shared": False,
        "backend": backend[0], #"zenoh-c"
    }

    def validate(self):
        if "1.0.0-rc5" == self.version and "zenoh-c" == self.options.backend:
            raise ConanInvalidConfiguration(f"Backend {self.options.backend} is not supported for version {self.version}.")
        if "zenoh-c" == self.options.backend and "Neutrino" == self.settings.os:
            raise ConanInvalidConfiguration(f"Backend {self.options.backend} is not supported for os {self.settings.os}.")

    def requirements(self):
        version_data = self.conan_data[self.version]
        if "requirements" in version_data:
            for requirement, version in version_data["requirements"].items():
                if requirement in self.backend and requirement != self.options.backend:
                    # skip requirement for unsuitable backend
                    continue
                self.requires(f"{requirement}/{version}")
        else:
            self.output.warning("No requirements specified in conandata.yml. Please check your configuration.")

    def source(self):
        get(self, **self.conan_data[self.version]["sources"], strip_root=True)

    def export_sources(self):
        export_conandata_patches(self)

    def layout(self):
        cmake_layout(self)

    def generate(self):
        deps = CMakeDeps(self)
        deps.generate()
        tc = CMakeToolchain(self)
        if "zenoh-c" == self.options.backend:
            tc.cache_variables["ZENOHCXX_ZENOHC"] = True
            tc.cache_variables["ZENOHCXX_ZENOHPICO"] = False
        elif "zenoh-pico" == self.options.backend:
            tc.cache_variables["ZENOHCXX_ZENOHC"] = False
            tc.cache_variables["ZENOHCXX_ZENOHPICO"] = True
        else:
            self.output.warning("No proper backend defined. Please check your backend option.")
            tc.cache_variables["ZENOHCXX_ZENOHC"] = False
            tc.cache_variables["ZENOHCXX_ZENOHPICO"] = False
        tc.cache_variables["ZENOHCXX_EXAMPLES_PROTOBUF"] = False
        tc.cache_variables["ZENOHCXX_ENABLE_TESTS"] = False
        tc.cache_variables["ZENOHCXX_ENABLE_EXAMPLES"] = False
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
        self.cpp_info.libs = ["zenohcxx"]
        self.cpp_info.builddirs.append(os.path.join("lib", "cmake"))
