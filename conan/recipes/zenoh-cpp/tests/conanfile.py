import os

from conan import ConanFile
from conan.tools.cmake import CMakeToolchain, cmake_layout, CMakeDeps

class TestPackageConan(ConanFile):
    name = "zenoh-cpp_unittest"

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

    def layout(self):
        project_root = os.environ["QNX_PROJECT_ROOT"]
        cmake_layout(self, src_folder=os.path.join(project_root,"."), build_folder=os.path.join(project_root,"build_tests"))

    def requirements(self):
        if "zenoh-c" == self.options.backend:
            self.requires(f"zenoh-c/{self.version}")
        elif "zenoh-pico" == self.options.backend:
            self.requires(f"zenoh-pico/{self.version}")
        else:
            self.output.warning("No proper backend defined. Please check your backend option.")

    def generate(self):
        deps = CMakeDeps(self)
        deps.generate()
        tc = CMakeToolchain(self)

        if self.version == "1.0.0-rc5":
            tc.cache_variables["CMAKE_CXX_FLAGS_INIT"] = "-Wno-error=pedantic"
            if self.settings.os == "Linux":
                tc.cache_variables["CMAKE_EXE_LINKER_FLAGS_INIT"] = "-pthread"
            if self.settings.os == "Neutrino":
                # workaround since _Bool is not defined for C++ in qnx.
                # This maybe incorrect use in zenoh-pico/1.0.0-rc5
                # fixed in newer version of zenoh-pico
                tc.preprocessor_definitions["_Bool"] = "bool"

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

        if self.settings.os == "Neutrino":
            tc.cache_variables["CMAKE_EXE_LINKER_FLAGS_INIT"] = "-lsocket"
            #for share object option "shared=true"
            tc.cache_variables["CMAKE_SHARED_LINKER_FLAGS_INIT"] = "-lsocket"
        tc.generate()
