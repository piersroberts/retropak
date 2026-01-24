# This portfile is for reference when submitting to the vcpkg registry
# It should be placed in the vcpkg/ports/retropak directory

# This is a data-only package (schemas and locales)
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO piersroberts/retropak
    REF v${VERSION}
    SHA512 34f6e5199204901861dfd49162f7d68c45606ee5b5bd42214c19ed3bbd5baa7013b4c8f0734af23fc5fdadb3fa2134bada16c7e718b57d463dcf15a431f1d76c
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

