from conan import ConanFile
from conan.tools.files import chdir, copy, rmdir, get, save, load
from conan.tools.cmake import CMake, CMakeToolchain, cmake_layout, CMakeDeps
from conan.tools.gnu import Autotools, AutotoolsToolchain, AutotoolsDeps
from conan.tools.layout import basic_layout
from conan.tools.build import build_jobs, cross_building, check_min_cppstd
from conan.tools.scm import Version
from conan.tools.microsoft import is_msvc
from conan.errors import ConanInvalidConfiguration

import os
import json

required_conan_version = ">=2.1"

class CMakeConan(ConanFile):
    name = "cmake"
    package_type = "application"
    description = "Conan installer for CMake"
    topics = ("cmake", "build", "installer")
    url = "https://github.com/conan-io/conan-center-index"
    homepage = "https://github.com/Kitware/CMake"
    license = "BSD-3-Clause"
    settings = "os", "arch", "compiler", "build_type"

    def validate_build(self):
        minimal_cpp_standard = "11"
        if self.settings.get_safe("compiler.cppstd"):
            check_min_cppstd(self, minimal_cpp_standard)

        minimal_version = {
            "gcc": "4.8",
            "clang": "3.3",
            "apple-clang": "9",
            "Visual Studio": "14",
            "msvc": "190",
        }

        compiler = str(self.settings.compiler)
        if compiler not in minimal_version:
            self.output.warning(
                f"{self.name} recipe lacks information about the {compiler} compiler standard version support")
            self.output.warning(
                f"{self.name} requires a compiler that supports at least C++{minimal_cpp_standard}")
            return

        version = Version(self.settings.compiler.version)
        if version < minimal_version[compiler]:
            raise ConanInvalidConfiguration(
                f"{self.name} requires a compiler that supports at least C++{minimal_cpp_standard}")

    def layout(self):
        cmake_layout(self, src_folder="src")

    def source(self):
        get(self, **self.conan_data["sources"][self.version],
            destination=self.source_folder, strip_root=True)
        rmdir(self, os.path.join(self.source_folder, "Tests", "RunCMake", "find_package"))

    def generate(self):
        tc = CMakeToolchain(self)
        tc.variables["BUILD_TESTING"] = False
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

    def build(self):
        cmake = CMake(self)
        cmake.configure()
        cmake.build()

    def package(self):
        copy(self, "Copyright.txt", self.source_folder, os.path.join(self.package_folder, "licenses"), keep_path=False)
        cmake = CMake(self)
        cmake.install()
        rmdir(self, os.path.join(self.package_folder, "doc"))

    def package_id(self):
        del self.info.settings.compiler

    def package_info(self):
        self.cpp_info.includedirs = []
        self.cpp_info.libdirs = []
