SRC:=.
TEST=./test
BUILD:=./build
TEST_BUILD:=$(TEST)/build
BOCHS_CONFIG:=$(TEST)/bochs/config

# # x86_64 dev env (in Linux)
# CC=/usr/bin/gcc
# AS=/usr/bin/nasm
# LD=/usr/bin/ld

# aarch64 dev env (in MacOS)
# for m1 Mac (arm64) build (install by brew: x86_64-elf-binutils x86_64-elf-gcc x86_64-elf-gdb)
CC=/opt/homebrew/bin/x86_64-elf-gcc
AS=/opt/homebrew/bin/nasm
LD=/opt/homebrew/bin/x86_64-elf-ld

CFLAGS:= -m32
CFLAGS+= -fno-builtin # no built-in function in gcc
CFLAGS+= -fno-pic # no position independent code
CFLAGS+= -fno-pie # no position independent excutable
CFLAGS+= -fno-stack-protector # no stack protector
CFLAGS+= -nostdinc # no standard header
CFLAGS+= -nostdlib # no standard library
CFLAGS:=$(strip ${CFLAGS})

ENTRYPOINT:=0X10000
DEBUG:= -g
INCLUDE:= -I $(SRC)/include/

$(BUILD)/boot/%.bin: $(SRC)/boot/%.asm
	$(shell mkdir -p $(dir $@))
	$(AS) -f bin $< -o $@

$(BUILD)/%.o: $(SRC)/%.asm
	$(shell mkdir -p $(dir $@))
	$(AS) -f elf32 -gdwarf $< -o $@

$(BUILD)/%.o: $(SRC)/%.c
	$(shell mkdir -p $(dir $@))
	$(CC) $(CFLAGS) $(DEBUG) $(INCLUDE) -c $< -o $@

$(BUILD)/kernel.bin: \
	$(BUILD)/kernel/start.o \
	$(BUILD)/kernel/main.o \
	$(BUILD)/kernel/io.o \
	$(BUILD)/lib/string.o

	$(shell mkdir -p $(dir $@))
	$(LD) -m elf_i386 -static $^ -o $@ -Ttext $(ENTRYPOINT)

$(BUILD)/system.bin: $(BUILD)/kernel.bin
	objcopy -O binary $< $@

$(BUILD)/system.map: $(BUILD)/kernel.bin
	nm $< | sort > $@

$(BUILD)/master.img: $(BUILD)/boot/boot.bin \
	$(BUILD)/boot/loader.bin \
	$(BUILD)/system.bin \
	$(BUILD)/system.map \

	yes | bximage -q -hd=16 -func=create -sectsize=512 -imgmode=flat $@
	dd if=$(BUILD)/boot/boot.bin of=$@ bs=512 count=1 conv=notrunc
	dd if=$(BUILD)/boot/loader.bin of=$@ bs=512 count=4 seek=2 conv=notrunc
	dd if=$(BUILD)/system.bin of=$@ bs=512 count=200 seek=10 conv=notrunc

.PHONY: usb # sample code for write image to USB device
usb: $(BUILD)/master.img /dev/sda
	sudo dd if=/dev/sda of=$(BUILD)/boot/tmp.bin bs=512 count=1000 conv=notrunc
	cp $(BUILD)/boot/tmp.bin $(BUILD)/boot/usb.bin
	sudo rm $(BUILD)/boot/tmp.bin
	dd if=$(BUILD)/master.img of=$(BUILD)/boot/usb.bin bs=512 count=1000 conv=notrunc
	sudo dd if=$(BUILD)/boot/usb.bin of=/dev/sda bs=512 count=1000 conv=notrunc
	rm $(BUILD)/boot/usb.bin

.PHONY: clean
clean:
	rm -rf $(BUILD); \
	rm $(SRC)/bochsrc*; 

# Windows win32 gui-debug (Linux as remote compiling machine, Windows machine as Local debugging machine)
.PHONY: image
image: $(BUILD)/master.img
	cp $(BOCHS_CONFIG)/win32_guidebug/bochsrc $(SRC)

# # Windows gdb (Windows Local debugging using Samba)
# .PHONY: image_gdb
# image_gdb: $(BUILD)/master.img
# 	cp $(BOCHS_CONFIG)/win32_guidebug/bochsrc_gdb $(SRC)

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
