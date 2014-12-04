# Variables
SHELL = /bin/bash
COMMON_CMAKE_ARGS = -G Ninja -DCMAKE_BUILD_TYPE=Release
BUILD_CMD = ninja

CPD_BUILD_DIR = .cpd-build
CPD_DEBUG_OUTPUT = TRUE
CPD_LIB = $(CPD_BUILD_DIR)/lib/libcpd64.dylib
CPD_SOURCE_DIR = /Users/gadomski/Repos/cpd
CPD_CMAKE_ARGS = -DBUILD_CLI=FALSE \
				 -DBUILD_DEBUG_OUTPUT=$(CPD_DEBUG_OUTPUT) \
				 -DBUILD_64BIT=TRUE

PDAL_BUILD_DIR = .pdal-build
PDAL_DRIVER_PATH = $(PDAL_BUILD_DIR)/lib
PDAL_EXE = time PDAL_DRIVER_PATH=$(PDAL_DRIVER_PATH) $(PDAL_BUILD_DIR)/bin/pdal
PDAL_CPD_PLUGIN = $(PDAL_BUILD_DIR)/lib/pdal_plugin_kernel_cpd.dylib
PDAL_SOURCE_DIR = /Users/gadomski/Repos/PDAL
PDAL_CMAKE_ARGS = -DBUILD_PLUGIN_CPD=TRUE \
				  -DCPD_INCLUDE_DIR=$(CPD_SOURCE_DIR)/include \
				  -DCPD_LIBRARY=$(CURDIR)/$(CPD_LIB) \
				  -DBUILD_PLUGIN_PGPOINTCLOUD=FALSE

LASFILE_DIR = ../las-octrees/1m
LASFILE_MANIFEST = MANIFEST.txt
MINX = 535000
MAXX = 537500
MINY = 7361000
MAXY = 7362000
MINZ = -1000
MAXZ = 10000
BOUNDS = "([$(MINX),$(MAXX)],[$(MINY),$(MAXY)],[$(MINZ),$(MAXZ)])"
NUMEIG = 100
PDAL_CPD_ARGS = --bounds $(BOUNDS) --numeig $(NUMEIG)
CHANGE_DIR = change
PNG_DIR = png
PLOT_SCRIPT = plot-magnitude.R

include change.mk

change.mk: Makefile generate
	rm -f $@
	./generate "$(LASFILE_MANIFEST)" "$(LASFILE_DIR)" > $@


# Build targets
pdal: $(PDAL_BUILD_DIR)/CMakeCache.txt
	ninja -C $(PDAL_BUILD_DIR)
.PHONY: pdal

$(PDAL_BUILD_DIR)/CMakeCache.txt: | $(PDAL_BUILD_DIR)
	cd $(PDAL_BUILD_DIR) && \
		cmake $(PDAL_SOURCE_DIR) $(COMMON_CMAKE_ARGS) $(PDAL_CMAKE_ARGS)

cpd: $(CPD_BUILD_DIR)/CMakeCache.txt
	ninja -C $(CPD_BUILD_DIR)

$(CPD_BUILD_DIR)/CMakeCache.txt: | $(CPD_BUILD_DIR)
	cd $(CPD_BUILD_DIR) && \
		cmake $(CPD_SOURCE_DIR) $(COMMON_CMAKE_ARGS) $(CPD_CMAKE_ARGS)
.PHONY: cpd


# Directory targets
$(PDAL_BUILD_DIR):
	mkdir $@

$(CPD_BUILD_DIR):
	mkdir $@

$(CHANGE_DIR):
	mkdir $@

$(PNG_DIR):
	mkdir $@
