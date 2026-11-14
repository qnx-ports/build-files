import os

from conan import ConanFile
from conan.tools.files import copy
from conan.tools.scm import Git
from conan.errors import ConanInvalidConfiguration

required_conan_version = ">=2.1"

class RustConan(ConanFile):
    name = "rust"
    package_type = "application"
    description = "The Rust Programming Language"
    topics = ("rust", "language", "rust-language")
    url = "https://github.com/qnx-ports/build-files/conan"
    homepage = "https://www.rust-lang.org"
    license = "MIT", "Apache-2.0"
    settings = "os", "arch"

    default_target = "x86_64-unknown-linux-gnu"

    linux_targets = [
        default_target
        ]

    qnx_targets = [
        "x86_64-pc-nto-qnx710",
        "aarch64-unknown-nto-qnx710",
        "x86_64-pc-nto-qnx800",
        "aarch64-unknown-nto-qnx800"
        ]

    options = {
        "target": linux_targets + qnx_targets
    }

    default_options = {
        "target": default_target
    }

    def validate(self):
        # validate QNX targets env
        if self.options.target in self.qnx_targets:
            qnx_host = os.environ.get("QNX_HOST")
            if None is qnx_host:
                raise ConanInvalidConfiguration(f"For target:{self.options.target} you forgot to source QNX sdp.")
            if 0 != self.run("which qcc", ignore_errors=True):
                raise ConanInvalidConfiguration(f"qcc was not found. Please sorce QNX sdp again.")

    def build_requirements(self):
        version_data = self.conan_data[self.version]
        if "build_requirements" in version_data:
            for requirement, version in version_data["build_requirements"].items():
                self.tool_requires(f"{requirement}/{version}")
        else:
            raise ConanInvalidConfiguration("No build requirements specified in conandata.yml. Please check your configuration.")

    def export_sources(self):
        copy(self, "config.toml", self.recipe_folder, self.export_sources_folder)

    def source(self):
        git = Git(self)
        git.fetch_commit(**self.conan_data[self.version]["sources"])

    @property
    def _get_targets_list(self):
        return self.default_target if self.options.target == self.default_target else f"{self.default_target},{self.options.target}"

    @property
    def _get_toolchain_name(self):
        return f"local-{self.version}-{self.options.target}"

    def build(self):
        self.run(f"./x build --target {self._get_targets_list}")

    def package(self):
        # copy all rust licenses
        copy(self, "LICENSE-APACHE", self.source_folder, os.path.join(self.package_folder, "licenses"))
        copy(self, "LICENSE-MIT", self.source_folder, os.path.join(self.package_folder, "licenses"))
        # install rust toolchain
        self.run(f"DESTDIR={self.package_folder} ./x install --target {self._get_targets_list}")
        # link new toolchain
        toolchain_path = os.path.join(self.package_folder, "usr/local")
        toolchain_name = self._get_toolchain_name
        self.run(f"rustup toolchain link {toolchain_name} {toolchain_path}")

    def package_info(self):
        self.cpp_info.includedirs = []
        self.cpp_info.libdirs = []
        self.conf_info.define("user.rust.toolchain:name", self._get_toolchain_name)
