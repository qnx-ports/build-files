import os
from shutil import copytree

from conan import ConanFile
from conan.tools.files import copy, rmdir
from conan.tools.scm import Git

required_conan_version = ">=2.1"

class RustConan(ConanFile):
    name = "rust-llvm"
    package_type = "application"
    description = "Patched LLVM compiler for rust"
    topics = ("rust", "llvm", "language", "rust-language")
    url = "https://github.com/qnx-ports/build-files/conan"
    homepage = "https://www.rust-lang.org"
    license = "MIT", "Apache-2.0"
    settings = "os", "compiler", "arch"

    def export_sources(self):
        copy(self, "config.toml", self.recipe_folder, self.export_sources_folder)

    def source(self):
        git = Git(self)
        git.fetch_commit(**self.conan_data[self.version]["sources"])

    def build(self):
        self.run("./x build llvm")

    @property
    def _get_build_llvm_path(self):
        return os.path.join(self.build_folder, "build", "x86_64-unknown-linux-gnu", "llvm")

    def package(self):
        # copy all rust licenses
        copy(self, "LICENSE-APACHE", self.source_folder, os.path.join(self.package_folder, "licenses"))
        copy(self, "LICENSE-MIT", self.source_folder, os.path.join(self.package_folder, "licenses"))
        # remove unneeded llvm build tree
        rmdir(self, os.path.join(self._get_build_llvm_path,"build"))
        # copy rust llvm patched version to package folder
        copytree(src=self._get_build_llvm_path, dst=self.package_folder, symlinks=True, dirs_exist_ok=True)

    def package_info(self):
        self.cpp_info.includedirs = []
        self.cpp_info.libdirs = []
        self.cpp_info.bindirs = []
        # provide full path of rust-llvm to the clients
        self.conf_info.define("user.rust.llvm:path", self.package_folder)
