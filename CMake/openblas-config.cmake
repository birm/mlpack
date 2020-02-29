# - Nuget specific OpenBLAS cmake file
#
# Copyright 2009 Kitware, Inc.
# Copyright 2009-2011 Philip Lowman <philip@yhbt.com>
# Copyright 2008 Esben Mose Hansen, Ange Optimization ApS
# Copyright Guillaume Dumont, 2014 [https://github.com/willyd]
# Copyright Bonsai AI, 2015 [http://bonsai.ai]
#
# Distributed under the OSI-approved BSD License (the "License");
# see accompanying file Copyright.txt for details.
#

if(NOT DEFINED openblas_STATIC)
  # look for global setting
  if(NOT DEFINED BUILD_SHARED_LIBS OR BUILD_SHARED_LIBS)
    option (openblas_STATIC "Link to static openblas name" OFF)
  else()
    option (openblas_STATIC "Link to static openblas name" ON)
  endif()
endif()

# Determine architecture
if (CMAKE_CL_64)
  set (MSVC_ARCH x64)
else ()
  set (MSVC_ARCH Win32)
endif ()

get_filename_component (CMAKE_CURRENT_LIST_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)

add_library(openblas_static_lib STATIC IMPORTED)
set_target_properties(openblas_static_lib PROPERTIES
  IMPORTED_LOCATION ${CMAKE_CURRENT_LIST_DIR}/build/native/lib/${MSVC_ARCH}/int32/static/libopenblas.a
  IMPORTED_LINK_INTERFACE_LANGUAGES "CXX"
)

add_library(openblas_shared_lib SHARED IMPORTED)
set_target_properties(openblas_shared_lib PROPERTIES 
  IMPORTED_LOCATION ${CMAKE_CURRENT_LIST_DIR}/build/native/bin/${MSVC_ARCH}/int32/dynamic/libopenblas.dll
  IMPORTED_IMPLIB ${CMAKE_CURRENT_LIST_DIR}/build/native/lib/${MSVC_ARCH}/int32/dynamic/libopenblas.dll.a
)

set(openblas_INCLUDE_DIR "${CMAKE_CURRENT_LIST_DIR}/build/native/include")
set(OpenBLAS_INCLUDE_DIR "${CMAKE_CURRENT_LIST_DIR}/build/native/include")
set(openblas_INCLUDE_DIRS "${CMAKE_CURRENT_LIST_DIR}/build/native/include")

if (openblas_STATIC)
    set (openblas_LIBRARY openblas_static_lib)
    # Caffe doesn't spell out library and instead uses LIB
    set (OpenBLAS_LIB openblas_static_lib)
    set (openblas_LIBRARIES openblas_static_lib)
else ()
    set (openblas_LIBRARY openblas_shared_lib)
    # Caffe doesn't spell out library and instead uses LIB
    set (OpenBLAS_LIB openblas_shared_lib)
    set (openblas_LIBRARIES openblas_shared_lib)
endif()

# The following macro copies DLLs to output.
macro(openblas_copy_shared_libs target)
    if (NOT openblas_STATIC)
        add_custom_command( TARGET ${target} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
            $<TARGET_PROPERTY:openblas_shared_lib,IMPORTED_LOCATION>
            $<TARGET_FILE_DIR:${target}>
        )
        add_custom_command( TARGET ${target} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
            $<TARGET_FILE_DIR:openblas_shared_lib>/libgcc_s_seh-1.dll
            $<TARGET_FILE_DIR:${target}>
        )
        add_custom_command( TARGET ${target} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
            $<TARGET_FILE_DIR:openblas_shared_lib>/libgfortran-3.dll
            $<TARGET_FILE_DIR:${target}>
        )
        add_custom_command( TARGET ${target} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
            $<TARGET_FILE_DIR:openblas_shared_lib>/libquadmath-0.dll
            $<TARGET_FILE_DIR:${target}>
        )
    endif()
endmacro()

mark_as_advanced(openblas_INCLUDE_DIR)
