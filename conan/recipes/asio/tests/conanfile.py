import os
import subprocess

from conan import ConanFile
from conan.tools.layout import basic_layout
from conan.tools.gnu import Autotools, AutotoolsToolchain
from conan.tools.build import cmd_args_to_string

def basic_layout(conanfile, src_folder=".", build_folder="build"):
    subproject = conanfile.folders.subproject

    conanfile.folders.source = src_folder if not subproject else os.path.join(subproject, src_folder)
    conanfile.folders.build = build_folder if not subproject else os.path.join(subproject, build_folder)
    if conanfile.settings.get_safe("build_type"):
        conanfile.folders.build = os.path.join(conanfile.folders.build, str(conanfile.settings.build_type))
    conanfile.folders.generators = os.path.join(conanfile.folders.build, "generators")
    conanfile.cpp.build.bindirs = ["."]
    conanfile.cpp.build.libdirs = ["."]

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

class TestPackageConan(ConanFile):
    name = "asio_unittest"
    settings = "os", "compiler", "build_type", "arch"

    def layout(self):
        project_root = os.environ["QNX_PROJECT_ROOT"]
        basic_layout(self, src_folder=os.path.join(project_root,"."), build_folder=os.path.join(project_root,"build_tests"))

    def _nto_cpu(self):
        return "aarch64" if "armv8" == self.settings.arch else self.settings.arch

    def _nto_ac_host(self):
        out=subprocess.run([f"nto{self._nto_cpu()}-gcc", "-dumpmachine"],
                       capture_output=True,
                       check=False,
                       text=True
        )
        return out.stdout.strip()

    def generate(self):
        tc = AutotoolsToolchain(self)
        tc.configure_args = ["--prefix=/usr"]
        if "Neutrino" == self.settings.os:
            tc.configure_args.extend(
                [
                f"--host={self._nto_ac_host()}",
                f"--target={self._nto_ac_host()}",
                ]
            )
            tc.extra_ldflags = ["-lsocket"]
            tc.extra_cxxflags = ["-DASIO_HAS_PTHREADS", "-DASIO_HAS_STD_STRING_VIEW", "-DASIO_HAS_CONSTEXPR", "-DASIO_HAS_STD_FUTURE_CLASS"]
        tc.generate()

    def build(self):
        root_src = os.path.join("..", "asio")
        if self.settings.get_safe("build_type"):
            root_src = os.path.join("..", root_src)
        self.run(cwd=root_src, command="./autogen.sh")
        autotools = RelativeAutotools(self)
        autotools.configure(nested_level=root_src)
        # Build all tests but do not execute them.
        autotools.make(target="check", args=["TESTS=''"])
