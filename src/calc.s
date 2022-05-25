extern printf
extern c_checkValidity

section .bss
	input_buffer: resb 1024
	op_count: resd 1
	op_stack_ptr: resd 1
	op_stack_cap: resd 1

section .data
    set_cap_msg:        db "setting stack capacity to %d", 10, 0
    debug_msg:          db "got here", 10, 0
	prompt_msg:         db "calc: ", 0;
	over_flow_error:    db "Error: Operand Stack Overflow", 10, 0;
	arguments_error:    db "Error: Insufficient Number of Arguments on Stack", 10, 0;
	arg_count_err_msg:  db "Error: invalid number of arguments", 10, 0;
	invalid_number_msg: db "Error: the number entered is invalid", 10, 0
	num_fmt: db "%X", 10, 0;
	str_fmt: db "%s", 10, 0;
	chr_fmt: db "%c", 10, 0;

	operations: db "q", "addition", "pnp", "dup", "bit_and", "bit_or", "n"

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
    xor ebx, ebx
    mov ebx, 5          ; default stack capacity
    mov eax, [ebp+8]        ; eax = argc
    cmp eax, 2
    jg arg_count_err
    jne default_capacity
    mov edi, [ebp+12]       ; edi = argv (char**)
    add edi, 4              ; edi = argv + 1
    mov edi, [edi]
    call string_to_hexa     ; ebx = int value of (argv + 1)

default_capacity:
    mov dword [op_stack_cap], ebx
    push dword [op_stack_cap]
    push set_cap_msg
    call printf
    add esp, 8
    mov [op_stack_ptr], esp
    sub esp, ebx
    mov dword [op_count], 0
iteration:
	call prompt
	call get_input          ; input_buff filled with user input
	mov ebx, dword[input_buffer]
	cmp bl, "+"
	je addition
	cmp bl, "p"
	je pnp
	cmp bl, "d"
	je dup
	cmp bl, "n"
	je n
	cmp bl, "&"
	je bit_and
	cmp bl, "|"
	je bit_or
	cmp bl, "q"
	je q
	mov edi, input_buffer
	call string_to_hexa
	call insert
	jmp iteration

string_to_hexa:
    ; INPUT: edi - char* of the number
    ; OUTPUT: eax - int value of edi string
    xor eax,eax    ; clear ebx
.next_digit:
    movzx ebx, byte[edi]
    inc edi
    cmp bl , '0'
    jb .invalid
    cmp bl, 'F'
    ja .invalid
    cmp bl, '9'
    jbe .valid_dec
    cmp bl, 'A'
    jae .valid_hex
    jmp .invalid
.valid_hex:
    sub bl, 7
.valid_dec:
    sub bl, '0'
    imul eax,16
    add eax,ebx
    cmp byte[edi], 0
    jne .next_digit
    ret
.invalid:
    push dword invalid_number_msg
    push str_fmt
    call printf
    add esp, 8
    jmp iteration

get_input:
    pushad
    mov eax, 3
    mov ebx, 0
    mov ecx, input_buffer
    mov edx, MAX_INPUT
    int 0x80
    dec eax
    mov byte[input_buffer + eax], 0
    popad
    ret

prompt:
    pushad
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_msg
    mov edx, 6
    int 0x80
    popad
    ret

insert:
    ; input: eax = number to insert
    mov edx, [op_stack_cap]
    cmp dword [op_count], edx
    jne .exe_insert
    push over_flow_error
    call printf
    add esp, 4
    ret
    .exe_insert:
        mov ecx, [op_stack_ptr]
        mov [ecx], eax
        sub ecx, 4
        mov [op_stack_ptr], ecx
        inc dword [op_count]
        ret

addition:
    cmp dword [op_count], 2
    jge .exe_addition
    push arguments_error
    call printf
    add esp, 4
    jmp iteration
.exe_addition:
    mov ecx, [op_stack_ptr]
	mov eax, [ecx+4]
	mov ebx, [ecx+8]
	add ecx, 8
	mov [op_stack_ptr], ecx
	sub dword [op_count], 2
    add eax, ebx
	call insert
	jmp iteration

pnp:
    ; attempt to pop an operand from the stack, if available then print
    cmp dword [op_count], 1
    jge .exe_pnp
    push arguments_error
    call printf
    add esp, 4
    jmp iteration
    .exe_pnp:
        mov ecx, [op_stack_ptr]
        mov eax, [ecx+4]
        pushad
        push eax
        push num_fmt
        call printf
        add esp, 8
        popad
        add ecx, 4
        mov [op_stack_ptr], ecx
        dec dword [op_count]
        jmp iteration

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
