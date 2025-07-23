import os

from conan import ConanFile
from conan.tools.files import get, download, copy, chmod
from conan.errors import ConanInvalidConfiguration


required_conan_version = ">=2"

class ZenohRouterConan(ConanFile):
    name = "zenoh-router"

    # Optional metadata
    license = "Apache-2.0"
    author = "ZettaScale Zenoh Team, <zenoh@zettascale.tech>"
    url = "https://github.com/eclipse-zenoh/zenoh-cpp"
    package_type = "application"
    description = "Zenoh router"
    topics = ("automotive", "iot", "zenoh", "messaging")

    # Binary configuration
    settings = "os", "compiler", "build_type", "arch"

    @property
    def _supported_platforms(self):
        return [
            ("Linux", "x86_64"),
        ]

    def configure(self):
        self.settings.rm_safe("compiler.cppstd")
        self.settings.rm_safe("compiler.libcxx")

    def package_id(self):
        del self.info.settings.compiler
        del self.info.settings.build_type

    def validate(self):
        if (self.settings.os, self.settings.arch) not in self._supported_platforms:
            raise ConanInvalidConfiguration(f"{self.settings.os}/{self.settings.arch} target is not supported")

    def source(self):
        pass

    def build(self):
        get(self, **self.conan_data["sources"][self.version][str(self.settings.os)][str(self.settings.arch)])
        download(self, **self.conan_data["sources"][self.version]["license"], filename="LICENSE")

    def package(self):
        copy(self, "*", src=self.build_folder, dst=self.package_folder)
        chmod(self, os.path.join(self.package_folder, "zenohd"), execute=True)

    def package_info(self):
        self.cpp_info.includedirs = []
        self.cpp_info.libdirs = []
