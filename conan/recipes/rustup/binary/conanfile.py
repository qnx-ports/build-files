import os

from conan import ConanFile
from conan.tools.files import download, copy, chmod, rm
from conan.errors import ConanInvalidConfiguration


required_conan_version = ">=2.1"

class RustupConan(ConanFile):
    name = "rustup"
    package_type = "application"
    description = "The Rust toolchain installer."
    topics = ("toolchain", "rust", "rustlang", "installer", "pre-built")
    url = "https://github.com/rust-lang/rustup"
    homepage = "https://rustup.rs"
    license = "MIT", "Apache-2.0"
    settings = "os", "arch"

    def validate(self):
        if "x86_64" != self.settings.arch:
            raise ConanInvalidConfiguration("Rustup binaries are only provided for x86_64 architectures")
        if "Linux" != self.settings.os:
            raise ConanInvalidConfiguration("Rustup binaries are only provided for Linux")

    def build(self):
        download(self, **self.conan_data["sources"][self.version][str(self.settings.os)][str(self.settings.arch)], filename="rustup-init")
        chmod(self, "rustup-init", execute=True)

    @property
    def _cargo_home(self):
        return os.path.join(self.package_folder, ".cargo")

    @property
    def _rustup_home(self):
        return os.path.join(self.package_folder, ".rustup")

    def package(self):
        copy(self, "rustup-init", src=self.build_folder, dst=self.package_folder)
        download(self, **self.conan_data["sources"][self.version]["license-apache"], filename="LICENSE-APACHE")
        download(self, **self.conan_data["sources"][self.version]["license-mit"], filename="LICENSE-MIT")
        self.run(f"CARGO_HOME={self._cargo_home} RUSTUP_HOME={self._rustup_home} ./rustup-init --no-modify-path -y")
        rm(self, "rustup-init", self.build_folder, recursive=False)
        rm(self, "rustup-init", self.package_folder, recursive=False)

    def package_info(self):
        bindir = os.path.join(".cargo","bin")
        self.cpp_info.bindirs = [bindir]
        self.cpp_info.includedirs = []
        self.cpp_info.libdirs = []
        self.buildenv_info.define("CARGO_HOME", self._cargo_home)
        self.buildenv_info.define("RUSTUP_HOME", self._rustup_home)
