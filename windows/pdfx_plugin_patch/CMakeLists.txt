# Patched pdfx Windows CMakeLists.txt
# Apply to: pub cache pdfx/windows/ or .plugin_symlinks/pdfx/windows/
# Fixes: (1) Optional local pdfium, (2) CMake VERSION/CMP0048, (3) NOMINMAX for min/max

cmake_minimum_required(VERSION 3.14)
set(PROJECT_NAME "pdfx")
# Explicit VERSION avoids CMP0048 / project() conflicts with VS 2022 and Windows 11 SDK
project(${PROJECT_NAME} VERSION 1.0.0 LANGUAGES CXX)

set(ARCH "x64")
set(PDFIUM_VERSION "4690" CACHE STRING "Version of pdfium used")

# Option: use pre-downloaded pdfium (skip DownloadProject when set)
option(PDFIUM_USE_LOCAL "Use pre-extracted pdfium from PDFIUM_SOURCE_DIR" OFF)
set(PDFIUM_SOURCE_DIR "" CACHE PATH "Path to extracted pdfium (e.g. build/windows/x64/pdfium-src) when PDFIUM_USE_LOCAL=ON")

if(PDFIUM_USE_LOCAL AND PDFIUM_SOURCE_DIR)
  if(NOT EXISTS "${PDFIUM_SOURCE_DIR}/PDFiumConfig.cmake")
    message(FATAL_ERROR "PDFIUM_USE_LOCAL=ON but PDFiumConfig.cmake not found in ${PDFIUM_SOURCE_DIR}. Extract the bblanchon pdfium-win-x64.tgz so that PDFiumConfig.cmake and lib/ exist.")
  endif()
  set(pdfium_SOURCE_DIR "${PDFIUM_SOURCE_DIR}")
  message(STATUS "pdfx: Using local pdfium at ${pdfium_SOURCE_DIR}")
else()
  # Automated download
  if(PDFIUM_VERSION STREQUAL "latest")
    set(PDFIUM_URL "https://github.com/bblanchon/pdfium-binaries/releases/latest/download/pdfium-windows-${ARCH}.zip")
  else()
    string(COMPARE GREATER_EQUAL "${PDFIUM_VERSION}" "4690" PDFIUM_BINARY_NEW_FORMAT)
    if(PDFIUM_BINARY_NEW_FORMAT)
      set(PDFIUM_URL "https://github.com/bblanchon/pdfium-binaries/releases/download/chromium/${PDFIUM_VERSION}/pdfium-win-${ARCH}.tgz")
    else()
      set(PDFIUM_URL "https://github.com/bblanchon/pdfium-binaries/releases/download/chromium/${PDFIUM_VERSION}/pdfium-windows-${ARCH}.zip")
    endif()
  endif()

  include(${CMAKE_CURRENT_LIST_DIR}/DownloadProject.cmake)
  download_project(
    PROJ
    pdfium
    URL
    ${PDFIUM_URL}
    DOWNLOAD_EXTRACT_TIMESTAMP
    FALSE
  )
endif()

# This value is used when generating builds using this plugin, so it must
# not be changed
set(PLUGIN_NAME "pdfx_plugin")

include(${pdfium_SOURCE_DIR}/PDFiumConfig.cmake)

add_library(${PLUGIN_NAME} SHARED
  "pdfx.cpp"
  "pdfx.h"
  "pdfx_plugin.cpp"
)
apply_standard_settings(${PLUGIN_NAME})
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
# NOMINMAX: prevent Windows min/max macros from breaking std::min/std::max
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL NOMINMAX)
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE pdfium flutter flutter_wrapper_plugin)

# List of absolute paths to libraries that should be bundled with the plugin
set(pdfx_bundled_libraries
  "${PDFium_LIBRARY}"
  PARENT_SCOPE
)
