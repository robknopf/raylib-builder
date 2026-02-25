# raylib-builder

A simple `Makefile`-driven builder for stock raylib that produces both desktop and wasm (Emscripten) static libraries, with separate output directories per build type.

Desktop builds use `gcc` (or equivalent toolchain).  
Web builds use `emcc`/`emar` from Emscripten.

You can use this repo directly, or just copy the [Makefile](https://github.com/robknopf/raylib-builder/blob/main/Makefile) into an empty directory and run `make`.

Built/tested primarily on Linux.

## Raylib source

This now targets stock raylib:

- [raysan5/raylib](https://github.com/raysan5/raylib)

The Makefile clones raylib into `src/` by default.

## Outputs

Libraries are copied into `lib/`:

- Native release: `lib/libraylib.a`
- Native debug: `lib/libraylib_d.a`
- Wasm release: `lib/libraylib.wasm.a`
- Wasm debug: `lib/libraylib_d.wasm.a`

Build intermediates are kept separate:

- `obj/desktop/debug`
- `obj/desktop/release`
- `obj/wasm/debug`
- `obj/wasm/release`

Headers are copied to `include/`:

- `raylib.h`
- `raymath.h`
- `rlgl.h`
- `rlights.h`

## Usage

### Common targets

```sh
make [all|debug|release|wasm|desktop|wasm_debug|wasm_release|desktop_debug|desktop_release|clean|clean_repo]
```

### Updating raylib

Build targets automatically ensure raylib is present and up to date:

- If `src/` is missing, they clone raylib.
- If `src/` exists, they run `git pull`.

To explicitly update raylib without building:

```sh
make update_raylib
```

Or combine update + build:

```sh
make update_raylib all
```

### Emscripten preflight (wasm targets)

`wasm_debug` and `wasm_release` run a preflight check before building:

- If `emcc` is on `PATH`, build proceeds.
- If `EMSDK` is set and `emcc` exists under `$EMSDK/upstream/emscripten/emcc` but is not on `PATH`, the build stops with guidance to run:

```sh
source $EMSDK/emsdk_env.sh
```

- If neither is valid, the build stops with a setup hint.

## Quick start

```sh
git clone https://github.com/robknopf/raylib-builder.git raylib
cd raylib
make all -j8
```

Pull requests are welcome.
