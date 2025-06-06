import os

from conan import ConanFile
from conan.tools.cmake import CMakeToolchain, cmake_layout
from conan.tools.scm import Version

class TestPackageConan(ConanFile):
    name = "protobuf_unittest"
    settings = "os", "compiler", "build_type", "arch"

    def layout(self):
        project_root = os.environ["QNX_PROJECT_ROOT"]
        #cmake_suffix = "."
        #if Version(self.version) < "3.21.0":
        #    cmake_suffix = "cmake"
        cmake_layout(self, src_folder=os.path.join(project_root, "."), build_folder=os.path.join(project_root,"build_tests"))

#    def requirements(self):
#        self.requires("zlib/[>=1.2.11 <2]")
#        if Version(self.version) <= "3.21.12":
#            self.requires("gtest/1.10.0")

    def build_requirements(self):
        self.tool_requires(f"protobuf/{self.version}")

    def generate(self):
        tc = CMakeToolchain(self)
        tc.variables["protobuf_BUILD_TESTS"] = True
        tc.variables["protobuf_BUILD_PROTOC_BINARIES"] = False
        tc.variables["protobuf_BUILD_LIBUPB"] = False
        tc.variables["protobuf_USE_EXTERNAL_GTEST"] = False
        tc.variables["protobuf_WITH_ZLIB"] = False
        tc.variables["protobuf_ABSOLUTE_TEST_PLUGIN_PATH"] = False
        if Version(self.version) <= "3.15.0":
            tc.cache_variables["CMAKE_POLICY_DEFAULT_CMP0042"] = "NEW"
            tc.cache_variables["CMAKE_POLICY_VERSION_MINIMUM"] = "3.5" # CMake 4 support
        if self.settings.os == "Neutrino":
            tc.cache_variables["CMAKE_EXE_LINKER_FLAGS_INIT"] = "-lregex -lsocket"
        tc.generate()
"""         tc.variables["protobuf_BUILD_TESTS"] = True
        #tc.variables["protobuf_BUILD_CONFORMANCE"] = True
        #tc.variables["CMAKE_CXX_STANDARD"] = "14"
        #tc.variables["protobuf_USE_EXTERNAL_GTEST"] = False
        tc.variables["protobuf_WITH_ZLIB"] = False
        tc.variables["protobuf_BUILD_PROTOC_BINARIES"] = False
        tc.variables["protobuf_ABSOLUTE_TEST_PLUGIN_PATH"] = False
        tc.variables["protobuf_BUILD_LIBUPB"] = False
        if Version(self.version) <= "3.15.0":
            tc.cache_variables["CMAKE_POLICY_DEFAULT_CMP0042"] = "NEW"
            tc.cache_variables["CMAKE_POLICY_VERSION_MINIMUM"] = "3.5" # CMake 4 support
        if self.settings.os == "Neutrino":
            tc.cache_variables["CMAKE_EXE_LINKER_FLAGS_INIT"] = "-lregex -lsocket"

        tc.generate()
"""
