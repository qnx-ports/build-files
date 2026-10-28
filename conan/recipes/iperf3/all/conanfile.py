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

class iperf3Conan(ConanFile):
    name = "iperf3"
    description = "Conan installer for iperf3"
    topics = ("iperf3", "benchmark", "performance", "network")
    url = "https://github.com/qnx-ports/build-files/conan"
    homepage = "https://github.com/esnet/iperf"
    license = "BSD-3-Clause-LBNL"
    package_type = "application"
    settings = "os", "arch", "compiler", "build_type"
    options = {"with_tests": [True, False]}
    default_options = {"with_tests": False}

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
        tc.generate()

    def build(self):
        apply_conandata_patches(self)
        autotools = RelativeAutotools(self)
        autotools.configure(nested_level="../src")
        autotools.make()

    def package(self):
        copy(self, "LICENSE", self.source_folder, os.path.join(self.package_folder, "licenses"))
        autotools = Autotools(self)
        autotools.install()
        if self.options.with_tests:
            # upstream's `make check` programs (t_timer t_units t_uuid t_api): built by `make` but not installed.
            # src/t_* are libtool wrapper scripts with host paths; the ELF binaries are in src/.libs.
            copy(self, "t_*", os.path.join(self.build_folder, "src", ".libs"),
                 os.path.join(self.package_folder, "usr", "libexec", "iperf3-tests"))

    def package_info(self):
        self.cpp_info.includedirs = []
        self.cpp_info.libdirs = []
