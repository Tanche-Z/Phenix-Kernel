# default tool chain is GNU
TOOL_CHAIN=GNU
# TOOL_CHAIN=LLVM

# Target host config
TARGET_ARCH:=x86
#TARGET_ARCH:=arm
#TARGET_ARCH:=risc-v

TARGET_ARCH_SUB:=i386
# TARGET_ARCH_SUB:=x86_64
#TARGET_ARCH_SUB:=aarch64

ifeq ($(TARGET_ARCH_SUB), x86_64)
	TARGET_CPU=x86-64
	MEM_SIZE:=16G
endif

ifeq ($(TARGET_ARCH_SUB), i386)
	TARGET_CPU=i386
	MEM_SIZE:=32M
endif

# Building host config
HOST_ARCH:=$(shell uname -m)
HOST_KERNEL:=$(shell uname -s)
HOST_DISTRO:=$(shell uname -n)

# working tree
SRC:=src
BOOT:=arch/$(TARGET_ARCH)/$(TARGET_ARCH_SUB)/boot/
TEST=tests
BUILD:=build
TOOLS:=tools
TEST_BUILD:=$(TEST)/build
BOCHS_CONFIG:=$(TOOLS)/bochs-config

# Set cross compile tools chain PATH
HOME_BREW_ARM64_PATH:=/opt/homebrew/bin/
LINUX_PATH:=/usr/bin/
LINUX_LOCAL_PATH:=/usr/local/bin/
BREW_LLVM_PATH:=/opt/homebrew/opt/llvm/bin/

# auto config (selecting tool chain)
# Host: Apple Silicon Mac(arm64)
ifeq ($(HOST_KERNEL), Darwin)
	ifeq ($(HOST_ARCH), arm64)
		ifeq ($(TARGET_ARCH_SUB), i386)
		TOOL_PATH:=$(HOME_BREW_ARM64_PATH)x86_64-elf-
		GDB:=$(HOME_BREW_ARM64_PATH)$(TARGET_ARCH_SUB)-elf-gdb
		endif
	endif
# TOOL_CHAIN=LLVM
# AS:=$(TOOL_PATH)as
# LD:=$(BREW_LLVM_PATH)ld.lld
# CC:=clang
# OBJCOPY:=$(BREW_LLVM_PATH)llvm-objcopy
# OBJDUMP:=$(BREW_LLVM_PATH)llvm-objdump
# NM:=$(BREW_LLVM_PATH)llvm-nm
endif
ifeq ($(HOST_KERNEL), Linux)
	ifeq ($(HOST_ARCH), x86_64)
		ifeq ($(TARGET_ARCH_SUB), i386)
			TOOL_PATH:=$(LINUX_PATH)
		endif
	endif
	ifeq ($(HOST_ARCH), aarch64)	
		ifeq ($(TARGET_ARCH_SUB), i386)
			ifeq ($(HOST_DISTRO), Asahi)
				# Host: Linux (arm64) (Arch like)
				TOOL_PATH:=$(LINUX_LOCAL_PATH)x86_64-elf-
			endif
			ifneq ($(HOST_DISTRO), Asahi)
				# Host: Linux (arm64) (Debian like)
				TOOL_PATH:=$(LINUX_PATH)x86_64-linux-gnu-
			endif
		endif
	endif
	GDB:=$(LINUX_PATH)gdb
endif

# using GNU toolchain (default)
ifeq ($(TOOL_CHAIN), GNU)
	AS:=$(TOOL_PATH)as
	LD:=$(TOOL_PATH)ld
	CC:=$(TOOL_PATH)gcc
	OBJCOPY:=$(TOOL_PATH)objcopy
	OBJDUMP:=$(TOOL_PATH)objdump
	NM:=$(TOOL_PATH)nm
endif

# # using clang
ifeq ($(TOOL_CHAIN), LLVM)
	AS:=$(TOOL_PATH)as
	LD:=$(LINUX_PATH)ld.lld
	CC:=$(LINUX_PATH)clang
	OBJCOPY:=$(LINUX_PATH)llvm-objcopy
	OBJDUMP:=$(LINUX_PATH)llvm-objdump
	NM:=$(TOOL_PATH)llvm-nm
endif

.PHONY: show_config
show_config:
	$(info $$HOST_ARCH = ${HOST_ARCH})
	$(info $$HOST_KERNEL = ${HOST_KERNEL})
	$(info $$TARGET_ARCH = ${TARGET_CPU})
	$(info $$AS = ${AS})
	$(info $$LD = ${LD})
	$(info $$CC = ${CC})
	$(info $$OBJCOPY = ${OBJCOPY})
	$(info $$OBJDUMP = ${OBJDUMP})
	$(info $$NM = ${NM})
	$(info $$GDB = ${GDB})
	$(info $$QEMU_MEM_SIZE = ${MEM_SIZE})

DEBUG:= -g
# DEBUG:= -gstabs
INCLUDE:= -I $(SRC)/include/

