
.global task_switch

task_switch:
    push %ebp
    movl %esp, %ebp

    push %ebx
    push %esi
    push %edi

    movl %esp, %eax
    andl $0xfffff000, %eax

    movl %esp, (%eax)

    movl 8(%ebp), %eax
    movl (%eax), %esp

    pop %edi
    pop %esi
    pop %ebx
    pop %ebp

    ret
