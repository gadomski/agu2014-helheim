#
# Variables
#
SHELL = /bin/bash
COMMON_CMAKE_ARGS = -G Ninja -DCMAKE_BUILD_TYPE=Release
BUILD_CMD = ninja

# Software
CPD_BUILD_DIR = .cpd-build
CPD_DEBUG_OUTPUT = TRUE
CPD_LIB = $(CPD_BUILD_DIR)/lib/libcpd64.dylib
CPD_SOURCE_DIR = /Users/gadomski/Repos/cpd
CPD_CMAKE_ARGS = -DBUILD_CLI=FALSE \
				 -DBUILD_DEBUG_OUTPUT=$(CPD_DEBUG_OUTPUT) \
				 -DBUILD_64BIT=TRUE

PDAL_BUILD_DIR = .pdal-build
PDAL_DRIVER_PATH = $(PDAL_BUILD_DIR)/lib
PDAL_EXE = PDAL_DRIVER_PATH=$(PDAL_DRIVER_PATH) $(PDAL_BUILD_DIR)/bin/pdal
PDAL_CPD_PLUGIN = $(PDAL_BUILD_DIR)/lib/pdal_plugin_kernel_cpd.dylib
PDAL_SOURCE_DIR = /Users/gadomski/Repos/PDAL
PDAL_CMAKE_ARGS = -DBUILD_PLUGIN_CPD=TRUE \
				  -DCPD_INCLUDE_DIR=$(CPD_SOURCE_DIR)/include \
				  -DCPD_LIBRARY=$(CURDIR)/$(CPD_LIB) \
				  -DBUILD_PLUGIN_PGPOINTCLOUD=FALSE

# Buildout
BUILDOUT_DIR = default
LASFILE_DIR = ../las/1m

R_DIR = R
MAGNITUDE_SCRIPT = $(R_DIR)/magnitude.R
VELOCITY_PLOT_SCRIPT = $(R_DIR)/velocities.R
COMARISON_SCRIPT = $(R_DIR)/comparison.R

LASFILE_MANIFEST = $(BUILDOUT_DIR)/MANIFEST.txt
CONFIG_FILE = $(BUILDOUT_DIR)/config.mk
CROP_DIR = $(BUILDOUT_DIR)/crop
CHANGE_DIR = $(BUILDOUT_DIR)/change
MAGNITUDE_DIR = $(BUILDOUT_DIR)/magnitude
VELOCITY_IMG = $(BUILDOUT_DIR)/velocities.png
GPS_COMPARISON_CSV = $(BUILDOUT_DIR)/gps-comparison.csv

NUMEIG = 0
TOL = 1e-05
MINX = MUST_BE_SET_IN_SUBFOLDER
MAXX = MUST_BE_SET_IN_SUBFOLDER
MINY = MUST_BE_SET_IN_SUBFOLDER
MINY = MUST_BE_SET_IN_SUBFOLDER
MINZ = -10000
MAXZ = 10000

include $(CONFIG_FILE)

BOUNDS = "([$(MINX),$(MAXX)],[$(MINY),$(MAXY)],[$(MINZ),$(MAXZ)])"
PDAL_CPD_ARGS = --bounds $(BOUNDS) --numeig $(NUMEIG) --tol $(TOL)


#
# Default target
#
all: crop change magnitude velocity-plot gps-comparison-csv
.PHONY: all

setup: $(LASFILE_MANIFEST) $(CONFIG_FILE)
	@echo "Buildout directory $(BUILDOUT_DIR) setup succesfully. Now go fill in the config and the manifest."
.PHONY: setup

$(LASFILE_MANIFEST): | $(BUILDOUT_DIR)
	touch $(LASFILE_MANIFEST)

$(CONFIG_FILE): | $(BUILDOUT_DIR)
	printf "MINX =\nMAXX =\nMINY =\nMAXY =" > $(CONFIG_FILE)

clean:
	rm -rf $(BUILDOUT_DIR)


# Buildout
# Includes crop, change, and magnitude
include $(BUILDOUT_DIR)/targets.mk
$(BUILDOUT_DIR)/targets.mk: Makefile targets-from-config $(LASFILE_MANIFEST)
	rm -f $@
	./targets-from-config "$(LASFILE_MANIFEST)" "$(LASFILE_DIR)" > $@

velocity-plot: $(VELOCITY_IMG)
.PHONY: velocity-plot

$(VELOCITY_IMG): change | $(BUILDOUT_DIR)
	rscript $(VELOCITY_PLOT_SCRIPT) $< $(CHANGE_DIR) $@

gps-comparison-csv: $(GPS_COMPARISON_CSV)
.PHONY: gps-comparison-csv

$(GPS_COMPARISON_CSV): change | $(BUILDOUT_DIR)
	rscript $(COMARISON_SCRIPT) $< $(CHANGE_DIR) $@


# Software targets
software: cpd pdal
.PHONY: software

clean-software:
	rm -rf $(CPD_BUILD_DIR) $(PDAL_BUILD_DIR)
.PHONY: clean-software

pdal: cpd $(PDAL_BUILD_DIR)/CMakeCache.txt
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

$(CHANGE_DIR): | $(BUILDOUT_DIR)
	mkdir $@

$(PNG_DIR): | $(BUILDOUT_DIR)
	mkdir $@

$(TEXT_DIR): | $(BUILDOUT_DIR)
	mkdir $@

$(VELOCITY_DIR): | $(BUILDOUT_DIR)
	mkdir $@

$(BUILDOUT_DIR):
	mkdir $@