# general CFLAGS
CFLAGS:= -fno-builtin # no built-in function in gcc
CFLAGS+= -fno-pic # no position independent code
CFLAGS+= -fno-pie # no position independent excutable
CFLAGS+= -ffreestanding
CFLAGS+= -fno-tree-vectorize # no vectorize instructor
CFLAGS+= -fno-stack-protector # no stack protector
CFLAGS+= -nostdinc # no standard c header
# CFLAGS+= -nostdinc++ # no standard c++ header
CFLAGS+= -nostdlib # no standard library
CFLAGS+= -O0 # disable all optimization

# using gcc (default)
ifeq ($(TOOL_CHAIN), GNU)
	ifeq ($(TARGET_ARCH_SUB), i386)
		CFLAGS+= -m32 # (when using gcc that target x86_64 (if target i686(already 32bits, then no need))) to enable i386 mode
		CFLAGS+= -march=$(TARGET_CPU)
# CFLAGS+= -mtune=$(TARGET_CPU) # optimize (will be ignored if march has set)
	endif
	ifeq ($(TARGET_ARCH_SUB), x86_64)
		CFLAGS+= -m64
		ifeq ($(HOST_ARCH), x86_64)
			CFLAGS+= -march=native
# CFLAGS+= -mtune=$(TARGET_CPU)
		endif
		ifneq ($(HOST_ARCH), x86_64)
			CFLAGS+= -march=$(TARGET_CPU)
		endif
	endif
endif

# if using clang
ifeq ($(TOOL_CHAIN), LLVM)
CFLAGS+= --target=$(TARGET_ARCH_SUB)-unknown-none-elf
# CFLAGS+= -mcpu=$(TARGET_ARCH_SUB)
# CFLAGS+= -fno-integrated-as # comment when buidling on MacOS
endif

# for GNU AS
ifeq ($(TARGET_ARCH_SUB), i386)
	ASFLAGS+= --32 # 32bit mode
	ASFLAGS+= -march=$(TARGET_CPU)
	ASFLAGS+= -mtune=$(TARGET_CPU) # optimize
	ASFLAGS+= -O0
endif
ASFLAGS+= $(DEBUG)
# ASFLAGS+= --gstabs

# ASFLAGS+= -mmnemonic=intel # default: att
# ASFLAGS+= -msyntax=intel # default: att

# for both GNU LD and LLVM LD.LLD
LDFLAGS+= -m elf_$(TARGET_ARCH_SUB)
LDFLAGS+= -static

# combine flags properly
CFLAGS:=$(strip ${CFLAGS})
ASFLAGS:=$(strip ${ASFLAGS})
LDFLAGS:=$(strip ${LDFLAGS})

# entry points for assembly
BOOT_EP:=0x7c00
LOADER_EP:=0x1000
KERNEL_EP:=0x10000

# # # long mode test using nasm
# BOOT:=arch/$(TARGET_ARCH)/$(TARGET_ARCH_SUB)/boot/nasm/
# $(BUILD)/$(BOOT)%.bin: $(SRC)/$(BOOT)%.asm
# 	$(shell mkdir -p $(dir $@))
# 	nasm -f bin -i $(BOOT) $< -o $@
# $(BUILD)/%.o: $(SRC)/%.asm
# 	$(shell mkdir -p $(dir $@))
# 	nasm -f elf32 $(DEBUG) $< -o $@

# building from source
$(BUILD)/$(BOOT)boot.bin: $(SRC)/$(BOOT)boot.S
	$(shell mkdir -p $(dir $@))
	$(AS) $(ASFLAGS) $< -o $@.o
	$(LD) $(LDFLAGS) $@.o -o $@.elf -Ttext $(BOOT_EP)
	$(OBJCOPY) -O binary $@.elf $@

$(BUILD)/$(BOOT)loader.bin: $(SRC)/$(BOOT)loader.S
	$(shell mkdir -p $(dir $@))
	$(AS) $(ASFLAGS) $< -o $@.o
	$(LD) $(LDFLAGS) $@.o -o $@.elf -Ttext $(LOADER_EP)
	$(OBJCOPY) -O binary $@.elf $@

$(BUILD)/%.o: $(SRC)/%.S
	$(shell mkdir -p $(dir $@))
	$(AS) $(ASFLAGS) $< -o $@

$(BUILD)/%.o: $(SRC)/%.c
	$(shell mkdir -p $(dir $@))
	$(CC) $(CFLAGS) $(DEBUG) $(INCLUDE) -c $< -o $@

$(BUILD)/kernel.bin: \
	$(BUILD)/kernel/start.o \
	$(BUILD)/kernel/main.o \
	$(BUILD)/kernel/io.o \
	$(BUILD)/kernel/console.o \
	$(BUILD)/kernel/printk.o \
	$(BUILD)/kernel/assert.o \
	$(BUILD)/kernel/debug.o \
	$(BUILD)/kernel/global.o \
	$(BUILD)/kernel/task.o \
	$(BUILD)/kernel/schedule.o \
	$(BUILD)/lib/string.o \
	$(BUILD)/lib/vsprintf.o

	$(shell mkdir -p $(dir $@))
	$(LD) -m elf_$(TARGET_ARCH_SUB) -static $^ -o $@ -Ttext $(KERNEL_EP)

