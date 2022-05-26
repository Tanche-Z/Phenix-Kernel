**English | [简体中文](./README_zh_cn.md)**<br>
[![License](https://img.shields.io/badge/License-MIT-blue)](https://github.com/HuayuZhangJager/ph1nix/blob/main/LICENSE.txt)
[![GitHub release](https://img.shields.io/badge/Releases-Latest-brightgreen)](https://github.com/HuayuZhangJager/ph1nix/releases/latest)

# ph1nix

The kernel tree of ph1nix OS.

### <mark>To Do:<mark>

- [ ] Basic Function of System Kernel:
    
    - [x] Real mode
    - [x] Protect mode
    - [x] IO
    - [x] String
    - [ ] Display driver (simplified)
    - [ ] Process management
    - [ ] Memory management
    - [ ] File system
    - [ ] Page system
    - [ ] buit-in shell

- [ ] Posix

- [ ] TCP/IP

- [ ] i386 to x86_64

- [ ] Port to ARMV8 (aarch64)
  
  - [ ] qemu-system-aarch64
  - [ ] support for Raspberry Pi 4B (ARMV8)

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
  - [ ] DE (kde/xfce/gnome)

---

## Thanks for the work of following projects, repo, books, websites and documents ... :

Kernel dev:

- Onix: <https://github.com/StevenBaby/onix>

- _《操作系统真象还原》_—— 郑钢

- OSDev.org: <https://wiki.osdev.org/>

- OSDever.net <http://www.osdever.net/>

Posix:

Unix network & TCP/IP:

UEFI:

Architecture/Assembly:
  
  - x86:
    - NASM (Intel)
      - *《x86汇编语言从实模式到保护模式》*—— 李忠, 王晓波, 余洁
      - NASM Doc <https://nasm.us/doc/>
    - GNU AS (AT&T)
      - GAS Document <https://sourceware.org/binutils/docs/as/>
      - AT&T assembly syntax and IA-32 instructions <https://gist.github.com/mishurov/6bcf04df329973c15044>
      - GNU Assembly Syntax <https://en.wikibooks.org/wiki/X86_Assembly/GNU_assembly_syntax>
    - Apple Silicon assembly <https://github.com/below/HelloSilicon>

  - ARM:
    - *Programming with 64-Bit ARM Assembly Language Single Board Computer Development for Raspberry Pi and Mobile Devices* By Stephen Smith

  - RISC-V:


C/C++:

- cppreference.com <https://en.cppreference.com/w/>
- gdb document <https://sourceware.org/gdb/download/onlinedocs/gdb.pdf>
- glibc document <https://www.gnu.org/software/libc/manual/pdf/libc.pdf>

Hardware Drivers:

- Nvidia Linux open-gpu-kernel-modules <https://github.com/NVIDIA/open-gpu-kernel-modules>

Compiler:

- gcc document <https://gcc.gnu.org/onlinedocs/>