# jq

`jq` is a lightweight and flexible command-line JSON processor akin to `sed`,`awk`,`grep`, and friends for JSON data. It's written in portable C and has zero runtime dependencies, allowing you to easily slice, filter, map, and transform structured data.

THIS FORK is a simple hack to add:
 * a string function 'md5'
 * a function 'rand' returning float64

where the underlying functions are written in [Zig](https://ziglang.org).

I'm pretty much a n00b with Makefiles, let alone Zig. But the latter is truly awesome.

Modified files:
===============
* Makefile.am   -- is there a better way to do this? Let me know via pull request thingy.
* src/builtin.c -- add the extern C-ABI functions f_md5, f_rand and register jq keywords 'md5', 'rand'.
* README.md     -- this.

Added file:
===========
* src/f_misc.zig -- see this file for a few notes on how it was done (TL;DR: really easily. Did I mention Zig is awesome?)

Example using hack:
===================
	$ ./jq -n 'rand,rand'
	0.9407224365467721
	0.4601556075983295

	$ ./jq -n '""|md5'
	"d41d8cd98f00b204e9800998ecf8427e"

compare (Mac md5, same as Linux md5sum):

	$ echo -n | md5
	d41d8cd98f00b204e9800998ecf8427e

The rest of this README is unchanged from jqlang/jq. Thanks!

## Documentation

- **Official Documentation**: [jqlang.github.io/jq](https://jqlang.github.io/jq)
- **Try jq Online**: [jqplay.org](https://jqplay.org)

## Installation

### Prebuilt Binaries

Download the latest releases from the [GitHub release page](https://github.com/jqlang/jq/releases).

### Docker Image

Pull the [jq image](https://github.com/jqlang/jq/pkgs/container/jq) to start quickly with Docker.

#### Run with Docker
##### Example: Extracting the version from a `package.json` file
```bash
docker run --rm -i ghcr.io/jqlang/jq:latest < package.json '.version'
```
##### Example: Extracting the version from a `package.json` file with a mounted volume
```bash
docker run --rm -i -v "$PWD:$PWD" -w "$PWD" ghcr.io/jqlang/jq:latest '.version' package.json
```

### Building from source

#### Dependencies

- libtool
- make
- automake
- autoconf

#### Instructions

```console
git submodule update --init # if building from git to get oniguruma
autoreconf -i               # if building from git
./configure --with-oniguruma=builtin
make -j8
make check
sudo make install
```

Build a statically linked version:

```console
make LDFLAGS=-all-static
```

If you're not using the latest git version but instead building a released tarball (available on the release page), skip the `autoreconf` step, and flex or bison won't be needed.

##### Cross-Compilation

For details on cross-compilation, check out the [GitHub Actions file](.github/workflows/ci.yml) and the [cross-compilation wiki page](https://github.com/jqlang/jq/wiki/Cross-compilation).

## Community & Support

- Questions & Help: [Stack Overflow (jq tag)](https://stackoverflow.com/questions/tagged/jq)
- Chat & Community: [Join us on Discord](https://discord.gg/yg6yjNmgAC)
- Wiki & Advanced Topics: [Explore the Wiki](https://github.com/jqlang/jq/wiki)

## License

`jq` is released under the [MIT License](COPYING). `jq`'s documentation is
licensed under the [Creative Commons CC BY 3.0](COPYING).
`jq` uses parts of the open source C library "decNumber", which is distributed
under [ICU License](COPYING)
