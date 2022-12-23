# Building Cross Compile Tool Chains on host Arch Linux x86_64
- i686-elf-gcc
  - version: 12.2.0
  - build and install `i686-elf-binutils` first
  - `configure` and `make` outside the source tree
  - ```sh
    configure \
    --target=i686-elf \
    --disable-nls \
    --without-headers \
    --enable-languages=c,c++
    ```
  - `make all-gcc` and `make all-target-libgcc`
  - `make install-gcc` and `make install-target-libgcc`
- i686-elf-binutils
  - version: 2.39
  - ```sh
    configure --with-sysroot \
    --prefix=/usr/local \
    --bindir=/usr/local/bin \
    --libdir=/usr/local/lib/i686-elf \
    --target=i686-elf \
    --disable-nls \
    --disable-werror
    ```
  - `make` and `make install`
- i686-elf-gdb
  - version: 12.1
  - ```sh
    configure --with-sysroot \
    --prefix=/usr/local \
    --bindir=/usr/local/bin \
    --libdir=/usr/local/lib/i686-elf \
    --target=i686-elf \
    --disable-nls \
    --disable-werror
    ```
  - `make` and `make install`
