from conan import ConanFile
from conan.errors import ConanInvalidConfiguration
from conan.tools.build import check_min_cppstd
from conan.tools.cmake import CMake, CMakeToolchain, cmake_layout
from conan.tools.files import copy, get, apply_conandata_patches, export_conandata_patches
import os

required_conan_version = ">=2.0"


class Catch2Recipe(ConanFile):
    name = "catch2"
    description = "A modern, C++-native, header-only, framework for unit-tests, TDD and BDD"
    license = "BSL-1.0"
    url = "https://github.com/qnx-ports/build-files/conan"
    homepage = "https://github.com/catchorg/Catch2"
    topics = ("catch2", "unit-test", "tdd", "bdd")
    package_type = "library"
    settings = "os", "arch", "compiler", "build_type"
    options = {
        "shared": [True, False],
        "fPIC": [True, False],
        "with_prefix": [True, False],
        "default_reporter": [None, "ANY"],
        "console_width": [None, "ANY"],
        "no_posix_signals": [True, False],
    }
    default_options = {
        "shared": False,
        "fPIC": True,
        "with_prefix": False,
        "default_reporter": None,
        "console_width": "80",
        "no_posix_signals": False,
    }
    # disallow cppstd compatibility, as it affects the ABI in this library
    # see https://github.com/conan-io/conan-center-index/issues/19008
    extension_properties = {"compatibility_cppstd": False}

    @property
    def _min_console_width(self):
        # Catch2 doesn't build if less than this value
        return 46

    @property
    def _default_reporter_str(self):
        return str(self.options.default_reporter).strip('"')

    def configure(self):
        if self.options.shared:
            self.options.rm_safe("fPIC")

    def layout(self):
        cmake_layout(self, src_folder="src")

    def build_requirements(self):
        self.tool_requires("cmake/[>=3.16]")

    def validate(self):
        check_min_cppstd(self, 14)

        try:
            if int(self.options.console_width) < self._min_console_width:
                raise ConanInvalidConfiguration(
                        f"option 'console_width' must be >= {self._min_console_width}, "
                        f"got {self.options.console_width}. Contributions welcome if this should work!")
        except ValueError as e:
            raise ConanInvalidConfiguration(f"option 'console_width' must be an integer, "
                                            f"got '{self.options.console_width}'") from e

    def source(self):
        get(self, **self.conan_data[self.version]["sources"], strip_root=True)

    def export_sources(self):
        export_conandata_patches(self)

    def generate(self):
        tc = CMakeToolchain(self)
        tc.variables["BUILD_TESTING"] = False
        tc.cache_variables["CATCH_INSTALL_DOCS"] = False
        tc.cache_variables["CATCH_INSTALL_EXTRAS"] = True
        tc.cache_variables["CATCH_DEVELOPMENT_BUILD"] = False
        tc.variables["CATCH_CONFIG_PREFIX_ALL"] = self.options.with_prefix
        tc.variables["CATCH_CONFIG_CONSOLE_WIDTH"] = self.options.console_width
        if self.options.default_reporter:
            tc.variables["CATCH_CONFIG_DEFAULT_REPORTER"] = self._default_reporter_str
        tc.variables["CATCH_CONFIG_NO_POSIX_SIGNALS"] = self.options.no_posix_signals
        tc.generate()

    def build(self):
        apply_conandata_patches(self)
        cmake = CMake(self)
        cmake.configure()
        cmake.build()

    def package(self):
        copy(self, "LICENSE.txt", src=self.source_folder, dst=os.path.join(self.package_folder, "licenses"))
        cmake = CMake(self)
        cmake.install()

    def package_info(self):
        self.cpp_info.set_property("cmake_file_name", "Catch2")
        self.cpp_info.set_property("cmake_target_name", "Catch2::Catch2WithMain")
        self.cpp_info.set_property("pkg_config_name", "catch2-with-main")
