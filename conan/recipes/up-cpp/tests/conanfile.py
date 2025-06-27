import os

from conan import ConanFile
from conan.tools.cmake import CMakeToolchain, cmake_layout, CMakeDeps
from conan.tools.scm import Version

class TestPackageConan(ConanFile):
    name = "up-cpp_unittest"

    # Optional metadata
    license = "Apache-2.0"
    author = "Contributors to the Eclipse Foundation <uprotocol-dev@eclipse.org>"
    url = "https://github.com/eclipse-uprotocol/up-cpp"
    description = "This library provides a C++ uProtocol API for the development of uEntities"
    topics = ("automotive", "iot", "uprotocol", "messaging")

    # Binary configuration
    settings = "os", "compiler", "build_type", "arch"
    options = {
        "shared": [True, False],
    }
    default_options = {
        "shared": False,
    }

    def requirements(self):
        self.requires("protobuf/3.21.12")
        self.requires("spdlog/1.13.0")
        self.requires("up-core-api/[~1.6, include_prerelease]")
        self.test_requires("gtest/1.14.0")

    def layout(self):
        project_root = os.environ["QNX_PROJECT_ROOT"]
        cmake_layout(self, src_folder=os.path.join(project_root,"."), build_folder=os.path.join(project_root,"build_tests"))

    def generate(self):
        deps = CMakeDeps(self)
        deps.generate()
        tc = CMakeToolchain(self)
        #all warnings have to be fixed
        tc.cache_variables["CMAKE_CXX_FLAGS_INIT"] = "-Wno-error=unused-but-set-variable -Wno-error=pedantic -Wno-error=conversion"
        tc.generate()
