#!/bin/sh

pass_count=0
fail_count=0

print_res() {
    if [ $? == 0 ]; then
        pass_count=$((pass_count + 1));
        echo -e "[PASSED]\t\t$1\n"
    else
        fail_count=$((fail_count + 1));
        echo -e "*[FAILED]*\t\t$1\n"
    fi
}

./test_array
print_res test_array

./test_chaos
print_res test_chaos

./test_copy
print_res test_copy

./test_dump
print_res test_dump

./test_dump_callback
print_res test_dump_callback

./test_equal
print_res test_equal

./test_fixed_size
print_res test_fixed_size

./test_load
print_res test_load

./test_load_callback
print_res test_load_callback

./test_loadb
print_res test_loadb

./test_memory_funcs
print_res test_memory_funcs

./test_number
print_res test_number

./test_object
print_res test_object

./test_pack
print_res test_pack

./test_simple
print_res test_simple

./test_sprintf
print_res test_sprintf

./test_unpack
print_res test_unpack

curr_dir=$(pwd)

for dir in "${curr_dir}/encoding-flags"/*/; do
    if [ -d "$dir" ]; then
        ./json_process "$dir"
        print_res "json_process_test_$(basename "$dir")"
    fi
done

for dir in "${curr_dir}/invalid-unicode"/*/; do
    if [ -d "$dir" ]; then
        ./json_process "$dir"
        print_res "json_process_test_$(basename "$dir")"
    fi
done

for dir in "${curr_dir}/valid"/*/; do
    if [ -d "$dir" ]; then
        ./json_process "$dir"
        print_res "json_process_test_$(basename "$dir")"
    fi
done

for dir in "${curr_dir}/invalid"/*/; do
    if [ -d "$dir" ]; then
        ./json_process "$dir"
        print_res "json_process_test_$(basename "$dir")"
    fi
done

for dir in "${curr_dir}/valid"/*/; do
    if [ -d "$dir" ]; then
        ./json_process --strip "$dir"
        print_res "json_process_test_$(basename "$dir")"
    fi
done

for dir in "${curr_dir}/invalid"/*/; do
    if [ -d "$dir" ]; then
        if [ ! -f ${dir}/nostrip ]; then
            ./json_process --strip "$dir"
            print_res "json_process_test_$(basename "$dir")"
        fi
    fi
done

echo -e "Total tests passed: ${pass_count}\nTotal tests failed: ${fail_count}"
