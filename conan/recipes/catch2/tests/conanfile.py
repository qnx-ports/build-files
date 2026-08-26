from conan import ConanFile
from conan.tools.cmake import CMakeToolchain, cmake_layout
from conan.tools.scm import Version

import os

required_conan_version = ">=2.0"


class Catch2Test(ConanFile):
    name = "catch2_test"
    settings = "os", "arch", "compiler", "build_type"

    def build_requirements(self):
        self.tool_requires("cmake/[>=3.16]")

    def layout(self):
        project_root = os.environ["QNX_PROJECT_ROOT"]
        cmake_layout(self, src_folder=os.path.join(project_root,"."), build_folder=os.path.join(project_root,"build_tests"))

    def generate(self):
        tc = CMakeToolchain(self)
        tc.variables["BUILD_TESTING"] = True
        #handle version specific settings
        if Version(self.version) < "3.0.0":
            # Catch2 2.y.z
            tc.cache_variables["CMAKE_POLICY_VERSION_MINIMUM"] = "3.5" # CMake 4 support
            tc.cache_variables["CATCH_BUILD_TESTING"] = True
            tc.cache_variables["CATCH_BUILD_EXAMPLES"] = True
            tc.cache_variables["CATCH_BUILD_EXTRA_TESTS"] = True
        else:
            # Catch2 3.y.z
            # basic-tests
            # Enables development build with basic tests that are cheap to build and run
            tc.cache_variables["CATCH_DEVELOPMENT_BUILD"] = True
            # all-tests
            # Enables development build with examples and ALL tests
            tc.cache_variables["CATCH_BUILD_EXAMPLES"] = True
            tc.cache_variables["CATCH_BUILD_EXTRA_TESTS"] = True
            tc.cache_variables["CATCH_BUILD_SURROGATES"] = True
            tc.cache_variables["CATCH_ENABLE_CONFIGURE_TESTS"] = True
            tc.cache_variables["CATCH_ENABLE_CMAKE_HELPER_TESTS"] = True
        if "Neutrino" == self.settings.os:
            tc.extra_cxxflags = ["-Wno-error=null-dereference", "-Wno-error=deprecated-declarations", "-Wno-error=maybe-uninitialized"]
        tc.generate()
