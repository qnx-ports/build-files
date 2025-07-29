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

if [ "$QNX_SDP_VERSION" == "qnx710" ]
then
    echo "Fast-DDS googletests are temporarily disabled because of an incompatibility with the WillOnce function"
    exit 0
fi

echo Testing Fast-DDS
export CERTS_PATH=${DIR}/test/fastrtps/certs
export TEST_DIR=${DIR}/test/fastrtps
cd ${DIR}/test/fastrtps/blackbox
./BlackboxTests_RTPS

cd ${DIR}/test/fastrtps/communication
./SimpleCommunicationPubSub
cd ${DIR}/test/fastrtps/dds/communication
./DDSCommunicationPubSub

cd ${DIR}/test/fastrtps/xtypes
./XTypesBlackBoxTests

# Run blackbox tests
cd $TEST_DIR/blackbox
#./BlackboxTests_DDS_PIM
./BlackboxTests_RTPS

# Run xtypes tests
cd $TEST_DIR/xtypes
./XTypesBlackBoxTests

# Run unit tests
cd $TEST_DIR/unittest/dds/collections
./LoanableSequenceTests

cd $TEST_DIR/unittest/dds/core/condition
./ConditionTests
./ConditionNotifierTests
./WaitSetImplTests
./StatusConditionImplTests

cd $TEST_DIR/unittest/dds/participant
# Memory fault
./ParticipantTests

cd $TEST_DIR/unittest/dds/publisher
# 1 failure
./DataWriterTests
# 1 failure
./PublisherTests

cd $TEST_DIR/unittest/dds/status
./ListenerTests

cd $TEST_DIR/unittest/dds/subscriber
# 1 failure
./DataReaderTests
# 2 failures
./SubscriberTests

cd $TEST_DIR/unittest/dds/topic
./TopicTests

cd $TEST_DIR/unittest/dds/topic/DDSSQLFilter
# 359 failures long double
./DDSSQLFilterTests

cd $TEST_DIR/unittest/dynamic_types
./DynamicComplexTypesTests
# Segfault
./DynamicTypesTests
./DynamicTypes_4_2_Tests

cd $TEST_DIR/unittest/logging
./LogFileTests

cd $TEST_DIR/unittest/logging/log_macros
./LogMacrosNoInfoTests
./LogMacrosNoWarningTests
./LogMacrosAllActiveTests
./LogMacrosDefaultTests
./LogMacrosInternalDebugOffTests
./LogMacrosNoErrorTests

cd $TEST_DIR/unittest/rtps/builtin
./BuiltinDataSerializationTests

cd $TEST_DIR/unittest/rtps/common
./GuidPrefixTests
./PortParametersTests
./GuidTests
./SequenceNumberTests
./CacheChangeTests
./GuidUtilsTests
./EntityIdTests

cd $TEST_DIR/unittest/rtps/discovery
./EdpTests

cd $TEST_DIR/unittest/rtps/history
./BasicPoolsTests
./CacheChangePoolTests
./TopicPayloadPoolTests
./ReaderHistoryTests

cd $TEST_DIR/unittest/rtps/network
./NetworkFactoryTests

cd $TEST_DIR/unittest/rtps/persistence
./PersistenceTests

cd $TEST_DIR/unittest/rtps/reader
./WriterProxyTests

cd $TEST_DIR/unittest/rtps/resources/timedevent
./TimedEventTests

cd $TEST_DIR/unittest/rtps/writer
./LivelinessManagerTests
./ReaderProxyTests

cd $TEST_DIR/unittest/statistics/rtps
./RTPSStatisticsTests

# Temporarily disable because stuck
cd $TEST_DIR/unittest/transport
#./TCPv4Tests
#./TCPv6Tests
#./UDPv4Tests
#./UDPv6Tests

cd $TEST_DIR/unittest/utils
./BitmapRangeTests
./ResourceLimitedVectorTests
./SharedMutexTests
./StringMatchingTests
./FixedSizeQueueTests
./FixedSizeStringTests
./LocatorTests

cd $TEST_DIR/unittest/xmlparser
./XMLEndpointParserTests
# Temporarily disable because stuck
#./XMLParserTests
./XMLProfileParserTests
./XMLTreeTests

cd $TEST_DIR/unittest/xtypes
./XTypesTests

# Temporarily disable because stuck
cd $TEST_DIR/unittest/transport
#./SharedMemTests
