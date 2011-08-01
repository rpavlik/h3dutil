# - Find TEEM
# Find the native TEEM headers and libraries.
#
#  TEEM_INCLUDE_DIR -  where to find TEEM.h, etc.
#  TEEM_LIBRARIES    - List of libraries when using TEEM.
#  TEEM_FOUND        - True if TEEM found.
#
#  In the future when the teem library fixes their CMakeLists.txt so that
#  the moss library is installed correctly then it is possible to rename
#  this module into FindTeemH3D (or something) and use the syntax below
#  to try to find TEEM. The CMakeLists.txt for MedX3D would have to be changed
#  to call the new module name instead to avoid conflicts.
#  FIND_PATH(TEEM_DIR NAMES TEEMUse.cmake
#                   PATHS /usr/local/lib/TEEM-1.9 )
#  MARK_AS_ADVANCED(TEEM_DIR)
#
#  IF( TEEM_DIR )
#    FIND_PACKAGE( TEEM )
#    IF( TEEM_FOUND )
#      INCLUDE( ${TEEM_USE_FILE} )
#    ELSE( TEEM_FOUND )
#      #Try to find libraries like the code below.
#    ENDIF( TEEM_FOUND
#  ENDIF( TEEM_DIR )
#
#
#

set(TEEM_BZIP2
	"NO"
	CACHE
	BOOL
	"If teem is built with bz2 support then this variable should be set to ON.")
set(TEEM_PNG
	"NO"
	CACHE
	BOOL
	"If teem is built with png support then this variable should be set to ON.")
set(TEEM_ZLIB
	"NO"
	CACHE
	BOOL
	"If teem is built with zlib support then this variable should be set to ON.")

mark_as_advanced(TEEM_BZIP2)
mark_as_advanced(TEEM_PNG)
mark_as_advanced(TEEM_ZLIB)

get_filename_component(module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH)

if(CMAKE_CL_64)
	set(LIB "lib64")
else()
	set(LIB "lib32")
endif()

# Look for the header file.
find_path(TEEM_INCLUDE_DIR
	NAMES
	teem/nrrd.h
	PATHS
	$ENV{H3D_EXTERNAL_ROOT}/include
	$ENV{H3D_ROOT}/../External/include
	../../External/include
	/usr/local/include
	${module_file_path}/../../../External/include
	${module_file_path}/../../teem/include
	DOC
	"Path in which the file teem/nrrd.h is located.")
mark_as_advanced(TEEM_INCLUDE_DIR)

# Look for the library.
find_library(TEEM_LIBRARY
	NAMES
	teem
	PATHS
	$ENV{H3D_EXTERNAL_ROOT}/${LIB}
	$ENV{H3D_ROOT}/../External/${LIB}
	../../External/${LIB}
	/usr/local/lib
	${module_file_path}/../../../External/${LIB}
	${module_file_path}/../../teem/lib
	DOC
	"Path to teem library.")
mark_as_advanced(TEEM_LIBRARY)

if(TEEM_LIBRARY)
	set(FOUND_TEEM_LIBRARIES 1)
else()
	set(FOUND_TEEM_LIBRARIES 0)
endif()

if(TEEM_ZLIB)
	find_library(TEEM_Z_LIBRARY
		NAMES
		z
		PATHS
		$ENV{H3D_EXTERNAL_ROOT}/${LIB}
		$ENV{H3D_ROOT}/../External/${LIB}
		../../External/${LIB}
		/usr/lib
		${module_file_path}/../../../External/${LIB}
		${module_file_path}/../../teem/lib
		DOC
		"Path to z library.")
	mark_as_advanced(TEEM_Z_LIBRARY)
	if(NOT TEEM_Z_LIBRARY)
		set(FOUND_TEEM_LIBRARIES 0)
	endif()
endif()

if(TEEM_PNG)
	find_library(TEEM_PNG_LIBRARY
		NAMES
		png
		PATHS
		$ENV{H3D_EXTERNAL_ROOT}/${LIB}
		$ENV{H3D_ROOT}/../External/${LIB}
		../../External/${LIB}
		/usr/lib
		${module_file_path}/../../../External/${LIB}
		${module_file_path}/../../teem/lib
		DOC
		"Path to png library.")
	mark_as_advanced(TEEM_PNG_LIBRARY)
	if(NOT TEEM_PNG_LIBRARY)
		set(FOUND_TEEM_LIBRARIES 0)
	endif()
endif()

if(TEEM_BZIP2)
	find_library(TEEM_BZ2_LIBRARY
		NAMES
		bz2
		PATHS
		$ENV{H3D_EXTERNAL_ROOT}/${LIB}
		$ENV{H3D_ROOT}/../External/${LIB}
		../../External/${LIB}
		/usr/lib
		${module_file_path}/../../../External/${LIB}
		${module_file_path}/../../teem/lib
		DOC
		"Path to bz2 library.")
	mark_as_advanced(TEEM_BZ2_LIBRARY)
	if(NOT TEEM_BZ2_LIBRARY)
		set(FOUND_TEEM_LIBRARIES 0)
	endif()
endif()

# Copy the results to the output variables.
if(TEEM_INCLUDE_DIR AND FOUND_TEEM_LIBRARIES)
	set(TEEM_FOUND 1)
	set(TEEM_LIBRARIES ${TEEM_LIBRARY})

	if(TEEM_Z_LIBRARY)
		set(TEEM_LIBRARIES ${TEEM_LIBRARIES} ${TEEM_Z_LIBRARY})
	endif()
	if(TEEM_PNG_LIBRARY)
		set(TEEM_LIBRARIES ${TEEM_LIBRARIES} ${TEEM_PNG_LIBRARY})
	endif()
	if(TEEM_BZ2_LIBRARY)
		set(TEEM_LIBRARIES ${TEEM_LIBRARIES} ${TEEM_BZ2_LIBRARY})
	endif()
	if(AIR_LIBRARY)
		set(TEEM_LIBRARIES ${TEEM_LIBRARIES} ${AIR_LIBRARY})
	endif()
	if(BIFF_LIBRARY)
		set(TEEM_LIBRARIES ${TEEM_LIBRARIES} ${BIFF_LIBRARY})
	endif()

	set(TEEM_INCLUDE_DIR ${TEEM_INCLUDE_DIR})
else()
	set(TEEM_FOUND 0)
	set(TEEM_LIBRARIES)
	set(TEEM_INCLUDE_DIR)
endif()

# Report the results.
if(NOT TEEM_FOUND)
	set(TEEM_DIR_MESSAGE
		"TEEM was not found. Make sure TEEM_LIBRARY, TEEM_PNG_LIBRARY, TEEM_Z_LIBRARY, TEEM_BZ2_LIBRARY and TEEM_INCLUDE_DIR are set.")
	if(TEEM_FIND_REQUIRED)
		set(TEEM_DIR_MESSAGE
			"${TEEM_DIR_MESSAGE} Teem is required to build. Some of the libraries only need to be set if teem should have support for those features.")
		message(FATAL_ERROR "${TEEM_DIR_MESSAGE}")
	elseif(NOT TEEM_FIND_QUIETLY)
		set(TEEM_DIR_MESSAGE
			"${TEEM_DIR_MESSAGE} If you do not have the libraries you will not be able to load nrrd files. Some of the libraries only need to be set if teem should have support for those features.")
		message(STATUS "${TEEM_DIR_MESSAGE}")
	endif()
endif()
