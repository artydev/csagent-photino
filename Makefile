# =============================================================================
# CsAgentUI — Build & Distribution Makefile
#
# Two distribution modes are available:
#
#   1. STANDARD  (make publish)
#        Single-file AOT executable + Photino.Native.so alongside it.
#        Cross-platform, honest, no runtime extraction.
#        Output:  publish/<RID>/CsAgentUI  +  Photino.Native.so
#
#   2. WRAPPED   (make wrap)
#        A single self-extracting executable produced by wrapper.py.
#        Embeds CsAgentUI + Photino.Native.so, extracts to /tmp at runtime.
#        Linux-only (uses fork/execv/LD_LIBRARY_PATH), needs /tmp write access.
#        Output:  dist/CsAgentUI-wrapper
#
# Usage:
#   make publish            Standard single-file AOT publish
#   make wrap               Wrapped single self-extracting executable
#   make all                Both distributions
#   make test               Verify the published executable runs
#   make clean              Remove build/publish/dist artifacts
#   make help               Show this help
#
# Overridable variables:
#   RID=linux-x64           Runtime identifier (default: linux-x64)
#   CONFIG=Release          Build configuration
#   WRAPPER=wrapper.py      Path to the wrapper script
#   WRAP_SUPPRESS=1         Suppress Photino debug output in wrapped build
#   WRAP_STATIC=0           Statically link the wrapper (needs static libc)
# =============================================================================

# --- Configuration -----------------------------------------------------------
RID        ?= linux-x64
CONFIG     ?= Release
WRAPPER    ?= wrapper.py
WRAP_SUPPRESS ?= 1
WRAP_STATIC   ?= 0

# --- Derived paths -----------------------------------------------------------
PUBLISH_DIR := publish/$(RID)
DIST_DIR    := dist
BINARY      := CsAgentUI
NATIVE_LIB  := Photino.Native.so
WRAP_OUT    := $(DIST_DIR)/$(BINARY)-wrapper

# --- Tools -------------------------------------------------------------------
DOTNET ?= dotnet
PYTHON ?= python3
GCC    ?= gcc

# --- Phony targets -----------------------------------------------------------
.PHONY: all publish wrap test clean help

all: publish wrap
	@echo ""
	@echo "=== Both distributions built ==="
	@echo "  Standard: $(PUBLISH_DIR)/$(BINARY) + $(NATIVE_LIB)"
	@echo "  Wrapped : $(WRAP_OUT)"

# --- Standard single-file AOT publish ----------------------------------------
publish:
	@echo "=== Publishing single-file AOT ($(CONFIG)/$(RID)) ==="
	$(DOTNET) publish -c $(CONFIG) -r $(RID) --self-contained true \
		-p:PublishSingleFile=true -p:PublishAot=true \
		-o $(PUBLISH_DIR)
	@echo ""
	@echo "=== Standard distribution ready ==="
	@echo "  Executable : $(PUBLISH_DIR)/$(BINARY)"
	@echo "  Native lib : $(PUBLISH_DIR)/$(NATIVE_LIB)  (required for --desktop)"
	@echo ""
	@echo "  NOTE: $(NATIVE_LIB) must stay alongside the executable;"
	@echo "        the filename is hardcoded by Photino and cannot be renamed."

# --- Wrapped single self-extracting executable -------------------------------
wrap: publish
	@echo "=== Building wrapped single executable via $(WRAPPER) ==="
	@mkdir -p $(DIST_DIR)
	$(PYTHON) $(WRAPPER) $(PUBLISH_DIR) \
		--binary $(BINARY) \
		--native $(NATIVE_LIB) \
		--output $(WRAP_OUT) \
		$(if $(filter 1,$(WRAP_SUPPRESS)),--suppress-debug,) \
		$(if $(filter 1,$(WRAP_STATIC)),--static,)
	@echo ""
	@echo "=== Wrapped distribution ready ==="
	@echo "  Single file : $(WRAP_OUT)"
	@echo "  (self-extracts $(NATIVE_LIB) to /tmp at runtime; Linux-only)"

# --- Verify the published executable runs ------------------------------------
test: publish
	@echo "=== Testing $(PUBLISH_DIR)/$(BINARY) ==="
	@$(PUBLISH_DIR)/$(BINARY) --version
	@echo "  --version OK"
	@echo ""
	@echo "=== Testing wrapped executable (if present) ==="
	@if [ -x "$(WRAP_OUT)" ]; then \
		$(WRAP_OUT) --version; \
		echo "  wrapped --version OK"; \
	else \
		echo "  (wrapped executable not built — run 'make wrap' first)"; \
	fi

# --- Cleanup -----------------------------------------------------------------
clean:
	@echo "=== Cleaning build artifacts ==="
	rm -rf bin obj publish dist
	@echo "  Done."

# --- Help --------------------------------------------------------------------
help:
	@echo "CsAgentUI build & distribution targets:"
	@echo ""
	@echo "  make publish   Standard single-file AOT (exe + Photino.Native.so)"
	@echo "  make wrap      Wrapped single self-extracting executable"
	@echo "  make all       Build both distributions"
	@echo "  make test      Verify the published executable runs"
	@echo "  make clean     Remove build/publish/dist artifacts"
	@echo ""
	@echo "Variables: RID, CONFIG, WRAPPER, WRAP_SUPPRESS, WRAP_STATIC"
