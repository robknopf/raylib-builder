LIB_OUT_DIR := lib
INCLUDE_OUT_DIR := include
BUILD_DIR := obj
RAYLIB_REPO := https://github.com/robknopf/raylib.git
RAYLIB_INSTALL_DIR := src
RAYLIB_SRC_DIR := $(RAYLIB_INSTALL_DIR)/src
RAYLIB_MAKEFILE := $(RAYLIB_SRC_DIR)/Makefile
DEBUG_TAG := _d

DESKTOP_DEBUG_BUILD_PATH := $(BUILD_DIR)/desktop/debug
DESKTOP_RELEASE_BUILD_PATH := $(BUILD_DIR)/desktop/release
WEB_DEBUG_BUILD_PATH := $(BUILD_DIR)/web/debug
WEB_RELEASE_BUILD_PATH := $(BUILD_DIR)/web/release

# create targets for the different platforms
all: release debug

release: ensure_directories desktop_release web_release copy_headers
debug: ensure_directories desktop_debug web_debug copy_headers


web: web_debug web_release
web_debug: update_raylib ensure_directories build_web_debug copy_headers
web_release: update_raylib ensure_directories build_web_release copy_headers

desktop: desktop_debug desktop_release
desktop_debug: update_raylib ensure_directories build_desktop_debug copy_headers
desktop_release: update_raylib ensure_directories build_desktop_release copy_headers

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

clean_repo:
	@rm -rf $(RAYLIB_INSTALL_DIR)

build_desktop_debug:
	@mkdir -p $(DESKTOP_DEBUG_BUILD_PATH)
	$(MAKE) -f $(RAYLIB_MAKEFILE) PLATFORM=PLATFORM_DESKTOP RAYLIB_BUILD_MODE=DEBUG RAYLIB_BUILD_PATH=$(DESKTOP_DEBUG_BUILD_PATH) RAYLIB_SRC_PATH=$(RAYLIB_SRC_DIR)
	@cp $(DESKTOP_DEBUG_BUILD_PATH)/libraylib.a $(LIB_OUT_DIR)/libraylib$(DEBUG_TAG).a

build_desktop_release:
	@mkdir -p $(DESKTOP_RELEASE_BUILD_PATH)
	$(MAKE) -f $(RAYLIB_MAKEFILE) PLATFORM=PLATFORM_DESKTOP RAYLIB_BUILD_MODE=RELEASE RAYLIB_BUILD_PATH=$(DESKTOP_RELEASE_BUILD_PATH) RAYLIB_SRC_PATH=$(RAYLIB_SRC_DIR)
	@cp $(DESKTOP_RELEASE_BUILD_PATH)/libraylib.a $(LIB_OUT_DIR)/libraylib.a

build_web_debug:
	@mkdir -p $(WEB_DEBUG_BUILD_PATH)
	$(MAKE) -f $(RAYLIB_MAKEFILE) CC=emcc PLATFORM=PLATFORM_WEB RAYLIB_BUILD_MODE=DEBUG RAYLIB_BUILD_PATH=$(WEB_DEBUG_BUILD_PATH) RAYLIB_SRC_PATH=$(RAYLIB_SRC_DIR)
	@cp $(WEB_DEBUG_BUILD_PATH)/libraylib.a $(LIB_OUT_DIR)/libraylib$(DEBUG_TAG).web.a

build_web_release:
	@mkdir -p $(WEB_RELEASE_BUILD_PATH)
	$(MAKE) -f $(RAYLIB_MAKEFILE) CC=emcc PLATFORM=PLATFORM_WEB RAYLIB_BUILD_MODE=RELEASE RAYLIB_BUILD_PATH=$(WEB_RELEASE_BUILD_PATH) RAYLIB_SRC_PATH=$(RAYLIB_SRC_DIR)
	@cp $(WEB_RELEASE_BUILD_PATH)/libraylib.a $(LIB_OUT_DIR)/libraylib.web.a

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
	@cp -u $(RAYLIB_SRC_DIR)/rlgl.h $(INCLUDE_OUT_DIR)/rlights.h

.NOTPARALLEL: ensure_directories copy_headers
