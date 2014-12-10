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
GPS_DIR = ../gps
ARCHIVE_DIR = _archive

R_DIR = R
MAGNITUDE_SCRIPT = $(R_DIR)/magnitude.R
VELOCITY_PLOT_SCRIPT = $(R_DIR)/velocities.R
COMARISON_SCRIPT = $(R_DIR)/comparison.R

LASFILE_MANIFEST = $(BUILDOUT_DIR)/MANIFEST.txt
CONFIG_FILE = $(BUILDOUT_DIR)/config.mk
CROP_DIR = $(BUILDOUT_DIR)/crop
CHANGE_DIR = $(BUILDOUT_DIR)/change
MAGNITUDE_DIR = $(BUILDOUT_DIR)/magnitude
GPS_COMPARISON_CSV = $(BUILDOUT_DIR)/gps-comparison.csv
GPS_CSV = $(BUILDOUT_DIR)/$(GPS_STATION).csv
TARBALL_NAME = $(ARCHIVE_DIR)/$(BUILDOUT_DIR).tgz

NUMEIG = 0
TOL = 1e-05
OUTLIERS = 0.1
BETA = 2
LAMBDA = 3
AUTO_Z_EXAGGERATION = false
CHIP = false
PLOT_FILE_EXTENSION = eps
MINX = MUST_BE_SET_IN_BUILDOUT_CONFIG
MAXX = MUST_BE_SET_IN_BUILDOUT_CONFIG
MINY = MUST_BE_SET_IN_BUILDOUT_CONFIG
MINY = MUST_BE_SET_IN_BUILDOUT_CONFIG
MINZ = -10000
MAXZ = 10000
MINMAGNITUDE = MUST_BE_SET_IN_BUILDOUT_CONFIG
MAXMAGNITUDE = MUST_BE_SET_IN_BUILDOUT_CONFIG
GPS_STATION = MUST_BE_SET_IN_BUILDOUT_CONFIG
CHIP_CAPACITY = 8000
CHIP_BUFFER = 50
VELOCITY_IMG = $(BUILDOUT_DIR)/velocities.$(PLOT_FILE_EXTENSION)

include $(CONFIG_FILE)

BOUNDS = "([$(MINX),$(MAXX)],[$(MINY),$(MAXY)],[$(MINZ),$(MAXZ)])"
PDAL_CPD_BASE_ARGS =  --numeig $(NUMEIG) --tol $(TOL) --auto-z-exaggeration $(AUTO_Z_EXAGGERATION) --outliers $(OUTLIERS) --beta $(BETA) --lambda $(LAMBDA) --bounds $(BOUNDS)
PDAL_CPD_ARGS = $(PDAL_CPD_BASE_ARGS)
PDAL_CPD_CHIP_ARGS = $(PDAL_CPD_BASE_ARGS) --chipped true --chip-capacity $(CHIP_CAPACITY) --chip-buffer $(CHIP_BUFFER)

PRODUCTS = $(CHANGE_DIR) $(CROP_DIR) $(MAGNITUDE_DIR) $(VELOCITY_IMG) $(GPS_COMPARISON_CSV) $(GPS_CSV)
STANDARD_BUILDOUT_DEPENDENCIES = Makefile $(CONFIG_FILE) $(LASFILE_MANIFEST)


#
# Default target
#
all: crop change magnitude velocity-plot gps-comparison-csv archive
.PHONY: all

setup: $(LASFILE_MANIFEST) $(CONFIG_FILE)
	@echo "Buildout directory $(BUILDOUT_DIR) setup succesfully. Now go fill in the config and the manifest."
.PHONY: setup

$(LASFILE_MANIFEST): | $(BUILDOUT_DIR)
	touch $(LASFILE_MANIFEST)

$(CONFIG_FILE): | $(BUILDOUT_DIR)
	printf "MINX = CONFIGURE_ME\nMAXX = CONFIGURE_ME\nMINY = CONFIGURE_ME\nMAXY = CONFIGURE_ME\nGPS_STATION = CONFIGURE_ME\nMINMAGNITUDE = CONFIGURE_ME\nMAXMAGNITUDE = CONFIGURE_ME" > $(CONFIG_FILE)

clean:
	rm -rf $(PRODUCTS) $(TARBALL_NAME)
.PHONY: clean

archive: crop change magnitude velocity-plot gps-comparison-csv | $(ARCHIVE_DIR)
	mkdir -p $(dir $(TARBALL_NAME))
	tar czvf $(TARBALL_NAME) $(BUILDOUT_DIR)
.PHONY: archive


# Buildout
# Includes crop, change, and magnitude
include $(BUILDOUT_DIR)/targets.mk
$(BUILDOUT_DIR)/targets.mk: targets-from-config $(STANDARD_BUILDOUT_DEPENDENCIES)
	rm -f $@
	./targets-from-config "$(LASFILE_MANIFEST)" "$(LASFILE_DIR)" "$(CHIP)" > $@

$(GPS_CSV): corresponding-gps-points $(STANDARD_BUILDOUT_DEPENDENCIES) | $(BUILDOUT_DIR)
	rm -f $@
	./corresponding-gps-points "$(LASFILE_MANIFEST)" "$(GPS_DIR)/$(GPS_STATION).csv" > $@

velocity-plot: $(VELOCITY_IMG)
.PHONY: velocity-plot

$(VELOCITY_IMG): $(GPS_CSV) change | $(BUILDOUT_DIR)
	rscript $(VELOCITY_PLOT_SCRIPT) $< $(CHANGE_DIR) $@

gps-comparison-csv: $(GPS_COMPARISON_CSV)
.PHONY: gps-comparison-csv

$(GPS_COMPARISON_CSV): $(GPS_CSV) change | $(BUILDOUT_DIR)
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

$(CROP_DIR): | $(BUILDOUT_DIR)
	mkdir $@

$(MAGNITUDE_DIR): | $(BUILDOUT_DIR)
	mkdir $@

$(SEGMENT_DIR): | $(BUILDOUT_DIR)
	mkdir $@

$(ARCHIVE_DIR):
	mkdir $@

$(BUILDOUT_DIR):
	mkdir -p $@
