cmake_minimum_required(VERSION 3.10)
project(GStreamerTest)

# Set C++ standard
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Enable verbose output for debugging
set(CMAKE_VERBOSE_MAKEFILE ON)

# Find PkgConfig for non-Windows systems
find_package(PkgConfig QUIET)
if(PKG_CONFIG_FOUND)
    set(PKG_CONFIG_FOUND TRUE)
endif()

# Your original GStreamer detection code
set(HAVE_GSTREAMER FALSE)

# --- GStreamer ---
if(NOT HAVE_GSTREAMER AND WIN32)
  set(env_paths "${GSTREAMER_DIR}" ENV GSTREAMER_ROOT)
  if(X86_64)
    list(APPEND env_paths ENV GSTREAMER_1_0_ROOT_X86_64 ENV GSTREAMER_ROOT_X86_64)
  else()
    list(APPEND env_paths ENV GSTREAMER_1_0_ROOT_X86 ENV GSTREAMER_ROOT_X86)
  endif()

  find_path(GSTREAMER_gst_INCLUDE_DIR
    gst/gst.h
    PATHS ${env_paths}
    PATH_SUFFIXES "include/gstreamer-1.0")
  find_path(GSTREAMER_glib_INCLUDE_DIR
    glib.h
    PATHS ${env_paths}
    PATH_SUFFIXES "include/glib-2.0")
  find_path(GSTREAMER_glibconfig_INCLUDE_DIR
    glibconfig.h
    PATHS ${env_paths}
    PATH_SUFFIXES "lib/glib-2.0/include")

  find_library(GSTREAMER_gstreamer_LIBRARY
    NAMES gstreamer gstreamer-1.0
    PATHS ${env_paths}
    PATH_SUFFIXES "lib")
  find_library(GSTREAMER_app_LIBRARY
    NAMES gstapp gstapp-1.0
    PATHS ${env_paths}
    PATH_SUFFIXES "lib")
  find_library(GSTREAMER_base_LIBRARY
    NAMES gstbase gstbase-1.0
    PATHS ${env_paths}
    PATH_SUFFIXES "lib")
  find_library(GSTREAMER_pbutils_LIBRARY
    NAMES gstpbutils gstpbutils-1.0
    PATHS ${env_paths}
    PATH_SUFFIXES "lib")
  find_library(GSTREAMER_riff_LIBRARY
    NAMES gstriff gstriff-1.0
    PATHS ${env_paths}
    PATH_SUFFIXES "lib")
  find_library(GSTREAMER_video_LIBRARY
    NAMES gstvideo gstvideo-1.0
    PATHS ${env_paths}
    PATH_SUFFIXES "lib")
  find_library(GSTREAMER_audio_LIBRARY
    NAMES gstaudio gstaudio-1.0
    PATHS ${env_paths}
    PATH_SUFFIXES "lib")

  find_library(GSTREAMER_glib_LIBRARY
    NAMES glib-2.0
    PATHS ${env_paths}
    PATH_SUFFIXES "lib")
  find_library(GSTREAMER_gobject_LIBRARY
    NAMES gobject-2.0
    PATHS ${env_paths}
    PATH_SUFFIXES "lib")

  if(GSTREAMER_gst_INCLUDE_DIR
      AND GSTREAMER_glib_INCLUDE_DIR
      AND GSTREAMER_glibconfig_INCLUDE_DIR
      AND GSTREAMER_gstreamer_LIBRARY
      AND GSTREAMER_app_LIBRARY
      AND GSTREAMER_base_LIBRARY
      AND GSTREAMER_pbutils_LIBRARY
      AND GSTREAMER_riff_LIBRARY
      AND GSTREAMER_video_LIBRARY
      AND GSTREAMER_audio_LIBRARY
      AND GSTREAMER_glib_LIBRARY
      AND GSTREAMER_gobject_LIBRARY)
    file(STRINGS "${GSTREAMER_gst_INCLUDE_DIR}/gst/gstversion.h" ver_strings REGEX "#define +GST_VERSION_(MAJOR|MINOR|MICRO|NANO).*")
    string(REGEX REPLACE ".*GST_VERSION_MAJOR[^0-9]+([0-9]+).*" "\\1" ver_major "${ver_strings}")
    string(REGEX REPLACE ".*GST_VERSION_MINOR[^0-9]+([0-9]+).*" "\\1" ver_minor "${ver_strings}")
    string(REGEX REPLACE ".*GST_VERSION_MICRO[^0-9]+([0-9]+).*" "\\1" ver_micro "${ver_strings}")
    set(GSTREAMER_VERSION "${ver_major}.${ver_minor}.${ver_micro}")  # informational
    set(HAVE_GSTREAMER TRUE)
    set(GSTREAMER_LIBRARIES
      ${GSTREAMER_gstreamer_LIBRARY}
      ${GSTREAMER_base_LIBRARY}
      ${GSTREAMER_app_LIBRARY}
      ${GSTREAMER_riff_LIBRARY}
      ${GSTREAMER_video_LIBRARY}
      ${GSTREAMER_audio_LIBRARY}
      ${GSTREAMER_pbutils_LIBRARY}
      ${GSTREAMER_glib_LIBRARY}
      ${GSTREAMER_gobject_LIBRARY})
    set(GSTREAMER_INCLUDE_DIRS
      ${GSTREAMER_gst_INCLUDE_DIR}
      ${GSTREAMER_glib_INCLUDE_DIR}
      ${GSTREAMER_glibconfig_INCLUDE_DIR})
  endif()
