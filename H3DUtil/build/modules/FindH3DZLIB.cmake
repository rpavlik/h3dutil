# - Find zlib
# Find the native ZLIB headers and libraries.
# If none is found for Windows use the distributed one in External
#
#  ZLIB_INCLUDE_DIR -  where to find zlib.h, etc.
#  ZLIB_LIBRARIES    - List of libraries when using zlib.
#  ZLIB_FOUND        - True if zlib found.


if(H3DZLIB_FIND_REQUIRED)
	find_package(ZLIB REQUIRED)
else()
	find_package(ZLIB)
endif()

if(CMAKE_CL_64)
	set(LIB "lib64")
else()
	set(LIB "lib32")
endif()

if(NOT ZLIB_FOUND AND WIN32)
	get_filename_component(module_file_path
		${CMAKE_CURRENT_LIST_FILE}
		PATH)
	# Look for the header file.
	find_path(ZLIB_INCLUDE_DIR
		NAMES
		zlib.h
		PATHS
		$ENV{H3D_EXTERNAL_ROOT}/include
		$ENV{H3D_EXTERNAL_ROOT}/include/zlib
		$ENV{H3D_ROOT}/../External/include
		$ENV{H3D_ROOT}/../External/include/zlib
		../../External/include
		../../External/include/zlib
		${module_file_path}/../../../External/include
		${module_file_path}/../../../External/include/zlib
		DOC
		"Path in which the file zlib.h is located.")

	# Look for the library.
	find_library(ZLIB_LIBRARY
		NAMES
		zlib
		PATHS
		$ENV{H3D_EXTERNAL_ROOT}/${LIB}
		$ENV{H3D_ROOT}/../External/${LIB}
		../../External/${LIB}
		${module_file_path}/../../../External/${LIB}
		DOC
		"Path to zlib library.")

	if(ZLIB_INCLUDE_DIR AND ZLIB_LIBRARY)
		set(ZLIB_FOUND 1)
		set(ZLIB_LIBRARIES ${ZLIB_LIBRARY})
		set(ZLIB_INCLUDE_DIR ${ZLIB_INCLUDE_DIR})
	endif()
endif()

# Report the results.
if(NOT ZLIB_FOUND)
	set(ZLIB_DIR_MESSAGE
		"ZLIB was not found. Make sure ZLIB_LIBRARY and ZLIB_INCLUDE_DIR are set if compressed files support is desired.")
	if(H3DZLIB_FIND_REQUIRED)
		set(LIB_DIR_MESSAGE
			"ZLIB was not found. Make sure ZLIB_LIBRARY and ZLIB_INCLUDE_DIR are set. ZLIB is required to build.")
		message(FATAL_ERROR "${ZLIB_DIR_MESSAGE}")
	elseif(NOT H3DZLIB_FIND_QUIETLY)
		message(STATUS "${LIB_DIR_MESSAGE}")
	endif()
endif()

mark_as_advanced(ZLIB_INCLUDE_DIR ZLIB_LIBRARY)
