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

set -e

sudo apt-get install -y -qq --allow-unauthenticated build-essential gfortran cmake

echo "Testing GStreamer configuration..."

sudo apt-get install -y --allow-unauthenticated libgstreamer1.0-dev libunwind-dev libgstreamer-plugins-base1.0-dev

echo "changing test directory for GStreamer..."
cd test_gstreamer
cmake .
if [ $? -ne 0 ]; then
	echo "GStreamer test failed, exiting..."
	exit 1
fi

echo "GStreamer test completed successfully."