endif()

# Helper function for pkg-config (simulating ocv_check_modules)
function(ocv_check_modules prefix module_name)
  if(PKG_CONFIG_FOUND)
    pkg_check_modules(${prefix} ${module_name})
  endif()
endfunction()

if(NOT HAVE_GSTREAMER AND PKG_CONFIG_FOUND)
  ocv_check_modules(GSTREAMER_base gstreamer-base-1.0)
  ocv_check_modules(GSTREAMER_app gstreamer-app-1.0)
  ocv_check_modules(GSTREAMER_riff gstreamer-riff-1.0)
  ocv_check_modules(GSTREAMER_pbutils gstreamer-pbutils-1.0)
  ocv_check_modules(GSTREAMER_video gstreamer-video-1.0)
  ocv_check_modules(GSTREAMER_audio gstreamer-audio-1.0)
  if(GSTREAMER_base_FOUND AND GSTREAMER_app_FOUND AND GSTREAMER_riff_FOUND AND GSTREAMER_pbutils_FOUND AND GSTREAMER_video_FOUND AND GSTREAMER_audio_FOUND)
    set(HAVE_GSTREAMER TRUE)
    set(GSTREAMER_VERSION ${GSTREAMER_base_VERSION})  # informational
    set(GSTREAMER_LIBRARIES ${GSTREAMER_base_LIBRARIES} ${GSTREAMER_app_LIBRARIES} ${GSTREAMER_riff_LIBRARIES} ${GSTREAMER_pbutils_LIBRARIES} ${GSTREAMER_video_LIBRARIES} ${GSTREAMER_audio_LIBRARIES})
    set(GSTREAMER_INCLUDE_DIRS ${GSTREAMER_base_INCLUDE_DIRS} ${GSTREAMER_app_INCLUDE_DIRS} ${GSTREAMER_riff_INCLUDE_DIRS} ${GSTREAMER_pbutils_INCLUDE_DIRS} ${GSTREAMER_video_INCLUDE_DIRS} ${GSTREAMER_audio_INCLUDE_DIRS})
  endif()
endif()

# Print detailed status
message(STATUS "=== GStreamer Detection Results ===")
message(STATUS "System: ${CMAKE_SYSTEM_NAME}")
message(STATUS "Architecture: ${CMAKE_SYSTEM_PROCESSOR}")
message(STATUS "PKG_CONFIG_FOUND: ${PKG_CONFIG_FOUND}")
message(STATUS "HAVE_GSTREAMER: ${HAVE_GSTREAMER}")

if(WIN32)
  message(STATUS "Environment paths checked:")
  message(STATUS "  GSTREAMER_DIR: $ENV{GSTREAMER_DIR}")
  message(STATUS "  GSTREAMER_ROOT: $ENV{GSTREAMER_ROOT}")
  if(X86_64)
    message(STATUS "  GSTREAMER_1_0_ROOT_X86_64: $ENV{GSTREAMER_1_0_ROOT_X86_64}")
    message(STATUS "  GSTREAMER_ROOT_X86_64: $ENV{GSTREAMER_ROOT_X86_64}")
  else()
    message(STATUS "  GSTREAMER_1_0_ROOT_X86: $ENV{GSTREAMER_1_0_ROOT_X86}")
    message(STATUS "  GSTREAMER_ROOT_X86: $ENV{GSTREAMER_ROOT_X86}")
  endif()
  
  message(STATUS "Include directories found:")
  message(STATUS "  GSTREAMER_gst_INCLUDE_DIR: ${GSTREAMER_gst_INCLUDE_DIR}")
  message(STATUS "  GSTREAMER_glib_INCLUDE_DIR: ${GSTREAMER_glib_INCLUDE_DIR}")
  message(STATUS "  GSTREAMER_glibconfig_INCLUDE_DIR: ${GSTREAMER_glibconfig_INCLUDE_DIR}")
  
  message(STATUS "Libraries found:")
  message(STATUS "  GSTREAMER_gstreamer_LIBRARY: ${GSTREAMER_gstreamer_LIBRARY}")
  message(STATUS "  GSTREAMER_base_LIBRARY: ${GSTREAMER_base_LIBRARY}")
  message(STATUS "  GSTREAMER_app_LIBRARY: ${GSTREAMER_app_LIBRARY}")
  message(STATUS "  GSTREAMER_riff_LIBRARY: ${GSTREAMER_riff_LIBRARY}")
  message(STATUS "  GSTREAMER_video_LIBRARY: ${GSTREAMER_video_LIBRARY}")
  message(STATUS "  GSTREAMER_audio_LIBRARY: ${GSTREAMER_audio_LIBRARY}")
  message(STATUS "  GSTREAMER_pbutils_LIBRARY: ${GSTREAMER_pbutils_LIBRARY}")
  message(STATUS "  GSTREAMER_glib_LIBRARY: ${GSTREAMER_glib_LIBRARY}")
  message(STATUS "  GSTREAMER_gobject_LIBRARY: ${GSTREAMER_gobject_LIBRARY}")
