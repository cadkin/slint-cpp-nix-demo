cmake_minimum_required(VERSION 3.21)
project(my_application LANGUAGES CXX)

find_package(Slint REQUIRED)
find_package(OpenGL REQUIRED)

add_executable(my_application main.cpp)
slint_target_sources(my_application scene.slint)
target_link_libraries(my_application PRIVATE Slint::Slint OpenGL::GL)

install(TARGETS my_application)
