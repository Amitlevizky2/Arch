macros:
	%macro startFunction 0
        push    ebp
        mov     ebp, esp
        sub     esp, 4
        pusha
        mov     ebx, dword[ebp + 8]
	%endmacro

	%macro endFunction 0
        popa
        mov     esp, ebp
        pop     ebp
        ret
	%endmacro
    
	%macro endFunctionParameter 0
        mov     eax, dword[ebp-4]
        mov     esp, ebp
        pop     ebp
        ret
	%endmacro
%macro generate_num 2
        push %1
        push %2
        call random_number
        add esp,8
%endmacro

%macro in_renage 1
	fld qword [%1]
	fcomi dword [dis]
	jg %%bigger
	fcomi 0
	jl %%lower
	%%jmp endmacro_in
	%%bigger:
		fsub dword [dis]
		fstp qword [%1]
		%%jmp endmacro_in
	%%lower:
		fadd dword [dis]
		fstp qword [%1]
	%%endmacro_in:		
%endmacro

%macro update_delta 1
	sub esp,8
	xor ebx,ebx
	xor edx,edx
	mov ebp,esp
	mov ebx,[ebp]
	mov dword [%1],ebx
	mov edx,[ebp+4]
	mov dword [%1+4],edx
	add esp,8
%endmacro

%macro zero_q 1
	mov dword [%1],0
    mov dword [%1+4],0
%endmacro


%macro print_float 0
    fld qword [res]
    sub esp,8
    fstp qword [esp]
    push format_string_2f
    call printf
    add esp,12
    %endmacro

section .data
	deg equ 360
	dis equ 100
	deg1 equ 60
	dis1 equ 50
	degree: dd 0
	olddegree: dd 0
	distance: dd 0
	olddistance: dd 0
	x1: dd 0			;first x cordinate
	x2: dd 0			;delta x cordinate
	y1: dd 0 			;first y cordinate		
	y2: dd 0			;first y cordinate
	maxint : DD 0xffff
	format_string_2f: db "%.2f",10,0 ; float 2 numbers after dot
	format_string : db "%d",10,0 


 


section .bss

section .text                           ; functions from c libary
  align 16
	 global drone:function
	 extern ass3
	 extern random_number
	 extern target
     extern scheduler
     extern printer
     extern printf 
     extern fprintf
     extern sscanf
     extern malloc
     extern free
     drone:
     	finit
     	xor ebx,ebx
     	generate_num ebx,dis
     	fld qword [res]
     	fstp qword [x1]
     	zero_q res
     	generate_num ebx,dis
     	fld qword [res]
     	fstp qword [y1]



     calc_gagree:
     	
     	generate_num deg1,deg
     	fld qword [res]
    	fld qword [olddegree]
    	zero_q degree
    	update_delta degree
    	fld dword [degree]
    	fadd
    	zero_q olddegree
    	update_delta olddegree
    	fild olddegree
    	fcomi dwrod [deg]
    	jl nofixdegree 
    	fild olddegree
    	fsub dword [deg]
    	zero_q olddegree
    	update_delta olddegree
    	nofixdegree:


   	 calc_dist: 	
    	zero_q res
    	zero_q x2			
    	zero_q y2
     	generate_num dis1,dis
     	fld qword [olddegree]		;load angle into st0
     	fcos						;st0 = cos(ang)
     	fmul qword [res]			;st0 = cos(ang) * distance
     	fstp qword [x2]
     	fld qword [x1]
     	fadd qword [x2]
     	zero_q x1
     	fstp qword [x1]
     	in_renage x1
     	fld qword [olddegree]		;load angle into st0
     	fsin 						;st0 = cos(ang)
     	fmul qword [res]			;st0 = cos(ang) * distance
     	fstp qword [y2]
     	fld qword [y1]
     	fadd qword [y2]
     	zero_q y1
     	fstp qword [y1]
     	in_renage y1
    	zero_q res 
    	





