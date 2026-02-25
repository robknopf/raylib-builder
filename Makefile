LIB_OUT_DIR := lib
INCLUDE_OUT_DIR := include
BUILD_DIR := obj
RAYLIB_REPO := https://github.com/raysan5/raylib.git
RAYLIB_INSTALL_DIR := src
RAYLIB_SRC_DIR := $(RAYLIB_INSTALL_DIR)/src
RAYLIB_EXAMPLES_DIR := $(RAYLIB_INSTALL_DIR)/examples
DEBUG_TAG := _d

DESKTOP_DEBUG_BUILD_PATH := $(BUILD_DIR)/desktop/debug
DESKTOP_RELEASE_BUILD_PATH := $(BUILD_DIR)/desktop/release
WASM_DEBUG_BUILD_PATH := $(BUILD_DIR)/wasm/debug
WASM_RELEASE_BUILD_PATH := $(BUILD_DIR)/wasm/release

# create targets for the different platforms
all: release debug

release: ensure_directories desktop_release wasm_release copy_headers
debug: ensure_directories desktop_debug wasm_debug copy_headers


wasm: wasm_debug wasm_release
wasm_debug: ensure_emcc ensure_raylib ensure_directories build_wasm_debug copy_headers
wasm_release: ensure_emcc ensure_raylib ensure_directories build_wasm_release copy_headers

desktop: desktop_debug desktop_release
desktop_debug: ensure_raylib ensure_directories build_desktop_debug copy_headers
desktop_release: ensure_raylib ensure_directories build_desktop_release copy_headers

clone_raylib:
	@if [ ! -d "$(RAYLIB_INSTALL_DIR)" ]; then \
		git clone $(RAYLIB_REPO) $(RAYLIB_INSTALL_DIR); \
	else \
		echo "$(RAYLIB_INSTALL_DIR) already exists. Skipping clone."; \
	fi

pull_raylib:
	@if [ -d "$(RAYLIB_INSTALL_DIR)" ]; then \
		cd $(RAYLIB_INSTALL_DIR) && git pull; \
	else \
		echo "$(RAYLIB_INSTALL_DIR) does not exist. Run make clone_raylib first."; \
		exit 1; \
	fi

update_raylib: clone_raylib pull_raylib

ensure_raylib: update_raylib
	@if [ ! -d "$(RAYLIB_SRC_DIR)" ]; then \
		echo "Missing raylib source at $(RAYLIB_SRC_DIR). Run make update_raylib first."; \
		exit 1; \
	fi

ensure_emcc:
	@if command -v emcc >/dev/null 2>&1; then \
		echo "Found emcc on PATH: $$(command -v emcc)"; \
	elif [ -n "$$EMSDK" ] && [ -x "$$EMSDK/upstream/emscripten/emcc" ]; then \
		echo "Found emcc under EMSDK at $$EMSDK/upstream/emscripten/emcc, but it is not on PATH."; \
		echo "Run: source $$EMSDK/emsdk_env.sh"; \
		exit 1; \
	elif [ -n "$$EMSDK" ]; then \
		echo "EMSDK is set to '$$EMSDK' but emcc was not found at $$EMSDK/upstream/emscripten/emcc."; \
		echo "Check your EMSDK path or run emsdk install/activate."; \
		exit 1; \
	else \
		echo "Missing emcc and EMSDK is not set."; \
		echo "Install Emscripten and run: source /path/to/emsdk/emsdk_env.sh"; \
		exit 1; \
	fi

clean_repo:
	@rm -rf $(RAYLIB_INSTALL_DIR)

build_desktop_debug:
	@mkdir -p $(DESKTOP_DEBUG_BUILD_PATH)
	$(MAKE) -C $(RAYLIB_SRC_DIR) clean
	$(MAKE) -C $(RAYLIB_SRC_DIR) PLATFORM=PLATFORM_DESKTOP RAYLIB_BUILD_MODE=DEBUG RAYLIB_RELEASE_PATH=$(abspath $(DESKTOP_DEBUG_BUILD_PATH))
	@cp $(DESKTOP_DEBUG_BUILD_PATH)/libraylib.a $(LIB_OUT_DIR)/libraylib$(DEBUG_TAG).a

build_desktop_release:
	@mkdir -p $(DESKTOP_RELEASE_BUILD_PATH)
	$(MAKE) -C $(RAYLIB_SRC_DIR) clean
	$(MAKE) -C $(RAYLIB_SRC_DIR) PLATFORM=PLATFORM_DESKTOP RAYLIB_BUILD_MODE=RELEASE RAYLIB_RELEASE_PATH=$(abspath $(DESKTOP_RELEASE_BUILD_PATH))
	@cp $(DESKTOP_RELEASE_BUILD_PATH)/libraylib.a $(LIB_OUT_DIR)/libraylib.a

build_wasm_debug:
	@mkdir -p $(WASM_DEBUG_BUILD_PATH)
	$(MAKE) -C $(RAYLIB_SRC_DIR) clean
	$(MAKE) -C $(RAYLIB_SRC_DIR) CC=emcc PLATFORM=PLATFORM_WEB RAYLIB_BUILD_MODE=DEBUG RAYLIB_RELEASE_PATH=$(abspath $(WASM_DEBUG_BUILD_PATH))
	@cp $(WASM_DEBUG_BUILD_PATH)/libraylib.web.a $(LIB_OUT_DIR)/libraylib$(DEBUG_TAG).wasm.a

build_wasm_release:
	@mkdir -p $(WASM_RELEASE_BUILD_PATH)
	$(MAKE) -C $(RAYLIB_SRC_DIR) clean
	$(MAKE) -C $(RAYLIB_SRC_DIR) CC=emcc PLATFORM=PLATFORM_WEB RAYLIB_BUILD_MODE=RELEASE RAYLIB_RELEASE_PATH=$(abspath $(WASM_RELEASE_BUILD_PATH))
	@cp $(WASM_RELEASE_BUILD_PATH)/libraylib.web.a $(LIB_OUT_DIR)/libraylib.wasm.a

clean:
	@rm -rf $(BUILD_DIR)
	@rm -rf $(LIB_OUT_DIR)
	@rm -rf $(INCLUDE_OUT_DIR)



ensure_directories:
	@mkdir -p $(LIB_OUT_DIR)
	@mkdir -p $(INCLUDE_OUT_DIR)

copy_headers:
	@cp -u $(RAYLIB_SRC_DIR)/raylib.h $(INCLUDE_OUT_DIR)/raylib.h
	@cp -u $(RAYLIB_SRC_DIR)/raymath.h $(INCLUDE_OUT_DIR)/raymath.h
	@cp -u $(RAYLIB_SRC_DIR)/rlgl.h $(INCLUDE_OUT_DIR)/rlgl.h
	@cp -u $(RAYLIB_EXAMPLES_DIR)/models/rlights.h $(INCLUDE_OUT_DIR)/rlights.h

.NOTPARALLEL: ensure_directories copy_headers