$(BUILD)/system.bin: $(BUILD)/kernel.bin
	$(OBJCOPY) -O binary $< $@

$(BUILD)/system.map: $(BUILD)/kernel.bin
	$(NM) $< | sort > $@

$(BUILD)/master.img: $(BUILD)/$(BOOT)boot.bin \
	$(BUILD)/$(BOOT)loader.bin \
	$(BUILD)/system.bin \
	$(BUILD)/system.map

# yes | bximage -q -func=create -hd=16  -sectsize=512 -imgmode=flat $@
	qemu-img create -o size=16M $@ 
	dd if=$(BUILD)/$(BOOT)boot.bin of=$@ bs=512 count=1 conv=notrunc
	dd if=$(BUILD)/$(BOOT)loader.bin of=$@ bs=512 count=4 seek=2 conv=notrunc
	dd if=$(BUILD)/system.bin of=$@ bs=512 count=200 seek=10 conv=notrunc

# # long mode test...
# $(BUILD)/master.img: $(BUILD)/$(BOOT)boot.bin \
# 	$(BUILD)/system.bin \
# 	$(BUILD)/system.map

# 	qemu-img create -o size=16M $@ 
# 	dd if=$(BUILD)/$(BOOT)boot.bin of=$@ bs=512 count=1 conv=notrunc
# 	dd if=$(BUILD)/system.bin of=$@ bs=512 count=200 seek=10 conv=notrunc

.PHONY: clean
clean:
	rm -rf $(BUILD); \
	rm -f $(SRC)/bochsrc*;

QEMU_BOOT_OPTIONS+= -m $(MEM_SIZE)
QEMU_BOOT_OPTIONS+= -boot c
QEMU_BOOT_OPTIONS:= $(strip ${QEMU_BOOT_OPTIONS})

.PHONY: qemu
qemu: $(BUILD)/master.img
	qemu-system-$(TARGET_ARCH_SUB) $(QEMU_BOOT_OPTIONS) -hda $<

.PHONY: qemu-gdb
qemu-gdb: $(BUILD)/master.img
	qemu-system-$(TARGET_ARCH_SUB) $(QEMU_BOOT_OPTIONS) -hda $< -s -S

.PHONY: disam-boot
disam_boot:
	$(OBJDUMP) -D -b binary -m $(TARGET_ARCH_SUB):x86-64 $(BUILD)/boot/boot.bin

# Bochs X11 gui-debug
.PHONY: bochs
bochs: $(BUILD)/master.img
	bochs -q -f $(BOCHS_CONFIG)/bochsrc

# Bochs gdb with stub
.PHONY: bochs-gdb
bochs-gdb: $(BUILD)/master.img
	bochs-gdb -q -f $(BOCHS_CONFIG)/bochsrc-gdb

# generate vmware disk image
$(BUILD)/master.vmdk: $(BUILD)/master.img
	qemu-img convert -pO vmdk $< $@
.PHONY: vmdk
vmdk: $(BUILD)/master.vmdk

# generate virtualbox disk image
$(BUILD)/master.vdi: $(BUILD)/master.img
	qemu-img convert -pO vdi $< $@
.PHONY: vdi
vdi: $(BUILD)/master.vdi

# for testing image in usb drive in virtualbox before going physic machine test
# should manually set path for IDE disk of usb.vmdk for usb test in virtualbox
.PHONY: vbox_usb_test
vbox_usb_test: usb
	sudo vboxmanage internalcommands createrawvmdk -filename $(BUILD)/usb.vmdk -rawdisk /dev/sda; \
	sudo chown kali:kali $(BUILD)/usb.vmdk

.PHONY: usb # sample code for write image to USB device
usb: $(BUILD)/master.img /dev/sda
	# sudo dd if=/dev/sda of=$(BUILD)/boot/tmp.bin bs=512 count=1000 conv=notrunc
	# cp $(BUILD)/boot/tmp.bin $(BUILD)/boot/usb.bin
	# sudo rm $(BUILD)/boot/tmp.bin
	# dd if=$(BUILD)/master.img of=$(BUILD)/boot/usb.bin bs=512 count=1000 conv=notrunc
	# sudo dd if=$(BUILD)/boot/usb.bin of=/dev/sda bs=512 count=1000 conv=notrunc
	# rm $(BUILD)/boot/usb.bin

	# sudo dd if=/dev/sda of=$(BUILD)/boot/tmp.bin bs=512 conv=notrunc
	# cp $(BUILD)/boot/tmp.bin $(BUILD)/boot/usb.bin
	# sudo rm $(BUILD)/boot/tmp.bin
	# dd if=$(BUILD)/master.img of=$(BUILD)/boot/usb.bin bs=512 conv=notrunc
	# sudo dd if=$(BUILD)/boot/usb.bin of=/dev/sda bs=512 conv=notrunc
	# rm $(BUILD)/boot/usb.bin

	sudo dd if=$(BUILD)/master.img of=/dev/sda

.PHONY: test
test: $(BUILD)/master.img