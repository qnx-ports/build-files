import os

from conan import ConanFile
from conan.tools.cmake import CMakeToolchain, cmake_layout
from conan.tools.build import cross_building

class TestPackageConan(ConanFile):
    name = "cmake_unittest"
    settings = "os", "compiler", "build_type", "arch"

    def layout(self):
        project_root = os.environ["QNX_PROJECT_ROOT"]
        cmake_layout(self, src_folder=os.path.join(project_root,"."), build_folder=os.path.join(project_root,"build_tests"))

    def generate(self):
        tc = CMakeToolchain(self)
        tc.variables["BUILD_TESTING"] = True
        if not self.settings.compiler.cppstd:
            tc.variables["CMAKE_CXX_STANDARD"] = 11
        tc.variables["CMAKE_BOOTSTRAP"] = False
        tc.variables["CMAKE_USE_OPENSSL"] = False
        if self.settings.os == "Neutrino":
            tc.cache_variables["CMake_HAVE_CXX_MAKE_UNIQUE"] = True
            tc.cache_variables["CMAKE_SYSTEM_NAME"] = "QNX"
            tc.cache_variables["CMAKE_SYSTEM_VERSION"] = f"{self.settings.os.version}"
            if   self.settings.arch == "armv8": #aarch64le
                tc.cache_variables["CMAKE_SYSTEM_PROCESSOR"] = "aarch64le"
            elif self.settings.arch == "x86_64": #x86_64
                tc.cache_variables["CMAKE_SYSTEM_PROCESSOR"] = "x86_64"
        if cross_building(self):
            tc.variables["HAVE_POLL_FINE_EXITCODE"] = ''
            tc.variables["HAVE_POLL_FINE_EXITCODE__TRYRUN_OUTPUT"] = ''
        tc.generate()
