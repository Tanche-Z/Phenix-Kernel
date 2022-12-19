SRC:=.
TEST=./ph1nix_test
BUILD:=../build
TEST_BUILD:=$(TEST)/build
BOCHS_CONFIG:=$(TEST)/bochs/config

# Set cross compile tools chain
HOME_BREW_ARM64_PATH:=/opt/homebrew/bin/
LINUX_PATH:=/usr/bin/
TARGET:=i686
#TARGET:=x86_64
#TARGET:=aarch64
HOST_ARCH:=$(shell uname -m)
HOST_KERNEL:=$(shell uname -s)
# Host: Apple Silicon Mac(arm64), Target: i686 (32bits)
ifeq ($(HOST_KERNEL), Darwin)
	ifeq ($(HOST_ARCH), arm64)
		ifeq ($(TARGET), i686)
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
		ifeq ($(TARGET), i686)
			# Host: Linux (x86_64), Target: i686 (32bits)
			TOOL_PATH:=$(LINUX_PATH)$(TARGET)-linux-gnu-
		endif
	endif
	ifeq ($(HOST_ARCH), aarch64)	
		ifeq ($(TARGET), i686)
			# Host: Linux (arm64), Target: i686 (32bits)
			TOOL_PATH:=$(LINUX_PATH)$(TARGET)-linux-gnu-
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
CFLAGS+= -fno-stack-protector # no stack protector
CFLAGS+= -nostdinc # no standard header
CFLAGS+= -nostdlib # no standard library
# CFLAGS+= -m32 # (when using gcc target x86_64) i386 mode
CFLAGS+= -Wa,--32 # (when using i686 gcc) pass option to assembler (generate 32bits code)
CFLAGS:=$(strip ${CFLAGS})

BOOT_EP:=0x7c00
LOADER_EP:=0x1000
KERNEL_EP:=0x10000

DEBUG:= -g
INCLUDE:= -I $(SRC)/include/

$(BUILD)/boot/%.bin: $(SRC)/boot/%.asm
	$(shell mkdir -p $(dir $@))
	$(NASM) -f bin $< -o $@

$(BUILD)/%.o: $(SRC)/%.asm
	$(shell mkdir -p $(dir $@))
	$(NASM) -f elf32 -gdwarf $< -o $@

# change assembler from NASM to GNU AS(x86)
# $(BUILD)/boot/boot.bin: $(SRC)/boot/boot.S
# 	$(shell mkdir -p $(dir $@))
# 	$(AS) --gstabs $< -o $@.o
# 	$(LD) -m elf_i386 -static $@.o -o $@.elf -Ttext $(BOOT_EP)
# 	$(OBJCOPY) -O binary $@.elf $@

# $(BUILD)/boot/loader.bin: $(SRC)/boot/loader.S
# 	$(shell mkdir -p $(dir $@))
# 	$(AS) --gstabs $< -o $@.o
# 	$(LD) -m elf_i386 -static $@.o -o $@.elf -Ttext $(LOADER_EP)
# 	$(OBJCOPY) -O binary $@.elf $@

# $(BUILD)/%.o: $(SRC)/%.S
# 	$(shell mkdir -p $(dir $@))
# 	$(AS) --gstabs $< -o $@

$(BUILD)/%.o: $(SRC)/%.c
	$(shell mkdir -p $(dir $@))
	$(CC) $(CFLAGS) $(DEBUG) $(INCLUDE) -c $< -o $@

$(BUILD)/kernel.bin: \
	$(BUILD)/kernel/start.o \
	$(BUILD)/kernel/main.o \
	$(BUILD)/kernel/io.o \
	$(BUILD)/kernel/console.o \
	$(BUILD)/kernel/printk.o \
	$(BUILD)/lib/string.o \
	$(BUILD)/lib/vsprintf.o


	$(shell mkdir -p $(dir $@))
	$(LD) -m elf_i386 -static $^ -o $@ -Ttext $(KERNEL_EP)

$(BUILD)/system.bin: $(BUILD)/kernel.bin
	$(OBJCOPY) -O binary $< $@

$(BUILD)/system.map: $(BUILD)/kernel.bin
	nm $< | sort > $@

$(BUILD)/master.img: $(BUILD)/boot/boot.bin \
	$(BUILD)/boot/loader.bin \
	$(BUILD)/system.bin \
	$(BUILD)/system.map

	if ($(HOST_KERNEL) == Linux);then \
		yes | bximage -q -hd=16 -mode=create -sectsize=512 -imgmode=flat $@; \
	elif ($(HOST_KERNEL) == Darwin);then \
		yes | bximage -q -hd=16 -func=create -sectsize=512 -imgmode=flat $@; \
	fi
	dd if=$(BUILD)/boot/boot.bin of=$@ bs=512 count=1 conv=notrunc
	dd if=$(BUILD)/boot/loader.bin of=$@ bs=512 count=4 seek=2 conv=notrunc
	dd if=$(BUILD)/system.bin of=$@ bs=512 count=200 seek=10 conv=notrunc

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

	dd if=$(BUILD)/master.img of=/dev/sda

.PHONY: clean
clean:
	rm -rf $(BUILD); \
	rm $(SRC)/bochsrc*; 

# Windows win32 gui-debug (Linux as remote compiling machine, Windows machine as Local debugging machine)
.PHONY: image
image: $(BUILD)/master.img
	cp $(BOCHS_CONFIG)/win32_guidebug/bochsrc $(SRC)

.PHONY: disam_boot
disam_boot:
	$(OBJDUMP) -D -b binary -m i386:x86-64 $(BUILD)/boot/boot.bin

# Linux X11 gui-debug
.PHONY: bochs
bochs: $(BUILD)/master.img
	bochs -q -f $(BOCHS_CONFIG)/linux_x_guidebug/bochsrc
#	bochs-debugger -f $(BOCHS_CONFIG)/linux_x_guidebug/bochsrc # When debug in Fedora Linux

# Linux gdb
.PHONY: bochs_gdb
bochs_gdb: $(BUILD)/master.img
	bochs-gdb -q -f $(BOCHS_CONFIG)/linux_x_guidebug/bochsrc_gdb

.PHONY: qemu
qemu: $(BUILD)/master.img
	qemu-system-i386 \
	-m 32M \
	-boot c \
	-hda $<

.PHONY: qemu_gdb
qemu_gdb: $(BUILD)/master.img
	qemu-system-i386 \
	-s -S \
	-m 32M \
	-boot c \
	-hda $<

# generate vmware disk image
$(BUILD)/master.vmdk: $(BUILD)/master.img
	qemu-img convert -pO vmdk $< $@
.PHONY: vmdk
vmdk: $(BUILD)/master.vmdk

# # generate virtualbox disk image
# # the virtualbox always check the uuid and new image wouldn't match, thus depreciated
# $(BUILD)/master.vdi: $(BUILD)/master.img
# 	qemu-img convert -pO vdi $< $@
# .PHONY: vdi
# vdi: $(BUILD)/master.vdi

# # for testing image in usb drive in virtualbox before going physic machine test
# # should manually set path for IDE disk of usb.vmdk for usb test in virtualbox
# .PHONY: vbox_usb_test
# vbox_usb_test: usb
# 	sudo vboxmanage internalcommands createrawvmdk -filename $(BUILD)/usb.vmdk -rawdisk /dev/sda; \
# 	sudo chown kali:kali $(BUILD)/usb.vmdk

.PHONY: test
test: $(BUILD)/boot/boot.o