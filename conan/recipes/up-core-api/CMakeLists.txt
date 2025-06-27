cmake_minimum_required(VERSION 3.23)
project(up-core-api VERSION 1.5.8 LANGUAGES CXX DESCRIPTION "uProtocol Core API")

find_package(protobuf CONFIG REQUIRED)
if (IS_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/up-core-api/")
	set(UP_PROTO_BASE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/up-core-api/")
else()
    message(FATAL_ERROR "Could not find up-core-api.")
endif()

####################################################################
# Use protoc to generate the C++ headers / sources from .proto files
set(UP_PROTO_OUT_DIR ${CMAKE_BINARY_DIR}/protoc)
file(MAKE_DIRECTORY ${UP_PROTO_OUT_DIR})

set(PROTO_FILES
	up-core-api/uprotocol/uoptions.proto
	up-core-api/uprotocol/v1/file.proto
	up-core-api/uprotocol/v1/uattributes.proto
	up-core-api/uprotocol/v1/umessage.proto
	up-core-api/uprotocol/v1/uri.proto
	up-core-api/uprotocol/v1/ustatus.proto
	up-core-api/uprotocol/v1/ucode.proto
	up-core-api/uprotocol/v1/uuid.proto
	up-core-api/uprotocol/core/udiscovery/v3/udiscovery.proto
	up-core-api/uprotocol/core/usubscription/v3/usubscription.proto
	up-core-api/uprotocol/core/utwin/v2/utwin.proto)

#Create an INTERFACE to hold the generated proto files
add_library(up-core-api-protos INTERFACE ${PROTO_FILES})

#protobuf_generate_cpp(PROTO_SRCS PROTO_HDRS ${PROTO_FILES})

protobuf_generate(LANGUAGE cpp TARGET up-core-api-protos
	PROTOS ${PROTO_FILES}
	OUT_VAR GENERATED_SRCS
	#IMPORT_DIRS ${UP_PROTO_BASE_PATH} ${UP_PROTO_BASE_PATH}/uprotocol
	IMPORT_DIRS ${UP_PROTO_BASE_PATH}
	PROTOC_OUT_DIR ${UP_PROTO_OUT_DIR})

#message("ALL GENERATED: ${GENERATED_SRCS}")
set(GENERATED_HDRS "${GENERATED_SRCS}")
list(FILTER GENERATED_SRCS INCLUDE REGEX ".pb.cc$")
list(FILTER GENERATED_HDRS INCLUDE REGEX ".pb.h$")
#message("FILTERED SRCS: ${GENERATED_SRCS}")
#message("FILTERED HDRS: ${GENERATED_HDRS}")

##########################
# Build the actual library
add_library(up-core-api)
target_include_directories(up-core-api
	PRIVATE
	${CMAKE_BINARY_DIR}
	${UP_PROTO_OUT_DIR}
	${UP_PROTO_OUT_DIR}/uprotocol
	${protobuf_INCLUDE_DIRS}
)
target_link_libraries(up-core-api ${protobuf_LIBRARIES})
target_sources(up-core-api
	PRIVATE
	${GENERATED_SRCS}
	PUBLIC FILE_SET public_headers TYPE HEADERS BASE_DIRS build/protoc build/Release/protoc build/Debug/protoc FILES
	${GENERATED_HDRS}
)

install(TARGETS up-core-api LIBRARY ARCHIVE FILE_SET public_headers)
