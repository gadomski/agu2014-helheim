# Variables
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
PDAL_EXE = $(PDAL_BUILD_DIR)/bin/pdal
PDAL_SOURCE_DIR = /Users/gadomski/Repos/PDAL
PDAL_CMAKE_ARGS = -DBUILD_PLUGIN_CPD=TRUE \
				  -DCPD_INCLUDE_DIR=$(CPD_SOURCE_DIR)/include/cpd \
				  -DCPD_LIBRARY=$(CURDIR)/$(CPD_LIB) \
				  -DBUILD_PLUGIN_PGPOINTCLOUD=FALSE



# Top-level targets
pdal: $(PDAL_EXE)
.PHONY: pdal

cpd: $(CPD_LIB)
.PHONY: cpd


# Business targets
$(PDAL_EXE): $(CPD_LIB) | $(PDAL_BUILD_DIR)
	cd $(PDAL_BUILD_DIR) && \
		cmake $(PDAL_SOURCE_DIR) $(COMMON_CMAKE_ARGS) $(PDAL_CMAKE_ARGS) && \
		$(BUILD_CMD)

$(CPD_LIB): | $(CPD_BUILD_DIR)
	cd $(CPD_BUILD_DIR) && \
		cmake $(CPD_SOURCE_DIR) $(COMMON_CMAKE_ARGS) $(CPD_CMAKE_ARGS) && \
		$(BUILD_CMD)


# Directory targets
$(PDAL_BUILD_DIR):
	mkdir $@

$(CPD_BUILD_DIR):
	mkdir $@
