cmake_minimum_required(VERSION 2.8)
PROJECT(csv2lmdb)
SET(EXECUTABLE_OUTPUT_PATH ${CMAKE_CURRENT_LIST_DIR}/bin)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")

#OpenCV
FIND_PACKAGE( OpenCV REQUIRED )
link_directories ( ${OpenCV_LIB_DIR} 
					/home/ozh/share/caffe/build/lib)

FIND_PACKAGE( CUDA REQUIRED )

INCLUDE_DIRECTORIES( /home/ozh/share/caffe/build/include 
					/home/ozh/share/caffe/include 
					/usr/local/cuda-9.0/include/ 
					/home/ozh/share/caffe/src)

ADD_EXECUTABLE(csv2lmdb ../main.cpp)
TARGET_LINK_LIBRARIES(csv2lmdb ${OpenCV_LIBS} caffe protobuf boost_system glog lmdb)