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

echo "Downloading Version Files..."
curl https://raw.githubusercontent.com/opencv/opencv/master/modules/core/include/opencv2/core/version.hpp -o version.hpp

CURRENT_OPENCV_VERSION=$(
    python <<EOF
import CppHeaderParser
import re
cppHeader = CppHeaderParser.CppHeader("version.hpp")
headers = [re.split('\s+', h.replace('"',''))  for h in cppHeader.defines if h.startswith("CV_VERSION_")]
cl_headers = [a[1]+"." if a[0].endswith(("MAJOR", "MINOR")) else a[1] for a in headers]
print("".join(cl_headers))
EOF
)

if [ -z "${CURRENT_OPENCV_VERSION}" ]; then
    echo "Something is wrong!"
    exit 1
fi

echo "Checking any old Binaries..."

for value in 3.6 3.7 3.8 3.9; do
    echo "$Testing OpenCV for $CURRENT_OPENCV_VERSION with python-$value"
    LATEST_VERSION=$(curl -s https://api.github.com/repos/abhiTronix/OpenCV-CI-Releases/releases |
        grep "OpenCV-$CURRENT_OPENCV_VERSION-$value.*.deb" |
        grep -Eo "(http|https)://[a-zA-Z0-9./?=_%:-]*")

    if [ -z "${LATEST_VERSION}" ]; then
        echo "No Old binaries found. Continuing..."
    else
        echo "Found Latest binaries already present at: $LATEST_VERSION"
        exit 1
    fi
done
