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

echo "Fetching current OpenCV version..."
CURRENT_OPENCV_VERSION=$(curl -s https://raw.githubusercontent.com/opencv/opencv/4.x/modules/core/include/opencv2/core/version.hpp |
    awk '/#define CV_VERSION_(MAJOR|MINOR|REVISION|STATUS)/{gsub(/"/,"",$3); v[$2]=$3}
        END{print v["CV_VERSION_MAJOR"]"."v["CV_VERSION_MINOR"]"."v["CV_VERSION_REVISION"]v["CV_VERSION_STATUS"]}')

if [ "${CURRENT_OPENCV_VERSION}" = ".." ] || [ -z "${CURRENT_OPENCV_VERSION}" ]; then
    echo "Something is wrong!"
    exit 1
fi

echo "Checking any old Binaries..."
RELEASES=$(curl -s https://api.github.com/repos/abhiTronix/OpenCV-CI-Releases/releases)

for value in 3.11 3.12 3.13 3.14; do
    echo "Testing OpenCV for $CURRENT_OPENCV_VERSION with python-$value"
    LATEST_VERSION=$(echo "$RELEASES" |
        grep "OpenCV-$CURRENT_OPENCV_VERSION-$value.*.deb" |
        grep -Eo "(http|https)://[a-zA-Z0-9./?=_%:-]*")

    if [ -z "${LATEST_VERSION}" ]; then
        echo "No Old binaries found. Continuing..."
    else
        echo "Found Latest binaries already present at: $LATEST_VERSION"
        exit 1
    fi
done
