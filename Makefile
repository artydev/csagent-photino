# =============================================================================
# CsAgentUI — Build & Distribution Makefile
#
# Distribution modes:
#
#   1. STANDARD LINUX  (make publish)
#        Single-file AOT executable + Photino.Native.so alongside it.
#        Cross-platform, honest, no runtime extraction.
#        Output:  publish/<RID>/CsAgentUI  +  Photino.Native.so
#
#   2. WRAPPED LINUX   (make wrap)
#        A single self-extracting executable produced by wrapper.py.
#        Embeds CsAgentUI + Photino.Native.so, extracts to /tmp at runtime.
#        Linux-only (uses fork/execv/LD_LIBRARY_PATH), needs /tmp write access.
#        Output:  dist/CsAgentUI-wrapper
#        (the intermediate publish/ directory is removed after wrapping)
#
#   3. WINDOWS         (make publish-win)
#        Self-contained single-file Windows executable (non-AOT, works from
#        Linux) + Photino.Native.dll + WebView2Loader.dll.
#        Output:  publish/win-x64/CsAgentUI.exe  +  Photino.Native.dll
#                 +  WebView2Loader.dll
#
#   NOTE on Native AOT for Windows:
#     .NET Native AOT cannot cross-compile across OSes ("Cross-OS native
#     compilation is not supported"). To get a Native AOT Windows build you
#     must run the publish ON a Windows machine (or Windows CI runner).
#     See the 'publish-win-aot' target below.
#
# Usage:
#   make publish            Standard Linux single-file AOT publish
#   make wrap               Wrapped Linux single self-extracting executable
#   make publish-win        Windows self-contained single-file (non-AOT)
#   make publish-win-aot    Windows Native AOT (must run on Windows)
#   make all                Linux standard + wrapped
#   make test               Verify the published executable runs
#   make clean              Remove build/publish/dist artifacts
#   make help               Show this help
#
# Overridable variables:
#   RID=linux-x64           Runtime identifier (default: linux-x64)
#   WIN_RID=win-x64         Windows runtime identifier
#   CONFIG=Release          Build configuration
#   WRAPPER=wrapper.py      Path to the wrapper script
#   WRAP_SUPPRESS=0         Suppress ALL output in wrapped build (default OFF —
#                           keeps the TUI/CLI working; enable only for
#                           desktop-only deployments to hide Photino noise)
#   WRAP_STATIC=0           Statically link the wrapper (needs static libc)
# =============================================================================

# --- Configuration -----------------------------------------------------------
RID        ?= linux-x64
WIN_RID    ?= win-x64
CONFIG     ?= Release
WRAPPER    ?= wrapper.py
WRAP_SUPPRESS ?= 0
WRAP_STATIC   ?= 0

# --- Derived paths -----------------------------------------------------------
PUBLISH_DIR := publish/$(RID)
WIN_PUBLISH_DIR := publish/$(WIN_RID)
DIST_DIR    := dist
BINARY      := CsAgentUI
NATIVE_LIB  := Photino.Native.so
WRAP_OUT    := $(DIST_DIR)/$(BINARY)-wrapper

# --- Tools -------------------------------------------------------------------
DOTNET ?= dotnet
PYTHON ?= python3
GCC    ?= gcc

# --- Phony targets -----------------------------------------------------------
.PHONY: all publish wrap publish-win publish-win-aot test clean help

# Build both Linux distributions. 'wrap' removes the intermediate publish/
# directory, so re-run 'publish' afterwards to leave the standard distribution
# in place too.
all:
	$(MAKE) wrap
	$(MAKE) publish
	@echo ""
	@echo "=== Both Linux distributions built ==="
	@echo "  Standard: $(PUBLISH_DIR)/$(BINARY) + $(NATIVE_LIB)"
	@echo "  Wrapped : $(WRAP_OUT)"

# --- Standard Linux single-file AOT publish ----------------------------------
publish:
	@echo "=== Publishing Linux single-file AOT ($(CONFIG)/$(RID)) ==="
	$(DOTNET) publish -c $(CONFIG) -r $(RID) --self-contained true \
		-p:PublishSingleFile=true -p:PublishAot=true \
		-o $(PUBLISH_DIR)
	@echo ""
	@echo "=== Standard Linux distribution ready ==="
	@echo "  Executable : $(PUBLISH_DIR)/$(BINARY)"
	@echo "  Native lib : $(PUBLISH_DIR)/$(NATIVE_LIB)  (required for --desktop)"
	@echo ""
	@echo "  NOTE: $(NATIVE_LIB) must stay alongside the executable;"
	@echo "        the filename is hardcoded by Photino and cannot be renamed."

