from conan import ConanFile
from conan.tools.cmake import CMake, CMakeDeps, CMakeToolchain, cmake_layout
import os

class RestbedTest(ConanFile):
    name = "restbed_test"
    homepage = "https://github.com/Corvusoft/restbed"
    description = "Corvusoft's Restbed framework brings asynchronous RESTful functionality to C++14 applications."
    topics = ("restful", "server", "client", "json", "http", "ssl", "tls")
    url = "https://github.com/qnx-ports/build-files/conan"
    license = "AGPL-3.0-or-later", "LicenseRef-CPL"  # Corvusoft Permissive License (CPL)
    settings = "os", "arch", "compiler", "build_type"

    def layout(self):
        project_root = os.environ["QNX_PROJECT_ROOT"]
        cmake_layout(self, src_folder=os.path.join(project_root,"."), build_folder=os.path.join(project_root,"build_tests"))

    def requirements(self):
        self.requires("catch2/2.13.10")
        self.requires("asio/1.29.0")

    def build_requirements(self):
        self.tool_requires("cmake/3.31.6")

    def generate(self):
        deps = CMakeDeps(self)
        deps.generate()
        tc = CMakeToolchain(self)
        tc.cache_variables["CMAKE_POLICY_VERSION_MINIMUM"] = "3.5" # CMake 4 support
        tc.variables["BUILD_TESTS"] = True
        tc.variables["BUILD_SSL"] = False
        tc.variables["BUILD_IPC"] = False

        if self.settings.os == "Neutrino":
            tc.cache_variables["CMAKE_EXE_LINKER_FLAGS_INIT"] = "-lsocket"
            #for share object option "shared=true"
            tc.cache_variables["CMAKE_SHARED_LINKER_FLAGS_INIT"] = "-lsocket"
            tc.extra_cxxflags = ["-DASIO_HAS_PTHREADS", "-DASIO_HAS_STD_STRING_VIEW", "-Wno-error=narrowing"]
        tc.generate()
