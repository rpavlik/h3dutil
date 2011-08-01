if(WIN32)
	cmake_minimum_required(VERSION 2.6.0)
endif()
project(H3DUtil)

# Add a cache variable GENERATE_CPACK_PROJECT to have the choice of generating a project
# for packaging H3DAPI. Default is NO since most people will not use this.
if(NOT DEFINED GENERATE_CPACK_PROJECT)
	set(GENERATE_CPACK_PROJECT
		"NO"
		CACHE
		BOOL
		"Decides if a cpack project should be generated. The project in the first loaded CMakeLists will configure CPack.")
	mark_as_advanced(GENERATE_CPACK_PROJECT)
endif()

# Add a cache variable PREFER_STATIC_LIBRARIES to have the choice of generating a project
# linking against static libraries if they exist. Default is NO since most people will not use this.
if(NOT DEFINED PREFER_STATIC_LIBRARIES)
	set(PREFER_STATIC_LIBRARIES
		"NO"
		CACHE
		BOOL
		"Decides if CMake should prefer static libraries to dynamic libraries when both exist.")
	mark_as_advanced(PREFER_STATIC_LIBRARIES)
endif()

if(PREFER_STATIC_LIBRARIES)
	set(CMAKE_FIND_LIBRARY_SUFFIXES .a;${CMAKE_FIND_LIBRARY_SUFFIXES})
endif()

set(H3DUTIL_MAJOR_VERSION 1)
set(H3DUTIL_MINOR_VERSION 1)
set(H3DUTIL_BUILD_VERSION 1)

set(H3DUTIL_FULL_VERSION
	${H3DUTIL_MAJOR_VERSION}.${H3DUTIL_MINOR_VERSION}.${H3DUTIL_BUILD_VERSION})

file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/include/H3DUtil/")
include_directories(${CMAKE_CURRENT_BINARY_DIR}/include)

# Add all sources, they are added to a variable called H3DUTIL_SRCS defined
# in the included file. All header files are added to a variable called
# H3DUTIL_HEADERS.
include(${H3DUtil_SOURCE_DIR}/H3DUtilSourceFiles.txt)

# add the H3DUtil.rc resource file if Visual Studio
if(MSVC)
	set(H3DUTIL_SRCS
		${H3DUTIL_SRCS}
		${CMAKE_CURRENT_BINARY_DIR}/H3DUtil.rc)
endif()

# add all optional libraries to this variable
set(optionalLibs)

# add all required libraries to this variable
set(requiredLibs)

set(CMAKE_MODULE_PATH ${H3DUtil_SOURCE_DIR}/modules)

find_package(FreeImage)
if(FREEIMAGE_FOUND)
	set(HAVE_FREEIMAGE 1)
	include_directories(${FREEIMAGE_INCLUDE_DIR})
	set(optionalLibs ${optionalLibs} ${FREEIMAGE_LIBRARIES})
endif()

find_package(H3DZLIB)
if(ZLIB_FOUND)
	set(HAVE_ZLIB 1)
	include_directories(${ZLIB_INCLUDE_DIR})
	set(optionalLibs ${optionalLibs} ${ZLIB_LIBRARIES})
endif()

find_package(DCMTK)
if(DCMTK_FOUND)
	set(HAVE_DCMTK 1)
	include_directories(${DCMTK_INCLUDE_DIR})
	set(requiredLibs ${requiredLibs} ${DCMTK_LIBRARIES})
endif()

find_package(TEEM)
if(TEEM_FOUND)
	set(HAVE_TEEM 1)
	include_directories(${TEEM_INCLUDE_DIR})
	set(requiredLibs ${requiredLibs} ${TEEM_LIBRARIES})
endif()

find_package(PTHREAD REQUIRED)
if(PTHREAD_FOUND)
	include_directories(${PTHREAD_INCLUDE_DIR})
	set(requiredLibs ${requiredLibs} ${PTHREAD_LIBRARIES})
endif()

