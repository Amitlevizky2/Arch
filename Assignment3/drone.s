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
    fild dword [dis]
    fcomip
    jg %%bigger
    fld qword [%1]
    ftst
    jl %%lower
   jmp  %%endmacro_in
    %%bigger:
        fsub dword [dis]
        fstp qword [%1]
        jmp %%endmacro_in
    %%lower:
        fadd dword [dis]
        fstp qword [%1]
    %%endmacro_in:      
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




section .text                           ; functions from c libary
  align 16

     global drone:function
     extern ass3
     extern res
     extern CURR
     extern x1
     extern beta
     extern d
     extern y1
     extern dronesArray
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
        xor eax,eax
        mov eax,dword [CURR]
        add eax,8
        shl eax,2
        xor ebx,ebx
        mov ebx,dword [dronesArray]


 
     calc_gagree:
        
        generate_num deg1,deg
        fld qword [res]
        fld qword [olddegree]               ; drone old degree
        fadd
        fstp qword [olddegree]
        fld qword [olddegree]
        fild dword [deg]    
        fcomip
        jl nofixdegree 
        fild qword [olddegree]
        fsub dword [deg]
        zero_q olddegree
        fstp qword [olddegree]
        nofixdegree:


     calc_dist:     
        zero_q res
        zero_q x2           
        zero_q y2
        generate_num dis1,dis
        fld qword [olddegree]       ;load angle into st0
        fld qword [rad]
        fmul
        fcos                        ;st0 = cos(ang)
        fmul qword [res]            ;st0 = cos(ang) * distance
        fstp qword [x2]             ; distance*cos(deg)
        fld qword [x1]
        fadd qword [x2]
        zero_q x1
        fstp qword [x1]             ;new x place
        in_renage x1
        fld qword [olddegree]       ;load angle into st0
        fld qword [rad]
        fmul
        fsin                        ;st0 = cos(ang)
        fmul qword [res]            ;st0 = cos(ang) * distance
        fstp qword [y2]             ;distance*cos(deg)
        fld qword [y1]
        fadd qword [y2]
        zero_q y1
        fstp qword [y1]             ;new y place
        in_renage y1
        zero_q res 




        

section .data
    deg equ 360
    dis equ 100
    deg1 equ 60
    dis1 equ 50
    rad : dq 0.01745329251
    degree: dd 0
    olddegree: dd 0
    distance: dd 0
    olddistance: dd 0
    x2: dd 0            ;delta x cordinate     
    y2: dd 0            ;first y cordinate
    maxint : DD 0xffff
    format_string_2f: db "%.2f",10,0 ; float 2 numbers after dot
    format_string : db "%d",10,0 


section .bss