else()
  message(STATUS "PkgConfig modules found:")
  message(STATUS "  GSTREAMER_base_FOUND: ${GSTREAMER_base_FOUND}")
  message(STATUS "  GSTREAMER_app_FOUND: ${GSTREAMER_app_FOUND}")
  message(STATUS "  GSTREAMER_riff_FOUND: ${GSTREAMER_riff_FOUND}")
  message(STATUS "  GSTREAMER_pbutils_FOUND: ${GSTREAMER_pbutils_FOUND}")
  message(STATUS "  GSTREAMER_video_FOUND: ${GSTREAMER_video_FOUND}")
  message(STATUS "  GSTREAMER_audio_FOUND: ${GSTREAMER_audio_FOUND}")
endif()

if(HAVE_GSTREAMER)
  message(STATUS "✓ GStreamer ${GSTREAMER_VERSION} found successfully!")
  message(STATUS "Include directories: ${GSTREAMER_INCLUDE_DIRS}")
  message(STATUS "Libraries: ${GSTREAMER_LIBRARIES}")
  
  # Create a simple test program
  file(WRITE ${CMAKE_BINARY_DIR}/gstreamer_test.cpp
"#include <gst/gst.h>
#include <iostream>

int main(int argc, char *argv[]) {
    gst_init(&argc, &argv);
    
    std::cout << \"GStreamer initialized successfully!\" << std::endl;
    std::cout << \"GStreamer version: \" << gst_version_string() << std::endl;
    
    // Test basic functionality
    GstElement *pipeline = gst_pipeline_new(\"test-pipeline\");
    if (pipeline) {
        std::cout << \"✓ Pipeline creation successful\" << std::endl;
        gst_object_unref(pipeline);
    } else {
        std::cout << \"✗ Pipeline creation failed\" << std::endl;
        return 1;
    }
    
    gst_deinit();
    std::cout << \"✓ All GStreamer tests passed!\" << std::endl;
    return 0;
}")

  # Create the test executable
  add_executable(gstreamer_test ${CMAKE_BINARY_DIR}/gstreamer_test.cpp)
  target_include_directories(gstreamer_test PRIVATE ${GSTREAMER_INCLUDE_DIRS})
  target_link_libraries(gstreamer_test ${GSTREAMER_LIBRARIES})
  
  # Add compiler definitions
  target_compile_definitions(gstreamer_test PRIVATE HAVE_GSTREAMER)
  
  # Add a custom target to run the test
  add_custom_target(run_gstreamer_test
    COMMAND gstreamer_test
    DEPENDS gstreamer_test
    COMMENT "Running GStreamer library test"
  )
  
  message(STATUS "Test executable 'gstreamer_test' created.")
  message(STATUS "Run 'make run_gstreamer_test' to execute the test.")
  
else()
  message(WARNING "✗ GStreamer libraries not found!")
  message(STATUS "Make sure GStreamer development packages are installed:")
  if(WIN32)
    message(STATUS "  - Download GStreamer development libraries from https://gstreamer.freedesktop.org/")
    message(STATUS "  - Set GSTREAMER_ROOT or GSTREAMER_DIR environment variable")
  else()
    message(STATUS "  Ubuntu/Debian: sudo apt-get install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev")
    message(STATUS "  CentOS/RHEL: sudo yum install gstreamer1-devel gstreamer1-plugins-base-devel")
    message(STATUS "  Fedora: sudo dnf install gstreamer1-devel gstreamer1-plugins-base-devel")
    message(STATUS "  macOS: brew install gstreamer gst-plugins-base")
  endif()
  
  # Create a dummy target so the build doesn't fail
  add_custom_target(gstreamer_test_dummy
    COMMAND ${CMAKE_COMMAND} -E echo "GStreamer not found - cannot create test"
    COMMENT "GStreamer test skipped"
  )
endif()

message(STATUS "=== End GStreamer Detection ===")

# Summary
if(HAVE_GSTREAMER)
  message(STATUS "🎉 SUCCESS: All required GStreamer components found and ready to use!")
else()
  message(STATUS "❌ FAILURE: GStreamer setup incomplete. Please install missing components.")
endif()