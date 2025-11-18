from conan import ConanFile
from conan.tools.files import copy, get
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
        :param nested_level: relative path to where the `configure` script is located. If not specified
                                    conanfile.source_folder is used.
        """
        script_folder = os.path.join(".", nested_level) \
            if nested_level else self._conanfile.source_folder

        configure_args = []
        configure_args.extend(args or [])

        self._configure_args = "{} {}".format(self._configure_args, cmd_args_to_string(configure_args))

        configure_cmd = "{}/configure".format(script_folder)
        cmd = '"{}" {}'.format(configure_cmd, self._configure_args)
        self._conanfile.run(cmd)

class Perl5Conan(ConanFile):
    name = "perl5"
    description = "Conan installer for Perl5"
    topics = ("perl5", "perl-cross", "build", "installer")
    url = "https://github.com/qnx-ports/build-files/conan"
    homepage = "https://github.com/Perl/perl5"
    license = "Artistic License"
    package_type = "application"
    settings = "os", "arch", "compiler", "build_type"

    def validate(self):
        if self.settings.os not in ["Linux", "Neutrino"]:
            raise ConanInvalidConfiguration(f"{self.ref} is not supported on {self.settings.os}.")

    def source(self):
        perl_data = self.conan_data["perl5"]
        perl_cross_version = perl_data[self.version]["perl-cross"]
        perl_cross_data = self.conan_data["perl-cross"]
        # fetch perl sources
        get(self, **perl_data[self.version]["sources"], destination=self.source_folder, strip_root=True)
        # fetch perl-cross sources
        get(self, **perl_cross_data[perl_cross_version]["sources"], destination=self.source_folder, strip_root=True)

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
                f"--target={self._nto_ac_host()}",
                f"--sysroot={os.getenv('QNX_TARGET')}"
                ]
            )
            tc.extra_ldflags = ["-lsocket", "-llogin"]
        tc.generate()

    def build(self):
        autotools = RelativeAutotools(self)
        autotools.configure(nested_level="../src")
        autotools.make()

    def package(self):
        # copy perl5 licenses
        copy(self, "Artistic", self.source_folder, os.path.join(self.package_folder, "licenses"))
        copy(self, "Copying", self.source_folder, os.path.join(self.package_folder, "licenses"))
        # copy perl-cross license
        copy(self, "LICENSE", self.source_folder, os.path.join(self.package_folder, "licenses"))
        autotools = Autotools(self)
        autotools.install()

    def package_info(self):
        self.cpp_info.includedirs = []
        self.cpp_info.libdirs = []
