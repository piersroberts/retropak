# This portfile is for reference when submitting to the vcpkg registry
# It should be placed in the vcpkg/ports/retropak directory

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO piersroberts/retropak
    REF v${VERSION}
    SHA512 7227f1e7f0e58d0eac3bb949bf273e2349a75b2aa08e10db3d67a05b28d30dd0feee79b7e756ca37e100928eca4aacf361a6a045b64903cfdee7e8713612c9f7
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/packages/vcpkg"
)

vcpkg_cmake_install()

# Remove empty directories
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# Install license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

# Copy usage file
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

