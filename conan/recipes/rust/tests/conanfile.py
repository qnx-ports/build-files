import os

from conan import ConanFile
from conan.errors import ConanInvalidConfiguration

required_conan_version = ">=2.1"

class RustTestConan(ConanFile):
    name = "rust-test"
    package_type = "application"
    description = "The Rust Programming Language"
    topics = ("rust", "language", "rust-language")
    url = "https://github.com/qnx-ports/build-files/conan"
    homepage = "https://www.rust-lang.org"
    license = "MIT", "Apache-2.0"
    settings = "os", "arch"

    qnx_targets = [
        "x86_64-pc-nto-qnx710",
        "aarch64-unknown-nto-qnx710",
        "x86_64-pc-nto-qnx800",
        "aarch64-unknown-nto-qnx800"
        ]
    linux_targets = [
        "x86_64-unknown-linux-gnu"
        ]
    default_target = linux_targets[0]
    options = {
        "target": linux_targets + qnx_targets
    }

    default_options = {
        "target": default_target
    }

    def layout(self):
        project_root = os.environ.get("QNX_PROJECT_ROOT")
        if None is project_root:
            raise ConanInvalidConfiguration("You forgot to set env variable QNX_PROJECT_ROOT.")
        self.folders.source = os.path.join(project_root, ".")
        self.folders.build = os.path.join(project_root,"build_toolchain")
        self.folders.generators = os.path.join(self.folders.build, "generators")

    def validate(self):
        # validate QNX targets env
        if self.options.target in self.qnx_targets:
            qnx_host = os.environ.get("QNX_HOST")
            if None is qnx_host:
                raise ConanInvalidConfiguration(f"For target:{self.options.target} you forgot to source QNX sdp.")
            if 0 != self.run("which qcc"):
                raise ConanInvalidConfiguration(f"qcc was not found. Please sorce QNX sdp again.")

    def build_requirements(self):
        self.tool_requires("rustup/1.28.2")

    @property
    def _get_targets_list(self):
        return self.default_target if self.options.target == self.default_target else f"{self.default_target},{self.options.target}"

    def build(self):
        build_cmd = os.path.join(self.source_folder, "x")
        self.run(f"{build_cmd} build --build-dir {self.build_folder} --target {self._get_targets_list}")
