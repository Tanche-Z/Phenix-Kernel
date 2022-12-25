SRC:=.
#TEST=./ph1nix_test
BUILD:=../build
TOOLS:=../tools
#TEST_BUILD:=$(TEST)/build
BOCHS_CONFIG:=$(TOOLS)/bochs-config

# Set cross compile tools chain
HOME_BREW_ARM64_PATH:=/opt/homebrew/bin/
LINUX_PATH:=/usr/bin/
LINUX_LOCAL_PATH:=/usr/local/bin/
TARGET_ARCH:=x86
TARGET:=i386
#TARGET:=x86_64
#TARGET:=aarch64
HOST_ARCH:=$(shell uname -m)
HOST_KERNEL:=$(shell uname -s)
HOST_DISTRO:=$(shell uname -n)
# Host: Apple Silicon Mac(arm64), Target: i686 (32bits)
ifeq ($(HOST_KERNEL), Darwin)
	ifeq ($(HOST_ARCH), arm64)
		ifeq ($(TARGET), i386)
		TOOL_PATH:=$(HOME_BREW_ARM64_PATH)$(TARGET)-elf-
		NASM:=$(HOME_BREW_ARM64_PATH)nasm
		GDB:=$(HOME_BREW_ARM64_PATH)i386-elf-gdb
		endif
	endif
endif

ifeq ($(HOST_KERNEL), Linux) 
	NASM:=$(LINUX_PATH)nasm
	GDB:=$(LINUX_PATH)gdb
	ifeq ($(HOST_ARCH), x86_64)
		ifeq ($(TARGET), i386)
			# Host: Linux (x86_64), Target: i386 (32bits)
			# TOOL_PATH:=$(LINUX_LOCAL_PATH)i686-elf-
			# GDB:=$(LINUX_LOCAL_PATH)i686-elf-gdb
			TOOL_PATH:=$(LINUX_PATH)
		endif
	endif
	ifeq ($(HOST_ARCH), aarch64)	
		ifeq ($(TARGET), i386)
			ifeq ($(HOST_DISTRO), Asahi)
				# Host: Linux (arm64), Target: i386 (32bits)
				TOOL_PATH:=$(LINUX_LOCAL_PATH)i686-elf-
			endif
			ifneq ($(HOST_DISTRO), Asahi)
				# Host: Linux (arm64), Target: i386 (32bits)
				TOOL_PATH:=$(LINUX_PATH)i686-linux-gnu-
			endif
			
		endif
	endif
endif

AS:=$(TOOL_PATH)as
CC:=$(TOOL_PATH)gcc
LD:=$(TOOL_PATH)ld
OBJCOPY:=$(TOOL_PATH)objcopy
OBJDUMP:=$(TOOL_PATH)objdump

.PHONY: show_config
show_config:
	$(info $$HOST_ARCH = ${HOST_ARCH})
	$(info $$HOST_KERNEL = ${HOST_KERNEL})
	$(info $$AS = ${AS})
	$(info $$LD = ${LD})
	$(info $$CC = ${CC})
	$(info $$OBJCOPY = ${OBJCOPY})
	$(info $$OBJDUMP = ${OBJDUMP})
	$(info $$GDB = ${GDB})
	$(info $$NASM = ${NASM})

CFLAGS:= -fno-builtin # no built-in function in gcc
CFLAGS+= -fno-pic # no position independent code
CFLAGS+= -fno-pie # no position independent excutable
CFLAGS+= -ffreestanding
CFLAGS+= -fno-tree-vectorize # no vectorize instructor
CFLAGS+= -fno-stack-protector # no stack protector
CFLAGS+= -nostdinc # no standard c header
CFLAGS+= -nostdinc++ # no standard c++ header
CFLAGS+= -nostdlib # no standard library
CFLAGS+= -m32 # (when using gcc target x86_64) enable i386 mode
# CFLAGS+= -Wa,--32,--gdwarf-5,-o,$@.o # (when using i686 gcc) pass option to assembler (generate 32bits code)
# CFLAGS+= -Wl,-melf_i386,-static,-o,$@.elf,-Ttext,$(BOOT_EP) # (when using i686 gcc) pass option to linker (generate 32bits code)
CFLAGS:=$(strip ${CFLAGS})

BOOT_EP:=0x7c00
LOADER_EP:=0x1000
KERNEL_EP:=0x10000

DEBUG:= -g
INCLUDE:= -I $(SRC)/include/

BOOT:=arch/$(TARGET_ARCH)/$(TARGET)/boot/

# $(BUILD)/$(BOOT)%.bin: $(SRC)/$(BOOT)%.asm
# 	$(shell mkdir -p $(dir $@))
# 	$(NASM) -f bin $< -o $@

# $(BUILD)/%.o: $(SRC)/%.asm
# 	$(shell mkdir -p $(dir $@))
# 	$(NASM) -f elf32 -gdwarf $< -o $@

# change assembler from NASM to GNU AS(x86)
$(BUILD)/$(BOOT)boot.bin: $(SRC)/$(BOOT)boot.S
	$(shell mkdir -p $(dir $@))
	$(AS) --32 --gdwarf-5 $< -o $@.o
	$(LD) -m elf_i386 -static $@.o -o $@.elf -Ttext $(BOOT_EP)
	$(OBJCOPY) -O binary $@.elf $@

