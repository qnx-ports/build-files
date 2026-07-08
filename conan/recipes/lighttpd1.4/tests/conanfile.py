import os

from conan import ConanFile
from conan.tools.cmake import CMakeToolchain, cmake_layout, CMakeDeps

class TestPackageConan(ConanFile):
    name = "lighttpd_unittest"
    settings = "os", "compiler", "build_type", "arch"

    def requirements(self):
        self.requires("pcre2/10.44")
        self.requires("zlib/1.3.1")

    def layout(self):
        project_root = os.environ["QNX_PROJECT_ROOT"]
        cmake_layout(self, src_folder=os.path.join(project_root,"."), build_folder=os.path.join(project_root,"build_tests"))

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
