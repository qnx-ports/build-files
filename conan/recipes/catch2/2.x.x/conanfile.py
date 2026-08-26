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
    # This option is explicitly removed to avoid a mandatory shared-option declaration,
    # since Catch2 2.y.z supports only static libraries.
    # package_type = "library"
    settings = "os", "arch", "compiler", "build_type"
    options = {
        "fPIC": [True, False],
        "with_prefix": [True, False],
        "default_reporter": [None, "ANY"],
    }
    default_options = {
        "fPIC": True,
        "with_prefix": False,
        "default_reporter": None,
    }
    # disallow cppstd compatibility, as it affects the ABI in this library
    # see https://github.com/conan-io/conan-center-index/issues/19008
    extension_properties = {"compatibility_cppstd": False}

    @property
    def _default_reporter_str(self):
        return str(self.options.default_reporter).strip('"')

    def layout(self):
        cmake_layout(self, src_folder="src")

    def build_requirements(self):
        self.tool_requires("cmake/[>=3.16]")

    def validate(self):
        check_min_cppstd(self, 14)

    def source(self):
        get(self, **self.conan_data[self.version]["sources"], strip_root=True)

    def export_sources(self):
        export_conandata_patches(self)

    def generate(self):
        tc = CMakeToolchain(self)
        tc.variables["BUILD_TESTING"] = False
        tc.cache_variables["CATCH_INSTALL_DOCS"] = False     # these are cmake options, so use cache_variables
        tc.cache_variables["CATCH_BUILD_TESTING"] = False
        tc.cache_variables["CATCH_INSTALL_HELPERS"] = True
        tc.cache_variables["CATCH_BUILD_STATIC_LIBRARY"] = True
        if self.options.with_prefix:
            tc.preprocessor_definitions["CATCH_CONFIG_PREFIX_ALL"] = 1
        tc.preprocessor_definitions["CATCH_CONFIG_ENABLE_BENCHMARKING"] = 1
        if self.options.default_reporter:
            tc.variables["CATCH_CONFIG_DEFAULT_REPORTER"] = self._default_reporter_str
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
