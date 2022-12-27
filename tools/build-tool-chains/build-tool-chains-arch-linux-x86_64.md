# Building Cross Compile Tool Chains on host Arch/Asahi Linux (aarch64)
## Target x86_64 (not verified whether works)
- x86_64-elf-binutils
  - version: 2.39
  - ```sh
    configure --with-sysroot \
    --prefix=/usr/local \
    --bindir=/usr/local/bin \
    --libdir=/usr/local/lib/x86_64-elf \
    --target=x86_64-elf \
    --disable-nls \
    --disable-werror
    ```
  - `make` and `make install`
- x86_64-elf-gdb
  - version: 12.1
  - ```sh
    configure --with-sysroot \
    --prefix=/usr/local \
    --bindir=/usr/local/bin \
    --libdir=/usr/local/lib/x86_64-elf \
    --target=x86_64-elf \
    --disable-nls \
    --disable-werror
    ```
  - `make` and `make install`
- x86_64-elf-gcc
  - version: 12.2.0
  - build and install `x86_64-elf-binutils` first
  - `configure` and `make` outside the source tree
  - ```sh
    configure \
    --target=x86_64-elf \
    --disable-nls \
    --without-headers \
    --enable-languages=c,c++
    ```
  - `make all-gcc` and `make all-target-libgcc`
  - `make install-gcc` and `make install-target-libgcc`