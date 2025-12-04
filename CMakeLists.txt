cmake_minimum_required(VERSION 3.24)
project(GDPlayerControllers)

file(GLOB SOURCES cpp/*)
add_subdirectory(godot-cpp)
add_library(${PROJECT_NAME} SHARED ${SOURCES})
target_link_libraries(${PROJECT_NAME} PRIVATE godot-cpp)
