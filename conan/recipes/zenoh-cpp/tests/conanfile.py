import os

from conan import ConanFile
from conan.tools.cmake import CMakeToolchain, cmake_layout, CMakeDeps
from conan.tools.scm import Version


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

    def layout(self):
        project_root = os.environ["QNX_PROJECT_ROOT"]
        cmake_layout(self, src_folder=os.path.join(project_root,"."), build_folder=os.path.join(project_root,"build_tests"))

    def requirements(self):
        self.requires(f"zenoh-pico/{self.version}")

    def generate(self):
        deps = CMakeDeps(self)
        deps.generate()
        tc = CMakeToolchain(self)

        if self.version == "1.0.0-rc5":
            tc.cache_variables["CMAKE_CXX_FLAGS_INIT"] = "-Wno-error=pedantic"
            if self.settings.os == "Linux":
                tc.cache_variables["CMAKE_EXE_LINKER_FLAGS_INIT"] = "-pthread"

        tc.cache_variables["ZENOHCXX_ZENOHC"] = False
        tc.cache_variables["ZENOHCXX_ZENOHPICO"] = True

        if self.settings.os == "Neutrino":
            tc.cache_variables["CMAKE_EXE_LINKER_FLAGS_INIT"] = "-lsocket"
            #for share object option "shared=true"
            tc.cache_variables["CMAKE_SHARED_LINKER_FLAGS_INIT"] = "-lsocket"
        tc.generate()
