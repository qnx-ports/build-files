from conan import ConanFile
from conan.tools.cmake import CMake, CMakeToolchain, cmake_layout, CMakeDeps
from conan.tools.files import apply_conandata_patches, export_conandata_patches, get, copy
import os

class Lighttpd14Recipe(ConanFile):
    name = "lighttpd1.4"

    # Optional metadata
    package_type = "application"
    description = "Conan installer for web server Lighttpd 1.4"
    topics = ("web", "server", "lighttpd")
    url = "https://github.com/qnx-ports/build-files/conan"
    homepage = "https://github.com/lighttpd/lighttpd1.4"
    license = "BSD-3-Clause"

    # Binary configuration
    settings = "os", "arch", "compiler", "build_type"

    def requirements(self):
        version_data = self.conan_data[self.version]
        if "requirements" in version_data:
            for requirement, version in version_data["requirements"].items():
                self.requires(f"{requirement}/{version}")
        else:
            self.output.warning("No requirements specified in conandata.yml. Please check your configuration.")

    def source(self):
        get(self, **self.conan_data[self.version]["sources"], strip_root=True)

    def export_sources(self):
        export_conandata_patches(self)

    def layout(self):
        cmake_layout(self)

    def generate(self):
        deps = CMakeDeps(self)
        deps.generate()
        tc = CMakeToolchain(self)
        tc.cache_variables["WITH_PCRE2"] = True
        tc.cache_variables["WITH_ZLIB"] = True
        if self.settings.os == "Neutrino":
            libs = "-llogin -lsocket"
            if self.settings.os.version == "8.0":
                libs = f"{libs} -lfsnotify"
            tc.cache_variables["CMAKE_EXE_LINKER_FLAGS_INIT"] = libs
            #for share object option "shared=true"
            tc.cache_variables["CMAKE_SHARED_LINKER_FLAGS_INIT"] = libs
        tc.generate()

    def build(self):
        apply_conandata_patches(self)
        cmake = CMake(self)
        cmake.configure()
        cmake.build()

    def package(self):
        copy(self, "COPYING", self.source_folder, os.path.join(self.package_folder, "licenses"))
        cmake = CMake(self)
        cmake.install()

    def package_info(self):
        self.cpp_info.includedirs = []
        self.cpp_info.libdirs = []
