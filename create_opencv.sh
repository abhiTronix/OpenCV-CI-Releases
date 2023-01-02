#!/bin/sh

# Copyright (c) 2019-2020 Abhishek Thakur(@abhiTronix) <abhi.una12@gmail.com>

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#    http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

######################################
#        CI Custom OpenCV Builds     #
######################################

# set -o errexit

echo "Installing OpenCV..."

#determining system Python suffix and  version
PYTHONSUFFIX=$(python -c 'import platform; a = platform.python_version(); print(".".join(a.split(".")[:2]))')
PYTHONVERSION=$(python -c 'import platform; print(platform.python_version())')

echo "Installing OpenCV Dependencies..."

sudo add-apt-repository universe

sudo apt-get install -y -qq --allow-unauthenticated build-essential cmake pkg-config gfortran libavutil-dev ffmpeg

sudo apt-get install -y -qq --allow-unauthenticated yasm libv4l-dev libgtk-3-dev libtbb-dev libavresample-dev

sudo apt-get install -y -qq --allow-unauthenticated libavcodec-dev libavformat-dev libswscale-dev libopenexr-dev

sudo apt-get install -y -qq --allow-unauthenticated libxvidcore-dev libx264-dev libatlas-base-dev libtiff5-dev python3-dev liblapacke-dev

sudo apt-get install -y -qq --allow-unauthenticated zlib1g-dev libjpeg-dev checkinstall libwebp-dev libpng-dev libopenblas-dev libopenblas-base

sudo apt-get install -y -qq --allow-unauthenticated libgstreamer1.0-0 libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev 

sudo apt-get install -y -qq --allow-unauthenticated gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-doc gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-gtk3 gstreamer1.0-qt5 gstreamer1.0-pulseaudio

echo "Installing OpenCV Library"

export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH

cd $HOME

wget -qq -O opencv.zip https://github.com/opencv/opencv/archive/master.zip
wget -qq -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/master.zip

unzip -qq opencv.zip
unzip -qq opencv_contrib.zip

mv opencv-master opencv
mv opencv_contrib-master opencv_contrib

rm opencv.zip
rm opencv_contrib.zip

cd $HOME/opencv
mkdir build
cd build

#PYTHON2_INCLUDE=$(python2 -c "from sysconfig import get_paths as gp; print(gp()['include'])")
PYTHON3_INCLUDE=$(python -c "from sysconfig import get_paths as gp; print(gp()['include'])")
#PYTHON2_LIB=$(python2 -c "import distutils.sysconfig as sysconfig; import os; print(os.path.join('/usr/lib/x86_64-linux-gnu/', sysconfig.get_config_var('LDLIBRARY')))")
PYTHON3_LIB=$(python -c "import distutils.sysconfig as sysconfig; import os; print(os.path.join('/usr/lib/x86_64-linux-gnu/', sysconfig.get_config_var('LDLIBRARY')))")
#-DPYTHON2_LIBRARY=$PYTHON2_LIB -DPYTHON3_LIBRARY=$PYTHON3_LIB -DPYTHON2_INCLUDE_DIR=$PYTHON2_INCLUDE -DPYTHON3_INCLUDE_DIR=$PYTHON3_INCLUDE \
cmake -DCMAKE_BUILD_TYPE=RELEASE -DOPENCV_EXTRA_MODULES_PATH=$HOME/opencv_contrib/modules \
	-DCMAKE_INSTALL_PREFIX=/usr/local -DINSTALL_PYTHON_EXAMPLES=OFF -DBUILD_DOCS=OFF -DBUILD_EXAMPLES=OFF \
	-DBUILD_TESTS=OFF -DBUILD_PERF_TESTS=OFF -DBUILD_opencv_java=OFF -DWITH_LIBV4L=0N -DWITH_V4L=ON -DBUILD_JPEG=ON \
	-DPYTHON_DEFAULT_EXECUTABLE=$(which python) -DOPENCV_SKIP_PYTHON_LOADER=ON \
	-DPYTHON3_LIBRARY=$PYTHON3_LIB -DPYTHON3_INCLUDE_DIR=$PYTHON3_INCLUDE \
	-DOPENCV_GENERATE_PKGCONFIG=YES -DBUILD_opencv_java=OFF -DWITH_TBB=ON ..
make -j$(nproc)
sudo make install
sudo ldconfig

sudo ln -s /usr/local/lib/python$PYTHONSUFFIX/site-packages/*.so /opt/hostedtoolcache/Python/$PYTHONVERSION/x64/lib/python$PYTHONSUFFIX/site-packages
sudo ldconfig

OPENCV_VERSION=$(python -c 'import cv2; print(cv2.__version__)')

echo "Building Binaries"

echo " OpenCV version $OPENCV_VERSION

(OpenCV Travis CLI Builds)

OpenCV (Open Source Computer Vision Library) is released under a BSD license and hence it’s free for both academic and commercial use. It has C++, Python and Java interfaces and supports Windows, Linux, Mac OS, iOS and Android. OpenCV was designed for computational efficiency and with a strong focus on real-time applications. Written in optimized C/C++, the library can take advantage of multi-core processing. Enabled with OpenCL, it can take advantage of the hardware acceleration of the underlying heterogeneous compute platform. " >description-pak

echo | sudo checkinstall -D --install=no --pkgname=opencv --pkgversion=$OPENCV_VERSION --provides=opencv --nodoc --backup=no --maintainer=abhi.una12@gmail.com --exclude=$HOME

CV_PATHNAME=OpenCV-$OPENCV_VERSION-$(python -c 'import platform; print(platform.python_version())').deb

sudo mv $(ls *.deb) $CV_PATHNAME

# assets name-path
echo "OPENCV_NAME=$CV_PATHNAME" >>$GITHUB_ENV
echo "OPENCV_PATHNAME=$HOME/opencv/build/$CV_PATHNAME" >>$GITHUB_ENV

echo "Built OpenCV version: $OPENCV_VERSION"

echo "Done Building Binaries...!!!"
