struc IDTEntry
    .offsetl resw 1
    .selector resw 1
    .zero resb 1
    .attribute resb 1
        .present equ 1 << 7
        .ring.1	equ 1 << 5
        .ring.2 equ 1 << 6
        .ring.3 equ 1 << 5 | 1 << 6
        .task32 equ 0x5
        .interrupt16 equ 0x6
        .trap16 equ 0x7
        .interrupt32 equ 0xE
        .trap32 equ 0xF
    .offseth resw 1
endstruc

[section .text]
[BITS 64]
interrupts:
.first:
    mov [0x200000], byte 0
    jmp qword .handle
.second:
%assign i 1
%rep 255
    mov [0x200000], byte i
    jmp qword .handle
%assign i i+1
%endrep
.handle:
    push rax
    push rcx
    push rdx
    push rbx
    push rsp
    push rbp
    push rsi
    push rdi
    push qword [0x200000]
    push r8
    push r9
    push r10
    push r11
    push r12
    push r13
    push r14
    push r15
    call [.handler]
    ;Put return value in stack for popad
    mov [esp + 32], eax
    pop r15
    pop r14
    pop r13
    pop r12
    pop r11
    pop r10
    pop r9
    pop r8
    add esp, 8
    pop rdi
    pop rsi
    pop rbp
    add esp, 8
    pop rbx
    pop rdx
    pop rcx
    pop rax
    iretq

.handler: dq 0

idtr:
    dw (idt_end - idt) + 1
    dd idt

idt:
%assign i 0
%rep 256	;fill in overrideable functions
	istruc IDTEntry
		at IDTEntry.offsetl, dw interrupts+(interrupts.second-interrupts.first)*i
		at IDTEntry.selector, dw 0x08
		at IDTEntry.attribute, db IDTEntry.present | IDTEntry.interrupt32
	iend
%assign i i+1
%endrep
idt_end:
