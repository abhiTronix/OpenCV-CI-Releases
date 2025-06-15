#!/bin/bash
#
# OpenCV Automated Build Script
# Author: Abhishek Thakur (@abhiTronix) <abhi.una12@gmail.com>
# Improved by: Claude
# License: Apache License 2.0
#
# Description: This script automates the building of OpenCV from source 
# with optimized settings for CI environments.
#
# Usage: ./build_opencv.sh

# Exit on error
set -e

echo "===== OpenCV Automated Build Script ====="

#######################################
# CONFIGURATION & ENVIRONMENT SETUP
#######################################

# Determine Python details
PYTHON_SUFFIX=$(python -c 'import platform; a = platform.python_version(); print(".".join(a.split(".")[:2]))')
PYTHON_VERSION=$(python -c 'import platform; print(platform.python_version())')

echo "Detected Python version: $PYTHON_VERSION (suffix: $PYTHON_SUFFIX)"

# Save current directory
CURRENT_DIR=$(pwd)

#######################################
# DEPENDENCY INSTALLATION
#######################################

echo "Installing OpenCV dependencies..."

# Update package list
sudo apt-get update -qq

# Install build tools
echo "Installing build essentials..."
sudo apt-get install -y -qq --allow-unauthenticated build-essential gfortran cmake python3-dev
sudo apt-get install -y -qq --allow-unauthenticated pkg-config cmake-data

# Install video/codec dependencies
echo "Installing video and codec dependencies..."
sudo apt-get install -y -qq --allow-unauthenticated \
    libavutil-dev ffmpeg yasm libv4l-dev \
    libxvidcore-dev libx264-dev \
    libavcodec-dev libavformat-dev libswscale-dev libswresample-dev

# Install image format dependencies
echo "Installing image format dependencies..."
sudo apt-get install -y -qq --allow-unauthenticated \
    libtiff5-dev libjpeg-dev libpng-dev libwebp-dev libopenexr-dev

# Install math libraries
echo "Installing math libraries..."
sudo apt-get install -y -qq --allow-unauthenticated \
    libatlas-base-dev liblapacke-dev libopenblas-dev libopenblas-base

# Install GUI and parallel processing dependencies
echo "Installing GUI and parallel processing dependencies..."
sudo apt-get install -y -qq --allow-unauthenticated \
    libgtk-3-dev libtbb-dev

# Install other required dependencies
echo "Installing other dependencies..."
sudo apt-get install -y -qq --allow-unauthenticated \
    zlib1g-dev checkinstall

# Install GStreamer dependencies
echo "Installing GStreamer dependencies..."
sudo apt-get install -y -qq --allow-unauthenticated \
    libunwind-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev \
    gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly \
    gstreamer1.0-libav gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-gtk3 \
    gstreamer1.0-qt5 gstreamer1.0-pulseaudio

#######################################
# OPENCV SOURCE DOWNLOAD
#######################################

echo "Downloading OpenCV source code..."

# Main OpenCV repository
cd "$HOME"
if [ ! -d "opencv" ]; then
    git clone https://github.com/opencv/opencv.git
fi
cd opencv && git checkout 4.x && git pull

# Extra modules repository
cd "$HOME"
if [ ! -d "opencv_contrib" ]; then
    git clone https://github.com/opencv/opencv_contrib.git
fi
cd opencv_contrib && git checkout 4.x && git pull

#######################################
# OPENCV BUILD CONFIGURATION
#######################################

echo "Configuring OpenCV build..."

# Create and enter build directory
cd "$HOME/opencv"
mkdir -p build
cd build

# Get Python paths for CMake configuration
PYTHON3_INCLUDE=$(python -c "from sysconfig import get_paths as gp; print(gp()['include'])")
PYTHON3_LIB=$(python -c "import sysconfig; import os; print(os.path.join('/usr/lib/x86_64-linux-gnu/', sysconfig.get_config_var('LDLIBRARY')))")

# Check if paths were found correctly
if [ -z "$PYTHON3_INCLUDE" ] || [ -z "$PYTHON3_LIB" ]; then
    echo "ERROR: Failed to detect Python paths correctly."
    echo "PYTHON3_INCLUDE: $PYTHON3_INCLUDE"
    echo "PYTHON3_LIB: $PYTHON3_LIB"
    exit 1
fi

echo "Using Python paths:"
echo "  Include: $PYTHON3_INCLUDE"
echo "  Library: $PYTHON3_LIB"

# Configure with CMake
# Note: LIBV4L flag corrected from "DWITH_LIBV4L=0N" to "DWITH_LIBV4L=ON"
cmake -DCMAKE_BUILD_TYPE=RELEASE \
    -DOPENCV_EXTRA_MODULES_PATH="$HOME/opencv_contrib/modules" \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
    -DINSTALL_PYTHON_EXAMPLES=OFF \
    -DBUILD_DOCS=OFF \
    -DBUILD_EXAMPLES=OFF \
    -DBUILD_TESTS=OFF \
    -DBUILD_PERF_TESTS=OFF \
    -DBUILD_opencv_java=OFF \
    -DWITH_LIBV4L=ON \
    -DWITH_V4L=ON \
    -DBUILD_JPEG=ON \
    -DPYTHON_DEFAULT_EXECUTABLE=$(which python) \
    -DOPENCV_SKIP_PYTHON_LOADER=ON \
    -DWITH_GSTREAMER=ON \
    -DPYTHON3_LIBRARY="$PYTHON3_LIB" \
    -DPYTHON3_INCLUDE_DIR="$PYTHON3_INCLUDE" \
    -DOPENCV_GENERATE_PKGCONFIG=YES \
    -DWITH_TBB=ON \
    ..

#######################################
# BUILD AND INSTALL
#######################################

echo "Building OpenCV (using $(nproc) cores)..."
make -j$(nproc)

echo "Installing OpenCV..."
sudo make install
sudo ldconfig

# Create symbolic links for Python packages
SITE_PACKAGES_DIR="/usr/local/lib/python$PYTHON_SUFFIX/site-packages"
PYTHON_TARGET_DIR="/opt/hostedtoolcache/Python/$PYTHON_VERSION/x64/lib/python$PYTHON_SUFFIX/site-packages"

echo "Creating symbolic links from $SITE_PACKAGES_DIR to $PYTHON_TARGET_DIR"
if [ -d "$SITE_PACKAGES_DIR" ]; then
    sudo mkdir -p "$PYTHON_TARGET_DIR"
    sudo ln -sf "$SITE_PACKAGES_DIR"/*.so "$PYTHON_TARGET_DIR"
    sudo ldconfig
else
    echo "WARNING: Site packages directory not found: $SITE_PACKAGES_DIR"
fi

#######################################
# PACKAGE CREATION
#######################################

# Get OpenCV version
OPENCV_VERSION=$(python -c 'import cv2; print(cv2.__version__)')
echo "Successfully built OpenCV version: $OPENCV_VERSION"

echo "Creating Debian package..."

# Create package description
cat > description-pak << EOF
OpenCV version $OPENCV_VERSION

(OpenCV Travis CI Builds)

OpenCV (Open Source Computer Vision Library) is released under a BSD license and hence it's free for both academic and commercial use. It has C++, Python and Java interfaces and supports Windows, Linux, Mac OS, iOS and Android. OpenCV was designed for computational efficiency and with a strong focus on real-time applications. Written in optimized C/C++, the library can take advantage of multi-core processing. Enabled with OpenCL, it can take advantage of the hardware acceleration of the underlying heterogeneous compute platform.
EOF

# Create package using checkinstall
echo | sudo checkinstall -D --install=no \
    --pkgname=opencv \
    --pkgversion="$OPENCV_VERSION" \
    --provides=opencv \
    --nodoc \
    --backup=no \
    --maintainer=abhi.una12@gmail.com \
    --exclude="$HOME"

# Rename package to standard naming convention
CV_PATHNAME="OpenCV-$OPENCV_VERSION-$(python -c 'import platform; print(platform.python_version())').deb"
sudo mv "$(ls *.deb)" "$CV_PATHNAME"

# Set GitHub environment variables if running in GitHub Actions
echo "Setting GitHub environment variables..."
echo "OPENCV_NAME=$CV_PATHNAME" >> "$GITHUB_ENV"
echo "OPENCV_PATHNAME=$HOME/opencv/build/$CV_PATHNAME" >> "$GITHUB_ENV"

echo "Debian package created: $CV_PATHNAME"
echo "Done! OpenCV $OPENCV_VERSION has been successfully built and packaged."

# Return to original directory
cd "$CURRENT_DIR"