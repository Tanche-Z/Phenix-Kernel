BUILD:=./build
SRC=.
BOCHS_CONFIG=./examples/bochs_config

ENTRYPOINT=0X10000

$(BUILD)/boot/%.bin: $(SRC)/boot/%.asm
	$(shell mkdir -p $(dir $@))
	nasm -f bin $< -o $@

$(BUILD)/kernel/%.o: $(SRC)/kernel/%.asm
	$(shell mkdir -p $(dir $@))
	nasm -f elf32 $< -o $@

$(BUILD)/kernel.bin: $(BUILD)/kernel/start.o
	$(shell mkdir -p $(dir $@))
	ld -m elf_i386 -static $^ -o $@ -Ttext $(ENTRYPOINT)

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
usb: $(BUILD)/boot/boot.bin /dev/sda
	sudo dd if=/dev/sda of=$(BUILD)/boot/tmp.bin bs=512 count=1 conv=notrunc
	cp $(BUILD)/boot/tmp.bin $(BUILD)/boot/usb.bin
	sudo rm $(BUILD)/boot/tmp.bin
	dd if=$(BUILD)/boot/boot.bin of=$(BUILD)/boot/usb.bin bs=446 count=1 conv=notrunc
	sudo dd if=$(BUILD)/boot/usb.bin of=/dev/sda bs=512 count=1 conv=notrunc
	rm $(BUILD)/boot/usb.bin

.PHONY: clean
clean:
	rm -rf $(BUILD)

# Windows win32 gui debug
.PHONY: image
image: $(BUILD)/master.img
	cp $(BOCHS_CONFIG)/win32_guidebug/bochsrc $(BUILD)

# Linux x11 gui debug
.PHONY: bochs
bochs: $(BUILD)/master.img
	cp $(BOCHS_CONFIG)/linux_x_guidebug/bochsrc $(BUILD)
	bochs -q
#	bochs-debugger -q # When debug in Fedora Linux

test: $(BUILD)/master.img