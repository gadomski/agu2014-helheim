# Variables
PDAL_BUILD_DIR = .pdal-build
PDAL = $(PDAL_BUILD_DIR)/bin/pdal
CPD_BUILD_DIR = .cpd-build
CPD_LIB = $(CPD_BUILD_DIR)/lib/libcpd64.dylib


# Top-level targets
pdal: $(PDAL)
.PHONY: pdal

cpd: $(CPD_LIB)
.PHONY: cpd
