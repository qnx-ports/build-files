import os

from conan import ConanFile
from conan.tools.cmake import CMakeToolchain, cmake_layout
from conan.tools.scm import Version

class TestPackageConan(ConanFile):
    name = "gtest_unittest"
    settings = "os", "compiler", "build_type", "arch"

    def layout(self):
        project_root = os.environ["QNX_PROJECT_ROOT"]
        cmake_layout(self, src_folder=os.path.join(project_root,"."), build_folder=os.path.join(project_root,"build_tests"))

    def generate(self):
        tc = CMakeToolchain(self)
        tc.variables["gtest_build_tests"] = True
        tc.variables["gtest_build_samples"] = True
        tc.variables["gmock_build_tests"] = True
        if Version(self.version) < "1.12.0":
            tc.cache_variables["CMAKE_POLICY_DEFAULT_CMP0042"] = "NEW"
            tc.cache_variables["CMAKE_POLICY_VERSION_MINIMUM"] = "3.5" # CMake 4 support

        if self.settings.os == "Neutrino":
            tc.cache_variables["CMAKE_EXE_LINKER_FLAGS_INIT"] = "-lregex"
            #for share object option "shared=true"
            tc.cache_variables["CMAKE_SHARED_LINKER_FLAGS_INIT"] = "-lregex"
        tc.generate()
