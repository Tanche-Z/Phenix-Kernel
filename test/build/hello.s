	.file	"hello.c"
	.text
	.globl	hello
	.data
	.align 4
	.type	hello, @object
	.size	hello, 16
hello:
	.string	"Hello World!!!\n"
	.globl	buf
	.bss
	.align 32
	.type	buf, @object
	.size	buf, 1024
buf:
	.zero	1024
	.text
	.globl	main
	.type	main, @function
main:
	leal	4(%esp), %ecx
	andl	$-16, %esp
	pushl	-4(%ecx)
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ecx
	subl	$4, %esp
	subl	$12, %esp
	pushl	$hello
	call	printf
	addl	$16, %esp
	movl	$0, %eax
	movl	-4(%ebp), %ecx
	leave
	leal	-4(%ecx), %esp
	ret
	.size	main, .-main
	.section	.note.GNU-stack,"",@progbits
