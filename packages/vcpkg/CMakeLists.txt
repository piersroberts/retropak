cmake_minimum_required(VERSION 3.14)
project(retropak LANGUAGES NONE)

# This is a data-only package (schemas and locales)
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

# Install schema files
install(
    DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/packages/schema/schemas/"
    DESTINATION "share/retropak/schemas"
    FILES_MATCHING PATTERN "*.json"
)

# Install locale files
install(
    DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/packages/schema/locales/"
    DESTINATION "share/retropak/locales"
    FILES_MATCHING PATTERN "*.json"
)

# Install package configuration files
include(CMakePackageConfigHelpers)

# Create the config file
configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/retropak-config.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/retropak-config.cmake"
    INSTALL_DESTINATION "share/retropak"
)

# Install the config files
install(
    FILES "${CMAKE_CURRENT_BINARY_DIR}/retropak-config.cmake"
    DESTINATION "share/retropak"
)