# To allow other projects that use H3DUtil as a subproject to add extra include directories
# when packaging.
if(GENERATE_CPACK_PROJECT)
	if(WIN32)
		set(H3DUTIL_CPACK_INSTALLED_DIRECTORIES
			""
			CACHE
			INTERNAL
			"Installed directories of H3DUtil.")

		if(FREEIMAGE_FOUND)
			set(H3DUTIL_CPACK_INSTALLED_DIRECTORIES
				"${FREEIMAGE_INCLUDE_DIR}/..;External/include/FreeImage"
				CACHE
				INTERNAL
				"Installed directories of H3DUtil.")
		endif()

		if(ZLIB_FOUND)
			set(H3DUTIL_CPACK_INSTALLED_DIRECTORIES
				${H3DUTIL_CPACK_INSTALLED_DIRECTORIES}
				"${ZLIB_INCLUDE_DIR};External/include/zlib"
				CACHE
				INTERNAL
				"Installed directories of H3DUtil.")
		endif()

		if(PTHREAD_FOUND)
			set(H3DUTIL_CPACK_INSTALLED_DIRECTORIES
				${H3DUTIL_CPACK_INSTALLED_DIRECTORIES}
				"${PTHREAD_INCLUDE_DIR};External/include/pthread"
				CACHE
				INTERNAL
				"Installed directories of H3DUtil.")
		endif()
	endif()

	set(CPACK_PACKAGE_DESCRIPTION_SUMMARY
		"H3DUtil. Help functions and utility functions for H3D API and HAPI.")
	set(CPACK_PACKAGE_VENDOR "SenseGraphics AB")
	set(CPACK_PACKAGE_CONTACT "support@sensegraphics.com")
	#  SET(CPACK_PACKAGE_DESCRIPTION_FILE "${H3DUtil_SOURCE_DIR}/../ReadMe.txt")
	set(CPACK_RESOURCE_FILE_LICENSE "${H3DUtil_SOURCE_DIR}/../LICENSE")
	set(CPACK_INSTALL_CMAKE_PROJECTS
		"${CMAKE_CURRENT_BINARY_DIR};H3DUtil;ALL;/")
	set(CPACK_PACKAGE_INSTALL_DIRECTORY "H3DUtil")
	set(CPACK_PACKAGE_VERSION_MAJOR ${H3DUTIL_MAJOR_VERSION})
	set(CPACK_PACKAGE_VERSION_MINOR ${H3DUTIL_MINOR_VERSION})
	set(CPACK_PACKAGE_VERSION_PATCH ${H3DUTIL_BUILD_VERSION})
	set(DEBIAN_PACKAGE_DEPENDS "zlib1g-dev, libfreeimage-dev")

	include(CPack)
	include(UseDebian)
	if(DEBIAN_FOUND)
		add_debian_targets(H3DUtil)
	endif()
endif()

# H3DUtil shared library definition.
add_library(H3DUtil SHARED ${H3DUTIL_SRCS} ${H3DUTIL_HEADERS})

# make sure that the H3DUtil.rc contains the correct svn-version
if(MSVC)
	execute_process(COMMAND
		${H3DUtil_SOURCE_DIR}/FindSVNVersion
		${H3DUtil_SOURCE_DIR}/../src/.svn/entries
		OUTPUT_VARIABLE
		H3DUTIL_SVN_VERSION)
	# autogenerate H3DUtil.rc depending on the version
	configure_file(H3DUtil.rc.cmake ${CMAKE_CURRENT_BINARY_DIR}/H3DUtil.rc)
	# Add option to disable UpdateResourceFile call, ON by default if this is an svn checkout.
	# OFF if this is not an svn checkout.
	if(H3DUTIL_SVN_VERSION EQUAL 0)
		option(CallUpdateResourceFile
			"If ON then a pre build command is added to call UpdateResourceFile. This is ON if H3DUtil is a subversion checkout, OFF if it is not."
			OFF)
	else()
		option(CallUpdateResourceFile
			"If ON then a pre build command is added to call UpdateResourceFile. This is ON if H3DUtil is a subversion checkout, OFF if it is not."
			ON)
	endif()

	if(CallUpdateResourceFile)
		add_custom_command(TARGET
			H3DUtil
			PRE_BUILD
			COMMAND
			${H3DUtil_SOURCE_DIR}/UpdateResourceFile
			ARGS
			H3DUTIL
			${CMAKE_CURRENT_BINARY_DIR}/H3DUtil.rc
			${H3DUtil_SOURCE_DIR}/H3DUtil.rc.cmake
			${H3DUTIL_MAJOR_VERSION}
			${H3DUTIL_MINOR_VERSION}
			${H3DUTIL_BUILD_VERSION}
			${H3DUtil_SOURCE_DIR}/../src/.svn/entries)
	endif()
endif()

