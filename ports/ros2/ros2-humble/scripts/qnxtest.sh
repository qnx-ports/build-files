#!/bin/sh

DIR=${PWD}

export PYTHONPATH=$PYTHONPATH:${DIR}/usr/lib/python3.11/site-packages
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/ros/humble/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${DIR}/test/libstatistics_collector
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${DIR}/test/rcpputils

chmod -R +x ${DIR}/test

# ALl tests pass
echo Testing foonathan_memory
cd ${DIR}/test/foonathan_memory
./foonathan_memory_test

# All tests pass
echo Testing fastcdr
cd ${DIR}/test/fastcdr
./UnitTests

# All tests pass
echo Testing libstatistics_collector
cd ${DIR}/test/libstatistics_collector
./test_collector
./test_moving_average_statistics
./test_received_message_age
./test_received_message_period

# All tests pass
echo Testing rcpputils
cd ${DIR}/test/rcpputils
./test_accumulator
./test_asserts_debug
./test_asserts_ndebug
./test_clamp
./test_endian
NORMAL_TEST=foo ./test_env
EXPECTED_WORKING_DIRECTORY="${DIR}/test/rcpputils" ./test_filesystem_helper
./test_find_and_replace
./test_find_library
./test_join
./test_pointer_traits
./test_process
./test_scope_exit
./test_shared_library
./test_split
./test_thread_safety_annotations
./test_time

# All tests pass
echo Testing rmw
cd ${DIR}/test/rmw/test
./test_allocators
./test_convert_rcutils_ret_to_rmw_ret
./test_event
./test_init
./test_init_options
./test_message_sequence
./test_names_and_types
./test_network_flow_endpoint
./test_network_flow_endpoint_array
./test_publisher_options
./test_qos_string_conversions
./test_sanity_checks
./test_security_options
./test_serialized_message
./test_subscription_content_filter_options
./test_subscription_options
./test_time
./test_topic_endpoint_info
./test_topic_endpoint_info_array
./test_types
./test_validate_full_topic_name
./test_validate_namespace
./test_validate_node_name

# All tests pass
echo Testing rosidl_runtime_c
cd ${DIR}/test/rosidl_runtime_c
./test_message_type_support
./test_primitives_sequence_functions
./test_sequence_bound
./test_service_type_support
./test_string_functions
./test_u16string_functions

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${DIR}/test/rosidl_typesupport_cpp
echo Testing rosidl_typesupport_cpp
cd ${DIR}/test/rosidl_typesupport_cpp
./test_message_type_support
./test_service_type_support

echo Testing rosidl_typesupport_fastrtps_cpp
cd ${DIR}/test/rosidl_typesupport_fastrtps_cpp
./test_wstring_conversion
./test_wstring_conversion_mem