$(BUILD)/$(BOOT)loader.bin: $(SRC)/$(BOOT)loader.S
	$(shell mkdir -p $(dir $@))
	$(AS) --32 --gdwarf-5 $< -o $@.o
	$(LD) -m elf_i386 -static $@.o -o $@.elf -Ttext $(LOADER_EP)
	$(OBJCOPY) -O binary $@.elf $@

$(BUILD)/%.o: $(SRC)/%.S
	$(shell mkdir -p $(dir $@))
	$(AS) --32 --gdwarf-5 $< -o $@

$(BUILD)/%.o: $(SRC)/%.c
	$(shell mkdir -p $(dir $@))
	$(CC) $(CFLAGS) $(DEBUG) $(INCLUDE) -c $< -o $@

$(BUILD)/kernel.bin: \
	$(BUILD)/kernel/start.o \

# $(BUILD)/kernel/main.o
# 	# $(BUILD)/kernel/io.o \
# 	# $(BUILD)/kernel/console.o \
# 	# $(BUILD)/kernel/printk.o \
# 	# $(BUILD)/lib/string.o \
# 	# $(BUILD)/lib/vsprintf.o

	$(shell mkdir -p $(dir $@))
	$(LD) -m elf_i386 -static $^ -o $@ -Ttext $(KERNEL_EP)

$(BUILD)/system.bin: $(BUILD)/kernel.bin
	$(OBJCOPY) -O binary $< $@

$(BUILD)/system.map: $(BUILD)/kernel.bin
	nm $< | sort > $@

$(BUILD)/master.img: $(BUILD)/$(BOOT)boot.bin \
	$(BUILD)/$(BOOT)loader.bin \
	$(BUILD)/system.bin \
	$(BUILD)/system.map

# # choosing different version of bximage in Debian like distro (if using newer version like in Arch, no need)
# if [ $(HOST_KERNEL) == "Linux" ];then \
# 	yes | bximage -q -hd=16 -mode=create -sectsize=512 -imgmode=flat $@; \
# elif [ $(HOST_KERNEL) == "Darwin" ];then \
# 	yes | bximage -q -hd=16 -func=create -sectsize=512 -imgmode=flat $@; \
# fi

	yes | bximage -q -hd=16 -func=create -sectsize=512 -imgmode=flat $@; \
	dd if=$(BUILD)/$(BOOT)boot.bin of=$@ bs=512 count=1 conv=notrunc
	dd if=$(BUILD)/$(BOOT)loader.bin of=$@ bs=512 count=4 seek=2 conv=notrunc
	dd if=$(BUILD)/system.bin of=$@ bs=512 count=200 seek=10 conv=notrunc

.PHONY: clean
clean:
	rm -rf $(BUILD); \
	rm $(SRC)/bochsrc*;

.PHONY: qemu
qemu: $(BUILD)/master.img
	qemu-system-i386 \
	-m 32M \
	-boot c \
	-hda $<

.PHONY: qemu-gdb
qemu-gdb: $(BUILD)/master.img
	qemu-system-i386 \
	-s -S \
	-m 32M \
	-boot c \
	-hda $<

.PHONY: disam-boot
disam_boot:
	$(OBJDUMP) -D -b binary -m i386:x86-64 $(BUILD)/boot/boot.bin

# Bochs X11 gui-debug
.PHONY: bochs
bochs: $(BUILD)/master.img
	bochs -q -f $(BOCHS_CONFIG)/bochsrc

# Bochs gdb with stub
.PHONY: bochs-gdb
bochs-gdb: $(BUILD)/master.img
	bochs-gdb -q -f $(BOCHS_CONFIG)/bochsrc_gdb

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

# # for testing image in usb drive in virtualbox before going physic machine test
# # should manually set path for IDE disk of usb.vmdk for usb test in virtualbox
# .PHONY: vbox_usb_test
# vbox_usb_test: usb
# 	sudo vboxmanage internalcommands createrawvmdk -filename $(BUILD)/usb.vmdk -rawdisk /dev/sda; \
# 	sudo chown kali:kali $(BUILD)/usb.vmdk

# .PHONY: usb # sample code for write image to USB device
# usb: $(BUILD)/master.img /dev/sda
# 	# sudo dd if=/dev/sda of=$(BUILD)/boot/tmp.bin bs=512 count=1000 conv=notrunc
# 	# cp $(BUILD)/boot/tmp.bin $(BUILD)/boot/usb.bin
# 	# sudo rm $(BUILD)/boot/tmp.bin
# 	# dd if=$(BUILD)/master.img of=$(BUILD)/boot/usb.bin bs=512 count=1000 conv=notrunc
# 	# sudo dd if=$(BUILD)/boot/usb.bin of=/dev/sda bs=512 count=1000 conv=notrunc
# 	# rm $(BUILD)/boot/usb.bin

# 	# sudo dd if=/dev/sda of=$(BUILD)/boot/tmp.bin bs=512 conv=notrunc
# 	# cp $(BUILD)/boot/tmp.bin $(BUILD)/boot/usb.bin
# 	# sudo rm $(BUILD)/boot/tmp.bin
# 	# dd if=$(BUILD)/master.img of=$(BUILD)/boot/usb.bin bs=512 conv=notrunc
# 	# sudo dd if=$(BUILD)/boot/usb.bin of=/dev/sda bs=512 conv=notrunc
# 	# rm $(BUILD)/boot/usb.bin

# 	dd if=$(BUILD)/master.img of=/dev/sda

.PHONY: test
test: $(BUILD)/master.img