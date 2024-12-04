# raylib-builder
Mostly just a makefile to pull my raylib repo and build desktop and web (emscripten) static libraries. The gcc toolchain is required (build-essential?) for desktop, as is emcc for the web build.

(You don't really need to clone this repo.  Just grab the [Makefile](https://github.com/robknopf/raylib-builder/blob/main/Makefile) save it in an empty directory and run `make` )

*I'm doing most of my development on Linux, so I'd be shocked if it worked on other platforms without some tweaks.*

#### Repositories
* [My fork of raylib](https://github.com/robknopf/raylib.git) ([NOTES](https://github.com/robknopf/raylib/blob/master/NOTES.md)))
* [Original raylib](https://github.com/raysan5/raylib.git)


#### Usage
```shell
$ make [all|debug|release|web|desktop|clean|clean_repo]
```

or, if you are like me and want things crisp and tidy:
> Note the `raylib` at the end of the git command.  This will clone to a new "raylib" directory.
```shell
$ git clone https://github.com/robknopf/raylib-builder.git raylib
$ cd raylib
$ make all -j8
```



Feel free to fork or submit pull requests.
