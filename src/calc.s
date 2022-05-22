extern printf
extern c_checkValidity

section .bss
	input_buff: resb 1024
	op_stack_ptr: resd 1
	op_stack_cap: resd 1

section .data
	prompt_msg:    db "calc: ", 0;
	over_flow_error: db "Error: Operand Stack Overflow", 10, 0;
	arguments_error: db "Error: Insufficient Number of Arguments on Stack", 10, 0;
	arg_count_err_msg: db "Error: invalid number of arguments", 10, 0;
	num_fmt: db "%d", 10, 0;
	str_fmt: db "%s", 10, 0;
	chr_fmt: db "%c", 10, 0;

	operations: dd q, addition, pnp, dup, bit_and, bit_or, n

section .rodata
    MAX_INPUT: dd 1024


section .text
	global main
	extern fgets
	align 16
	extern printf
	extern fprintf 
	extern fflush
	extern malloc 
	extern calloc 
	extern free 
	extern gets 
	extern getchar 
	extern fgets 
	extern stdout
	extern stdin
	extern stderr

main:
    push ebp
    mov ebp, esp
    mov eax, [ebp+8]
    cmp eax, 2
    jb arg_count_err
    mov ebx, [ebp+12]
    add ebx, 4
    push dword [ebx]
    push str_fmt
    call printf
    cmp ecx, 2
    jb q
	push ebp
	mov ebp, esp
;	mov eax, [ebp+8]
;	mov [op_stack_cap], eax
;	xor ecx, ecx
;	mov esi, esp
;	sub esp, eax

	call prompt
	call get_input
	push input_buff
	push str_fmt;
	call printf
	add esp, 8
	jmp q

get_input:
    pushad
    mov eax, 3
    mov ebx, 0
    mov ecx, input_buff
    mov edx, MAX_INPUT
    int 0x80
    popad
    ret

prompt:
    push dword prompt_msg
    call printf
    add esp, 4
    ret

insert:
    pop eax
    cmp ecx, [op_stack_cap]
    jne exe_insert
    push over_flow_error
    call printf
    ret
    exe_insert:
	sub esi, 4
	mov [esi], eax
	inc ecx
	ret


addition:
    ; attemp to pop 2 operands from stack and perform addition, then insert
    cmp ecx, 2
    jge exe_addition
    push arguments_error
    call printf
    add esp, 4
    ret
    exe_addition:
	mov eax, [esi]
	mov ebx, [esi+4]
	add esi, 8
	sub ecx, 2
        add eax, ebx
        push eax
	call insert
	add esp, 4
	ret

pnp:
    ; attemp to pop an operand from the stack, if available then print
    cmp ecx, 1
    jge exe_pnp
    push arguments_error
    call printf
    add esp, 4
    ret
    exe_pnp:
	mov eax, [esi]
	add esi, 4
	dec ecx
	push eax
	push dword [num_fmt]
	call printf
	add esp, 8
	ret

dup:
    ; check if there is an argument to duplicate, if not error, else insert a copy
    cmp ecx, 1
    jge exe_dup
    push arguments_error
    call printf
    add esp, 4
    ret
    exe_dup:
	mov eax, [esi]
	push eax
	call insert
	add esp, 4
	ret

bit_and:
    cmp ecx, 2
    jge exe_and
    push arguments_error
    call printf
    add esp, 4
    ret
    exe_and:
        mov eax, [esi]
        mov ebx, [esi+4]
        and eax, ebx
        push eax
        call insert
        add esp, 4
        ret

bit_or:
    cmp ecx, 2
    jge exe_or
    push arguments_error
    call printf
    add esp, 4
    ret
    exe_or:
        mov eax, [esi]
        mov ebx, [esi+4]
        or eax, ebx
        push eax
        call insert
        add esp, 4
        ret

n:
    cmp ecx, 1
        jge exe_n
        push arguments_error
        call printf
        add esp, 4
        ret
    exe_n:
        mov eax, [esi]

arg_count_err:
    push arg_count_err_msg
    call printf
    add esp, 4

q:
	mov esp, ebp
	pop ebp
	mov eax, 0
	nop
