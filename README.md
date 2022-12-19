**English | [简体中文](./src/docs/translations/zh_cn/README_zh_cn.md)**<br>

# ph1nix

ph1nix OS.

### <mark>To Do:<mark>

- [ ] Basic Function of System Kernel:
    
    - [x] Real mode
    - [x] Protect mode
    - [x] IO
    - [x] String
    - [x] VGA
    - [ ] Process management
    - [ ] Memory management
    - [ ] File system
    - [ ] Page system
    - [ ] buit-in shell

- [ ] Posix

- [ ] Toolchain imgration/support (to Clang)

- [ ] Toolchain migration (to Rust)

- [ ] Network Stack (TCP/IP)

- [ ] NASM to GNU AS

- [ ] i686 to x86_64

- [ ] Port to ARMV8 (aarch64)
  
  - [ ] qemu-system-aarch64
  - [ ] support for Raspberry Pi 4B (Cortex-a72)(ARMV8)

- [ ] BIOS (Legacy) to UEFI + support grub2

- [ ] Hardware Driver Subsystem

  - [ ] Display driver (nvidia kernel space)
  - [ ] alsa

- [ ] Port to RISC-V

- [ ] Compiler (Monkey King)(mkk)

  - [ ] c/c++

- [ ] GUI (C++) (Dragon DE)

- [ ] Developing APIs

- [ ] Mass migration of software (sperate repo)

  - [ ] bash/zsh
  - [ ] vim
  - [ ] gnu toolchain
  - [ ] llvm
  - [ ] Rust
  - [ ] DE (kde/xfce/gnome)
---

# Current Dev Env
## MacOS (Apple Silicon)
- Homebrew packages:
  - i686-elf-gcc
  - i686-elf-binutils
  - nasm
  - qemu
  - bochs
## Linux (aarch64) 
- (Debian) apt packages:
  - gcc-i686-linux-gnu
  - binutils-i686-linux-gnu
  - i386-elf-gdb
  - nasm
  - qemu-system-x86
  - bochs
## Linux (x86_64) 
- (Debian) apt packages:
  - gcc-i686-linux-gnu
  - binutils-i686-linux-gnu
  - nasm
  - qemu-system-x86
  - bochs