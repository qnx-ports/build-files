from conan import ConanFile
from conan.tools.cmake import CMake, CMakeDeps, CMakeToolchain, cmake_layout
from conan.tools.files import apply_conandata_patches, copy, export_conandata_patches, get, rm
import os

required_conan_version = ">=2"

class RestbedConan(ConanFile):
    name = "restbed"
    homepage = "https://github.com/Corvusoft/restbed"
    description = "Corvusoft's Restbed framework brings asynchronous RESTful functionality to C++14 applications."
    topics = ("restful", "server", "client", "json", "http", "ssl", "tls")
    url = "https://github.com/qnx-ports/build-files/conan"
    license = "AGPL-3.0-or-later", "LicenseRef-CPL"  # Corvusoft Permissive License (CPL)
    package_type = "library"
    settings = "os", "arch", "compiler", "build_type"

    options = {
        # Versions 4.8 and below always build both shared and static libraries.
        # However, this option must be defined to satisfy Conan.
        # Proper handling will be added in a future restbed version via BUILD_SHARED_LIBRARY / BUILD_STATIC_LIBRARY.
        "shared": [True, False],
        #"fPIC": [True, False],
        #TODO To be implemented once OpenSSL is available.
        #"with_openssl": [True, False],
    }

    default_options = {
        "shared": False,
        #"fPIC": True,
        #TODO To be implemented once OpenSSL is available.
        #"with_openssl": False,
    }

    def export_sources(self):
        export_conandata_patches(self)

    # def config_options(self):
    #     if self.settings.os == "Neutrino":
    #         #TODO: add support QNX openssl late
    #         self.options.with_openssl = False

    # def configure(self):
    #     if self.options.shared:
    #         self.options.rm_safe("fPIC")

    def layout(self):
        cmake_layout(self, src_folder="src")

    def requirements(self):
        version_data = self.conan_data[self.version]
        if "requirements" in version_data:
            for requirement, version in version_data["requirements"].items():
                self.requires(f"{requirement}/{version}")
        else:
            self.output.warning("No requirements specified in conandata.yml. Please check your configuration.")

    def build_requirements(self):
        version_data = self.conan_data[self.version]
        if "build_requirements" in version_data:
            for requirement, version in version_data["build_requirements"].items():
                self.tool_requires(f"{requirement}/{version}")
        else:
            self.output.warning("No build requirements specified in conandata.yml. Please check your configuration.")

    def source(self):
        get(self, **self.conan_data[self.version]["sources"], strip_root=True)

    def generate(self):
        tc = CMakeToolchain(self)
        tc.variables["BUILD_TESTS"] = False
        #TODO tc.variables["BUILD_SSL"] = self.options.with_openssl
        tc.variables["BUILD_SSL"] = False
        tc.variables["BUILD_IPC"] = False
        tc.cache_variables["CMAKE_POLICY_VERSION_MINIMUM"] = "3.5" # CMake 4 support
        if self.settings.os == "Neutrino":
            tc.cache_variables["CMAKE_EXE_LINKER_FLAGS_INIT"] = "-lsocket"
            #for share object option "shared=true"
            tc.cache_variables["CMAKE_SHARED_LINKER_FLAGS_INIT"] = "-lsocket"
            tc.extra_cxxflags = ["-DASIO_HAS_PTHREADS", "-DASIO_HAS_STD_STRING_VIEW", "-Wno-error=narrowing"]
        tc.generate()
        deps = CMakeDeps(self)
        deps.generate()

    def build(self):
        apply_conandata_patches(self)
        cmake = CMake(self)
        cmake.configure()
        cmake.build()

    def package(self):
        copy(self, "LICENSE*", src=self.source_folder, dst=os.path.join(self.package_folder, "licenses"))
        cmake = CMake(self)
        cmake.install()
        rm(self, "*.pdb", os.path.join(self.package_folder, "bin"))

    def package_info(self):
        libname = "restbed"
        self.cpp_info.libs = [libname]

        if self.settings.os in ["FreeBSD", "Linux"]:
            self.cpp_info.system_libs.extend(["dl", "m"])

        elif self.settings.os == "Neutrino":
            self.cpp_info.system_libs.extend(["socket"])
