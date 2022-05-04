# *****+. =***+====+*Fk U Nvidia!!!***********
# *****+. =*++==++*+-+**----Linus Torvalds****
# *****+. ===+-...:-===+**********************
# *****+..=+*-:-------=++*********************
# *****+:.=*=--======--=++********************
# *****+:.=*==**#*=##*+=++********************
# *****+:.=++++**=:+++=-+*********************
# *****+:.=*=-=*%***===-+*********************
# *****+:.=++=*#%#**+++==+********************
# *****+:.-+=*#%%#*+++++**********************
# *****+:.-*#%%%%%#*++++**********************
# *****+:.-+#%%%%%%#**+==*********************
# *****+:.-+#%%%%%%#**+++-***#****************
# *****+-=+*#%%%%%%#**+*+.*#%######*#*********
# *******###%%%%%%%*==+==+*%%%######%#********
# ********#%%%%%%%#+=+===+*#%%######%%#*******
# ##%#######%%%%%%*=======*%%%%%%###%%%#******
# #%%%%%%%%+%%%%%%#=---::-+%%%%%%%%%%%%%******
# #%####%%+:#%%%%%%*---:.:-%%%%%%%%%%%%%#*****
# *##%%%%%-:+*%%%%%%=:::..:#%%%%%%%%@@%%%#****
# *#%%%%#%*---=+*%%%#-:...:*%%%%%%%%@@%%%%****
# **%###%%%*+===#@@@%=-::::=%%%%%@@@@@%%%%#***
# **###%%@@@%*+*#@@@%=--:::-%%%%@@@@@@@%%#%***
# ***#%@@@@@@%#*%@@@%=-:::--*%%@@@@@@@@@%%##**
# ***%%@@%@@@@@@@@@%#--..:--+%%%@@@@@@@@@@@%*+
# ***%%@@@@@@@@@@@%%*=-..:--=%%%@@@@@@@##%%%#+
# ***%@@@@@@@@@@@@%%+=:..:---#%%@@@@@@@%##%%%*

TEST=.
TEST_BUILD:=$(TEST)/build
MK_TEST_BUILD:=mkdir -p $(TEST_BUILD)

CFLAGS:= -m32
# CFLAGS+= -fno-builtin # no built-in function in gcc
CFLAGS+= -fno-pic # no position independent code
# CFLAGS+= -fno-pie # no position independent excutable
# CFLAGS+= -fno-stack-protector # no stack protector
CFLAGS+= -fno-asynchronous-unwind-tables # no CFI (Call Frame Information)
# CFLAGS+= -nostdinc # no standard header
# CFLAGS+= -nostdlib # no standard library
CFLAGS+= -Qn # no gcc version info
CFLAGS+= -mpreferred-stack-boundary=2 # no stack align
# CFLAGS+= -fomit-frame-pointer # no stack frame
CFLAGS:=$(strip ${CFLAGS})


.PHONY: hello.s
hello.s: hello.c
	gcc $(CFLAGS) -S $< -o $@
	$(MK_TEST_BUILD)
	mv $@ $(TEST_BUILD)

.PHONY: params.s
params.s: params.c
	gcc $(CFLAGS) -S $< -o $@
	$(MK_TEST_BUILD)
	mv $@ $(TEST_BUILD)

.PHONY: clean
clean:
	rm -rf $(TEST_BUILD)