# set the install directory to the H3D directory on Windows
if(WIN32 AND CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
	set(CMAKE_INSTALL_PREFIX
		${H3DUtil_SOURCE_DIR}/../..
		CACHE
		PATH
		"Install path prefix, prepended onto install directories."
		FORCE)
endif()

set(H3DUTIL_INCLUDE_DIRS
	${H3DUtil_SOURCE_DIR}/../include
	${CMAKE_CURRENT_BINARY_DIR}/include)
set(H3DUTIL_INCLUDE_DIRS ${H3DUTIL_INCLUDE_DIRS} PARENT_SCOPE)
include_directories(${H3DUTIL_INCLUDE_DIRS})

# check all available libraries

if(WIN32)
	set(requiredLibs ${requiredLibs} winmm.lib)
endif()

# make sure symbols are exported.
set(H3DUTIL_COMPILE_FLAGS "-DH3DUTIL_EXPORTS")

# add the libraries needed for linking
target_link_libraries(H3DUtil ${requiredLibs} ${optionalLibs})

# make the name of debug libraries end in _d.
set_target_properties(H3DUtil PROPERTIES DEBUG_POSTFIX "_d")

# set the version of the library
set_target_properties(H3DUtil
	PROPERTIES
	VERSION
	${H3DUTIL_FULL_VERSION})

# change the name depending on compiler to be able to tell them apart
# since they are not compatible with each other.
if(MSVC70 OR MSVC71)
	set_target_properties(H3DUtil
		PROPERTIES
		OUTPUT_NAME
		H3DUtil_vc7
		LINK_FLAGS_DEBUG
		" /NODEFAULTLIB:msvcrt")
	set(H3DAPI_COMPILE_FLAGS "${H3DAPI_COMPILE_FLAGS} /Zc:wchar_t")
elseif(MSVC80)
	set_target_properties(H3DUtil
		PROPERTIES
		OUTPUT_NAME
		H3DUtil_vc8
		LINK_FLAGS_DEBUG
		" /NODEFAULTLIB:msvcrt")
	set(H3DUTIL_COMPILE_FLAGS
		"${H3DUTIL_COMPILE_FLAGS} -D_CRT_SECURE_NO_DEPRECATE")

	# This might be useful for visual studio 2005 users that often recompile the api.
	if(NOT DEFINED USE_VC8_MP_FLAG)
		set(USE_VC8_MP_FLAG
			"NO"
			CACHE
			BOOL
			"In visual studio 8 the MP flag exists but is not documented. Maybe it is unsafe to use. If you want to use it then set this flag to yes.")
	endif()

	if(USE_VC8_MP_FLAG)
		set(H3DUTIL_COMPILE_FLAGS "${H3DUTIL_COMPILE_FLAGS} /MP")
	endif()
elseif(MSVC90)
	set_target_properties(H3DUtil
		PROPERTIES
		OUTPUT_NAME
		H3DUtil_vc9
		LINK_FLAGS_DEBUG
		" /NODEFAULTLIB:msvcrt")
	set(H3DUTIL_COMPILE_FLAGS
		"${H3DUTIL_COMPILE_FLAGS} /MP -D_CRT_SECURE_NO_DEPRECATE")
elseif(MSVC10)
	set_target_properties(H3DUtil
		PROPERTIES
		OUTPUT_NAME
		H3DUtil_vc10
		LINK_FLAGS_DEBUG
		" /NODEFAULTLIB:msvcrt")
	set(H3DUTIL_COMPILE_FLAGS
		"${H3DUTIL_COMPILE_FLAGS} /MP -D_CRT_SECURE_NO_DEPRECATE")
elseif(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
	#used to link in dynamic library load functions. Needed by some examples in HAPI
	set_target_properties(H3DUtil PROPERTIES LINK_FLAGS "-ldl")
endif()

# set compile flags.
set_target_properties(H3DUtil
	PROPERTIES
	COMPILE_FLAGS
	"${H3DUTIL_COMPILE_FLAGS}")

# autogenerate H3DUtil.h depending on the libraries available.
set(H3DUTIL_H ${CMAKE_CURRENT_BINARY_DIR}/include/H3DUtil/H3DUtil.h)
configure_file(${H3DUtil_SOURCE_DIR}/../include/H3DUtil/H3DUtil.cmake
	"${H3DUTIL_H}")
list(APPEND H3DUTIL_HEADERS "${H3DUTIL_H}")

install(TARGETS
	H3DUtil
	LIBRARY
	DESTINATION
	lib
	RUNTIME
	DESTINATION
	bin
	ARCHIVE
	DESTINATION
	lib)

if(NOT WIN32)
	install(FILES ${H3DUTIL_HEADERS} DESTINATION include/H3DUtil)
endif()



