section	.rodata			; we define (global) read-only variables in .rodata section
	format_string: db "%s", 10, 0	; format string

section .bss			; we define (global) uninitialized variables in .bss section
	numx: resb 4 ; 		define int x
	numy: resb 4 ;		define int y
	an: resb 12 ; 
section .data
	msg db "illegal input",13,10,0
section .text
	global assFunc
	extern printf
	extern c_checkValidity

		assFunc:
		xor edi,edi
		mov edi,an
		push ebp
		mov ebp, esp	
		pushad	
		mov ecx, [ebp+8]   ;  get x-first argument
		mov edx, [ebp+12]  ;  get y-second argument
		push edx
		push ecx
		xor eax,eax
		call c_checkValidity
		pop ecx
		pop edx
		cmp eax , '0'
		je illegalValue

		add ecx,edx
		jmp pushStack

		illegalValue:
			push msg
			jmp toPrint

		pushStack:
		xor edx,edx
		mov eax,ecx
		mov ebx, dword 10
		mov cl,0

	pushJump:
		cmp eax, 0
		je prePopStack
		div ebx
		inc cl
		push edx
		xor edx, edx
		jmp pushJump

	prePopStack:
		xor eax, eax
		jmp popStack

		popStack:
		pop eax
		add eax, 48
		mov [edi], eax 
		inc edi
		dec cl
		cmp cl,0
		jnz popStack
		mov [edi+1], byte 0x00
		jmp toEnd	



	toEnd:		

	push an			; call printf with 2 arguments -  
	push format_string			; pointer to str and pointer to format string
	toPrint:
	call printf
	add esp, 8		; clean up stack after call

	popad			
	mov esp, ebp	
	pop ebp
	ret