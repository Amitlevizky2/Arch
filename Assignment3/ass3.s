
%macro print_t 2
    push %1
    push %2
    call printf
    add esp, 8
%endmacro

%macro print_float 0
    fld qword [res]
    sub esp,8
    fstp qword [esp]
    push format_string_2f
    call printf
    add esp,12
    %endmacro


%macro create_random 1
        push dword %1
        call random_number 
        add esp, 4
    %endmacro


%macro callscanf 3
    push dword %1                   ; arg3
    push dword %2                   ; arg2
    push dword %3                   ; arg1
    call sscanf
    add esp, 12
%endmacro

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


section .data
    format_string_s : db "%s",0 
    format_string : db "%d",10,0 
    down :db '',10,0
    format_string_int: db "%d", 10, 0   ; format string int
    format_string_float: db "%f", 10, 0 ; format string float
    format_string_floatl: db "%lf", 10, 0 ; format string float
    format_string_2f: db "%.2f",10,0 ; float 2 numbers after dot
    degree equ 360
    distance equ 100
    maxint: dd 0xffff
    bignum: DD 0
    res : dd 0



section .bss
    N : resd 1                          ; Number of drones
    T : resd 1                          ; Number of targets to destroy to win the game
    K : resd 1                          ; How many drone steps between game board printings
    beta : rest 1                       ; Angle of drone field-of-view
    d : rest 1                          ; Maximum distance that allows to destroy a target
    seed : resd 1                       ; Seed for initialization of LFSR shift register
    CORS : resd 1                       ; Number of all the co-routines in the program

    ;------------Co-routines fields------------;
    CURR: resd 1
    SPT: resd 1
    SPMAIN: resd 1
    STKSZ equ 16*1024
    CODEP equ 0
    SPP equ 4
    




section .text                           ; functions from c libary
  align 16
     global main 
     global random_number
     extern printf 
     extern fprintf
     extern sscanf
     extern malloc
     extern free
     extern mayDestroy

main:

    mov eax, dword [esp + 8]

    getArgsValues:
        pushad
        callscanf N, format_string_int, dword [eax + 4]     ; Number of drones
        popad

        pushad
        callscanf T, format_string_int,dword [eax + 8]      ; Number of targets to destroy to win the game
        popad

        pushad
        callscanf K, format_string_int, dword [eax + 12]        ; How many drone steps between game board printings
        popad

        pushad
        callscanf beta, format_string_float, dword [eax + 16]  ; Angle of drone field-of-view
        popad

        pushad
        callscanf d, format_string_float, dword [eax + 20]  ; Maximum distance that allows to destroy a target
        popad

        pushad
        callscanf seed, format_string_int, dword [eax + 24] ; Seed for initialization of LFSR shift register
        popad

            
     
    ;set the number of co-routins in CORS to be N+3
    AlcCoRoutins:
        xor ecx, ecx
        xor ebx, ebx
        mov ecx, [N]                    ; Number of co-routins
        add ecx, dword 2                ; Plus the printer and schedual co-routines
        cmp dword [N], 0                ; Check the Co-routine number > 0
        je endAlcCoRou
        pushad                          ; Saves the state of the registers
        ;mov ebx, (N+2)*8                   ; Set size for allocation to be (4 + 4) * (N + 2)
        ;dec ecx                            ; After alloc the first co-routine
        push STKSZ                      ; parameter to malloc
        call malloc
        add esp, 4
        mov dword [CORS], eax           ; eax keeps the address to the alocated memory
        popad                           ; rerieve the state of the registers

        xor edi, edi
        xor ebx, ebx

        allocLoop:
            pushad
            push STKSZ
            call malloc                     ; Allocate stack size
            add esp, 4
            mov ebx, dword [CORS]
            add ebx, dword edi
            mov dword [ebx + 4], eax        ; Set  cell in Cors array to point to  alocated stack
            popad
            add edi, dword 8
            loop allocLoop, ecx
        
        endAlcCoRou:
        create_random distance
        print_float
        create_random degree
        print_float
        jmp endAss3
    
    ;----------initCo Function---------;
    initCo:
        startFunction               ; get co-routine ID number
        mov ebx, [4*ebx + CORS]     ; get pointer to COi struct
        mov eax, [ebx+CODEP]        ; get initial EIP value – pointer to COi function
        mov [SPT], ESP              ; save ESP value
        mov esp, [EBX+SPP]          ; get initial ESP value – pointer to COi stack
        push eax                    ; push initial “return” address
        pushfd                      ; push flags
        pushad                      ; push all other registers
        mov [ebx+SPP], esp          ; save new SPi value (after all the pushes)
        mov ESP, [SPT]              ; restore ESP value
        endFunction
    ;----------end initCo Function---------;
    
    
   
    random_number:
        startFunction
        mov dword [bignum],ebx

 LFSR:  
        mov edi,16
        looplfsr:
        cmp edi,0
        je end1
        mov eax, 1
        mov esi, 1
        xor ebx, ebx
        mov ebx, [seed]
        and eax, ebx                ;find the 16 bit
        shr  ebx, 2
        and esi, ebx                ;find the 14 bit
        xor eax, esi                ;xor 16's bit with 14's bit
        shr  ebx, 1
        mov esi, 1
        and esi, ebx                ;find the 13 bit
        xor eax, esi                ;xor previos xor result of bit with 13s bit
        shr  ebx, 2
        mov esi, 1
        and esi, ebx                 ;find the 11 bit
        xor eax, esi                ;xor previos xor result of bit with 11s bit
        shl eax,  15
        shr dword[seed], 1
        xor dword [seed], eax       ;genatate the new seed number
        dec edi
        jmp looplfsr
        end1:
        

    scaling:
        finit
        fild dword [bignum]
        fild dword [maxint]
        fdiv
        fild dword [seed]
        fmul
        fstp qword [res] 
    endFunction

    


endAss3:
