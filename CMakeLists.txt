# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

cmake_minimum_required(VERSION 3.3)

set(DEFAULT_PACKAGE_NAME    "csi")
set(DEFAULT_PACKAGE_VERSION "0.1.0")

#############################
# Configuration options.
#############################

set(PACKAGE_NAME
  ${DEFAULT_PACKAGE_NAME}
  CACHE STRING
  "The name of the package")

set(PACKAGE_VERSION
  ${DEFAULT_PACKAGE_VERSION}
  CACHE STRING
  "The version of the package")

set(PROTOBUF_COMPILER_PATH
  ""
  CACHE FILEPATH
  "Path to the protobuf compiler")

set(GRPC_CXX_PLUGIN_PATH
  ""
  CACHE FILEPATH
  "Path to the GRPC C++ plugin")

set(GRPC_GO_PLUGIN_PATH
  ""
  CACHE FILEPATH
  "Path to the GRPC go plugin")

#############################
# Source files.
#############################

project(${PACKAGE_NAME})

enable_language(CXX)

set(CSI_SPEC    ${CMAKE_CURRENT_SOURCE_DIR}/spec.md)
set(CSI_PROTO   ${CMAKE_CURRENT_BINARY_DIR}/${PACKAGE_NAME}.proto)

set(CSI_CXX_PROTO_HEADERS
  ${CMAKE_CURRENT_BINARY_DIR}/${PACKAGE_NAME}.pb.h
  ${CMAKE_CURRENT_BINARY_DIR}/${PACKAGE_NAME}.grpc.pb.h
)

set(CSI_CXX_PROTO_SOURCES
  ${CMAKE_CURRENT_BINARY_DIR}/${PACKAGE_NAME}.pb.cc
  ${CMAKE_CURRENT_BINARY_DIR}/${PACKAGE_NAME}.grpc.pb.cc
)

set(CSI_CXX_PROTO_GEN
  ${CSI_CXX_PROTO_HEADERS}
  ${CSI_CXX_PROTO_SOURCES}
)

set(CSI_GO_PROTO_GEN
  ${CMAKE_CURRENT_BINARY_DIR}/${PACKAGE_NAME}.pb.go
)

#############################
# Build rules.
#############################

set(CMAKE_CXX_STANDARD 11)

# Find the protobuf compiler and plugins if not specified.
if (NOT PROTOBUF_COMPILER_PATH)
  find_program(PROTOBUF_COMPILER protoc)
else()
  set(PROTOBUF_COMPILER ${PROTOBUF_COMPILER_PATH})
endif ()

if (NOT GRPC_CXX_PLUGIN)
  find_program(GRPC_CXX_PLUGIN grpc_cpp_plugin)
else()
  set(GRPC_CXX_PLUGIN ${GRPC_CXX_PLUGIN_PATH})
endif ()

if (NOT GRPC_GO_PLUGIN)
  find_program(GRPC_GO_PLUGIN protoc-gen-go)
else()
  set(GRPC_GO_PLUGIN ${GRPC_GO_PLUGIN_PATH})
endif ()

configure_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/cxx/csi.h.in
  ${CMAKE_CURRENT_BINARY_DIR}/cxx/${PACKAGE_NAME}.h
)

add_custom_command(
  OUTPUT    ${CSI_CXX_PROTO_GEN}
  COMMAND   ${PROTOBUF_COMPILER}
  ARGS      --grpc_out=${CMAKE_CURRENT_BINARY_DIR}
            --cpp_out=${CMAKE_CURRENT_BINARY_DIR}
            --proto_path=${CMAKE_CURRENT_BINARY_DIR}
            --plugin=protoc-gen-grpc=${GRPC_CXX_PLUGIN}
            ${CSI_PROTO}
  DEPENDS   ${CSI_PROTO}
  COMMENT   "Generating CXX protobuf files"
)

add_custom_command(
  OUTPUT    ${CSI_GO_PROTO_GEN}
  COMMAND   ${PROTOBUF_COMPILER}
  ARGS      --go_out=plugins=grpc:${CMAKE_CURRENT_BINARY_DIR}
            --proto_path=${CMAKE_CURRENT_BINARY_DIR}
            --plugin=protoc-gen-go=${GRPC_GO_PLUGIN}
            ${CSI_PROTO}
  DEPENDS   ${CSI_PROTO}
  COMMENT   "Generating Go protobuf files"
)

add_custom_command(
  OUTPUT    ${CSI_PROTO}
  COMMAND   cat ${CSI_SPEC} | sed -n -e '/```protobuf$$/,/```$$/ p' | sed -e 's@^```.*$$@////////@g' > ${CSI_PROTO}
  DEPENDS   ${CSI_SPEC}
  COMMENT   "Generating protobuf file from the spec"
)

add_custom_target(
  proto ALL
  DEPENDS ${CSI_PROTO})

add_library(${PACKAGE_NAME} ${CSI_CXX_PROTO_SOURCES})

add_custom_target(
  go_source ALL
  DEPENDS ${CSI_GO_PROTO_GEN})


#############################
# Install rules.
#############################

include(CMakePackageConfigHelpers)

install(
  TARGETS   ${PACKAGE_NAME}
  EXPORT    export_targets
  LIBRARY   DESTINATION     lib
  ARCHIVE   DESTINATION     lib
  INCLUDES  DESTINATION     include
)

install(
  FILES         ${CMAKE_CURRENT_BINARY_DIR}/cxx/${PACKAGE_NAME}.h
  DESTINATION   include/${PACKAGE_NAME}
  COMPONENT     Devel
)

install(
  FILES         ${CSI_CXX_PROTO_HEADERS}
  DESTINATION   include/${PACKAGE_NAME}/internal
  COMPONENT     Devel
)

write_basic_package_version_file(
  ${CMAKE_CURRENT_BINARY_DIR}/cmake/${PACKAGE_NAME}-config-version.cmake
  VERSION         ${PACKAGE_VERSION}
  COMPATIBILITY   AnyNewerVersion
)

install(
  EXPORT        export_targets
  FILE          ${PACKAGE_NAME}-targets.cmake
  NAMESPACE     ${PACKAGE_NAME}::
  DESTINATION   lib/cmake/${PACKAGE_NAME}
)

install(
  FILES         ${CMAKE_CURRENT_BINARY_DIR}/cmake/${PACKAGE_NAME}-config.cmake
                ${CMAKE_CURRENT_BINARY_DIR}/cmake/${PACKAGE_NAME}-config-version.cmake
  DESTINATION   lib/cmake/${PACKAGE_NAME}
  COMPONENT     Devel
)

# Support direct use of build tree.
export(
  EXPORT      export_targets
  FILE        ${CMAKE_CURRENT_BINARY_DIR}/cmake/${PACKAGE_NAME}-targets.cmake
  NAMESPACE   ${PACKAGE_NAME}::
)

configure_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/cmake/csi-config.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/cmake/${PACKAGE_NAME}-config.cmake
  @ONLY
)
