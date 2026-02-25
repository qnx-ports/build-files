from conan import ConanFile
from conan.tools.files import apply_conandata_patches, export_conandata_patches, get, copy
from conan.tools.gnu import Autotools, AutotoolsToolchain
from conan.tools.layout import basic_layout
from conan.tools.build import cmd_args_to_string
from conan.errors import ConanInvalidConfiguration

import os
import subprocess

required_conan_version = ">=2.1"

class RelativeAutotools(Autotools):
    def configure(self, nested_level=None, args=None):
        """
        Call the configure script.

        :param args: List of arguments to use for the ``configure`` call.
        :param nested_level: relative path to where the `configure` script is located.
                             If not specified conanfile.source_folder is used.
        """
        script_folder = os.path.join(".", nested_level) \
            if nested_level else self._conanfile.source_folder

        configure_args = []
        configure_args.extend(args or [])

        self._configure_args = f"{self._configure_args} {cmd_args_to_string(configure_args)}"

        configure_cmd = f"{script_folder}/configure"

        cmd = f'"{configure_cmd}" {self._configure_args}'
        self._conanfile.run(cmd)

class iperf2Conan(ConanFile):
    name = "iperf2"
    description = "Conan installer for iperf2"
    topics = ("iperf2", "benchmark", "performance", "network")
    url = "https://github.com/qnx-ports/build-files/conan"
    homepage = "https://sourceforge.net/projects/iperf2/"
    license = "BSD-3-Clause–style license"
    package_type = "application"
    settings = "os", "arch", "compiler", "build_type"

    def validate(self):
        if self.settings.os not in ["Linux", "Neutrino"]:
            raise ConanInvalidConfiguration(f"{self.ref} is not supported on {self.settings.os}.")

    def source(self):
        get(self, **self.conan_data[self.version]["sources"], strip_root=True)

    def export_sources(self):
        export_conandata_patches(self)

    def _nto_cpu(self):
        return "aarch64" if "armv8" == self.settings.arch else self.settings.arch

    def _nto_ac_host(self):
        out=subprocess.run([f"nto{self._nto_cpu()}-gcc", "-dumpmachine"],
                       capture_output=True,
                       check=False,
                       text=True
        )
        return out.stdout.strip()

    def layout(self):
        basic_layout(self, src_folder="src")

    def generate(self):
        tc = AutotoolsToolchain(self)
        tc.configure_args = ["--prefix=/usr"]
        if "Neutrino" == self.settings.os:
            tc.configure_args.extend(
                [
                f"--host={self._nto_ac_host()}",
                #f"--target={self._nto_ac_host()}",
                #f"--sysroot={os.getenv('QNX_TARGET')}"
                ]
            )
            tc.extra_ldflags = ["-lsocket", "-llogin"]
        tc.generate()

    def build(self):
        apply_conandata_patches(self)
        autotools = RelativeAutotools(self)
        autotools.configure(nested_level="../src")
        autotools.make()

    def package(self):
        copy(self, "COPYING", self.source_folder, os.path.join(self.package_folder, "licenses"))
        autotools = Autotools(self)
        autotools.install()

    def package_info(self):
        self.cpp_info.includedirs = []
        self.cpp_info.libdirs = []
