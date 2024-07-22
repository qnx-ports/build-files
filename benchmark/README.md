# Compile the port for QNX

**NOTE**: QNX ports are only supported from a Linux host operating system

- Setup your QNX SDP environment
- Build and install `googletest` first (tested version 1.13.0 with QNX changes)

# Compile the port for QNX in a Docker container

Pre-requisite: Install Docker on Ubuntu https://docs.docker.com/engine/install/ubuntu/
```bash
# Build the Docker image and create a container
git clone https://gitlab.com/qnx/ports/docker-build-environment.git && cd docker-build-environment
./docker-build-qnx-image.sh
./docker-create-container.sh

# Now you are in the Docker container

# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://gitlab.com/qnx/ports/build-files.git && cd build-files

# source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh

# Clone benchmark
cd ~/qnx_workspace
git clone https://gitlab.com/qnx/ports/benchmark.git

# Build benchmark
QNX_PROJECT_ROOT="$(pwd)/benchmark" make -C build-files/benchmark JLEVEL=$(nproc) install
```

# Compile the port for QNX on Ubuntu host
```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://gitlab.com/qnx/ports/build-files.git
git clone https://gitlab.com/qnx/ports/benchmark.git

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Build
QNX_PROJECT_ROOT="$(pwd)/benchmark" make -C build-files/benchmark JLEVEL=$(nproc) install
```

# How to run tests


Compile the benchmark source for desired architecture.

**RPI**: Move Benchmark library and the test binary to the target:

e.g.

    - scp ~/build-files/benchmark/nto-aarch64-le/build/src/libbenchmark* root@<target-ip-address>:/usr/lib
    - scp ~/build-files/benchmark/nto-aarch64-le/build/test/*test root@<target-ip-address>:/usr/bin
    - scp ~/build-files/benchmark/nto-aarch64-le/build/lib/lib* root@<target-ip-address>:/usr/lib

ssh into your target and run the tests

**QEMU**: Move Benchmark library and test binary to qemu instance:

e.g.

    - scp ~/build-files/benchmark/nto-x86_64-o/build/lib/lib* root@<target-ip-address>:/system/lib
    - scp ~/build-files/benchmark/nto-x86_64-o/build/src/libbenchmark* root@<target-ip-address>:/system/lib
    - scp ~/build-files/benchmark/nto-x86_64-o/build/test/*test root@<target-ip-address>:/system/xbin

Make sure the library and binary path you're adding to is correct.

ssh into your target and run the tests with the following flags for each test:

- args_product_test --benchmark_min_time=0.01s
- basic_test --benchmark_min_time=0.01s
- benchmark_name_gtest
- benchmark_min_time_flag_iters_test
- benchmark_min_time_flag_time_test
- benchmark_name_gtest
- benchmark_random_interleaving_gtest
- benchmark_setup_teardown_test
- benchmark_test --benchmark_min_time=0.01s
- commandlineflags_gtest
- complexity_test --benchmark_min_time=0.5s
- complexity_test --benchmark_min_time=0.01s
- diagnostics_test --benchmark_min_time=0.01s
- display_aggregates_only_test
- donotoptimize_test --benchmark_min_time=0.01s
- filter_test --benchmark_min_time=0.01s
- filter_test --benchmark_list_tests
- fixture_test --benchmark_min_time=0.01s
- internal_threading_test --benchmark_min_time=0.01s
- link_main_test --benchmark_min_time=0.01s
- map_test --benchmark_min_time=0.01s
- memory_manager_test --benchmark_min_time=0.01s
- min_time_parse_gtest
- multiple_ranges_test --benchmark_min_time=0.01s
- options_test --benchmark_min_time=0.01s
- perf_counters_gtest
- perf_counters_test --benchmark_min_time=0.01s --benchmark_perf_counters=CYCLES,BRANCHES
- register_benchmark_test --benchmark_min_time=0.01s
- repetitions_test --benchmark_min_time=0.01s --benchmark_repetitions=3
- report_aggregates_only_test --benchmark_min_time=0.01s
- reporter_output_test --benchmark_min_time=0.01s
- skip_with_error_test --benchmark_min_time=0.01s
- spec_arg_test --benchmark_filter=BM_NotChosen
- spec_arg_verbosity_test --v=42
- statistics_gtest
- string_util_gtest
- templated_fixture_test --benchmark_min_time=0.01s
- time_unit_gtest
- user_counters_tabular_test --benchmark_counters_tabular=true --benchmark_min_time=0.01s
- user_counters_test --benchmark_min_time=0.01s
- user_counters_thousands_test --benchmark_min_time=0.01s