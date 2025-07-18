import os

from conan import ConanFile
from conan.tools.cmake import CMakeToolchain, cmake_layout, CMakeDeps
from conan.tools.scm import Version


class TestPackageConan(ConanFile):
    name = "up-transport-zenoh-cpp_unittest"

    # Optional metadata
    license = "Apache-2.0"
    author = "Contributors to the Eclipse Foundation <uprotocol-dev@eclipse.org>"
    url = "https://github.com/eclipse-uprotocol/up-transport-zenoh-cpp"
    description = "This library provides a Zenoh-based uProtocol transport for C++ uEntities"
    topics = ("automotive", "iot", "uprotocol", "messaging")

    # Binary configuration
    settings = "os", "compiler", "build_type", "arch"
    options = {
            "shared": [True, False],
            "pico": [True, False],
            }

    default_options = {
            "shared": False,
            "pico": False,
            }

    def layout(self):
        project_root = os.environ["QNX_PROJECT_ROOT"]
        cmake_layout(self, src_folder=os.path.join(project_root,"."), build_folder=os.path.join(project_root,"build_tests"))

    def requirements(self):
        self.requires("zenoh-pico/[~1.0, include_prerelease]")
        self.requires("zenoh-cpp/[~1.0, include_prerelease]")
        self.requires("up-core-api/[~1.6, include_prerelease]")
        self.requires("up-cpp/[^1.0, include_prerelease]")
        self.requires("spdlog/1.13.0")
        self.requires("protobuf/3.21.12")
        self.test_requires("gtest/1.14.0")

    def generate(self):
        deps = CMakeDeps(self)
        deps.generate()
        tc = CMakeToolchain(self)

        if self.settings.os == "Neutrino":
            v_zenoh_pico = Version(self.dependencies["zenoh-pico"].ref.version)
            if v_zenoh_pico <= "1.0.0-rc5":
                # workaround since _Bool is not defined for C++ in qnx.
                # This maybe incorrect use in zenoh-pico/1.0.0-rc5 and older
                # fixed in newer version of zenoh-pico
                tc.preprocessor_definitions["_Bool"] = "bool"

        tc.generate()
