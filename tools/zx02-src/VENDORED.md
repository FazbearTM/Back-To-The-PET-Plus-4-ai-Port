# ZX02

Vendored from https://github.com/dmsc/zx02 so the build works from a fresh
clone with no network. MIT licensed (see LICENSE) -- compressor by Daniel
Serpell, based on Einar Saukas's ZX0 (see LICENSE.zx0).

Unmodified. `make` builds it into `tools/zx02` and `tools/dzx02`.

The PET original used the same format, and this compressor reproduces its
packed assets byte for byte -- which is how the port was checked against it.
