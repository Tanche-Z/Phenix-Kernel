TEST=.
TEST_BUILD:=$(TEST)/build

CFLAGS:= -m32
# CFLAGS+= -fno-builtin # no built-in function in gcc
# CFLAGS+= -fno-pic # no position independent code
# CFLAGS+= -fno-pie # no position independent excutable
# CFLAGS+= -fno-stack-protector # no stack protector
CFLAGS+= -fno-asynchronous-unwind-tables # no CFI (Call Frame Information)
# CFLAGS+= -nostdinc # no standard header
# CFLAGS+= -nostdlib # no standard library
CFLAGS:=$(strip ${CFLAGS})

$(TEST_BUILD)/hello.s: $(TEST)/hello.c
	$(shell mkdir -p $(dir $@))
	gcc $(CFLAGS) -S $< -o $@

.PHONY: hello.s
hello.s: $(TEST_BUILD)/hello.s

.PHONY: clean
clean:
	rm -rf $(TEST_BUILD)