# --- Wrapped Linux single self-extracting executable -------------------------
wrap: publish
	@echo "=== Building wrapped Linux single executable via $(WRAPPER) ==="
	@mkdir -p $(DIST_DIR)
	$(PYTHON) $(WRAPPER) $(PUBLISH_DIR) \
		--binary $(BINARY) \
		--native $(NATIVE_LIB) \
		--output $(WRAP_OUT) \
		$(if $(filter 1,$(WRAP_SUPPRESS)),--suppress-debug,) \
		$(if $(filter 1,$(WRAP_STATIC)),--static,)
	@echo ""
	@echo "=== Removing intermediate publish directory ==="
	@rm -rf $(PUBLISH_DIR)
	@echo "  Removed $(PUBLISH_DIR)/ (CsAgentUI, CsAgentUI.dbg, $(NATIVE_LIB))"
	@echo ""
	@echo "=== Wrapped Linux distribution ready ==="
	@echo "  Single file : $(WRAP_OUT)"
	@echo "  (self-extracts $(NATIVE_LIB) to /tmp at runtime; Linux-only)"

# --- Windows self-contained single-file (non-AOT, buildable from Linux) ------
publish-win:
	@echo "=== Publishing Windows self-contained single-file ($(CONFIG)/$(WIN_RID)) ==="
	@echo "  (non-AOT: Native AOT cannot cross-compile across OSes)"
	$(DOTNET) publish -c $(CONFIG) -r $(WIN_RID) --self-contained true \
		-p:PublishSingleFile=true -p:PublishAot=false \
		-o $(WIN_PUBLISH_DIR)
	@echo ""
	@echo "=== Windows distribution ready ==="
	@echo "  Executable  : $(WIN_PUBLISH_DIR)/$(BINARY).exe"
	@echo "  Native lib  : $(WIN_PUBLISH_DIR)/Photino.Native.dll"
	@echo "  WebView2    : $(WIN_PUBLISH_DIR)/WebView2Loader.dll"
	@echo ""
	@echo "  NOTE: Windows needs BOTH Photino.Native.dll AND WebView2Loader.dll"
	@echo "        alongside the exe (WebView2 is the Windows webview engine)."
	@echo "        This is a non-AOT build (bundles the .NET runtime); for a"
	@echo "        smaller Native AOT build, run 'make publish-win-aot' ON a"
	@echo "        Windows machine."

# --- Windows Native AOT (MUST be run on a Windows machine) -------------------
publish-win-aot:
	@echo "=== Publishing Windows Native AOT ($(CONFIG)/$(WIN_RID)) ==="
	@echo "  NOTE: .NET Native AOT cannot cross-compile across OSes."
	@echo "  This target MUST be run on a Windows machine (or Windows CI)."
	@echo "  On Linux it will fail with: Cross-OS native compilation is not supported."
	$(DOTNET) publish -c $(CONFIG) -r $(WIN_RID) --self-contained true \
		-p:PublishSingleFile=true -p:PublishAot=true \
		-o $(WIN_PUBLISH_DIR)
	@echo ""
	@echo "=== Windows Native AOT distribution ready ==="
	@echo "  Executable  : $(WIN_PUBLISH_DIR)/$(BINARY).exe"
	@echo "  Native lib  : $(WIN_PUBLISH_DIR)/Photino.Native.dll"
	@echo "  WebView2    : $(WIN_PUBLISH_DIR)/WebView2Loader.dll"

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
	@echo "  make publish         Standard Linux single-file AOT (exe + Photino.Native.so)"
	@echo "  make wrap            Wrapped Linux single self-extracting executable"
	@echo "  make publish-win     Windows self-contained single-file (non-AOT, from Linux)"
	@echo "  make publish-win-aot Windows Native AOT (MUST run on a Windows machine)"
	@echo "  make all             Build both Linux distributions"
	@echo "  make test            Verify the published executable runs"
	@echo "  make clean           Remove build/publish/dist artifacts"
	@echo ""
	@echo "Variables: RID, WIN_RID, CONFIG, WRAPPER, WRAP_SUPPRESS, WRAP_STATIC"
	@echo ""
	@echo "  WRAP_SUPPRESS=1      Suppress ALL output in the wrapped build"
	@echo "                       (hides Photino debug noise, but breaks the"
	@echo "                       TUI/CLI — use only for desktop-only deploys)"
